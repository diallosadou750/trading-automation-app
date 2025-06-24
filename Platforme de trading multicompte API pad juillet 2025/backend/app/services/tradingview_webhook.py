import hmac
import hashlib
import json
from typing import Dict, Optional
from fastapi import Request, HTTPException
from .trading_executor import TradingExecutor
import os
import logging
import aiohttp

class TradingViewWebhookService:
    def __init__(self, trading_executor: TradingExecutor):
        self.trading_executor = trading_executor
        self.webhook_secret = os.environ.get("TRADINGVIEW_WEBHOOK_SECRET", "")
        
    async def process_webhook(self, request: Request) -> Dict:
        """Traiter un webhook TradingView"""
        try:
            # Récupérer le body de la requête
            body = await request.body()
            signature = request.headers.get("X-Signature", "")
            
            # Valider la signature
            if not self._verify_signature(body, signature):
                raise HTTPException(status_code=401, detail="Signature invalide")
            
            # Parser le JSON
            data = json.loads(body)
            
            # Valider la structure du signal
            if not self._validate_signal_structure(data):
                raise HTTPException(status_code=400, detail="Structure de signal invalide")
            
            # Traiter le signal
            result = await self._process_signal(data)
            
            return {
                "status": "success",
                "message": "Signal traité avec succès",
                "trade_id": result.get("trade_id"),
                "signal": data
            }
            
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="JSON invalide")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Erreur interne: {str(e)}")
    
    def _verify_signature(self, body: bytes, signature: str) -> bool:
        """Vérifier la signature du webhook"""
        if not self.webhook_secret:
            return True  # Pas de vérification si pas de secret configuré
        
        expected_signature = hmac.new(
            self.webhook_secret.encode(),
            body,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(signature, expected_signature)
    
    def _validate_signal_structure(self, data: Dict) -> bool:
        """Valider la structure du signal TradingView"""
        required_fields = ["symbol", "side", "strategy"]
        optional_fields = ["quantity", "price", "stop_loss", "take_profit", "exchange"]
        
        # Vérifier les champs requis
        for field in required_fields:
            if field not in data:
                return False
        
        # Vérifier les types
        if not isinstance(data["symbol"], str):
            return False
        if data["side"] not in ["BUY", "SELL"]:
            return False
        if not isinstance(data["strategy"], str):
            return False
        
        return True
    
    async def _process_signal(self, signal_data: Dict) -> Dict:
        """Traiter un signal de trading"""
        # Extraire les données du signal
        symbol = signal_data["symbol"]
        side = signal_data["side"]
        strategy = signal_data["strategy"]
        quantity = signal_data.get("quantity", 0.01)  # Quantité par défaut
        price = signal_data.get("price")
        stop_loss = signal_data.get("stop_loss")
        take_profit = signal_data.get("take_profit")
        exchange = signal_data.get("exchange", "binance")  # Exchange par défaut
        
        # Log du signal reçu
        logging.info(f"Signal TradingView reçu: {symbol} {side} via {strategy}")
        
        # Exécuter le trade
        trade_result = await self.trading_executor.execute_trade(
            symbol=symbol,
            side=side,
            quantity=quantity,
            exchange=exchange,
            strategy=strategy,
            stop_loss=stop_loss,
            take_profit=take_profit,
            source="tradingview_webhook"
        )
        
        # Envoyer une notification
        await self._send_trade_notification(signal_data, trade_result)
        
        return trade_result
    
    async def _send_trade_notification(self, signal: Dict, result: Dict):
        """Envoyer une notification de trade exécuté"""
        message = f"""
🚨 Trade exécuté via TradingView

📊 Signal: {signal['symbol']} {signal['side']}
📈 Stratégie: {signal['strategy']}
💰 Quantité: {signal.get('quantity', 'N/A')}
🏢 Exchange: {signal.get('exchange', 'N/A')}

✅ Résultat: {result.get('status', 'N/A')}
🆔 Trade ID: {result.get('trade_id', 'N/A')}
        """
        
        # Envoyer via Telegram
        await self._send_telegram_notification(message)
    
    async def _send_telegram_notification(self, message: str):
        """Envoyer une notification Telegram"""
        bot_token = os.environ.get("TELEGRAM_BOT_TOKEN")
        chat_id = os.environ.get("TELEGRAM_CHAT_ID")
        
        if not bot_token or not chat_id:
            return
        
        try:
            url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
            async with aiohttp.ClientSession() as session:
                await session.post(url, json={
                    "chat_id": chat_id,
                    "text": message,
                    "parse_mode": "HTML"
                })
        except Exception as e:
            logging.error(f"Erreur envoi notification Telegram: {e}")
    
    def get_webhook_url(self) -> str:
        """Générer l'URL du webhook pour TradingView"""
        base_url = os.environ.get("BASE_URL", "http://localhost:8000")
        return f"{base_url}/webhook/tradingview" 
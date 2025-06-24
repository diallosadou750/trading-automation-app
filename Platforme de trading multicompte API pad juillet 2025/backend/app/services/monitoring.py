import logging
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import aiohttp
import json
import os

class MonitoringService:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.performance_metrics: Dict[str, List[float]] = {}
        self.error_counts: Dict[str, int] = {}
        self.alert_thresholds = {
            "error_rate": 0.05,  # 5% d'erreurs
            "response_time": 2.0,  # 2 secondes
            "memory_usage": 0.8,  # 80% de mémoire
        }
        
    async def log_performance(self, endpoint: str, response_time: float):
        """Enregistrer les métriques de performance"""
        if endpoint not in self.performance_metrics:
            self.performance_metrics[endpoint] = []
        
        self.performance_metrics[endpoint].append(response_time)
        
        # Garder seulement les 1000 dernières mesures
        if len(self.performance_metrics[endpoint]) > 1000:
            self.performance_metrics[endpoint] = self.performance_metrics[endpoint][-1000:]
        
        # Vérifier les seuils d'alerte
        await self._check_performance_alerts(endpoint, response_time)
    
    async def log_error(self, error_type: str, error_message: str, context: Dict = None):
        """Enregistrer les erreurs"""
        if error_type not in self.error_counts:
            self.error_counts[error_type] = 0
        
        self.error_counts[error_type] += 1
        
        # Log détaillé de l'erreur
        self.logger.error(f"Error {error_type}: {error_message}", extra={
            "error_type": error_type,
            "error_message": error_message,
            "context": context or {},
            "timestamp": datetime.utcnow().isoformat()
        })
        
        # Vérifier les seuils d'alerte
        await self._check_error_alerts(error_type)
    
    async def _check_performance_alerts(self, endpoint: str, response_time: float):
        """Vérifier les alertes de performance"""
        if response_time > self.alert_thresholds["response_time"]:
            await self._send_alert(
                "PERFORMANCE",
                f"Temps de réponse élevé sur {endpoint}: {response_time:.2f}s"
            )
    
    async def _check_error_alerts(self, error_type: str):
        """Vérifier les alertes d'erreur"""
        total_requests = sum(len(metrics) for metrics in self.performance_metrics.values())
        if total_requests > 0:
            error_rate = self.error_counts.get(error_type, 0) / total_requests
            if error_rate > self.alert_thresholds["error_rate"]:
                await self._send_alert(
                    "ERROR",
                    f"Taux d'erreur élevé pour {error_type}: {error_rate:.2%}"
                )
    
    async def _send_alert(self, alert_type: str, message: str):
        """Envoyer une alerte"""
        alert_data = {
            "type": alert_type,
            "message": message,
            "timestamp": datetime.utcnow().isoformat(),
            "service": "trading-api"
        }
        
        # Log de l'alerte
        self.logger.warning(f"ALERT: {alert_type} - {message}")
        
        # Envoyer via webhook (configurable)
        await self._send_webhook_alert(alert_data)
        
        # Envoyer via Telegram (si configuré)
        await self._send_telegram_alert(alert_data)
    
    async def _send_webhook_alert(self, alert_data: Dict):
        """Envoyer une alerte via webhook"""
        webhook_url = os.environ.get("ALERT_WEBHOOK_URL")
        if not webhook_url:
            return
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.post(webhook_url, json=alert_data) as response:
                    if response.status != 200:
                        self.logger.error(f"Échec envoi webhook: {response.status}")
        except Exception as e:
            self.logger.error(f"Erreur envoi webhook: {e}")
    
    async def _send_telegram_alert(self, alert_data: Dict):
        """Envoyer une alerte via Telegram"""
        bot_token = os.environ.get("TELEGRAM_BOT_TOKEN")
        chat_id = os.environ.get("TELEGRAM_CHAT_ID")
        
        if not bot_token or not chat_id:
            return
        
        try:
            message = f"🚨 ALERTE {alert_data['type']}\n\n{alert_data['message']}\n\n⏰ {alert_data['timestamp']}"
            url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
            
            async with aiohttp.ClientSession() as session:
                async with session.post(url, json={
                    "chat_id": chat_id,
                    "text": message,
                    "parse_mode": "HTML"
                }) as response:
                    if response.status != 200:
                        self.logger.error(f"Échec envoi Telegram: {response.status}")
        except Exception as e:
            self.logger.error(f"Erreur envoi Telegram: {e}")
    
    def get_metrics_summary(self) -> Dict:
        """Obtenir un résumé des métriques"""
        summary = {
            "performance": {},
            "errors": self.error_counts.copy(),
            "timestamp": datetime.utcnow().isoformat()
        }
        
        for endpoint, metrics in self.performance_metrics.items():
            if metrics:
                summary["performance"][endpoint] = {
                    "avg_response_time": sum(metrics) / len(metrics),
                    "min_response_time": min(metrics),
                    "max_response_time": max(metrics),
                    "request_count": len(metrics)
                }
        
        return summary
    
    async def cleanup_old_metrics(self):
        """Nettoyer les anciennes métriques"""
        cutoff_time = datetime.utcnow() - timedelta(hours=24)
        
        for endpoint in list(self.performance_metrics.keys()):
            # Garder seulement les métriques des dernières 24h
            if len(self.performance_metrics[endpoint]) > 1000:
                self.performance_metrics[endpoint] = self.performance_metrics[endpoint][-1000:] 
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
import time
import hashlib
from typing import Dict, Set
import os

class SecurityMiddleware:
    def __init__(self):
        self.rate_limit_requests: Dict[str, list] = {}
        self.rate_limit_window = 60  # 60 secondes
        self.max_requests = 100  # 100 requêtes par minute
        self.blocked_ips: Set[str] = set()
        
    async def __call__(self, request: Request, call_next):
        # Vérification de l'IP
        client_ip = request.client.host
        
        # Vérifier si l'IP est bloquée
        if client_ip in self.blocked_ips:
            return JSONResponse(
                status_code=403,
                content={"detail": "IP bloquée pour des raisons de sécurité"}
            )
        
        # Rate limiting
        if not await self._check_rate_limit(client_ip):
            return JSONResponse(
                status_code=429,
                content={"detail": "Trop de requêtes. Veuillez réessayer plus tard."}
            )
        
        # Validation des headers de sécurité
        if not await self._validate_security_headers(request):
            return JSONResponse(
                status_code=400,
                content={"detail": "Headers de sécurité invalides"}
            )
        
        # Protection contre les attaques par injection
        if await self._detect_injection_attempt(request):
            self.blocked_ips.add(client_ip)
            return JSONResponse(
                status_code=403,
                content={"detail": "Tentative d'attaque détectée"}
            )
        
        response = await call_next(request)
        
        # Ajouter des headers de sécurité à la réponse
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = "default-src 'self'"
        
        return response
    
    async def _check_rate_limit(self, client_ip: str) -> bool:
        current_time = time.time()
        
        if client_ip not in self.rate_limit_requests:
            self.rate_limit_requests[client_ip] = []
        
        # Nettoyer les anciennes requêtes
        self.rate_limit_requests[client_ip] = [
            req_time for req_time in self.rate_limit_requests[client_ip]
            if current_time - req_time < self.rate_limit_window
        ]
        
        # Vérifier la limite
        if len(self.rate_limit_requests[client_ip]) >= self.max_requests:
            return False
        
        # Ajouter la requête actuelle
        self.rate_limit_requests[client_ip].append(current_time)
        return True
    
    async def _validate_security_headers(self, request: Request) -> bool:
        # Vérifier User-Agent
        user_agent = request.headers.get("user-agent", "")
        if not user_agent or len(user_agent) > 500:
            return False
        
        # Vérifier Content-Type pour les requêtes POST/PUT
        if request.method in ["POST", "PUT", "PATCH"]:
            content_type = request.headers.get("content-type", "")
            if not content_type.startswith("application/json"):
                return False
        
        return True
    
    async def _detect_injection_attempt(self, request: Request) -> bool:
        # Mots-clés suspects pour détecter les injections SQL
        suspicious_patterns = [
            "'; DROP TABLE", "UNION SELECT", "OR 1=1", "'; --",
            "<script>", "javascript:", "onload=", "onerror="
        ]
        
        # Vérifier l'URL
        url = str(request.url)
        for pattern in suspicious_patterns:
            if pattern.lower() in url.lower():
                return True
        
        # Vérifier les paramètres de requête
        for param_name, param_value in request.query_params.items():
            for pattern in suspicious_patterns:
                if pattern.lower() in str(param_value).lower():
                    return True
        
        return False 
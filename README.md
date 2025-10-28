# Grafana Alloy - Railway Deployment

Este directorio contiene la configuración de Grafana Alloy para recibir datos de observabilidad desde Faro Web SDK y reenviarlos a Grafana Cloud.

## Arquitectura

```
Frontend (Cloudflare Workers)
    ↓ OTLP/HTTP (puerto 4318)
Alloy (Railway)
    ↓ Remote Write
Grafana Cloud (Loki, Tempo, Prometheus)
```

## Prerrequisitos

1. Cuenta de Railway
2. Grafana Cloud configurado con:
   - Access Policy Token con permisos: `logs:write`, `metrics:write`, `traces:write`
   - URLs de endpoints para Loki, Tempo y Prometheus

## Obtener credenciales de Grafana Cloud

### 1. Access Policy Token

1. Ve a https://whitepearltranslations.grafana.net/
2. Click en tu perfil → **"Administration"** → **"Access Policies"**
3. **"Create access policy"**
   - Nombre: `alloy-observability`
   - Scopes: `logs:write`, `metrics:write`, `traces:write`
4. **"Add token"** → Copia el token

### 2. Endpoints URLs

En Grafana Cloud, ve a **"Connections"** → **"Data Sources"**:

#### Loki (Logs)
- URL: `https://logs-prod-XXX.grafana.net/loki/api/v1/push`
- Username: Ver en la configuración de Loki

#### Tempo (Traces)
- Endpoint: `tempo-prod-XXX.grafana.net:443`
- Username: Ver en la configuración de Tempo

#### Prometheus (Metrics)
- URL: `https://prometheus-prod-XXX.grafana.net/api/prom/push`
- Username: Ver en la configuración de Prometheus

## Despliegue en Railway

### Paso 1: Crear proyecto en Railway

1. Ve a https://railway.app/
2. **"New Project"** → **"Deploy from GitHub repo"**
3. Selecciona este repositorio (o haz push a un repo separado con estos archivos)
4. Railway detectará automáticamente el Dockerfile

### Paso 2: Configurar variables de entorno

En el proyecto de Railway, ve a **"Variables"** y añade:

```env
GRAFANA_CLOUD_TOKEN=glc_xxxxxxxxxxxxx
LOKI_ENDPOINT=https://logs-prod-XXX.grafana.net/loki/api/v1/push
LOKI_USERNAME=123456
OTLP_ENDPOINT=tempo-prod-XXX.grafana.net:443
OTLP_USERNAME=123456
PROMETHEUS_ENDPOINT=https://prometheus-prod-XXX.grafana.net/api/prom/push
PROMETHEUS_USERNAME=123456
```

### Paso 3: Exponer servicio públicamente

1. En Railway, ve a **"Settings"**
2. Habilita **"Public Networking"**
3. Railway generará una URL pública como: `https://tu-servicio.railway.app`
4. El endpoint OTLP será: `https://tu-servicio.railway.app:4318`

### Paso 4: Configurar React App

Actualiza el archivo `.env` de la aplicación React:

```env
REACT_APP_ALLOY_ENDPOINT=https://tu-servicio.railway.app:4318
```

Y modifica `src/lib/observability.js` para usar Alloy en lugar del colector directo de Faro.

## Monitoreo

### Health check
```bash
curl https://tu-servicio.railway.app:12345/ready
```

### Ver logs de Alloy en Railway
Ve al dashboard de Railway → **"Logs"**

### UI de Alloy
Accede a: `https://tu-servicio.railway.app:12345`

## Puertos expuestos

- **4318**: OTLP HTTP receiver (entrada de datos desde Faro)
- **12345**: API/UI de Alloy
- **9090**: Métricas de Prometheus del propio Alloy

## Troubleshooting

### Error: "connection refused"
- Verifica que Railway tenga Public Networking habilitado
- Verifica que el puerto 4318 esté expuesto

### Error: "unauthorized" en Grafana Cloud
- Verifica el token `GRAFANA_CLOUD_TOKEN`
- Verifica que tenga los scopes correctos

### No llegan datos
- Revisa logs en Railway
- Verifica CORS en `config.alloy`
- Verifica que la URL en React sea correcta

## Alternativa: Despliegue manual

Si prefieres no usar GitHub:

```bash
# En el directorio alloy-railway
railway login
railway init
railway up
railway variables set GRAFANA_CLOUD_TOKEN=xxx ...
```

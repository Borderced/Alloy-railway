# Usar la imagen oficial de Grafana Alloy
FROM grafana/alloy:latest

# Copiar configuración
COPY config.alloy /etc/alloy/config.alloy

# Exponer puertos
# 12345: API/UI de Alloy
# 4318: OTLP HTTP receiver (para recibir datos de Faro)
# 9090: Prometheus metrics
EXPOSE 12345 4318 9090

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:12345/ready || exit 1

# Ejecutar Alloy con la configuración
ENTRYPOINT ["/bin/alloy"]
CMD ["run", "/etc/alloy/config.alloy", "--server.http.listen-addr=0.0.0.0:12345", "--storage.path=/var/lib/alloy/data"]

FROM nginx:alpine

# 1. Удаляем дефолтный конфиг, чтобы не было конфликтов
RUN rm /etc/nginx/conf.d/default.conf

# 2. Копируем конфиг в папку conf.d (он автоматически подгрузится)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 3. Копируем статику
COPY html/ /usr/share/nginx/html/

# 4. Порт
EXPOSE 80

# 5. Healthcheck для Kubernetes
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# 6. Запуск nginx в фоне (обязательно для Docker!)
CMD ["nginx", "-g", "daemon off;"]
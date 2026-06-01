FROM nginx:alpine

# Копируем статику
COPY html/ /usr/share/nginx/html/

# Копируем конфиг с кастомной страницей 404
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
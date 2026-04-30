#!/bin/bash
set -e

# Образ уже содержит Apache. Просто заменяем index.html
cat > /var/www/html/index.html << HTMLEOF
<!DOCTYPE html>
<html lang="ru">
<head><meta charset="UTF-8"><title>HW 15.2</title></head>
<body>
  <h1>Instance Group + Load Balancer</h1>
  <p><strong>Hostname:</strong> $(hostname)</p>
  <img src="${image_url}" alt="Logo" style="max-width:400px">
  <p><a href="${image_url}" target="_blank">Открыть картинку</a></p>
</body>
</html>
HTMLEOF

# Перезапуск Apache (игнорируем ошибку, если уже запущен)
systemctl restart apache2 2>/dev/null || true

echo "user-data completed at $(date)"
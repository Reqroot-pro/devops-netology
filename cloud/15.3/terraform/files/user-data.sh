#!/bin/bash
set -e

# ACME challenge для Certificate Manager
sudo mkdir -p /var/www/html/.well-known/acme-challenge && \
echo -n "KPwsTzQ-qRdtsrDBLWnGOhIcEtq6cD0tnV40LmtQ24k.1z7S3GuatPqVIiIWxAGVn8Ymv1Hax4_3YvyNiZv27Wg" | \
sudo tee /var/www/html/.well-known/acme-challenge/KPwsTzQ-qRdtsrDBLWnGOhIcEtq6cD0tnV40LmtQ24k && \
sudo chmod 644 /var/www/html/.well-known/acme-challenge/KPwsTzQ-qRdtsrDBLWnGOhIcEtq6cD0tnV40LmtQ24k

# Ваш основной index.html
cat > /var/www/html/index.html << HTMLEOF
<!DOCTYPE html>
<html lang="ru">
<head><meta charset="UTF-8"><title>HW 15.3</title></head>
<body>
  <h1>Instance Group + Load Balancer</h1>
  <p><strong>Hostname:</strong> $(hostname)</p>
  <img src="${image_url}" alt="Logo" style="max-width:400px">
  <p><a href="${image_url}" target="_blank">Открыть картинку</a></p>
</body>
</html>
HTMLEOF

# Перезапуск Apache
sudo systemctl restart apache2

echo "user-data completed at $(date)"
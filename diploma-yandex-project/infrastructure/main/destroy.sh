REGISTRY_ID="crpm9pqss19nnotip8kc"

# Получаем список ID образов
IMAGE_IDS=$(yc container image list --registry-id "$REGISTRY_ID" --format json | jq -r '.[].id')

# Если есть образы — удаляем синхронно
if [ -n "$IMAGE_IDS" ]; then
  echo "Found images, starting deletion..."
  
  for image_id in $IMAGE_IDS; do
    echo "Deleting $image_id (sync mode)..."
    # Убираем --async и --silent для видимости процесса
    yc container image delete --id "$image_id"
  done
  
  echo "Deletion commands sent. Verifying..."
  sleep 10
  
  # Проверяем, что реестр пуст
  REMAINING=$(yc container image list --registry-id "$REGISTRY_ID" --format json | jq 'length')
  if [ "$REMAINING" -eq 0 ]; then
    echo "Registry is empty. Proceeding with terraform destroy."
  else
    echo "Warning: $REMAINING images still present. Check manually."
    yc container image list --registry-id "$REGISTRY_ID" --format table
  fi
else
  echo "Registry is already empty."
fi

terraform destroy -auto-approve
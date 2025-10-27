#!/bin/bash
#!/bin/bash

# Проверка наличия kubectl
if ! command -v kubectl &> /dev/null
then
    echo "kubectl не установлен. Установите его и повторите."
    exit 1
fi

# Создание PV
echo "Создаём PersistentVolume..."
kubectl apply -f pv.yml

# Создание PVC
echo "Создаём PersistentVolumeClaim..."
kubectl apply -f pvc.yml

# Создание ConfigMap (если ещё не создан)
echo "Создаём ConfigMap..."
kubectl apply -f app-config.yml

# Создание Secret (если ещё не создан)
echo "Создаём Secret..."
kubectl apply -f app-secret.yml

# Создание Deployment
echo "Создаём Deployment..."
kubectl apply -f deployment.yml

echo "Все ресурсы успешно созданы!"

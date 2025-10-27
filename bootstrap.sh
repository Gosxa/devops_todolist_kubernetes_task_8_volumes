#!/bin/bash

# Проверка наличия kubectl
if ! command -v kubectl &> /dev/null
then
    echo "kubectl не установлен. Установите его и повторите."
    exit 1
fi

# Создание PV
echo "Создаём PersistentVolume..."
kubectl apply -f .infrastructure/pv.yml

# Создание PVC
echo "Создаём PersistentVolumeClaim..."
kubectl apply -f .infrastructure/pvc.yml

# Создание Deployment
echo "Создаём Deployment..."
kubectl apply -f .infrastructure/deployment.yml

echo "Все ресурсы успешно созданы!"

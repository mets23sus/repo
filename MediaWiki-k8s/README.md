# MediaWiki в Kubernetes

Этот проект развертывает MediaWiki с PostgreSQL в Kubernetes кластере.

## Компоненты

- **PostgreSQL 15** - база данных
- **MediaWiki 1.39** - вики-платформа (образ Bitnami с поддержкой PostgreSQL)
- **Nginx Ingress** - для внешнего доступа
- **Local Storage** - для персистентного хранения данных

## Предварительные требования

1. Kubernetes кластер с установленным nginx-ingress
2. Узел `node2` с директориями:
   - `/mnt/data/postgres` - для PostgreSQL данных
   - `/mnt/data/mediawiki` - для MediaWiki данных

## Развертывание

```bash
# Создание директорий на узле node2
sudo mkdir -p /mnt/data/postgres /mnt/data/mediawiki
sudo chmod 755 /mnt/data/postgres /mnt/data/mediawiki

# Применение всех ресурсов
kubectl apply -k .

# Проверка статуса
kubectl get all -n mediawiki
kubectl get pv,pvc -n mediawiki
```

## Доступ

После развертывания MediaWiki будет доступна по адресу, указанному в Ingress.

**Данные для входа:**
- Пользователь: `admin`
- Пароль: `admin123`

## Устранение неполадок

### Проверка логов
```bash
kubectl logs -f deployment/mediawiki -n mediawiki
kubectl logs -f statefulset/postgres -n mediawiki
```

### Проверка подключения к БД
```bash
kubectl exec -it deployment/mediawiki -n mediawiki -- pg_isready -h postgres -p 5432 -U mediawiki_user
```

### Пересоздание секретов
```bash
# Удаление и пересоздание секрета
kubectl delete secret postgres-secret -n mediawiki
kubectl apply -f postgres-secret.yaml
```

## Основные изменения

1. **Использован образ Bitnami MediaWiki** - содержит PostgreSQL клиент
2. **Добавлены переменные окружения** - для автоматической настройки
3. **Создан init-контейнер** - для ожидания готовности PostgreSQL
4. **Исправлен StorageClass** - убраны лишние пробелы
5. **Добавлены секреты** - для безопасного хранения паролей
6. **Улучшена конфигурация** - увеличены ресурсы и таймауты

## Безопасность

- Пароли хранятся в секретах Kubernetes
- Рекомендуется изменить пароли по умолчанию
- Используйте HTTPS в продакшене

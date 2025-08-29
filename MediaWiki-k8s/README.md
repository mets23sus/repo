# MediaWiki в Kubernetes (MySQL)

Этот проект развертывает MediaWiki с MySQL в Kubernetes кластере.

## Компоненты

- **MySQL 8.0** — база данных (StatefulSet)
- **MediaWiki 1.39** — вики-платформа (образ Bitnami)
- **Nginx Ingress** — внешний доступ
- **Local Storage** — локальные PV на `node2`

## Предварительные требования

1. Кластер Kubernetes с ingress-nginx
2. Узел `node2` с директориями:
   - `/mnt/data/mysql` — данные MySQL
   - `/mnt/data/mediawiki` — данные MediaWiki

## Развертывание

```bash
# Подготовка директорий на node2
ssh node2 'sudo mkdir -p /mnt/data/mysql /mnt/data/mediawiki && sudo chmod 777 /mnt/data/mysql /mnt/data/mediawiki'

# Применение манифестов (kustomize)
kubectl apply -k MediaWiki-k8s/

# Проверка статуса
kubectl get all -n mediawiki
kubectl get pv,pvc -A | grep -E 'mediawiki|mysql'
```

## Доступ

После старта MediaWiki будет доступна через Ingress (`mediawiki-ingress`).

## Переменные/секреты

Секрет `mysql-secret` содержит:
- `mysql-root-password`, `mysql-user`, `mysql-password`, `mysql-database`

## Траблшутинг

```bash
# Логи MySQL
kubectl logs -f statefulset/mysql -n mediawiki

# Логи MediaWiki
kubectl logs -f deploy/mediawiki -n mediawiki

# Проверка готовности БД
kubectl exec -it deploy/mediawiki -n mediawiki -c init-mediawiki -- mysqladmin ping -h mysql --silent
```

## Примечания

- Postgres манифесты удалены из kustomization; используется MySQL.
- Если Docker Hub требует авторизацию, используйте imagePullSecret и привяжите к ServiceAccount.

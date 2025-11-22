# Источники
## 1. Основной .sqlite файл слишком большой для GitHub, скачайте его с Kaggle:

- [Kaggle Dataset: European Soccer Database](https://www.kaggle.com/datasets/hugomathien/soccer)
- Имя файла после скачивания: `database.sqlite` (положить в папку `data/`)

### Как скачать

1. Зарегистрируйтесь на kaggle.com (если еще нет аккаунта)
2. Скачайте датасет вручную или через Kaggle CLI/API:
   - CLI: `kaggle datasets download -d hugomathien/soccer`
3. Положите файл `database.sqlite` в папку `data/` проекта

## 2. uefa_rating - собран вручную, основывясь на [официальном сайте УЕФА](https://ru.uefa.com/nationalassociations/uefarankings/country/) 
  - Лежит в `data/uefa_rating.csv`

## 3. uefacompetitionresult - [результаты всех матчей под эгидой УЕФА](https://www.kaggle.com/datasets/rtx666x3/all-time-uefa-competitions-results)
  - Лежит в `data/uefacompetitinresult.csv`

# Получение рабочих датасетов

### 1. Получение основного датасета из database.sqlite

- Откройте базу `data/database.sqlite` в DBeaver или любом SQL-клиенте.
- Выполните скрипты из папки `/sql`:
    - `team_attr.sql` — получение таблицы с результатами матчей и атрибутам команд.
    - `bk_pred.sql` — получение таблицы с предсказаниями букмекеров.
- Экспортируйте результаты выполнения в CSV-файлы:
    - Результат выполнения `team_attr.sql` сохраните как `data/team_attr.csv`
    - Результат выполнения `bk_pred.sql` сохраните как `data/bk_pred.csv`

### 2. Обработка вручную собранных CSV

- Исходные файлы: `data/uefa_rating.csv`, `data/uefacompetitionresult.csv`
- Можно использовать для дополнительного анализа.

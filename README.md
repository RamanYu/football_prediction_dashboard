# football_prediction_dashboard
# Аналитика футбольных матчей: Дашборд для прогнозирования исходов футбольных матчей

## Описание

Учебный проект: дашборд для анализа и прогнозирования исхода футбольных матчей для частного инвестора. Вся цепочка: SQL-джойны, аналитика на Python, визуализация в Tableau.

## Задача

- Построить дашборд для прогнозирования результатов матча между выбранными футбольными командами.
- Выделить ключевые характеристики, влияющие на результат игры.
- Убедить пользователя в эффективности аналитического пайплайна.

## Архитектура проекта

1. **SQL**
    - Джойны и подготовка данных из исходных таблиц (матчи, команды, игроки, котировки).
    - Итогового датасеты:
        - `data/bk_pred.csv`,
        - `data/team_attr.csv`.
2. **Python/Jupyter Notebook**
    - Аналитика, выявление ключевых признаков и метрик.
    - Подготовка данных для визуализации.
    - Основной ноутбук: `football_prediction_dashboard_FINAL.ipynb`.
3. **Tableau**
    - Итоговая визуализация для пользователя.
    - [Ссылка на Tableau Public](https://public.tableau.com/app/profile/roman.yurenia/viz/football_prediction_dashboard/Dashboard1?publish=yes),
    - Скриншот: `dashboard/image.jpg`,
    - Основной файл: `football_prediction_dashboard.twbx`.

## Структура репозитория

```football_prediction_dashboard/
├─ data/
│    ├─source.md
│    ├─ bk_pred.csv
│    ├─ team_attr.csv
│    └─ final_matrix_for_tableau.csv
├─ notebooks/
│    └─ CL-Project-Team-2.-PREFINAL.ipynb
├─ sql/
│    ├─ bk_pred.sql
│    └─ team_attr.sql
├─ dashboard/
│    ├─ tableau_dashboard.twbx
│    ├─ link_to_public_dashboard.md
│    └─ image.jpg
├─ README.md
├─ LICENSE
├─ .gitignore
└─ requirements.txt
```


## Ключевые метрики для прогноза

- Количество набранных очков за последние 5 матчей
- Количество забитых мячей
- Количество пропущенных мячей

## Как пользоваться проектом

- SQL: обработать исходные данные скриптами из папки `/sql`.
- Python: провести анализ, повторить обработку данных в ноутбуке `/notebooks`.
- Данные для визуализации — итоговый CSV: `/data/запрос_ред_база.csv`.
- Визуализация: открыть Tableau Dashboard (`dashboard/image.jpg` для примера).

## Пример дашборда

![Дашборд - прогнозирование исхода футбольного матча](dashboard/image.png)

## Требования

- PostgreSQL для обработки исходных данных
- Python 3.8+ и библиотеки (см. `requirements.txt`)
- Tableau для визуализации

## Автор

- Юреня Роман, plowram@gmail.com



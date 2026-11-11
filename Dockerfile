# Базовый образ из ПР № 7: фиксированная версия, вариант slim
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Сначала только зависимости: слой pip install берётся из кэша,
# пока не изменился requirements.txt
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Непривилегированный пользователь для запуска приложения
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

# Код приложения копируется последним: он меняется чаще всего
COPY app.py .

USER app

EXPOSE 8004

# exec-форма: gunicorn работает как PID 1 и сам получает SIGTERM
CMD ["gunicorn", "--bind", "0.0.0.0:8004", "--access-logfile", "-", "app:app"]

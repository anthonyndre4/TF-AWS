FROM python:3.12-alpine

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt \
    && adduser -D botuser \
    && chown -R botuser:botuser /app \
    && chmod 555 /app

USER botuser

CMD ["python", "bot.py"]
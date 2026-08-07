FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

COPY app.py /app.py

CMD ["python", "/app.py"]

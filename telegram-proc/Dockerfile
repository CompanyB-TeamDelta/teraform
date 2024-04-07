FROM python:3.9-slim

WORKDIR /app

ADD . /app

RUN pip install --no-cache-dir -r /app/requirements.txt

EXPOSE 80

CMD ["python", "main.py"]

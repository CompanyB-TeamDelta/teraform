FROM python:3.9-slim
RUN ls -a
WORKDIR /app

ADD . /app

RUN pip install --no-cache-dir -r /app/requirements.txt

EXPOSE 80

CMD ["python", "main.py"]

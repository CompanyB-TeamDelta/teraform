FROM python:3.9-slim
RUN ls -a
WORKDIR /app

ADD . /app

RUN ls ./app

RUN pip install --no-cache-dir -r ./app/requirements.txt

EXPOSE 80

ENTRYPOINT python main.py

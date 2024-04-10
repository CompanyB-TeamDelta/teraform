FROM python:3.9-slim
RUN ls -a

ADD ./app /app

RUN ls ./app

RUN pip install --no-cache-dir -r ./app/requirements.txt

EXPOSE 80

ENTRYPOINT python ./app/main.py

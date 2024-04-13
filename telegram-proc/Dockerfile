FROM python:3.9-slim
RUN ls -a

ADD ./app /app

RUN ls ./app/tmp

RUN pip install --no-cache-dir -r ./app/requirements.txt

EXPOSE 80

ENTRYPOINT cd ./app; python main.py

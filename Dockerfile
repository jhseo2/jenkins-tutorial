FROM python:3.8
MAINTAINER Anderson Jo
USER root
ENV PYTHONUNBUFFERED=True
ENV APP_HOME=/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY . ./
RUN pip install --upgrade pip \
    && pip install -r requirements.txt
CMD exec gunicorn --bind 0.0.0.0:80 --workers 4 --threads 8 app:app

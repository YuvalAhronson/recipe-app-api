# FROM image:tag
FROM python:3.9-alpine3.13 
# Specify maintainer
LABEL maintainer="yuvalahronson" 

# Dont buffer when print to stdout
ENV PYTHONUNBUFFERED 1 

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# working directory for ADD, COPY, CMD, ENTRYPOINT, RUN
WORKDIR /app
# expose port 
EXPOSE 8000 

ARG DEV=false
# virtual environment for edge cases
RUN python -m venv /py && \  
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        # use a limietd user instead of root
        django-user
# To execute every python command in /bin/py directory which holds all commands
ENV PATH="/py/bin:$PATH"
# switch to USER django-user. From now on everything runs as django-user
USER django-user

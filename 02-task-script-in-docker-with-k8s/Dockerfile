FROM python:3.9-slim-buster

RUN pip install kubernetes

COPY ./python/main.py /app/
COPY ./k8s/kubeconfig.yaml /app/
COPY ./k8s/service-account-token /app/

ENV KUBECONFIG=/app/kubeconfig.yaml
ENV SERVICE_ACCOUNT_TOKEN=/app/service-account-token

WORKDIR /app

ENTRYPOINT ["python", "main.py"]
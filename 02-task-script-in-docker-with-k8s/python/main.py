from kubernetes import client, config
from datetime import datetime
import logging

FORMAT = '%(asctime)s - %(message)s'


def get_pod_age(pod_data):
    created_time = pod_data.metadata.creation_timestamp
    current_time = datetime.now(created_time.tzinfo)
    age_seconds = (current_time - created_time).total_seconds()
    age_hours, age_minutes = divmod(age_seconds // 60, 60)
    return f'{int(age_hours)}h:{int(age_minutes)}m'


def get_time_log(pod_data, log_format, age):
    logging.basicConfig(format=log_format, level=logging.INFO)
    logging.info(f'Name: {pod_data.metadata.name}, labels: {pod_data.metadata.labels}, AGE: {age};')


if __name__ == '__main__':
    config.load_incluster_config()
    v1 = client.CoreV1Api()
    list_pod = v1.list_namespaced_pod(namespace="default")

    for pod in list_pod.items:
        if 'env' in pod.metadata.labels.keys() and pod.metadata.labels['env'] == 'test':
            pod_age = get_pod_age(pod)
            get_time_log(pod, FORMAT, pod_age)
        continue

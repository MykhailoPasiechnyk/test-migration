from kubernetes import client, config
from datetime import datetime
from logging.handlers import TimedRotatingFileHandler
import logging


FORMAT = '%(asctime)s - %(message)s'
FILE_NAME = 'info.log'


def get_pod_age(pod_data):
    created_time = pod_data.metadata.creation_timestamp
    current_time = datetime.now(created_time.tzinfo)
    age_seconds = (current_time - created_time).total_seconds()
    age_hours, age_minutes = divmod(age_seconds // 60, 60)
    return f'{int(age_hours)}h:{int(age_minutes)}m'


def create_info_logger(msg_format, filename):
    logging.basicConfig(format=msg_format)
    logger = logging.getLogger('info_log')
    log_formatter = logging.Formatter(msg_format)
    file_handler = TimedRotatingFileHandler(filename, backupCount=50, when='s', interval=59)
    file_handler.setFormatter(log_formatter)
    logger.setLevel(logging.INFO)
    logger.addHandler(file_handler)
    return logger


def get_time_log(loger, pod_data, age):
    loger.info(f'Name: {pod_data.metadata.name}, labels: {pod_data.metadata.labels}, AGE: {age};')


if __name__ == '__main__':
    config.load_config()
    v1 = client.CoreV1Api()
    list_pod = v1.list_pod_for_all_namespaces()
    info_logger = create_info_logger(FORMAT, filename=FILE_NAME)

    for pod in list_pod.items:
        if 'env' in pod.metadata.labels.keys() and pod.metadata.labels['env'] == 'test':
            pod_age = get_pod_age(pod)
            get_time_log(info_logger, pod, pod_age)

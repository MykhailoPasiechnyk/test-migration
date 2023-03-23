.PHONY : clean, docker, test-deployment

config:
	kubectl config view --minify > 02-task-script-in-docker-with-k8s/k8s/kubeconfig.yaml

token:
	kubectl get secret python-secret -o jsonpath='{.data.token}' | base64 --decode > 02-task-script-in-docker-with-k8s/k8s/service-account-token

docker: build
	docker push pasiechnyk/my-python

build:
	docker build -t pasiechnyk/my-python 02-task-script-in-docker-with-k8s

test-deployment:
	kubectl apply -f test-deployment.yaml

clean:
	kubectl delete -f test-deployment.yaml
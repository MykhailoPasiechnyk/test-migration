.PHONY : clean

push: build
	docker push pasiechnyk/my-python

build:
	docker build -t pasiechnyk/my-python 02-task-script-in-docker-with-k8s

test-deployment:
	kubectl apply -f test-deployment.yaml

clean:
	kubectl delete -f test-deployment.yaml
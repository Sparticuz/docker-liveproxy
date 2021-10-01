APP_NAME=liveproxy

build:
	docker build . -t $(APP_NAME)

run:
	docker run --rm -p 53422:53422 --name="$(APP_NAME)" $(APP_NAME)

tag:
	docker tag $(APP_NAME) sparticuz/$(APP_NAME):latest

publish:
	docker push sparticuz/$(APP_NAME):latest

VERSION?=$(shell git rev-parse HEAD)
BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')

build: buildApi buildProxy buildSwagger buildLocal

buildApi:
	protoc -I/usr/local/include -I. \
  	-I$(GOPATH)/src \
  	-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--go_out=plugins=grpc:$(GOPATH)/src/github.com/bege13mot/vessel-service \
		proto/vessel/vessel.proto

buildProxy:
	protoc -I/usr/local/include -I. \
  	-I$(GOPATH)/src \
  	-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--grpc-gateway_out=logtostderr=true:. \
		proto/vessel/vessel.proto

buildSwagger:
	protoc -I/usr/local/include -I. \
  	-I$(GOPATH)/src \
  	-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--swagger_out=logtostderr=true:. \
		proto/vessel/vessel.proto

buildLocal:
	go build \
		-ldflags="-X main.Version=${VERSION} \
		-X main.Branch=${BRANCH} \
		-X main.BuildTime=${BUILD_TIME}"

dockerPush:
	docker build -t bege13mot/vessel-service:latest .
	docker push bege13mot/vessel-service:latest

deploy:
	helm upgrade --install vessel-service deployment-chart

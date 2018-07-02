build: buildApi buildProxy buildSwagger

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

# build:
# 	protoc -I. --go_out=plugins=grpc:$(GOPATH)/src/github.com/testProject/vessel-service \
#     proto/vessel/vessel.proto
	# GOOS=linux GOARCH=amd64 go build
	# docker build -t shippy-vessel-service .
	# docker build -t eu.gcr.io/shippy-freight/vessel:latest .
	# docker push eu.gcr.io/shippy-freight/vessel:latest


# run:
# 	docker run -p 50052:50051 -e MICRO_SERVER_ADDRESS=:50051 -e MICRO_REGISTRY=mdns vessel-service

run:
	docker run -d --net="host" \
		-p 50053 \
		-e MICRO_SERVER_ADDRESS=:50053 \
		-e MICRO_REGISTRY=mdns \
		vessel-service

deploy:
	sed "s/{{ UPDATED_AT }}/$(shell date)/g" ./deployments/deployment.tmpl > ./deployments/deployment.yml
	kubectl replace -f ./deployments/deployment.yml

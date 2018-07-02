FROM alpine:latest

RUN apk --no-cache add ca-certificates
RUN mkdir /app

WORKDIR /app

ADD vessel-service /app/vessel-service

CMD ["./vessel-service"]

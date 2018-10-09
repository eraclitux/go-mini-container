FROM golang:alpine

RUN apk add --no-cache binutils git xz
RUN wget https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz
RUN tar xf upx-3.95-amd64_linux.tar.xz
RUN cp upx-3.95-amd64_linux/upx /usr/local/bin

# go-mini-container

[![Docker Build Status](https://img.shields.io/docker/build/eraclitux/go-mini-container.svg)](https://hub.docker.com/r/eraclitux/go-mini-container/)

This images is meant to be used to build very small Docker images or stand-alone Go binaries.

It includes optional tools that can further reduce the size of the final artifact (notably [upx](https://upx.github.io)).

Make the smaller possible Docker images (and Go binaries in general) can help in many cases. It reduces the bandwidth required by registry, speeds up deployment and scaling activities and minimizes cold start in serverless environments. From a _security_ standpoint putting into the images only the things that are strictly necessary to run the code, minimizes the attack surface.
To run a Go binary a full fledged GNU/Linux distro is generally required. Unfortunately most official images are more than 100MB, [Alpine Linux](https://alpinelinux.org/) to the rescue, this amazing distro is less than 5MB.

# How to use this image

## FROM scratch

This method produces the smallest possible image.

Example Dockerfile:

```
FROM eraclitux/go-mini-container as builder
WORKDIR /go/src/github.com/eraclitux/rim
COPY . .
RUN go get ./...
RUN CGO_ENABLED=0 go build -ldflags '-w'
RUN strip rim
RUN upx rim

FROM scratch
COPY --from=builder /go/src/github.com/eraclitux/rim/rim /
ENTRYPOINT ["/rim"]
```

In the example the final images passes from ~4MB to ~1MB.

## FROM alpine

Not all the binaries can run in a `FROM scratch` images. In case you got runtime errors like:

```
user: Current not implemented on linux/amd64
```

it may be that your executable needs an OS to work. Build the image on top of Alpine, this will only adds ~5MB to the final artifact. Es.:

```
FROM eraclitux/go-mini-container as builder
WORKDIR /go/src/app
COPY . .
RUN go get ./...
RUN go build -ldflags '-w'
RUN strip app
RUN upx app

FROM alpine
COPY --from=builder /go/src/app/app /
CMD ["/app"]
```

### Notes

Certification authority files will be required if your code makes https requests. In case of errors like this:

```
Get https://some-uri.tld/resource: x509: failed to load system roots and no roots provided
```

add in Dockerfile:

```
RUN apk add --no-cache ca-certificates && update-ca-certificates
```

## Stand-alone binary

Create an intermediate container with the image just created and copy the binary from it (it will work on Linux/amd64 only):

```
$ docker run --name intermediate eraclitux/rim
$ docker cp intermediate:/rim .
```

Cross compilation will not work in Docker image, just run these commands on your target platform after have installed `strip` (usually from `binutils` package) and `upx` for your platform/architecture:

```
go build -o app -ldflags '-w'
strip app
upx app
```

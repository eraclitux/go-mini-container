go-mini-container
=================

[![Docker Build Status](https://img.shields.io/docker/build/eraclitux/go-mini-container.svg)](https://hub.docker.com/r/eraclitux/go-mini-container/)

Maintain Docker images small can help in many cases. It reduces the bandwidth required by registry and dramatically speed up deployment in large clusters.
To run a Go binary a full fledged distro with `libc` is generally required. Unfortunately most linux official images are more than 100MB, [Alpine Linux](https://alpinelinux.org/) to the rescue, this amazing distro is less than 5MB.

How to use this image
=====================

This images is meant to be used to build Go binaries statically linked against `musl libc` (the Alpine version of libc).

From the root of your project:
```
$ docker run --rm -v "$PWD":/usr/src/<my-project> \
-w /usr/src/<my-project> eraclitux/go-mini-container \
sh -c "go get -v -d ./... && CC=$(which gcc) go build -v --ldflags '-w -linkmode external -extldflags \"-static\"' -o my-bin"
```
The `-w` flag tells the linker to omit the debug information obtaining a smaller output file.

After compilation ends to verify that everything has worked:
```
$ file ./my-bin
my-bin: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, with debug_info, not stripped
```
Add the binary into a Dockerfile derived from Alpine:
```
FROM alpine
WORKDIR /app
COPY ./my-bin .
CMD ["./my-bin"]
```

Enjoy the ~10MB image.

Notes
=====

Certification authority files could be required. In case an error like this:
```
Get https://some-uri.tld/resource: x509: failed to load system roots and no roots provided
```
add in Dockerfile:

```
FROM alpine
RUN apk add --no-cache ca-certificates && update-ca-certificates
```

A word of caution
-----------------

Images built with this method have not been thoroughly tested in production environments,
the use of `musl libc` can have unpredictable side effects. Instrument code and infrastructure
and use *canary deploy* to spot possible issues.

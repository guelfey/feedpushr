#########################################
# Build stage
#########################################
FROM golang:1.13 AS builder

# Repository location
ARG REPOSITORY=github.com/ncarlier

# Artifact name
ARG ARTIFACT=feedpushr

# Copy sources into the container
ADD . /go/src/$REPOSITORY/$ARTIFACT

# Set working directory
WORKDIR /go/src/$REPOSITORY/$ARTIFACT

# Build the binary
RUN make build plugins

#########################################
# Distribution stage
#########################################
FROM alpine

# Repository location
ARG REPOSITORY=github.com/ncarlier

# Artifact name
ARG ARTIFACT=feedpushr

# Fix lib dep
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# Install root certificates
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

# Install project files
COPY --from=builder /go/src/$REPOSITORY/$ARTIFACT/release/ /usr/local/share/$ARTIFACT/

# Install binary
RUN ln -s /usr/local/share/$ARTIFACT/$ARTIFACT /usr/local/bin/$ARTIFACT

# Define working directory
WORKDIR /usr/local/share/$ARTIFACT

# Define command
CMD feedpushr


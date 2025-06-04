FROM quay.io/projectquay/golang:1.24 AS builder

ARG TARGETARCH
ARG VERSION

WORKDIR /go/src/app
COPY . .
RUN make build TARGETARCH=$TARGETARCH VERSION=$VERSION

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]
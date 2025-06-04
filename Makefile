APP := $(shell basename $(shell git remote get-url origin) )
REGISTRY := vasylvolyk
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows
TARGETARCH=arm64 #amd64 arm64

format:
	@echo "Formatting Go code..."
	@gofmt -s -w ./

install-lint:
	@which golangci-lint >/dev/null || (echo "Installing golangci-lint..." && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest)

# Run linter
lint: install-lint
	@echo "Running linter..."
	@golangci-lint run ./...

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X=github.com/vasyl-volyk/kbot/cmd.appVersion=${VERSION}"

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	rm -rf *.tar.gz

# OS shortcuts
linux:
	$(MAKE) build TARGETOS=linux

windows:
	$(MAKE) build TARGETOS=windows

macos:
	$(MAKE) build TARGETOS=darwin

# ARCH shortcuts
amd64:
	$(MAKE) build TARGETARCH=amd64

arm64:
	$(MAKE) build TARGETARCH=arm64

# Комбінації ОС + архітектура (приклади)
linux-amd64:
	$(MAKE) build TARGETOS=linux TARGETARCH=amd64

linux-arm64:
	$(MAKE) build TARGETOS=linux TARGETARCH=arm64

windows-amd64:
	$(MAKE) build TARGETOS=windows TARGETARCH=amd64

darwin-arm64:
	$(MAKE) build TARGETOS=darwin TARGETARCH=arm64
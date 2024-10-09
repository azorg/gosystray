# File: "Makefile"

PRJ = gosystray

BIN := bin
OUT := $(BIN)

GIT_MESSAGE = "auto commit"

# Version, git hash
MAJOR := 0
MINOR := 1
BUILD := 0
VERSION := $(MAJOR).$(MINOR).$(BUILD)
GIT_HASH := `git rev-parse HEAD | head -c 7`
BUILD_TIME := `date '+%Y.%m.%d_%H:%M'`

LDFLAGS=-ldflags "-X=main.Version=$(VERSION) -X=main.GitHash=$(GIT_HASH) -X=main.BuildTime=$(BUILD_TIME)"

export GOOS = linux
#export GOOS = windows
export GOARCH = amd64
export CGO_ENABLED = 1

# go source files, ignore vendor directory
SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")

pkgs = .

.PHONY: all rebuild help prepare clean distclean \
        fmt simplify vet tidy vendor commit

all: $(PRJ)

apk: $(APK)

rebuild: clean all

help:
	@echo "make prepare   - install dependencies for build"
	@echo "make all       - full build (by default)"
	@echo "make rebuild   - clean and full rebuild"
	@echo "make clean     - clean"
	@echo "make distclean - full clean (go.mod, go.sum)"
	@echo "make fmt       - format Go sources"
	@echo "make simplify  - simplify Go sources (go fmt -s)"
	@echo "make vet       - report likely mistakes (go vet)"
	@echo "make go.mod    - generate go.mod"
	@echo "make go.sum    - generate go.sum"
	@echo "make tidy      - automatic update go.sum by tidy"
	@echo "make vendor    - create vendor"
	@echo "make commit    - auto commit by git"
	@echo "make help      - this help"

checkroot:
ifneq ($(shell whoami), root)
	@echo "you must be root; cancel" && false
endif

prepare: #checkroot
	@echo ">>> install dependencies to build"
	@#apt install -y make
	@#apt install -y golang
	@sudo apt-get install gcc libgtk-3-dev libayatana-appindicator3-dev
	@#go install fyne.io/fyne/v2/cmd/fyne@latest

clean:
	rm -f $(PRJ)
	rm -f $(APK)

distclean: clean
	rm -f go.mod
	rm -f go.sum
	@#sudo rm -rf go/pkg
	rm -rf vendor
	go clean -modcache

fmt: go.mod go.sum
	@#echo ">>> format Go sources"
	@go fmt

simplify:
	@echo ">>> simplify Go sources"
	@gofmt -l -w -s $(SRC)

vet:
	@echo ">>> report likely mistakes (go vet)"
	@#go vet
	@go vet $(PKGS)

go.mod:
	@go mod init $(PRJ)
	@#touch go.mod

tidy: go.mod
	@go mod tidy

go.sum: go.mod Makefile tidy
	@#go get github.com/azorg/xlog@v1.1.3-go1.20
	@touch go.sum

vendor: go.sum
	@go mod vendor

commit: clean
	git add .
	git commit -am $(GIT_MESSAGE)
	git push

$(PRJ): *.go go.sum go.mod
	@mkdir -p $(OUT)
	@go build $(LDFLAGS) -o $(OUT) $(PRJ)

# EOF: "Makefile"

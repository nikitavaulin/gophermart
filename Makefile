APP_PACKAGE := ./cmd/gophermart
APP_BINARY := cmd/gophermart/gophermart
ifeq ($(OS),Windows_NT)
APP_BINARY := $(APP_BINARY).exe
endif

DATABASE_URI ?= postgres://gophermart:gophermart@127.0.0.1:55432/gophermart?sslmode=disable
export DATABASE_URI

.PHONY: test build run compose-up migration-create migrate-up migrate-down

test:
	@go test ./...

build:
	@go build -o "$(APP_BINARY)" $(APP_PACKAGE)

run:
	@go run $(APP_PACKAGE)

compose-up:
	@docker compose up -d --wait

migration-create:
ifeq ($(strip $(NAME)),)
	$(error Укажи имя миграции: make migration-create NAME=add_example)
endif
	@migrate create -ext sql -dir migrations -seq -digits 6 "$(NAME)"

migrate-up:
	@migrate -path migrations -database "$(DATABASE_URI)" up

migrate-down:
	@migrate -path migrations -database "$(DATABASE_URI)" down 1

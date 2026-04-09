SHELL := bash

.PHONY: format lint

format:
	./scripts/format.sh

lint:
	./scripts/lint.sh

help:
	@echo "Available targets:"
	@echo "  make format - Format code"
	@echo "  make lint   - Run linter"
	@echo "  make help   - Show this help message"
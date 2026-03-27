SHELL := bash

.PHONY: format lint

format:
	./scripts/format.sh

lint:
	./scripts/lint.sh
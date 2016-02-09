CRYSTAL_BIN ?= $(shell which crystal)
ICR_BIN ?= $(shell which icr)

benchmark:
	@mkdir -p ./tmp
	@$(CRYSTAL_BIN) build --release -o ./tmp/benchmark ./samples/benchmark.cr $(CRFLAGS)
	@./tmp/benchmark

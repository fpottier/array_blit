# [make all] compiles this benchmark.
# Using --profile release ensures that debug assertions are turned off.

.PHONY: all
all:
	@ dune build --profile release

.PHONY: clean
clean:
	git clean -fX

MAIN := _build/default/main.exe

.PHONY: test
test: all
	@ hyperfine -N --min-runs 30 --warmup 10 \
	  -n "polymorphic array blit" "$(MAIN)" \
	  -n "monomorphic array blit" "$(MAIN) --mono" \

.PHONY: once
once: all
	@ echo
	@ echo "## Running poly:"
	@ echo
	@ $(MAIN)
	@ echo
	@ echo "## Running mono:"
	@ echo
	@ $(MAIN) --mono

.PHONY: assembly
assembly:
	@ dune clean
	@ make all
	@ open -a /Applications/Emacs.app _build/default/.main.eobjs/native/dune__exe__Main.s

build: clean scanner parser semant

setup:
	@if ! opam switch list | grep -q '5.1.1'; then \
        opam switch create 5.1.1 || true; \
    else \
        echo "Switch 5.1.1 already exists."; \
	fi
	opam install ocaml-lsp-server
	opam install ocamlformat
	eval $$(opam config env)
	eval $$(opam env)
	eval $$(opam env --switch=5.1.1)

env:
	eval $$(opam env)


semant: src/semant.ml
	rm -f src/parser.ml
	rm -f src/parser.mli
	ocamlbuild -I src src/semant.native

scanner: src/scanner.mll
	ocamlbuild -I src src/scanner.native

parser: src/parser.mly
	ocamlyacc -v src/parser.mly

ast_test:
	ocamlbuild -I src test/ast_test.native

sast_test:
	ocamlbuild -I src test/sast_test.native

anon:
	ocamlbuild -I src test/sast_test.native
	./sast_test.native < test/anonymous_function.tb

hello_world:
	ocamlbuild -I src test/sast_test.native
	./sast_test.native < test/hello_world.tb

for_loop:
	ocamlbuild -I src test/sast_test.native
	./sast_test.native < test/for_loop.tb

function:
	ocamlbuild -I src test/sast_test.native
	./sast_test.native < test/function.tb

struct:
	ocamlbuild -I src test/sast_test.native
	./sast_test.native < test/struct.tb


.PHONY: clean
clean:
	rm -f src/parser.ml
	rm -f src/parser.mli
	rm -f src/parser.output
	rm -f src/*.native
	rm -f *.native
	rm -rf _build
	rm -f src/ast.cmi
	rm -f src/ast.cmo
	rm -f test/ast_test.cmi
	rm -f test/ast_test.cmo
	rm -f ./test/*.cmi
	rm -f ./test/*.cmo
	rm -f ./test/*.native
	rm -f ./test/*.out
	rm -f hello_world.output
	rm -f *.out
	rm -f /src/*.output

.PHONY: unit_tests unit_tests_ast unit_tests_scanner unit_tests_parser unit_tests_sast unit_tests_semant unit_tests_irgen

unit_tests: unit_tests_ast unit_tests_scanner unit_tests_parser unit_tests_sast unit_tests_semant unit_tests_irgen
	
unit_tests_ast:
	ocamlbuild -I src test/unit_tests_ast.native
	rm -f ./test/unit_tests_ast.cmi
	rm -f ./test/unit_tests_ast.cmo
	./unit_tests_ast.native > ./unit_tests_ast.out

unit_tests_scanner:
	rm -f /test/ast.cmi
	rm -f /test/ast.cmo
	ocamlbuild -I src test/unit_tests_scanner.native
	./unit_tests_scanner.native > ./unit_tests_scanner.out

unit_tests_parser:
	rm -f /test/ast.cmi
	rm -f /test/ast.cmo
	ocamlbuild -I src test/unit_tests_parser.native
	./unit_tests_parser.native > ./unit_tests_parser.out

unit_tests_sast:
	rm -f /test/ast.cmi
	rm -f /test/ast.cmo
	ocamlbuild -I src test/unit_tests_sast.native
	./unit_tests_sast.native > ./unit_tests_sast.out

unit_tests_semant:
	rm -f /test/ast.cmi
	rm -f /test/ast.cmo
	ocamlbuild -I src test/unit_tests_semant.native
	./unit_tests_semant.native > ./unit_tests_semant.out

unit_tests_irgen:
	rm -f /test/ast.cmi
	rm -f /test/ast.cmo
	ocamlbuild -pkgs llvm -I src test/unit_tests_irgen.native
	./unit_tests_irgen.native > ./unit_tests_irgen.out
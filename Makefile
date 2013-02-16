all: deps compile generate

compile:
	./rebar compile

console: compile
	erl +K true +A 8 -env ERL_LIBS "..:deps" -args_file rel/files/vm.args -run myapp_app dev

depends:
	./rebar get-deps

depends-update:
	./rebar get-deps

clean:
	rm -rf deps/*
	./rebar clean

generate:
	./rebar generate

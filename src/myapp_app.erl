-module(myapp_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-export([dev/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

dev() ->
    [ok = application:start(App)
     || App <- [crypto,
                ranch,
                cowboy,
                inets,
                public_key,
                ssl,
                myapp]],
    ok.

start(_StartType, _StartArgs) ->
    myapp_sup:start_link().

stop(_State) ->
    ok.

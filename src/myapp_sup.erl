
-module(myapp_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Dispatch = cowboy_router:compile([
        {'_', [{'_', rss_proxy, []}]}
    ]),
    %% Name, NbAcceptors, TransOpts, ProtoOpts
    R = (catch cowboy:start_http(my_http_listener, 100,
        [{port, 1234}],
        [{env, [{dispatch, Dispatch}]}]
    )),
    error_logger:error_msg("~p\n", [R]),
    {ok, { {one_for_one, 5, 10}, []} }.


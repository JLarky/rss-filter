-module(rss_proxy).

-behaviour(cowboy_http_handler).

-include_lib("xmerl/include/xmerl.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined_state}.

handle(Req, State) ->
    {ok, Cfg} = file:consult(<<"priv/app.cfg">>),
    Filters = proplists:get_value(filters, Cfg),
    Url = proplists:get_value(url, Cfg),
    case httpc:request(get, {Url, []}, [], []) of
        {ok, {{_, 200, _}, _Headers, Body}} ->
            ok
    end,
    {Rss, ""} = xmerl_scan:string(xmerl_ucs:to_utf8(Body)),
    A = lists:nth(3, Rss#xmlElement.content),
    % d(element(1, A)),
    d(lists:sublist(A#xmlElement.content, 19)),
    d(record_info(fields, xmlElement)),
    NewItem = fun
        (E = #xmlElement{name=item, content = Content}, Acc) ->
            T = getTitle(Content),
            _ = E,
            error_logger:error_msg("~s", [T]),
            % d(T),
            case test(T, Filters) of
                false -> Acc;
                true  -> Acc++[E]
            end;
        (E, Acc) -> Acc++[E]
    end,
    NewContent = lists:map(fun
        (E = #xmlElement{name=channel, content = Content}) ->
            d(channel),
            E#xmlElement{content = lists:foldl(NewItem, [], Content)};
        (E) -> E
    end, Rss#xmlElement.content),
    NewRss = Rss#xmlElement{content = NewContent},
    Res = xmerl:export_simple([NewRss], xmerl_xml, [{prolog, <<>>}]),
    {ok, Req2} = cowboy_req:reply(200, [], Res, Req),
    {ok, Req2, State}.


terminate(_Reason, _Req, _State) ->
    ok.

getTitle([#xmlElement{name = title, content = Content}|_]) ->
    xmerl:export_simple(Content, xmerl_xml, [{prolog, <<>>}]);
getTitle([_| Tail]) ->
    getTitle(Tail).

d(A) ->
    error_logger:error_msg("~p", [A]).

test(Title, Filters) ->
    lists:any(fun(Filter) ->
        case re:run(Title, Filter) of
            nomatch -> false;
            _ -> true
        end
    end, Filters).

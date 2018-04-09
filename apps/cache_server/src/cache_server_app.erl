%%%-------------------------------------------------------------------
%% @doc cache_server public API
%% @end
%%%-------------------------------------------------------------------

-module(cache_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->

    %%{ok, Port} = application:get_env(port),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/api/cache_server", cache_server_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
        {env, [{dispatch, Dispatch}]}
    ]),
    cache_server_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

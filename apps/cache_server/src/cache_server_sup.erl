%%%-------------------------------------------------------------------
%% @doc cache_server top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(cache_server_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Procs = {my_cache, {my_cache, start_link, []},
        permanent, 5000, worker, [my_cache]},
    {ok, {{one_for_one, 10, 10}, [Procs]}}.
%%====================================================================
%% Internal functions
%%====================================================================

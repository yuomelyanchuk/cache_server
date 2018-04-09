
-module(my_cache).


-behaviour(gen_server).

-include_lib("stdlib/include/ms_transform.hrl").

-define(Time,application:get_env(cache_server,drop_interval)).


-export([stop/0]).
-export([start_link/0]).
-export([get_timestamp/0]).

-export([init/1, handle_call/3, handle_cast/2,
  handle_info/2, terminate/2, code_change/3]).

-export([insert/2,lookup/1,lookup_by_date/2]).


-record(cacheItem, {key, value, lives_to = 0,inserted}).

get_timestamp() ->
  calendar:datetime_to_gregorian_seconds(calendar:now_to_datetime(os:timestamp())).


start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
  gen_server:call({local, ?MODULE}, stop).

init([]) ->
  State = ets:new(?MODULE, [public, {keypos, #cacheItem.key}, named_table]),
  %%{ok,T}=?Time,
   T=3600,
  timer:send_after(T * 1000, self(), {delete, T * 1000}),
  {ok, State}.

handle_info({delete, Time}, State) ->
  T_now = get_timestamp(),
  L = ets:select(?MODULE, ets:fun2ms(fun(#cacheItem{lives_to = T,key=K}) when T < T_now ->K end)),
  lists:map(fun(K) -> ets:delete(?MODULE, K) end, L),
  timer:send_after(Time, self(), {delete, Time}),
  {noreply, State}.


insert(K, V) ->
  %{ok,T}=?Time,
  T=3600,
  ets:insert(?MODULE, #cacheItem{key = K, value = V, lives_to = get_timestamp() + T,inserted = get_timestamp()}),
  jsone:encode({[{result, <<"ok">>}]}).

lookup(K)->
  Ex = ets:member(?MODULE, K),
  if
    Ex ->
      [Item | _T] = ets:lookup(?MODULE, K),
      Is_alive = Item#cacheItem.lives_to > get_timestamp(),
      if
        Is_alive -> jsone:encode({[{result,  Item#cacheItem.value}]});
        true -> jsone:encode({[{result,  []}]})
      end;
      true -> jsone:encode({[{result,  []}]})
  end.

lookup_by_date(Ds,De)->
  Res=ets:select(?MODULE,ets:fun2ms(fun(#cacheItem{inserted=I,key=K,value = V})
    when I>Ds, I<De ->[{<<"key">>,K},{<<"value">>,V}] end )),
  jsone:encode({[{result, Res}]}).


handle_cast(_Message, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.


handle_call(_Request, _From, State) ->
  {reply, ignored, State}.
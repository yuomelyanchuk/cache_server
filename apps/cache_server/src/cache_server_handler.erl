%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(cache_server_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).


init(_Type, Req, []) ->
  {ok, Req, undefined}.


handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  case Method of
    <<"POST">> ->
      {ok, ReqBody, Req3} = cowboy_req:body(Req2),
      Body = jsone:decode(ReqBody),
      {ok, Req4} = action(maps:get(<<"action">>, Body, <<"other_action">>), Body, Req3),
      {ok, Req4, State};
    _ -> {ok, Req3} = cowboy_req:reply(405, Req2),
      {ok, Req3, State}
  end.


action(<<"insert">>, Body, Req3) ->
  A = maps:is_key(<<"key">>, Body),
  B = maps:is_key(<<"value">>, Body),
  if
    A, B -> Result = my_cache:insert(maps:get(<<"key">>, Body), maps:get(<<"value">>, Body)),
      cowboy_req:reply(201, [], Result, Req3);
    true -> action(<<"other_action">>, [], Req3)
  end;

action(<<"lookup">>, Body, Req3) ->
  A = maps:is_key(<<"key">>, Body),
  if
    A -> Result = my_cache:lookup(maps:get(<<"key">>, Body)),
      cowboy_req:reply(200, [], Result, Req3);
    true -> action(<<"other_action">>, [], Req3)
  end;

action(<<"lookup_by_date">>, Body, Req3) ->
  A = maps:is_key(<<"date_from">>, Body),
  B = maps:is_key(<<"date_to">>, Body),
  if
    A, B ->
      Ds = ec_date:parse(binary_to_list(maps:get(<<"date_from">>, Body))),
      De = ec_date:parse(binary_to_list(maps:get(<<"date_to">>, Body))),
      Result = my_cache:lookup_by_date(calendar:datetime_to_gregorian_seconds(Ds),
        calendar:datetime_to_gregorian_seconds(De)),
      cowboy_req:reply(200, [], Result, Req3);
    true -> action(<<"other_action">>, [], Req3)
  end;

action(<<"other_action">>, _, Req3) ->
  cowboy_req:reply(400, [], [], Req3).








terminate(_Reason, _Req, _State) ->
  ok.

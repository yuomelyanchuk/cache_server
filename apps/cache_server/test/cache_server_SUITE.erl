
-module(cache_server_SUITE).


%% API
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib ("etest/include/etest.hrl").
% etest_http macros
-include_lib ("etest_http/include/etest_http.hrl").

all() ->
  [
    insert_test,
    lookup_test,
    lookup_test2,
    lookup_by_date_test
  ].


init_per_suite(Config) ->
  {ok,_A}=application:ensure_all_started(cache_server),
  Config.

end_per_suite(Config) ->
  ok = application:stop(cache_server),
  Config.

insert_test(_Config)->
  Js=jsone:encode({[{<<"action">>,insert},{<<"key">>,1},{<<"value">>,[1,2,3]}]}),
  Res = ?perform_post("http://localhost:8080/api/cache_server"
    , [{"Content-Type", "application/json"}], Js),
  ?assert_body("{\"result\":\"ok\"}",Res).

lookup_test(_Config)->
  Js=jsone:encode({[{<<"action">>,lookup},{<<"key">>,1}]}),
  Res = ?perform_post("http://localhost:8080/api/cache_server"
    , [{"Content-Type", "application/json"}], Js),
  ?assert_body("{\"result\":[1,2,3]}",Res).


lookup_test2(_Config)->
  Js=jsone:encode({[{<<"action">>,lookup},{<<"key">>,"1"}]}),
  Res = ?perform_post("http://localhost:8080/api/cache_server"
    , [{"Content-Type", "application/json"}], Js),
  ?assert_body("{\"result\":[]}",Res).

lookup_by_date_test(_Config)->
  Js=jsone:encode({[{<<"action">>,lookup_by_date}
    ,{<<"date_from">>,<<"2018/4/9 00:00:00">>}
    ,{<<"date_to">>,<<"2018/4/10 23:59:59">>}]}),

  Res = ?perform_post("http://localhost:8080/api/cache_server"
    , [{"Content-Type", "application/json"}], Js),
  ?assert_body("{\"result\":[{\"key\":1,\"value\":[1,2,3]}]}",Res).


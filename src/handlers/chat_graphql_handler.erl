-module(chat_graphql_handler).

%% API
-export([init/3, handle/2, terminate/3]).


init(_Type, Req, _Opts) ->
  {ok, Req, #{
  }}.

handle(Req, State)->
  {ok, Body, _} = cowboy_req:body(Req),
  {Session, _} = cowboy_req:cookie(<<"session">>, Req),

  BodyJson = jsx:decode(Body, [return_maps]),

  Document = maps:get(<<"query">>, BodyJson),
  Variables = maps:get(<<"variables">>, BodyJson, #{}),

  Context = #{
    req => Req,
    session => Session
  },

  Response = graphql:run(Document, #{
    variable_values => Variables,
    context => Context,
    return_maps => true
  }),

  {ok, Reply} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode(Response), Req),
  {ok, Reply, State}.

terminate(_Reason, _Req, _State) ->
  ok.
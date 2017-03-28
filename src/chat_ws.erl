-module(chat_ws).

-export([init/3]).
-export([websocket_handle/3, websocket_init/3]).
-export([websocket_info/3, websocket_terminate/3, terminate/3]).


init(_, Req, Opts) ->
  io:format("~nINIT WEBSOCKET~n"),
  gproc:reg({p, l, websocket}),
  {upgrade, protocol, cowboy_websocket, Req, Opts}.

websocket_init(_Type, Req, _Opts) ->
  {ok, Req, #{}}.

websocket_handle({text, Data}, Req, State) ->
  io:format("IMA! HANDLE THIS! State: ~p, Data: ~p~n", [State, Data]),

  {Session, _} = cowboy_req:cookie(<<"session">>, Req),

  Q = jsx:decode(Data, [return_maps]),

  Document = maps:get(<<"query">>, Q),
  Variables = maps:get(<<"variables">>, Q, #{}),

  Context = #{
    req => Req,
    session => Session,
    ws_pid => self()
  },

  Response = graphql:execute(chatql_schema:schema_ws(), Document, Variables, #{}, Context),

  io:format("Response: ~p~n", [Response]),

  {reply, {text, jsx:encode(Response)}, Req, State};

websocket_handle(Data, Req, State) ->
  io:format("HANDLE THIS! State: ~p, Data: ~p~n", [State, Data]),
  {ok, Req, State}.

websocket_info({sub, Channel, Context}, Req, State)->
  gproc:reg({p, l, Channel}),
  {ok, Req, State#{
    Channel => #{
      context => Context
    }
  }};

websocket_info({newmsg, Msg}, Req, State) ->
  #{msg := #{ context := Context}} = State,

  Reply = graphql_execution:execute_operation(Msg, Context#{resolve => query}),

  {reply, {text, jsx:encode(Reply#{operation => subscription})}, Req, State};

websocket_info(Info, Req, State) ->
  io:format("~nWEBSOCKET INFO: ~p~n", [Info]),
  {ok, Req, State}.

websocket_terminate(Reason, _, _) ->
  io:format("~nWescoket terminate: ~p", [Reason]),
  ok.

terminate(_, _Req, _State) ->
  io:format("TERMINATE~n"),
  ok.
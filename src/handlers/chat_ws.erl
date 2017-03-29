-module(chat_ws).

-export([init/3]).
-export([websocket_handle/3, websocket_init/3]).
-export([websocket_info/3, websocket_terminate/3, terminate/3]).


init(_, Req, _) ->
  io:format("~n * Init websocket~n"),
  case cowboy_session:get(<<"is_auth">>, false, Req) of
    {true, Req1} ->
      {User, Req2} = cowboy_session:get(<<"user">>, Req1),
      {upgrade, protocol, cowboy_websocket, Req2, #{
        current_user => User
      }};

    {false, _} -> terminate
  end.

websocket_init(_Type, Req, #{current_user := User} = Opts) ->
  gproc:reg({p, l, websocket}),

  chat_history:user_online(User),

  {ok, Req, Opts}.

websocket_handle({text, Data}, Req, #{current_user := User} = State) ->

  Q = jsx:decode(Data, [return_maps]),

  Document = maps:get(<<"query">>, Q),
  Variables = maps:get(<<"variables">>, Q, #{}),

  Context = #{
    req => Req,
    user => User,
    ws_pid => self()
  },

  Response = graphql:execute(chatql_schema:schema_ws(), Document, Variables, #{}, Context),

  io:format("Response: ~p~n", [Response]),

  {reply, {text, jsx:encode(Response)}, Req, State};

websocket_handle(Data, Req, State) ->
  io:format("HANDLE THIS! State: ~p, Data: ~p~n", [State, Data]),
  {ok, Req, State}.

websocket_info({sub, user, RoomId, Context}, Req, State)->
  gproc:reg({p, l, user}),
  {ok, Req, State#{
    user => #{
      room_id => RoomId,
      context => Context
    }
  }};

websocket_info({user, Action, UserId, Room}, Req, #{ user := Sub} = State)->
  case Action of
    _ when Action =:= online orelse Action =:= offline ->
      case Sub of
        #{room_id := Room, context := Context} ->  % this is it!
          Msg = #{
            user => chat_history:get_user(UserId),
            action => Action
          },
          Reply = graphql_execution:execute_operation(Msg, Context#{resolve => query}),
          io:format("Make reply!: ~p~n", [Reply]),
          {reply, {text, jsx:encode(Reply#{operation => subscription})}, Req, State};
        _ -> {ok, Req, State}  % nothing interesting here - ignore it
      end;
    swith ->
%%      {FromRoom, ToRoom} = Room,
      {ok, Req, State}
  end;

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

websocket_terminate(_, _, #{current_user := User}) ->
  gproc:unreg({p, l, websocket}),
  chat_history:user_offline(User),
  ok.

terminate(_, _Req, _State) ->
  io:format("TERMINATE~n"),
  ok.
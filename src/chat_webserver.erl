-module(chat_webserver).

-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-record(state, {}).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  Port = case os:getenv("PORT") of false -> 8080; Any -> list_to_integer(Any) end,

  io:format("* Init webserver. PORT: ~p~n", [Port]),

  Dispatch = cowboy_router:compile([
    {'_', [
      {"/", chat_handler, []},
      {"/auth_callback", chat_auth_handler, []},
      {"/graphiql", cowboy_static, {priv_file, chat, "graphiql.html"}},
      {"/graphql", chat_graphql_handler, []},
      {"/ws", chat_ws, []},

%%      {"/static/[...]", cowboy_static, {priv_div, chat, "static"}}  %%  FIXME: does not work :(
      {"/static/GitHub-Mark-32px.png", cowboy_static, {priv_file, chat, "static/GitHub-Mark-32px.png"}},
      {"/static/chat.js", cowboy_static, {priv_file, chat, "static/chat.js"}},
      {"/static/chat.css", cowboy_static, {priv_file, chat, "static/chat.css"}}
    ]}
  ]),

  cowboy:start_http(http, 100, [
    {port, Port}
  ], [
    {env, [{dispatch, Dispatch}]},
    {onrequest, fun cowboy_session:on_request/1}
  ]),

  {ok, #state{}}.

%%%%%%%%%%%%%%%%%%%%%%
% GenServer callbacks
%%%%%%%%%%%%%%%%%%%%%%
handle_call(Msg, _From, State) ->
  io:format("Unknown handle_call: ~p~n", [Msg]),
  {reply, unknown, State}.

handle_cast(Msg, State) ->
  io:format("Unknown pubsub cast: ~p~n", [Msg]),
  {noreply, State}.

handle_info(start, S) ->
  {stop, normal, S}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

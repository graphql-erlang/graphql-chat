-module(chatql_message).
-include_lib("graphql/include/types.hrl").

%% API
-export([

  % resolvers
  resolver/3,
  subscription_resolver/3,

  % types
  mutation/0,
  type/0
]).

resolver(_, _, #{session := Session}) ->
  chat_user:get_user(Session).

subscription_resolver(Obj,_, #{resolve := query}) ->
  [Obj];
subscription_resolver(_,_, #{ws_pid := SubPid} = Context) ->
  SubPid ! {sub, msg, Context},
  chat_history:get().


type() -> ?OBJECT("Message", "Chat item", #{

  "user" => ?FIELD(?STRING, "Username", fun(Obj)-> maps:get(user, Obj) end),
  "msg" => ?FIELD(?STRING, "Message", fun(Obj)-> maps:get(msg, Obj) end)

}).

mutation() -> ?OBJECT("MessageMutation", "Mutation for messages", #{
  "send" => ?FIELD(type(), "Send message", #{
    "username" => ?ARG(?STRING, "Message author"),
    "text" => ?ARG(?STRING, "Message data")
  }, fun(_, #{<<"username">> := User, <<"text">> := Text}, _) ->
    Msg = #{
      user => User,
      msg => Text
    },

    chat_history:save(Msg),

    Msg
  end)

}).
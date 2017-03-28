-module(chatql_message).
-include_lib("graphql/include/types.hrl").

%% API
-export([

  % resolvers
%%  resolver/3,
  subscription_resolver/3,

  % types
  mutation/0,
  type/0
]).


subscription_resolver(Obj,_, #{resolve := query}) ->
  [Obj];
subscription_resolver(_,_, #{ws_pid := SubPid} = Context) ->
  SubPid ! {sub, msg, Context},
  chat_history:get().


type() -> ?OBJECT("Message", "Chat item", #{

  "user" => ?FIELD(fun chatql_user:type/0, "Message owner", fun(Obj)-> maps:get(user, Obj) end),
  "msg" => ?FIELD(?STRING, "Message", fun(Obj)-> maps:get(msg, Obj) end)

}).

mutation() -> ?OBJECT("MessageMutation", "Mutation for messages", #{
  "send" => ?FIELD(type(), "Send message", #{
    "text" => ?ARG(?STRING, "Message data")
  }, fun(_, #{<<"text">> := Text}, #{user := User}) ->
    Msg = #{
      user => User,
      msg => Text
    },

    chat_history:save(Msg),

    Msg
  end)

}).
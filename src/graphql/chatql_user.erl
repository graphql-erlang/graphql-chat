-module(chatql_user).
-include_lib("graphql/include/types.hrl").

%% API
-export([
  subscription_rooms_resolver/3,

  room_users/0,
  type/0
]).

subscription_rooms_resolver(Obj, _, #{resolve := query}) ->
  io:format("Obj ib rooms: ~p~n", [Obj]),
  #{
    users => [maps:get(user, Obj)],
    action => maps:get(action, Obj)
  };
subscription_rooms_resolver(_, #{<<"room_id">> := RoomId}, #{ws_pid := WsPid} = Context) ->
  WsPid ! {sub, user, RoomId, Context},
  {ok, #{
    users => lists:map(fun(UserId)->
        chat_history:get_user(UserId)
      end, chat_history:room_users(RoomId)),
    action => null
  }}.

room_users()-> ?OBJECT('RoomUsersSubscription', "", #{
  "users" => ?FIELD(?LIST(fun type/0), "List of room users or user with action", fun(#{users := Users}) ->
    {ok, Users}
  end),
  "action" => ?FIELD(fun room_user_action_enum/0, "User actions", fun(#{action := Action})-> {ok, Action} end)
}).

room_user_action_enum() -> ?ENUM('UserActionSubscription', "connected/disconnected", [
  ?ENUM_VAL(online, "ENTERED", "User entered into room"),
  ?ENUM_VAL(offline, "LEFT", "User left the chat")
]).

type()-> ?OBJECT('User', "Github user", #{
  <<"avatar_url">> => ?FIELD(?STRING),
  <<"bio">> => ?FIELD(?STRING),
  <<"blog">> => ?FIELD(?STRING),
  <<"company">> => ?FIELD(?STRING),
  <<"created_at">> => ?FIELD(?STRING),
  <<"email">> => ?FIELD(?STRING),
  <<"events_url">> => ?FIELD(?STRING),
  <<"followers">> => ?FIELD(?INT),
  <<"followers_url">> => ?FIELD(?STRING),
  <<"following">> => ?FIELD(?INT),
  <<"following_url">> => ?FIELD(?STRING),
  <<"gists_url">> => ?FIELD(?STRING),
  <<"gravatar_id">> => ?FIELD(?STRING),
  <<"hireable">> => ?FIELD(?BOOLEAN),
  <<"html_url">> => ?FIELD(?STRING),
  <<"id">> => ?FIELD(?INT),
  <<"location">> => ?FIELD(?STRING),
  <<"login">> => ?FIELD(?STRING),
  <<"name">> => ?FIELD(?STRING),
  <<"organizations_url">> => ?FIELD(?STRING),
  <<"public_gists">> => ?FIELD(?INT),
  <<"public_repos">> => ?FIELD(?INT),
  <<"received_events_url">> => ?FIELD(?STRING),
  <<"repos_url">> => ?FIELD(?STRING),
  <<"site_admin">> => ?FIELD(?BOOLEAN),
  <<"starred_url">> => ?FIELD(?STRING),
  <<"subscriptions_url">> => ?FIELD(?STRING),
  <<"type">> => ?FIELD(?STRING),
  <<"updated_at">> => ?FIELD(?STRING),
  <<"url">> => ?FIELD(?STRING)
}).



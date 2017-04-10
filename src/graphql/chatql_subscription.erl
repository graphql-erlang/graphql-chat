-module(chatql_subscription).
-include_lib("graphql/include/types.hrl").

-export([type/0]).

type()-> ?OBJECT('Subscription', "Root object type for subscriptions", #{

  "messages" => ?FIELD(?LIST(fun chatql_message:type/0), "Subscribe to messages", fun chatql_message:subscription_resolver/3),

  "room_users" => ?FIELD(fun chatql_user:room_users/0, "Subsctibe for room participants", #{
    "room_id" => ?ARG(?NON_NULL(?INT))
  }, fun chatql_user:subscription_rooms_resolver/3)

}).

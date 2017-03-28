-module(chatql_subscription).
-include_lib("graphql/include/types.hrl").

-export([type/0]).

type()-> ?OBJECT("Subscription", "Root object type for subscriptions", #{

  "messages" => ?FIELD(?LIST(fun chatql_message:type/0), "Subscribe to messages", fun chatql_message:subscription_resolver/3)

}).

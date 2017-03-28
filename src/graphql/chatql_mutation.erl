-module(chatql_mutation).
-include_lib("graphql/include/types.hrl").

-export([type/0]).

type()-> ?OBJECT("Mutation", "Root object type for mutation", #{

  "message" => ?FIELD(fun chatql_message:mutation/0, "", fun()-> #{} end)

}).

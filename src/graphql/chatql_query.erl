-module(chatql_query).
-include_lib("graphql/include/types.hrl").

-export([type/0]).

type()-> ?OBJECT("Query", "Root object type for query", #{

  "hello" => ?FIELD(?STRING, "hello", fun() -> <<"ok">> end)

}).

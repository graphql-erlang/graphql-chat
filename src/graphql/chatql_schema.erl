-module(chatql_schema).
-include_lib("graphql/include/types.hrl").

%% API
-export([
  schema_http/0,
  schema_ws/0
]).

schema_http() -> graphql:schema(#{
  query => chatql_query:type(),
  mutation => chatql_mutation:type()
}).

schema_ws() -> graphql:schema(#{
  query => chatql_query:type(),
  mutation => chatql_mutation:type(),
  subscription => chatql_subscription:type()
}).

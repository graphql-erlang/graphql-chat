-module(chatql_scalar_datetime).
-include_lib("graphql/include/types.hrl").
%% API
-export([type/0]).

type()-> #{
  kind => 'SCALAR',
  name => 'DateTime',
  ofType => null,
  description => <<
    "Respresent erlang datetime on erlang side and unixtimestamp on front"
  >>,

  serialize => fun serialize/3,
  parse_value => fun parse_value/2,
  parse_literal => fun parse_literal/2
}.

serialize(Datetime,_,_) -> to_timestamp(Datetime).

parse_value(null,_) -> null.

parse_literal(null, _) -> null.

to_timestamp({{Year,Month,Day},{Hours,Minutes,Seconds}}) ->
  (calendar:datetime_to_gregorian_seconds(
    {{Year,Month,Day},{Hours,Minutes,Seconds}}
  ) - 62167219200).
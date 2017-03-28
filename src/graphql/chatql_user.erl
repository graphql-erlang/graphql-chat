-module(chatql_user).
-include_lib("graphql/include/types.hrl").

%% API
-export([type/0]).

type()-> ?OBJECT("User", "Github user", #{
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



-module(chat_auth_handler).

%% API
-export([init/3, handle/2, terminate/3]).


init(_Type, Req, _Opts) -> {ok, Req, #{ }}.


handle(Req, State)->
  case cowboy_req:path(Req) of
    {<<"/auth_callback", _/binary>>, _} -> handle_callback(Req, State);
    {<<"/auth", _/binary>>, _} -> handle_auth(Req, State)
  end.

handle_auth(Req, State) ->

  Args = #{
    <<"client_id">> => list_to_binary(os:getenv("GITHUB_CLIENT_ID")),
    <<"redirect_uri">> => list_to_binary(os:getenv("GITHUB_REDIRECT_URI", "http://127.0.0.1:8080/auth_callback"))
  },

  {ok, chat:reply("templates/auth.html", Args, Req), State}.

handle_callback(Req, State)->
  {Code, _} = cowboy_req:qs_val(<<"code">>, Req),

  {ok, Response} = chat:github_request(post, "https://github.com/login/oauth/access_token", #{
    client_id => list_to_binary(os:getenv("GITHUB_CLIENT_ID")),
    client_secret => list_to_binary(os:getenv("GITHUB_CLIENT_SECRET")),
    code => Code
  }),

  {ok, handle_step2(Response, Req), State}.


handle_step2(#{<<"error">> := _} = Res, Req) ->
  chat:reply("templates/error_github.html", Res, Req);
handle_step2(#{<<"access_token">> := Token}, Req) ->
  {ok, User} = chat:github_request(get, "https://api.github.com/user", Token),
  {ok, Req2} = cowboy_session:set(<<"access_token">>, Token, Req),
  {ok, Req3} = cowboy_session:set(<<"user">>, User, Req2),
  {ok, Req4} = cowboy_session:set(<<"is_auth">>, true, Req3),

  {ok, Reply} = cowboy_req:reply(302, [
    {<<"Location">>, <<"/chat">>}
  ], <<>>, Req4),
  Reply.


terminate(_Reason, _Req, _State) ->
  ok.
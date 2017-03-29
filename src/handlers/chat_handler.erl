-module(chat_handler).

%% API
-export([init/3, handle/2, terminate/3]).


init(_Type, Req, _Opts) -> {ok, Req, #{ }}.

handle(Req, State) ->

  case cowboy_session:get(<<"is_auth">>, false, Req) of

    {true, Req1} ->
      {User, Req2} = cowboy_session:get(<<"user">>, Req1),
      {ok, chat:reply("templates/chat.html", User, Req2), State};

    {false, Req1} ->
      Args = #{
        <<"client_id">> => list_to_binary(os:getenv("GITHUB_CLIENT_ID")),
        <<"redirect_uri">> => list_to_binary(os:getenv("GITHUB_REDIRECT_URI", "http://127.0.0.1:8080/auth_callback"))
      },

      {ok, chat:reply("templates/auth.html", Args, Req), State}

  end.


terminate(_Reason, _Req, _State) ->
  ok.
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
      {ok, chat:reply("templates/forbidden.html", #{}, Req1), State}

  end.


terminate(_Reason, _Req, _State) ->
  ok.
-module(chat).
-author("mrchex").

%% API
-export([
  get_priv/1,
  format_template/2,
  format_file/2,
  reply/3,
  github_request/3
]).

get_priv(Path) when is_list(Path) ->
  PrivDir = code:priv_dir(chat),
  file:read_file(PrivDir ++ "/" ++ Path).

format_template(Template, Args) when is_binary(Template) and is_map(Args)->
  maps:fold(fun(K, V, Acc) ->
    binary:replace(Acc, [<<"{{", K/binary,"}}">>, <<"{{ ", K/binary," }}">>], coerce_value(V), [global])
  end, Template, Args).

coerce_value(V) when is_atom(V)-> atom_to_binary(V, utf8);
coerce_value(V) when is_binary(V) -> V;
coerce_value(V) when is_integer(V) -> list_to_binary(integer_to_list(V)).

format_file(Path, Args)->
  {ok, Template} = get_priv(Path),
  format_template(Template, Args).

reply(TemplatePath, Args, Req) ->
  {ok, Req2} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"text/html">>}
  ], chat:format_file(TemplatePath, Args), Req),
  Req2.

github_request(post, URI, Request)->
  RequestEncoded = jsx:encode(Request),

  {ok, {
    {"HTTP/1.1", 200, "OK"}, _, Body
  }} = httpc:request(
    post,
    { URI,
      [{"Accept", "application/json"}],
      "application/json",
      RequestEncoded
    },
  [], []),

  {ok, jsx:decode(list_to_binary(Body), [return_maps])};

github_request(get, URI, Token)->

  {ok, {
    {"HTTP/1.1", 200, "OK"}, _, Body
  }} = httpc:request( get,
    { URI,
      [
        {"Accept", "application/json"},
        {"User-Agent", "GraphQL-Chat"},
        {"Authorization", "token " ++ binary_to_list(Token)}
      ]
    },
  [], []),

  {ok, jsx:decode(list_to_binary(Body), [return_maps])}.

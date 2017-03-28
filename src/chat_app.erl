%%%-------------------------------------------------------------------
%% @doc graphql-chat public API
%% @end
%%%-------------------------------------------------------------------

-module(chat_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    chat_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
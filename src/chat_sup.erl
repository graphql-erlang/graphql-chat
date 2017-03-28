-module(chat_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).
-define(STOP_CHILD_TIMEOUT, 5000).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, ?STOP_CHILD_TIMEOUT, Type, [I]}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_all, 0, 1}, [
        ?CHILD(chat_history, worker),
        ?CHILD(chat_webserver, worker)
    ]} }.

%%====================================================================
%% Internal functions
%%====================================================================

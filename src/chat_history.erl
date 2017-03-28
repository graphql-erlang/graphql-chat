-module(chat_history).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([
  save/1,
  get/0
]).

-define(SERVER, ?MODULE).

-record(state, {
  history = []
}).

start_link() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
init([]) -> {ok, #state{}}.


save(Msg) -> gen_server:call(?SERVER, {save, Msg}).
get() -> gen_server:call(?SERVER, get).

handle_call({save, Msg}, _From, #state{history = History} = State) ->
  History1 = [Msg|History],
  History2 = case length(History1) of
    Len when Len > 10 ->
      A = lists:reverse(History1),
      [_|B] = A,
      lists:reverse(B);
    _ -> History1
  end,

  gproc:send({p,l, msg}, {newmsg, Msg}),

  {reply, ok, State#state{ history = History2}};

handle_call(get, _From, #state{history = History} = State) ->
  {reply, History, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
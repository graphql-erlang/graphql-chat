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
  get/0,
  get_user/1,
  get_room/1,
  rooms/0,
  room_users/1,
  user_online/1, user_offline/1
]).

-define(SERVER, ?MODULE).

-record(state, {
  history = [],
  rooms = #{
    1 => #{
      id => 1,
      name => <<"General">>,
      protected => true
    },

    2 => #{
      id => 2,
      name => <<"Random">>
    },

    3 => #{
      id => 3,
      name => <<"GraphQL Dev">>
    }
  },
  default_room = 1,
  rooms_i = 3,  % increment

  users = #{},  % UserId => UserObject
  room_users = #{}  % UserId => RoomId
}).

start_link() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
init([]) -> {ok, #state{}}.

% api
save(Msg) -> gen_server:call(?SERVER, {save, Msg}).
get() -> gen_server:call(?SERVER, get).
get_user(UserId) -> gen_server:call(?SERVER, {get_user, UserId}).
get_room(RoomId) -> gen_server:call(?SERVER, {get_room, RoomId}).
rooms() -> gen_server:call(?SERVER, rooms).
room_users(RoomId) -> gen_server:call(?SERVER, {room_users, RoomId}).

user_online(User)-> gen_server:call(?SERVER, {user, online, User}).
user_offline(User)-> gen_server:call(?SERVER, {user, offline, User}).


% internal
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
  {reply, History, State};

handle_call({get_user, UserId}, _, #state{users = Users} = State)->
  {reply, maps:get(UserId, Users, null), State};

handle_call({get_room, RoomId}, _, #state{rooms = Rooms} = State)->
  {reply, maps:get(RoomId, Rooms, null), State};

handle_call(rooms, _, #state{rooms = Rooms} = State)-> {reply, Rooms, State};
handle_call({room_users, RoomId}, _, #state{room_users = RoomUsers} = State) ->

  Reply = maps:fold(fun
    (UserId, UserRoomId, Acc) when UserRoomId =:= RoomId-> [UserId|Acc];
    (_,_,Acc) -> Acc
  end, [], RoomUsers),

  {reply, Reply, State};

handle_call({user, online, #{<<"id">> := UserId} = User}, _From, State) ->
  RoomUsers0 = State#state.room_users,
  RoomUsers = RoomUsers0#{
    UserId => State#state.default_room
  },

  gproc:send({p,l, user}, {user, online, UserId, State#state.default_room}),

  {reply, maps:get(State#state.default_room, State#state.rooms), State#state{
    room_users = RoomUsers,
    users = (State#state.users)#{
      UserId => User
    }
  }};

handle_call({user, offline, #{<<"id">> := UserId}}, _From, State) ->
  UserRoomId = maps:get(UserId, State#state.room_users),

  gproc:send({p,l, user}, {user, offline, UserId, UserRoomId}),

  {reply, ok, State#state{
    room_users = maps:remove(UserId, State#state.room_users)
  }}.


handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
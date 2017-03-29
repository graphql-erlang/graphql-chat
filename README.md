# GraphQL chat example
Chat example with subscription on graphql-erlang

# Run

```bash
$ env GITHUB_REDIRECT_URI=http://you-host/auth_callback GITHUB_CLIENT_ID= GITHUB_CLIENT_SECRET= rebar3 auto
```

# gproc messages

messages

`{p,l, msg}, {newmsg, Msg}`

user actions

`{p,l, user}, {user, online, UserId, RoomId}`

`{p,l, user}, {user, offline, UserId, RoomId}`

# limitations

- only one user socket (do not open separate window with chat)
- history does not save
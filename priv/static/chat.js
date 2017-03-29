// This is demo of erlang code not js ) thats why this code is so ugly (i know - erlang code ugly too. I work on improvements :) )

var protocol = location.protocol === "https:" ? "wss:" : "ws:";
var ws = new WebSocket(protocol + "//" + location.host + "/ws/");

ws.onopen = function() {
  document.getElementById("online-status").innerHTML = "online";
  ws.send(makeQ(`subscription { messages { user { ...User } msg created } } ${userFragment()}`));
  ws.send(makeQ(`subscription($roomId: Int!) { room_users(room_id: $roomId) { users { ...User } action }} ${userFragment()}`, {roomId: 1}));
};

ws.close = function() {
  document.getElementById("online-status").innerHTML = "offline";
};

ws.onmessage = function(msg) {
  var data = JSON.parse(msg.data)
  if(data.data.messages)
    handleMessages(data.data.messages);
  else if(data.data.room_users)
    handleRoomUsers(data.data.room_users);
};

function makeQ(query, variables) {
  return JSON.stringify({
    "query": query,
    "variables": variables
  })
}

function handleMessages(msgs) {
  var m = document.getElementById('inbox');
  var messagesHtml = msgs.map(msgDiv);
  m.innerHTML = messagesHtml.join("") + m.innerHTML;
}

var g_users_online = [];

function handleRoomUsers(o) {
  if(o.action === null)
    g_users_online = o.users;
  else if(o.action === "ENTERED") {
    $('#online_users_log').prepend(`<li><a href="${o.users[0].url}">@${o.users[0].login}</a> entered</li>`);
    g_users_online.push(o.users[0]);
  } else if(o.action === "LEFT") {
    $('#online_users_log').prepend(`<li><a href="${o.users[0].url}">@${o.users[0].login}</a> left</li>`);
    g_users_online = g_users_online.filter( user => user.id != o.users[0].id );
  }
  render_online_users();
}

function render_online_users() {
  $('#online_users').html(g_users_online.map(userDiv).join(''));
}







function formSubmit(e) {
  var text = document.getElementById('text').value;
  ws.send(makeQ(`mutation($msg: String) {
                message {
                  send( text: $msg) { user { ...User } msg created }
                }
              } ${userFragment()}`, {msg: text}));
  document.getElementById('text').value = "";
}

function userFragment() {return `fragment User on User {
                id
                login
                avatar_url
                url:html_url
            }`;}

function msgDiv(msg) {
  var dateString = new Date(msg.created * 1000).toLocaleString();
  return `<div class="msg">
    <img src="${msg.user.avatar_url}" />
    <a href="${msg.user.url}">@${msg.user.login}</a> [${dateString}]<br />
    ${msg.msg}
  </div>`;
}

function userDiv(user) {
  return `<div class="msg">
        <img src="${user.avatar_url}" />
        ${user.login}
    </div>`;
}
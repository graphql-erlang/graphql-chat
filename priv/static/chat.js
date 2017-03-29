var protocol = location.protocol === "https:" ? "wss:" : "ws:";
var ws = new WebSocket(protocol + "//" + location.host + "/ws/");

ws.onopen = function() {
  console.log("WS OPEN!");
  ws.send(makeQ(`subscription { messages { user { ...User } msg } } ${userFragment()}`));
};

ws.close = function() {
  console.log('WS closed');
};

ws.onmessage = function(msg) {
  var data = JSON.parse(msg.data)
  console.log("Msg: ", data);
  if(data.data.messages) {
    handleMessages(data.data.messages);
  }
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

function formSubmit(e) {
  var text = document.getElementById('text').value;
  ws.send(makeQ(`mutation($msg: String) {
                message {
                  send( text: $msg) { user { ...User } msg }
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
  return `<div class="msg">
    <img src="${msg.user.avatar_url}" />
    <a href="${msg.user.url}">${msg.user.login}</a><br />
    ${msg.msg}
  </div>`;
}
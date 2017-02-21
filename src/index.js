require('./styles/reset.css');
require('./styles/main.css');
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('root');

var app = Elm.Main.embed(mountNode);

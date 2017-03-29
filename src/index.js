// require('./styles/reset.css');
// require('./styles/main.css');
require('materialize-css/sass/materialize.scss');
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('root');

var app = Elm.Main.embed(mountNode, {
    width: window.innerWidth,
    height: window.innerHeight,
    currentTime: Date.now()
});

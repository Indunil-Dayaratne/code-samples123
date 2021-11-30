import Vue from 'vue';

Vue.prototype.$getRandomColor = function () {
  //var letters = '0123456789ABCDEF';
  //var color = '#';
  //for (var i = 0; i < 6; i++) {
  //  color += letters[Math.floor(Math.random() * 16)];
  //}

  // return color;
  return "#" + ((1 << 24) * Math.random() | 0).toString(16);

  /* Brit colours
  var colours = [
    "#000000",
    "#3A2178",
    "#85679D",
    "#BE79AC",
    "#464646",
    "#66CCFF",
    "#00B8DB",
    "#004B8C",
    "#007BA5",
    "#F37B7D",
    "#C74A5D",
    "#6F1200",
    "#FFD200",
    "#B5D334",
    "#4BB749",
    "#296858",
    "#C3B600",
    "#D1D3CE",
    "#919195"  
  ]
  return colours[Math.floor(Math.random() * colours.length)];
  */

}
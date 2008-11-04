window.addEvent('domready', function(){
  $$('td.progressed').each(function(day){
    var x = new Element('div', {'class': 'xmarksthespot ' + ["x-1", "x-2", "x-3"].getRandom() });
    day.appendChild(x);
  })
});
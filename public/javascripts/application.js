jQuery.ajaxSetup({  
  'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
}); 

$(document).ready(function () {
  $('.sparkline').sparkline('html', {type: 'bar', barColor: '#383838'});
});

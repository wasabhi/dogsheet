jQuery.ajaxSetup({  
  'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
}); 

$(document).ready(function () {
  $('.sparkline').sparkline('html', {type: 'bar', barColor: '#383838'});

  $('#timeslice_select_all').click(function () {
    var checked = $(this).attr('checked');
    $('td.checkbox input').attr('checked', checked);
  });
});

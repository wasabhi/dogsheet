$(document).ready(function () {
  $('#new_task').submit(function (){
    $.post($(this).attr('action'), $(this).serialize(), null, "script");
    return false;
  });
});

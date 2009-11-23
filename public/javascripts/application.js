jQuery.ajaxSetup({  
  'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
}); 

$(document).ready(function () {

  /* Bring the task selector into focus on page load */
  $('#timeslice_task_id').focus();

  timeentry_attrs = {
    show24Hours: true,
    timeSteps: [1,15,0],
    spinnerImage: '',
    beforeShow: limitRange
  };

  $('#timeslice_started_time').timeEntry(timeentry_attrs);
  $('#timeslice_finished_time').timeEntry(timeentry_attrs);

  /* Override action of 'Create timeslice' form */
  $('#new_timeslice').submit(function (){
    $.post($(this).attr('action'), $(this).serialize(), null, "script");
    return false;
  });

  $('#new_task').submit(function (){
    $.post($(this).attr('action'), $(this).serialize(), null, "script");
    return false;
  });

});

/* Limit relevant time entry max + min based on value of the other */
function limitRange(input) {
  return { minTime: (input.id == 'timeslice_finished_time' ?
    $('#timeslice_started_time').timeEntry('getTime') : null),
    maxTime: (input.id == 'timeslice_started_time' ?
    $('#timeslice_finished_time').timeEntry('getTime') : null)
  }
}

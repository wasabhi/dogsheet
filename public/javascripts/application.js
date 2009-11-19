jQuery.ajaxSetup({  
  'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
}); 

$(document).ready(function () {

  $('#task_id').focus();

  $('#timeslice_started_time').timeEntry({
                                show24Hours: true,
                                timeSteps: [1,15,0],
                                spinnerImage: '',
                                beforeShow: limitRange
  });
  $('#timeslice_finished_time').timeEntry({
                                show24Hours: true,
                                timeSteps: [1,15,0],
                                spinnerImage: '',
                                beforeShow: limitRange
  });

  $('#new_timeslice').submit(function (){
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

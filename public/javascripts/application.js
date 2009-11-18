$(document).ready(function () {
  $('#timeslice_started_time').timeEntry({
                                show24Hours: true,
                                timeSteps: [1,15,0],
                                beforeShow: limitRange
  });
  $('#timeslice_finished_time').timeEntry({
                                show24Hours: true,
                                timeSteps: [1,15,0],
                                beforeShow: limitRange
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

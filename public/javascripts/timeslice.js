$(document).ready(function () {

  $('#timeslice_task_id').mcDropdown('#task_list', { 
    allowParentSelect: true
  });

  $('#timeslice_task_id').mcDropdown().focus();

  timeentry_attrs = {
    show24Hours: true,
    timeSteps: [1,TIMESLICE_GRANULARITY,0],
    spinnerImage: '',
    initialField: 1,
  };

  finished_timeentry_attrs = {
    beforeShow: limitRange
  };

  finished_timeentry_attrs = {
    beforeShow: limitRange
  };

  $('#timeslice_started_time').timeEntry(timeentry_attrs);
  $('#timeslice_started_time').change(function() {
    $('#timeslice_finished_time').timeEntry('change', {
      minTime: $(this).timeEntry('getTime')
    });
  });
  $('#timeslice_finished_time').timeEntry(timeentry_attrs);
  $('#timeslice_finished_time').timeEntry('change', finished_timeentry_attrs);

  /* Override action of 'Create timeslice' form */
  $('#new_timeslice').submit(function (){
    $.post($(this).attr('action'), $(this).serialize(), null, "script");
    return false;
  });

  $('input.dateselect').daterangepicker({
    dateFormat:'yy-mm-dd',
    presetRanges: [
			{text: 'Today', dateStart: 'today', dateEnd: 'today' },
      {text: 'Working week to date', dateStart: function(){ return Date.parse('today').is().monday() ? Date.parse('today') : Date.parse('last Monday') }, dateEnd: 'Today' },
			{text: 'Month to date', dateStart: function(){ return Date.parse('today').moveToFirstDayOfMonth();  }, dateEnd: 'today' },
			{text: 'Last month', dateStart: function(){ return Date.parse('1 month ago').moveToFirstDayOfMonth();  }, dateEnd: function(){ return Date.parse('1 month ago').moveToLastDayOfMonth();  } }
    ],
    presets: {specificDate: 'Specific date',dateRange: 'Date range'}
  });

  $('h3.dayheader.closed').next().toggle(false);

  $('h3.dayheader').click(function() {
    $(this).next().toggle('fast');
    $(this).toggleClass('closed');
  });

  $('#collapse-all').click(function() {
    $('.timeslice-list').toggle(false);
    $('h3.dayheader').addClass('closed');
  });
  $('#expand-all').click(function() {
    $('.timeslice-list').toggle(true);
    $('h3.dayheader').removeClass('closed');
  });
});

/* Limit relevant time entry max + min based on value of the other */
function limitRange(input) {
  return { 
    minTime: (input.id == 'timeslice_finished_time' ?
      $('#timeslice_started_time').timeEntry('getTime') : null),
    maxTime: (input.id == 'timeslice_started_time' ?
      $('#timeslice_finished_time').timeEntry('getTime') : null)
  }
}

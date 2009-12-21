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

  $('#new_task').submit(function (){
    $.post($(this).attr('action'), $(this).serialize(), null, "script");
    return false;
  });

  $('#task-tree .task').draggable({revert: "invalid"});
  $('#task-tree .task').droppable({
    accept: '#task-tree .task',
    hoverClass: "accept",
    drop: function(event, props) {
      $('#task-tree').load('tasks/move',
        {drag_id: $(props.draggable).attr('id'),
         drop_id: $(this).attr('id')});
    }
  });

  $('#dateselect').daterangepicker({
    dateFormat:'yy-mm-dd'
  });

  $('#dateselect-go').click(function(){
    window.location.href = '/timesheet/' + 
                            $('#dateselect').val().split(' - ').join('/');
  });

  $('h3.dayheader.closed').next().toggle(false);

  $('h3.dayheader').click(function() {
    $(this).next().toggle('fast');
    $(this).toggleClass('closed');
    return false;
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

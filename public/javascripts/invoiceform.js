$(document).ready(function () {
  $('.datepicker').datepicker({
    dateFormat:'yy-mm-dd'
  });

  $('#timeslice_select_all').click(function () {
    var checked = $(this).attr('checked');
    $('td.checkbox input').attr('checked', checked);
    calculateTotals();
  });

  $('input.timeslice_toggle').change(function() {calculateTotals()});
});

function calculateTotals() {
  var total = 0.00;
  $('tbody > tr.timeslice').each(function(index) {
    if ($(this).find('input.timeslice_toggle:first').is(':checked')) {
      total = total + parseFloat($(this).attr('data-cost'));
    }
  });
  $('td#total').text('$' + $.currency(total));
}

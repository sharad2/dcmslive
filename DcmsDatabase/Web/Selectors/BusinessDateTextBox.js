/* Applies bdtb-month-start class to month start dates */
function BusinessDateTextBox_beforeShowDay(date) {
    var _bdtb_startDates = [[]];      // Empty square brackets will be replaced by month start array by the server control
    var cssClass = '';
    var tip = '';
    var curyear = date.getFullYear();
    var curmonth = date.getMonth();
    var curdate = date.getDate();
    for (var i = 0; i < _bdtb_startDates.length; ++i) {
        var curStartDate = _bdtb_startDates[i];
        if (curStartDate[0] == curyear && curStartDate[1] == curmonth && curStartDate[2] == curdate) {
            cssClass = 'bdtb-month-start ui-priority-primary';
            tip = 'Business month start date';
            break;
        }
    }
    return [true, cssClass, tip];
}
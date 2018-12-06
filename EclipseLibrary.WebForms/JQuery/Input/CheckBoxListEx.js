/*
Raises custom event cblitemclick when any of the checkboxes within the list are clicked. This event
is used as our InterestEvent.

cblitemclick can be raised for two reasons:
- user clicks on a check box. In this case e.originalEvent.target refers to the input control which was clicked.
- check box list was loaded via ajax. In this case e.originalEvent is undefined.

Example:
function(e) {
if (e.originalEvent === undefined) {
// Read all the checked values and do something with them
var values = $(this).checkBoxListEx('values');
// Or initialize the checkboxes
$(this).checkBoxListEx('select', 'P,U');
} else {
if ($(e.originalEvent.target).is(':checked')) {
// This value has just been selected
var newval = $(e.originalEvent.target).val();
} else {
// This value has just been unselected
var oldval = $(e.originalEvent.target).val();    
}
}
}
*/
(function($) {
    $.widget('ui.checkBoxListEx', {
        widgetEventPrefix: 'cbl',

        // Default options of this widget.
        options: {
            widthItem: '15em'       // Width of each item in the list. Used when filling from AJAX
        },

        _create: function() {
            // Constructor
            this._refresh();
        },

        // Binds click handlers to checkboxes within list.
        _refresh: function() {
            var widget = this;
            $('input:checkbox', this.element).click(function(e) {
                //widget.element.triggerHandler('itemclick');       // raise custom click
                widget._trigger('itemclick', e);
            });
        },

        // Pass an array of values to enable. Remaining values will be disabled and unchecked.
        enableValues: function(values) {
            var widget = this;
            $(':checkbox', this.element).each(function(i) {
                if ($.inArray($(this).val(), values) >= 0) {
                    $(this).removeAttr('disabled');
                } else {
                    $(this).attr('disabled', 'true').removeAttr('checked');
                }
            });
        },

        // Pass a comma seperated list of values to select.
        // We do not raise the itemclick event to avoid the possibility of recursion.
        select: function(values) {
            values = values.split(',');
            $('input:checkbox', this.element).each(function(i) {
                if ($.inArray($(this).val(), values) >= 0) {
                    $(this).attr('checked', 'checked');
                } else {
                    $(this).removeAttr('checked');
                }
            });
        },

        // Returns array of all selected values. Equivalent to server side SelectedValues
        values: function() {
            var widget = this;
            var values = [];
            $('input:checkbox:checked', this.element).each(function(i) {
                values.push($(this).val());
            });
            return values;
        }

        // data is an array of DropDownItem. Removes all checkboxes which currently exist and
        // creates new ones based on data. Called when checkbox list has a cascade parent.
//        load: function(data) {
//            var curval = this.values();
//            this.element.empty();
//            if (data == null || data.length == 0) {
//                // If no available choices, say so
//                //this.element.append($('<option></option>').val('').html('(None available)'));
//            } else {
//                for (var i = 0; i < data.length; ++i) {
//                    var id = this.element[0].id + '_' + i;
//                    var cb = $('<span><input type=\'checkbox\' value=\'' +
//                        data[i].Value + '\' id=\'' + id + '\' /><label for=\'' + id + '\' style=\'width:20em;\'>' +
//                        data[i].Text + '</label></span>');
//                    this.element.append(cb);
//                }
//            }
//            this._refresh();
//            // Must fire the change event to let everyone know that our contents have changed
//            this.element.removeClass('ui-state-disabled');
//            this._trigger('itemclick', null);
//        }
    });

})(jQuery);

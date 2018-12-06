// Fires the change event when radio selection changes. The change event can be cancelled by returning false
(function ($) {
    $.widget('ui.radioButtonListEx', {
        // Default options of this widget. Options beginning with _ are private
        options: {
            groupName: ''     // The name attribute of each radio in the group
        },
        _create: function () {
            // Constructor
            var widget = this;
            widget._allButtons = $('input:radio[name=' + widget.options.groupName + ']', widget.element.closest('form'));
            // For radio buttons which are not directly inside the widget element,
            // Raise the change event handler of the widget element
            widget._allButtons.not(widget.element.children('input:radio')).change(function (e) {
                widget.element.triggerHandler('change');
            });
        },

        // A cached Jquery selector representing all buttons
        _allButtons: null,

//        setValue: function (value) {
//            alert('setValue superseded by radioButtonListEx("val")');
//            var $curChecked = this._allButtons.filter(':checked');
//            if ($curChecked.val() != value) {
//                this._allButtons.filter('[value=' + value + ']').attr('checked', 'checked');
//                this.element.change();
//            }
//        },


//        getValue: function () {
//            alert('getValue superseded by radioButtonListEx("val")');
//            return this._allButtons.filter(':checked').val();
//        },

        // If no value is passed, returns the currently selected value.
        // If string value is passed, sets the value to value.
        val: function (value) {
            if (value === undefined) {
                return this._allButtons.filter(':checked').val();
            } else {
                var $curChecked = this._allButtons.filter(':checked');
                if (value != this.val()) {
                    this._allButtons.filter('[value=' + value + ']').attr('checked', 'checked');
                    this.element.change();
                }
            }
        },

        // If i is not passed, returns the index of the currently selected button
        // If i is passed, selects the button at the passed index.
        // If i is negative, or greater than the index of the last button, this function does nothing.
        // Thus selecting the button after last is equivalent to selecting the first button.
        // Ignores invisible buttons while setting or getting index.
        index: function (i) {
            var $visibleButtons = this._allButtons.filter(':visible');
            if (i === undefined) {
                return $visibleButtons.index($visibleButtons.filter(':checked'));
            } else {
                if (i < $visibleButtons.length && i != this.index()) {
                    $visibleButtons.eq(i).attr('checked', 'checked');
                    if (this.element.has($visibleButtons[i]).length == 0) {
                        // Raise the change event only if the button is not within the radio button list.
                        // When the button is within the list, change event bubbles automatically.
                        this.element.change();
                    }
                }
            }
        }
    });
})(jQuery);

/*
Usage: $('#tb').textBoxEx(...).ajaxDialog(options);

The behavior you describe is the way IE works, i.e. onChange does not fire when AutoComplete is used to change the value.
Its unfortunate, because its obviously wrong.

In my Professional Validation And More product, I added a bunch of javascript to my textboxes to avoid this.
The general idea:
- Capture the original text on focus
- If onchange fires, abandon the captured text
- If onblur fires and the captured text is still around, compare it to the current value of the textbox.
If there is a difference, fire the onchange event.

21 Nov 2009: Setting tabindex = -1 for datepicker button

29 Jan 2010: Added watermark feature. Water mark added when textbox is initialized and whenever it loses focus.
Watermark removed whenever text box receives focus and when the form is submitted.

When watermark is being used, you cannot use the jQuery val() function to get or set the value since
the water mark text will appear to be the value. Therefore, you should use .textBoxEx('getval')
to get the value and .textBoxEx('setval', 'newval') to set the value.
*/
(function ($) {
    $.widget('ui.textBoxEx', {
        options: {
            fromSelector: null,  // Selector which selects the from date
            pickerOptions: null,     // Options to pass to date picker
            maxDateRange: null      // Used only for to dates
        },
        _create: function () {
            var oldText = null;
            var widget = this;
            widget._originalName = this.element.attr('name');
            if (!this.element.attr('readonly')) {
                $(this.element).focus(function (e) {
                    $(this).addClass('ui-selecting');
                    oldText = $(this).val();
                }).change(function (e) {
                    oldText = null;
                }).blur(function (e) {
                    $(this).removeClass('ui-selecting');
                    if (oldText != null && oldText != $(this).val()) {
                        $(this).change();
                    }
                });
            }
            if (this.options.pickerOptions) {
                if (this.options.fromSelector) {
                    this._fromElement = $(this.options.fromSelector);
                    var widget = this;
                    // Setting the beforeShow option later interferes with watermark functionality
                    $.extend(this.options.pickerOptions, { beforeShow: function (input, picker) {
                        return widget._beforeShow(input, picker);
                    }
                    });
                }
                this.element.datepicker(this.options.pickerOptions)
                    .nextAll('button.ui-datepicker-trigger:first')
                    .attr('tabindex', '-1')
                    .button({ icons: { primary: 'ui-icon-calendar' }, text: false, disabled: this.options.disabled });

            }
        },

        _originalName: null,

        getval: function () {
            return this.element.val();
        },

        setval: function (value) {
            this.element.val(value);
        },

        // If data is an array of values of cascade parent. Last value is loaded
        loadParentValues: function (data) {
            var countItems = (data == null ? 0 : data.length);
            if (countItems == 0) {
                this.element.val('');
            } else {
                this.element.val(data[countItems - 1].toString());
            }
            this.element.triggerHandler('change');
        },

        // Cached JQuery of from element
        _fromElement: null,

        // Called when the date picker is attached to a to date control
        // Sets min based on from date. Sets max based on date range. Never violates original min and max
        _beforeShow: function (input, picker) {
            var options = {};
            // Find out the date entered in the to box. Assume that the to box is the next input control
            var fromDate = this._fromElement.datepicker('getDate');
            // Find out the number of days that we are allowed to enter max.
            if (fromDate == null) {
                // Honor the minimum set for this control
                options = $.extend(options, { minDate: this.options.pickerOptions.minDate });
                //return { minDate: this.options.pickerOptions.minDays };
            } else {
                // From date has been entered. See whether it should serve as the minimum.
                var ONE_DAY = 86400000;    // Number of milliseconds in one day
                var today = new Date();
                if (this.options.pickerOptions.minDate == null) {
                    // Min days not specified so this becomes the min
                    options = $.extend(options, { minDate: fromDate });
                    //return { minDate: fromDate };
                } else {
                    // Min days has been specified. Compute the max of the two.
                    var origMinDate = new Date(today.getTime() + parseInt(this.options.pickerOptions.minDate * ONE_DAY));
                    options = $.extend(options, { minDate: origMinDate > fromDate ? origMinDate : fromDate });
                    //return { minDate: origMinDate > fromDate ? origMinDate : fromDate };
                }
                // Calculate max range constraint
                if (this.options.maxDateRange) {
                    var maxRangeDate = new Date(fromDate.getTime() + (this.options.maxDateRange * ONE_DAY));
                    var origMaxDate = new Date(today.getTime() + (this.options.pickerOptions.maxDate * ONE_DAY));
                    options = $.extend(options, { maxDate: origMaxDate < maxRangeDate ? origMaxDate : maxRangeDate });
                }
            }
            return options;
        }

    });
})(jQuery);
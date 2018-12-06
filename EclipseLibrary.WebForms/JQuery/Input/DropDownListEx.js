
(function ($) {
    $.widget('ui.dropDownListEx', {
        // Default options of this widget. Options beginning with _ are private
        options: {
            // Items which will be added to the beginnng of the list before items from the web method are added
            // e.g. [ {Text='(Please Select)', Value=''}, Persitent='WhenEmpty' ]
            persistentItems: [],
            clientPopulate: false, // true means that the web method will be called on first click
            cookieExpiryDays: 7,         // Used if we are asked to set the cookie
            cookieName: null                // Used by setCookie
        },
        _create: function () {
            this.element.change(function (e) {
                // Populate hidden field
                $(this).nextAll(':input:first').val($('option[value="' + $(this).val() + '"]', this).text());
            });
            if (this.options.clientPopulate) {
                this.element.one('click.dropDownListEx', function (e) {
                    $(this).cascade('callWebMethod');
                });
            }
        },

        // Save the current value so that we can reselect it after loading
        preFill: function () {
            var curVal = this.element.val();
            this.element.empty()
                .append($('<option></option>').val(curVal).html('Loading...'))
                .addClass('ui-state-disabled');
        },

        // Data is an array of drop down items to be used for filling the combo
        // data will be null in case of an ajax error
        // TODO: Support optgroup element
        fill: function (data) {
            // Make an attempt to keep the current value selected
            var curval = this.element.val();
            this.element.empty();
            var widget = this;
            if (data && data.length > 0) {
                // Some items found. Add only AlwaysVisible persistent items
                $.each(this.options.persistentItems, function (i) {
                    if (this.Persistent == 'Always') {
                        widget.element.append($('<option></option>').val(this.Value).html(this.Text));
                    }
                });
                for (var i = 0; i < data.length; ++i) {
                    var newOption = $('<option></option>').val(data[i].Value).html(data[i].Text);
                    if (data[i].Value == curval) {
                        newOption.attr('selected', 'true');
                    }
                    this.element.append(newOption);
                }
            } else {
                // No items found. Add all persistent items
                $.each(this.options.persistentItems, function (i) {
                    widget.element.append($('<option></option>').val(this.Value).html(this.Text));
                });
            }
            this.element.removeClass('ui-state-disabled');
            // Must fire the change event to let everyone know that our contents have changed
            if (curval != this.element.val()) {
                this.element.change();
            }
            // Don't attempt to fill when control is clicked
            this.element.unbind('click.dropDownListEx');
        },

        // Called when UseCookie is true. Sets the value of the cookie. The cookie is read on server side by SetValueFromCookie
        setCookie: function () {
            var data = { Text: $('option:selected', this.element).text(), Value: this.element.val() };
            createCookie(this.options.cookieName, escape(JSON.stringify(data)), this.options.cookieExpiryDays)
        }
    });
})(jQuery);

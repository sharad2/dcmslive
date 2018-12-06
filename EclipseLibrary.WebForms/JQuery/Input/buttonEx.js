/*
buttonEx class
*/
(function ($) {
    // Global variables
    $.buttonEx = {
        // JQuery. Button ex sets this global before valdiating elements. showErrors option set by JQueryScriptManager
        // displays errors within this validation summary
        validationSummary: null
    };

    // If causesValidation is true, validates all controls within the closest validation container
    // Hidden fields are not validated. Only controls within the same form as the button are validated.
    $.widget('ui.buttonEx', $.ui.button, {
        // Default options of this widget. Options beginning with _ are private
        options: {
            causesValidation: false,     // Whether validation should be performed
            click: null,           // function to call on click. If causesValidation is true, called only if validation passes
            disableAfterClick: false    // Whether button should be disabled after it is successfully clicked
        },

        _create: function () {
            var widget = this;
            // On click handler will be called only if validation succeeds
            widget.element.click(function (e) {
                var b = true;
                if (widget.options.causesValidation) {
                    b = widget.validate();
                }
                if (b && widget.options.click) {
                    b = widget.options.click.call(this, e);
                }
                if (b && widget.options.disableAfterClick) {
                    $(this).buttonEx('option', 'icons', { primary: 'ui-icon-clock' });
                    // Use timeout to allow other actions, such as form submission, to complete
                    setTimeout(function () {
                        widget.element.buttonEx('disable');
                    }, 0);
                }
                return b;
            });
            // Call base class
            $.ui.button.prototype._create.apply(this, arguments);
        },

        // Use this function to programmatically cause the validation on the client side
        // returns true if validation succeeds. Inputs which are within the same validation container as the button
        // are valdiated. Inputs in nested validation containers are excluded.
        // The validation summary must be within the same validation container as the button or it must be in one of the
        // enclosing validation containers. The form is considered to be the outermost valiadtion container.
        validate: function () {
            var $form = this.element.closest('form');
            var validator = $form.validate();
            var $containerElement = this.element.closest('.val-container,form');
            // Inputs within container elements which have a rule defined. Also, the element must be directly within the
            // button's validation container
            var $inputs = $('input,select', $containerElement)
                .not(validator.settings.ignore)
                .not('[disabled]')
                .filter(function (i) {
                    return validator.settings.rules[$(this).attr('name')] !== undefined &&
                        $(this).closest('.val-container,form')[0] == $containerElement[0];
                });
            // All parent validation containers of the button's validation container.
            // Top most parent is first in the list.
            var $parents = $containerElement.parents('.val-container,form').andSelf();
            var best = -1;
            $('ol.val-summary').addClass('ui-helper-hidden').empty().each(function (i) {
                var index = $parents.index($(this).closest('.val-container,form'));
                if (index > best) {
                    // This validation summary is so far closest to the button's container
                    $.buttonEx.validationSummary = $(this);
                }
            });
            if (!$.buttonEx.validationSummary) {
                alert('Internal error: Validation summary not found');
                return false;   // Assume validation has failed
            }
            var bValid = true;
            var namecache = [];   // Validate only one element per name. Important for radio buttons.
            $inputs.each(function (i) {
                if ($.inArray($(this).attr('name'), namecache) < 0) {
                    var b = validator.element(this);
                    if (b !== undefined && !b) {
                        bValid = false;
                    }
                    namecache.push($(this).attr('name'));
                }
            });
            return bValid;
        }
    });

})(jQuery);


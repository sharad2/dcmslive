(function ($) {
    // Static variable which keeps track of the number of autocomplete widgets created.
    //var __count = 0;
    $.widget("ui.autocompleteEx", $.ui.autocomplete, {

        widgetEventPrefix: 'autocomplete',

        options: {
            webServicePath: null,
            webMethodName: null,        // required
            delay: 4000,
            focus: function (event, ui) {
                // Do not change the value in the text box
                return false;
            },
            // The text for which a valid id has been saved. When the value in tb does not match this,
            // we clear the stored id
            _validText: '',

            // Set these in the search event to pass custom parameters to your web method
            // They are cleared after the ajax call is initiated.
            parameters: null,

            // If true, then the value entered is validated when focus lost. Invalid values are cleared.
            autoValidate: false,

            // Web method to invoke to validate the entered text. Defaults to webMethodName
            validateWebMethodName: null
        },

        _relevanceGood: -1000000,        // some huge negative number

        // Fires the ajax query to retrieve the list
        _fire: function (request, response) {
            var self = this;
            $.ajax({
                type: 'POST',
                url: (this.options.webServicePath || window.location.pathname) + '/' + this.options.webMethodName,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(this.options.parameters || { term: request.term }),
                //dataType: 'json',  -- jquery 1.5 does not like us to specify the data type
                success: function (data, textStatus) {
                    var items;
                    var relevancePerfect = -1000000;     // some huge negative number
                    self._relevanceGood = -1000000;
                    if (!data || !data.d) {
                        items = null;
                    } else if ($.isArray(data.d)) {
                        items = data.d;
                    } else if (data.d.RelevancePerfect || data.d.RelevanceGood) {
                        items = data.d.Items;
                        if (items && items.length > 1) {
                            // Relevance is relevant only if we have multiple items
                            if (typeof data.d.RelevancePerfect === "number") {
                                relevancePerfect = data.d.RelevancePerfect;
                            }
                            if (typeof data.d.RelevanceGood === "number" && items[0].Relevance <= data.d.RelevanceGood) {
                                // Only the best choices should be highlighted
                                self._relevanceGood = items[0].Relevance;
                            }
                        }
                    } else {
                        // Unexpected return object
                        items = null;
                    }
                    if (items == null || items.length == 0) {
                        // No match
                        response([{ Text: 'No Match', Value: ''}]);
                    } else if (items.length == 1) {
                        // If there is only a single match, auto select it regardless of relevance
                        //self.select(items[0].Value, items[0].Text);
                        response(items);
                        // trigger the select handler so that the item gets selected
                        self._trigger('select', null, { item: items[0] });
                    } else if (items[0].Relevance <= relevancePerfect) {
                        // Auto select the first perfectly relevant item but still show the menu
                        self.select(items[0].Value, items[0].Text);
                        response(items);
                    } else {
                        response(items);
                    }
                },
                error: function (xhr, status, e) {
                    response([{ Text: xhr.responseText, value: ''}]);
                }
            });
            this.options.parameters = null;
        },

        _create: function () {
            var self = this;
            this.options.source = function (request, response) {
                self._fire(request, response);
            };

            // Call base class
            $.ui.autocomplete.prototype._create.apply(this, arguments);

            this.element.dblclick(function (e) {
                // Double clicking will unconditionally open the drop down
                var oldMinLength = self.options.minLength;
                self.options.minLength = 0;
                self.search();
                self.options.minLength = oldMinLength;
            }).keyup(function (e) {
                // If value in text box changes, mark it as invalid
                if ($(this).is('.ac-valid') && self.options._validText != $(this).val()) {
                    self.clearItem();
                }
            });

            this.options.autoValidate && this.element.change(function (e) {
                if (!self._noAutoValidate) {
                    self.validate(function (item) {
                        item || self.element.addClass('ui-state-error').effect('pulsate', {}, 500, function () {
                            self.element.removeClass('ui-state-error').val('');
                        });
                    });
                }
            });
        },

        // While autocomplete menu is open, autovalidation should not happen
        _noAutoValidate: false,

        /* Special handle the select event. */
        _trigger: function (type, event, ui) {
            var b = $.ui.autocomplete.prototype._trigger.apply(this, arguments);
            switch (type) {
                case 'select':
                    if (b) {
                        // developer did not cancel the selection
                        this.select(ui.item.Value, ui.item.Text);
                        b = false;
                    }
                    break;

                case 'open':
                    this._noAutoValidate = true;
                    break;

                case 'close':
                    this._noAutoValidate = false;
                    break;
            }
            return b;
        },

        // Display the text property instead of the label property
        // Items with the most negative relevance are displayed in bold. It is assumed that items are sorted 
        // ascending by relevance.
        _renderItem: function (ul, item) {
            var menuText = item.Text;
            if (item.Detail) {
                menuText += ' <em>(' + item.Detail + ')</em>';
            }
            var $li = $("<li></li>")
			    .data("item.autocomplete", item)
			    .append("<a>" + menuText + "</a>")
			    .appendTo(ul);
            if (!item.Value) {
                // Indicate that this is unselectable
                $li.addClass('ui-state-error');
            } else if (item.Relevance && item.Relevance == this._relevanceGood) {
                $li.addClass('ui-priority-primary');
            }
            return $li;
        },

        /****************** Public functions *********************/
        // Utility to select an item and underline it
        // Pass empty value to clear the item
        select: function (value, text) {
            if (value) {
                this.element.val(text)
                    .addClass('ac-valid')
                    .attr('title', text)
                    .prev('input').val(value);
                this.options._validText = text;
            } else {
                this.clearItem();
            }
        },

        // Clears the value in the control. The hidden field is cleared but the text box is not.
        // You should clear the textbox seperately using $(this).autocompleteEx('clearItem').val('');
        clearItem: function () {
            this.element.removeClass('ac-valid').removeAttr('title')
                        .prev('input').val('');
        },

        // Return the currently selected value. The currently selected text is retrieved from val().
        selectedValue: function () {
            var ret = this.element.prev('input').val();
            return ret;
        },

        // Synchronously calls the web method to validate the entry in the text box.
        // The entry is passed as the id parameter to the web method.
        // To pass custom parameters, set the parameters option before calling this method
        // It updates text and value in case of success. If validation fails, text box is cleared.
        // Example: var x = $(this).autocompleteEx('validate' callback);
        // A call back function can be passed which will be called only after successful validation.
        // function MyCallBack(item) {
        //   // this is the autocomplete element
        //   // item is the AutoCompleteItem returned by the web method or null if no matching item
        //}
        // This function is chainable
        validate: function (callback) {
            this.options.validateWebMethodName || alert('Autocomplete Error: validateWebMethodName is needed');
            if (this.element.is('.ac-valid')) {
                // Already valid or empty. do nothing
                return;
            }
            var ret = this.element.val();
            if (!ret) {
                // Textbox is empty. Validate the value. This scenario
                // occurs when value is set via quaery string on the server side and this function is called
                // from ready handler.
                ret = this.selectedValue();
            }
            // Now we have text but no value
            this.element.addClass("ui-autocomplete-loading");
            var self = this;
            $.ajax({
                async: false,
                timeout: 1000,   // Since the request is synchronous, do not wait for more than a second
                type: 'POST',
                url: (this.options.webServicePath || window.location.pathname) + '/' + this.options.validateWebMethodName,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(this.options.parameters || { term: ret }),
                //dataType: 'json',  -- jquery 1.5 does not like us to specify the data type
                success: function (data, textStatus) {
                    if (data.d) {
                        if (!data.d.Value) {
                            alert('Autocomplete Error: Empty value returned for text *' + data.d.Text + '*');
                        }
                        self._trigger('select', null, { item: data.d });
                        ret = null;     // to indicate success
                    } else {
                        self.clearItem();
                    }
                    if (callback) {
                        callback.call(self.element[0], data.d);
                    }
                },
                error: function (xhr, status, e) {
                    // AJAX error
                    alert(xhr.responseText);
                },
                complete: function (XMLHttpRequest, textStatus) {
                    self.element.removeClass("ui-autocomplete-loading");
                }
            });
            this.options.parameters = null;
            //return ret;
        }
    })
})(jQuery);
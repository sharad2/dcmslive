/// <reference path="~/Doc/jquery-1.3.2-vsdoc.js" />
/*
Usage: $('#mydlg').dialog(...).ajaxDialog(options);

Sharad 15 Sep 2009: After loading, setting focus to first tabbable element.
<div>
<div>
... remote contents ...
</div>
<div>
... content template ...
</div>
</div>

22 Oct 2009: Only a single dialog will be open at any time.
Cancelling long running ajax calls when dialog closes.
Preventing submit if ajax call is in progress.

19 Nov 2009: loaded event raised even when cache is true and loading event has not been raised.

11 Dec 2009: Explicitly calling the dialong open handler if autoOpen is true

All events receive just the event object. There is no ui object. During the event you can access the
remote container: var $remote = $(this).ajaxDialog('remoteContainer');
ui.remote: JQuery object representing the div containing the remote contents
ui.content: JQuery object representing the div containing the content template
*/
(function(jQuery) {
    // We keep track of the currently open dialog here.
    // When another dialog is opened, we close this one. Thus only a single dialog will show at any time.
    var _currentlyOpenDialog = null;

    $.widget('ui.ajaxDialog', {

        // Default options of this widget. Options beginning with _ are private
        options: {
            // Dialog options
            _defButtonText: '',     // Text of the default button. It is displayed highleighted and is pressed when user presses enter
            _enablePostBack: false,     // Whether the dialog should be allowed to postback to the same page
            // Ajax options
            url: null,      // the remote url to invoke
            cache: false,       // Whether to avoid the load if content has already been loaded
            alreadyLoaded: false,
            _useDialog: true,    // Used internally to remember whether dialog is being used
            loaded: null,        // Function to call after the remote contents have been successfully loaded
            // When a submit button on the remote form is clicked, we temporarily store its name and value here so that
            // it can be posted as form data. e.g. 'btnCreate=value'
            _clickedSubmitButton: null,
            data: {},        // Data to pass along with query string
            submitting: null,   // this event is raised just before the form is submitted. Good time to update query string.
            // return false to prevent the submit
            loading: null,   // event is raised just before the remote contents are loaded. Return false to cancel load                    
            autoOpen: true,
            autoClose: true  // If true, close the currently open dialog when this dialog opens
        },

        widgetEventPrefix: 'ajaxdialog',

        _create: function() {
            // Perform widget initialization here.
            var widget = this;
            // If cache is false, we do not need the remote contents after the dialog closes
            if (widget.options._useDialog) {
                widget.element.dialog(widget.options)
                    .bind('dialogopen', function(event, ui) {
                        widget._onDialogOpen();
                    }).bind('dialogclose', function(event) {
                        if (widget.options.autoClose) {
                            _currentlyOpenDialog = null;
                        }
                        if (!widget.options.cache) {
                            // When the dialog closes, empty the remote contents.
                            // We expect to reload them when the dialog opens again. This prevents unnecessary events from firing
                            // even though the remote contents are no longer relevant.
                            widget.remoteContainer().empty();
                        }
                        // If an ajax call is still running, abort it when dialog closes
                        if (widget._ajaxCall != null) {
                            widget._ajaxCall.abort();
                            widget._ajaxCall = null;
                            widget.element.removeClass('ui-state-disabled');
                        }
                    });
                if (widget.options.autoOpen) {
                    // We have missed the open event. Call the event handler now
                    widget._onDialogOpen();
                }
            } else {
                if (widget.options.autoOpen) {
                    widget.load();
                }
            }
        },

        // Hook up default button handling
        _onDialogOpen: function() {
            var widget = this;
            if (widget.options.autoClose) {
                if (_currentlyOpenDialog) {
                    _currentlyOpenDialog.dialog('close');
                }
                _currentlyOpenDialog = widget.element;
            }
            var $defButton = widget.element.parent()
                .find('> .ui-dialog-buttonpane :button')
                .filter(function(index) {
                    return $(this).text() == widget.options._defButtonText;
                }).addClass('ui-priority-primary');
            if ($defButton.length > 0) {
                widget.element.bind('keydown.EclipseDialog', function(e) {
                    if (e.keyCode && e.keyCode == $.ui.keyCode.ENTER && !$(e.target).is('textarea')) {
                        $defButton.click();
                    }
                }).bind('dialogclose', function(event, ui) {
                    widget.element.unbind('keydown.EclipseDialog');
                });
            }
            if (widget.options._enablePostBack) {
                widget.element.parent().appendTo($('form:first'));
                // SS 14 Dec 2009: After dialog is repositioned, we need to manage focus again
                setTimeout(function() {
                    widget.element.find(':tabbable:first').focus();
                }, 0);
            }
        },

        // A jquery object representing the div in which remote contents have been loaded
        remoteContainer: function() {
            return $('div:first', this.element);
        },

        // Loads ajax contents even if they have been already loaded. Useful when cache=true
        load: function() {
            if (this.options._useDialog) {
                $(this.element).dialog('open');
            }
            if (this.options.cache && this.options.alreadyLoaded) {
                // If caching requested and already loaded, do not load again but do trigger the loaded event
                this._trigger('loaded', null, { cached: true });
                return;
            }
            this.reload();
        },

        // Current ajax request which is in progress. Type XmlHttpRequest.
        _ajaxCall: null,

        // Usage:  $('#mydlg').ajaxDialog('load')
        // loads the remote form using the url and the data specified in options.
        reload: function() {
            var widget = this;
            if (!widget._trigger('loading', null, null)) {
                return;
            }
            if (!widget.options.url) {
                // No url, no load
                return;
            }
            var queryData = widget._queryStringData();
            // Make the ajax call
            if (widget.options._useDialog) {
                $(widget.element).dialog('open');
            }
            widget.remoteContainer().html('Loading...')
            $.ajax({
                cache: false,       // Always call the remote page. Do not ever cache its contents.
                data: queryData,    // Query string to pass
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    // Something bad happened. Display error within the div
                    widget.remoteContainer().html(XMLHttpRequest.responseText)
                },
                success: function(data, status) {
                    $('> div:last', widget.element).removeClass('ui-helper-hidden');
                    widget.options.alreadyLoaded = true;
                    widget._loadData(data);
                },
                complete: function(XMLHttpRequest, textStatus) {
                    widget._onAjaxComplete(XMLHttpRequest);
                },
                type: 'GET',
                url: this.options.url
            });
        },

        // The form has been successfully loaded. bind submit and click events so that we can
        // prevent the browser from submitting the form without our consent.
        _loadData: function(data) {
            var widget = this;
            widget.remoteContainer()
                .html(data)
                .find('form')
                .submit(function(e) {
                    widget.submit();
                    return false;   // Important. Prevent the browser from submitting it.
                }).find(':submit')
                .click(function(e) {
                    widget.options._clickedSubmitButton = $(this).attr('name') + '=' + $(this).val();
                    // TODO: should we forget this task when the form is actually submitted?
                    setTimeout(function() {
                        // If the button does not actually cause a submit, we want to forget about it
                        widget.options._clickedSubmitButton = null;
                    }, 0);
                });
            if (widget.options._useDialog) {
                $(':input:not(:button):focusable:first', widget.remoteContainer()).focus();
            }
            // loaded event is triggered after the remote contents have been loaded.
            // ui.remote is a jquery selector which refers to the div in which the remote contents
            // were loaded.
            var ui = { remote: widget.remoteContainer(), cached: false };
            widget._trigger('loaded', null, ui);
        },

        // Usage: $('#mydlg').ajaxDialog('submit', 'btnInsert').
        // You can pass the name of a button which will be posted to the form. This is useful for simulating button clicks.
        submit: function(btnSubmitName, btnSubmitValue) {
            var widget = this;
            if (widget._ajaxCall) {
                //alert('Please hold on');
                return;
            }
            //TODO: Pass a reasonable ui object
            if (!widget._trigger('submitting', null)) {
                return;
            }

            var submitButtonValue;
            if (btnSubmitName) {
                submitButtonValue = '&' + btnSubmitName + '=' + (btnSubmitValue ? btnSubmitValue : 'dummy');
            } else if (widget.options._clickedSubmitButton) {
                submitButtonValue = '&' + widget.options._clickedSubmitButton;
            } else {
                submitButtonValue = '';
            }
            widget.options._clickedSubmitButton = null;     // forget the value now. We don't need it.
            var qdata = $.param(widget._queryStringData());
            var url = widget.options.url;
            if (qdata) {
                if (url.indexOf('?') == -1) {
                    url += '?';
                } else {
                    url += '&';
                }
                url += qdata;
            }
            var $form = $('form:first', widget.remoteContainer());
            widget.element.addClass('ui-state-disabled');
            widget._ajaxCall = $.ajax({
                cache: false,
                dataType: "html",
                data: $form.serialize() + submitButtonValue, // The submit button if any is part of the data
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    // In case of error, show the yellow page within the dialog.
                    $form.html(XMLHttpRequest.responseText)
                },
                success: function(data, status) {
                    widget._loadData(data);
                },
                complete: function(XMLHttpRequest, textStatus) {
                    widget._onAjaxComplete(XMLHttpRequest);
                },
                type: 'POST',
                // Always pass the initial query string when posting. This mimics ASP.NET behavior
                url: url
            });
        },

        // Triggers the closing event if appropriate
        _onAjaxComplete: function(XMLHttpRequest) {
            this._ajaxCall = null;
            this.element.removeClass('ui-state-disabled');

            if (XMLHttpRequest.status == 205) {
                // Status code 205 means that we should close the form
                // Assume that response is serialized json. Deserialize it.
                // rverma 3 Nov 2011:if there is no responseText then we are passing null as a data.
                var obj;
                if (XMLHttpRequest.responseText) {
                    obj = JSON.parse(XMLHttpRequest.responseText);
                    ui = { data: obj };
                } else {
                    obj = null;
                }

                var ui = { data: obj };
                var b = this._trigger('closing', null, ui);

                if (b && this.options._useDialog) {
                    this.element.dialog('close');
                } else {
                    // Reload dialog
                    this.reload();
                }
            }
        },
        // Returns the query string which will be passed along with the AJAX call in object format,
        // e.g. {pickslip_id: 123, customer_id:'234'}
        _queryStringData: function() {
            var widget = this;
            var data = $.extend({}, widget.options.data);
            return data;
        }
    });
})(jQuery);
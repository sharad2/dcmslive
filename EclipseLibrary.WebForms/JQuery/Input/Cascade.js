/*
$('#ddlColor').cascade(options);

this refers to the dropdown which will be filled with the contents returned by the web method.
this can also refer to a text box. In this situation, the value in the textbox is updated with the
first value returned by the method.
    
Required options:
outermostContainer: The outermost container within which all searches will be scoped
cascadeParentSelector: The selector of the parent whose change we will monitor, e.g. '#ddlStyle'.
webServicePath: The path to the web service or page which contains the method to call
webMethodName: The name of the web method to call
Order is important. The topmost parent should be listed first.

9 Nov 2009: Supported radio button as cascade parent
16 Nov: If web method not specified, pass parent keys to load function
17 Nov 2009: If option initializeAtStartup is true, call web method on startup to refresh the element's value
*/
(function ($) {
    $.widget('ui.cascade', {

        widgetEventPrefix: 'cascade',

        // Default options of this widget. Options beginning with _ are private
        options: {
            // If this is null, then the drop down is populated once when it is first clicked by calling
            // the WebMethod without any arguments
            cascadeParentSelector: null,
            webServicePath: null,
            webMethodName: null,
            preLoadData: null,  // function to call before making the ajax call to retrieve data.
            loadData: null,  // function responsible for loading the data returned from AJAX call. this is the DOM element
            parentChangeEventName: 'change',  // The event which the parent raises when its value changes
            interestEvent: 'click',  // When there is no parent, ajax method is called when this event occurs
            parentValue: null,   // function. this refers to the parent whose value is sought
            initializeAtStartup: false,  // Whether the web method should be invoked when document loads
            hideParentsFromChildren: false  // Whether my ancestors are visible to my children
        },

        _create: function () {
            var widget = this;
            this.refresh();
            if (widget.options.initializeAtStartup) {
                // Invoke the web method on ducument load
                widget._pendingCall = setTimeout(function () {
                    widget.callWebMethod();
                    widget._pendingCall = null;
                }, 0);
            }
        },

        // Non null when a tak to callWebMethod is pending
        _pendingCall: null,

        // Does the actual work of hooking up event. You should call it from your script only if your 
        // cascade parent element is created after initialization.
        refresh: function () {
            var widget = this;
            if (widget.options.cascadeParentSelector) {
                // Bind to change event of cascade parent
                widget._cascadeParentCached = $(widget.options.cascadeParentSelector);
                widget._cascadeParentCached.bind(widget.options.parentChangeEventName, function (e) {
                    widget.callWebMethod();
                });
            }
        },

        // The worker method which actually fires the ajax call. The call is bypassed if any parent key is empty.
        // Public because AjaxDropDown calls it to fill the list on click
        callWebMethod: function () {
            var widget = this;
            if (widget._pendingCall) {
                clearTimeout(widget._pendingCall);
                widget._pendingCall = null;
            }

            var parentKeys = widget._ancestorValues();
            // If any parent key is empty, avoid the ajax call
            if ($.inArray('', parentKeys) >= 0) {
                // At least one parent key is empty. Do not call the method.
                widget._loadAjaxData(null);
                return;
            }

            if (widget.options.preLoadData) {
                widget.options.preLoadData.call(this.element[0]);
            }
            if (widget.options.webMethodName) {
                // Add the disabled class to visually indicate that we are retrieving data.
                // The class will be removed when the ajax call completes.
                widget.element.addClass('ui-state-disabled');
                $.ajax({
                    type: 'POST',
                    url: widget.options.webServicePath + '/' + widget.options.webMethodName,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ parentKeys: parentKeys }),
                    //dataType: 'json',
                    success: function (data, textstatus) {
                        widget._loadAjaxData(data.d);
                    },
                    error: function (xhr, status, e) {
                        alert('Cascade call failed. Info: ' + xhr.responseText);
                    },
                    complete: function (XMLHttpRequest, textStatus) {
                        widget.element.removeClass('ui-state-disabled');
                    }
                });
            } else {
                // No web method specified. Pass parent keys as data
                widget._loadAjaxData(parentKeys);
            }
        },

        // Caching the parent for performance reasons. null if we have no parent
        _cascadeParentCached: null,

        // Returns key value pair representing the cascade parent and its value.
        // Parent is null if cascadeParentSelector not specified.
        // Public because we internally call it for our cascade parents.
        cascadeParent: function (ignoreHideParents) {
            if (!ignoreHideParents && this.options.hideParentsFromChildren) {
                return null;
            } else {
                return {
                    parent: this._cascadeParentCached,
                    value: this.options.parentValue == null ? null : this.options.parentValue.call(this._cascadeParentCached)
                };
            }
        },

        // Returns the values of all cascade ancestors, including self. The topmost ancestor is first in the array
        _ancestorValues: function () {
            //var k = k.k;
            var parentKeys = [];
            var curAncestor = this.cascadeParent(true);
            // curAncestor.jquery is true for jquery objects. When the parent is not cascadable, we get back some
            // jquery object (in jquery 1.4.2). We break the loop in this case.
            while (curAncestor && curAncestor.parent) {
                parentKeys.push(curAncestor.value);
                if ($.data(curAncestor.parent[0], 'cascade')) {
                    curAncestor = curAncestor.parent.cascade('cascadeParent', false);
                } else {
                    // parent is not cascadable
                    curAncestor = null;
                }
            }
            return parentKeys.reverse();
        },

        // Called after ajax data has been retrieved from the web method. Loads this data in the associated element
        _loadAjaxData: function (data) {
            var $ctl = this.element;
            // loadData is responsible for firing the change event
            this.options.loadData.call(this.element[0], data);
        }

    });


})(jQuery);                                                                                                                                                                                                            // pass the jQuery object to this function

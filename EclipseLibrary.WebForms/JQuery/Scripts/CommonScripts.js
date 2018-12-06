/* SS 14 Jul 2010: Touch this file to forice rebuild of all scripts. */

/*
Utility function to create cookies
*/

function createCookie(name, value, days) {
    var expires;
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    }
    else {
        expires = "";
    }
    document.cookie = name + "=" + value + expires + "; path=/";
}


// Use this when you want to change the text within a container while keeping the old value visible.
// It Appends to the current text within the container.
// If the current text in the container is the same as passed text, it does nothing.
// Old Behavior: lbl -> <span>new value</span>
// $lbl.latestText('new value')
// New Behavior: current contents of td
// $td.latestText('new value') -> <span>new value</span>
// The whole container is pulsated to draw attention to it.
/*
latestText is used to update the value displayed within a container while preserving the previous value at the same time.
e.g. $('#mydiv').latestText('New Value');

How it works:
If mydiv does not contain any child elements as in <div>Value</div>, then the contents of the div are wrapped within
a span so that it now becomes <div><span>Value</span></div>.

Now the new value is inserted in the clone of the last element and the result becomes
<div><span>Value</span><span>New Value</span></div>

Finally, the container is pulsated to draw attention to it.

Special Cases:
If the container is a TD, we additionally enclose its contents in a div since pulsating a td is very ugly.
7 Dec 2009: If multiple elements are being updated, we avoid the pulsate effect because it takes too much time.
*/
(function ($) {
    $.fn.latestText = function (newValue) {
        if (newValue === undefined) {
            // Acts as getter
            var $span = $(':visible:last-child', this);
            if ($span.length == 0) {
                return $(this).text();
            } else {
                // Return the text of the last element
                return $span.eq($span.length - 1).text();
            }
        } else {
            var contElements = this.length;
            return this.each(function () {
                var $container;
                if (this.tagName == 'TD') {
                    // Wrap contents in a div for better pulsate effect
                    $container = $('> div', this);
                    if ($container.length == 0) {
                        $(this).wrapInner('<div></div>');
                        $container = $('> div', this);
                    }
                } else {
                    $container = $(this);
                }
                var $lastChild = $('> :visible:last-child', $container).removeClass('ui-state-highlight');
                if ($lastChild.length == 0) {
                    // Wrap contents in span
                    $container.wrapInner('<span></span>');
                    $lastChild = $('> :visible:last-child', $container);    // Now last child is span
                }
                if ($lastChild.length == 0) {
                    // Empty cell
                    $lastChild = $('<span></span>');
                }
                var addHtml = '<span class="ui-icon ui-icon-arrowthick-1-e" style="display:inline-block" >&nbsp;&nbsp;&nbsp;</span>';
                var $clone = $lastChild.clone().text(newValue).addClass('ui-state-highlight');
                $container.append(addHtml).append($clone);
                if (contElements == 1) {
                    $container.effect('pulsate');
                }
            });
        }
    }
})(jQuery);                                                                         // pass the jQuery object to this function

// This file contains methods which we developed at Eclipse

// http://www.dexign.net/post/2008/07/16/jQuery-To-Call-ASPNET-Page-Methods-and-Web-Services.aspx
// successFn(data, textStatus)
// errorFn(xhr, status, e)
// Example: CallPageMethod('GetCustomerDetails', {customer_id: '1234'}, function(data, textStatus) {
//   alert(data.d);
// });
/*
8 Dec 2009: Returns HttpRequest object which can be used to cancel the ajax call. The data returned by your web method
is passed to your success function as the first argument.
*/
function CallPageMethod(fn, data, successFn, errorFn) {
    var jsonData = JSON.stringify(data);

    var pagePath = window.location.pathname;
    //Call the page method
    return $.ajax({
        type: "POST",
        url: pagePath + "/" + fn,
        contentType: "application/json; charset=utf-8",
        data: jsonData,
        //dataType: "json",
        success: successFn,
        error: errorFn ? errorFn : function (xhr, status, e) {
            alert(xhr.responseText);
        }
    });
}



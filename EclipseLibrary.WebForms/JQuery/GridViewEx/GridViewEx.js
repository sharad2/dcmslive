/*

CSS classes interpreted by the gridViewEx widget.
gvex-sort-link. Apply to a link which is expected to sort the grid. The href of the link should be the sort expression.
gvex-edit-link. Apply to a link within a row which should put the grid in edit mode.
It is also applied to the row which is in edit or insert mode so that row
menu is not displayed for that row.
gvex-delete-link: Apply to a link within a row which should delete the row.
gvex-cancel-link. Apply to a link within a row which should cancel the editing of a row.
gvex-page-link. Apply to a link within the pages which should navigate to a specific page. href is the page#
gvex-masterrow. Apply to a tr element which functions as a master row. If ui-icon-folder-open icon is clicked within
this row, the child rows are collapsed and the icon is changed to ui-icon-folder-collapsed. The converse happens
when the collapsed icon is clicked.
Depends On: json2.js

2 Nov 2009: Popup menu is not displayed when multiple rows have been selected
5 Nov 2009: Selecting/unselecting checkbox in master row works.
18 Feb 2010: submitForm is now public because RowMenuPostBack calls it.
19 Jul 2010: Row menu now works with master detail
Added public function keyIndex.
*/
(function ($) {
    // options can contain any option supported by the selectable widget.
    // If the filter option is specified, the selectable widget is created.
    $.widget('ui.gridViewEx', {
        // Our prefix should be the same as the prefix of the selectable widget to ensure that we can fake
        // raising of selectable events.
        widgetEventPrefix: 'selectable',

        // Default options of this widget. Options beginning with _ are private
        options: {
            columnNames: null,      // Name by which each column can be referenced. String array
            form: 'form:first',          // The selector of the form to submit when sort link is clicked
            uniqueId: null,      // Server unique id of the grid
            _selections: null,    // The selector to a hidden field in which selected indexes should be stored when the grid is selectable
            // dataKeys are populated in _init by parsing the value of hidden field _dataKeysInputSelector
            dataKeys: [],          // json string representation of data key array [[key11, key12], [key21, key22], ...]
            menuItemActions: null,   // Array of functions to call when menu item clicked
            dataKeysCount: 0,        // Number of data keys specified for the grid
            _dataKeysInputSelector: null,  // selector of the input control in which data keys will be posted back. Optional.
            selectable: null        // Options to pass to the selectable widget.
        },

        _create: function () {
            var widget = this;
            if (widget.options._dataKeysInputSelector) {
                widget.options.dataKeys = JSON.parse($(widget.options._dataKeysInputSelector).val());
                //$(widget.options._dataKeysInputSelector).val(JSON.stringify(widget.options.dataKeys));
            }
            widget.element.click(function (e) {
                // Handle edit/cancel/page/expand/collapse etc clicks
                return widget._onClick(e);
            });
            if (widget.options.selectable) {
                // This is a selectable grid. Manage check boxes associted with the row.
                widget.element.selectable(widget.options.selectable);
            }

            // If hidden field for selections exists, update it whenever selections stop
            if (this.options._selections) {
                widget.element.bind('selectablestop', function (event, ui) {
                    // Update the hidden field after selections have been made
                    widget._updateClientState();
                });
            }
            if (widget.options.menuItemActions) {
                widget._rowMenu = $('#' + widget.element[0].id + '_menu');
                widget._hookRowMenu();
            }
        },
        /*************** Begin Row Menu code ********************/
        // The jquery object representing the menu. Set during init.
        _rowMenu: null,

        // DOM element representing the row in which the menu should be displayed
        // Set unset during mouse movement
        _curRow: null,

        // true when the user is in the process of selecting so that we can prevent display of row menu
        _selecting: false,

        // Non null when the menu has been queued up for display
        _showMenuTimer: null,

        // Called from _init only if the grid has row menu. Hooks up all the mouse events
        _hookRowMenu: function () {
            var widget = this;
            widget._rowMenu.click(function (e) {
                // Call the function associated with the clicked item
                $(this).addClass('ui-helper-hidden');
                var itemindex = $('div', this).index(e.target);
                // If no function has been specified for the item, do nothing
                if (itemindex != -1 && widget.options.menuItemActions[itemindex] != null) {
                    // Sharad 19 Jul 2010: Fixed bug when menu displayed within master-detail row
                    //var rowIndex = $('> tbody > tr', widget.element).index(widget._curRow);
                    var rowIndex = widget.rowIndex(widget._curRow);
                    var keys = widget.options.dataKeys[rowIndex];
                    // Introducing delay here to ensure that the menu gets hidden before
                    // a potentially long running function begins work.
                    widget._selecting = true; // Prevent row selections on hover
                    setTimeout(function () {
                        widget._selecting = false;
                        widget.options.menuItemActions[itemindex].apply(widget.element[0], [keys]);
                    }, 0);
                }
            }).find('div').hover(function (e) {
                $(this).addClass('ui-selected');
            }, function (e) {
                $(this).removeClass('ui-selected');
            });

            // If the grid is selectable, prevent interference with the
            // selection process by disabling hover during selection
            if (widget.options.selectable) {
                widget.element.bind('selectablestart', function (event, ui) {
                    widget._hideRowMenu();
                    widget._selecting = true;
                }).bind('selectablestop', function (event, ui) {
                    // If multiple selections have been made, we do not turn off the _selecting flag so that
                    // the display of popup menu is prevented.
                    widget._selecting = $('> tbody > tr.ui-selected', widget.element).length > 1;
                });
            }
            $('> tbody', widget.element).bind('mousemove', function (e) {
                if (widget._selecting) {
                    // Do nothing
                    return;
                }
                var $tr = $(e.target).closest('tr');
                // No row menu displayed for disabled rows
                if ($tr.length > 0 && $tr[0] != widget._curRow) {
                    widget._hideRowMenu();
                    // Sharad 19 Jul 2010: Row menu should not be displayed for master rows
                    //if ($tr.is(':not([disabled])') && !$tr.is('.gvex-edit-link')) {
                    if ($tr.is(':not([disabled], .gvex-masterrow, .gvex-subtotal-row, :has(th), .gvex-edit-link)')) {
                        widget._curRow = $tr[0];
                        // We want the menu to show only if the user sticks around at the row
                        widget._showMenuTimer = setTimeout(function () {
                            var offset = $(widget._curRow).position();
                            // Display menu to the left of the row. by subtracting menu width from left
                            widget._rowMenu.css('left', offset.left - widget._rowMenu.outerWidth())
                                            .css('top', offset.top)
                                            .removeClass('ui-helper-hidden');
                            $(widget._curRow).addClass('ui-selecting');
                        }, 500);
                    }
                }
            }).bind('mouseenter mouseleave', function (e) {
                if ($.inArray(e.relatedTarget, widget._rowMenu.find('*').andSelf()) != -1) {
                    // The user has moved on to the menu. Leave the row selected.
                } else {
                    widget._hideRowMenu();
                }
            }).keydown(function (e) {
                // Hide the menu on ESCAPE but do not change the current row.
                // This ensures that hovering on the current row will not display the menu again.
                if (e.keyCode == $.ui.keyCode.ESCAPE) {
                    widget._rowMenu.addClass('ui-helper-hidden');
                    if (widget._showMenuTimer != null) {
                        clearTimeout(widget._showMenuTimer);
                        widget._showMenuTimer = null;
                    }
                }
            }); ;
        },

        _hideRowMenu: function () {
            // Update current row book keeping
            if (this._showMenuTimer != null) {
                clearTimeout(this._showMenuTimer);
                this._showMenuTimer = null;
            }
            if (this._curRow != null) {
                $(this._curRow).removeClass('ui-selecting');
                this._curRow = null;
            }
            if (this._rowMenu) {
                this._rowMenu.addClass('ui-helper-hidden');
            }
        },
        /*************** End Row Menu code ********************/

        /**************** Begin row selection code ***************/
        // Store the selected indexes in the hidden field using JSON
        _updateClientState: function () {
            $(this.options._selections).val(JSON.stringify(this.selectedIndexes()));
        },
        /**************** End row selection code ***************/

        // Catches all sorts clicks to implement various features
        // If the clicked element has the class gvex-edit-link, the form is submitted for editing the row clicked
        // CommandFieldEx sets this class on the edit link
        _onClick: function (e) {
            var widget = this;
            widget._hideRowMenu();
            $tr = $(e.target).closest('tr');
            if ($(e.target).is('.gvex-sort-link')) {
                // Sort link clicked. Postback the form along with the sort expression
                $(e.target).html('Sorting...').closest('th')
                    .addClass('ui-state-disabled');
                widget.submitForm('Sort$' + $(e.target).attr('href'));
                return false;   // prevent hyperlink navigation
            } else if ($(e.target).is('.gvex-edit-link')) {
                // Edit link clicked. Postback the form along with the row index
                widget.submitForm('Edit$' + widget.rowIndex($tr));
                return false;
            } else if ($(e.target).is('.gvex-delete-link')) {
                // Delete link clicked. Postback the form along with the row index
                widget.submitForm('Delete$' + widget.rowIndex($tr));
                return false;
            } else if ($(e.target).is('.gvex-cancel-link')) {
                // Cancel link clicked. Postback the form along with the row index
                widget.submitForm('Cancel$' + widget.rowIndex($tr));
                return false;
            } else if ($(e.target).is('tr.gvex-masterrow > td span.ui-icon')) {
                // Icon in the master row clicked. Expand or collapse
                if ($(e.target).hasClass('ui-icon-folder-open')) {
                    // Collapsing
                    widget._collapseMasterRow(e.target);
                } else if ($(e.target).hasClass('ui-icon-folder-collapsed')) {
                    // Expanding
                    widget._expandMasterRow(e.target);
                } else {
                    // We must be displaying the clock icon. Do nothing.
                }
                return false;
            } else if ($(e.target).is('.gvex-page-link')) {
                widget.submitForm('PageSort$' + $(e.target).attr('href'));
                return false;
            } else if (widget.options.selectable && widget.options.selectable.cancel == '*' && $tr.is('.ui-selectee')) {
                // Implement single row selection
                widget.unselectRows(e, $('tr.ui-selected', widget.element));
                widget.selectRows(e, $tr);
                return true;
            } else {
                return true;
            }
        },

        // Selects the passed rows and raises all the necessary events
        // Public because it is called by SelectCheckBoxField.
        // The start and stop events are always raised. Selecting and selected events are raised only for
        // those rows which are not already selected.
        selectRows: function (e, $tr) {
            // raise selecting event
            var widget = this;
            widget._trigger('start', e);
            $tr.filter(function (i) {
                // Ignore already selected rows
                return !$(this).is('.ui-selected');
            }).each(function (i) {
                $(this).addClass('ui-selecting');
                widget._trigger('selecting', e, { selecting: this });
                if ($(this).hasClass('ui-selecting')) {
                    // Selection was not cancelled
                    $(this).addClass('ui-selected').removeClass('ui-selecting');
                    widget._trigger('selected', e, { selected: this });
                } else {
                    // Selection was cancelled
                }
            });
            widget._trigger('stop', e);
        },

        // unselects the passed rows. Public because it is called by SelectCheckBoxField.
        unselectRows: function (e, $tr) {
            var widget = this;
            widget._trigger('start', e);
            $tr.each(function (i) {
                $(this).addClass('ui-unselecting');
                widget._trigger('unselecting', e, { unselecting: this });
                if ($(this).hasClass('ui-unselecting')) {
                    $(this).removeClass('ui-unselecting ui-selected');
                    widget._trigger('unselected', e, { unselected: this });
                }
            });
            widget._trigger('stop', e);
        },

        /*
        A variation on the built in __doPostBack(). Takes formId as an additional parameter so that we know which
        form needs to be submitted. Used by the sorting and paging click handlers of GridViewEx.
        */
        submitForm: function (eventArgument) {
            var widget = this;
            var $form = $(widget.options.form);
            var $target = $('input:hidden[name=__EVENTTARGET]', $form);
            if ($target.length == 0) {
                // __EVENTTARGET may not always exist so we create it if necessary
                $form.append('<input type="hidden" name="__EVENTTARGET" value="' + widget.options.uniqueId + '" />');
            } else {
                $target.val(widget.options.uniqueId);
            }
            var $arg = $('input:hidden[name=__EVENTARGUMENT]', $form);
            if ($arg.length == 0) {
                $form.append('<input type="hidden" name="__EVENTARGUMENT" value="' + eventArgument + '" />');
            } else {
                $arg.val(eventArgument);
            }
            // trigger the submit events attached to this form. This gives a chance to our AJAX handler to
            // submit the form properly
            $form.submit();
        },

        /********* Begin Public functions to access rows/columns/cells ****************/

        // Returns an array of data key values. The first array is the values of the first data key and so on.
        // The length of the returned array is always equal to the number of data keys.
        // If there are no data keys, the length of the array would be 0
        // If there are no rows, the length of each inner array would be 0.
        // Example: DataKeyNames=customer_id,po_id. Suppose three rows are selected. The return value would be
        // [[c1,c2,c3] [p1,p2,p3]]
        selectedKeys: function () {
            var widget = this;
            var keyArray = [];
            // Create one empty array per key within array
            for (var i = 0; i < widget.options.dataKeysCount; ++i) {
                keyArray.push([]);
            }
            var rows = $('> tbody > tr', widget.element).each(function (i) {
                if ($(this).is('.ui-selected')) {
                    for (var j = 0; j < keyArray.length; ++j) {
                        // Push the j'th key in the j'th array within keyArray
                        keyArray[j].push(widget.options.dataKeys[i][j]);
                    }
                }
            });
            return keyArray;
        },

        // Returns an array of keys corresponding to the passed rows
        // Example: DataKeyNames=customer_id,po_id. Suppose three rows are passed. The return value would be
        // [[c1,c2,c3] [p1,p2,p3]]
        /* Code example:
        function(event, ui) {
        var x = $(this).gridViewEx('keys', $(ui.selected));
        alert(x[0][0]);
        }
        */
        keys: function (rows) {
            var widget = this;
            var keyArray = [];
            // Create one empty array per key within array
            for (var i = 0; i < widget.options.dataKeysCount; ++i) {
                keyArray.push([]);
            }
            $(rows).each(function (i) {
                var rowIndex = widget.rowIndex($(this));
                for (var j = 0; j < keyArray.length; ++j) {
                    // Push the j'th key in the j'th array within keyArray
                    keyArray[j].push(widget.options.dataKeys[rowIndex][j]);
                }
            });
            return keyArray;
        },

        // Returns a jquery object containing all tr elements which are currently selected
        // Example usage:
        // $('#gvPickSlip').gridViewEx('selectedRows').attr('disabled','true');
        selectedRows: function () {
            return $('> tbody > tr.ui-selected', this.element);
        },

        // Returns an array of selected indexes
        selectedIndexes: function () {
            var widget = this;
            var indexes = [];
            $('> tbody > tr:not(.gvex-masterrow, .gvex-subtotal-row, :has(th))', this.element).map(function (i) {
                if ($(this).is('.ui-selected')) {
                    indexes.push(i);
                }
            });
            return indexes;
        },

        // Pass a jquery object containing the tr element, or a DOM element representing tr.
        // Get back the index of the row
        rowIndex: function (tr) {
            return $('> tbody > tr', this.element).not('.gvex-masterrow, .gvex-subtotal-row, :has(th)').index(tr);
        },

        // returns a jquery object containing the td of the row in the footer
        // col can be a number representing a column index or it can be
        // col can be a string representing a column name
        // col can also be a jquery object representing a single td.
        // Example usage:
        // $('input', $grid.gridViewEx('footerCell', colIndex)).val(sum);
        footerCell: function (col) {
            var colIndex;
            if (typeof col === "number") {
                colIndex = col;
            } else {
                colIndex = this.colIndex(col);
            }
            return $('> tfoot > tr > td', this.element).eq(colIndex);
        },

        // Returns the cell in the header row. Does not work in the presence of multi row headers.
        headerCell: function (col) {
            var colIndex;
            if (typeof col === "number") {
                colIndex = col;
            } else {
                colIndex = this.colIndex(col);
            }
            return $('> thead > tr > th', this.element).eq(colIndex);
        },

        // returns a jquery object containing all td of the rows in the passed column
        // Pass column name as string, or column index as integer.
        // Example usage
        //  var $grid = $('form#frmSolidSize #gvSolidSize'); // Some code to find the grid.
        //  $('input:text', $grid.gridViewEx('columnCells', ['Pieces', 'Cartons'])).change(function(e) {
        //     alert('You have just hooked the change event to the columns Pieces and Cartons of grid');
        //                });
        // SS 26 Feb 2010: Optionally pass a jquery object containing the rows whose cells you are intrested in
        columnCells: function (col, rows) {
            var widget = this;
            var colIndexes = [];
            if (typeof col === "number") {
                colIndexes.push(col);
            } else if ($.isArray(col)) {
                // For now assume string array
                colIndexes = $.map(col, function (val, i) {
                    if (typeof val === "number") {
                        return val;
                    } else if (typeof val === "string") {
                        return widget.colIndex(val);
                    } else {
                        alert('gridViewEx error 1');
                        return null;
                    }
                });
            } else {
                colIndexes.push(widget.colIndex(col));
            }
            if (rows === undefined) {
                rows = $('> tbody > tr', widget.element);
            }
            return $('> td', rows).filter(function (i) {
                return $.inArray(i % widget.options.columnNames.length, colIndexes) != -1;
            });
        },

        // Returns a jquery object containing a single tr element corresponding to the passed keys
        // keys is an array of values to match, e.g. ['customer_id1']
        // Example usage:
        // var $row=$('#gvLocationAudit').gridViewEx('rows',keys);
        rows: function (keys) {
            // SS 3 Aug 2010: Handled master detail case
            var rowIndex = this.keyIndex(keys);
            return $('> tbody > tr:not(.gvex-masterrow, .gvex-subtotal-row, :has(th))', this.element).eq(rowIndex);

        },

        // Pass an array of key values, get back the index of the single row
        // which corresponds to these key values.
        // keys is an array of values to match, e.g. ['customer_id1']
        keyIndex: function (keys) {
            var widget = this;
            var rowIndex = -1;
            $.each(widget.options.dataKeys, function (i, val) {
                var isMatch = true;     // Presume a match
                for (var j = 0; j < keys.length; ++j) {
                    if (val[j] != keys[j]) {
                        isMatch = false;
                        break;
                    }
                }
                if (isMatch) {
                    // This is the row we are looking for
                    rowIndex = i;
                    return false;   // break the each loop
                }
                return true;    // continue loop
            });
            return rowIndex;
        },

        // Pass a string representing column name or a jquery object representing td
        // Returns integer. -1 if index not found
        // Example usage
        // var colIndex = $grid.gridViewEx('colIndex', $(this).closest('td'));
        colIndex: function (col) {
            if (typeof col === "string") {
                return $.inArray(col, this.options.columnNames);
            } else {
                // Assume col represents a jquery object representing td
                return col.closest('tr').find('> td').index(col);
            }
        },

        /********* End Public functions to access rows/columns/cells ****************/

        /************ Begin expand collapse functions ****************/
        // Utility function to expand the passed master row
        // Pass the icon whose image will also be set to expanded
        _expandMasterRow: function (icon) {
            var $icon = $(icon);
            $icon.removeClass('ui-icon-folder-collapsed')
                .addClass('ui-icon-clock');
            setTimeout(function () {
                $icon.closest('tr')
                    .nextAll('tr').show();
                $icon.removeClass('ui-icon-clock')
                    .addClass('ui-icon-folder-open');
            }, 0);
        },

        // Utility function to collapse the passed master row
        // Pass the icon whose image will also be set to collapsed
        // Sharad 1 Aug 2009: Do not collapse subheaders and subfooters
        _collapseMasterRow: function (icon) {
            $(icon).removeClass('ui-icon-folder-open')
                .addClass('ui-icon-clock');
            setTimeout(function () {
                $(icon).removeClass('ui-icon-clock')
                    .addClass('ui-icon-folder-collapsed')
                    .closest('tr')
                    .nextAll('tr')      // Sharad 7 Sep 2010: Hiding the header row as well
                    .hide();
            }, 0);
        },

        expandAll: function () {
            var widget = this;
            $(' > tbody > tr > td span.ui-icon-folder-collapsed;', widget.element).each(function () {
                widget._expandMasterRow(this);
            });
        },

        collapseAll: function () {
            var widget = this;
            $(' > tbody > tr > td span.ui-icon-folder-open', widget.element).each(function () {
                widget._collapseMasterRow(this);
            });
        }
        /************ End expand collapse functions ****************/
    });

})(jQuery);


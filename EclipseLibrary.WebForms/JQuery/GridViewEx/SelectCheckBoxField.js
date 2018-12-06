// Called when something is clicked in a grid containing a SelectCheckBoxField
function SelectCheckBoxField_GridClick(e) {
    var checked = $(e.target).is(':checked');
    var $grid = $(this);
    if ($(e.target).is('.gvex-header-checkbox')) {
        var $container = $(e.target).closest('tbody');
        if ($container.length == 0) {
            // This is the real header check box. Use all tbodies within the grid
            $container = $('> tbody', this);
        }
        // Check/uncheck all master row check boxes as well
        $('> tr > th > input.gvex-header-checkbox', $(this)).attr('checked', checked);
        $rows = $('> tr', $container).filter(function (i) {
            // return false if the riw does not have a check box. Insert and edit rows do not display check box.
            return $('input.gvex-row-checkbox', this).attr('checked', checked).length > 0;
        }).each(function (i) {
            if (checked) {
                // these rows will now get selected
                $grid.gridViewEx('selectRows', e, $(this));
            } else {
                // These rows will get unselected
                $grid.gridViewEx('unselectRows', e, $(this));
            }
        }); ;
        return true;
    } else if ($(e.target).is('.gvex-row-checkbox')) {
        var $tr = $(e.target).closest('tr.ui-selectee');
        if ($tr.length == 0) {
            // This row is not selectable. Ignore the click.
            return false;
        } else {
            if (checked) {
                $(this).gridViewEx('selectRows', e, $tr);
                return $tr.hasClass('ui-selected')
            } else {
                $(this).gridViewEx('unselectRows', e, $tr);
                return !$tr.hasClass('ui-selected')
            }
        }
    }
}
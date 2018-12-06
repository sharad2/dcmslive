(function($) {
    // Private functions
    // Toggle the direction of the icon
    // event.target is the icon which was clicked
    function OnIconClick(event) {
        if (!$(event.target).is('span.ui-icon')) {
            // Ignore the click
            return;
        }
        if ($(event.target).hasClass('ui-icon-triangle-1-n')) {
            $(event.target).removeClass('ui-icon-triangle-1-n').addClass('ui-icon-triangle-1-s').attr('title', 'Descending');
        } else {
            $(event.target).removeClass('ui-icon-triangle-1-s').addClass('ui-icon-triangle-1-n').attr('title', 'Ascending');
        }
        // change {0:I} to {0} and vice versa
        $li = $(event.target).closest('li');
        var sortExpr = $li.attr('sortexpr');
        sortExpr = sortExpr.replace('{0:I}', '{0:X}');
        sortExpr = sortExpr.replace('{0}', '{0:I}');
        sortExpr = sortExpr.replace('{0:X}', '{0}');
        $li.attr('sortexpr', sortExpr);
        UpdateSortExpression($li.closest('ul'));
    }

    // Updates the sort expression in the hidden field
    function UpdateSortExpression(sortable) {
        var sortExpr = ''
        var sortSequence = 0;
        $('li', sortable).each(function(i) {
            if (sortExpr != '') {
                sortExpr += ';';
            }
            if ($(this).attr('sortexpr') != '$') {
                ++sortSequence;
            }
            sortExpr += $(this).attr('sortexpr');
            $('sup', this).html(sortSequence);
        });
        $(sortable).closest('div.ecl-sortcolumnchooser')
            .find('input:checkbox')
            .attr('checked', 'true')
            .val(sortExpr);
    }
    
    $.widget('ui.sortColumnsChooser', {
        _init: function() {
            var widget = this;
            $columns = $('ul.ui-widget-content', widget.element);
            $columns.eq(0).sortable({
                connectWith: '#' + widget.element[0].id + '_2',
                containment: widget.element[0],
                items: '> li',
                cancel: 'span.ui-icon'
            }).disableSelection();
            $columns.eq(1).sortable(
                {
                    connectWith: '#' + widget.element[0].id + '_1',
                    placeholder: 'ui-state-highlight',
                    forcePlaceholderSize: true,
                    containment: widget.element[0],
                    items: '> li',
                    cancel: 'span.ui-icon'
                }).bind('sortstop sortreceive sortremove', function(event, ui) {
                    UpdateSortExpression(this);
                }).click(function(e) {
                    OnIconClick(e);
                }).disableSelection();
        }
    });

    $.extend($.ui.sortColumnsChooser, {
        // Default options of this widget. Options beginning with _ are private
        defaults: {}
    });
})(jQuery);




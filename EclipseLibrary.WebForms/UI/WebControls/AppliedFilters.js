/*
You can determine the filters visible to this Applied Filters
var filters = $('#ctlAPpliedFilters').appliedFilters('option', 'filters');
alert(filters.vwh_id);
*/
(function($) {
    $.widget('ui.appliedFilters', {
        options: {
            filters: {}  // key value pair representing all filters
        },

        _create: function() {
            // Constructor
        }
    });

})(jQuery);
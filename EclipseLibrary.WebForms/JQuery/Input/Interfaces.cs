
namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// If a control implements IFilterInputControl, FriendlyName is used instead of tool tip.
    /// Text property is used as the value.
    /// During rendering only filters with non empty display values are rendered.
    /// When constructing query string, all filters with non empty QueryStringValue are included.
    /// </summary>
    /// <remarks>
    /// Hemant 21 Aug: Disregarding disabled and invisible filters. Showing filters if they have either query string value or display value.
    /// Rendering invisible filters if they have query string value.
    /// </remarks>
    public interface IFilterInput
    {
        /// <summary>
        /// The friendly name to render. Used to generated validation error messages
        /// </summary>
        string FriendlyName { get; set; }

        /// <summary>
        /// Used to read initial value from query string
        /// </summary>
        string QueryString { get; }

        /// <summary>
        /// Think of this as the friendly name of the value. In most cases it is the same as the value.
        /// For drop down lists, this is the text which is visible to the user and is not necessarily the same as the
        /// associated value.
        /// </summary>
        string DisplayValue { get; }

        /// <summary>
        /// This is the value of the control. Importantly, it should reutrn an empty string if FilterDisabled is true.
        /// This is also the value which should be used as the parameter value in queries.
        /// </summary>
        string QueryStringValue { get; }

        /// <summary>
        /// If this is true, then the control is not treated as an active filter.
        /// Implementors of this interface must disable all their validators when FilterDisabled is set to true.
        /// </summary>
        bool FilterDisabled { get;  }
    }

}

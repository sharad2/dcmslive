using System.Web.UI.WebControls;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// This is implemented by DataControlField derived classes to indicate that they need custom cells.
    /// MatrixField is the first implementer of this interface. It uses it to render multiple cells
    /// within a single cell.
    /// </summary>
    /// <remarks>
    /// Sharad 3 Sep 2009: CreateCell() function now takes cell type as parameter. Added method RenderSubtotals().
    /// Sharad 5 Sep 2009: INeedsSummaries interface:
    ///   Changed return type of SummaryValues property from object[] to decimal?[].
    ///   Added new property SummaryValuesCount.
    ///   Added new value ValueAverage for enum SummaryCalculationType.
    /// Sharad 19 Dec 2009: Added interface IGridViewExRow
    /// </remarks>
    public interface IHasCustomCells
    {
        /// <summary>
        /// Create the custom cell 
        /// </summary>
        /// <returns></returns>
        DataControlFieldCell CreateCell(DataControlCellType cellType);

        void RenderSubtotals(GridViewRow parentRow, HtmlTextWriter writer, int firstRowIndex, int lastRowIndex);

        /// <summary>
        /// Return true to accept the row, false to reject it. If multiple fields are filtering rows, then they all must agree.
        /// </summary>
        /// <param name="dataItem"></param>
        /// <param name="peek">The data item which will be delivered next</param>
        /// <returns></returns>
        bool FilterRow(object dataItem, object peek);
    }

    /// <summary>
    /// If a field implements this interface, we can display a header tool tip
    /// </summary>
    public interface IHasHeaderToolTip
    {
        string HeaderToolTip { get; set; }
    }
}

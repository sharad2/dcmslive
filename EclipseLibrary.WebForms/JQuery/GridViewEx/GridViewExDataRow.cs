using System.Web.UI.WebControls;
using System.Linq;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// The RowIndex represents the index of the visible row. This helps the SequenceField display row sequence
    /// properly
    /// </summary>
    internal class GridViewExDataRow : GridViewRow
    {
        private readonly GridViewEx _gv;
        public GridViewExDataRow(GridViewEx gv, int rowIndex, int dataSourceIndex, DataControlRowType rowType, DataControlRowState rowState) :
            base(rowIndex, dataSourceIndex, rowType, rowState)
        {
            _gv = gv;
            // This ensures that controls within the row get unique ids
            this.ClientIDMode = System.Web.UI.ClientIDMode.Predictable;
        }

        protected GridViewEx Grid
        {
            get
            {
                return _gv;
            }
        }

        public override int RowIndex
        {
            get
            {
                return base.RowIndex - InvisibleRowCount;
            }
        }

        public int InvisibleRowCount { get; set; }

        /// <summary>
        /// If the user sets a CssClass for a row, base class ignores row style and alternating row style
        /// This code fixes this issue. TODO: Handle Edit and Selected cases as well
        /// </summary>
        public override string CssClass
        {
            get
            {
                return base.CssClass;
            }
            set
            {
                if ((this.RowState & DataControlRowState.Alternate) == DataControlRowState.Alternate)
                {
                    if (string.IsNullOrEmpty(_gv.AlternatingRowStyle.CssClass))
                    {
                        base.CssClass = value;
                    }
                    else
                    {
                        base.CssClass = _gv.AlternatingRowStyle.CssClass + " " + value;
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(_gv.RowStyle.CssClass))
                    {
                        base.CssClass = value;
                    }
                    else
                    {
                        base.CssClass = _gv.RowStyle.CssClass + " " + value;
                    }
                }
            }
        }

        public override void DataBind()
        {
            if ((this.RowState & DataControlRowState.Insert) == DataControlRowState.Insert)
            {
                // Do not go through the data binding process since the data item has nothing to bind
            }
            else
            {
                base.DataBind();
            }
        }
    }
}

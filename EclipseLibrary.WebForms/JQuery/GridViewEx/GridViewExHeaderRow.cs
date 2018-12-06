using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Displays two row header when necessary. Displays sort icons.
    /// </summary>
    /// <remarks>
    /// Sharad 3 Sep 2009: CreateCell() function now takes cell type as parameter
    /// </remarks>
    internal class GridViewExHeaderRow:GridViewRow
    {
        internal const int ROW_FIRST_LINE_HEADER = -1;
        internal const int ROW_SECOND_LINE_HEADER = -2;
        internal const int ROW_SINGLE_LINE_HEADER = -3;
        public GridViewExHeaderRow(int rowIndex, int dataSourceIndex, DataControlRowType rowType, DataControlRowState rowState):
            base(rowIndex, dataSourceIndex, rowType, rowState)
        {
            //_rowIndex = ROW_FIRST_LINE_HEADER;
            this.TableSection = TableRowSection.TableHeader;
        }

        private GridViewRow _newRow;

        private int _rowIndex = ROW_SINGLE_LINE_HEADER;

        public override int RowIndex
        {
            get
            {
                return _rowIndex;
            }
        }

        /// <summary>
        /// When we are exporting to excel, OnPreRender() is not called. In this case our <see cref="RowIndex"/>
        /// remains <c>ROW_SINGLE_LINE_HEADER</c>.
        /// Excel cannot tolerate multiple line headers.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            _rowIndex = ROW_FIRST_LINE_HEADER;
            base.OnPreRender(e);
            GridViewEx gv = (GridViewEx)this.NamingContainer;
            _newRow = FormatMultiRowHeader(gv);
            if (_newRow != null)
            {
                _newRow.CssClass = gv.HeaderStyle.CssClass;
            }
        }

        /// <summary>
        /// If client sorting is enabled, we generate the custom column attribute. The value of this attribute
        /// is the column index. It is generated only for those columns which should be sortable.
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            base.Render(writer);
            if (_newRow != null)
            {
                //_newRow.CssClass = "ui-widget-header";
                _newRow.Page = this.Page;
                _newRow.RenderControl(writer);
            }
        }

        private void SetCellToolTip(DataControlFieldCell cell)
        {
            if (cell.ContainingField is IHasHeaderToolTip)
            {
                IHasHeaderToolTip tip = (IHasHeaderToolTip)cell.ContainingField;
                cell.ToolTip = tip.HeaderToolTip;
            }
        }

        /// <summary>
        /// If multiple rows are necessary, the passed row becomes the current row becomes the first row.
        /// The new row is returned.
        /// </summary>
        /// <param name="gv"></param>
        /// <returns></returns>
        private GridViewRow FormatMultiRowHeader(GridViewEx gv)
        {
            // Start by assuming that we will need a new row
            // Set row index to -2 to indicate that this is the second header row.
            // GridViewMatrixCell looks at this to determine whether the first row or the second row of the header should
            // be rendered
            GridViewRow rowAdded = new GridViewRow(ROW_SECOND_LINE_HEADER,
                -1, DataControlRowType.Header, DataControlRowState.Normal);
            for (int i = 0; i < this.Cells.Count; ++i)
            {
                DataControlFieldCell cellOrig = (DataControlFieldCell)this.Cells[i];
                if (!cellOrig.ContainingField.Visible)
                {
                    // Ignore invisible columns
                    continue;
                }
                char[] seperator = new char[] { '|' };
                string[] tokens = cellOrig.ContainingField.HeaderText.Split(seperator, StringSplitOptions.RemoveEmptyEntries);
                //string[] expressions = gv.SortExpression.Split(';');
                //List<string> listSortExpressions = new List<string>(expressions);
                switch (tokens.Length)
                {
                    case 0:
                        // Empty header
                        cellOrig.RowSpan = 2;
                        break;

                    case 1:
                        // single line header
                        cellOrig.RowSpan = 2;
                        cellOrig.VerticalAlign = VerticalAlign.Middle;
                        cellOrig.Text = tokens[0];
                        break;

                    case 2:
                        // Tow header rows are in fact needed
                        cellOrig.Text = tokens[0];
                        DataControlFieldCell cellNew;
                        if (cellOrig.ContainingField is IHasCustomCells)
                        {
                            IHasCustomCells cancreate = cellOrig.ContainingField as IHasCustomCells;
                            cellNew = cancreate.CreateCell(DataControlCellType.Header);
                        }
                        else
                        {
                            cellNew = new GridViewExHeaderCell(gv, cellOrig.ContainingField);
                        }
                        cellNew.Text = tokens[1];
                        rowAdded.Cells.Add(cellNew);
                        break;

                    default:
                        throw new NotSupportedException("At most one pipe character is allowed in the header text");
                }
            }

            if (rowAdded.Cells.Count == 0)
            {
                // Revert all the rowspans back to default
                foreach (TableCell cell in this.Cells)
                {
                    cell.RowSpan = 0;
                }
                rowAdded = null;
            }
            else
            {
                SetColumnSpan();
            }
            return rowAdded;
        }

        private void SetColumnSpan()
        {
            TableCell visibleCell = null;
            foreach (DataControlFieldCell cell in this.Cells)
            {
                //set the column span 0 
                cell.ColumnSpan = 0;
                if (cell.ContainingField.Visible)
                {
                    if (visibleCell == null)
                    {
                        visibleCell = cell;
                        continue;
                    }
                }
                else
                {
                    // Ignore invisible cells
                    continue;
                }
                // SS 5 Feb 2010: If visbile cell has controls, it cannot span any cell
                if (!cell.HasControls() && !visibleCell.HasControls() && visibleCell.Text == cell.Text)
                {
                    if (visibleCell.ColumnSpan == 0)
                    {
                        visibleCell.ColumnSpan = 2;
                        visibleCell.HorizontalAlign = HorizontalAlign.Center;
                    }
                    else
                    {
                        ++visibleCell.ColumnSpan;
                    }
                    cell.Visible = false;
                }
                else
                {
                    visibleCell = cell;
                }
            }

        }
    }
}

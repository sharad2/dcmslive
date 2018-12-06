using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Created by GridViewEx only when master columns have been specified.
    /// By default it behaves just like a normal GridViewRow.
    /// It has the capabilty of displaying an additional master row above the normal row
    /// </summary>
    /// <remarks>
    /// When constructed, it hooks to the grid's row data bound event only if this is the first master row.
    /// RowDataBound is called for each row in the grid. During this event, we check whether the
    /// current row belongs to us. If it does, we increment our row count, etc.
    /// If it does not, then the set of our child rows is final. This new row is the new master.
    /// We unhook the row data bound event from ourselves and hook it to the new master row.
    /// 
    /// It uses jquery scripting to repeat the grid headers above the normal row.
    /// 
    /// Subtotals are not displayed if there is only one detail row. This is by design.
    /// 
    /// Sharad 4 Aug 2009: Expand All and Collapse All buttons are rendered in a table to accommodate IE7
    /// Sharad 4 Aug 2009: Fixed IE7 specific placement issue in master row entries
    /// Sharad 13 Aug 2009: Guaranteeing that the header columns will show up in the same order as defined in the 
    /// list of columns.
    /// Sharad 3 Sep 2009: Introduced class SubTotalInfo to facilitate subtotals of Matrix cells.
    /// Sharad 5 Sep: Added support for sub total averages
    /// Sharad 19 Dec 2009: Implemented interface IGridViewExRow
    /// Sharad 29 Dec 2009: Now it works even when view state is turned on.
    /// </remarks>
    /// <include file='GridViewExMasterRow.xml' path='GridViewExMasterRow[@name="class"]'/>
    internal class GridViewExMasterRow : GridViewExDataRow
    {
        #region Private fields
        /// <summary>
        /// Saved in view state
        /// </summary>
        [Serializable]
        private struct RowInfo
        {
            /// <summary>
            /// Index of the row within the master group. This is returned as our RowIndex. Thus
            /// SequenceField prints indexes which are within master.
            /// </summary>
            public int _indexWithinMaster;

            /// <summary>
            /// The index of this master row. Not relevant for detail rows.
            /// </summary>
            public int _masterRowIndex;

            /// <summary>
            /// The number of detail rows within the master row. Not relevant for detail rows.
            /// </summary>
            public int _countRowsInMaster;
        };

        private RowInfo _rowInfo;

        [Serializable]
        private struct SummaryData
        {
            public decimal?[] Values { get; set; }
            public int RowCount { get; set; }
        }

        [Serializable]
        private class SubtotalInfo
        {
            private readonly Dictionary<int, SummaryData> _dictSubtotals;
            private readonly int _firstRowIndex;

            public SubtotalInfo(int firstRowIndex)
            {
                _dictSubtotals = new Dictionary<int, SummaryData>();
                _firstRowIndex = firstRowIndex;
                this.LastRowIndex = _firstRowIndex;
            }
            public int FirstRowIndex
            {
                get
                {
                    return _firstRowIndex;
                }

            }
            public int LastRowIndex { get; set; }

            public Dictionary<int, SummaryData> Subtotals
            {
                get { return _dictSubtotals; }
            }

        }

        /// <summary>
        /// Saved in view state
        /// </summary>
        private SubtotalInfo _subtotalInfo;
        #endregion

        #region Base overrides
        public override int RowIndex
        {
            get
            {
                //GridViewEx gv = (GridViewEx)this.NamingContainer;
                //Return base row index if user doesn't wish to resequnce rows for each master.
                return (this.Grid.EnableMasterRowNewSequence) ?
                    _rowInfo._indexWithinMaster : base.RowIndex;
                //return index - this.InvisibleRowCount;
            }
        }
        #endregion

        #region Initialization and cleanup
        public GridViewExMasterRow(GridViewEx gv, int rowIndex, int dataItemIndex, DataControlRowState rowState)
            : base(gv, rowIndex, dataItemIndex, DataControlRowType.DataRow, rowState)
        {
            _rowInfo._countRowsInMaster = 1;
            if (rowIndex == 0)
            {
                // This is the first master row. Hook up to grid's events.
                gv.RowDataBound += new GridViewRowEventHandler(gv_RowDataBound);
                gv.DataBound += new EventHandler(gv_DataBound);
                // Start by assuming that we are the last detail row
                _lastDetailRow = this;
            }
        }

        /// <summary>
        /// Cleans up the markup comparer
        /// </summary>
        public override void Dispose()
        {
            if (_markupComparer != null)
            {
                _markupComparer.Dispose();
                _markupComparer = null;
            }
            base.Dispose();
        }
        #endregion

        #region Data Binding

        /// <summary>
        /// This comparer is created by the first master row during the RowDataBound event.
        /// Each master row passes it to the next in order to avoid repeated creations.
        /// It is disposed off by the last master row during DataBound event.
        /// </summary>
        private ControlMarkupComparer _markupComparer;

        /// <summary>
        /// The last detail row we have encountered for this master
        /// </summary>
        private GridViewExMasterRow _lastDetailRow;

        /// <summary>
        /// Make ourselves a master row. This event is only expected to be received by the last master row.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void gv_DataBound(object sender, EventArgs e)
        {
            GridViewEx gv = this.Grid;

            _lastDetailRow._subtotalInfo = _subtotalInfo;
            _subtotalInfo = null;

            if (_markupComparer != null)
            {
                _markupComparer.Dispose();
                _markupComparer = null;
            }
            // Tell sequence fields to not use page index while computing row sequence
            gv.Columns.Cast<DataControlField>()
                .OfType<SequenceField>().ToList().ForEach(p => p.UsePageIndex = false);
        }

        /// <summary>
        /// If a detail row belonging to the next master is encountered, finalize our master status by
        /// creating _dictMasterCells. Unhook all grid events and hook them to the new master.
        /// </summary>
        /// <remarks>
        /// The function checks mark up of rows, if markup is not same this states that master is not same for both hence renders 
        /// master row. Since this is a special row so we have to explicitly unhook to <see cref="GridViewEx" /> <c>RowDataBound</c> 
        /// and <c>DataBound</c> events, then calling <c>InitializeSubTotals</c> for initializing master columns and after this the 
        /// class again hooks to <c>GridViewEx</c> <c>RowDataBound</c> and <c>DataBound</c> events. If markups are same then the 
        /// function perfoms row counts and summasion for all the child columns.
        /// </remarks>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void gv_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (!e.Row.Visible)
            {
                // Ignore
                return;
            }
            GridViewEx gv = this.Grid;
            GridViewExMasterRow row = e.Row as GridViewExMasterRow;
            if (row == null)
            {
                // Do nothing. This must be a normal row
                return;
            }
            
            // Sharad 26 Feb 2010: Checking this.RowIndex instead of this.DataItemIndex to avoid special situation bug of 
            // subtotal and total
            // GL 11 June, 2010: Now checking row.DataItemIndex instead of row.RowIndex as this was resulting into
            // erronous sequencing in master-details reports when it was required to have new sequence for every master.
            if (row.DataItemIndex == this.RowIndex)
            {
                // First row of the master. Simply Initialize totals. We get here only for the very first master row.
                InitializeSubTotals(e.Row.DataItem, e.Row.RowIndex);
                return;
            }

            // e.Row is one of the detail rows or a new master row
            switch (e.Row.RowType)
            {
                case DataControlRowType.DataRow:
                    if (_markupComparer == null)
                    {
                        _markupComparer = new ControlMarkupComparer();
                    }
                    if (gv.MasterColumnIndexes.Any(p => !_markupComparer.MarkupSame(
                        this.Cells[p], e.Row.Cells[p])))
                    {
                        // First row of this master
                        gv.RowDataBound -= gv_RowDataBound;
                        gv.DataBound -= gv_DataBound;
                        row._rowInfo._masterRowIndex = _rowInfo._masterRowIndex + 1;
                        row._markupComparer = _markupComparer;
                        row._lastDetailRow = row;
                        row._rowInfo._indexWithinMaster = 0;
                        row.InitializeSubTotals(row.DataItem, row.DataItemIndex);
                        // first row of master is handing over the subtotals to the last row.
                        // The last row will be responsible for displaying them.
                        _lastDetailRow._subtotalInfo = _subtotalInfo;
                        _subtotalInfo = null;
                        gv.RowDataBound += row.gv_RowDataBound;
                        gv.DataBound += row.gv_DataBound;
                    }
                    else
                    {
                        // Subsequent row of this master
                        _lastDetailRow = row;
                        row._rowInfo._indexWithinMaster = this._rowInfo._countRowsInMaster;
                        ++_rowInfo._countRowsInMaster;
                        _subtotalInfo.LastRowIndex = row.DataItemIndex;
                        var query = gv.Columns.Cast<DataControlField>()
                            .Select((p, i) => new { Column = p as INeedsSummaries, Index = i })
                            .Where(p => p.Column != null);
                        foreach (var colInfo in query)
                        {
                            switch (colInfo.Column.DataSummaryCalculation)
                            {
                                case SummaryCalculationType.None:
                                case SummaryCalculationType.DataSource:
                                    // No subtotals
                                    break;

                                case SummaryCalculationType.ValueSummation:
                                case SummaryCalculationType.ValueWeightedAverage:
                                    SummaryData data = _subtotalInfo.Subtotals[colInfo.Index];
                                    for (int i = 0; i < colInfo.Column.DataFooterFields.Length; ++i)
                                    {
                                        object obj = DataBinder.Eval(e.Row.DataItem, colInfo.Column.DataFooterFields[i]);
                                        if (obj != DBNull.Value)
                                        {
                                            if (data.Values[i] == null)
                                            {
                                                data.Values[i] = Convert.ToDecimal(obj);
                                            }
                                            else
                                            {
                                                data.Values[i] += Convert.ToDecimal(obj);
                                            }
                                            ++data.RowCount;
                                        }
                                    }
                                    break;

                                default:
                                    throw new NotImplementedException();
                            }
                        }

                    }
                    break;
            }
        }

        /// <summary>
        /// Initializes the value for each column whose sum is to be displayed in the footer,
        /// is called during the first row of grid encountered and for then each time master row changes.
        /// </summary>
        /// <remarks>
        /// The function evaluates value for each detail column and places these with in a variable of
        /// type <see cref="SubtotalInfo"/>. However for any column to participate within the variable
        /// they must be of type <see cref="INeedsSummaries" />. By this column defines that it agress
        /// to the contract of being participating in the summing operation.
        /// </remarks>
        /// <param name="dataItem"></param>
        /// <param name="rowIndex"></param>
        private void InitializeSubTotals(object dataItem, int rowIndex)
        {
            _subtotalInfo = new SubtotalInfo(rowIndex); // { RowCounts = new int[col.DataFooterFields.Length] };
            // First row of the master. Simply Initialize totals
            var query = this.Grid.Columns.Cast<DataControlField>()
                .Select((p, i) => new { Column = p as INeedsSummaries, Index = i })
                .Where(p => p.Column != null);
            foreach (var colInfo in query)
            {
                switch (colInfo.Column.DataSummaryCalculation)
                {
                    case SummaryCalculationType.None:
                    case SummaryCalculationType.DataSource:
                        break;

                    case SummaryCalculationType.ValueSummation:
                    case SummaryCalculationType.ValueWeightedAverage:
                        if (colInfo.Column.DataFooterFields == null || colInfo.Column.DataFooterFields.Length == 0)
                        {
                            throw new InvalidOperationException("To compute totals, DataFooterFields must be specified");
                        }
                        SummaryData data = new SummaryData();
                        data.Values = new decimal?[colInfo.Column.DataFooterFields.Length];
                        for (int i = 0; i < data.Values.Length; ++i)
                        {
                            object obj = DataBinder.Eval(dataItem, colInfo.Column.DataFooterFields[i]);
                            if (obj != DBNull.Value)
                            {
                                data.Values[i] = Convert.ToDecimal(obj);
                                data.RowCount = 1;
                            }

                        }
                        _subtotalInfo.Subtotals.Add(colInfo.Index, data);
                        break;

                    default:
                        throw new NotImplementedException();
                }
            }
        }
        #endregion

        #region Render
        /// <summary>
        /// The event first calls <c>RenderMasterRowHeader"</c> if list to which header information exist is non empty,
        /// the function takes the responsibility of rendering header for the master row header, after the master row render
        /// <see cref="GridViewEx" />  <see cref="Render" /> is called which renders all the child rows and on completion of 
        /// master information if gridview has to render footer information then <c>RenderMasterRowFooter</c> is called.
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            //GridViewEx gv = (GridViewEx)this.NamingContainer;
            if (_rowInfo._indexWithinMaster == 0)
            {
                RenderMasterRowHeader(writer);
                this.Grid.HeaderRow.RenderControl(writer);
            }
            // Display the normal row
            base.Render(writer);

            if (this._subtotalInfo != null)
            {
                RenderMasterRowFooter(writer);
            }

        }

        /// <summary>
        /// The function retains information of all the columns implementing the interface <see cref="INeedsSummaries" />.
        /// </summary>
        /// <param name="writer"></param>
        private void RenderMasterRowFooter(HtmlTextWriter writer)
        {
            if (!this.Grid.ShowFooter)
            {
                return;
            }
            // Script uses this class to exclude subtotal rows from becoming selectable
            this.Grid.FooterStyle.CssClass += " gvex-subtotal-row";
            this.Grid.FooterStyle.AddAttributesToRender(writer);
            writer.RenderBeginTag(HtmlTextWriterTag.Tr);
            var query = this.Grid.Columns.Cast<DataControlField>()
                .Select((p, i) => new { Column = p, Index = i })
                .Where(p => p.Column.Visible);
            foreach (var colInfo in query)
            {
                IHasCustomCells customCellField = colInfo.Column as IHasCustomCells;
                if (customCellField == null)
                {
                    colInfo.Column.FooterStyle.AddAttributesToRender(writer);

                    writer.RenderBeginTag(HtmlTextWriterTag.Td);
                    INeedsSummaries summaryCol = colInfo.Column as INeedsSummaries;
                    if (summaryCol == null)
                    {
                        if (string.IsNullOrEmpty(colInfo.Column.FooterText))
                        {
                            writer.Write("&nbsp;");
                        }
                        else
                        {
                            writer.Write("Subtotal");
                        }
                    }
                    else
                    {
                        string formatString = summaryCol.DataFooterFormatString;
                        object[] values;
                        switch (summaryCol.DataSummaryCalculation)
                        {
                            case SummaryCalculationType.None:
                            case SummaryCalculationType.DataSource:
                                formatString = "&nbsp;";
                                values = new object[0];
                                break;

                            case SummaryCalculationType.ValueWeightedAverage:
                                if (string.IsNullOrEmpty(formatString))
                                {
                                    formatString = "{0}";
                                }
                                SummaryData data = _subtotalInfo.Subtotals[colInfo.Index];
                                values = new object[] { data.Values[0] / data.Values[1] };
                                break;

                            case SummaryCalculationType.ValueSummation:
                                if (string.IsNullOrEmpty(formatString))
                                {
                                    formatString = "{0}";
                                }
                                values = _subtotalInfo.Subtotals[colInfo.Index].Values.Cast<object>().ToArray();
                                break;

                            default:
                                throw new NotImplementedException();
                        }

                        writer.Write(formatString, values);
                    }
                    writer.RenderEndTag();      //td
                }
                else
                {
                    customCellField.RenderSubtotals(this, writer, _subtotalInfo.FirstRowIndex, _subtotalInfo.LastRowIndex);
                }
            }
            writer.RenderEndTag();          // tr
        }

        /// <summary>
        /// Master row markup looks like:
        /// <tr>
        ///   <td colspan="x">
        ///     <table>
        ///     <tbody>
        ///       <tr>
        ///         <td>Header Text 1: Header Value 1</td>
        ///         ...
        ///       </tr>
        ///       </tbody>
        ///     </table>
        ///   </td>
        /// </tr>
        /// </summary>
        /// <remarks>
        /// The method renders the content of <c>GridViewExMasterRow</c> with in gridview header using custom HTML table.
        /// </remarks>
        private void RenderMasterRowHeader(HtmlTextWriter writer)
        {
            // Render the master row before we render the normal row
            if (_rowInfo._masterRowIndex != 0)
            {
                // We are not the first master row. 
                // Enclose the rows of this master in a seperate tbody for ease of scripting
                writer.Write("</tbody><tbody>");
            }
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-masterrow ui-widget-content");
            writer.RenderBeginTag(HtmlTextWriterTag.Tr);

            writer.AddStyleAttribute(HtmlTextWriterStyle.TextAlign, "right");
            writer.AddStyleAttribute(HtmlTextWriterStyle.WhiteSpace, "nowrap");
            writer.RenderBeginTag(HtmlTextWriterTag.Td);
            writer.Write("{0:N0}&nbsp;", _rowInfo._masterRowIndex + 1);

            /*
<A class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only">
  <SPAN class="ui-button-icon-primary ui-icon ui-icon-gear" />
  <SPAN class=ui-button-text>Hello</SPAN>
             * 
             */
            //Folder icon here
            writer.RenderBeginTag(HtmlTextWriterTag.Sup);
            ButtonEx.RenderIcon(writer, "ui-icon-folder-open");
            writer.RenderEndTag();      // sup;
            writer.RenderEndTag();      //td

            // Here are aggregating the column spans of each visible header cell. If the column span is 0, we
            // treat it as 1.
            int visibleColumnCount = this.Grid.HeaderRow.Cells.Cast<DataControlFieldHeaderCell>()
                .Where(p => p.Visible)
                .Aggregate(0, (total, next) => total + (next.ColumnSpan == 0 ? 1 : next.ColumnSpan));
            
           
            // Subtract 2 for the first and last columns
            int nColSpan = visibleColumnCount - 2;

            writer.AddAttribute(HtmlTextWriterAttribute.Colspan, nColSpan.ToString());
            writer.RenderBeginTag(HtmlTextWriterTag.Td);

            int i = 0;
            foreach (int masterIndex in this.Grid.MasterColumnIndexes.OrderBy(p => p))
            {
                DataControlField col = this.Grid.Columns[masterIndex];
                SortExpression colSortExpression = new SortExpression(col.SortExpression);
                int nSortIndex = this.Grid.SortExpressions.Select((p, index) => p.Equals(colSortExpression) ? index : -1)
                    .Single(p => p != -1);
                SortDirection dirIcon = colSortExpression.GetSortDirection();
                col.ItemStyle.AddAttributesToRender(writer);
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "header-entry");
                TableCell cell = this.Cells[masterIndex];
                if (cell.HasControls())
                {
                    // Ignore header text
                    writer.RenderBeginTag(HtmlTextWriterTag.Div);
                    foreach (Control ctl in cell.Controls)
                    {
                        ctl.RenderControl(writer);
                    }
                    writer.RenderEndTag();  // div
                }
                else
                {
                    writer.RenderBeginTag(HtmlTextWriterTag.Span);
                    if (string.IsNullOrEmpty(col.HeaderText))
                    {
                        writer.Write(cell.Text);
                    }
                    else
                    {
                        writer.RenderBeginTag(HtmlTextWriterTag.Strong);
                        GridViewExHeaderCell.RenderNotSortableWithIcon(writer, col.HeaderText, dirIcon, nSortIndex + 1);
                        writer.RenderEndTag();  // strong
                        writer.Write(": {0}", cell.Text);
                    }
                    writer.RenderEndTag();  // span
                }
                ++i;
                if (i % 2 == 0)
                {
                    writer.WriteBreak();
                }
            }

            writer.RenderEndTag();      //td

            // Row count
            writer.AddStyleAttribute(HtmlTextWriterStyle.TextAlign, "right");
            writer.RenderBeginTag(HtmlTextWriterTag.Td);
            writer.Write("{0:N0} row{1}", _rowInfo._countRowsInMaster, _rowInfo._countRowsInMaster == 1 ? "" : "s");
            writer.RenderEndTag();
            writer.RenderEndTag();      //tr
        }
        #endregion

        #region View State
        protected override object SaveViewState()
        {
            //object obj = base.SaveViewState();
            if (_subtotalInfo == null)
            {
                return _rowInfo;
            }
            else
            {
                object[] values = new object[] { _rowInfo, _subtotalInfo };
                return values;
            }
        }

        protected override void LoadViewState(object savedState)
        {
            object[] values = savedState as object[];
            if (values == null)
            {
                _rowInfo = (RowInfo)savedState;
            }
            else
            {
                _rowInfo = (RowInfo)values[0];
                _subtotalInfo = (SubtotalInfo)values[1];
            }
            //base.LoadViewState(savedState);
        }
        #endregion
    }
}

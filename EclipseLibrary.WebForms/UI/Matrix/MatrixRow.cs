using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.UI.Matrix
{
    /// <summary>
    /// This actually reprsents a cell within the row of the grid. This cell itself looks like a row because it contains multiple columns.
    /// </summary>
    /// <remarks>
    /// To customize the text displayed in any column you can access this class within the <c>RowDataBound</c> of the grid. The example shown here
    /// sets custom text for two static columns which were added in <see cref="MatrixField.DataHeaderValues"/>
    /// </remarks>
    /// <![CDATA[
    /// protected void gvPaybill_RowDataBound(object sender, GridViewRowEventArgs e)
    ///    {
    ///        EclipseLibrary.Web.UI.Matrix.MatrixRow mr;
    ///        switch (e.Row.RowType)
    ///        {
    ///            case DataControlRowType.DataRow:
    ///                mr = e.Row.Controls.OfType<EclipseLibrary.Web.UI.Matrix.MatrixRow>().Single();
    ///                var deductionsTotal = mr.MatrixCells.Where(p => p.DisplayColumn.MatrixColumn.ColumnType == MatrixColumnType.CellValue && p.DataItem != null &&
    ///                    (bool) DataBinder.Eval(p.DataItem, "IsDeduction")).Sum(p => (decimal?)DataBinder.Eval(p.DataItem, "AmountRounded"));
    ///                var deductionsTotalCell = mr.MatrixCells.First(p => (bool)DataBinder.Eval(p.DataItem, "IsDeduction") && DataBinder.Eval(p.DataItem, "AdjustmentCategoryDescription", "{0}") == "X");
    ///                deductionsTotalCell.Text = string.Format("{0:N0}", deductionsTotal);
    ///                _finalDeductions = _finalDeductions + Convert.ToDecimal(deductionsTotal);
    ///                decimal? basicPay = (decimal?)DataBinder.Eval(e.Row.DataItem, "BasicPay");
    ///                var earningsTotal = mr.MatrixCells.Where(p => p.DisplayColumn.MatrixColumn.ColumnType == MatrixColumnType.CellValue && p.DataItem != null &&
    ///                    !(bool)DataBinder.Eval(p.DataItem, "IsDeduction")).Sum(p => (decimal?)DataBinder.Eval(p.DataItem, "AmountRounded"));
    ///                     if (earningsTotal == null)
    ///                    {
    ///                        earningsTotal = basicPay ?? 0;
    ///                    }
    ///                    else
    ///                    {
    ///                        earningsTotal = (earningsTotal ?? 0) + (basicPay ?? 0);
    ///                   }
    ///                var earningsTotalCell = mr.MatrixCells.First(p => !(bool)DataBinder.Eval(p.DataItem, "IsDeduction") && DataBinder.Eval(p.DataItem, "AdjustmentCategoryDescription", "{0}") == "X");
    ///                earningsTotalCell.Text = string.Format("{0:N0}", earningsTotal);
    ///                _finalSanctions = _finalSanctions + Convert.ToDecimal(earningsTotal);                    
    ///                decimal? netPay;
    ///                if (deductionsTotal != null)
    ///                  {
    ///                      netPay = earningsTotal - deductionsTotal;
    ///                  }
    ///                  else
    ///                 {
    ///                     netPay = earningsTotal;
    ///                 }
    ///               int indexNetPay = gvPaybill.Columns.Cast<DataControlField>()
    ///               .Select((p, i) => p.AccessibleHeaderText == "netPay" ? i : -1).First(p => p >= 0);
    ///               e.Row.Cells[indexNetPay].Text = string.Format("{0:N0}", netPay);
    ///             _totalNetPay += Convert.ToDecimal(netPay);
    ///                break;
    ///            case DataControlRowType.Footer:
    ///                int index = gvPaybill.Columns.Cast<DataControlField>()
    ///                    .Select((p, i) => p.AccessibleHeaderText == "netPay" ? i : -1).First(p => p >= 0);
    ///                e.Row.Cells[index].Text = string.Format("{0:N0}", _totalNetPay);
    ///                mr = e.Row.Controls.OfType<EclipseLibrary.Web.UI.Matrix.MatrixRow>().Single();
    ///                var deductionCell = mr.MatrixCells.First(p => (bool)DataBinder.Eval(p.DataItem, "IsDeduction") && DataBinder.Eval(p.DataItem, "AdjustmentCategoryDescription", "{0}") == "X");
    ///                deductionCell.Text = string.Format("{0:N0}", _finalDeductions);
    ///                mr = e.Row.Controls.OfType<EclipseLibrary.Web.UI.Matrix.MatrixRow>().Single();
    ///                var earingCell = mr.MatrixCells.First(p => !(bool)DataBinder.Eval(p.DataItem, "IsDeduction") && DataBinder.Eval(p.DataItem, "AdjustmentCategoryDescription", "{0}") == "X");
    ///                earingCell.Text = string.Format("{0:N0}", _finalSanctions);                  
    ///                break;
    ///        }
    ///    }
    /// 
    /// ]]>
    
    public class MatrixRow : DataControlFieldCell
    {
        public MatrixRow(MatrixField containingField)
            : base(containingField)
        {

        }

        public IEnumerable<MatrixCell> MatrixCells
        {
            get
            {
                return this.Controls.OfType<MatrixCell>();
            }
        }

        /// <summary>
        /// Create the <see cref="MatrixCell"/> controls. Also instantiate the item template if it exists
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInit(EventArgs e)
        {
            MatrixField mf = (MatrixField)this.ContainingField;
            foreach (var dc in mf.DisplayColumns)
            {
                MatrixCell mc = new MatrixCell(dc);
                mc.MergeStyle(this.ContainingField.ItemStyle);
                this.Controls.Add(mc);
            }
            mf.DisplayColumns.CollectionChanged += DisplayColumns_CollectionChanged;
            base.OnInit(e);
        }

        /// <summary>
        /// Create a <see cref="MatrixCell"/> for each <see cref="MatrixDisplayColumn"/> which is added after <see cref="OnInit"/>
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DisplayColumns_CollectionChanged(object sender, NotifyCollectionChangedEventArgs e)
        {
            switch (e.Action)
            {
                case NotifyCollectionChangedAction.Add:
                    foreach (MatrixDisplayColumn dc in e.NewItems.Cast<MatrixDisplayColumn>())
                    {
                        MatrixCell cell = new MatrixCell(dc);
                        this.Controls.Add(cell);
                    }
                    break;

                default:
                    throw new NotImplementedException();
            }
        }

        #region Rendering
        protected override void Render(HtmlTextWriter writer)
        {
            MatrixField mf = (MatrixField)this.ContainingField;

            if (mf.DisplayColumns.Count == 0)
            {
                // We have no columns to show. Do nothing
                return;
            }

            var query = from mc in this.MatrixCells
                        where mc.Visible
                        orderby mc.DisplayColumn
                        select mc;
            foreach (var mc in query)
            {
                mc.RenderControl(writer);
            }
        }
        #endregion


        /// <summary>
        /// This is called when master-detail GricViewEx asks us to rener subtotals. We compute the subtotals for each <see cref="MatrixCell"/>
        /// and then temporarily change its text.
        /// </summary>
        /// <param name="writer"></param>
        /// <param name="firstRowIndex"></param>
        /// <param name="lastRowIndex"></param>
        internal void RenderSubtotals(HtmlTextWriter writer, int firstRowIndex, int lastRowIndex)
        {
            var query = from mc in this.MatrixCells
                        where mc.Visible && mc.DisplayColumn.MatrixColumn.DisplayColumnTotal
                        orderby mc.DisplayColumn
                        select mc;
            foreach (var mc in query)
            {
                string oldText = mc.Text;
                DoRenderSubtotals(mc, firstRowIndex, lastRowIndex);
                mc.RenderControl(writer);
                mc.Text = oldText;
            }
        }

        private void DoRenderSubtotals(MatrixCell mc, int firstRowIndex, int lastRowIndex)
        {
            GridView gv = (GridView)this.NamingContainer.NamingContainer;
            decimal?[] subtotals = new decimal?[mc.CellValues.Length];

            IEnumerable<object[]> query = gv.Rows.Cast<GridViewRow>()
                            .Skip(firstRowIndex).Take(lastRowIndex - firstRowIndex + 1)
                            .SelectMany(p => p.Cells.OfType<MatrixRow>())
                            .SelectMany(p => p.MatrixCells)
                            .Where(p => object.ReferenceEquals(p.DisplayColumn, mc.DisplayColumn))
                            .Select(p => p.CellValues);

            /*
                         foreach (int i in _mf.DataCellFields
                .Select((p, i) => _colTotalindexes.Contains(i) ? i : -1)
                .Where(p => p >= 0))
            {
                if (values[i] != DBNull.Value)
                {
                    _columnTotals[i] = (_columnTotals[i] ?? 0) + Convert.ToDecimal(values[i]);
                }

            }
             */
            MatrixField mf = (MatrixField)this.ContainingField;
            foreach (var values in query)
            {
                if (values != null)
                {
                    foreach (int i in mf.DataCellFields
                        .Select((p, i) => mc.DisplayColumn.FieldsToTotal.Contains(i) ? i : -1)
                        .Where(p => p >= 0))
                    {
                        if (values[i] != DBNull.Value)
                        {
                            subtotals[i] = (subtotals[i] ?? 0) + Convert.ToDecimal(values[i]);
                        }
                    }
                    //for (int i = 0; i < subtotals.Length; ++i)
                    //{
                    //    if (values[i] != DBNull.Value)
                    //    {
                    //        subtotals[i] = (subtotals[i] ?? 0) + Convert.ToDecimal(values[i]);
                    //    }
                    //}
                }
            }
            mc.Text = string.Format(mc.DisplayColumn.MatrixColumn.ColumnTotalFormatString, subtotals.Cast<object>().ToArray());
        }
    }
}

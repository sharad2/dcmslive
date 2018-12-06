using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery;

namespace EclipseLibrary.Web.UI.Matrix
{
    /// <summary>
    /// Displays the first and second rows of matrix header
    /// </summary>
    /// <remarks>
    /// <para>
    /// <see cref="MatrixField"/>
    /// </para>
    /// </remarks>
    internal class MatrixHeaderRow : DataControlFieldHeaderCell
    {
        public MatrixHeaderRow(MatrixField field)
            : base(field)
        {
            //this.RowToRender = GridViewExHeaderRow.ROW_FIRST_LINE_HEADER;
        }

        /// <summary>
        /// Used only by <see cref="MatrixHeaderRowProxy"/>
        /// </summary>
        internal int? RowToRender { get; set; }
        /// <summary>
        /// Prevents this column from spanning with previous or next columns even if the first row
        /// header text matches
        /// </summary>
        /// <returns></returns>
        public override bool HasControls()
        {
            return true;
        }

        /// <summary>
        /// The call to this function is expected only from the GridViewExMasterRow class.
        /// It returns the number of columns we are actually showing. The value of this property cannot
        /// be set.
        /// </summary>
        /// <remarks>
        /// GL: Dated - 22 July, 2010.
        /// </remarks>
        public override int ColumnSpan
        {
            get
            {
                MatrixField mf = (MatrixField)this.ContainingField;
                return mf.DisplayColumns.Where(p => p.Visible).Count();
                //MatrixField mf = (MatrixField)this.ContainingField;
                //int count = mf.InstanceColumns.Where(p => p.SourceColumn.Visible)
                //    .Select(p => p.SourceColumn.DisplayRowTotal ? 2 : 1).Sum();
                //var query = mf.InstanceColumns.Select(p => p.SourceColumn).Distinct().Count(p => p.DisplayRowTotal);
                ////if (mf.DisplayRowTotals)
                ////{
                ////    // One column for row total of each column group
                ////    count += mf.ColumnGroups.Count;
                ////}
                //return count;
            }
            set
            {
                // Ignore the span we are being asked to set
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="writer"></param>
        /// <exception cref="NotImplementedException"></exception>
        protected override void Render(HtmlTextWriter writer)
        {
            MatrixField mf = (MatrixField)this.ContainingField;
            if (mf.DisplayColumns.Count == 0)
            {
                // We have no columns to show. Do nothing
                return;
            }

            GridViewRow row = (GridViewRow) this.NamingContainer;
            IEnumerable<string> headers;
            switch (this.RowToRender ?? row.RowIndex)
            {
                case GridViewExHeaderRow.ROW_FIRST_LINE_HEADER:
                    headers = from dc in mf.DisplayColumns
                            where dc.Visible
                            orderby dc
                            select mf.GroupByColumnHeaderText ? dc.ColumnHeaderText : dc.MainHeaderText;
                    //var query1 = mf.DisplayColumns.Where(p=> p.Visible)
                    //    .OrderBy(p => p)
                    //    .Select(p => mf.GroupByColumnHeaderText ? p.ColumnHeaderText : p.MainHeaderText);
                    RenderOneRow(writer, headers);
                    break;

                case GridViewExHeaderRow.ROW_SECOND_LINE_HEADER:
                case GridViewExHeaderRow.ROW_SINGLE_LINE_HEADER:
                    // This is the second header row
                    // ROW_SINGLE_LINE_HEADER is received only when we are exporting to Excel
                    headers = from dc in mf.DisplayColumns
                              where dc.Visible
                              orderby dc
                              select mf.GroupByColumnHeaderText ? dc.MainHeaderText : dc.ColumnHeaderText;
                    //var query2 = mf.DisplayColumns.Where(p => p.Visible)
                    //    .OrderBy(p => p)
                    //    .Select(p => mf.GroupByColumnHeaderText ? p.MainHeaderText : p.ColumnHeaderText);
                    RenderOneRow(writer, headers);
                    break;

                //case GridViewExHeaderRow.ROW_SINGLE_LINE_HEADER:
                //    throw new NotImplementedException("Not Possible");

                default:
                    throw new NotImplementedException("Will this happen ?");
            }
        }

        private void RenderOneRow(HtmlTextWriter writer, IEnumerable<string> query)
        {
            MatrixField mf = (MatrixField)this.ContainingField;
            int colSpan = 0;
            string prevGroupText = null;
            bool bFirst = true;
            foreach (var groupText in query)
            {
                if (bFirst)
                {
                    prevGroupText = groupText;
                    colSpan = 1;
                    bFirst = false;
                }
                else if (groupText == prevGroupText)
                {
                    ++colSpan;
                }
                else
                {
                    // Render previous group
                    RenderTh(writer, mf, colSpan, prevGroupText);
                    colSpan = 1;
                    prevGroupText = groupText;
                }
            }
            if (!bFirst)
            {
                // Render last group
                RenderTh(writer, mf, colSpan, prevGroupText);
            }
        }

        private static void RenderTh(HtmlTextWriter writer, MatrixField mf, int colSpan, string text)
        {
            mf.HeaderStyle.AddAttributesToRender(writer);
            if (colSpan > 1)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Colspan, colSpan.ToString());
            }

            writer.RenderBeginTag(HtmlTextWriterTag.Th);
            if (string.IsNullOrWhiteSpace(text))
            {
                // Make this a 0 height cell
                writer.AddStyleAttribute(HtmlTextWriterStyle.Height, "0");
            }
            else
            {
                writer.Write(text);
            }
            writer.RenderEndTag();
        }
    }

    internal class MatrixHeaderRowProxy : DataControlFieldHeaderCell
    {
        private readonly MatrixHeaderRow _proxy;
        public MatrixHeaderRowProxy(MatrixHeaderRow proxy)
            : base(proxy.ContainingField)
        {
            _proxy = proxy;
        }

        protected override void Render(HtmlTextWriter writer)
        {
            GridViewRow row = (GridViewRow)this.NamingContainer;
            _proxy.RowToRender = row.RowIndex;
            _proxy.RenderControl(writer);
            _proxy.RowToRender = null;
            //base.Render(writer);
        }
    }
}

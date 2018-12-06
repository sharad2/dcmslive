using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Renders custom paging buttons. Special code exists to ensure that sort expression does not change
    /// when a new page is clicked
    /// </summary>
    public class GridViewExPagerRow : GridViewRow
    {
        private int _totalRows;
        public GridViewExPagerRow(TableRowSection section)
            : base(-1, -1, DataControlRowType.Pager, DataControlRowState.Normal)
        {
            this.TableSection = section;
        }

        //private int _columnSpan;
        private bool _isLastPage;
        private bool _isFirstPage;
        private int _pageCount;
        internal void Intialize(int columnSpan, PagedDataSource pagedDataSource)
        {
            _totalRows = pagedDataSource.VirtualCount;
            //_columnSpan = columnSpan;
            _isFirstPage = pagedDataSource.IsFirstPage;
            _isLastPage = pagedDataSource.IsLastPage;
            _pageCount = pagedDataSource.PageCount;
        }

        protected override void Render(HtmlTextWriter writer)
        {
            GridViewEx gv = (GridViewEx)this.NamingContainer;
            // This takes care of the possibility of a MatrixField existing as one of the columns
            int visibleColumnCount = gv.HeaderRow.Cells.Cast<DataControlFieldHeaderCell>()
                .Where(p => p.Visible)
                .Aggregate(0, (total, next) => total + (next.ColumnSpan == 0 ? 1 : next.ColumnSpan));
            writer.RenderBeginTag(HtmlTextWriterTag.Tr);
            writer.AddAttribute(HtmlTextWriterAttribute.Colspan, visibleColumnCount.ToString());
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-pager-cell");
            writer.RenderBeginTag(HtmlTextWriterTag.Td);
            RenderContents(writer);
            writer.RenderEndTag();      // td
            writer.RenderEndTag();      // tr
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            GridViewEx gv = (GridViewEx)this.NamingContainer;
            string str;
            if (!_isFirstPage)
            {
                writer.AddStyleAttribute("float", "left");
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-page-link ui-icon ui-icon-seek-first");
                writer.AddAttribute(HtmlTextWriterAttribute.Title, "First Page");
                str = string.Format("1${0}", gv.DefaultSortExpression);
                writer.AddAttribute(HtmlTextWriterAttribute.Href, str);
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.RenderEndTag();
                writer.AddStyleAttribute("float", "left");
                str = string.Format("{0}${1}", gv.PageIndex, gv.DefaultSortExpression);
                writer.AddAttribute(HtmlTextWriterAttribute.Href, str);
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-page-link ui-icon ui-icon-seek-prev");
                writer.AddAttribute(HtmlTextWriterAttribute.Title, "Previous Page");
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.RenderEndTag();
            }
            if (!_isLastPage)
            {
                writer.AddStyleAttribute("float", "right");
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-page-link ui-icon ui-icon-seek-end");
                writer.AddAttribute(HtmlTextWriterAttribute.Title, "Last Page");
                str = string.Format("{0}${1}", _pageCount, gv.DefaultSortExpression);
                writer.AddAttribute(HtmlTextWriterAttribute.Href, str);
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.RenderEndTag();
                writer.AddStyleAttribute("float", "right");
                str = string.Format("{0}${1}", gv.PageIndex + 2, gv.DefaultSortExpression);
                writer.AddAttribute(HtmlTextWriterAttribute.Href, str);
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-page-link ui-icon ui-icon-seek-next");
                writer.AddAttribute(HtmlTextWriterAttribute.Title, "Next Page");
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.RenderEndTag();
            }

            //writer.Write("Displaying {0:N0} - {1:N0} of {2:N0} results &bull; ",
            //    (gv.PageIndex * gv.PageSize) + 1,
            //    (gv.PageIndex + 1) * gv.PageSize - (gv.PageSize - gv.Rows.Count),
            //    _totalRows);
            writer.Write("Displaying {0:N0} to {1:N0} of ",
                (gv.PageIndex * gv.PageSize) + 1,
                (gv.PageIndex + 1) * gv.PageSize - (gv.PageSize - gv.Rows.Count));
            writer.AddStyleAttribute(HtmlTextWriterStyle.FontWeight, "bold");
            writer.AddStyleAttribute(HtmlTextWriterStyle.FontSize, "1.2em");
            writer.RenderBeginTag(HtmlTextWriterTag.Span);
            writer.Write("{0:N0} ", _totalRows);
            writer.RenderEndTag();  // span
            writer.Write("results &bull; ");

            const int MAX_NUMERIC_BUTTONS = 10;
            int nFirstButtonPageIndex = gv.PageIndex - (gv.PageIndex % MAX_NUMERIC_BUTTONS);
            int nLastButtonPageIndex = Math.Min(_pageCount - 1, nFirstButtonPageIndex + MAX_NUMERIC_BUTTONS);

            for (int i = nFirstButtonPageIndex; i <= nLastButtonPageIndex; ++i)
            {
                if (i == gv.PageIndex)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-state-active");
                }
                else
                {
                    str = string.Format("{0}${1}", i + 1, gv.DefaultSortExpression);
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-page-link");
                    writer.AddAttribute(HtmlTextWriterAttribute.Href, str);
                }
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.Write(i + 1);
                writer.RenderEndTag();      //a
                writer.Write(" ");
            }
            return;
        }


    }
}

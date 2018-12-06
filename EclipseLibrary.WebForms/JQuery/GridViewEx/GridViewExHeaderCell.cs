using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;
using EclipseLibrary.Web.JQuery.Input;
using System.Linq;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Responsible for generating the appropriate sort icon
    /// </summary>
    /// <include file='GridViewExHeaderCell.xml' path='GridViewExHeaderCell/doc[@name="class"]/*'/>
    internal class GridViewExHeaderCell : DataControlFieldHeaderCell
    {
        private readonly GridViewEx _gv;

        public GridViewExHeaderCell(GridViewEx gv, DataControlField containingField)
            : base(containingField)
        {
            _gv = gv;
        }


        protected override void Render(HtmlTextWriter writer)
        {
            IHasHeaderToolTip tip = this.ContainingField as IHasHeaderToolTip;
            if (tip != null)
            {
                this.ToolTip = tip.HeaderToolTip;
            }
            base.Render(writer);
        }


        protected override void RenderContents(HtmlTextWriter writer)
        {
//#if DEBUG
//            if (!_gv.PreSorted && string.IsNullOrEmpty(_gv.SortExpression))
//            {
//                throw new InvalidOperationException("You are attempting to display the " + _gv.ID + " list in an unsorted order");
//            }
//#endif
            if (this.HasControls())
            {
                // Must be HeaderTemplate of Template field. No sort icons to be displayed here
                base.RenderContents(writer);
                return;
            }
            SortExpression colSortExpression;
            int nSortIndex;
            bool bIsSortable = _gv.AllowSorting;
            if (string.IsNullOrEmpty(this.ContainingField.SortExpression))
            {
                bIsSortable = false;
                nSortIndex = -1;
                colSortExpression = null;
            }
            else
            {
                colSortExpression = new SortExpression(this.ContainingField.SortExpression);
                if (_gv.SortExpressions.Any())
                {
                    nSortIndex = _gv.SortExpressions.Select((p, i) => p.Equals(colSortExpression) ? i : -1).Max();
                }
                else
                {
                    nSortIndex = -1;
                }
            }


            if (this.ColumnSpan == 0)
            {
                // Case 1: Sortable with icon
                // Case 2: Sortable without icon
                // Case 3: Not sortable with icon
                // Case 4: Not sortable, no icon
                if (bIsSortable)
                {
                    // Sortable
                    SortExpressionCollection coll = new SortExpressionCollection(_gv.SortExpressions, colSortExpression);

                    //string script = string.Format("javascript:gridviewex_submit('{0}', '{1}', 'Sort${2}');",
                    //    this.Page.Form.ClientID, _gv.UniqueID, coll);
                    string script = string.Format("{0}", coll);

                    if (nSortIndex < 0)
                    {
                        // Case 2
                        RenderSortableNoIcon(writer, script);
                    }
                    else
                    {
                        colSortExpression = _gv.SortExpressions[nSortIndex];
                        RenderSortableWithIcon(writer, script, colSortExpression.GetSortDirection(), nSortIndex + 1);
                    }
                }
                else
                {
                    // Not sortable
                    if (nSortIndex < 0)
                    {
                        // Case 4
                        writer.Write(this.Text);
                    }
                    else
                    {
                        // Case 3
                        colSortExpression = _gv.SortExpressions[nSortIndex];
                        RenderNotSortableWithIcon(writer, this.Text, colSortExpression.GetSortDirection(), nSortIndex + 1);
                    }
                }
            }
            else
            {
                // Top row of the header should never have icons
                // Case 4
                writer.Write(this.Text);
            }

        }

        /// <summary>
        /// Renders: Text icon sequence
        /// </summary>
        /// <param name="writer"></param>
        /// <param name="text"></param>
        /// <param name="dirIcon"></param>
        /// <param name="nSortSequence"></param>
        internal static void RenderNotSortableWithIcon(HtmlTextWriter writer, string text, SortDirection dirIcon, int nSortSequence)
        {
            writer.Write(text);
            RenderSortIcon(writer, dirIcon, nSortSequence);
        }

        private void RenderSortableNoIcon(HtmlTextWriter writer, string script)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Href, script);
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-sort-link");
            writer.RenderBeginTag(HtmlTextWriterTag.A);
            writer.Write(this.Text);
            writer.RenderEndTag();      // a
        }

        //<a href='__dopostback()' class='gvex-button ui-state-default ui-corner-all' onclick='Code to display Sorting...'>
        //        Cell Header Text<span class='ui-icon ui-icon-triangle-1-n'></span><sup>1</sup>
        //</a>;
        private void RenderSortableWithIcon(HtmlTextWriter writer, string script, SortDirection dirIcon,
            int nSortSequence)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Href, script);
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-sort-link");
            writer.RenderBeginTag(HtmlTextWriterTag.A);
            writer.Write(this.Text);
            writer.RenderEndTag();      //a

            RenderSortIcon(writer, dirIcon, nSortSequence);
        }

        private static void RenderSortIcon(HtmlTextWriter writer, SortDirection dirIcon, int nSortSequence)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-sort-icon");
            writer.RenderBeginTag(HtmlTextWriterTag.Span);
            writer.RenderBeginTag(HtmlTextWriterTag.Sup);
            //ButtonEx btn = new ButtonEx();
            //btn.Icon = IconType.Custom;
            string str = string.Format("ui-icon-triangle-1-{0}", dirIcon == SortDirection.Ascending ? "n" : "s");
            ButtonEx.RenderIcon(writer, str);
            //btn.ButtonState = ButtonState.None;
            //btn.RenderControl(writer);
            writer.RenderEndTag();

            if (nSortSequence > 0)
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Sup);
                writer.Write("{0}", nSortSequence);
                writer.RenderEndTag();          // sup
            }
            writer.RenderEndTag();          // span
        }
    }
}

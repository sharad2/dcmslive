/* $Id: LeftPanel.cs 36656 2010-10-26 05:53:29Z ssinghal $ */

using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;
using System;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// This class simply enables child controls to be placed in the left column of a TwoColumnPanel
    /// </summary>
    /// <remarks>
    /// 25 Nov 2009: Deriving from Control instead of from Panel
    /// </remarks>
    public class LeftPanel:Control, ILeftColumn
    {
        public LeftPanel()
        {
            this.RowVisible = true;
        }


        protected override void Render(HtmlTextWriter writer)
        {
            //if (this.Width != Unit.Empty)
            //{
            //    writer.AddStyleAttribute(HtmlTextWriterStyle.Width, this.Width.ToString());
            //}
            //if (this.Wrap)
            //{
            //    writer.AddStyleAttribute(HtmlTextWriterStyle.WhiteSpace, "normal");
            //}
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            base.Render(writer);
            writer.RenderEndTag();
        }

        #region ILeftColumn Members

        [Browsable(true)]
        [DefaultValue(true)]
        public bool RowVisible
        {
            get;
            set;
        }

        [Browsable(true)]
        [DefaultValue(false)]
        [Description("Whether this column should span to the right column as well")]
        public bool Span { get; set; }

        #endregion
    }
}

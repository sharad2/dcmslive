using System.ComponentModel;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Mimics the behavior of ASP.NET LinkButton
    /// </summary>
    /// <remarks>
    /// <para>
    /// The button is rendered hidden. The link is rendered visible which clicks the button when the link
    /// is clicked.
    /// </para>
    /// </remarks>
    public class LinkButtonEx:ButtonEx
    {
        public LinkButtonEx()
        {
            //this.Action = ButtonAction.Submit;
        }

        /// <summary>
        /// Click the hidden button when link is clicked
        /// </summary>
        protected override void PreCreateScripts()
        {
            if (this.IsEnabled)
            {
                string script = string.Format(@"$('{0}').prev().click(function(e) {{
    $(this).next().click();
    return false;
}});", this.ClientSelector);
                JQueryScriptManager.Current.RegisterReadyScript(script);
            }
            base.PreCreateScripts();
        }

        [Browsable(false)]
        public override ButtonClientVisibility ClientVisible
        {
            get
            {
                return ButtonClientVisibility.Never;
            }
            set
            {
            }
        }

        /// <summary>
        /// Render the link
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Href, "#");
            if (!string.IsNullOrEmpty(this.ToolTip))
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Title, this.ToolTip);
            }
            if (this.IsEnabled)
            {
                writer.RenderBeginTag(HtmlTextWriterTag.A);
            }
            else
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
            }
            writer.Write(this.Text);
            writer.RenderEndTag();
            base.Render(writer);
        }

        /// <summary>
        /// Action must always be Submit
        /// </summary>
        [Browsable(false)]
        [ReadOnly(true)]
        public override ButtonAction Action
        {
            get
            {
                return ButtonAction.Submit;
            }
            set
            {
                //base.Action = value;
            }
        }
    }
}

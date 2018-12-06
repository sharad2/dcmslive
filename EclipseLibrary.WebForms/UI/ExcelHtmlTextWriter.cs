using System.IO;
using System.Web.UI;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// Designed to render markup for EXCEL html.
    /// Does not render any attributes or styles so that comparisons do not fail.
    /// 
    /// </summary>
    /// <remarks>
    /// Visual tags such as em, strong, etc. are not rendered since they do not impact content.
    /// div and span are not rendered because because they have no effect in the abscense of styles
    /// Sharad 4 Aug 2009: Adding border tag to all td elements so that excel displays horizontal and vertical lines
    /// </remarks>
    public class ExcelHtmlTextWriter : HtmlTextWriter
    {
        public ExcelHtmlTextWriter(TextWriter writer)
            : base(writer, "")
        {
            this.Indent = 0;
        }

        /// <summary>
        /// Does not render any attributes
        /// </summary>
        /// <param name="name"></param>
        /// <param name="value"></param>
        /// <param name="key"></param>
        /// <returns></returns>
        protected override bool OnAttributeRender(string name, string value, HtmlTextWriterAttribute key)
        {
            return false;
        }

        /// <summary>
        /// Does not render any style attribute except mso-number-format
        /// </summary>
        /// <param name="name"></param>
        /// <param name="value"></param>
        /// <param name="key"></param>
        /// <returns></returns>
        protected override bool OnStyleAttributeRender(string name, string value, HtmlTextWriterStyle key)
        {
            if (name == "mso-number-format" || name == "border")
            {
                return true;
            }
            return false;
        }


        /// <summary>
        /// If td has an align left attibute we add the mso-number-format attribute so that excel treats it as text
        /// </summary>
        /// <param name="tagKey"></param>
        public override void RenderBeginTag(HtmlTextWriterTag tagKey)
        {
            if (tagKey == HtmlTextWriterTag.Td)
            {
                string value;
                if (IsAttributeDefined(HtmlTextWriterAttribute.Align, out value))
                {
                    if (value == "left")
                    {
                        this.AddStyleAttribute("mso-number-format", "'\\@'");
                    }
                }
                // This ensures that excel displays lines around its cells
                this.AddStyleAttribute("border", ".5pt solid windowtext");
            }
            else if (tagKey == HtmlTextWriterTag.Table)
            {
                this.AddAttribute(HtmlTextWriterAttribute.Rules, "all");
            }
            base.RenderBeginTag(tagKey);
        }

    }
}

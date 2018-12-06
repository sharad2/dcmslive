using System.IO;
using System.Web.UI;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// Does not render any attributes or styles so that comparisons do not fail.
    /// 
    /// This class can be used for markup comparisons, export to excel, etc.
    /// </summary>
    /// <remarks>
    /// Visual tags such as em, strong, etc. are not rendered since they do not impact content.
    /// div and span are not rendered because because they have no effect in the abscense of styles
    /// 
    /// SS 10 Jul 2009: title is considered to be a content attribute, so it is rendered
    /// </remarks>
    public class MiniHtmlTextWriter : HtmlTextWriter
    {
        public MiniHtmlTextWriter(TextWriter writer)
            : base(writer, "")
        {
            this.Indent = 0;
        }

        protected override bool OnAttributeRender(string name, string value, HtmlTextWriterAttribute key)
        {
            switch (key)
            {
                case HtmlTextWriterAttribute.Title:
                    return true;

                default:
                    return false;
            }
        }

        protected override bool OnStyleAttributeRender(string name, string value, HtmlTextWriterStyle key)
        {
            return false;
        }

        protected override bool OnTagRender(string name, HtmlTextWriterTag key)
        {
            switch (key)
            {
                case HtmlTextWriterTag.Sup:
                case HtmlTextWriterTag.Em:
                case HtmlTextWriterTag.Strong:
                case HtmlTextWriterTag.Div:
                case HtmlTextWriterTag.Span:
                    return false;

                default:
                    return true;
            }

        }

    }
}

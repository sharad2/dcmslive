using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Web.UI;
using System.Linq;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Represents a multi line text control
    /// </summary>
    /// <remarks>
    /// <para>
    /// <see cref="Rows"/> and <see cref="Cols"/> control how big the text box will appear to be.
    /// </para>
    /// </remarks>
    public class TextArea:InputControlBase
    {
        /// <summary>
        /// 
        /// </summary>
        public TextArea() : base(string.Empty)
        {
            this.Text = string.Empty;
        }

        /// <summary>
        /// The value of the text box
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// Number of rows to display in the UI
        /// </summary>
        public int Rows { get; set; }

        /// <summary>
        /// Number of columns to display in the UI
        /// </summary>
        public int Cols { get; set; }

        //public override bool LoadPostData(string postDataKey, NameValueCollection postCollection)
        //{
        //    this.Text = postCollection[postDataKey];
        //    return false;
        //}

        /// <summary>
        /// Proxy for <see cref="Text"/>
        /// </summary>
        public override string Value
        {
            get
            {
                return this.Text;
            }
            set
            {
                this.Text = value;
            }
        }

        /// <summary>
        /// Returns TEXTAREA
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Textarea;
            }
        }

        /// <summary>
        /// Adds <see cref="Rows"/> and <see cref="Cols"/> attributes
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            if (this.Rows > 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Rows, this.Rows.ToString());
            }
            if (this.Cols > 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Cols, this.Cols.ToString());
            }
            base.AddAttributesToRender(attributes, cssClasses);
        }

        protected override void Render(HtmlTextWriter writer)
        {
            base.Render(writer);
            if (this.Validators.OfType<Required>().Any())
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Sup);
                writer.Write("*");
                writer.RenderEndTag();
            }
        }

        protected override void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            styles.Add(HtmlTextWriterStyle.Overflow, "auto");
            base.AddStylesToRender(styles, stylesSpecial);
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            writer.Write(this.Text);
            base.RenderContents(writer);
        }
    }
}

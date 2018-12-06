using System;
using System.Collections.Generic;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// It is invisible if there is no status text. It does not maintain view state. Status disappears
    /// after any postback. Call AddStatusText to add status text. You can also specify whether it is an error message.
    /// Error messages are displayed in red.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Call <see cref="AddStatusText"/> to add status text or <see cref="AddErrorText"/> to add error text.
    /// Error text is displayed in red. <see cref="HasErrorText"/> can tell you whether any error text has been added.
    /// </para>
    /// <para>
    /// This <c>Updated</c>handler displays a status message indicating how many copies were printed. If an error occurs,
    /// the exception message is displyed as an error
    /// </para>
    /// <code>
    /// <![CDATA[
    /// protected void dsPickslips_Updated(object sender, SqlDataSourceStatusEventArgs e)
    /// {
    ///     if (e.Exception == null && e.AffectedRows > 0)
    ///     {
    ///        // string str = string.Format("Pack types of {0:N0} SKU line items updated", e.AffectedRows);
    ///         tpStatus.AddStatusText("Pack types of {0:N0} SKU line items updated", e.AffectedRows);
    ///     }
    ///     else
    ///     {
    ///         tpStatus.AddErrorText(e.Exception.Message);
    ///         e.ExceptionHandled = true;
    ///     }
    /// }
    /// ]]>
    /// </code>
    /// </remarks>
    public class StatusPanel:Dialog
    {
        //private readonly Literal _lit;

        private List<string> _list;
        public StatusPanel()
        {
            this.EnableViewState = false;
            this.Buttons.Add(new CloseButton() { Text="Close"});
        }

        protected override void OnInit(EventArgs e)
        {
            this.Page.LoadComplete += new EventHandler(Page_LoadComplete);
            base.OnInit(e);
        }

        void Page_LoadComplete(object sender, EventArgs e)
        {
            this.Visible = _list != null;
        }

        /// <summary>
        /// Returns whether any status text has been added, including error text
        /// </summary>
        public bool HasStatusText
        {
            get
            {
                return _list != null;
            }
        }

        /// <summary>
        /// Whether any error text has been added
        /// </summary>
        public bool HasErrorText { get; set; }

        /// <summary>
        /// Add some text to display. This will make the status panel visible
        /// </summary>
        /// <param name="formatString"></param>
        /// <param name="values"></param>
        public void AddStatusText(string formatString, params object[] values)
        {
            if (_list == null)
            {
                _list = new List<string>();
            }
            string str = string.Format(formatString, values);
            _list.Add(str);
        }

        public void AddErrorText(string formatString, params object[] values)
        {
            if (_list == null)
            {
                _list = new List<string>();
            }
            string str = string.Format(formatString, values);
            str = string.Format("<span style='color:red'>{0}</span>", str);
            _list.Add(str);
            this.HasErrorText = true;
        }

        /// <summary>
        /// Text to show after all messages have been displayed
        /// </summary>
        public string FooterText { get; set; }

        /// <summary>
        /// Removes all the status messages added so far
        /// </summary>
        public void ClearAll()
        {
            _list = null;
        }


        protected override void RenderChildren(HtmlTextWriter writer)
        {
            if (_list == null)
            {
                return;
            }
            if (_list.Count == 1)
            {
                writer.Write(_list[0]);
                writer.WriteBreak();
            }
            else
            {
                writer.AddStyleAttribute(HtmlTextWriterStyle.MarginLeft, "4mm");
                writer.RenderBeginTag(HtmlTextWriterTag.Ol);
                foreach (string str in _list)
                {
                    writer.RenderBeginTag(HtmlTextWriterTag.Li);
                    writer.Write(str);
                    writer.RenderEndTag();
                }
                writer.RenderEndTag();
            }


            if (!string.IsNullOrEmpty(this.FooterText))
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Em);
                writer.Write(this.FooterText);
                writer.RenderEndTag();
            }
        }
    }
}

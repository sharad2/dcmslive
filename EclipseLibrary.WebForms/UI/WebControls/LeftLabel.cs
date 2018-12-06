/* $Id: LeftLabel.cs 36656 2010-10-26 05:53:29Z ssinghal $ */
using System;
using System.ComponentModel;
using System.Web.UI;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// Text is saved in ViewState so that you can bind to it dynamically. By default, view state is off.
    /// Turn it on only if you need it
    /// </summary>
    /// <remarks>
    /// SS 19 Jul 2008: Added ability to have child controls
    /// </remarks>
    [ToolboxData(@"
<{0}:LeftLabel runat=""server"" Text=""LeftLabel"" />
")]
    [Themeable(false)]
    [ParseChildren(true)]
    public sealed class LeftLabel:Control, IHotKeyLeftColumn
    {
        public LeftLabel()
        {
        }

        private string _text = string.Empty;

        [Browsable(true)]
        public string Text
        {
            get { return _text; }
            set { _text = value; }
        }

        [Browsable(true)]
        [DefaultValue(true)]
        public bool RowVisible
        {
            get
            {
                object obj = ViewState["RowVisible"];
                if (obj == null)
                {
                    return true;
                }
                return (bool)obj;
            }
            set
            {
                ViewState["RowVisible"] = value;
            }
        }

        private string _accessKey = string.Empty;

        /// <summary>
        /// If you specify an access key, it will be underlined within the text
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Category("Behavior")]
        public string AccessKey
        {
            get { return _accessKey; }
            set
            {
                if (value.Length > 1)
                {
                    throw new ArgumentException("Only a single character is allowed");
                }
                _accessKey = value;
            }
        }

        private string _associatedControlId = string.Empty;

        /// <summary>
        /// If set, the access key will set the focus to associated control
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string AssociatedControlID
        {
            get { return _associatedControlId; }
            set
            {
                _associatedControlId = value;
            }
        }

        [Browsable(true)]
        [DefaultValue(false)]
        [Description("Whether this column should span to the right column as well")]
        public bool Span { get; set; }

        private Control _ctlAssociated;
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (!string.IsNullOrEmpty(this.AssociatedControlID))
            {
                _ctlAssociated = this.Parent.FindControl(this.AssociatedControlID);
                if (_ctlAssociated == null)
                {
                    string str = string.Format("Control {0} cannot be found", this.AssociatedControlID);
                }
            }
        }

        protected override void Render(HtmlTextWriter writer)
        {
            int index;
            if (string.IsNullOrEmpty(this.AccessKey) || _ctlAssociated == null)
            {
                index = -1;
            }
            else
            {
                //if (_ctlAssociated == null)
                //{
                //    throw new InvalidOperationException("If access key is specified, AssociatedControlid must be specified as well");
                //}
                index = this.Text.IndexOf(this.AccessKey);
            }
            if (index == -1)
            {
                writer.Write(this.Text);
            }
            else
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Accesskey, this.AccessKey);
                writer.AddAttribute(HtmlTextWriterAttribute.For, _ctlAssociated.ClientID);
                writer.RenderBeginTag(HtmlTextWriterTag.Label);
                writer.Write(this.Text.Substring(0, index));
                writer.AddStyleAttribute(HtmlTextWriterStyle.TextDecoration, "underline");
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                writer.Write(this.AccessKey);
                writer.RenderEndTag();      // span
                writer.Write(this.Text.Substring(index + 1));
                writer.RenderEndTag();      // label
            }

        }

        protected override void LoadViewState(object savedState)
        {
            if (savedState != null)
            {
                object[] states = (object[])savedState;
                _text = (string)states[0];
                base.LoadViewState(states[1]);
            }
        }

        protected override object SaveViewState()
        {
            object[] states = new object[2];
            states[0] = _text;
            states[1] = base.SaveViewState();
            return states;
        }
    }
}

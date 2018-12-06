using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using EclipseLibrary.Web.Extensions;

namespace EclipseLibrary.Web.JQuery.Input
{
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class RadioItemProxy : Control
    {
        public string CheckedValue
        {
            get
            {
                return _radioItem.Value;
            }
            set
            {
                _radioItem.Value = value;
            }
        }

        public string Text
        {
            get
            {
                return _radioItem.Text;
            }
            set
            {
                _radioItem.Text = value;
            }
        }

        public string ToolTip
        {
            get
            {
                return _radioItem.ToolTip;
            }
            set
            {
                _radioItem.ToolTip = value;
            }
        }

        /// <summary>
        /// Corresponds to the <see cref="RadioItem.FilterDisabled"/> property.
        /// </summary>
        public bool FilterDisabled
        {
            get
            {
                return _radioItem.FilterDisabled;
            }
            set
            {
                _radioItem.FilterDisabled = value;
            }
        }


        public string QueryString { get; set; }


        private RadioButtonListEx _radioList;
        private readonly RadioItem _radioItem;

        public RadioItemProxy()
        {
            _radioItem = new RadioItem() { Proxy = this };
        }

        /// <summary>
        /// Discover our radio button list and add self to that list
        /// </summary>
        /// <param name="e"></param>
        /// <para>
        /// The associated <see cref="RadioButtonListEx"/> must be in the same naming container. 
        /// This makes it possible
        /// to use <see cref="RadioButtonListEx"/> and its associated <see cref="RadioItemProxy"/>
        /// controls within templates of data bound controls.
        /// </para>
        protected override void OnInit(EventArgs e)
        {
            // Exception if you have forgotten to add a RadioButtonListEx with the same QueryString as the RadioButtonItem
            _radioList = this.NamingContainer.Descendants().OfType<RadioButtonListEx>().First(p => p.QueryString == this.QueryString);
            _radioList.Items.Add(_radioItem);
            base.OnInit(e);
        }

        protected override void Render(HtmlTextWriter writer)
        {
            // This hidden field is necessary to force LoadPostData() to fire
            writer.AddAttribute(HtmlTextWriterAttribute.Type, "radio");

            if (_radioList.Value == this.CheckedValue)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Checked, "checked");
            }
            writer.AddAttribute(HtmlTextWriterAttribute.Value, this.CheckedValue);
            writer.AddAttribute(HtmlTextWriterAttribute.Name, _radioList.UniqueID);
            writer.AddAttribute(HtmlTextWriterAttribute.Id, this.ClientID);
            writer.RenderBeginTag(HtmlTextWriterTag.Input);
            writer.RenderEndTag();          // input

            writer.AddAttribute(HtmlTextWriterAttribute.For, this.ClientID);
            if (!string.IsNullOrEmpty(this.ToolTip))
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Title, this.ToolTip);
            }
            writer.RenderBeginTag(HtmlTextWriterTag.Label);
            writer.Write(this.Text);
            writer.RenderEndTag();      // label            
        }
    }
}

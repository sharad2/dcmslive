using System;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using EclipseLibrary.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// 31 Jan 2011: Now being used on Master page of DcmsLive for theme selector
    /// </summary>
    public class DropDownAjax : InputControlBase
    {
        private readonly Collection<DropDownItem> _items;
        private readonly CascadableHelper _cascadable;
        public DropDownAjax()
            : base("dropDownListEx")
        {
            _items = new Collection<DropDownItem>();
            _cascadable = new CascadableHelper();
        }
        #region Cascadable

        /// <summary>
        /// If this control should update its value whenever the value of some other control changes, then you would
        /// need to specify some Cascadable properties.
        /// </summary>
        /// <remarks>
        /// It is virtual so that derived classes can make it Browsable(false) if they do not support cascading
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public CascadableHelper Cascadable
        {
            get
            {
                return _cascadable;
            }
        }
        #endregion

        /// <summary>
        /// A collection of items in this drop down
        /// </summary>
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        public Collection<DropDownItem> Items
        {
            get
            {
                return _items;
            }
        }

        /// <summary>
        /// Name of the hidden field which will post back the selected text
        /// </summary>
        private string HiddenFieldName
        {
            get
            {
                return this.ClientID + "_hf";
            }
        }

        protected override void PreCreateScripts()
        {
            _cascadable.CreateCascadeScripts(this);

            DropDownItem[] persistentItems = this.Items.Where(p => p.Persistent != DropDownPersistenceType.Never).ToArray();
            if (persistentItems.Length > 0)
            {
                this.ClientOptions.Add("persistentItems", persistentItems);
            }
            this.ClientOptions.Add("clientPopulate", true);
            if ((this.UseCookie & CookieUsageType.Write) == CookieUsageType.Write)
            {
                // When filled via AJAX, we store both text and value in cookie
                this.ClientOptions.Add("cookieName", this.QueryString);
                this.ClientOptions.Add("cookieExpiryDays", this.CookieExpiryDays);
            }
        }

        internal override string GetClientCode(ClientCodeType codeType)
        {
            switch (codeType)
            {
                case ClientCodeType.InterestEvent:
                    return "click";

                case ClientCodeType.InputSelector:
                    return this.ClientSelector;

                case ClientCodeType.GetValue:
                    return "function(e) { return $(this).val(); }";

                case ClientCodeType.LoadData:
                    return "function(data) { $(this).dropDownListEx('fill', data); }";

                case ClientCodeType.PreLoadData:
                    return "function(data) { $(this).dropDownListEx('preFill'); }";

                case ClientCodeType.SetCookie:
                    // Store both text and value in cookie
                    string func = string.Format(@"function(e) {{
$(this).{0}('setCookie');
}}", this.WidgetName);
                    return func;

                default:
                    return base.GetClientCode(codeType);
            }

        }

        protected override void Render(HtmlTextWriter writer)
        {

            base.Render(writer);

            // Hidden Field to postback selected text
            writer.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
            writer.AddAttribute(HtmlTextWriterAttribute.Name, this.HiddenFieldName);
            writer.AddAttribute(HtmlTextWriterAttribute.Value, this.DisplayValue);
            writer.RenderBeginTag(HtmlTextWriterTag.Input);
            writer.RenderEndTag();
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            var groups = _items.ToLookup(p => p.OptionGroup);
            string selectedValue = this.Value;      // for efficiency
            var groupCount = groups.Count(p => !string.IsNullOrEmpty(p.Key));
            foreach (var group in groups)
            {
                if (groupCount > 1 && !string.IsNullOrEmpty(group.Key))
                {
                    writer.AddAttribute("label", group.Key);
                    writer.RenderBeginTag("optgroup");
                }
                foreach (var li in group)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Value, li.Value);
                    if (li.Value == selectedValue)
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Selected, "selected");
                    }
                    if (!string.IsNullOrEmpty(li.CssClass))
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, li.CssClass);
                    }
                    writer.RenderBeginTag(HtmlTextWriterTag.Option);
                    writer.Write(li.Text);
                    writer.RenderEndTag();      // option
                }
                if (groupCount > 1 && !string.IsNullOrEmpty(group.Key))
                {
                    writer.RenderEndTag();      // optgroup
                }
            }
        }

        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Select;
            }
        }

        public override string Value
        {
            get;
            set;
        }

        public override bool LoadPostData(string postDataKey, NameValueCollection postCollection)
        {
            string str = postCollection[postDataKey];
            this.Value = str;
            string text = postCollection[HiddenFieldName];
            this.Items.Add(new DropDownItem() { Value = this.Value, Text = text, Persistent = DropDownPersistenceType.Never });

            return false;
        }

        protected override void SetValueFromCookie(string cookieValue)
        {
            // Filled via AJAX. Cookie contains both text and value
            JavaScriptSerializer ser = new JavaScriptSerializer();
            string str = HttpUtility.UrlDecode(cookieValue);
            try
            {
                DropDownItem item = ser.Deserialize<DropDownItem>(str);
                this.Items.Add(item);
                this.Value = item.Value;
            }
            catch (ArgumentException)
            {
                // Garbage cookie. Ignore.
            }

        }

        /// <summary>
        /// Returns text corresponding to the item whose value is <see cref="Value"/>.
        /// </summary>
        public override string DisplayValue
        {
            get
            {
                var item = _items.FirstOrDefault(p => p.Value == this.Value);
                if (item == null || this.FilterDisabled)
                {
                    return string.Empty;
                }
                else
                {
                    return item.Text;
                }
            }
        }
    }
}

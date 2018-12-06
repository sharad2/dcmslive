using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// An item in <see cref="RadioButtonListEx"/>
    /// </summary>
    public class RadioItem
    {
        #region Properties
        /// <summary>
        /// Gets or Sets the text value to be displayed to the user.
        /// </summary>        
        public string Text { get; set; }

        /// <summary>
        /// Gets or Sets the value to be used by the developer.
        /// </summary>
        public string Value { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the control is enabled.
        /// </summary>
        /// <remarks>
        /// Use the Enabled property to specify or determine whether a control is functional. When set to false, the       
        /// control appear dimmed, preventing any input is being entered in the control.
        /// </remarks>
        public bool Enabled { get; set; }

        /// <summary>
        /// Whether this item should be rendered
        /// </summary>
        /// <remarks>
        /// Make sure that at least one radio item remains visible, otherwise undefined behavior will result.
        /// </remarks>
        public bool Visible { get; set; }

        /// <summary>
        /// The RadioItemProxy control, if this item represents a proxy
        /// </summary>
        /// <remarks>
        /// Use this property when you want to render your item apart from RadioButtonList. RadioItemProxy communicates
        /// through QueryString property. 
        /// </remarks>
        [Browsable(false)]
        internal RadioItemProxy Proxy { get; set; }

        /// <summary>
        /// Gets or sets the text displayed when the mouse pointer hovers over the control. 
        /// </summary>
        /// <remarks>
        /// Use when you want to show you custom text for the control.
        /// </remarks>
        public string ToolTip { get; set; }

        /// <summary>
        /// If true, then the list filter is disabled whenever this item is selected
        /// </summary>
        /// <remarks>
        /// <para>
        /// If you set this to true, then the value displays as empty in <see cref="EclipseLibrary.Web.UI.AppliedFilters"/>.
        /// </para>
        /// </remarks>
        public bool FilterDisabled { get; set; }

        /// <summary>
        /// The Css class to apply to this item and its associated label
        /// </summary>
        public string CssClass { get; set; }
        #endregion

        #region Initialization
        /// <summary>
        /// 
        /// </summary>
        public RadioItem()
        {
            this.Enabled = true;
            this.Text = string.Empty;
            this.Value = string.Empty;
            this.Visible = true;
        }
        #endregion
    }

    /// <summary>
    /// Retrievs the collection of items in the control. You can set RadioItem in design time.
    /// </summary>
    /// <remarks>    
    /// <para>
    /// This control avoids receiving focus by setting <see cref="FocusPriority"/> to <c>Low</c> by default.
    /// </para>
    /// <para>
    /// To access the control's value in client script, you must use the <c>val</c> method.
    /// </para>
    /// <code lang="javascript">
    /// <![CDATA[
    ///function ddlVoucherTypes_Change(e) {
    ///    switch ($(this).radioButtonListEx('val')) {
    ///        case 'B':
    ///        case 'C':
    ///            $('#tbPayee').closest('tr').show();
    ///            break;
    ///        case 'J':
    ///            $('#tbPayee').closest('tr').hide();
    ///            break;
    ///    }
    ///}
    /// ]]>
    /// </code>
    /// <para>
    /// There is no property equivalent to the ASP.NET <c>AutoPostBack</c> property since we discourage postbacks.
    /// Nevertheless, if you need the form to auto postback whenever a radio button is clicked, you can easily accomplish
    /// it by submitting the form in the change event handler as demonstrated in this code. You must
    /// click a button, even though it is hidden, instead of posting the form directly to avoid validation problems.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <i:RadioButtonListEx ID="rbProcessType" runat="server" Orientation="Horizontal" SelectedValue="EXP"
    ///     OnClientChange="function(e) { $('#btnGo').click(); }">
    ///     <Items>
    ///         <i:RadioItem Text="Import" Value="IMP" />
    ///         <i:RadioItem Text="Export" Value="EXP" />
    ///     </Items>
    /// </i:RadioButtonListEx>
    /// <i:ButtonEx ID="btnGo" runat="server" Text="Go" Action="Submit"
    ///     ClientIdSameAsId="true" CssClasses="ui-helper-hidden" />
    /// ]]>
    /// </code>
    /// <para>
    /// This is not a data bound control and thus you cannot create <see cref="Items"/> by data binding. However, you can
    /// create the items manually during the <c>OnInit</c> event as shown in this code.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// protected void rblRoles_Init(object sender, EventArgs e)
    /// {
    ///     RadioButtonListEx rblRoles = (RadioButtonListEx)sender;
    ///     foreach (string role in Roles.GetAllRoles())
    ///     {
    ///         rblRoles.Items.Add(new RadioItem() { Text = role, Value = role });
    ///     }
    /// }
    /// ]]>
    /// </code>
    /// <para>
    /// The inherited <see cref="InputControlBase.OnClientChange"/> event can cancel the radio button selection
    /// made by the user.
    /// </para>
    /// <code>
    /// <![CDATA[
    ///    <i:RadioButtonListEx ID="rblPitchingPath" runat="server" SelectedValue="M" OnClientChange="function(e) {
    ///    return confirm("Are you sure?");
    ///    }">
    ///        <Items>
    ///            <i:RadioItem Text="MPC" Value="M" />
    ///            <i:RadioItem Text="Z-Bar" Value="Z" />
    ///            <i:RadioItem Text="Checking Path" Value="C" />
    ///        </Items>
    ///    </i:RadioButtonListEx>
    /// ]]>
    /// </code>
    /// </remarks>
    public class RadioButtonListEx : InputControlBase
    {
        #region Properties

        /// <summary>
        /// Gets or sets the width of each item.
        /// </summary>
        /// <remarks>
        /// <para>
        /// To make each item use the same width, set this property.
        /// This is ignored if <see cref="RepeatDirection"/> is set to vertical since each item takes up a full line.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("")]
        public Unit WidthItem { get; set; }

        /// <summary>
        /// Gets or sets the the look of RadioItems viz. Vertical and Horizontal.
        /// </summary>
        /// <remarks>
        /// Use this property to set the orientation of the Items. You have 2 types of orientations viz. Vertical 
        /// and Horizontal. Set vertical when you want to view all the items in single line and use Horizontal when
        /// you want to view each Item in a single line. Horizontal is set by default.
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(RepeatDirection.Horizontal)]
        public RepeatDirection Orientation { get; set; }

        /// <summary>
        /// Gets or Sets the item selected by the user for the RadioButton control. 
        /// </summary>
        /// <remarks>
        /// Use this property when you want to access the value and text of the RadioButton item.
        /// SelectedItem will give you the Value and Text of the item.
        /// </remarks>
        [Browsable(false)]
        public RadioItem SelectedItem
        {
            get
            {
                return _items.Cast<RadioItem>().FirstOrDefault(p => p.Visible && p.Value == this.Value);
            }
        }

        /// <summary>
        /// Gets the item collection for thwe RadioButton control.
        /// </summary>
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        public Collection<RadioItem> Items
        {
            get
            {
                return _items;
            }
        }

        //public override bool LoadPostData(string postDataKey, System.Collections.Specialized.NameValueCollection postCollection)
        //{
        //    this.Value = postCollection[postDataKey];
        //    return false;
        //}

        /// <summary>
        /// Gets or Sets the value to be used by developer.
        /// </summary>
        [Browsable(true)]
        public override string Value
        {
            get;
            set;
        }

        /// <summary>
        /// Returns DIV
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Div;
            }
        }

        /// <summary>
        /// Gets or Sets the text value to be dsipalayed to the end user.
        /// </summary>
        public override string DisplayValue
        {
            get
            {
                RadioItem item = this.SelectedItem;
                if (item == null)
                {
                    return string.Empty;
                }
                else
                {
                    return item.Text;
                }
            }
        }

        /// <summary>
        /// If the selected item has filter disabled property set to true, then we are disabled as well.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Note that when this property set to true and you are using that value in your Control parameter, this
        /// will not reflect in your query as you set FilterDisabled property to true.
        /// </para>
        /// <para>
        /// If there is no selected item, then we do not check the FilterDisabled
        /// property of any item.
        /// </para>
        /// </remarks>
        public override bool FilterDisabled
        {
            get
            {
                if (base.FilterDisabled)
                {
                    return true;
                }
                if (this.SelectedItem == null)
                {
                    return false;
                }
                else
                {
#pragma warning disable 618
                    return this.SelectedItem.FilterDisabled;
#pragma warning restore
                }
            }
        }
        #endregion

        #region Initialization
        private readonly Collection<RadioItem> _items;

        /// <summary>
        /// 
        /// </summary>
        public RadioButtonListEx()
            : base("radioButtonListEx")
        {
            _items = new Collection<RadioItem>();
            // Selecting by default empty value
            this.Value = string.Empty;
            this.FocusPriority = FocusPriority.Low;
        }
        #endregion

        #region Scripts

        /// <summary>
        /// Called before the base class creates the ready scripts. If we are a date, we set the date picker options here.
        /// </summary>
        protected override void PreCreateScripts()
        {
            base.PreCreateScripts();
            this.ClientOptions.Add("groupName", this.UniqueID);
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.RadioButtonListEx);
        }

        /// <summary>
        /// Returns javascript code needed by the validation framework.
        /// </summary>
        /// <param name="codeType"></param>
        /// <returns></returns>
        internal override string GetClientCode(ClientCodeType codeType)
        {
            switch (codeType)
            {
                case ClientCodeType.SetValue:
                    return "function(val) { $(this).radioButtonListEx('setValue', val); }";

                case ClientCodeType.GetValue:
                    return "function() { return $(this).radioButtonListEx('val'); }";

                case ClientCodeType.InterestEvent:
                    return "change";

                case ClientCodeType.InputSelector:
                    RadioItem item = this.Items.FirstOrDefault(p => p.Proxy == null);
                    if (item == null)
                    {
                        // Selector of the proxy
                        return this.Items.Where(p => p.Proxy != null)
                            .Select(p => string.Format("#{0}", p.Proxy.ClientID))
                            .First();
                    }
                    else
                    {
                        // First radio within us
                        return string.Format("{0} input:radio:first", this.ClientSelector);
                    }

                default:
                    return base.GetClientCode(codeType);
            }
        }

        #endregion

        #region Rendering
        /// <summary>
        /// Remove the Name attribute which the base would have added
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            base.AddAttributesToRender(attributes, cssClasses);

            attributes.Remove(HtmlTextWriterAttribute.Name);
        }

        protected override void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            styles.Add(HtmlTextWriterStyle.Display, "inline-block");
            base.AddStylesToRender(styles, stylesSpecial);
        }

        /// <summary>
        /// If there is no selected item, we show the first one as selected
        /// </summary>
        /// <param name="writer"></param>
        /// <remarks>
        /// <para>
        /// Sharad 30 Nov 2010: No default width is applied to individual items.
        /// </para>
        /// </remarks>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            int i = 0;
            string selectedValue;
            if (this.SelectedItem == null && this.Items.Any(p => p.Visible))
            {
                selectedValue = this.Items.First(p => p.Visible).Value;
            }
            else
            {
                selectedValue = this.Value;
            }
            foreach (RadioItem item in _items.Where(p => p.Proxy == null && p.Visible))
            {
                switch (this.Orientation)
                {
                    case RepeatDirection.Horizontal:
                        if (!this.WidthItem.IsEmpty)
                        {
                            writer.AddStyleAttribute(HtmlTextWriterStyle.Width, this.Width.ToString());
                            writer.AddStyleAttribute(HtmlTextWriterStyle.Display, "inline-block");
                        }
                        break;

                    case RepeatDirection.Vertical:
                        writer.AddStyleAttribute(HtmlTextWriterStyle.Display, "block");
                        break;
                    default:
                        throw new NotImplementedException();
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                string clientId = string.Format("{0}_{1}", this.ClientID, i);
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "radio");
                if (item.Value == selectedValue)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Checked, "checked");
                }
                writer.AddAttribute(HtmlTextWriterAttribute.Name, this.UniqueID);
                if (!this.IsEnabled || !item.Enabled)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Disabled, "true");
                }

                writer.AddAttribute(HtmlTextWriterAttribute.Value, item.Value);
                writer.AddAttribute(HtmlTextWriterAttribute.Id, clientId);
                if (!string.IsNullOrEmpty(item.CssClass))
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, item.CssClass);
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Input);
                writer.RenderEndTag();

                writer.AddAttribute(HtmlTextWriterAttribute.For, clientId);
                if (!string.IsNullOrEmpty(item.ToolTip))
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Title, item.ToolTip);
                }
                if (!string.IsNullOrEmpty(item.CssClass))
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, item.CssClass);
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Label);
                writer.Write(item.Text);
                writer.RenderEndTag();      // label
                writer.RenderEndTag();      // span
                ++i;
            }
        }
        #endregion
    }
}

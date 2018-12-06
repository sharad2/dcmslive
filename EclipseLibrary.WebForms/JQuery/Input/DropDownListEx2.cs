using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using EclipseLibrary.Oracle.Helpers.XPath;
using EclipseLibrary.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    public enum DropDownSingleItemAction
    {
        /// <summary>
        /// Display normally
        /// </summary>
        Normal,

        /// <summary>
        /// Display as a span
        /// </summary>
        AsLabel,

        /// <summary>
        /// The control is not rendered at all
        /// </summary>
        NotRendered,

        /// <summary>
        /// The control is rendered as a hidden field which has the same client Id.
        /// You can access the value through client script.
        /// </summary>
        ClientHidden

    }
    /// <summary>
    /// Similar to ASP DropDownList. Adds support for option groups and JQuery validation
    /// </summary>
    /// <remarks>
    /// <para>
    /// You can add items statically using the <see cref="Items"/> property. You can also add items
    /// via data binding. Specify <see cref="DataSourceID"/> as well as <see cref="DataFields"/>
    /// Data binding will happen automatically. Alternatively you can
    /// specify <see cref="DataSource"/> and call <see cref="DataBind"/> manually. <see cref="DataValueFormatString"/>,
    /// <see cref="DataTextFormatString"/>, <see cref="DataOptionGroupFormatString"/> are used to compute the value,
    /// text and option group respectively.
    /// </para>
    /// <para>
    /// You specify the initial value to select using the <see cref="Value"/> property. This can be
    /// done at any time, even before items have been added to the list. If the 
    /// <c>SelectedValue</c> does not exist in list of items, the first item will be selected.
    /// </para>
    /// <para>
    /// If you would like to derive a class which is responsible for filling its own items, then the recommended pattern
    /// is to override PerformDataBinding() and add the items you need. Do NOT call the base PerformDataBinding().
    /// In your OnPreRender() override, call EnsureDataBound().
    /// </para>
    /// <para>
    /// Normally, you will let the framework update the cookie value by setting <see cref="InputControlBase.UseCookie"/> to <c>WriteOnChange</c>.
    /// To manually set the value of the cookie, call <c>$('#ddl').dropdownListEx('setCookie')</c>.
    /// </para>
    /// <para>
    /// Sharad 5 Jan 2010: If there is only a single entry in the list, it displays as a label.
    /// </para>
    /// <para>
    /// Sharad 17 Aug 2010: Not generating hidden field if web method not specified
    /// </para>
    /// <para>
    /// Sharad 13 Sep 2010: When <see cref="CascadableHelper.WebMethod"/> specified, both text and value are stored in the cookie.
    /// </para>
    /// <para>
    /// Sharad 22 Sep 2010: Added property CssClass to <see cref="DropDownItem"/>.
    /// </para>
    /// <para>
    /// Sharad 26 Nov 2010: New Property <see cref="SingleItemAction"/>
    /// </para>
    /// </remarks>
    /// <example>
    /// <code>
    /// <![CDATA[
    ///<o:OracleDataSource runat="server" ID="dsLabel" ConnectionString="<%$ ConnectionStrings:dcms8 %>"
    ///    ProviderName="<%$ ConnectionStrings:dcms8.ProviderName %>"
    ///    SelectCommand="Select tabLabel.label_id, tabLabel.description from tab_style_label tabLabel order by tabLabel.description" />
    ///<i:DropDownListEx ID="ddlLabel" ToolTip="Label" runat="server" DataTextField="description"
    ///    DataValueField="label_id" DataSourceID="dsLabel" AppendDataBoundItems="True">
    ///    <Items>
    ///        <eclipse:DropDownItem Value="" Text="(All Labels)" />
    ///    </Items>
    ///</i:DropDownListEx>
    /// ]]>
    /// </code>
    /// </example>
    public class DropDownListEx2 : InputControlBase
    {
        private readonly Collection<DropDownItem> _items;

        /// <summary>
        /// 
        /// </summary>
        public DropDownListEx2()
            : base(string.Empty)
        {
            _items = new Collection<DropDownItem>();
            this.DataTextFormatString = "{0}";
// ReSharper disable DoNotCallOverridableMethodsInConstructor
            this.Value = string.Empty;
// ReSharper restore DoNotCallOverridableMethodsInConstructor
            this.DataValueFormatString = "{0}";
            this.SingleItemAction = DropDownSingleItemAction.AsLabel;
        }

        /// <summary>
        /// Format string to use for generating the option group of each item.
        /// </summary>
        /// <remarks>
        /// <para>
        /// You can specify format string for the field specified in the <see cref="DataFields"/>,
        /// and eventually it gets shown under HTML OPTGROUP tag.
        /// </para>
        /// </remarks>
        /// <example>
        ///     <para>
        ///     Following example checks the value <c>"Y"</c> in <c>Is_Pallet_Required</c> field, (which 
        ///     is specified in <see cref="DataFields"/>) and shows <c>"Pallet Areas"</c> or else
        ///     for the values other than <c>"Y"</c>, <c>"Non Pallet Areas"</c> will be shown.
        ///     </para>
        ///     <code>
        ///         <![CDATA[
        ///         <i:DropDownListEx ID="ddlDestinationArea" runat="server" DataSourceID="dsDestinationArea"
        ///             FriendlyName="Destination Area" ClientIDMode="Static" DataFields="Inventory_Storage_Area,description,Is_Pallet_Required"
        ///             DataValueFormatString="{0}" DataTextFormatString="{0}: {1}"
        ///             DataOptionGroupFormatString="{3::$Is_Pallet_Required = 'Y':Pallet Areas:Non Pallet Areas}">
        ///         </i:DropDownListEx>
        ///         ]]>
        ///     </code>
        /// </example>
        [Browsable(true)]
        [DefaultValue("{0}")]
        public string DataOptionGroupFormatString { get; set; }
        //#region Cascadable

        //private CascadableHelper _cascadable;

        ///// <summary>
        ///// If this control should update its value whenever the value of some other control changes, then you would
        ///// need to specify some Cascadable properties.
        ///// </summary>
        ///// <remarks>
        ///// It is virtual so that derived classes can make it Browsable(false) if they do not support cascading
        ///// </remarks>
        //[Browsable(true)]
        //[PersistenceMode(PersistenceMode.InnerProperty)]
        //public CascadableHelper Cascadable
        //{
        //    get { return _cascadable ?? (_cascadable = new CascadableHelper()); }
        //}
        //#endregion

        #region DataBinding

        /// <summary>
        /// The field from which item text will be read.
        /// </summary>
        /// <remarks>
        /// <para>
        /// It is permissible to leave this blank. If this has not been specified, then the
        /// <c>ToString()</c> of the data item is used as <see cref="DropDownItem.Text"/>.
        /// This is useful if you are binding to
        /// an array of strings.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string DataFields { get; set; }

        /// <summary>
        /// {0} refers to DataTextField, {1} refers to DataValueField, {2} refers to DataOptionGroupField
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is useful when you want to include the value as part of the text which displays.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("{0}")]
        public string DataTextFormatString { get; set; }

        /// <summary>
        /// The field from which item value will be read.
        /// </summary>
        /// <remarks>
        /// <para>
        /// It is permissible to leave this blank. If this has not been specified, then the
        /// <c>ToString()</c> of the data item is used as <see cref="DropDownItem.Value"/>. This is useful if you are binding to
        /// an array of strings.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("{0}")]
        public string DataValueFormatString { get; set; }

        [Browsable(true)]
        [DefaultValue("")]
        public string DataCssClassFormatString { get; set; }

        /// <summary>
        /// How should the control display when the list contains only a single item
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property controls the appearance of the drop down if only a single item remains after data binding.
        /// You can display as a label, as a hidden field, or not render it at all. This value is ignored
        /// if <see cref="CascadableHelper.WebMethod"/> has been specified since the list will bind on the client side.
        /// The <see cref="AssociatedControlID"/> is hidden along with it.
        /// </para>
        /// <para>
        /// <see cref="Visible"/> returns false when this is set to <see cref="DropDownSingleItemAction.NotRendered"/>.
        /// <see cref="TagKey"/> returns select, input or span depending on the value.
        /// <see cref="AddAttributesToRender"/> adds <c>type="hidden"</c> attribute to make this a hidden field.
        /// <see cref="RenderContents"/> renders just the item text for the span. <see cref="OnPreRender"/> removes all
        /// validators.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(DropDownSingleItemAction.AsLabel)]
        [Themeable(false)]
        public DropDownSingleItemAction SingleItemAction { get; set; }

        /// <summary>
        /// This is hidden along with the drop down if demanded by <see cref="SingleItemAction"/> property.
        /// </summary>
        [Browsable(true)]
        [IDReferenceProperty]
        [DefaultValue("")]
        public string AssociatedControlID { get; set; }

        /// <summary>
        /// The ID of the data source to use for data binding.
        /// </summary>
        /// <remarks>
        /// <para>
        /// You do not need to manually call <see cref="DataBind"/>. It will be called automatically.
        /// </para>
        /// <para>
        /// The data source is first searched for within the same naming container as this drop down list. If it is not
        /// found there, then each parent naming container is searched until the source is found.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [IDReferenceProperty(typeof(DataSourceControl))]
        public string DataSourceID { get; set; }

        /// <summary>
        /// Use this if you want to call DataBind yourself.
        /// </summary>
        [Browsable(false)]
        public object DataSource { get; set; }

        private bool _requiresDataBinding = true;

        /// <summary>
        /// Set to true just before DataBind() is called from within PreRender. Then set to false.
        /// </summary>
        private bool _inPreRender;

        /// <summary>
        /// Calls <see cref="DataBind"/> if it has not been called already.
        /// </summary>
        /// <param name="inPreRender">true if you are calling this function from within OnPrender</param>
        protected void EnsureDataBound(bool inPreRender)
        {
            if (_requiresDataBinding)
            {
                if (inPreRender)
                {
                    _inPreRender = true;
                }
                DataBind();
                if (inPreRender)
                {
                    _inPreRender = false;
                }

            }
        }

        public event EventHandler DataBound;

        /// <summary>
        /// When resolving the data source, the data source identified by the DataSourceID property takes precedence.
        /// If DataSourceID is not set, the object identified by the DataSource property is used.
        /// </summary>
        public override void DataBind()
        {

            // Save potentially persisten items for later use
            var query = _items.Where(p => p.Persistent == DropDownPersistenceType.Always || p.Persistent == DropDownPersistenceType.WhenEmpty)
                .ToList();
            _items.Clear();
            query.ForEach(item => _items.Add(item));

            if (!_inPreRender)
            {
                OnDataBinding(EventArgs.Empty);
            }

            int preCount = _items.Count;
            PerformDataBinding();

            // Sharad 2 Aug 2010: Added code to handle the WhenEmpty case
            if (_items.Count > preCount)
            {
                // We added some items. Remove the WhenEmpty items
                var toRemove = _items.Where(p => p.Persistent == DropDownPersistenceType.WhenEmpty).ToArray();
                foreach (var item in toRemove)
                {
                    _items.Remove(item);
                }
            }

            _requiresDataBinding = false;

            if (_items.Count == 1 && !string.IsNullOrEmpty(this.AssociatedControlID))
            {
                switch (this.SingleItemAction)
                {
                    case DropDownSingleItemAction.Normal:
                    case DropDownSingleItemAction.AsLabel:
                        break;

                    case DropDownSingleItemAction.NotRendered:
                        // Exception here if associated control not found
                        this.NamingContainer.FindControl(this.AssociatedControlID).Visible = false;
                        break;

                    case DropDownSingleItemAction.ClientHidden:
                        // Generate script to hide on document ready
                        Control ctl = this.NamingContainer.FindControl(this.AssociatedControlID);
                        string script = string.Format("$('#{0}').hide();", ctl.ClientID);
                        JQueryScriptManager.Current.RegisterReadyScript(script);
                        break;

                    default:
                        break;
                }
            }
            OnDataBound(EventArgs.Empty);
        }

        protected virtual void OnDataBound(EventArgs e)
        {
            if (this.DataBound != null)
            {
                this.DataBound(this, e);
            }
        }

        private IEnumerable PerformSelect()
        {
            IEnumerable data;
            if (!string.IsNullOrEmpty(this.DataSourceID))
            {
                IDataSource ds = (IDataSource)this.NamingContainer.FindControl(this.DataSourceID) ??
                                 (IDataSource)this.NamingContainer.NamingContainer.FindControl(this.DataSourceID);
                data = null;
                ds.GetView(string.Empty).Select(DataSourceSelectArguments.Empty, delegate(IEnumerable data1)
                {
                    data = data1;
                });
            }
            else if (this.DataSource == null)
            {
                data = null;
            }
            else if (this.DataSource is IEnumerable)
            {
                data = (IEnumerable)this.DataSource;
            }
            else if (this.DataSource is IDataSource)
            {
                IDataSource ds = (IDataSource)this.DataSource;
                data = null;
                ds.GetView(string.Empty).Select(DataSourceSelectArguments.Empty, delegate(IEnumerable data1)
                {
                    data = data1;
                });
            }
            else
            {
                throw new NotSupportedException();
            }
            return data;
        }

        /// <summary>
        /// Add <see cref="Items"/> from the data source. Derived classes should override this to add items
        /// from their custom data source.
        /// </summary>
        protected virtual void PerformDataBinding()
        {
            IEnumerable data = PerformSelect();
            if (data == null)
            {
                // Do nothing. This happens when no data source has been assigned to us
                return;
            }

            //Dictionary<string, object> dict;
            ConditionalFormatter formatter = new ConditionalFormatter(null);
            foreach (object dataItem in data)
            {
                DropDownItem item = new DropDownItem();
                if (string.IsNullOrEmpty(this.DataFields))
                {
                    item.CustomData = new Dictionary<string, object> {{"", dataItem.ToString()}};
                }
                else
                {
                    item.CustomData = this.DataFields.Split(',').Select(p => new
                    {
                        Field = p,
                        Value = DataBinder.Eval(dataItem, p)
                    }).ToDictionary(p => p.Field, q => (q.Value == DBNull.Value ? null : q.Value));
                }
                formatter.Callback = p => item.CustomData[p];
                object[] fieldValues = item.CustomData.Values.ToArray();
                item.Value = string.Format(formatter, this.DataValueFormatString, fieldValues);
                item.Text = string.Format(formatter, this.DataTextFormatString, fieldValues);
                if (!string.IsNullOrEmpty(this.DataOptionGroupFormatString))
                {
                    item.OptionGroup = string.Format(formatter, this.DataOptionGroupFormatString, fieldValues);
                }
                if (!string.IsNullOrEmpty(this.DataCssClassFormatString))
                {
                    item.CssClass = string.Format(formatter, this.DataCssClassFormatString, fieldValues);
                }
                _items.Add(item);
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
        /// Selection in the drop down list.
        /// </summary>
        /// <remarks>
        /// <para>
        /// After postback, this is the value selected
        /// by the user. It can be specified at any time, even before data binding.
        /// </para>
        /// <para>
        /// After the control has been data bound, this must
        /// match the value of one of items. If this is not the case, this
        /// is updated to be the same as the value of the first item.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public override string Value
        {
            get;
            set;
        }

        #region Rendering

        /// <summary>
        /// Data bind if necessary
        /// </summary>
        /// <param name="e"></param>
        /// <exception cref="NotImplementedException"></exception>
        protected override void OnPreRender(EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.DataSourceID))
            {
                EnsureDataBound(true);
            }

            switch (this.SingleItemAction)
            {
                case DropDownSingleItemAction.Normal:
                    break;
                case DropDownSingleItemAction.AsLabel:
                case DropDownSingleItemAction.ClientHidden:
                    // Remove all validators if the there are only one item.
                    if (_items.Count == 1)
                    {
                        this.Validators.Clear();
                    }
                    break;

                case DropDownSingleItemAction.NotRendered:
                    throw new HttpException("We should not get here because we are not visible");

                default:
                    throw new NotImplementedException();
            }

            base.OnPreRender(e);
        }

        public override bool Visible
        {
            get
            {
                if (this.SingleItemAction == DropDownSingleItemAction.NotRendered && _items.Count == 1)
                {
                    return false;
                }
                return base.Visible;
            }
            set
            {
                base.Visible = value;
            }
        }
        /// <summary>
        /// The tag which will enclose this control
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                if (_items.Count == 1)
                {
                    switch (this.SingleItemAction)
                    {
                        case DropDownSingleItemAction.Normal:
                            return HtmlTextWriterTag.Select;

                        case DropDownSingleItemAction.NotRendered:
                            throw new HttpException("Since we are not visible, we should not have got here");

                        case DropDownSingleItemAction.AsLabel:
                        case DropDownSingleItemAction.ClientHidden:
                            // Input field
                            return HtmlTextWriterTag.Input;

                        default:
                            throw new NotImplementedException();
                    }
                }
                else
                {
                    return HtmlTextWriterTag.Select;
                }

            }
        }

        /// <summary>
        /// If there is a single value in the list, and we are not cascadable, displays as label
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            if (this.Validators.OfType<Required>().Any(p => p.DependsOnState == DependsOnState.NotSet) && this.IsEnabled)
            {
                writer.AddStyleAttribute(HtmlTextWriterStyle.WhiteSpace, "nowrap");
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
            }
            base.Render(writer);
            if (this.Validators.OfType<Required>().Any(p => p.DependsOnState == DependsOnState.NotSet) && this.IsEnabled)
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Sup);
                writer.Write("*");
                writer.RenderEndTag();  // sup
                writer.RenderEndTag();  // span
            }
            //if (!string.IsNullOrEmpty(this.Cascadable.WebMethod))
            //{
            //    // Hidden Field to postback selected text
            //    writer.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
            //    writer.AddAttribute(HtmlTextWriterAttribute.Name, this.HiddenFieldName);
            //    writer.AddAttribute(HtmlTextWriterAttribute.Value, this.DisplayValue);
            //    writer.RenderBeginTag(HtmlTextWriterTag.Input);
            //    writer.RenderEndTag();
            //}
        }

        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            if (_items.Count == 1)
            {
                switch (this.SingleItemAction)
                {
                    case DropDownSingleItemAction.Normal:
                        break;
                    case DropDownSingleItemAction.AsLabel:
                        attributes.Add(HtmlTextWriterAttribute.ReadOnly, "readonly");
                        attributes.Add(HtmlTextWriterAttribute.Value, _items[0].Value);
                        break;

                    case DropDownSingleItemAction.NotRendered:
                        throw new HttpException("We should not get here since we are not visible");

                    case DropDownSingleItemAction.ClientHidden:
                        // Rendering hidden field
                        attributes.Add(HtmlTextWriterAttribute.Type, "hidden");
                        attributes.Add(HtmlTextWriterAttribute.Value, _items[0].Value);
                        break;

                    default:
                        throw new NotImplementedException();
                }
            }
            base.AddAttributesToRender(attributes, cssClasses);
        }

        protected override void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            if (_items.Count == 1)
            {
                switch (SingleItemAction)
                {
                    default:
                        break;
                    case DropDownSingleItemAction.AsLabel:
                        styles.Add(HtmlTextWriterStyle.BorderWidth, "0");
                        break;   
                }
                
            }
            base.AddStylesToRender(styles, stylesSpecial);
        }
        /// <summary>
        /// Render each item as an OPTION tag
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            if (_items.Count == 1)
            {
                switch (this.SingleItemAction)
                {
                    case DropDownSingleItemAction.Normal:
                        break;

                    case DropDownSingleItemAction.NotRendered:
                        throw new HttpException(" should not get here since we are not visible");

                    case DropDownSingleItemAction.AsLabel:
                    case DropDownSingleItemAction.ClientHidden:
                        // Do not render any items
                        return;

                    default:
                        throw new NotImplementedException();
                }
            }
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

        #endregion

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

                //case ClientCodeType.LoadData:
                //    return "function(data) { $(this).dropDownListEx('fill', data); }";

                //case ClientCodeType.PreLoadData:
                //    return "function(data) { $(this).dropDownListEx('preFill'); }";

//                case ClientCodeType.SetCookie:
//                    if (string.IsNullOrEmpty(this.Cascadable.WebMethod))
//                    {
//                        // Base class will do fine
//                        return base.GetClientCode(codeType);
//                    }
//                    // Store both text and value in cookie
//                    string func = string.Format(@"function(e) {{
//$(this).{0}('setCookie');
//}}", this.WidgetName);
//                    return func;

                default:
                    return base.GetClientCode(codeType);
            }

        }

        /// <summary>
        /// Returns text corresponding to the item whose value is <see cref="Value"/>.
        /// </summary>
        public override string DisplayValue
        {
            get
            {
                EnsureDataBound(false);
                var item = _items.FirstOrDefault(p => p.Value == this.Value);
                if (item == null)
                {
                    return string.Empty;
                }
                return item.Text;
            }
        }

        ///// <summary>
        ///// Name of the hidden field which will post back the selected text
        ///// </summary>
        //private string HiddenFieldName
        //{
        //    get
        //    {
        //        return this.ClientID + "_hf";
        //    }
        //}
        /// <summary>
        /// Accesses the posted value from <paramref name="postCollection"/> using <paramref name="postDataKey"/>
        /// and sets it as the <see cref="Value"/>
        /// </summary>
        /// <param name="postDataKey"></param>
        /// <param name="postCollection"></param>
        /// <returns></returns>
        public override bool LoadPostData(string postDataKey, NameValueCollection postCollection)
        {
            string str = postCollection[postDataKey];
            this.Value = str;
            //if (!string.IsNullOrEmpty(this.Cascadable.WebMethod))
            //{
            //    string text = postCollection[HiddenFieldName];
            //    this.Items.Add(new DropDownItem { Value = this.Value, Text = text, Persistent = DropDownPersistenceType.Never });
            //}
            return false;
        }

        //protected override void PreCreateScripts()
        //{
        //    //if (_items.Count == 1)
        //    //{
        //    //    // See whether we need to handle the special case
        //    //    switch (this.SingleItemAction)
        //    //    {
        //    //        case DropDownSingleItemAction.Normal:
        //    //            break;

        //    //        case DropDownSingleItemAction.AsLabel:
        //    //        case DropDownSingleItemAction.NotRendered:
        //    //        case DropDownSingleItemAction.ClientHidden:
        //    //            // Scripts not needed
        //    //            this.WidgetName = string.Empty;
        //    //            return;

        //    //        default:
        //    //            throw new NotImplementedException();
        //    //    }
        //    //}

        //    //if (_cascadable != null)
        //    //{
        //    //    _cascadable.CreateCascadeScripts(this);
        //    //}

        //    //if (string.IsNullOrEmpty(this.Cascadable.WebMethod))
        //    //{
        //        // Scripts not needed
        //        //this.WidgetName = string.Empty;
        //    //}
        //    //else
        //    //{
        //    //    DropDownItem[] persistentItems = this.Items.Where(p => p.Persistent != DropDownPersistenceType.Never).ToArray();
        //    //    if (persistentItems.Length > 0)
        //    //    {
        //    //        this.ClientOptions.Add("persistentItems", persistentItems);
        //    //    }
        //    //    this.ClientOptions.Add("clientPopulate", true);
        //    //    if ((this.UseCookie & CookieUsageType.Write) == CookieUsageType.Write)
        //    //    {
        //    //        // When filled via AJAX, we store both text and value in cookie
        //    //        this.ClientOptions.Add("cookieName", this.QueryString);
        //    //        this.ClientOptions.Add("cookieExpiryDays", this.CookieExpiryDays);
        //    //    }
        //    //}

        //    base.PreCreateScripts();
        //}

        //protected override void SetValueFromCookie(string cookieValue)
        //{
        //    //if (string.IsNullOrEmpty(this.Cascadable.WebMethod))
        //    //{
        //        // Normal drop down. Cookie contains just the value
        //        this.Value = cookieValue;
        //    //}
        //    //else
        //    //{
        //    //    // Filled via AJAX. Cookie contains both text and value
        //    //    JavaScriptSerializer ser = new JavaScriptSerializer();
        //    //    string str = HttpUtility.UrlDecode(cookieValue);
        //    //    try
        //    //    {
        //    //        DropDownItem item = ser.Deserialize<DropDownItem>(str);
        //    //        this.Items.Add(item);
        //    //        this.Value = item.Value;
        //    //    }
        //    //    catch (ArgumentException)
        //    //    {
        //    //        // Garbage cookie. Ignore.
        //    //    }
        //    //}
        //}
    }
}

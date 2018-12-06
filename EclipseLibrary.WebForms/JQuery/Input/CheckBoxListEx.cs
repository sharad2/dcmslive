using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// The CheckBoxList control provides a multi selection check box group that can be
    /// dynamically generated with data binding. It contains an CheckBoxItem collection with members
    /// corresponding to individual items in the list. To determine which items are checked,
    /// iterate through the collection and test the Selected property of each item in the list.
    /// </summary>
    /// <remarks>
    /// 
    /// </remarks>
    public class CheckBoxItem
    {

        #region Properties
        /// <summary>      
        /// Get and Sets text value to be displayed to the user.  
        /// </summary>
        /// <remarks>
        /// The Text property is commonly use to determine the text of selected 
        /// CheckBoxItem in checkBoxList and the Text you specify at design time.
        /// </remarks>
        public string Text { get; set; }
        /// <summary>
        /// Get and Sets the value to use by the developer.
        /// </summary>
        /// <remarks>
        /// The value property are commonly use to detemine the value of selected
        /// CheckBoxItem and the values you specify at design time.
        /// </remarks>
        public string Value { get; set; }
        /// <summary>
        /// Get and set the  valus of selected item in the list of item.
        /// </summary>
        /// <remarks>
        ///The Selected property is commonly used to determine the
        ///value of the selected item in the ListControl control.
        ///If no item is selected, an empty string ("") is returned.
        /// </remarks>
        public bool Selected { get; set; }
        /// <summary>       
        /// Gets or sets a value indicating whether the CheckBoxListEx is enabled
        /// </summary>
        /// <remarks>
        /// Use the Enabled property to specify or determine whether a control is functional.
        /// When set to false, the control appears dimmed, preventing any input from being entered
        /// in the control
        /// </remarks>
        public bool Enabled { get; set; }
        #endregion

        #region Initilzation
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxItem()
        {
            this.Text = this.Value = string.Empty;
            this.Enabled = true;
        }
        #endregion
    }
    /// <summary>
    /// Similar to ASP CheckBoxList. Adds support for option group and JQuery Validation. The CheckBoxList control provieds a
    /// multi selection check group that can be dyanmically generated with the data binding.To determine which items are checked,
    /// iterate through the collection and test the DataSelectedField property of CheckBoxList.
    /// </summary>
    /// <example>
    /// <![CDATA[
    /// <oracle:OracleDataSource runat="server" ID="dsCustomerTypes" ConnectionString="<%$ ConnectionStrings:dcms4 %>"
    ///           ProviderName="<%$ ConnectionStrings:dcms4.ProviderName %>" 
    ///           SelectCommand=" select tct.customer_type, tct.description, tct.subgroup_flag from tab_customer_type tct order
    ///           by tct.description" />
    /// <i:CheckBoxListEx runat="server" ID="cblCustomerTypes" DataSourceID="dsCustomerTypes"
    ///           DataTextField="description" DataValueField="customer_type" DataSelectedField="subgroup_flag"
    ///           DataCheckedValue="Y" ClientIdSameAsId="true" QueryString="customer_types">   
    /// </i:CheckBoxListEx>
    /// ]]>
    ///</example>    
    public sealed class CheckBoxListEx : InputControlBase
    {

        #region Propreties
        /// <summary>
        ///Gets or set the field from database
        /// </summary>
        /// <remarks>The values selected from the database are added to the values you specify at design time</remarks> 
        [Browsable(true)]
        public string DataSelectedField { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string DataCheckedValue { get; set; }
        /// <summary>
        /// Gets or sets the field of the data source that provides the text content of the list items.
        /// </summary>
        /// <remarks>Use this property to specify a field in the DataSource property to display as the items of the list in a list control.
        ///</remarks>
        [Browsable(true)]
        public string DataTextField { get; set; }

        /// <summary>
        /// Gets or sets the field of the data source that provides the value of each list item
        /// </summary>
        /// <remarks>Use this property to specify the field that contains the value of each item in a list control.
        ///</remarks>
        [Browsable(true)]
        public string DataValueField { get; set; }
        /// <summary>
        /// Gets or sets the ID of the control from which the data-bound control retrieves its list of data items. 
        /// </summary>
        /// <remarks>The ID of a control that represents the data source from which the data-bound control retrieves its data.
        ///</remarks>
        [Browsable(true)]
        [IDReferenceProperty(typeof(DataSourceControl))]
        public string DataSourceID { get; set; }
        /// <summary>
        /// Gets or sets the object from which the data-bound control retrieves its list of data items
        /// </summary>      
        /// <remarks>An object that represents the data source from which the data-bound control
        /// retrieves its data.  
        /// </remarks>
        public object DataSource { get; set; }
        /// <summary>
        /// The width of each item in the list. Defaults to x em where x is the max characters in item text
        /// </summary>      
        [Browsable(true)]
        public Unit WidthItem { get; set; }
        /// <summary>
        /// 
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Fieldset;
            }
        }
        #endregion

        #region Initialization
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxListEx()
            : base("checkBoxListEx")
        {
            _items = new Collection<CheckBoxItem>();
        }

        private readonly Collection<CheckBoxItem> _items;
        /// <summary>
        /// 
        /// </summary>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public Collection<CheckBoxItem> Items
        {
            get
            {
                return _items;
            }

        }
        /// <summary>
        /// Returns first selected item in the list. If there are no items then returns empty string.
        /// </summary>
        /// <remarks>
        ///The SelectedValue property is commonly used to determine the
        ///value of the selected item in the ListControl control.
        ///If no item is selected, an empty string ("") is returned.
        /// </remarks>
        public string SelectedValue
        {

            get
            {
                if (_selectedValues != null)
                {

                    return _selectedValues.FirstOrDefault();
                }
                return string.Empty;
            }
        }

        private string[] _selectedValues;

        /// <summary>
        /// Will return empty array if there are no selected values.
        /// </summary>
        /// <remarks>
        /// The SelectedValues property return list of array if
        /// no item is selected an empty string is returned.
        /// </remarks>
        [Browsable(true)]
        [TypeConverter(typeof(StringArrayConverter))]
        public string[] SelectedValues
        {
            get { return _selectedValues ?? (_selectedValues = new string[0]); }
            set
            {
                _selectedValues = value;
                foreach (var item in this._items)
                {
                    item.Selected = _selectedValues == null ? false : _selectedValues.Contains(item.Value);
                }
            }
        }

        private void SetValue(string value)
        {
            _selectedValues = value == null ? null : value.Split(',');

            // Sharad 6 Aug 2010: Resync the selected flag of each item
            foreach (var item in _items)
            {
                item.Selected = _selectedValues == null ? false : _selectedValues.Contains(item.Value);
            }
        }

        /// <summary>
        ///  Gets or Sets the value to be used by developer.
        /// Returns the currently selected item from the list.
        /// </summary>
        public override string Value
        {
            get
            {
                if (_selectedValues == null)
                {
                    return string.Empty;
                }
                return string.Join(",", _selectedValues);
            }
            set
            {
                SetValue(value);
            }
        }


        /// <summary>
        /// Generate SelectedValues from items specified in markup
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInit(EventArgs e)
        {
            if (this.Page.IsPostBack)
            {
            }
            else
            {
                // Record initial selection
                _selectedValues = (from item in _items
                                   where item.Selected
                                   select item.Value).ToArray();
            }
            base.OnInit(e);
        }
        /// <summary>
        /// This becomes true when we are passed value from query string. In this case, we ignore selections from
        /// database.
        /// </summary>
        private bool _bValueSetFromQueryString;

        /// <summary>
        /// If a Querystring is being passed, then set to item of  CheckBoxList. 
        /// </summary>
        /// <param name="queryStringValue"></param>
        protected override void SetValueFromQueryString(string queryStringValue)
        {
            _bValueSetFromQueryString = true;
            SetValue(queryStringValue);
        }
        #endregion

        #region Client Scripts
        /// <summary>
        ///  Called before the base class creates the ready scripts.    
        /// </summary>
        protected override void PreCreateScripts()
        {
            base.PreCreateScripts();
            if (this.WidthItem != Unit.Empty)
            {
                this.ClientOptions.Add("widthItem", this.WidthItem.ToString());
            }
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.CheckBoxListEx);
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
                case ClientCodeType.InterestEvent:
                    return this.ClientChangeEventName;

                case ClientCodeType.MinLengthErrorMessage:
                    return string.Format("Please select at least {0} {{0}}", this.FriendlyName);

                case ClientCodeType.MaxLengthErrorMessage:
                    return string.Format("Please select no more than {{0}} {0}", this.FriendlyName);

                case ClientCodeType.GetValue:
                    // toString converts array into comma seperated list
                    return "function() { return $(this).checkBoxListEx('values'); }";

                // Only the first check box needs to be valdiated
                case ClientCodeType.InputSelector:
                    return string.Format("{0} input:checkbox:first", this.ClientSelector);

                //case ClientCodeType.LoadData:
                //    return "function(data) { $(this).checkBoxListEx('load', data); }";

                default:
                    return base.GetClientCode(codeType);
            }
        }

        public override string ClientChangeEventName
        {
            get
            {
                return "cblitemclick";
            }
        }

        #endregion

        #region DataBinding

        /// <summary>
        /// Data binds the control if it has not already been data bound
        /// </summary>
        private void EnsureDataBound()
        {
            if (_requiresDataBinding)
            {
                DataBind();
            }
        }

        private bool _requiresDataBinding = true;
        /// <summary>
        /// Set to true just before DataBind() is called from within PreRender. Then set to false.
        /// </summary>
        private bool _inPreRender;

        /// <summary>
        /// Raised after the list of items have been data bound
        /// </summary>
        public event EventHandler<EventArgs> DataBound;
        /// <summary>
        /// Occurs when the server control binds to a data source.
        /// </summary>
        /// <remarks>
        /// This event notifies the server control that any data binding logic written for it has completed.
        /// </remarks>
        public override void DataBind()
        {
            base.DataBind();

            if (!_inPreRender)
            {
                OnDataBinding(EventArgs.Empty);
            }
            PerformDataBinding();

            OnDataBound(EventArgs.Empty);

            _requiresDataBinding = false;
        }
        /// <summary>
        /// Occurs after the server control binds to a data source.
        /// </summary>
        /// <param name="e"></param>
        /// <remarks>
        /// This event notifies the server control to perform any data-binding logic that has been written for it.
        /// </remarks>
        private void OnDataBound(EventArgs e)
        {
            if (this.DataBound != null)
            {
                this.DataBound(this, e);
            }
        }

        /// <summary>
        /// the data source identified by the DataSourceID property takes precedence.
        ///If DataSourceID is not set, the object identified by the DataSource property is used.
        /// </summary>
        /// <returns></returns>
        private IEnumerable PerformSelect()
        {
            IEnumerable data;
            if (!string.IsNullOrEmpty(this.DataSourceID))
            {
                IDataSource ds = (IDataSource)this.NamingContainer.FindControl(this.DataSourceID);
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
        /// Does nothing if there is no data source. Otherwise creates items using the data source.
        /// </summary>
        private void PerformDataBinding()
        {
            IEnumerable data = PerformSelect();
            if (data == null)
            {
                // Do nothing as no data source has been assigned to us
                return;
            }
            _items.Clear();
            List<string> selectedValues = new List<string>();
            foreach (object dataItem in data)
            {
                CheckBoxItem li = new CheckBoxItem
                                      {
                                          Text = DataBinder.Eval(dataItem, this.DataTextField, "{0}"),
                                          Value = DataBinder.Eval(dataItem, this.DataValueField, "{0}")
                                      };
                if (this.Page.IsPostBack)
                {
                    li.Selected = this.Value.IndexOf(li.Value) >= 0;
                }
                else if (!_bValueSetFromQueryString && !string.IsNullOrEmpty(this.DataSelectedField))
                {
                    li.Selected = DataBinder.Eval(dataItem, this.DataSelectedField, "{0}") == this.DataCheckedValue;
                    if (li.Selected)
                    {
                        selectedValues.Add(li.Value);
                    }
                }
                this._items.Add(li);
            }
            if (selectedValues.Count > 0)
            {
                // Add selections from database to current selections
                if (_selectedValues != null)
                {
                    selectedValues.AddRange(_selectedValues);
                }
                this.SelectedValues = selectedValues.Distinct().ToArray();
            }
        }

        #endregion

        #region Rendering
        /// <summary>
        /// Occurs after the Control object is loaded but prior to rendering.
        /// </summary>
        /// <param name="e"></param>
        /// <remarks>
        /// Use this event to perform any updates before the server control is rendered
        /// to the page. Any changes in the view state of the server control can be saved 
        /// during this event. Such changes made in the rendering phase will not be saved.
        /// </remarks>
        protected override void OnPreRender(EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.DataSourceID))
            {
                _inPreRender = true;
                EnsureDataBound();
                _inPreRender = false;
            }

            base.OnPreRender(e);
        }
        /// <summary>
        /// Adds styles and attributes.
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            cssClasses.Add("ui-widget");
            cssClasses.Add("cbl-container");
            base.AddAttributesToRender(attributes, cssClasses);

            // We do not want the name attribute
            attributes.Remove(HtmlTextWriterAttribute.Name);
        }

        /// <summary>
        ///  Convenience settings:
        ///  set the friendlly name for the  diffrent validation case.
        /// <legend>Friendly Name</legend>
        /// <span>
        ///   <input name="UniqueID" value="CheckedValue" id="myid_1" type="checkbox"></input>
        ///   <label for="myid_1" style="width:ItemWidth;">Text</label>
        /// </span>
        /// </summary>
        /// <param name="writer"></param>
        /// <exception cref="NotImplementedException"></exception>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            string msg;
            Value val = this.Validators.OfType<Value>().FirstOrDefault(p => p.MinLength > 0 || p.MaxLength > 0);
            if (val == null)
            {
                msg = this.Validators.OfType<Required>().Any() ? "Select at least one" : string.Empty;
            }
            else
            {
                if (val.MinLength > 0 && val.MaxLength > 0)
                {
                    msg = val.MinLength == val.MaxLength ? string.Format("Select exactly {0}", val.MinLength) : string.Format("Select {0} to {1}", val.MinLength, val.MaxLength);
                }
                else if (val.MinLength > 0)
                {
                    msg = string.Format("Select at least {0}", val.MinLength);
                }
                else if (val.MaxLength > 0)
                {
                    msg = string.Format("Select at most {0}", val.MaxLength);
                }
                else
                {
                    throw new NotImplementedException("Call not expected");
                }
            }
            if (!string.IsNullOrEmpty(msg) && !string.IsNullOrEmpty(this.FriendlyName))
            {
                msg = string.Format("{0} ({1})", this.FriendlyName, msg);
            }
            else if (string.IsNullOrEmpty(msg))
            {
                msg = this.FriendlyName;
            }
            if (!string.IsNullOrEmpty(msg))
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-widget-header");
                writer.RenderBeginTag(HtmlTextWriterTag.Legend);
                writer.Write(msg);
                writer.RenderEndTag();      // legend
            }

            int i = 0;
            Unit itemWidth;
            if (this.WidthItem == Unit.Empty)
            {
                itemWidth = _items.Count == 0 ? new Unit(15, UnitType.Em) : new Unit(_items.Max(p => p.Text.Length), UnitType.Em);
            }
            else
            {
                itemWidth = this.WidthItem;
            }

            foreach (CheckBoxItem item in _items)
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                string clientId = string.Format("{0}_{1}", this.ClientID, i);
                writer.AddAttribute(HtmlTextWriterAttribute.Name, this.UniqueID);
                if (string.IsNullOrEmpty(item.Value))
                {
                    throw new HttpException("Value must be provided for each item");
                }
                writer.AddAttribute(HtmlTextWriterAttribute.Value, item.Value);
                writer.AddAttribute(HtmlTextWriterAttribute.Id, clientId);
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "checkbox");
                if (_selectedValues != null && _selectedValues.Contains(item.Value))
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Checked, "true");
                }
                if (!item.Enabled)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Disabled, "true");
                }
                //if ((i == 0 && this.FilterDisabled) || i > 0)
                //{
                //    // Except the first checkbox, all others are ignored by validation
                //    writer.AddAttribute(HtmlTextWriterAttribute.Class, JQueryScriptManager.CssClassIgnoreValidation);
                //}

                writer.RenderBeginTag(HtmlTextWriterTag.Input);
                writer.RenderEndTag();

                writer.AddStyleAttribute(HtmlTextWriterStyle.Width, itemWidth.ToString());
                writer.AddAttribute(HtmlTextWriterAttribute.For, clientId);
                writer.RenderBeginTag(HtmlTextWriterTag.Label);
                writer.Write(item.Text);
                writer.RenderEndTag();
                //writer.WriteBreak();
                writer.RenderEndTag();      // span
                ++i;
            }
            base.RenderContents(writer);
        }

        #endregion

        /// <summary>
        /// Returns comma seperated list of all selected text
        /// </summary>
        public override string DisplayValue
        {
            get
            {
                //string[] displayValues = _items.Where(p => p.Selected).Select(p => p.Text).ToArray();
                //return string.Join(", ", displayValues);
                return _selectedValues != null && _selectedValues.Count() > 0 ? string.Join(", ", _selectedValues) : string.Empty;
            }
        }

    }
}

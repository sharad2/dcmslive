using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    internal enum ClientCodeType
    {
        /// <summary>
        /// Which event is raised when a user expresses interest in this control. Usually keypress or click.
        /// When this event is raised for a dependee, the dependent control validation state is updated. When this
        /// event is raised for a dependent, the checked state of the dependee is updated.
        /// </summary>
        InterestEvent,

        /// <summary>
        /// Called just before LoadData is called. Good time to update your ui to indicate that loading is in progress.
        /// It is not passed anything. this, as always, is the DOM element
        /// </summary>
        PreLoadData,

        /// <summary>
        /// Implement this if you want to be cascadable. This requires that you should be able to load data
        /// returned from an AJAX call. The function is called with an array of drop down items as argument. this
        /// refers to the DOM element that must be filled.
        /// </summary>
        LoadData,

        /// <summary>
        /// Function which returns the value of the control
        /// </summary>
        /// <remarks>
        /// <example>
        /// function() { return $(this).val() }
        /// </example>
        /// </remarks>
        GetValue,

        /// <summary>
        /// Function which sets the value of the input control. The passed value can be boolean true or false.
        /// In this case buttons should check or uncheck themselves. Non buttons should do nothing.
        /// The value can also be a string. Buttons should check themselves if the value matches their value and uncheck
        /// themselves otherwise. Text boxes/drop downs should set the passed value as their value.
        /// </summary>
        SetValue,

        /// <summary>
        /// The error message to show when the min length constraint is violated.
        /// e.g. Pickslip id must be at least {0} characters
        /// </summary>
        MinLengthErrorMessage,

        /// <summary>
        /// The error message to show when the max length constraint is violated.
        /// e.g. Pickslip id must not be more than {0} characters
        /// </summary>
        MaxLengthErrorMessage,

        /// <summary>
        /// A selector which selects all input controls which must be validated
        /// </summary>
        InputSelector,

        /// <summary>
        /// The function to be called to set the cookie. It will not be passed anything.
        /// </summary>
        SetCookie
    }

    /// <summary>
    /// Whether the <see cref="InputControlBase"/> derived control should read and/or write its value to/from cookie.
    /// </summary>
    [Flags]
    public enum CookieUsageType
    {
        /// <summary>
        /// Cookies will not be used.
        /// </summary>
        None = 0x0,

        /// <summary>
        /// Initial value will be loaded from the cookie when the page first loads.
        /// </summary>
        Read = 0x1,

        /// <summary>
        /// The cookie will be updated each time the <see cref="InputControlBase.OnClientChange"/> event fires.
        /// </summary>
        Write = 0x2,

        /// <summary>
        /// The value will be read from the cookie and the changed value will be written back to the cookie.
        /// </summary>
        ReadWrite = Read | Write
    }

    /// <summary>
    /// Base class for all input controls which support JQuery validation.
    /// </summary>
    /// <remarks>
    /// <para>
    /// There are several Rendering virtual functions available which make it easy for you to render your derived control.
    /// To derive from InputControlBase:
    /// </para>
    /// <list type="number">
    /// <item>
    /// <description>
    ///  Decide what markup you need. If the tag you need is anything other than INPUT, override <see cref="TagKey"/>  and return the tag.
    /// </description>
    /// </item>
    /// <item>
    /// <description>
    ///  Implement the abstract <see cref="Value"/>  property. It must return the value of your control.
    /// </description>
    /// </item>
    /// <item>
    /// <description>
    ///  Render your markup in your override of <see cref="WidgetBase.RenderContents"/>.
    ///  Render attributes in the override <see cref="AddAttributesToRender"/>.
    /// </description>
    /// </item>
    /// </list>
    /// <para>
    /// You can set <see cref="UseCookie"/> if you the control to read and write its value to a cookie.
    /// The cookie is read when the page initially loads. It is written via javascript whenever the value
    /// of the control changes. This ensures that the cookie is written even if the page does not postback.
    /// By default, <see cref="CookieExpiryDays"/> is 14 days.
    /// </para>
    /// <para>
    /// 17 Feb 2010: Special code exists to ensure that controls which are not visible read their value from query string
    /// on each postback. This ensures that they do not lose their value after the postback.
    /// </para>
    /// <para>
    /// Several abstract functions need to be implemented to set your value.
    /// </para>
    /// <list type="table">
    /// <item>
    /// <term><see cref="SetValueFromQueryString"/></term>
    /// <description>The passed value is received via query string</description>
    /// </item>
    /// <item>
    /// <term><see cref="LoadPostData"/></term>
    /// <description>Posted values are passed any you should read your own value</description>
    /// </item>
    /// <item>
    /// <term></term>
    /// <description></description>
    /// </item>
    /// <item>
    /// <term></term>
    /// <description></description>
    /// </item>
    /// </list>
    /// </remarks>
    [ParseChildren(true)]
    [PersistChildren(false)]
    [ControlValueProperty("QueryStringValue")]
    [Themeable(true)]
    public abstract class InputControlBase : WidgetBase, IFilterInput, IPostBackDataHandler, IFocusable, IValidator
    {
        #region Properties

        /// <summary>
        /// Index in the tab order. By default, the browser decides based on control placement.
        /// </summary>
        [Browsable(true)]
        [DefaultValue(0)]
        public int TabIndex { get; set; }

        /// <summary>
        /// Tooltip to display for the control
        /// </summary>
        /// <remarks>
        /// This is generated as the <c>title</c> attribute of the tag returned by <see cref="TagKey"/>.
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(null)]
        public string ToolTip { get; set; }

        /// <summary>
        /// The access key to assign to this control
        /// </summary>
        /// <remarks>
        /// It is the responsibility of derived classes to make the access key obvious in the UI.
        /// It is generated as the <c>accesskey</c> attribute of the tag returned by <see cref="TagKey"/>.
        /// </remarks>
        [Browsable(true)]
        [Themeable(false)]
        public string AccessKey { get; set; }
        #endregion

        #region Validation Properties
        private readonly Collection<ValidatorBase> _validators = new Collection<ValidatorBase>();

        /// <summary>
        /// List of all validators associated with this textbox.
        /// </summary>
        /// <remarks>
        /// <para>
        /// These are usually set via markup.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<i:TextBoxEx ID="tbProgressData" runat="server" Text="Hello">
        ///    <Validators>
        ///        <i:Value ValueType="Decimal" MaxLength="15" />
        ///    </Validators>
        ///</i:TextBoxEx>
        /// ]]>
        /// </code>
        /// <seealso cref="Date"/>
        /// <seealso cref="Required"/>
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [Themeable(true)]
        [Bindable(true)]
        [NotifyParentProperty(true)]
        public Collection<ValidatorBase> Validators
        {
            get
            {
                return _validators;
            }
        }
        #endregion

        #region Cookies
        /// <summary>
        /// Whether cookie is used to get and set the value
        /// </summary>
        /// <remarks>
        /// <para>
        /// The <see cref="QueryString"/> property is used as the name of the cookie. An exception is raised
        /// if <c>UseCookie</c> is true and <c>QueryString</c> is not provided. The cookie will survive for
        /// <see cref="CookieExpiryDays"/>.
        /// </para>
        /// <para>
        /// When this property is <c>ReadOnLoad</c>, the initial value of the control is read from the cookie when the page initially loads.
        /// If a query string has been passed with the URL, the cookie is ignored and the value passed in the query string is used instead.
        /// If <see cref="UseCookie"/> is <c>WriteOnChange</c>,
        /// a client event handler is associated with the <see cref="ClientChangeEventName"/> event which
        /// writes the cookie whenever the value of the control changes.
        /// </para>
        /// <para>
        /// To manually update the value of the cookie, you need to call a control specific function. Check the documentation of each control to determine
        /// how to legally set the cookie so that it can be read back properly.
        /// </para>
        /// <seealso cref="SetValueFromCookie"/>
        /// <seealso cref="OnInit"/>
        /// <seealso cref="GetClientCode"/>
        /// <seealso cref="PreCreateScripts"/>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(CookieUsageType.None)]
        [Description("Whether the value should be read from and written to a cookie")]
        [Category("Cookie")]
        public CookieUsageType UseCookie { get; set; }

        /// <summary>
        /// The number of days after which the cookie should expire
        /// </summary>
        /// <value>Default 14 days</value>
        /// <remarks>
        /// <para>
        /// This value is used only if <see cref="UseCookie"/> is set to true.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(14)]
        [Description("Number of days after which the cookie should expire")]
        [Category("Cookie")]
        public int CookieExpiryDays { get; set; }

        /// <summary>
        /// Sets value of the control by reading a cookie
        /// </summary>
        /// <remarks>
        /// <para>
        /// This implementation calls <see cref="SetValueFromQueryString"/> to set the value. Derived classes should override this
        /// function to set the value differently.
        /// </para>
        /// </remarks>
        protected virtual void SetValueFromCookie(string cookieValue)
        {
            this.Value = cookieValue;
            return;
        }
        #endregion

       

        #region Client Events

        /// <summary>
        /// The function to call when the control is clicked
        /// </summary>
        public string OnClientClick
        {
            get
            {
                return this.ClientEvents["click"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["click"] = value;
            }
        }


        /// <summary>
        /// Function to call when the value of the input control changes
        /// </summary>
        /// <remarks>
        /// <para>
        /// The supplied function is associated with the event returned by <see cref="ClientChangeEventName"/>.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string OnClientChange
        {
            get
            {
                return this.ClientEvents[this.ClientChangeEventName] ?? string.Empty;
            }
            set
            {
                this.ClientEvents[this.ClientChangeEventName] = value;
            }

        }

        /// <summary>
        /// The name of the client event raised when value in the input control changes.
        /// </summary>
        /// <remarks>
        /// Virtual because CheckBoxListEx renames the event
        /// </remarks>
        [DefaultValue("change")]
        public virtual string ClientChangeEventName
        {
            get
            {
                return "change";
            }
        }

        #endregion

        #region Initialization
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="widgetName"></param>
        public InputControlBase(string widgetName)
            : base(widgetName)
        {
            this.EnableViewState = false;
            this.IsValid = true;
            this.CookieExpiryDays = 14;
        }

        /// <summary>
        /// Set initial value from query string or cookie
        /// </summary>
        /// <param name="e"></param>
        /// <remarks>
        /// <para>
        /// If the control is invisible, we read the query string regardless of whether this is postback or not.
        /// This is because invisble controls do not post back their values.
        /// </para>
        /// </remarks>
        protected override void OnInit(EventArgs e)
        {
            //this.Page.Validators.Add(this);
            if (!DesignMode && !string.IsNullOrEmpty(this.QueryString))
            {
                if (!this.Page.IsPostBack || !this.Visible)
                {
                    string str = this.Page.Request.QueryString[this.QueryString];
                    if (!string.IsNullOrEmpty(str))
                    {
                        SetValueFromQueryString(str);
                    }
                    else if ((this.UseCookie & CookieUsageType.Read) == CookieUsageType.Read)
                    {
                        // Try to read from cookie
                        HttpCookie cookie = this.Page.Request.Cookies.Get(this.QueryString);
                        if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
                        {
                            SetValueFromCookie(cookie.Value);
                        }
                    }
                }
            }
            base.OnInit(e);
        }

        /// <summary>
        /// Override this if you want to manipulate the value received from query string in a specialized way
        /// </summary>
        /// <param name="queryStringValue"></param>
        /// <remarks>
        /// This implementation simply uses the <see cref="Value"/> property to set the value
        /// </remarks>
        protected virtual void SetValueFromQueryString(string queryStringValue)
        {
            this.Value = queryStringValue;
        }

        #endregion

        #region Pre Render
        /// <summary>
        /// Allow validators to register their scripts
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            JQueryScriptManager.Current.AddTopLevelFocusable(this);
            foreach (ValidatorBase val in _validators)
            {
                val.RegisterClientRules(this);
            }

        }

        /// <summary>
        /// Generate cookie scripts if <see cref="UseCookie"/> is true.
        /// </summary>
        protected override void PreCreateScripts()
        {
            if ((this.UseCookie & CookieUsageType.Write) == CookieUsageType.Write)
            {
                this.ClientEvents.Add(this.ClientChangeEventName, this.GetClientCode(ClientCodeType.SetCookie));
            }

            if (this.InitialFocus)
            {
                this.ReadyScripts.Add(".focus()");
            }
        }

        #endregion

        #region Rendering

        /// <summary>
        /// By passing a dictionary here, we are able to catch errors due to duplicate adding of attributes
        /// </summary>
        /// <param name="attributes">A dictionary of attributes and their value which will be rendered with the <see cref="TagKey"/></param>
        /// <param name="cssClasses">Add the class names to this collection</param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            base.AddAttributesToRender(attributes, cssClasses);
            if (this.TabIndex != 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Tabindex, this.TabIndex.ToString());
            }
            if (!string.IsNullOrEmpty(this.UniqueID))
            {
                attributes.Add(HtmlTextWriterAttribute.Name, this.UniqueID);
            }
            if (!string.IsNullOrEmpty(this.ToolTip))
            {
                attributes.Add(HtmlTextWriterAttribute.Title, this.ToolTip);
            }
            if (!this.IsEnabled)
            {
                attributes.Add(HtmlTextWriterAttribute.Disabled, "true");
            }
            if (!string.IsNullOrEmpty(this.AccessKey))
            {
                attributes.Add(HtmlTextWriterAttribute.Accesskey, this.AccessKey);
            }
            //if (this.FilterDisabled)
            //{
            //    AddIgnoreValidationClass(cssClasses);
            //}
            return;
        }

        /// <summary>
        /// Returns INPUT
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Input;
            }
        }

        #endregion

        #region Unused base functionality

        /// <summary>
        /// Always returns false
        /// </summary>
        /// <returns></returns>
        public override bool HasControls()
        {
            return false;
        }

        /// <summary>
        /// Returns an empty collection. Derived classes should override this
        /// and <see cref="HasControls"/> if they intend to allow controls.
        /// </summary>
        /// <returns></returns>
        protected override ControlCollection CreateControlCollection()
        {
            return new EmptyControlCollection(this);
        }
        #endregion

        #region IFilterInput Members

        private string _friendlyName = string.Empty;

        /// <summary>
        /// The friendly name to be used in validation error messages
        /// </summary>
        [Browsable(true)]
        public string FriendlyName
        {
            get
            {
                return string.IsNullOrEmpty(_friendlyName) ? this.ID : _friendlyName;
            }
            set
            {
                _friendlyName = value;
            }
        }

        /// <summary>
        /// The query string from which the initial value should be read
        /// </summary>
        public string QueryString
        {
            get;
            set;
        }

        /// <summary>
        /// Returns the Value. override to return something else.
        /// </summary>
        [Browsable(false)]
        public virtual string DisplayValue
        {
            get
            {
                return this.Value;
            }
        }

        /// <summary>
        /// Returns empty string if <see cref="FilterDisabled"/> is true, otherwise returns <see cref="Value"/>
        /// </summary>
        /// <remarks>
        /// <para>
        /// When you are using two way data binding in conjunction with conditional validations, then you should use this property
        /// instead of the usual control specific property. When used with <see cref="TextBoxEx"/>, setting the value is equivalent
        /// to setting the value using the <see cref="TextBoxEx.Text"/> property. However getting the value will return an empty
        /// string if the textbox did not participate in validation, or if validation was bypassed due to the <see cref="ValidatorBase.DependsOn"/>
        /// dependency. Thus you will avoid saving redundant values in your data base.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// Consider this textbox which is designed to accept the payee name. However, the payee is relevant
        /// only if the voucher type is bank or cash. Because we have used <see cref="QueryStringValue"/> for two way data binding,
        /// the value of payee will not be returned for journal voucher types. If we had used the <see cref="TextBoxEx.Text"/> property
        /// instead, the payee would have been saved to the database, regardless of what the voucher type was.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///<i:RadioButtonListEx ID="rblVoucherTypes" runat="server" Value='<%# Bind("VoucherTypeCode") %>'
        ///    OnClientChange="rblVoucherTypes_Change" ClientIdSameAsId="true">
        ///    <Items>
        ///        <i:RadioItem Text="Bank" Value="B" />
        ///        <i:RadioItem Text="Cash" Value="C" />
        ///        <i:RadioItem Text="Journal" Value="J" />
        ///    </Items>
        ///</i:RadioButtonListEx>
        ///<i:TextBoxEx ID="tbPayee" runat="server" QueryStringValue='<%# Bind("PayeeName") %>' MaxLength="50"
        ///    ClientIdSameAsId="true">
        ///    <Validators>
        ///        <i:Filter DependsOn="rblVoucherTypes" DependsOnState="AnyValue" DependsOnValue="B,C" />
        ///        <i:Required />
        ///    </Validators>
        ///</i:TextBoxEx>
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [Themeable(false)]
        public string QueryStringValue
        {
            get
            {

                return this.FilterDisabled ? string.Empty : GetQueryStringValue();
            }
            set
            {
                SetValueFromQueryString(value);
            }
        }

        /// <summary>
        /// Allows derived classes to format the value differently
        /// </summary>
        /// <returns></returns>
        /// <remarks>
        /// <para>
        /// As an example, <see cref="TextBoxEx"/> returns the data in yyyy/mm/dd format through this function.
        /// Through the <see cref="Value"/> property, it returns the data formatted in UI culture.
        /// </para>
        /// </remarks>
        protected virtual string GetQueryStringValue() {
            return this.Value;
        }

        private bool? _filterDisabled;
        /// <summary>
        /// Whether the value is hidden because of the <see cref="Filter"/> validator
        /// </summary>
        /// <remarks>
        /// <para>
        /// FilterDisabled becomes true when the <see cref="Filter"/> validator determines that the value is not relevant.
        /// When it is true, <see cref="QueryStringValue"/> will return an empty string instead of of <see cref="Value"/>.
        /// </para>
        /// <para>
        /// Normally filter check is performed during the validation lifecycle. The filter check will be performed during 
        /// <see cref="AddAttributesToRender"/>, if it has not already been performed, to decide whether the 
        /// <see cref="JQueryScriptManager.CssClassIgnoreValidation"/> class should be applied to the control.
        /// Finally, during data binding scenarios the filter check is performed when <see cref="QueryStringValue"/> is accessed.
        /// </para>
        /// <para>
        /// If you are using a <see cref="Filter"/> validator, make sure you bind the result to the <see cref="QueryStringValue"/> property
        /// and not to the <see cref="Value"/> property. See <see cref="QueryStringValue"/> for an example.
        /// </para>
        /// <para>
        /// It is virtual so that derived classes can execute custom logic to determine whether the filter should be disabled.
        /// </para>
        /// </remarks>
        [Browsable(false)]
        [Themeable(false)]
        public virtual bool FilterDisabled
        {
            get
            {
                if (_filterDisabled == null)
                {
                    var valFilter = this.Validators.OfType<Filter>().FirstOrDefault();
                    _filterDisabled = valFilter != null && !valFilter.PerformDependencyCheck(this);
                }
                return _filterDisabled.Value;
            }
            set
            {
                _filterDisabled = value;
            }
        }
        #endregion

        /// <summary>
        /// Derived classes must return the value of the control
        /// </summary>
        /// <remarks>
        /// This property is used by all <see cref="ValidatorBase"/> derived validators to validate the value in a generic way.
        /// </remarks>
        [Browsable(false)]
        public abstract string Value
        {
            get;
            set;
        }

        #region IValidator Members

        /// <summary>
        /// The error message to display when valdiation has failed
        /// </summary>
        [Browsable(false)]
        public string ErrorMessage
        {
            get;
            set;
        }

        /// <summary>
        /// Whether validation has succeeded. It is always true to start with and can become false only if
        /// <see cref="Validate"/> is called
        /// </summary>
        [Browsable(false)]
        public bool IsValid
        {
            get;
            set;
        }

        /// <summary>
        /// Gives a chance to each validator to perform validation. If <see cref="FilterDisabled"/> is true
        /// then validation is not performed and <see cref="IsValid"/> will always return true.
        /// </summary>
        public virtual void Validate()
        {
            // Assume valid
            this.IsValid = true;
            _validators.OrderBy(p => p.Type).FirstOrDefault(p => !p.Validate(this));
            if (this._filterDisabled == null)
            {
                // We now know that the filter will not be disabled
                _filterDisabled = false;
            }
        }

        #endregion

        #region View State
        /// <summary>
        /// Some validators support view state. Give a chance to these validators to load their view state.
        /// </summary>
        /// <param name="savedState"></param>
        protected override void LoadViewState(object savedState)
        {
            Pair pair = (Pair)savedState;
            object[] states = (object[])pair.First;
            int i = 0;
            foreach (var val in _validators.OfType<IStateManager>())
            {
                val.LoadViewState(states[i]);
                ++i;
            }
            base.LoadViewState(pair.Second);
        }

        /// <summary>
        /// Some validators support view state. Give a chance to these validators to save their view state.
        /// </summary>
        /// <returns></returns>
        protected override object SaveViewState()
        {
            object[] states = (from val in _validators.OfType<IStateManager>()
                               select val.SaveViewState()).ToArray();
            return new Pair() { First = states, Second = base.SaveViewState() };
        }

        /// <summary>
        /// Some validators support view state. Give a chance to these validators to manage their view state.
        /// </summary>
        protected override void TrackViewState()
        {
            _validators.OfType<IStateManager>().ToList().ForEach(p => p.TrackViewState());
            base.TrackViewState();
        }
        #endregion

        internal virtual string GetClientCode(ClientCodeType codeType)
        {
            switch (codeType)
            {
                case ClientCodeType.PreLoadData:
                    return string.Empty;

                case ClientCodeType.MaxLengthErrorMessage:
                    return string.Format("{0} must be at most {{0}} characters", this.FriendlyName);

                case ClientCodeType.InputSelector:
                    return this.ClientSelector;

                case ClientCodeType.SetCookie:
                    string func = string.Format(@"function(e) {{
var newval = ({1}).call(this);
createCookie('{0}', newval, {2});
}}", this.QueryString, this.GetClientCode(ClientCodeType.GetValue), this.CookieExpiryDays);
                    return func;

                default:
                    throw new NotSupportedException(this.GetType().ToString() + " does not support " + codeType.ToString());
            }
        }

        #region IPostBackDataHandler Members

        /// <summary>
        /// Access the posted value from <paramref name="postCollection"/> using <paramref name="postDataKey"/>
        /// and sets it as your value
        /// </summary>
        /// <param name="postDataKey"></param>
        /// <param name="postCollection"></param>
        /// <returns>Always returns false</returns>
        public virtual bool LoadPostData(string postDataKey, NameValueCollection postCollection)
        {
            this.Value = postCollection[postDataKey];
            return false;
        }

        /// <summary>
        /// This should never get called.
        /// </summary>
        public virtual void RaisePostDataChangedEvent()
        {
            throw new NotImplementedException();
        }

        #endregion

        #region IFocusable Members

        /// <summary>
        /// Whether this control should receive focus when the page loads. Use this sparingly and only if you have a
        /// special situation. Normally you should set up your page to give focus to the first control on the page.
        /// </summary>
        [Browsable(false)]
        private bool InitialFocus { get; set; }

        FocusPriority _focusPriority = FocusPriority.Normal;

        /// <summary>
        /// How interested is this control in receiving focus.
        /// </summary>
        [Browsable(true)]
        public FocusPriority FocusPriority
        {
            get
            {
                if (this.TabIndex < 0 || !this.IsEnabled)
                {
                    return FocusPriority.NotAllowed;
                }
                else
                {
                    return _focusPriority;
                }
            }
            set
            {
                _focusPriority = value;
            }
        }

        /// <summary>
        /// Update the flag so that we will generated the focus script in <see cref="PreCreateScripts"/>
        /// </summary>
        public override void Focus()
        {
            this.InitialFocus = true;
        }

        #endregion

        public override string ToString()
        {
            return string.Format("{0}: {1}", GetType(), this.ID);
        }
    }
}

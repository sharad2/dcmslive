using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery.Scripts;


namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Enumerates the possible case conversions that TextBoxEx can perform
    /// </summary>
    public enum CharacterCaseConversion
    {
        /// <summary>
        /// This is the default. The input will be in the same case as entered by the user.
        /// </summary>
        None,

        /// <summary>
        /// All input entered by the user is converted to upper case
        /// </summary>
        UpperCase,

        /// <summary>
        /// All input entered by the user is converted to lower case
        /// </summary>
        LowerCase,

        /// <summary>
        /// The characters entered are not displayed. No case conversion is performed.
        /// </summary>
        Password
    }

    /// <summary>
    /// A textbox which uses JQuery validation. Provides validation capability such as MinLength and MaxLength. It can 
    /// accept valdiated numeric input if you use the <see cref="Value"/> validator where you can specify the Min and 
    /// Max properties.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Simply by associating a <see cref="Date"/> validator with the text box, you can associate a date picker with the textbox.
    /// If necessary, use <see cref="DatePickerOptions"/> to customize the datepicker.
    /// </para>
    /// <list type="table">
    /// <listheader>
    /// <term>Date</term>
    /// <description>Change Log</description>
    /// </listheader>
    /// <item>
    /// <term>
    /// 28 Oct 2009
    /// </term>
    /// <description>IEditableTextControl interface allows use of TextBoxEx</description>
    /// </item>
    /// <item>
    /// <term>7 Nov 2009</term>
    /// <description>If date validator specified, the Value of Text is treated as Relative date
    /// within asp:Login control</description>
    /// </item>
    /// </list>
    /// <para>
    /// The date is displayed in the current UI culture.
    /// </para>
    /// <para>
    /// <c>ControlParameter</c> expects the date to be in a very specific format and <see cref="GetQueryStringValue"/>
    /// returns the text in that format. <c>ControlValueProperty</c> attribute specifies that ControlParameters should
    /// use the <see cref="GetQueryStringValue"/> to access the value of the control.
    /// </para>
    /// </remarks>
    [ControlValueProperty("QueryStringValue")]
    public class TextBoxEx : InputControlBase, IEditableTextControl
    {
        #region Properties
        /// <summary>
        /// Whether the browser should be allowed to provide auto complete help for this field.
        /// </summary>
        /// <value>Gets/sets the AutoComplete Value. Default true.</value>
        /// <remarks>
        /// By default, the browser will remember the values the user enters in a text box and provide autocomplete help.
        /// In some situations this may not be desirable. For example if you are entering received pieces, it may cause
        /// confusion to remind the user what he entered previously. You should set the property to false to prevent
        /// auto completion.
        /// </remarks>
        public bool AutoComplete { get; set; }

        /// <summary>
        /// Number of characters which will be visible in the textbox
        /// </summary>
        /// <value>Get/Set. Defaults to MaxLength.</value>
        /// <remarks><see cref="MaxLength"/> controls how many maximum characters the user should be allowed to enter.
        /// By contrast, <c>Size</c> controls how big the text box should appear to be. The best practice is to set the 
        /// Size equal to the most common length that you expect users to enter.
        /// </remarks>
        [Browsable(true)]
        [Themeable(true)]
        public int Size { get; set; }

        /// <summary>
        /// Alignment of the text within the text box. It is recommended that numeric input should be right aligned.
        /// </summary>
        [Browsable(true)]
        [Themeable(true)]
        public HorizontalAlign TextAlign { get; set; }

        /// <summary>
        /// Whether the text box is readonly
        /// </summary>
        /// <remarks>
        /// No scripts are generated for readonly textboxes.
        /// </remarks>
        [Browsable(true)]
        [Themeable(true)]
        [DefaultValue(false)]
        public bool ReadOnly { get; set; }

        /// <summary>
        /// Whether the characters entered by the user should be automatically converted to upper or lower case.
        /// </summary>
        [Browsable(true)]
        [Themeable(true)]
        public CharacterCaseConversion CaseConversion { get; set; }

        /// <summary>
        /// This is a convenience property as an alternative to specifying MaxLength on the Value validator.
        /// If specified, it takes precedence.
        /// </summary>
        /// <remarks>
        /// <para>
        /// <c>MaxLength</c> limits the number of characters a user is allowed to enter in the text box.
        /// Use the <see cref="Size"/> property to control how wide the textbox should be on screen. It will
        /// automatically horizontally scroll when necesssary.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Themeable(true)]
        public int MaxLength { get; set; }

        [Browsable(true)]
        public string OnClientKeyPress
        {
            get
            {
                return this.ClientEvents["keypress"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["keypress"] = value;
            }
        }

        #endregion

        #region Initialization
        /// <summary>
        /// 
        /// </summary>
        public TextBoxEx()
            : base("textBoxEx")
        {
            this.IsValid = true;
            this.ErrorMessage = string.Empty;
            this.AutoComplete = true;
            //this.AutoWaterMark = true;
        }

        /// <summary>
        /// If we are displaying a date, the <see cref="Text"/> property in the markup 
        /// is expected to be numeric and is interpreted
        /// as relative date. Convert this numberic number to an actual date.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInit(EventArgs e)
        {
            if (!this.Page.IsPostBack && !string.IsNullOrEmpty(this.Text) && this.Validators.Any(p => p is Date))
            {
                // Interpret the value of text as relative date
                DateTime defDate = DateTime.Today + TimeSpan.FromDays(double.Parse(this.Text));
                this.Text = defDate.ToString("d");
            }

            base.OnInit(e);
        }

        /// <summary>
        /// If a date value is being passed, convert it from yyyy/mm/dd format to culture short date format
        /// </summary>
        /// <param name="queryStringValue"></param>
        protected override void SetValueFromQueryString(string queryStringValue)
        {
            if (this.Validators.OfType<Date>().Any())
            {
                // The date we receive is in yyyy/mm/dd format. Convert it to culture format
                DateTime result;
                if (DateTime.TryParse(queryStringValue, out result))
                {
                    this.Text = result.ToString("d");
                }
                else
                {
                    // Use the value as is
                    this.Text = queryStringValue;
                }

            }
            else
            {
                this.Text = queryStringValue;
            }
            //if (this.MaxLength > 0)
            //{
            //    Value val = this.Validators.OfType<Value>().FirstOrDefault();
            //    if (val == null)
            //    {
            //        val = new Value();
            //        this.Validators.Add(val);
            //    }
            //    val.MaxLength = this.MaxLength;
            //}
        }
        #endregion

        #region Abstract overrides

        //public override bool LoadPostData(string postDataKey, System.Collections.Specialized.NameValueCollection postCollection)
        //{
        //    this.Text = postCollection[postDataKey];
        //    return false;
        //}
        /// <summary>
        /// The <see cref="Text"/> property is our value so Value is synonymous with <c>Text</c>
        /// </summary>
        [Browsable(false)]
        public override string Value
        {
            get
            {
                return this.Text;
            }
            set
            {
                this.Text = value;
                switch (this.CaseConversion)
                {
                    case CharacterCaseConversion.None:
                    case CharacterCaseConversion.Password:
                        break;

                    case CharacterCaseConversion.UpperCase:
                        this.Text = this.Text.ToUpper();
                        break;

                    case CharacterCaseConversion.LowerCase:
                        this.Text = this.Text.ToLower();
                        break;

                    default:
                        throw new NotImplementedException();
                }
            }
        }


        #endregion

        #region Client Scripts
        /// <summary>
        /// Called before the base class creates the ready scripts. If we are a date, we set the date picker options here.
        /// No script is generated for <see cref="ReadOnly"/> textboxes
        /// </summary>
        protected override void PreCreateScripts()
        {
            base.PreCreateScripts();

            Date dateValidator = this.Validators.OfType<Date>().FirstOrDefault();
            if (dateValidator != null)
            {
                RegisterDatePicker(dateValidator);
            }
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.TextBoxEx);
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
                    return "keypress";

                case ClientCodeType.PreLoadData:
                    return string.Empty;

                case ClientCodeType.LoadData:
                    return "function(data) { $(this).textBoxEx('setval', data); }";

                case ClientCodeType.GetValue:
                    return "function() { return $(this).textBoxEx('getval'); }";

                case ClientCodeType.InputSelector:
                    return this.ClientSelector;

                case ClientCodeType.MinLengthErrorMessage:
                    return string.Format("{0} must contain at least {{0}} characters",
                        this.FriendlyName);

                default:
                    return base.GetClientCode(codeType);
            }
        }
        #endregion

        #region Rendering
        /// <summary>
        /// Convenience settings:
        /// If date, max length = 12
        /// If integer, max length deduced from max value
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            // If value type is numeric, we should be right aligned
            if (this.TextAlign == HorizontalAlign.NotSet && this.Validators.OfType<Value>()
                .Any(p => p.ValueType == ValidationValueType.Integer || p.ValueType == ValidationValueType.Decimal))
            {
                this.TextAlign = HorizontalAlign.Right;
            }

            if (this.MaxLength == 0)
            {
                if (this.Validators.OfType<Date>().Any())
                {
                    this.MaxLength = 10;
                    if (this.Size == 0)
                    {
                        this.Size = 11;
                    }
                }
            }

            // Now let the base class initialize validators
            base.OnPreRender(e);
        }


        protected override void Render(HtmlTextWriter writer)
        {
            if (this.Validators.OfType<Required>().Any(p=>p.DependsOnState== DependsOnState.NotSet) && !this.ReadOnly)
            {
                writer.AddStyleAttribute(HtmlTextWriterStyle.WhiteSpace, "nowrap");
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
            }
            base.Render(writer);
            // No required hint for readonly text boxes
            if (this.Validators.OfType<Required>().Any(p => p.DependsOnState == DependsOnState.NotSet) && !this.ReadOnly)
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Sup);
                writer.Write("*");
                writer.RenderEndTag();  // sup
                writer.RenderEndTag();  // span
            }
        }

        /// <summary>
        /// Adds styles and attributes to support <see cref="MaxLength"/> and <see cref="CaseConversion"/>
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            attributes.Add(HtmlTextWriterAttribute.Value, this.Text);
            if (this.MaxLength > 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Maxlength, this.MaxLength.ToString());
            }

            if (!this.AutoComplete)
            {
                attributes.Add(HtmlTextWriterAttribute.AutoComplete, "off");
            }
            if (this.Size > 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Size, this.Size.ToString());
            }
            else if (this.MaxLength > 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Size, this.MaxLength.ToString());
            }

            if (this.ReadOnly)
            {
                // Do not add special classes for read only. Let users customize on their own
                attributes.Add(HtmlTextWriterAttribute.ReadOnly, "true");
                //cssClasses.Add("ui-priority-secondary");
                //cssClasses.Add("ui-widget-content");
            }

            switch (this.CaseConversion)
            {
                case CharacterCaseConversion.None:
                case CharacterCaseConversion.UpperCase:
                case CharacterCaseConversion.LowerCase:
                    attributes.Add(HtmlTextWriterAttribute.Type, "text");
                    break;

                case CharacterCaseConversion.Password:
                    attributes.Add(HtmlTextWriterAttribute.Type, "password");
                    break;

                default:
                    throw new NotImplementedException();
            }
            base.AddAttributesToRender(attributes, cssClasses);
            return;
        }

        /// <summary>
        /// Adds the style needed to support <see cref="TextAlign"/>
        /// </summary>
        /// <param name="styles"></param>
        /// <param name="stylesSpecial"></param>
        protected override void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            base.AddStylesToRender(styles, stylesSpecial);
            switch (this.TextAlign)
            {
                case HorizontalAlign.NotSet:
                    break;

                case HorizontalAlign.Center:
                case HorizontalAlign.Justify:
                case HorizontalAlign.Left:
                case HorizontalAlign.Right:
                    styles.Add(HtmlTextWriterStyle.TextAlign, this.TextAlign.ToString().ToLower());
                    break;

                default:
                    throw new NotImplementedException();
            }

            switch (this.CaseConversion)
            {
                case CharacterCaseConversion.None:
                case CharacterCaseConversion.Password:
                    break;

                case CharacterCaseConversion.UpperCase:
                    stylesSpecial.Add("text-transform", "uppercase");
                    break;

                case CharacterCaseConversion.LowerCase:
                    stylesSpecial.Add("text-transform", "lowercase");
                    break;

                default:
                    throw new NotImplementedException();
            }
        }
        #endregion

        #region DatePicker

        private JQueryOptions _pickerOptions;

        /// <summary>
        /// Derived classes can add additional date picker options. <c>BusinessDateTextBox</c> uses it to
        /// display business month start dates in special color.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property is public so that your classes can take advantage of it as well. See example below.
        /// </para>
        /// <para>
        /// You can easily convert the date picker into a month selector simply by adding the code
        /// <c>tb.DatePickerOptions.Add("dateFormat", "m/yy");</c> to your <c>OnLoad</c> handler.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// jQuery date picker provides a <c>beforeShowDay</c> event which we want to hook up. This can be done in your <c>OnLoad</c>
        /// handler. This trivial function makes all dates unselectable.
        /// </para>
        /// <code>
        /// <![CDATA[
        /// protected override void OnLoad(EventArgs e)
        ///{
        ///   tbProgressDate.DatePickerOptions.AddRaw("beforeShowDay", @"function(date) {
        ///   var ret = [];
        ///   ret[0] = false;
        ///   ret[1] = '';
        ///   ret[2] = 'Hello';
        ///   return ret;
        ///}");
        /// ]]>
        /// </code>
        /// </example>
// ReSharper disable MemberCanBeProtected.Global
        public JQueryOptions DatePickerOptions
// ReSharper restore MemberCanBeProtected.Global
        {
            get { return _pickerOptions ?? (_pickerOptions = new JQueryOptions()); }
        }

        /// <summary>
        /// Attach a datepicker with the textbox. 
        /// </summary>
        /// <param name="dateValidator"></param>
        private void RegisterDatePicker(Date dateValidator)
        {
            DatePickerOptions.Add("showOn", "button");
            if (dateValidator.Min.HasValue)
            {
                DatePickerOptions.Add("minDate", dateValidator.Min.Value);
            }
            if (dateValidator.Max.HasValue)
            {
                DatePickerOptions.Add("maxDate", dateValidator.Max.Value);
            }
            DatePickerOptions.Add("showOtherMonths", true);
            DatePickerOptions.Add("changeMonth", true);
            //DatePickerOptions.Add("buttonText", "<SPAN class=\"ui-button-icon-only ui-icon ui-icon-calendar\"></SPAN>");
            // Because of the possibility of watermark, we must use this
            // event to set the value. To help DropDownSuggest, we are raising the keypress event.
            DatePickerOptions.AddRaw("onSelect", @"function(dateText, inst) {
$(this).val(dateText).change();
}");

            // The date should use the current UI culture
            if (!this.DatePickerOptions.ContainsKey("dateFormat"))
            {
                switch (CultureInfo.CurrentUICulture.DateTimeFormat.ShortDatePattern)
                {
                    case "M/d/yyyy":
                    case "M'/'d'/'yyyy":
                        DatePickerOptions.Add("dateFormat", "m/d/yy");
                        break;

                    case "d/M/yyyy":
                        DatePickerOptions.Add("dateFormat", "d/m/yy");
                        break;

                    case "dd-MMM-yy":
                        DatePickerOptions.Add("dateFormat", "d-M-y");
                        break;

                    case "MM/dd/yyyy":
                    case "MM'/'dd'/'yyyy":
                        DatePickerOptions.Add("dateFormat", "mm/dd/yy");
                        break;

                    default:
                        throw new NotImplementedException();
                }
            }
            this.ClientOptions.Add("pickerOptions", DatePickerOptions);
            switch (dateValidator.DateType)
            {
                case DateType.Default:
                    break;

                case DateType.ToDate:
                    TextBoxEx tbFrom = dateValidator.GetFromControl(this);
                    this.ClientOptions.Add("fromSelector", tbFrom.ClientSelector);
                    if (dateValidator.MaxRange > 0)
                    {
                        this.ClientOptions.Add("maxDateRange", dateValidator.MaxRange);
                    }
                    break;

                default:
                    break;
            }
        }

        /// <summary>
        /// If you are accepting date input, this is a convenient way to get value as Date. If the text does
        /// not represent a valid date, null is returned.
        /// </summary>
        /// <remarks>
        /// Make sure that you are using a Date validator to ensure
        /// validity of your page.
        /// </remarks>
        public DateTime? ValueAsDate
        {
            get
            {
                if (string.IsNullOrEmpty(this.Value))
                {
                    return null;
                }
                DateTime dt;
                var b = DateTime.TryParseExact(this.Value,
                    CultureInfo.CurrentUICulture.DateTimeFormat.ShortDatePattern,
                         CultureInfo.CurrentUICulture,
                         DateTimeStyles.None,
                         out dt);
                if (b)
                {
                    return dt;
                }
                return null;
            }
        }

        protected override string GetQueryStringValue()
        {
            // Special handling for date types. Control Parameters require value in the format 2007/12/24
            // http://weblogs.asp.net/kencox/archive/2007/06/19/setting-a-datetime-as-the-defaultvalue-in-sqldatasource-asp-parameter.aspx
            if (this.Validators.OfType<Date>().Any())
            {
                return string.Format("{0:yyyy'/'MM'/'dd}", this.ValueAsDate);
            }
            return base.GetQueryStringValue();
        }

        #endregion

        #region ITextControl Members

        private string _text = string.Empty;

        /// <summary>
        /// The value being displayed in the text box.
        /// If a <c>Date</c> validator is associated with this TextBox, then the value of Text is read from the
        /// markup is interpreted as relative date.
        /// </summary>
        /// <remarks>
        /// <para>
        /// When the page intially loads, this value is set by you,
        /// typically in the markup. After postback, this contains the value entered by the user.
        /// You should normally not be changing it since this could lead to surprising behavior from the
        /// end user's point of view.
        /// </para>
        /// <para>
        /// 29 Jan 2010 SS: Not trimming the value being set.
        /// </para>
        /// </remarks>
        public string Text
        {
            get
            {
                return _text;
            }
            set
            {
                _text = value;
            }
        }

        #endregion

        #region IEditableTextControl Members

        // Disable warning TextChanged is never used
#pragma warning disable 67
        /// <summary>
        /// This event is not currently used
        /// </summary>
        [Browsable(false)]
        public event EventHandler TextChanged;
#pragma warning restore 67

        #endregion

    }
}

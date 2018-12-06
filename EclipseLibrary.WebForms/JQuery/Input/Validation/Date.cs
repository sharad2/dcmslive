using System;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Web.UI;

// ReSharper disable CheckNamespace
namespace EclipseLibrary.Web.JQuery.Input
// ReSharper restore CheckNamespace
{
    /// <summary>
    /// By specifying the DateType as ToDate for the <see cref="Date"/> validator, you can enable range validation
    /// </summary>
    public enum DateType
    {
        /// <summary>
        /// Stand alone date picker
        /// </summary>
        Default,

        /// <summary>
        /// The previous DOM sibling is presumed to be the From Date
        /// </summary>
        ToDate
    }

    /// <summary>
    /// Supports basic Min and Max validations. Also supports compare validation by setting DateType to FromDate or ToDate.
    /// By default the associated control is assumed to be immediately after or before the from/to control respectively.
    /// However, you can specify AssociatedControlID to override the default.
    /// </summary>
    public class Date : ValidatorBase
    {
        /// <summary>
        /// Specify FromDate or ToDate
        /// </summary>
        [Browsable(true)]
        [DefaultValue(DateType.Default)]
        public DateType DateType { get; set; }

        /// <summary>
        /// The minimum acceptable value. +/- number of days from today.
        /// </summary>
        /// 
        [Browsable(true)]
        public int? Min { get; set; }

        /// <summary>
        /// The maximum acceptable value. +/- number of days from today.
        /// </summary>
        [Browsable(true)]
        public int? Max { get; set; }

        /// <summary>
        /// The range should not exceed these many days. Can be specified only for ToDate.
        /// </summary>
        public int MaxRange { get; set; }

        /// <summary>
        /// Used only if <see cref="DateType"/> is set to <c>ToDate</c>. Normally it is presumed that the
        /// <see cref="TextBoxEx"/> just before the text box with which this validator is associated is the From
        /// text box. If this is not the case, you can specifically provides its ID here.
        /// </summary>
        [Browsable(true)]
        [IDReferenceProperty(typeof(TextBoxEx))]
// ReSharper disable MemberCanBePrivate.Global
        public string AssociatedControlID { get; set; }
// ReSharper restore MemberCanBePrivate.Global

        /// <summary>
        /// 
        /// </summary>
        public Date()
            : base(ValidatorType.Value)
        {

        }

        /// <summary>
        /// We only validate that to is less than from. There is no need to validate that from is greter than to.
        /// </summary>
        /// <param name="ctlInput"></param>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        protected override bool OnServerValidate(InputControlBase ctlInput)
        {
            // We only expect to be associated with a text box
            TextBoxEx tb = (TextBoxEx)ctlInput;
            if (string.IsNullOrEmpty(tb.Text))
            {
                return true;        // Empty values are valid
            }

            DateTime? value = tb.ValueAsDate;

            if (!value.HasValue)
            {
                ctlInput.ErrorMessage = string.Format(MSG1_VALID, ctlInput.FriendlyName);
                ctlInput.IsValid = false;
                return false;
            }

            switch (this.DateType)
            {
                case DateType.Default:
                    break;

                case DateType.ToDate:
                    // Get the previous TextBoxEx
                    TextBoxEx tbFrom = GetFromControl(ctlInput);
                    DateTime? dateFrom = tbFrom.ValueAsDate;
                    if (dateFrom.HasValue)
                    {
                        if (value < dateFrom)
                        {
                            ctlInput.ErrorMessage = string.Format(MSG2_TO_GE_FROM, ctlInput.FriendlyName, tbFrom.FriendlyName);
                            ctlInput.IsValid = false;
                            return false;
                        }
                        if (this.MaxRange > 0 && (value.Value - dateFrom.Value).TotalDays > this.MaxRange)
                        {
                            ctlInput.IsValid = false;
                            return false;
                        }
                    }
                    break;

                default:
                    throw new NotImplementedException();
            }

            if (this.Min.HasValue)
            {
                DateTime minDate = DateTime.Today + TimeSpan.FromDays(this.Min.Value);
                if (value < minDate)
                {
                    ctlInput.ErrorMessage = string.Format(CultureInfo.CurrentUICulture, MSG2_MINDATE, ctlInput.FriendlyName, minDate);
                    ctlInput.IsValid = false;
                    return false;
                }
            }
            if (this.Max.HasValue)
            {
                DateTime maxDate = DateTime.Today + TimeSpan.FromDays(this.Max.Value);
                if (value > maxDate)
                {
                    ctlInput.ErrorMessage = string.Format(CultureInfo.CurrentUICulture, MSG2_MAX, ctlInput.FriendlyName, maxDate);
                    ctlInput.IsValid = false;
                    return false;
                }
            }
            return true;
        }

        private const string MSG2_MINDATE = "{0} must be {1:d} or later";
        private const string MSG1_VALID = "{0} must be a valid date";
        private const string MSG2_MAX = "{0} must be {1:d} or earlier";
        private const string MSG2_TO_GE_FROM = "{0} must be {1} or later";

        /// <summary>
        /// Add client rules for main and max values. Also add a compare validator to the to date
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <exception cref="NotImplementedException"></exception>
        internal override void RegisterClientRules(InputControlBase ctlInputControl)
        {
            string param;

            // date picker utility function provides robust date validation
            string script = @"
if (this.optional(element)) return true;
var fmt = $(element).datepicker('option', 'dateFormat');
try {
    var dt = $.datepicker.parseDate(fmt, value);
    return true;
}
catch (err) {
    return false;
}
";
            string newRule = "$.validator.addMethod('checkdate', function(value, element, param) {"
                             + script + "});";
            JQueryScriptManager.Current.RegisterScriptBlock("checkdate_validator", newRule);
            string msg = string.Format(MSG1_VALID, ctlInputControl.FriendlyName);
            DoRegisterValidator(ctlInputControl, "checkdate", true, msg);

            if (this.Min.HasValue)
            {
                script = @"
if (this.optional(element)) return true;
try {
    var fmt = $(element).datepicker('option', 'dateFormat');
    var dt = $.datepicker.parseDate(fmt, value);
    var minDate = $.datepicker.parseDate(fmt, param);
    return dt >= minDate;
}
catch (err) {
    // If any of the dates is not parseable, we deem ourselves to be valid
    return true;
}
";
                newRule = "$.validator.addMethod('mindate', function(value, element, param) {"
    + script + "});";
                JQueryScriptManager.Current.RegisterScriptBlock("mindate_validator", newRule);
                DateTime minDate = DateTime.Today + TimeSpan.FromDays(this.Min.Value);
                param = string.Format(CultureInfo.CurrentUICulture, "{0:d}", minDate);
                msg = string.Format(CultureInfo.CurrentUICulture, MSG2_MINDATE, ctlInputControl.FriendlyName, minDate);
                DoRegisterValidator(ctlInputControl, "mindate", param, msg);
            }

            if (this.Max.HasValue)
            {
                script = @"
if (this.optional(element)) return true;
try {
    var fmt = $(element).datepicker('option', 'dateFormat');
    var dt = $.datepicker.parseDate(fmt, value);
    var maxDate = $.datepicker.parseDate(fmt, param);
    return dt <= maxDate;
}
catch (err) {
    return true;
}
";
                newRule = "$.validator.addMethod('maxdate', function(value, element, param) {"
    + script + "});";
                JQueryScriptManager.Current.RegisterScriptBlock("maxdate_validator", newRule);
                DateTime maxdate = DateTime.Today + TimeSpan.FromDays(this.Max.Value);
                param = string.Format(CultureInfo.CurrentUICulture, "{0:d}", maxdate);
                msg = string.Format(CultureInfo.CurrentUICulture, MSG2_MAX, ctlInputControl.FriendlyName, maxdate);
                DoRegisterValidator(ctlInputControl, "maxdate", param, msg);
            }
            switch (this.DateType)
            {
                case DateType.Default:
                    break;
                case DateType.ToDate:
                    // Ensure to date is more than from date
                    script = @"
if (this.optional(element)) return true;
try {
    var fmt = $(element).datepicker('option', 'dateFormat');
    var val = $.datepicker.parseDate(fmt, value);
    var from = $.datepicker.parseDate(fmt, $(param).textBoxEx('getval'));
    if (from == '') return true;
    var fromDate = new Date(from);
    return val >= fromDate;
}
catch (err) {
    return true;
}
";
                    // Creating a new rule which ensures to date is greater than from date
                    newRule = "$.validator.addMethod('todate', function(value, element, param) {"
                        + script + "});";
                    JQueryScriptManager.Current.RegisterScriptBlock("todate_validator", newRule);
                    TextBoxEx tbFrom = GetFromControl(ctlInputControl);
                    param = tbFrom.ClientSelector;
                    msg = string.Format(MSG2_TO_GE_FROM, ctlInputControl.FriendlyName, tbFrom.FriendlyName);
                    DoRegisterValidator(ctlInputControl, "todate", param, msg);

                    if (this.MaxRange > 0)
                    {
                        // getDate can return a garbage date if any input control contains an invalid date.
                        // This is OK since the checkdate validator will fail first.
                        newRule = @"$.validator.addMethod('maxdaterange', function(value, element, param) {
var val = $(element).datepicker('getDate');
var fromDate = $(param[0]).datepicker('getDate');
return !val || !fromDate || (val.getTime() - fromDate.getTime()) <= (param[1] * 1000*60*60*24);
                        });";
                        JQueryScriptManager.Current.RegisterScriptBlock("maxdaterange_validator", newRule);
                        object[] ruleParams = new object[2];
                        ruleParams[0] = tbFrom.ClientSelector;
                        ruleParams[1] = string.Format("{0}", this.MaxRange);
                        msg = string.Format("{0} must be within {1} days of {2}",
                            ctlInputControl.FriendlyName, this.MaxRange, tbFrom.FriendlyName);
                        DoRegisterValidator(ctlInputControl, "maxdaterange", ruleParams, msg);
                    }
                    break;

                default:
                    throw new NotImplementedException();
            }
            //RegisterDatePicker(ctlInputControl);
        }

        /// <summary>
        /// Returns the associated From control
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <returns></returns>
        public TextBoxEx GetFromControl(InputControlBase ctlInputControl)
        {
            TextBoxEx tbFrom;
            if (string.IsNullOrEmpty(this.AssociatedControlID))
            {
                // Previous control is From Date
                tbFrom = ctlInputControl.Parent.Controls.OfType<TextBoxEx>().Reverse()
                    .SkipWhile(p => p != ctlInputControl).Skip(1).First();
            }
            else
            {
                tbFrom = (TextBoxEx)ctlInputControl.FindControl(this.AssociatedControlID);
            }
            return tbFrom;
        }

    }
}

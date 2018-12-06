using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Scripts;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Defines the type of value which is expected. The <see cref="Integer"/> and <see cref="Decimal"/> types apply 
    /// only to <see cref="TextBoxEx"/>
    /// </summary>
    public enum ValidationValueType
    {
        /// <summary>
        /// Only MinLength is honored
        /// </summary>
        String,

        /// <summary>
        /// Allows digits and negative character
        /// </summary>
        Integer,

        /// <summary>
        /// Allows all characters necessary for a decimal number
        /// </summary>
        Decimal
    }

    /// <summary>
    /// Validates various chracteristics of the text entered in a textbox. Min and Max are saved in view state to
    /// make server side validation convenient. If ValueType indicates that a date is being entered, a date picker is 
    /// associated ith the textbox.
    /// </summary>
    public class Value : ValidatorBase, IStateManager
    {
        /// <summary>
        /// 
        /// </summary>
        public Value()
            : base(ValidatorType.Value)
        {

        }

        #region Properties
        /// <summary>
        /// What type of value is expected? String is the most generic type. You can also specify Integer or deciamal.
        /// </summary>
        [Browsable(true)]
        public ValidationValueType ValueType { get; set; }

        private int? _min;

        /// <summary>
        /// The minimum permissible value for numeric input
        /// </summary>
        /// <remarks>
        /// An exception is raised if the <see cref="ValueType"/> is non numeric.
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(null)]
        public int? Min
        {
            get
            {
                return _min;
            }
            set
            {
                if (_isTrackingViewState && _min != value)
                {
                    _isDirty = true;
                }
                _min = value;
            }
        }

        private int? _max;

        /// <summary>
        /// The maximum permissible value for numeric input
        /// </summary>
        /// <remarks>
        /// An exception is raised if the <see cref="ValueType"/> is non numeric.
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(null)]
        public int? Max
        {
            get
            {
                return _max;
            }
            set
            {
                if (_isTrackingViewState && _max != value)
                {
                    _isDirty = true;
                }
                _max = value;
            }
        }

        /// <summary>
        /// Minimum permissible length of the input.
        /// </summary>
        /// <remarks>
        /// Useful only for <see cref="TextBoxEx"/> and <see cref="CheckBoxListEx"/>. For the latter it ensures that
        /// the number of checkboxes selected is greater than or equal to <c>MinLength</c>. If the control does not require
        /// a value (i.e. it does not have an associated <see cref="Required"/> validator), then zero selections
        /// are allowed regardless of what <c>MinLength</c> has been set to. This can be surprising when MinLength=1.
        /// </remarks>
        [Browsable(true)]
        public int MinLength { get; set; }

        /// <summary>
        /// Maximum permissible length of the input. 
        /// </summary>
        /// <remarks>
        /// Useful only for <see cref="TextBoxEx"/> and <see cref="CheckBoxListEx"/>. For the latter it ensures that
        /// the number of checkboxes selected is less than or equal to <c>MaxLength</c>
        /// </remarks>
        [Browsable(true)]
        public int MaxLength { get; set; }

        /// <summary>
        /// If specified, we ensure that the value entered is greater than the value entered by the user
        /// in the control identified by the ID. The Min property is additionally honored.
        /// Ignored for string value types. Validation is not failed if the MinControl contains an unreasonable
        /// value, or is empty.
        /// </summary>
        [Browsable(true)]
        [IDReferenceProperty(typeof(InputControlBase))]
        public string MinControlID { get; set; }
        #endregion

        private const string MSG1_BETWEEN = "{0} must be between {1} and {2}.";
        private const string MSG2_BETWEEN = "{0} must contain only digits.";
        private const string MSG1_MIN = "{0} must be {1} or more.";
        private const string MSG1_MAX = "{0} must be {1} or less.";

        #region Server Validation
        /// <summary>
        /// TODO: Date validation
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <returns></returns>
        protected override bool OnServerValidate(InputControlBase ctlInputControl)
        {
            if (string.IsNullOrEmpty(ctlInputControl.Value))
            {
                return true;        // Empty values are valid
            }
            if (this.MinLength > 0)
            {
                if (ctlInputControl is CheckBoxListEx)
                {
                    ctlInputControl.IsValid = ctlInputControl.Value.Split(new char[] { ',' }).Length >= this.MinLength;
                    ctlInputControl.ErrorMessage = string.Format("Select at least {1} {0}", ctlInputControl.FriendlyName, this.MinLength);
                }
                else
                {
                    ctlInputControl.IsValid = ctlInputControl.Value.Length >= this.MinLength;
                    ctlInputControl.ErrorMessage = string.Format("{0} must contain at least {1} characters", ctlInputControl.FriendlyName, this.MinLength);
                }
            }
            if (!ctlInputControl.IsValid)
            {
                return base.OnServerValidate(ctlInputControl);
            }
            if (this.MaxLength > 0)
            {
                if (ctlInputControl is CheckBoxListEx)
                {
                    ctlInputControl.IsValid = ctlInputControl.Value.Split(new char[] { ',' }).Length <= this.MaxLength;
                    ctlInputControl.ErrorMessage = string.Format("Select at most {1} {0}", ctlInputControl.FriendlyName, this.MaxLength);
                }
                else
                {
                    ctlInputControl.IsValid = ctlInputControl.Value.Length <= this.MaxLength;
                    ctlInputControl.ErrorMessage = string.Format("{0} must contain at most {1} characters",
                        ctlInputControl.FriendlyName, this.MaxLength);
                }
            }
            if (!ctlInputControl.IsValid)
            {
                return base.OnServerValidate(ctlInputControl);
            }
            decimal d;
            switch (this.ValueType)
            {
                case ValidationValueType.String:
                    ctlInputControl.IsValid = true;
                    d = 0;
                    break;

                case ValidationValueType.Integer:
                    Int64 n;
                    ctlInputControl.IsValid = Int64.TryParse(ctlInputControl.Value, out n);
                    if (ctlInputControl.IsValid)
                    {
                        d = n;
                    }
                    else
                    {
                        ctlInputControl.ErrorMessage = string.Format("{0} must be a valid integer", ctlInputControl.FriendlyName);
                        d = 0;
                    }
                    break;

                case ValidationValueType.Decimal:
                    ctlInputControl.IsValid = decimal.TryParse(ctlInputControl.Value, out d);
                    if (!ctlInputControl.IsValid)
                    {
                        ctlInputControl.ErrorMessage = string.Format("{0} must be a valid decimal", ctlInputControl.FriendlyName);
                    }
                    break;

                default:
                    throw new NotImplementedException();
            }

            if (!ctlInputControl.IsValid)
            {
                return base.OnServerValidate(ctlInputControl);
            }

            if (this.Min.HasValue || this.Max.HasValue)
            {
                if (this.Min.HasValue && this.Max.HasValue)
                {
                    ctlInputControl.IsValid = d >= this.Min.Value && d <= this.Max.Value;
                    if (!ctlInputControl.IsValid)
                    {
                        ctlInputControl.ErrorMessage = string.Format(MSG2_BETWEEN, ctlInputControl.FriendlyName);
                    }
                }
                else if (this.Min.HasValue)
                {
                    ctlInputControl.IsValid = d >= this.Min.Value;
                    if (!ctlInputControl.IsValid)
                    {
                        ctlInputControl.ErrorMessage = string.Format(MSG1_MIN, ctlInputControl.FriendlyName, this.Min);
                    }
                }
                else if (this.Max.HasValue)
                {
                    ctlInputControl.IsValid = d <= this.Max.Value;
                    if (!ctlInputControl.IsValid)
                    {
                        ctlInputControl.ErrorMessage = string.Format(MSG1_MAX, ctlInputControl.FriendlyName, this.Max);
                    }
                }
            }
            if (!ctlInputControl.IsValid)
            {
                return base.OnServerValidate(ctlInputControl);
            }
            if (!string.IsNullOrEmpty(this.MinControlID))
            {
                InputControlBase ctlMin = (InputControlBase)ctlInputControl.NamingContainer.FindControl(this.MinControlID);
                decimal otherVal;
                if (decimal.TryParse(ctlMin.Value, out otherVal))
                {
                    ctlInputControl.IsValid = d >= otherVal;
                    if (!ctlInputControl.IsValid)
                    {
                        ctlInputControl.ErrorMessage = string.Format("{0} must be greater than or equal to {1}",
                            ctlInputControl.FriendlyName, ctlMin.FriendlyName);
                        return base.OnServerValidate(ctlInputControl);
                    }
                }

            }
            return base.OnServerValidate(ctlInputControl);
        }
        #endregion

        #region Client Validation
        /// <summary>
        /// Registers the rules for client validation
        /// </summary>
        /// <param name="ctlInputControl"></param>
        internal override void RegisterClientRules(InputControlBase ctlInputControl)
        {
            string msg;
            if (_isDirty && !ctlInputControl.EnableViewState)
            {
                msg = string.Format("Since you are updating validator property values dynamically, EnableViewState must be true for {0}",
                    ctlInputControl.ID);
                throw new HttpException(msg);
            }
            //string script;
            switch (this.ValueType)
            {
                case ValidationValueType.String:
                    if (this.Min.HasValue || this.Max.HasValue)
                    {
                        throw new NotSupportedException(ctlInputControl.ID + ": Min and Max are not supported for string values");
                    }
                    break;

                case ValidationValueType.Integer:
                    if (this.Min.HasValue && this.Min >= 0)
                    {
                        DoRegisterValidator(ctlInputControl, "digits", true,
                            string.Format("{0} must contain only digits", ctlInputControl.FriendlyName));
                    }
                    else
                    {
                        // Creating a new rule which allows leading negative character
                        string newRule = @"$.validator.addMethod('integer', function(value, element, params) {
    return this.optional(element) || /^-{0,1}\d+$/.test(value);
});";
                        JQueryScriptManager.Current.RegisterScriptBlock("integer_validator", newRule);
                        DoRegisterValidator(ctlInputControl, "integer", true,
                            string.Format("{0} must contain only digits, with an optional leading minus sign",
                            ctlInputControl.FriendlyName));
                    }
                    RegisterNumericRules(ctlInputControl);
                    break;

                case ValidationValueType.Decimal:
                    DoRegisterValidator(ctlInputControl, "number", true,
                        string.Format("{0} must be a valid decimal number", ctlInputControl.FriendlyName));
                    RegisterNumericRules(ctlInputControl);
                    break;

                default:
                    throw new NotImplementedException();
            }

            if (this.MinLength > 0)
            {
                msg = ctlInputControl.GetClientCode(ClientCodeType.MinLengthErrorMessage);
                DoRegisterValidator(ctlInputControl, "minlength", this.MinLength, msg);
            }
            if (this.MaxLength > 0)
            {
                msg = ctlInputControl.GetClientCode(ClientCodeType.MaxLengthErrorMessage);
                DoRegisterValidator(ctlInputControl, "maxlength", this.MaxLength, msg);
            }
        }

        /// <summary>
        /// Crete rules for Min and Max.
        /// </summary>
        /// <param name="ctlInputControl"></param>
        private void RegisterNumericRules(InputControlBase ctlInputControl)
        {
            string script;
            if (this.Min.HasValue)
            {
                // Sharad 21 Sep 2010: making min numeric specific. Tolerates commas
                script = @"$.validator.addMethod('greaterthan', function(value, element, params) {
    if (this.optional(element)) {
        return true;
    }
    var val = Number(value.replace(/,/g, ''));
    return isNaN(val) || val >= params;
});";
                JQueryScriptManager.Current.RegisterScriptBlock("greaterthan_validator", script);
                DoRegisterValidator(ctlInputControl, "greaterthan", this.Min,
                    string.Format("{0} must be {{0}} or more", ctlInputControl.FriendlyName));

            }
            if (this.Max.HasValue)
            {
                // Sharad 21 Sep 2010: making min numeric specific. Tolerates commas
                script = @"$.validator.addMethod('lessthan', function(value, element, params) {
    if (this.optional(element)) {
        return true;
    }
    var val = Number(value.replace(/,/g, ''));
    return isNaN(val) || val <= params;
});";
                JQueryScriptManager.Current.RegisterScriptBlock("lessthan_validator", script);
                DoRegisterValidator(ctlInputControl, "max", this.Max,
                    string.Format("{0} must be {{0}} or less", ctlInputControl.FriendlyName));
            }
            if (!string.IsNullOrEmpty(this.MinControlID))
            {
                // param is the selector of the associated control
                script = @"if (this.optional(element)) return true;
var thisVal = Number(value);
var otherVal = Number($(param).val());
if (isNaN(otherVal) || isNaN(thisVal)) return true;
return thisVal >= otherVal;";
                string newRule = "$.validator.addMethod('minfromctl', function(value, element, param) {"
+ script + "});";
                JQueryScriptManager.Current.RegisterScriptBlock("minfromctl_validator", newRule);

                InputControlBase ctlMin = (InputControlBase)ctlInputControl.NamingContainer.FindControl(this.MinControlID);
                string jqParam = ctlMin.ClientSelector;
                string jqMsg = string.Format("'{0} must be same as or more than {1}'",
                    ctlInputControl.FriendlyName, ctlMin.FriendlyName);
                DoRegisterValidator(ctlInputControl, "minfromctl", jqParam, jqMsg);
            }
        }

        /// <summary>
        /// Attach a datepicker with the textbox
        /// </summary>
        /// <param name="ctlInputControl"></param>
        private void RegisterDatePicker(InputControlBase ctlInputControl)
        {
            JQueryOptions options = new JQueryOptions();
            options.Add("showOn", "button");
            string script;
            if (this.Min.HasValue)
            {
                options.Add("minDate", this.Min.Value);
                options.Add("origMinDays", this.Min.Value);
            }
            if (this.Max.HasValue)
            {
                options.Add("maxDate", this.Max.Value);
                options.Add("origMaxDays", this.Max.Value);
            }

            script = string.Format("$('{0}').datepicker({1});", ctlInputControl.ClientSelector, options);
            JQueryScriptManager.Current.RegisterReadyScript(script);

        }
        #endregion

        #region IStateManager Members

        private bool _isTrackingViewState;
        private bool _isDirty;

        bool IStateManager.IsTrackingViewState
        {
            get { throw new NotImplementedException(); }
        }

        void IStateManager.LoadViewState(object state)
        {
            if (state != null)
            {
                Pair pair = (Pair)state;
                this.Min = (int?)pair.First;
                this.Max = (int?)pair.Second;
            }
        }

        object IStateManager.SaveViewState()
        {
            if (_isDirty)
            {
                return new Pair() { First = this.Min, Second = this.Max };
            }
            else
            {
                return null;
            }
        }

        void IStateManager.TrackViewState()
        {
            _isTrackingViewState = true;
        }

        #endregion
    }
}

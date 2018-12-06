
using System.ComponentModel;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Implements client and server side Required validation 
    /// </summary>
    /// <remarks>
    /// The following table lists how this validator valdiates each type of control
    /// <list type="table">
    /// <listheader>
    /// <term>Control</term>
    /// <description>How it validates</description>
    /// </listheader>
    /// <item>
    /// <term><see cref="TextBoxEx"/> and <see cref="TextArea"/></term>
    /// <description>Validation passes if the text box contains any text. Leading and trailing spaces are not considered.</description>
    /// </item>
    /// <item>
    /// <term><see cref="CheckBoxEx"/></term>
    /// <description>Validation passes if the checkbox is checked</description>
    /// </item>
    /// <item>
    /// <term><see cref="CheckBoxListEx"/></term>
    /// <description>Validation passes if any checkbox is checked</description>
    /// </item>
    /// <item>
    /// <term><see cref="RadioButtonListEx"/></term>
    /// <description>Not useful because the radio button list must always have exactly one button selected.</description>
    /// </item>
    /// </list>
    /// </remarks>
    public class Required : ValidatorBase
    {
        /// <summary>
        /// 
        /// </summary>
        public Required()
            : base(ValidatorType.Required)
        {
            //this.Required = true;
        }

        /// <summary>
        /// Performs server side valdiation
        /// </summary>
        /// <param name="ctlInputControl">The control to be validated</param>
        /// <returns>true if validation succeeds</returns>
        /// <remarks>
        /// Accesses the abstract <see cref="P:EclipseLibrary.Web.JQuery.Input.InputControlBase.Value"/> property
        /// of <see cref="InputControlBase"/> base class and returns true if the returned value in non empty after trimming.
        /// </remarks>
        protected override bool OnServerValidate(InputControlBase ctlInputControl)
        {
            if (ctlInputControl.Value == null || string.IsNullOrEmpty(ctlInputControl.Value.Trim()))
            {
                ctlInputControl.ErrorMessage = string.Format("{0} is required", ctlInputControl.FriendlyName);
                ctlInputControl.IsValid = false;
            }
            return base.OnServerValidate(ctlInputControl);
        }

        internal override void RegisterClientRules(InputControlBase ctlInputControl)
        {
            DoRegisterValidator(ctlInputControl, "required", true,
                string.Format("{0} is required", ctlInputControl.FriendlyName));
        }

    }
}

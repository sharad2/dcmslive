using System;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Disables the filter when the dependency is not satisfied. Performs both client and server checks.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Filter is a validator which sets <see cref="InputControlBase.FilterDisabled"/> to true if the associated dependency
    /// condition is not specified. When this happens, the <see cref="InputControlBase.QueryStringValue"/> property returns
    /// an empty string even if the control has a value.
    /// </para>
    /// <para>
    /// On the client side, the dependencies are revaluated each time the value in the control <see cref="ValidatorBase.DependsOn"/> changes.
    /// The <see cref="JQueryScriptManager.CssClassIgnoreValidation"/> class is applied to the input control if the dependency is
    /// not satisfied. The effect of this is that the input control will not participate in validation until the value of the control
    /// <see cref="ValidatorBase.DependsOn"/> changes again.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// In this example, the value in the weight text box is relevant only when the Weight per dozen
    /// checkbox is checked. For this reason there is a <c>Filter</c> validator associated with the 
    /// <see cref="TextBoxEx"/> <c>tbWeight</c> which states that the value in the textbox should be
    /// visible to a <c>ControlParameter</c> only when the text box contains some value.
    /// </para>
    /// <code>
    ///  <![CDATA[
    ///<i:CheckBoxEx ID="cbWeight" runat="server" FriendlyName="Weight" Text="Weight per dozen"
    ///    CheckedValue="W" ClientIdSameAsId="true">  
    ///</i:CheckBoxEx>
    ///<i:TextBoxEx ID="tbWeight" runat="server" FriendlyName="Weight">
    ///    <Validators>
    ///        <i:Value MaxLength="9" ValueType="Decimal" />
    ///        <i:Filter DependsOn="cbWeight" DependsOnState="Checked" />
    ///    </Validators>
    ///</i:TextBoxEx>
    ///  ]]>
    ///  </code>
    /// </example>
    /// <example>
    /// <para>
    /// This example demonstrates the usefulness of <see cref="DependsOnState"/> equal to <c>AnyValue</c>.
    /// The Modules checkboxes are relevant only when the Manager or the Operator role has been chosen.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <i:RadioButtonListEx ID="rblRoles" runat="server" SelectedValue='<%# Bind("Roles") %>'
    ///     FriendlyName="Roles">
    ///     <Items>
    ///         <i:RadioItem Text="Administrator" Value="Administrator" />
    ///         <i:RadioItem Text="Manager" Value="Manager" />
    ///         <i:RadioItem Text="Operator" Value="Operator" />
    ///     </Items>
    /// </i:RadioButtonListEx>
    /// <i:CheckBoxListEx runat="server" ID="cblModules" OnLoad="cblModules_Load" FriendlyName="Packages"
    ///     QueryStringValue='<%# Bind("Modules") %>'>
    ///     <Validators>
    ///         <i:Filter DependsOn="rblRoles" DependsOnState="AnyValue" DependsOnValue="Operator,Manager" />
    ///         <i:Value MinLength="1" />
    ///     </Validators>
    /// </i:CheckBoxListEx>
    /// ]]>
    /// </code>
    /// </example>
    public class Filter : ValidatorBase
    {
        public Filter()
            : base(ValidatorType.Filter)
        {

        }

        /// <summary>
        /// Always returns true.
        /// </summary>
        /// <param name="ctlInput"></param>
        /// <returns>true</returns>
        /// <remarks>
        /// <para>
        /// This valdiator does not perform any server side validation so this function always returns true.
        /// The base class is not called to prevent arising hte <see cref="ValidatorBase.ServerValidate"/> event.
        /// </para>
        /// </remarks>
        protected override bool OnServerValidate(InputControlBase ctlInput)
        {
            return true;
        }

        /// <summary>
        /// Set <see cref="InputControlBase.FilterDisabled"/> to true.
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <returns>false to indicate that validation should not continue</returns>
        protected override bool ServerValidationBypassed(InputControlBase ctlInputControl)
        {
            ctlInputControl.FilterDisabled = true;
            return false;
        }

        /// <summary>
        /// 1) Script to automatically check the associated button when the value in the input control is
        /// manipulated by the user.
        /// 2) Script to prevent all other validations if the filter is being disabled
        /// </summary>
        /// <param name="ctlInputControl">The control with which the filter is associated</param>
        /// <exception cref="NotImplementedException"></exception>
        /// <remarks>
        /// <para>
        /// A dummy validation rule, which always returns true, called <c>filter</c> is associated with the input control.
        /// A client script is associated with the <see cref="InputControlBase.ClientChangeEventName"/> event of the control
        /// specified in <see cref="ValidatorBase.DependsOn"/>. This client script toggles the
        /// <see cref="JQueryScriptManager.CssClassIgnoreValidation"/> depending on whether the dependency is satisfied or not.
        /// </para>
        /// </remarks>
        internal override void RegisterClientRules(InputControlBase ctlInputControl)
        {
            const string NEW_RULE = @"
$.validator.addMethod('filter', function() { return true; });
function filter_fixDependent(elementSelector) {
    var $element = $(elementSelector);
    var filter = $element.closest('form').validate().settings.rules[$element.attr('name')].filter;
    var keepRule = filter.depends.call($element[0], $element[0]);
    $element.toggleClass('val-ignore', !keepRule);
}
";
            JQueryScriptManager.Current.RegisterScriptBlock("filter_validator", NEW_RULE);
            //ctlInputControl.ClientIdRequired = true;    // Since we are referencing it in the function
            DoRegisterValidator(ctlInputControl, "filter", true, null);

            string onDependeeChange = string.Format(@"function (e) {{
filter_fixDependent('{0}');
}}", ctlInputControl.GetClientCode(ClientCodeType.InputSelector));

            if (this.DependsOnState == DependsOnState.Custom)
            {
                //TODO: The programmer is responsible for creating the client side vent handler
                throw new NotImplementedException();
            }
            InputControlBase ctlRadio = GetDependsOnControl(ctlInputControl);
            if (ctlRadio != null)
            {
                ctlRadio.ClientEvents.Add(ctlRadio.ClientChangeEventName, onDependeeChange);
            }
            return;
        }

    }
}

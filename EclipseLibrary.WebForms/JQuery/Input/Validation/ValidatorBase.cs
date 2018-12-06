using System;
using System.ComponentModel;
using System.Text;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Scripts;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

// ReSharper disable CheckNamespace
// ReSharper disable CheckNamespace
namespace EclipseLibrary.Web.JQuery.Input
// ReSharper restore CheckNamespace
// ReSharper restore CheckNamespace
{
    /// <summary>
    /// Arguments passed along with the ServerValidate event
    /// </summary>
    public class ServerValidateEventArgs : EventArgs
    {
        /// <summary>
        /// The control which must be valdiated
        /// </summary>
// ReSharper disable UnusedAutoPropertyAccessor.Global
        public InputControlBase ControlToValidate { get; set; }
// ReSharper restore UnusedAutoPropertyAccessor.Global
    }

    /// <summary>
    /// Raised when a custom validation dependency is specified
    /// </summary>
    /// <remarks>
    /// </remarks>
    public class DependencyCheckEventArgs : EventArgs
    {
        /// <summary>
        /// 
        /// </summary>
        public DependencyCheckEventArgs()
        {
            this.NeedsToBeValdiated = true;
        }

        /// <summary>
        /// Set to <c>false</c> to by pass validations associated with the valdiator
        /// </summary>
        /// <value>Default true</value>
        // ReSharper disable MemberCanBePrivate.Global
        public bool NeedsToBeValdiated { get; set; }
        // ReSharper restore MemberCanBePrivate.Global

        /// <summary>
        /// The control with which the validator is associated
        /// </summary>
// ReSharper disable UnusedAutoPropertyAccessor.Global
        public InputControlBase ControlToValidate { get; set; }
// ReSharper restore UnusedAutoPropertyAccessor.Global
    }

    /// <summary>
    /// Used by the DependsOn property. By default the dependent validation rule is applied if the
    /// associated checkbox is checked.
    /// If you specify DependsOnState=Unchecked, the interpretration is reversed.
    /// </summary>
    public enum DependsOnState
    {
        /// <summary>
        /// Default.
        /// </summary>
        NotSet,
        /// <summary>
        /// Dependency is satisfied if the state of the associated control is checked.
        /// For a text box, this means that the text box is not empty.
        /// </summary>
        Checked,

        /// <summary>
        /// Dependency is satisfied if the state of the associated control is unchecked. For a text box, this means
        /// that the text box is empty.
        /// </summary>
        Unchecked,

        /// <summary>
        /// In this case, <see cref="P:EclipseLibrary.Web.JQuery.Input.ValidatorBase.DependsOn"/> 
        /// property is evaluated as a function which must return true if the dependency is
        /// satisfied
        /// </summary>
        Custom,

        /// <summary>
        /// Dependency is satisfied if the state of the associated control has a specific value.
        /// </summary>
        Value,

        /// <summary>
        /// Dependency is satisfied if the control has one of the specified comma seperated values.
        /// See <see cref="Filter"/> for an example.
        /// </summary>
        AnyValue,

        Selector
    }

    /// <summary>
    /// Abstract Base class for all validators.
    /// </summary>
    /// <include file='ValidatorBase.xml' path='ValidatorBase/doc[@name="class"]/*'/>
    public abstract class ValidatorBase
    {
        /// <summary>
        /// The checks are performed in this order.
        /// </summary>
        public enum ValidatorType
        {
            /// <summary>
            /// This validator may enable or disable the filter.
            /// </summary>
            Filter,

            /// <summary>
            /// Required checks are performed first. For empty values, this is the only check that can fail
            /// since no other validations are performed.
            /// </summary>
            Required,

            /// <summary>
            /// These are the last level of checks and are invoked if other tests have passed so that we have
            /// reasonable assurance that these chcks can perform their work.
            /// </summary>
            Value
        }

        private readonly ValidatorType _validatorType;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="validatorType"></param>
        protected ValidatorBase(ValidatorType validatorType)
        {
            _validatorType = validatorType;
            this.DependsOnState = DependsOnState.NotSet;
        }

        /// <summary>
        /// The type of this validator. Validators of type <c>Filter</c> are evaluated first followed by
        /// <c>Required</c> and <c>Value</c> validators.
        /// </summary>
        [Browsable(false)]
        public ValidatorType Type
        {
            get
            {
                return _validatorType;
            }
        }

        /// <summary>
        /// Message to display in case of validation failure
        /// </summary>
        /// <remarks>
        /// <para>
        /// You normally do not have to specify this since each validator constructs an appropriate message based on the
        /// <see cref="InputControlBase.FriendlyName"/>. However, you can choose to specify a custom message.
        /// Your message string can contain {0}, {1} etc as place holders for each value in the rule params. Each validator
        /// passes different params to the rule. The <see cref="Custom"/> validator allows you to specify <see cref="Custom.Params"/>.
        /// </para>
        /// <para>
        /// If you need more control, you can pass a <see cref="ClientMessageFunction"/> instead.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        // ReSharper disable UnusedAutoPropertyAccessor.Global
        public string ClientMessage { get; set; }
        // ReSharper restore UnusedAutoPropertyAccessor.Global

        /// <summary>
        /// Javascript function which will return the message to display
        /// </summary>
        /// <remarks>
        /// <para>
        /// The function is passed <c>params</c> as the first argument and the <c>element</c> as the second argument.
        /// See example.
        /// </para>
        /// <para>
        /// If this is specified, then <see cref="ClientMessage"/> is ignored.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// In this example, we include the row number in the validation error message. Javascript function <c>msg_HeadRequired</c>
        /// is specified as the value of <c>ClientMessageFunction</c>. To display the same message during server validataion, we
        /// also handle the <see cref="ServerValidate"/> event.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<jquery:GridViewExInsert ID="gvEditVoucherDetails" runat="server" AutoGenerateColumns="False"
        ///    DataSourceID="dsEditVoucherDetail" DataKeyNames="VoucherDetailId" ShowFooter="true"
        ///    ClientIdSameAsId="true" InsertRowsCount="6">
        ///    <Columns>
        ///        ...
        ///        <asp:TemplateField HeaderText="Head" AccessibleHeaderText="Head">
        ///            <ItemTemplate>
        ///                <i:AutoComplete ID="tbHead" runat="server" FriendlyName="Head of Account" SelectedValue='<%# Bind("HeadOfAccountId") %>'
        ///                    SelectedText='<%# Eval("HeadOfAccount.DisplayDescription") %>' Width="30em">
        ///                    <Cascadable WebMethod="GetHeadOfAccount" WebServicePath="~/Services/HeadOfAccounts.asmx" />
        ///                    <Validators>
        ///                        <i:Required DependsOn="IsRowSelected" DependsOnState="Custom" OnServerDependencyCheck="val_IsRowSelected"
        ///                            ClientMessage="msg_HeadRequired"  OnServerValidate="val_HeadRequired" />
        ///                    </Validators>
        ///                </i:AutoComplete>
        ///            </ItemTemplate>
        ///        </asp:TemplateField>
        ///    </Columns>
        ///</jquery:GridViewExInsert>
        /// ]]>
        /// </code>
        /// <code lang="js">
        /// <![CDATA[
        ///function msg_HeadRequired(params, element) {
        ///    var rowIndex = $('#gvEditVoucherDetails').gridViewEx('rowIndex', $(element).closest('tr'));
        ///    return $.validator.format('Row {0}: Head of account is required', rowIndex + 1);
        ///}
        /// ]]>
        /// </code>
        /// <code lang="c#">
        /// <![CDATA[
        ///protected void val_HeadRequired(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
        ///{
        ///    if (!e.ControlToValidate.IsValid)
        ///    {
        ///        GridViewRow row = (GridViewRow)e.ControlToValidate.NamingContainer;
        ///        e.ControlToValidate.ErrorMessage = string.Format("Row {0}: ", row.RowIndex + 1) + e.ControlToValidate.ErrorMessage;
        ///    }
        ///}
        /// ]]>
        /// </code>
        /// </example>
        // ReSharper disable MemberCanBePrivate.Global
        // ReSharper disable UnusedAutoPropertyAccessor.Global
        public string ClientMessageFunction { get; set; }
        // ReSharper restore UnusedAutoPropertyAccessor.Global
        // ReSharper restore MemberCanBePrivate.Global

        #region Virtual functions


        /// <summary>
        /// Raised during the validation life cycle requesting you to perform server validation.
        /// </summary>
        /// <remarks>
        /// <para>
        /// All validators, except the <see cref="Filter"/> validator raise this event. The <see cref="InputControlBase.IsValid"/>
        /// and <see cref="InputControlBase.ErrorMessage"/> properties have already been set by the derived validator. Most often,
        /// you will customize the <see cref="InputControlBase.ErrorMessage"/> property to display a more explanatory
        /// message. For the <see cref="Custom"/> validator, you mustalso perform validation and set the value of 
        /// <see cref="InputControlBase.IsValid"/> property.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// <see cref="ClientMessageFunction"/> for an example.
        /// </para>
        /// </example>
        // ReSharper disable EventNeverSubscribedTo.Global
        public event EventHandler<ServerValidateEventArgs> ServerValidate;
        // ReSharper restore EventNeverSubscribedTo.Global

        /// <summary>
        /// Provide code to perform server side validation
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <returns>true if other validators should be invoked</returns>
        /// <remarks>
        /// <para>
        /// Validation is stopped if the validator fails
        /// </para>
        /// </remarks>
        protected virtual bool OnServerValidate(InputControlBase ctlInputControl)
        {
            if (ServerValidate != null)
            {
                ServerValidateEventArgs args = new ServerValidateEventArgs
                                                   {
                                                       ControlToValidate = ctlInputControl
                                                   };
                ServerValidate(this, args);
            }
            return ctlInputControl.IsValid;
        }

        /// <summary>
        /// This function is called by InputControlBase to give us a chance to register our client scripts.
        /// Derived classes must register their validation rules. They can use the helper DoRegisterValidator()
        /// which will add the dependency, if any, to the validation rule
        /// </summary>
        /// <param name="ctlInputControl"></param>
        internal abstract void RegisterClientRules(InputControlBase ctlInputControl);
        #endregion

        #region Dependency
        /// <summary>
        /// If <see cref="DependsOnState"/>=Value, then <c>DependsOnValue</c> must be specified
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is ignored if <see cref="DependsOnState"/> is <c>Custom</c>.
        /// </para>
        /// </remarks>
        // ReSharper disable UnusedAutoPropertyAccessor.Global
        public string DependsOnValue { get; set; }
        // ReSharper restore UnusedAutoPropertyAccessor.Global

        /// <summary>
        /// What does validation depend on.
        /// </summary>
        /// <include file='ValidatorBase.xml' path='ValidatorBase/doc[@name="DependsOn"]/*'/>
        [Browsable(true)]
        [IDReferenceProperty(typeof(InputControlBase))]
        // ReSharper disable UnusedAutoPropertyAccessor.Global
        public string DependsOn { get; set; }
        // ReSharper restore UnusedAutoPropertyAccessor.Global

        /// <summary>
        /// The state for which validation should succced
        /// </summary>
        ///  <include file='ValidatorBase.xml' path='ValidatorBase/doc[@name="DependsOnState"]/*'/>
        [Browsable(true)]
        [DefaultValue(DependsOnState.NotSet)]
        public DependsOnState DependsOnState { get; set; }

        #endregion

        #region Server validation

        /// <summary>
        /// This event is raised when custom dependency check is specified.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This event is raised when <see cref="DependsOnState"/> is set to <c>Custom</c>.
        /// See <see cref="DependsOn"/> for a working example.
        /// </para>
        /// </remarks>
        // ReSharper disable EventNeverSubscribedTo.Global
        public event EventHandler<DependencyCheckEventArgs> ServerDependencyCheck;
        // ReSharper restore EventNeverSubscribedTo.Global

        /// <summary>
        /// This is called during the server validation cycle and performs the same validation on server side.
        /// Derived classes should override this function and call the base class first. If the base class
        /// returns false, they should do nothing else. Otherwise they must perform their validations.
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <returns>true if validation should continue for this control, false otherwise</returns>
        public bool Validate(InputControlBase ctlInputControl)
        {
            bool bNeedsToBeValidated = string.IsNullOrEmpty(this.DependsOn) || PerformDependencyCheck(ctlInputControl);
            if (bNeedsToBeValidated)
            {
                ctlInputControl.IsValid = true;
                return OnServerValidate(ctlInputControl);
            }
            return ServerValidationBypassed(ctlInputControl);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ctlInputControl"></param>
        /// <returns>true if dependency check succeeds</returns>
        internal bool PerformDependencyCheck(InputControlBase ctlInputControl)
        {
            bool bNeedsToBeValidated;
            InputControlBase ctlDependsOn;
            switch (this.DependsOnState)
            {
                case DependsOnState.Checked:
                    // Validate only of value is non empty
                    ctlDependsOn = GetDependsOnControl(ctlInputControl);
                    bNeedsToBeValidated = !string.IsNullOrWhiteSpace(ctlDependsOn.Value);
                    break;

                case DependsOnState.Unchecked:
                    // Validate only if value is empty
                    ctlDependsOn = GetDependsOnControl(ctlInputControl);
                    bNeedsToBeValidated = string.IsNullOrWhiteSpace(ctlDependsOn.Value);
                    break;

                case DependsOnState.Value:
                    ctlDependsOn = GetDependsOnControl(ctlInputControl);
                    bNeedsToBeValidated = ctlDependsOn.Value.Trim() == this.DependsOnValue;
                    break;

                case DependsOnState.AnyValue:
                    ctlDependsOn = GetDependsOnControl(ctlInputControl);
                    bNeedsToBeValidated = this.DependsOnValue.Contains(ctlDependsOn.Value.Trim());
                    break;
                case DependsOnState.Selector:
                case DependsOnState.Custom:
                    DependencyCheckEventArgs args = new DependencyCheckEventArgs
                                                        {
                                                            ControlToValidate = ctlInputControl
                                                        };
                    OnServerDependencyCheck(args);
                    bNeedsToBeValidated = args.NeedsToBeValdiated;
                    break;
                case DependsOnState.NotSet:
                    bNeedsToBeValidated = false;
                    break;

                default:
                    throw new NotImplementedException();
            }
            return bNeedsToBeValidated;
        }

        protected virtual bool ServerValidationBypassed(InputControlBase ctlInputControl)
        {
            return false;
        }

        /// <summary>
        /// Raises the <see cref="ServerDependencyCheck"/> event.
        /// </summary>
        /// <param name="e"><see cref="DependencyCheckEventArgs"/> </param>
        /// <include file='ValidatorBase.xml' path='ValidatorBase/doc[@name="OnServerDependencyCheck"]/*'/>
        private void OnServerDependencyCheck(DependencyCheckEventArgs e)
        {
            if (this.ServerDependencyCheck != null)
            {
                ServerDependencyCheck(this, e);
            }
        }
        #endregion


        #region Client Side Validation
        /// <summary>
        /// Helper function to register the validation rule with the script manager.
        /// If ID has been specified, cloneScript is used to clone the rule
        /// </summary>
        /// <param name="ctlInputControl">The control for which client validation needs to be registered</param>
        /// <param name="ruleName">The name of the client validation rule</param>
        /// <param name="jqRuleParams">Parameters to pass to the rule in javascript syntax</param>
        /// <param name="defaultMsg">Used only if MessageFormatString is empty</param>
        protected void DoRegisterValidator(InputControlBase ctlInputControl, string ruleName, object jqRuleParams, object defaultMsg)
        {
            object script = GetDependencyFunction(ctlInputControl);
            if (script != null)
            {
                JQueryOptions options = new JQueryOptions();
                options.Add("param", jqRuleParams);
                options.Add("depends", script);
                jqRuleParams = options;
            }

            object msg;
            if (!string.IsNullOrEmpty(this.ClientMessageFunction))
            {
                msg = new JScriptCode(this.ClientMessageFunction);
            }
            else if (!string.IsNullOrEmpty(this.ClientMessage))
            {
                // Special handling. Show row number when control within grid.
                GridViewRow row = ctlInputControl.NamingContainer as GridViewRow;
                if (row == null)
                {
                    msg = this.ClientMessage;
                }
                else
                {
                    msg = string.Format("Row {0}: ", row.RowIndex + 1) + this.ClientMessage;
                }
            }
            else if (defaultMsg is string)
            {
                // Special handling. Show row number when control within grid.
                GridViewRow row = ctlInputControl.NamingContainer as GridViewRow;
                if (row == null)
                {
                    msg = defaultMsg;
                }
                else
                {
                    msg = string.Format("Row {0}: ", row.RowIndex + 1) + defaultMsg;
                }
            }
            else
            {
                msg = defaultMsg;
            }

            JQueryScriptManager.Current.AddValidationRule(ctlInputControl, ruleName, jqRuleParams, msg);
        }

        private object GetDependencyFunction(InputControlBase ctlInputControl)
        {
            switch (this.DependsOnState)
            {
                case DependsOnState.Custom:
                    // DependsOn is the custom function
                    if (string.IsNullOrEmpty(this.DependsOn))
                    {
                        string msg = string.Format("Control {0}: DependsOn must be specified when DependsOnState=Custom",
                            ctlInputControl.ID);
                        throw new InvalidOperationException(msg);
                    }
                    return new JScriptCode(this.DependsOn);

                case DependsOnState.Selector:
                    // DependsOn is the custom function
                    if (string.IsNullOrEmpty(this.DependsOn))
                    {
                        string msg = string.Format("Control {0}: DependsOn must be specified when DependsOnState=Custom",
                            ctlInputControl.ID);
                        throw new InvalidOperationException(msg);
                    }
                    return this.DependsOn;

                case DependsOnState.NotSet:
                    return null;
            }

            InputControlBase ctlDependsOn = GetDependsOnControl(ctlInputControl);
            if (ctlDependsOn == null)
            {
                return null;
            }
            StringBuilder sb = new StringBuilder("function(element) {");

            // We must ensure that the client id of ctlDependsOn is generated because our script will be referencing it
            //ctlDependsOn.ClientIdRequired = true;
            sb.AppendFormat("var $dependee = $('#{0}', $(element).closest('form'));", ctlDependsOn.ClientID);
            sb.AppendFormat("var valDependee = ({0}).call($dependee[0]);", ctlDependsOn.GetClientCode(ClientCodeType.GetValue));

            switch (this.DependsOnState)
            {
                case DependsOnState.Checked:
                    sb.Append("var okToValidate = (valDependee != '');");
                    break;

                case DependsOnState.Unchecked:
                    sb.Append("var okToValidate = (valDependee == '');");
                    break;

                case DependsOnState.Value:
                    sb.AppendFormat("var okToValidate = (valDependee == '{0}');",
                        this.DependsOnValue);
                    break;

                case DependsOnState.AnyValue:
                    JavaScriptSerializer ser = new JavaScriptSerializer();
                    string str = ser.Serialize(this.DependsOnValue.Split(','));
                    sb.AppendFormat("var okToValidate = ($.inArray(valDependee, {0}) >= 0);", str);
                    break;

                default:
                    throw new NotImplementedException();
            }
            sb.Append("return okToValidate;");
            sb.Append("}");
            return new JScriptCode(sb.ToString());
        }
        #endregion

        #region Utility functions

        private InputControlBase _dependsOnControl;

        /// <summary>
        /// You can set the control directly instead of setting <see cref="DependsOn"/>
        /// </summary>
        /// <param name="dependsOnControl"></param>
        public void SetDependsOnControl(InputControlBase dependsOnControl)
        {
            _dependsOnControl = dependsOnControl;
        }

        /// <summary>
        /// Attempts to find the control in the naming container of the passed control and all naming containers
        /// above it. Throws an exception if the control cannot be resolved.
        /// </summary>
        /// <param name="ctl"></param>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        protected InputControlBase GetDependsOnControl(InputControlBase ctl)
        {
            switch (this.DependsOnState)
            {
                case DependsOnState.Checked:
                case DependsOnState.Unchecked:
                case DependsOnState.Value:
                case DependsOnState.AnyValue:
                    break;
                case DependsOnState.NotSet:
                case DependsOnState.Custom:
                case DependsOnState.Selector:
                    return null;

                default:
                    throw new NotImplementedException();
            }

            if (_dependsOnControl == null && !string.IsNullOrEmpty(this.DependsOn))
            {
                InputControlBase ctlReturn = null;
                Control curContainer = ctl;
                while (ctlReturn == null && !(curContainer is Page))
                {
                    curContainer = curContainer.NamingContainer;
                    ctlReturn = (InputControlBase)curContainer.FindControl(this.DependsOn);
                }
                if (ctlReturn == null)
                {
                    string str = string.Format("Control {0} could not be found in any of the naming containers above {1}",
                        this.DependsOn, ctl.ID);
                    throw new ArgumentException(str);
                }
                _dependsOnControl = ctlReturn;
            }
            return _dependsOnControl;
        }
        #endregion
    }
}

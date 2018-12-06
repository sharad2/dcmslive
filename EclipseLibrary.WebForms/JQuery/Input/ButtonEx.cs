using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// The action to perform when the button is clicked
    /// </summary>
    public enum ButtonAction
    {
        /// <summary>
        /// Performs no action. You should set the <see cref="ButtonEx.OnClientClick"/> property to a javascript function.
        /// </summary>
        None,

        /// <summary>
        /// Submits the form. If <see cref="ButtonEx.CausesValidation"/> is true, then submits only if validation passes
        /// </summary>
        Submit,

        /// <summary>
        /// Reloads the current page by redirecting the browser to the URL which was used to load the page.
        /// </summary>
        Reset,

        /// <summary>
        /// Navigates to the URL specified in OnClientClick
        /// </summary>
        Navigate,

        /// <summary>
        /// Opens the Url specified in OnClientClick in a new browser window
        /// </summary>
        NewWindow
    }

    /// <summary>
    /// Whether the button should be rendered visible
    /// </summary>
    public enum ButtonClientVisibility
    {
        /// <summary>
        /// Button will be visible
        /// </summary>
        Always,

        /// <summary>
        /// The button will be hidden if it is part of a page which has been loaded via an AJAX call
        /// </summary>
        AjaxHidden,

        /// <summary>
        /// Button will not be visible in the browser but client script can mainipulate it
        /// </summary>
        Never
    }

    /// <summary>
    /// Behaves like the ASP.NET button, but is focused on jquery valdiation. 
    /// You can display an Icon in the button to the left or to the right of the text. Icon only buttons are also possible
    /// by not specifying the text.
    /// </summary>
    /// <remarks>
    /// <para>
    /// By default this button simply executes the
    /// script you provide for <see cref="OnClientClick"/>.
    /// You can set <see cref="CausesValidation"/> to true to force validation of the form before
    /// your click handler is called or before the form is submitted. You can check whether validation has succeeded
    /// using the <see cref="IsPageValid"/> function.
    /// <see cref="Action"/> is a required property is most commonly set to <c>Submit</c> or <c>Navigate</c>.
    /// </para>
    /// <para>
    /// Depending on <see cref="Action"/>, either the HTML button or the HTML a element is rendered. Visually, they all look the same.
    /// Use the <see cref="Text"/> property and the <see cref="Icon"/> property to control how the button looks.
    /// </para>
    /// <para>
    /// <see cref="DisableAfterClick"/> property can help in avoiding duplicate form submissions.
    /// </para>
    /// <para>
    /// If <see cref="CausesValidation"/> and <see cref="DisableAfterClick"/> are both false, then the button does not need any associated
    /// scripts. In this common situation, the button markup is rendered properly without the need for any scripts which greatly improves
    /// the load speed of the page.
    /// </para>
    /// <para>
    /// You can make the button visible only if the user belongs to specific roles by setting the
    /// <see cref="RolesRequired"/> property.
    /// </para>
    /// </remarks>
    [ParseChildren(true)]
    [PersistChildren(false)]
    public partial class ButtonEx : WidgetBase, IPostBackEventHandler, IButtonControl
    {
        #region Properties
        /// <summary>
        /// The text to display on the button. Not required if you are creating an icon only button.
        /// </summary>
        [Browsable(true)]
        public string Text { get; set; }

        /// <summary>
        /// Whether validation should be performed before submitting the form
        /// </summary>
        /// <remarks>
        /// <para>
        /// When this is <c>true</c>, validation will be performed whenever the button is clicked.
        /// The validation is always performed on the client side. If this button causes a postback, validation will be performed
        /// on the server side as well. To check whether validation has succeeded, use the <see cref="IsPageValid"/> property.
        /// </para>
        /// <para>
        /// All <see cref="InputControlBase"/> derived controls in the same <see cref="IValidationContainer"/> are validated.
        /// The server form is treated as an implicit validation container. Controls within nested validation containers are not 
        /// considered to be part of the outer validation container. The <see cref="ValidationSummary"/> control must either be in the
        /// same validation container as the button, or it must be in one of the enclosing validation containers. This enables you to
        /// have a single validation summary for multiple validation containers, or different validation summaries for each validation
        /// container.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// The simplest page which performs some validation might
        ///  look like this. It defines a <see cref="TextBoxEx"/>
        ///  which is required and which must consist of exactly 20 characters.
        /// </para>
        /// <code language="XML">
        /// <![CDATA[
        ///Carton ID:
        ///    <input:TextBoxEx ID="tbCartonId" runat="server" QueryString="carton_id" ClientIdSameAsId="true">
        ///        <Validators>
        ///            <input:Required />
        ///            <input:Value MinLength="20" MaxLength="20" />
        ///        </Validators>
        ///    </input:TextBoxEx>
        ///    <input:ButtonEx ID="btnGo" runat="server" Text="Go" CausesValidation="true" />
        ///<input:ValidationSummary ID="ValidationSummary1" runat="server" />        
        /// ]]>
        /// </code>
        ///<para>
        ///    The <see cref="Required" />
        ///    validator makes it required and the <see cref="Value" /> validator enforces the
        ///    <see cref="Value.MinLength" /> and <see cref="Value.MaxLength" />  requirements. Both these validators have been added to the the
        ///    <see cref="InputControlBase.Validators"/> collection.
        ///</para>
        /// </example>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool CausesValidation { get; set; }

        /// <summary>
        /// Whether client side validation should be disabled
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is primarily intended to be a diagnostic aid. You should set it to true to ensure that your server side validation
        /// code is working as expected.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool DisableClientValidation { get; set; }

        /// <summary>
        /// The tool tip to display for the button.
        /// </summary>
        public string ToolTip { get; set; }

        /// <summary>
        /// The icon to display on the button
        /// </summary>
        public ButtonIconType Icon { get; set; }

        /// <summary>
        /// Name of a jquery icon. Used only when <see cref="Icon"/> is set to Custom.
        /// </summary>
        public string CustomIconName { get; set; }

        /// <summary>
        /// Whether the button will be visible in the browser
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is not the same as <see cref="Control.Visible"/> property which prevents the button from rendering
        /// if it is set to false. <see cref="ClientVisible"/> on the other hand will render the button with a hidden style.
        /// This is useful if you want to programmatically click the button.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public virtual ButtonClientVisibility ClientVisible { get; set; }

        /// <summary>
        /// What to do when the button is clicked. The default is to do nothing which could be surprising.
        /// </summary>
        /// <remarks>
        /// <list type="table">
        /// <listheader>
        /// <term><see cref="Action"/></term>
        /// <description>Consequence</description>
        /// </listheader>
        /// <item>
        /// <term>None</term>
        /// <description>Performs no action. You should set the <see cref="OnClientClick"/> property to a javascript function
        /// which will do something.</description>
        /// </item>
        /// <item>
        /// <term>Submit</term>
        /// <description>Submits the form. If <see cref="CausesValidation"/>  is true, then submits only if validation passes</description>
        /// </item>
        /// <item>
        /// <term>Reset</term>
        /// <description>Redirects the browser to the URL which was used to initially load the page.
        /// This causes all input controls to have their
        /// default value.
        /// </description>
        /// </item>
        /// <item>
        /// <term>Navigate</term>
        /// <description>Renders a hyper link which looks like a button. Navigates to the URL specified in 
        /// <see cref="OnClientClick"/>.
        /// </description>
        /// </item>
        /// <item>
        /// <term>NewWindow</term>
        /// <description>Opens the Url specified in <see cref="OnClientClick"/> in a new browser window.</description>
        /// </item>
        /// </list>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(ButtonAction.None)]
        public virtual ButtonAction Action { get; set; }

        /// <summary>
        /// Whether this is the default button within its enclosing validation container
        /// </summary>
        /// <remarks>
        /// You can have at most one default button per validation container. Whenever enter is pressed while
        /// the focus is on any control within the validation container, this button gets clicked.
        /// </remarks>
        public bool IsDefault { get; set; }

        /// <summary>
        /// The tab index in the tabbing order
        /// </summary>
        /// <remarks>
        /// <para>
        /// Use this property only if you are exercising minute control on the tabbing order. It may also be useful to set it to -1
        /// if you do not want the user to tab to this button.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(0)]
        public int TabIndex { get; set; }

        /// <summary>
        /// The button will be renderd only if the user has at least one of these roles assigned to him
        /// </summary>
        /// <remarks>
        /// <para>
        /// <c>*</c> is a special role which matches any role. Use a * when you only care whether the user is logged in or not.
        /// </para>
        /// <para>
        /// If no role provider has been defined, then the roles you set here are ignored. Note that you can still specify *
        /// as the role which will display the button only if the user is authenticated.
        /// </para>
        /// <para>
        /// The <see cref="Visible"/> override implements this security pattern by returning false if the role requirements are not met.
        /// </para>
        /// <example>
        /// <para>
        /// The following markup specifies that the button should be visible only if the user belongs to
        /// the <c>PayrollOperator</c> role.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        /// <i:ButtonEx ID="btnNew" runat="server" OnClick="btnNew_Click" Text="Add New Adjustment"
        ///   Action="Submit" RolesRequired="PayrollOperator" />
        /// ]]>
        /// </code>
        /// </example>
        /// </remarks>
        [Browsable(true)]
        [Category("Security")]
        [Description("Comma seperated list of roles")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] RolesRequired { get; set; }

        /// <summary>
        /// Whether icon should be displayed to the right of text
        /// </summary>
        /// <remarks>
        /// <para>
        /// Normally the icon is displayed to the left of the text.
        /// </para>
        /// </remarks>
        public bool IconOnRight { get; set; }

        /// <summary>
        /// Javascript function to call when the button is clicked
        /// </summary>
        /// <remarks>
        /// If <see cref="CausesValidation"/> is true, this function is called only if validation succeeds. It is interpreted
        /// as a javascript function or a URL depending on the value of <see cref="Action"/>.
        /// </remarks>
        public string OnClientClick
        {
            get;
            set;
        }

        /// <summary>
        /// The access key which could click the button
        /// </summary>
        /// <remarks>
        /// <para>
        /// No visual cue is provided to indicate to the user what the access key is.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Themeable(false)]
        public string AccessKey { get; set; }

        /// <summary>
        /// Disables the button after it is clicked
        /// </summary>
        /// <remarks>
        /// <para>
        /// Useful for preventing duplicate form submissions. The button is disabled only if validation succeeds and
        /// the <see cref="OnClientClick"/> handler returns true. Disabling does not depend on the return value of other click handlers 
        /// which may associated with this button. Therefore you must use this option only if you are sure that noone else will want to
        /// cancel the click. Once the button is disabled, it will stay disabled. So you must reload the form.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool DisableAfterClick
        {
            get
            {
                return this.ClientOptions.Get<bool>("disableAfterClick");
            }
            set
            {
                this.ClientOptions.Set("disableAfterClick", value, false);
            }
        }
        #endregion

        #region Initialization
        /// <summary>
        /// 
        /// </summary>
        public ButtonEx()
            : base("buttonEx")
        {
            this.ClientVisible = ButtonClientVisibility.Always;
        }
        #endregion

        #region Rendering
        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            if (this.IsDefault)
            {
                cssClasses.Add("ui-priority-primary");
            }

            if (!IsScriptNeeded())
            {
                if (this.CssClasses.Length == 0)
                {
                    cssClasses.Add("ui-state-default");
                }
                cssClasses.Add("ui-button");
                cssClasses.Add("ui-widget");
                cssClasses.Add("ui-corner-all");
                if (this.Icon != ButtonIconType.None)
                {
                    if (string.IsNullOrEmpty(this.Text))
                    {
                        cssClasses.Add("ui-button-icon-only");
                    }
                    else
                    {
                        cssClasses.Add("ui-button-text-icon-primary");
                    }
                }
                else
                {
                    cssClasses.Add("ui-button-text-only");
                }
            }

            switch (this.Action)
            {
                case ButtonAction.Submit:
                    // Button
                    attributes.Add(HtmlTextWriterAttribute.Type, "submit");
                    if (!string.IsNullOrEmpty(this.UniqueID))
                    {
                        // UniqueID can be null when buton is not part of a page
                        attributes.Add(HtmlTextWriterAttribute.Name, this.UniqueID);
                    }
                    break;

                case ButtonAction.Reset:
                    // A
                    attributes.Add(HtmlTextWriterAttribute.Href, this.Page.Request.RawUrl);
                    break;


                case ButtonAction.Navigate:
                    // A. OnClientClick interpreted as URL
                    attributes.Add(HtmlTextWriterAttribute.Href, this.ResolveUrl(this.OnClientClick));
                    break;

                case ButtonAction.NewWindow:
                    // A
                    attributes.Add(HtmlTextWriterAttribute.Href, this.ResolveUrl(this.OnClientClick));

                    // Each distinct URL will open in a different window. Same URL will reuse the previously opened window.
                    attributes.Add(HtmlTextWriterAttribute.Target, OnClientClick.GetHashCode().ToString());
                    break;

                case ButtonAction.None:
                    // Button
                    attributes.Add(HtmlTextWriterAttribute.Type, "button");
                    break;

                default:
                    throw new NotImplementedException();
            }


            if (!string.IsNullOrEmpty(this.ToolTip))
            {
                attributes.Add(HtmlTextWriterAttribute.Title, this.ToolTip);
            }
            if (!string.IsNullOrEmpty(this.AccessKey))
            {
                attributes.Add(HtmlTextWriterAttribute.Accesskey, this.AccessKey);
            }
            if (this.TabIndex != 0)
            {
                attributes.Add(HtmlTextWriterAttribute.Tabindex, this.TabIndex.ToString());
            }
            base.AddAttributesToRender(attributes, cssClasses);
        }

        private bool IsClientVisible()
        {
            switch (this.ClientVisible)
            {
                case ButtonClientVisibility.Always:
                    return true;

                case ButtonClientVisibility.AjaxHidden:
                    return !JQueryScriptManager.IsAjaxCall;

                case ButtonClientVisibility.Never:
                    return false;

                default:
                    throw new NotImplementedException();
            }
        }

        protected override void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            base.AddStylesToRender(styles, stylesSpecial);

            if (!IsClientVisible())
            {
                // Adding ui-helper-hidden is not sufficient because the style gets overridden
                // Get rid of all superfluous styles if we will not be visible
                styles.Clear();
                styles.Add(HtmlTextWriterStyle.Display, "none");
            }
        }

        /// <summary>
        /// If <see cref="Action"/> is Submit then <c>button</c>, else <c>a</c>
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                switch (this.Action)
                {
                    case ButtonAction.Reset:
                    case ButtonAction.Navigate:
                    case ButtonAction.NewWindow:
                        return HtmlTextWriterTag.A;

                    case ButtonAction.None:
                    case ButtonAction.Submit:
                        return HtmlTextWriterTag.Button;

                    default:
                        throw new NotImplementedException();
                }

            }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            if (!IsClientVisible())
            {
                // Do not render ay content in the button
            }
            else if (IsScriptNeeded())
            {
                // Rendering something is necessary to prevent the height of an icon only button from becoming too small
                if (string.IsNullOrEmpty(this.Text))
                {
                    writer.Write("&nbsp;");
                }
            }
            else
            {
                if (this.Icon != ButtonIconType.None)
                {
                    string icon;
                    if (this.Icon == ButtonIconType.Custom)
                    {
                        icon = this.CustomIconName;
                    }
                    else
                    {
                        icon = GetIcon(this.Icon);
                    }
                    string classes = string.Format("ui-button-icon-primary ui-icon {0}", icon);
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, classes);
                    writer.RenderBeginTag(HtmlTextWriterTag.Span);
                    writer.RenderEndTag();      // span
                }
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-button-text");
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                // Rendering something is necessary to prevent the height of an icon only button from becoming too small
                if (string.IsNullOrEmpty(this.Text))
                {
                    writer.Write("&nbsp;");
                }
                else
                {
                    writer.Write(this.Text);
                }
                writer.RenderEndTag();      // span
            }
            base.RenderContents(writer);
        }
        #endregion

        #region IPostBackEventHandler Members

        /// <summary>
        /// Raised when the form has been submitted because this button was clicked
        /// </summary>
        public event EventHandler Click;

        /// <summary>
        /// The server form is a defacto validation container
        /// </summary>
        /// <param name="ctl"></param>
        /// <returns></returns>
        private static bool IsValidationContainer(Control ctl)
        {
            if (ctl is HtmlForm)
            {
                return true;
            }
            IValidationContainer val = ctl as IValidationContainer;
            return val != null && val.IsValidationContainer;
        }

        /// <summary>
        /// Performs validation if <see cref="CausesValidation"/> is true and then raises the <see cref="Click"/> event.
        /// </summary>
        /// <param name="eventArgument"></param>
        /// <remarks>
        /// <para>
        /// If <see cref="CausesValidation"/> is true, then the following sequence of events occur to validate the page.
        /// </para>
        /// </remarks>
        public void RaisePostBackEvent(string eventArgument)
        {
            if (this.CausesValidation)
            {
                Validate();
            }
            OnClick(EventArgs.Empty);
        }


        private bool? _pageValid;

        /// <summary>
        /// Similar to Page.IsValid, but does not require validation to be performed in advance.
        /// </summary>
        /// <returns>true if controls within the validation container successfully pass validation</returns>
        /// <remarks>
        /// <para>
        /// All your validatable controls must be one of the controls which derive from <see cref="InputControlBase"/>.
        /// This function is very commonly called in the <c>Selecting</c> event of your data source. You can cancel the
        /// query if this function returns false. This function can be safely called at any time, regardless of whether 
        /// the <see cref="CausesValidation"/> property is true or not.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// The following is a selecting event handler which cancels the query if validation has failed.
        /// </para>
        /// <code lang="C#">
        /// <![CDATA[
        ///protected void ds_Selecting(object sender, LinqDataSourceSelectEventArgs e)
        ///{
        ///    if (!btnGo.IsPageValid())
        ///    {
        ///        e.Cancel = true;
        ///        return;
        ///    }
        ///    ...
        ///}
        /// ]]>
        /// </code>
        /// </example>
        public bool IsPageValid()
        {
            if (_pageValid == null)
            {
                Control ctlContainer = GetValidationContainer();
                _pageValid = !GetInvalidInputs(ctlContainer).Any();
            }
            return _pageValid.Value;
        }

        private IEnumerable<InputControlBase> GetInvalidInputs(Control ctlContainer)
        {
            var inputs = ctlContainer.Descendants(p => !IsValidationContainer(p)).OfType<InputControlBase>().ToArray();
            foreach (var input in inputs)
            {
                input.Validate();
            }
            return inputs.Where(p => !p.IsValid);
        }

        private void Validate()
        {
            Control ctlContainer = GetValidationContainer();
            var invalidInputs = GetInvalidInputs(ctlContainer).ToArray();
            _pageValid = !invalidInputs.Any();
            if (!_pageValid.Value)
            {
                // First look for a validation summary within the same container
                ValidationSummary valSummary = ctlContainer.Descendants(p => !IsValidationContainer(p))
                    .OfType<ValidationSummary>().FirstOrDefault();
                if (valSummary == null)
                {
                    // Failing that, look for a validation summary in ancestor containers.
                    // Exception if not found
                    valSummary = ctlContainer.Ancestors(false)
                        .Where(p => IsValidationContainer(p))
                        .Select(p => p.Descendants(q => !IsValidationContainer(q)).OfType<ValidationSummary>().FirstOrDefault())
                        .First();
                }
                foreach (var input in invalidInputs)
                {
                    valSummary.ErrorMessages.Add(input.ErrorMessage);
                }
            }

            // Disable filters of all controls which are in other containers
            HashSet<IValidationContainer> set = (HashSet<IValidationContainer>)HttpContext.Current.Items["KEY_CONTAINER"];
            // Inputs in all validation containers except ctlContainer must be disabled
            var inputsToDisable = set.Where(p => p.IsValidationContainer && !object.ReferenceEquals(p, ctlContainer))
                .Cast<Control>()
                .SelectMany(p => p.Descendants().OfType<InputControlBase>());
            // Inputs in ctlContainer which are not in a nested validation container must not be disabled
            var inputsToExclude = ctlContainer.Descendants(p => !IsValidationContainer(p))
                .OfType<InputControlBase>();
            foreach (var ctl in inputsToDisable.Except(inputsToExclude))
            {
                ctl.FilterDisabled = true;
            }
        }

        /// <summary>
        /// Raises the <see cref="Click"/> event
        /// </summary>
        /// <param name="e"></param>
        protected virtual void OnClick(EventArgs e)
        {
            if (this.Click != null)
            {
                this.Click(this, e);
            }
        }

        #endregion

        #region Security
        /// <summary>
        /// Always returns true if <paramref name="roles"/> is null or empty
        /// </summary>
        /// <param name="user"></param>
        /// <param name="roles"></param>
        /// <returns></returns>
        internal static bool IsUserInAnyRole(IPrincipal user, string[] roles)
        {
            if (roles == null || roles.Length == 0)
            {
                return true;
            }
            if (roles.Any(p => p == "*"))
            {
                // Visible only if this is not an anonymous user
                return user.Identity.IsAuthenticated;
            }
            else
            {
                if (Roles.Provider == null)
                {
                    // No provider means no security check
                    return true;
                }
                else
                {
                    // Visible if any user role is one of the roles we require
                    string[] userRoles = Roles.GetRolesForUser();
                    return userRoles.Intersect(roles).Any();
                }
            }
        }

        /// <summary>
        /// If the visiblity has been set to false, it always returns false. If visibility is set to true, then it returns true
        /// only if security check is met.
        /// </summary>
        public override bool Visible
        {
            get
            {
                if (base.Visible)
                {
                    // Security check
                    return IsUserInAnyRole(this.Page.User, this.RolesRequired);
                }
                return base.Visible;
            }
            set
            {
                base.Visible = value;
            }
        }
        #endregion

        #region Scripts
        private bool IsScriptNeeded()
        {
            return this.CausesValidation || this.DisableAfterClick || this.IconOnRight;
        }
        /// <summary>
        /// Prepares the options to pass to buttonEx widget
        /// </summary>
        protected override void PreCreateScripts()
        {
            Control valContainer;
            if (this.CausesValidation || this.IsDefault)
            {
                valContainer = GetValidationContainer();
            }
            else
            {
                // Save the expense of searching for the validation container
                valContainer = null;
            }
            if (this.IsDefault)
            {
                if (valContainer is HtmlForm)
                {
                    this.Page.Form.DefaultButton = this.UniqueID;
                }
                else if (valContainer != null)
                {
                    // Handle missing ClientID gracefully before creating script
                    string func = string.Format(@"function(e) {{
if (e.which == $.ui.keyCode.ENTER) {{
    $('{0}', this).click();
    return false;
}}
}}", this.ClientSelector);
                    WidgetBase widget = valContainer as WidgetBase;
                    string script;
                    if (widget == null)
                    {
                        if (string.IsNullOrEmpty(valContainer.ClientID))
                        {
                            string str = string.Format("An ID must be specified for the validation container of button {0}",
                                this.ToString());
                            throw new HttpException(str);
                        }
                        else
                        {
                            script = string.Format(@"$('#{0}').keypress({1});", valContainer.ClientID, func);
                        }
                    }
                    else
                    {
                        script = string.Format(@"$('{0}').keypress({1});", widget.ClientSelector, func);
                    }
                    JQueryScriptManager.Current.RegisterReadyScript(script);
                }
            }

            if (!IsScriptNeeded())
            {
                this.WidgetName = string.Empty;
                if (!string.IsNullOrEmpty(this.OnClientClick))
                {
                    switch (this.Action)
                    {
                        case ButtonAction.None:
                        case ButtonAction.Submit:
                            this.ClientEvents.Add("click", this.OnClientClick);
                            break;
                    }
                }
                return;
            }
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.UiCore | ScriptTypes.Validation | ScriptTypes.ButtonEx);

            string iconName;
            switch (this.Icon)
            {
                case ButtonIconType.None:
                    iconName = string.Empty;
                    break;

                case ButtonIconType.Custom:
                    iconName = this.CustomIconName;
                    break;

                default:
                    iconName = GetIcon(this.Icon);
                    break;
            }

            if (!string.IsNullOrEmpty(iconName))
            {
                var icons = new
                {
                    primary = this.IconOnRight ? (string)null : iconName,
                    secondary = this.IconOnRight ? iconName : (string)null
                };
                this.ClientOptions.Add("icons", icons);
            }

            if (string.IsNullOrEmpty(this.Text))
            {
                this.ClientOptions.Add("text", false);
            }
            else
            {
                this.ClientOptions.Add("label", this.Text);
            }

            if (this.CausesValidation && !this.DisableClientValidation)
            {
                this.ClientOptions.Add("causesValidation", true);
            }

            if (!string.IsNullOrEmpty(this.OnClientClick))
            {
                switch (this.Action)
                {
                    case ButtonAction.None:
                    case ButtonAction.Submit:
                        this.ClientOptions.AddRaw("click", this.OnClientClick);
                        break;
                }
            }
        }
        #endregion

        #region Uniplemented IButtonControl
        event CommandEventHandler IButtonControl.Command
        {
            add { throw new NotImplementedException(); }
            remove { throw new NotImplementedException(); }
        }

        string IButtonControl.CommandArgument
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        string IButtonControl.CommandName
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        string IButtonControl.PostBackUrl
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        string IButtonControl.ValidationGroup
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }
        #endregion

        #region Static
        /// <summary>
        /// The common need to render a jQuery icon is encapsulated by this function
        /// </summary>
        /// <param name="writer">The writer on which the markup will be rendered</param>
        /// <param name="iconName">The name of the icon which needs to be displayed, e.g. ui-icon-folder-open</param>
        internal static void RenderIcon(HtmlTextWriter writer, string iconName)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-button ui-widget ui-corner-all ui-button-icon-only");
            writer.RenderBeginTag(HtmlTextWriterTag.A);
            string str = "ui-button-icon-primary ui-icon " + iconName;
            writer.AddAttribute(HtmlTextWriterAttribute.Class, str);
            writer.RenderBeginTag(HtmlTextWriterTag.Span);
            writer.RenderEndTag();      //span
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-button-text");
            writer.RenderBeginTag(HtmlTextWriterTag.Span);
            writer.RenderEndTag();      //span 
            writer.RenderEndTag();      //a
        }

        private const string KEY_CONTAINER = "ButtonEx_Containers";
        private const string KEY_VALSUMMARY = "ButtonEx_ValSummaries";
        private Control GetValidationContainer()
        {
            IValidationContainer container = this.Ancestors(false).OfType<IValidationContainer>().FirstOrDefault(p => p.IsValidationContainer);
            Control ctlContainer;
            if (container == null)
            {
                ctlContainer = this.Page.Form;
            }
            else
            {
                ctlContainer = (Control)container;
            }
            return ctlContainer;
        }

        internal static void RegisterValidationContainer(IValidationContainer container)
        {
            HashSet<IValidationContainer> set = (HashSet<IValidationContainer>)HttpContext.Current.Items["KEY_CONTAINER"];
            if (set == null)
            {
                set = new HashSet<IValidationContainer>();
                HttpContext.Current.Items["KEY_CONTAINER"] = set;
            }
            set.Add(container);
        }

        #endregion

        /// <summary>
        /// For help in debugging
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format("ButtonEx {0}; Text={1}; Icon={2}", this.ID, this.Text, this.Icon);
        }
    }
}

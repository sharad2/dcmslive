using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery.Scripts;
using EclipseLibrary.Web.JQuery.Input;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// The position of the dialog within the document window
    /// </summary>
    public enum DialogPosition
    {
        /// <summary>
        /// Centered within the browser window
        /// </summary>
        Center,

        /// <summary>
        /// Touching the left edge and centered vertically
        /// </summary>
        Left,

        /// <summary>
        /// Touching the right edge and centered vertically
        /// </summary>
        Right,


        /// <summary>
        /// Touching the top edge and centered vertically
        /// </summary>
        Top,

        /// <summary>
        /// Touching the bottom edge and centered vertically
        /// </summary>
        Bottom,

        /// <summary>
        /// In the top left corner
        /// </summary>
        LeftTop,

        /// <summary>
        /// In the top right corner
        /// </summary>
        RightTop,

        /// <summary>
        /// In the left bottom corner
        /// </summary>
        LeftBottom,

        /// <summary>
        /// In the right bottom corner
        /// </summary>
        RightBottom
    }

    /// <summary>
    /// Controls the overall appearance of the dialog
    /// </summary>
    public enum DialogStyle
    {
        /// <summary>
        /// The default style of the dialog
        /// </summary>
        Default,

        /// <summary>
        /// Displays thin title and compresses space used around it. Picker dialogs are always modal
        /// </summary>
        Picker,

        /// <summary>
        /// The dialog stays pinned on the page and does not scroll with the page
        /// </summary>
        AlwaysVisible
    }

    /// <summary>
    /// Provides a wrapper to the jQuery dialog widget. <seealso cref="AjaxDialogSettings"/>
    /// </summary>
    /// <include file='dialog.xml' path='Dialog/doc[@name="class"]/*'/>
    [ParseChildren(true)]
    [PersistChildren(false)]
    [Designer(typeof(System.Web.UI.Design.ControlDesigner))]
    public class Dialog : WidgetBase, IValidationContainer, IFocusable
    {
        #region Initialization
        /// <summary>
        /// 
        /// </summary>
        public Dialog()
            : base("ajaxDialog")
        {
            this.CloseOnEscape = true;
        }

        /// <summary>
        /// Ensures that child controls have been created. This is necessary so that
        /// page developers can access the controls within the <see cref="ContentTemplate"/> at design time
        /// without the necessity of using <see cref="Control.FindControl(string)"/>
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInit(EventArgs e)
        {
            ButtonEx.RegisterValidationContainer(this);
            EnsureChildControls();
            base.OnInit(e);
        }

        /// <summary>
        /// Instantiate the content template
        /// </summary>
        protected override void CreateChildControls()
        {
            if (this.ContentTemplate != null)
            {
                this.ContentTemplate.InstantiateIn(this);
            }
            base.CreateChildControls();
        }
        #endregion

        #region Properties
        /// <summary>
        /// By default, buttons in a dialog cannot postback because the dialog is moved outside the form.
        /// Set this to true if you want to postback.
        /// </summary>
        /// <value>Default value is false</value>
        /// <remarks>
        /// This is useful if your <see cref="ContentTemplate"/> contains buttons which are expected to post back the page.
        /// </remarks>
        public bool EnablePostBack { get; set; }

        /// <summary>
        /// When AutoOpen is true the dialog will open automatically when page is loaded.
        /// If false it will stay hidden until .dialog("open") is called on it.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Most commonly you will set the value of this property to false. The default however is true
        /// so that you can see the dialog during your initial debugging stages.
        /// </para>
        /// <para>
        /// See <a href="ff16f3a6-d63b-48cc-a0fb-438cd8c281a2.htm">Creating an AJAX Dialog</a> for a complete example
        /// of how a dialog can be opened on a button click. The example in <see cref="Title"/> has a code fragment
        /// which demonstrates the same concept.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool AutoOpen
        {
            get
            {
                return ClientOptions.Get<bool>("autoOpen", true);
            }
            set
            {
                this.ClientOptions.Set("autoOpen", value, true);
                //this.ClientOptions.Add("autoOpen", value);
            }
        }

        /// <summary>
        /// Specifies whether the dialog should close when it has focus and the user presses the esacpe (ESC) key.
        /// </summary>
        /// <value>Default is true</value>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool CloseOnEscape
        {
            get
            {
                return ClientOptions.Get<bool>("closeOnEscape", true);
            }
            set
            {
                this.ClientOptions.Set("closeOnEscape", value, true);
                //this.ClientOptions.Add("CloseOnEscape", value);
            }
        }

        /// <summary>
        /// If set to true, the dialog will be draggable by the titlebar.
        /// </summary>
        /// <value>Default is true</value>
        [Browsable(true)]
        [DefaultValue(true)]
        [Themeable(true)]
        public bool Draggable
        {
            get
            {
                return ClientOptions.Get<bool>("draggable", true);
            }
            set
            {
                this.ClientOptions.Set("draggable", value, true);
                //this.ClientOptions.Add("draggable", value);
            }
        }

        /// <summary>
        /// If set to true, the dialog will have modal behavior; other items on the page will be disabled
        /// (i.e. cannot be interacted with). Modal dialogs create an overlay below the dialog but above other page elements.
        /// </summary>
        /// <value>Default is false</value>
        [Browsable(true)]
        [DefaultValue(false)]
        [Themeable(true)]
        public bool Modal
        {
            get
            {
                return ClientOptions.Get<bool>("modal");
            }
            set
            {
                this.ClientOptions.Set("modal", value, false);
                //this.ClientOptions.Add("modal", value);
            }
        }

        /// <summary>
        /// Width of the dialog in pixels
        /// </summary>
        /// <exception cref="NotSupportedException">Width has been specified in some unit other than pixels</exception>
        /// <remarks>
        /// In most cases you will need to specify a reasonable width for the dialog. The default width 0f 300 pixels 
        /// could prove to be too small and scroll bars would appear. You will need to do some hit and trial
        /// to determine the appropriate width.
        /// </remarks>
        public override Unit Width
        {
            get
            {
                return base.Width;
            }
            set
            {
                if (value != Unit.Empty && value.Type != UnitType.Pixel)
                {
                    throw new NotSupportedException("Width can only be specified in pixels");
                }
                base.Width = value;
            }
        }

        /// <summary>
        /// Height of the dialog in pixels
        /// </summary>
        public int Height
        {
            get
            {
                return ClientOptions.Get<int>("height");
            }
            set
            {
                this.ClientOptions.Set("height", value, 0);
                //if (value != 0)
                //{
                //    this.ClientOptions.Add("height", value);
                //}
            }
        }
        private DialogPosition _position;

        /// <summary>
        /// Specifies where the dialog should be displayed.
        /// </summary>
        /// <value>Default value <see cref="DialogPosition.Center" /></value>
        [Browsable(true)]
        [DefaultValue(DialogPosition.Center)]
        public DialogPosition Position
        {
            get
            {
                return _position;
            }
            set
            {
                if (value != _position)
                {
                    //ClientOptions.Remove("position");
                    switch (value)
                    {
                        case DialogPosition.Center:
                        case DialogPosition.Left:
                        case DialogPosition.Right:
                        case DialogPosition.Top:
                        case DialogPosition.Bottom:
                            this.ClientOptions.Set("position", value.ToString().ToLower());
                            break;

                        case DialogPosition.LeftTop:
                            this.ClientOptions.AddRaw("position", "['left', 'top']");
                            break;

                        case DialogPosition.LeftBottom:
                            this.ClientOptions.AddRaw("position", "['left', 'bottom']");
                            break;

                        case DialogPosition.RightBottom:
                            this.ClientOptions.AddRaw("position", "['right', 'bottom']");
                            break;

                        case DialogPosition.RightTop:
                            this.ClientOptions.AddRaw("position", "['right', 'top']");
                            break;

                        default:
                            throw new NotImplementedException();
                    }
                    _position = value;
                }
            }
        }

        /// <summary>
        /// If set to true, the dialog will be resizeable.
        /// </summary>
        /// <value>Default value true</value>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool Resizable
        {
            get
            {
                return ClientOptions.Get<bool>("resizable", true);
            }
            set
            {
                this.ClientOptions.Set("resizable", value, true);
                //this.ClientOptions.Add("resizable", value);
            }
        }

        /// <summary>
        /// Specifies the title of the dialog.
        /// </summary>
        /// <include file='dialog.xml' path='Dialog/doc[@name="Title"]/*'/>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(true)]
        public string Title
        {
            get
            {
                //object obj;
                //bool b = this.ClientOptions.TryGetValue("title", out obj);
                //return b ? (string)obj : string.Empty;
                return this.ClientOptions.Get("title", string.Empty);
            }
            set
            {
                this.ClientOptions.Set("title", value, string.Empty);
                //this.ClientOptions.Add("title", value);
            }
        }

        /// <summary>
        /// Setting this to Picker makes the dialog use less space. The title and button bar is thinner.
        /// When <c>AlwaysVisible</c>, the dialog does not scroll with the page.
        /// </summary>
        /// <remarks>
        /// <para>
        /// If the value is <c>Picker</c>, existing dialogs will not automatically close.
        /// In the future, more possible values for <see cref="DialogStyle"/> might be added.
        /// </para>
        /// </remarks>
        public DialogStyle DialogStyle { get; set; }


        private AjaxDialogSettings _ajax;

        /// <summary>
        /// AJAX specific properties are set here
        /// </summary>
        /// <remarks>
        /// See See <a href="ff16f3a6-d63b-48cc-a0fb-438cd8c281a2.htm">Creating an AJAX Dialog</a>
        /// for a complete working example
        /// of an AJAX enable dialog.
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public AjaxDialogSettings Ajax
        {
            get
            {
                if (_ajax == null)
                {
                    _ajax = new AjaxDialogSettings();
                }
                return _ajax;
            }
        }

        private readonly Collection<DialogButton> _buttons = new Collection<DialogButton>();

        /// <summary>
        /// Buttons to be displayed in the dialog button bar
        /// </summary>
        /// <remarks>
        /// Buttons are rendered in the same order in which you add them to this list.
        /// For each button you specify the <see cref="DialogButton.Text"/> to display.
        /// Most commonly you will use and <see cref="ActionButton"/> and set its
        /// <see cref="ActionButton.OnClientClick"/> property which specifies
        /// the javascript to execute when the button is clicked.
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [Themeable(false)]
        [Bindable(true)]
        [NotifyParentProperty(true)]
        public Collection<DialogButton> Buttons
        {
            get
            {
                return _buttons;
            }
        }

        /// <summary>
        /// Content to be displayed in the content region of the dialog
        /// </summary>
        /// <remarks>
        /// If your content template contains buttons which are expected to post back the page, make sure you set
        /// <see cref="EnablePostBack"/> to true.
        /// </remarks>
        [
            Browsable(false),
            PersistenceMode(PersistenceMode.InnerProperty),
            DefaultValue(typeof(ITemplate), ""),
            Description("Control template"),
            TemplateInstance(TemplateInstance.Single)
        ]
        public ITemplate ContentTemplate { get; set; }


        #endregion

        #region Client Events
        /// <summary>
        /// This event is triggered when a dialog attempts to close.
        /// If the beforeclose event handler (callback function) returns false, the close will be prevented.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientBeforeClose
        {
            get
            {
                return this.ClientEvents["dialogbeforeclose"] ?? string.Empty;
                //return GetEvent("dialogbeforeclose");
            }
            set
            {
                this.ClientEvents["dialogbeforeclose"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when dialog is opened.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientOpen
        {
            get
            {
                return this.ClientEvents["dialogopen"] ?? string.Empty;
                //return GetEvent("dialogopen");
            }
            set
            {
                this.ClientEvents["dialogopen"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when the dialog gains focus.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientFocus
        {
            get
            {
                return this.ClientEvents["dialogfocus"] ?? string.Empty;
                //return GetEvent("dialogfocus");
            }
            set
            {
                this.ClientEvents["dialogfocus"] = value;
            }
        }

        /// <summary>
        /// This event is triggered at the beginning of the dialog being dragged.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientDragStart
        {
            get
            {
                return this.ClientEvents["dragStart"] ?? string.Empty;
                //return GetEvent("dragStart");
            }
            set
            {
                this.ClientEvents["dragStart"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when the dialog is dragged.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientDrag
        {
            get
            {
                return this.ClientEvents["drag"] ?? string.Empty;
                //return GetEvent("drag");
            }
            set
            {
                this.ClientEvents["drag"] = value;
            }
        }

        /// <summary>
        /// This event is triggered after the dialog has been dragged.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientDragStop
        {
            get
            {
                return this.ClientEvents["dragStop"] ?? string.Empty;
                //return GetEvent("dragStop");
            }
            set
            {
                this.ClientEvents["dragStop"] = value;
            }
        }

        /// <summary>
        /// This event is triggered at the beginning of the dialog being resized.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientResizeStart
        {
            get
            {
                return this.ClientEvents["resizeStart"] ?? string.Empty;
                //return GetEvent("resizeStart");
            }
            set
            {
                this.ClientEvents["resizeStart"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when the dialog is resized.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientResize
        {
            get
            {
                return this.ClientEvents["resize"] ?? string.Empty;
                //return GetEvent("resize");
            }
            set
            {
                this.ClientEvents["resize"] = value;
            }
        }

        /// <summary>
        /// This event is triggered after the dialog has been resized.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientResizeStop
        {
            get
            {
                return this.ClientEvents["resizeStop"] ?? string.Empty;
                //return GetEvent("resizeStop");
            }
            set
            {
                this.ClientEvents["resizeStop"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when the dialog is closed.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Themeable(false)]
        public string OnClientClose
        {
            get
            {
                return this.ClientEvents["dialogclose"] ?? string.Empty;
                //return GetEvent("dialogclose");
            }
            set
            {
                this.ClientEvents["dialogclose"] = value;
            }
        }
        #endregion

        #region Client Scripts

        protected override void OnPreRender(EventArgs e)
        {
            JQueryScriptManager.Current.AddTopLevelFocusable(this);
            base.OnPreRender(e);
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        protected override void PreCreateScripts()
        {
            JQueryOptions buttonOptions = new JQueryOptions();
            foreach (DialogButton btn in this.Buttons)
            {
                btn.AddButtonOption(this, buttonOptions);
            }

            ClientOptions.Add("buttons", buttonOptions);

            if (Buttons.Count > 0)
            {
                // If no button has been specified as default, use the cancel button. If no cancel button, use the first one.
                DialogButton defButton = Buttons.FirstOrDefault(p => p.IsDefault);
                if (defButton == null)
                {
                    defButton = Buttons.OfType<CloseButton>().FirstOrDefault();
                }
                if (defButton == null)
                {
                    // Use the first button as default
                    defButton = Buttons[0];
                }
                ClientOptions.Add("_defButtonText", defButton.Text);
            }

            if (this.EnablePostBack)
            {
                ClientOptions.Add("_enablePostBack", true);
            }
            if (_ajax != null)
            {
                _ajax.UpdateStartupOptions(this, this.ClientOptions);
            }
            if (this.Width != Unit.Empty)
            {
                if (this.Width.Type != UnitType.Pixel)
                {
                    throw new HttpException("Dialog width can only be specified in pixels");
                }
                this.ClientOptions.Add("width", this.Width.Value.ToString());
            }

            switch (this.DialogStyle)
            {
                case DialogStyle.Default:
                    break;

                case DialogStyle.Picker:
                    this.ClientOptions.Add("dialogClass", "ui-pickerdialog");
                    if (!this.ClientOptions.ContainsKey("modal"))
                    {
                        this.ClientOptions.Add("modal", true);
                    }
                    break;

                case DialogStyle.AlwaysVisible:
                    this.ClientOptions.Add("dialogClass", "ui-fixeddialog");
                    break;

                default:
                    throw new NotImplementedException();
            }
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.AjaxDialog);

            if (JQueryScriptManager.IsAjaxCall && this.Page.Form != null && _ajax != null && _ajax.UseDialog)
            {
                // Make sure we get destroyed if and when the page posts back
                string script = string.Format(@"$('#{0}').submit(function(e) {{
    $('#{1}').dialog('destroy').remove();
}});", this.Page.Form.ClientID, this.ClientID);
                JQueryScriptManager.Current.RegisterReadyScript(script);
            }
        }
        #endregion

        #region Rendering
        /// <summary>
        /// Client script assumes that the remote HTML is loaded in the first div with the outermost div
        /// </summary>
        /// <param name="writer"></param>
        /// <remarks>
        /// Resulting Markup:
        /// <code>
        /// <![CDATA[
        ///<div id="clientid" class="ui-ajax-dialog">
        ///   <div>
        ///   ... remote HTML ...
        ///   </div>
        ///   <div>
        ///   ...dialog child controls of content template...
        ///   </div>
        ///</div>
        ///]]>
        ///</code>
        /// The content template is invisible until the ajax page is loaded.
        /// </remarks>
        protected override void RenderChildren(HtmlTextWriter writer)
        {
            // Remote page is always its own validation container
            writer.AddAttribute(HtmlTextWriterAttribute.Class, JQueryScriptManager.CssClassValidationContainer);
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.RenderEndTag();
            if (this.IsValidationContainer)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Class, JQueryScriptManager.CssClassValidationContainer);
            }
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            base.RenderChildren(writer);        // Content template
            writer.RenderEndTag();
        }

        /// <summary>
        /// Adds the ui-ajax-dialog class. This makes it possible to search for dialogs using jQuery selectors.
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            cssClasses.Add("ui-ajax-dialog");
            base.AddAttributesToRender(attributes, cssClasses);
        }
        #endregion

        #region IValidationContainer Members

        /// <summary>
        /// A dialog is always a validation container
        /// </summary>
        /// <value>Always returns true. Cannot be set.</value>
        [Browsable(false)]
        public bool IsValidationContainer
        {
            get
            {
                return true;
            }
            set
            {

            }
        }

        #endregion

        #region IFocusable Members

        public FocusPriority FocusPriority
        {
            get {
                return FocusPriority.NotAllowed;
            }
        }

        #endregion
    }
}

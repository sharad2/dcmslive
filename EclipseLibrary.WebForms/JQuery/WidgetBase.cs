using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;
using EclipseLibrary.Web.JQuery.Scripts;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Serves as a base class for all widgets
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Themeable(true)]
    public abstract class WidgetBase : Control
    {
        private string _widgetName;

        /// <summary>
        /// You can change this in PreCreateScripts if necessary. Setting it to empty will prevent ready script generation.
        /// </summary>
        [Browsable(false)]
        protected string WidgetName
        {
            get { return _widgetName; }
            set { _widgetName = value; }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="widgetName"></param>
        protected WidgetBase(string widgetName)
        {
            _clientOptions = new JQueryOptions();
            _widgetName = widgetName;
            _clientEvents = new MultiKeyDictionary<string, string>();
            this.Enabled = true;
// ReSharper disable DoNotCallOverridableMethodsInConstructor
            this.EnableViewState = false;
// ReSharper restore DoNotCallOverridableMethodsInConstructor
        }

        #region Styles

        private readonly HashSet<string> _cssClasses = new HashSet<string>();

        /// <summary>
        /// Comma seperated list of the css classes to apply to this widget. Provided for use in markup.
        /// </summary>
        [Browsable(true)]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] CssClasses
        {
            get
            {
                return _cssClasses.ToArray();
            }
            set
            {
                _cssClasses.Clear();
                if (value != null)
                {
                    foreach (string cssclass in value)
                    {
                        _cssClasses.Add(cssclass);
                    }
                }
            }
        }

        /// <summary>
        /// Add a css class to the list of css classes which will be applied to this widget.
        /// </summary>
        /// <param name="cssClass"></param>
        /// <remarks>
        /// This is useful if you want to add an additional class to the widget. By contrast
        /// <see cref="CssClasses"/> requires an array of classes and it clears all existing classes.
        /// </remarks>
        public void AddCssClass(string cssClass)
        {
            _cssClasses.Add(cssClass);
        }

        /// <summary>
        /// Width of the widget. Virtual because <see cref="Dialog"/> overrides it.
        /// </summary>
        [Browsable(true)]
        public virtual Unit Width { get; set; }

        /// <summary>
        /// Whether the widget is enabled. Default <c>true</c>
        /// </summary>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool Enabled
        {
            get;
            set;
        }

        /// <summary>
        /// Returns true only if all containing widgets/web controls are enabled.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This allows for inheriting the <see cref="Enabled"/> property of containing controls. Therefore if you set Enabled=false
        /// for the containing form view, this control will behave as disabled also.
        /// </para>
        /// </remarks>
        internal bool IsEnabled
        {
            get
            {
                return this.Enabled && this.Ancestors(false).All(p => (!(p is WebControl) || ((WebControl)p).Enabled) &&
                    (!(p is WidgetBase) || ((WidgetBase)p).Enabled));
            }
        }

        #endregion

        #region Client Properties

        private readonly JQueryOptions _clientOptions;

        /// <summary>
        /// Key is event name, value is function name
        /// </summary>
        private readonly MultiKeyDictionary<string, string> _clientEvents;

        /// <summary>
        /// Options to be passed to the associated client widget class
        /// </summary>
        [Browsable(false)]
// ReSharper disable MemberCanBeProtected.Global
        public JQueryOptions ClientOptions
// ReSharper restore MemberCanBeProtected.Global
        {
            get
            {
                return _clientOptions;
            }
        }

        /// <summary>
        /// Event bindings for this widget.
        /// </summary>
        public IDictionary<string, string> ClientEvents
        {
            get
            {
                return _clientEvents;
            }
        }


        /// <summary>
        /// The JQuery selector to use for selecting this element.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The selector generated prefixes the <c>ClientId</c> with <c>#</c>.
        /// Sample client selectors might look like <c>#tbBucketId</c>, or <c>#mytb</c>.
        /// </para>
        /// <para>
        /// If <c>ClientID</c> has not been specified, then it changes <c>ClientIDMode</c> to <c>AutoID</c> to guarantee
        /// that the selector will be usable.
        /// </para>
        /// </remarks>
        [Browsable(false)]
        public string ClientSelector
        {
            get
            {
                if (string.IsNullOrEmpty(this.ClientID))
                {
                    this.ClientIDMode = ClientIDMode.AutoID;
                    // This can happen if the control has not been added to the page
                    //throw new HttpException("ID must be specified");
                } 
                return string.Format("#{0}", this.ClientID);
            }

        }
        #endregion

        #region Client Scripts

        private List<string> _readyScripts;

        /// <summary>
        /// The added script should be chainable. e.g. "bind('click', function(e) { ...})"
        /// Do not terminate with semicolon.
        /// </summary>
        [Browsable(false)]
        public List<string> ReadyScripts
        {
            get { return _readyScripts ?? (_readyScripts = new List<string>()); }
        }

        /// <summary>
        /// Hooks to the PreRenderComplete event. Scripts are needed only if we will be rendered
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            JQueryScriptManager.Current.CreateScripts += JQueryScriptManager_CreateScripts;
            base.OnPreRender(e);
        }

// ReSharper disable InconsistentNaming
        private void JQueryScriptManager_CreateScripts(object sender, EventArgs e)
// ReSharper restore InconsistentNaming
        {
            if (this.Visible)
            {
                RegisterScripts();
            }
        }

        /// <summary>
        /// This is public so that you can call it yourself for controls which have not been added to the page.
        /// It should be called during the Page PreRenderComplete event or from the PreCreateScripts() override in a 
        /// widget derived class.
        /// </summary>
        public void RegisterScripts()
        {
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.UiCore);
            StringBuilder sb = new StringBuilder();
            if (!this.IsEnabled)
            {
                this.ClientOptions.Add("disabled", true);
            }
            PreCreateScripts();
            if (!string.IsNullOrEmpty(this._widgetName))
            {
                sb.AppendFormat(".{0}({1})", this._widgetName, _clientOptions.ToJson());
            }
            foreach (var item in _clientEvents)
            {
                sb.AppendFormat(".bind('{0}', {1})", item.Key, item.Value);
            }

            if (_readyScripts != null)
            {
                foreach (var item in _readyScripts)
                {
                    sb.Append(item);
                }
            }
            if (sb.Length > 0)
            {
                sb.Insert(0, string.Format("$('{0}')", this.ClientSelector));
                sb.Append(";");
                JQueryScriptManager.Current.RegisterReadyScript(sb.ToString());
            }
        }

        /// <summary>
        /// This is a good time to update your widget name or set it to empty. Also update ClientEvents and
        /// ClientOptions. ReadyScripts should also be updated here.
        /// </summary>
        protected abstract void PreCreateScripts();
        #endregion

        #region Rendering

        /// <summary>
        /// Call the rendering virtual methods to help the derived classes render themselves
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            Dictionary<HtmlTextWriterAttribute, string> attributes = new Dictionary<HtmlTextWriterAttribute, string>();
            AddAttributesToRender(attributes, _cssClasses);
            foreach (var item in attributes)
            {
                writer.AddAttribute(item.Key, item.Value);
            }
            if (_cssClasses.Count > 0)
            {
                string str = string.Join(" ", _cssClasses.ToArray());
                writer.AddAttribute(HtmlTextWriterAttribute.Class, str);
            }
            Dictionary<HtmlTextWriterStyle, string> styles = new Dictionary<HtmlTextWriterStyle, string>();
            Dictionary<string, string> stylesSpecial = new Dictionary<string, string>();
            AddStylesToRender(styles, stylesSpecial);
            foreach (var item in styles)
            {
                writer.AddStyleAttribute(item.Key, item.Value);
            }
            foreach (var item in stylesSpecial)
            {
                writer.AddStyleAttribute(item.Key, item.Value);
            }
            writer.RenderBeginTag(TagKey);
            RenderContents(writer);
            writer.RenderEndTag();

        }

        /// <summary>
        /// Simply calls <see cref="Control.RenderChildren"/>
        /// </summary>
        /// <param name="writer"></param>
        protected virtual void RenderContents(HtmlTextWriter writer)
        {
            RenderChildren(writer);
        }

        /// <summary>
        /// Returns DIV
        /// </summary>
        protected virtual HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Div;
            }
        }

        /// <summary>
        /// We attempt to avoid generating the client id to save on markup length
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses">The classes which will be applied to this widget</param>
        /// <remarks>
        /// <para>
        /// Passed <c>cssClasses</c> include the classes specified by the developer via the <see cref="CssClasses"/> property.
        /// </para>
        /// </remarks>
        protected virtual void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            if (string.IsNullOrEmpty(this.ClientID))
            {
                //if (this.ClientIdRequired)
                //{
                //    throw new InvalidOperationException("When ClientIdRequired=true, an ID must be specified");
                //}
            }
            else
            {
                // Client ID can be null when widget has not been added to the page. This is common for buttons.
                // If ClientIdSameAsId=true, then the user intends to use id within the script so we must always generate it
                //if (this.ClientIdRequired || this.ClientIDMode == ClientIDMode.Static || _scriptsNeeded)
                //{
                    attributes.Add(HtmlTextWriterAttribute.Id, this.ClientID);
                //}
            }
        }

        /// <summary>
        /// Adds the width attribute if specified
        /// </summary>
        /// <param name="styles"></param>
        /// <param name="stylesSpecial"></param>
        protected virtual void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            if (this.Width != Unit.Empty)
            {
                styles.Add(HtmlTextWriterStyle.Width, this.Width.ToString());
            }
        }
        #endregion

        /// <summary>
        /// The default of the base class is Browsable(false) so we override it here
        /// </summary>
        [Browsable(true)]
        public override string SkinID
        {
            get
            {
                return base.SkinID;
            }
            set
            {
                base.SkinID = value;
            }
        }

        public override void Focus()
        {
            throw new NotSupportedException();
        }
    }
}

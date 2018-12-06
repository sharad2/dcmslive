using System;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using EclipseLibrary.Web.Extensions;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Provides a tabbed interface.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Uses the jQuery UI tabs widget. The selected tab can be remembered across postbacks if you set
    /// <see cref="EnableClientState"/> to true. Each time a new tab is selected, the first focusable element receives focus.
    /// If <see cref="Animated"/> is set to true, a nice animation will be performed.
    /// </para>
    /// <para>
    /// Sharad 19 Jan 2010: If a JPanel ID is specified, it must contain an _ in jax pages. This is done to 
    /// ensure that the ID is globally unique.
    /// </para>
    /// </remarks>
    [ToolboxData(@"<{0}:Tabs runat=server>
        <{0}:JPanel runat=""server"" HeaderText=""Tab 1"">
            This is the content of tab 1
        </{0}:JPanel>
        <{0}:JPanel ID=""JPanel1"" runat=""server"" HeaderText=""Tab 2"">
            This is the content of tab 2
        </{0}:JPanel>
</{0}:Tabs>")]
    [ParseChildren(typeof(JPanel))]
    [PersistChildren(true)]
    public class Tabs : WidgetBase, IPostBackDataHandler, IFocusable
    {
        public Tabs()
            : base("tabs")
        {
            this.ClientOptions.Add("collapsible", true);
        }

        #region Options
        /// <summary>
        /// Whether all tabs can be collapsed
        /// </summary>
        /// <remarks>
        /// <para>
        /// Sharad 25 Oct 2010: Fixed but. The default was pecified wrong.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool Collapsible
        {
            get
            {
                return ClientOptions.Get<bool>("collapsible", false);
            }
            set
            {
                this.ClientOptions.Set("collapsible", value, false);
                //this.ClientOptions.Add("collapsible", value);
            }
        }

        /// <summary>
        /// Index of the selected tab
        /// </summary>
        [Browsable(true)]
        [DefaultValue(0)]
        public int Selected
        {
            get
            {
                return ClientOptions.Get<int>("selected");
            }
            set
            {
                this.ClientOptions.Set("selected", value, 0);
                //this.ClientOptions.Add("selected", value);
            }
        }

        /// <summary>
        /// Whether to perform animation when a new tab is made active
        /// </summary>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool Animated { get; set; }
        #endregion

        #region Client Events
        /// <summary>
        /// This event is triggered when a tab is shown.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string OnClientShow
        {
            get
            {
                return this.ClientEvents["tabsshow"] ?? string.Empty;
                //return GetEvent("tabsshow");
            }
            set
            {
                this.ClientEvents["tabsshow"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when a tab is shown.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string OnClientSelect
        {
            get
            {
                return this.ClientEvents["tabsselect"] ?? string.Empty;
                //return GetEvent("tabsselect");
            }
            set
            {
                this.ClientEvents["tabsselect"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when a tab is enabled.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string OnClientEnable
        {
            get
            {
                return this.ClientEvents["tabsenable"] ?? string.Empty;
                //return GetEvent("tabsenable");
            }
            set
            {
                this.ClientEvents["tabsenable"] = value;
            }
        }

        /// <summary>
        /// This event is triggered when a tab is disabled.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string OnClientDisable
        {
            get
            {
                return this.ClientEvents["tabsdisable"] ?? string.Empty;
                //return GetEvent("tabsdisable");
            }
            set
            {
                this.ClientEvents["tabsdisable"] = value;
            }
        }
        #endregion


        /// <summary>
        /// Whether the selected tab index should be remembered across postbacks
        /// </summary>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool EnableClientState { get; set; }

        protected override void AddParsedSubObject(object obj)
        {
            JPanel objTabPanel = obj as JPanel;
            if (null != objTabPanel)
            {
                Controls.Add(objTabPanel);
            }
            else if (!(obj is LiteralControl))
            {
                throw new HttpException(string.Format("The children {0}, ID {1} must be of type {2}. Type {2} is not allowed.",
                    this.GetType(), this.ID, typeof(JPanel), obj.GetType()));
            }
        }

        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Div;
            }
        }

        /// <summary>
        /// Add the ui-tabs class in advance to prevent flickering
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(System.Collections.Generic.IDictionary<HtmlTextWriterAttribute, string> attributes, System.Collections.Generic.ICollection<string> cssClasses)
        {
            base.AddAttributesToRender(attributes, cssClasses);
            cssClasses.Add("ui-tabs");
        }

        /// <summary>
        /// Render the hidden field if client state is enabled
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            if (this.EnableClientState)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Name, this.UniqueID);
                writer.AddAttribute(HtmlTextWriterAttribute.Value, Selected.ToString());
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
                writer.RenderBeginTag(HtmlTextWriterTag.Input);
                writer.RenderEndTag();      // input
            }
            base.RenderContents(writer);
        }

        /// <summary>
        /// Apply styles in advance to prevent screen flicker
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderChildren(HtmlTextWriter writer)
        {
            writer.RenderBeginTag(HtmlTextWriterTag.Ul);
            int i = 0;
            foreach (JPanel panel in this.Controls.OfType<JPanel>().Where(p => p.Visible))
            {
                // Hide the tab in advance to prevent flicker
                if (i != this.Selected)
                {
                    panel.AddCssClass("ui-tabs-hide");
                }
                ++i;
                writer.RenderBeginTag(HtmlTextWriterTag.Li);
#if DEBUG
                if (JQueryScriptManager.IsAjaxCall)
                {
                    if (!string.IsNullOrEmpty(panel.ID) && !panel.ID.Contains("_"))
                    {
                        // In AJAX pages, the ID of each JPanel must be prefixed with something unique
                        // to avoid the possibility of duplicate IDs. For example, frmCartonDetails_filters
                        // is a reasonable id
                        string str = string.Format(@"In AJAX pages, 
the ID of each JPanel within Tabs {0} must have a unique prefix, e.g. frmCartonDetails_filters.
The ID {1} does not contain an _.", this.ID, panel.ID);
                        throw new HttpException(str);
                    }
                }
#endif
                //writer.AddAttribute(HtmlTextWriterAttribute.Href, string.Format("#{0}", panel.ClientID));
                writer.AddAttribute(HtmlTextWriterAttribute.Href, panel.ClientSelector);
                // Tab key should not navigate to tab headers.
                writer.AddAttribute(HtmlTextWriterAttribute.Tabindex, "-1");
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                if (!string.IsNullOrEmpty(panel.ToolTip))
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Title, panel.ToolTip);
                    panel.ToolTip = string.Empty;
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                writer.Write(panel.HeaderText);
                writer.RenderEndTag();              // span
                writer.RenderEndTag();              // a
                writer.RenderEndTag();              // li
            }
            writer.RenderEndTag();              // ul
            //}
            base.RenderChildren(writer);
        }

        /// <summary>
        /// Returns the index of the tab in which the control exists. Throws exception if
        /// control not found.
        /// </summary>
        /// <param name="ctl"></param>
        /// <returns></returns>
        /// <remarks>
        /// Keep looking at the parent until we find one of our JPanels. Then figure out its
        /// index and return it.
        /// </remarks>
        public int TabIndexOfControl(Control ctl)
        {
            JPanel jpChild = null;
            // save this control for the purpose of using in the case of exception. 
            Control passedControl = ctl;
            while (ctl != this && ctl != null)
            {
                ctl = ctl.Parent;
                JPanel jp = ctl as JPanel;
                if (jp != null && jp.Parent == this)
                {
                    jpChild = jp;
                    break;
                }
            }
            if (jpChild == null)
            {
                // control id does not exist in tab container ...
                throw new ArgumentOutOfRangeException(string.Format("Control {0} not found.", passedControl.ID));
            }
            int index = this.Controls.IndexOf(jpChild);
            return index;
        }

        protected override void OnPreRender(EventArgs e)
        {
            JQueryScriptManager.Current.AddTopLevelFocusable(this);
            base.OnPreRender(e);
        }

        #region WidgetBase overrides

        /// <summary>
        /// Attach scripts to set intitial focus when the tab is clicked
        /// </summary>
        protected override void PreCreateScripts()
        {
            // When a tab is clicked, set focus to first focusable element
            // The timeout appears to be necessary for focus to work properly when contents have been AJAX loaded.
            string script = @"function(event, ui) {
setTimeout(function() {
    $(':input:not(:button):focusable:first', $(ui.panel)).focus();
}, 0);
}";

            this.ClientEvents.Add("tabsselect", script);

            if (this.EnableClientState)
            {
                // In the function, this refers to the UL element. Find the first input element of the parent
                // and use it to save state. Not using the :hidden selector so that we can make it non hidden while
                // debugging and still expect it to work
                script = "function (event, ui) { $('input:first', this).val(ui.index); }";
                this.ClientEvents.Add("tabsshow", script);
            }

            if (this.Animated)
            {
                this.ClientOptions.AddRaw("fx", "{ height: 'toggle', duration: 'fast' }");
            }
        }
        #endregion

        #region IPostBackDataHandler Members

        public bool LoadPostData(string postDataKey, NameValueCollection postCollection)
        {
            string str = postCollection[postDataKey];
            if (!string.IsNullOrEmpty(str))
            {
                Selected = int.Parse(str);
            }
            return false;
        }

        public void RaisePostDataChangedEvent()
        {
            throw new NotImplementedException("Call not expected");
        }

        #endregion

        #region IFocusable Members

        private IFocusable _focusControl;

        public FocusPriority FocusPriority
        {
            get
            {
                // It is possible that no tab is selected
                if (_focusControl == null && this.Selected >= 0)
                {
                    _focusControl = this.Controls[this.Selected].Descendants(p => !(p is IFocusable)).OfType<IFocusable>()
                       .OrderBy(p => p.FocusPriority).FirstOrDefault();
                }
                if (_focusControl == null)
                {
                    return FocusPriority.NotAllowed;
                }
                else
                {
                    return _focusControl.FocusPriority;
                }
            }
        }

        public override void Focus()
        {
            _focusControl.Focus();
        }

        #endregion
    }
}

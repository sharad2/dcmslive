using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using EclipseLibrary.Web.Extensions;
using System;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// A simple wrapper to the jQuery Accordion widget
    /// </summary>
    /// <remarks>
    /// <para>
    /// This is a simple wrapper to the jQuery Accordion widget with very few additional features.
    /// By default, at least one pane will always remain open unless you set <see cref="Collapsible"/>
    /// to true. Use one or more <see cref="JPanel"/> controls to define each pane. The 
    /// <see cref="JPanel.HeaderText"/> is the header text which displays for each accordion pane
    /// and <see cref="JPanel.ToolTip"/> is the associated tool tip.
    /// Use <see cref="SelectedIndex"/> to decide which pane should be initially visible.
    /// </para>
    /// <para>
    /// <see cref="JPanel.SubHeaderText"/> can be used to display additional information in the header
    /// of each pane. This is useful for drawing attention to specific panes.
    /// <see cref="SubHeadersAsError"/> property can be used to make the sub headers look like an
    /// error condition.
    /// </para>
    /// <para>
    /// Whenever an accordion pane is opened, the focus is set to the first focusable
    /// control in the pane now becoming visible.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// Typical markup.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <jquery:Accordion runat="server">
    ///     <jquery:JPanel runat="server" HeaderText="Basic">
    ///         Contents of Pane 1
    ///     </jquery:JPanel>
    ///     <jquery:JPanel runat="server" HeaderText="Step 1: Assign Carriers">
    ///         Contents of Pane 2
    ///     </jquery:JPanel>
    /// </jquery:Accordion>
    /// ]]>
    /// </code>
    /// </example>
    [ParseChildren(typeof(JPanel))]
    [PersistChildren(true)]
    public class Accordion : WidgetBase, IFocusable
    {
        /// <summary>
        /// 
        /// </summary>
        public Accordion()
            : base("accordion")
        {
            this.Animated = true;
        }

        /// <summary>
        /// Setting this to true associates ui-state-error class with each subheader.
        /// </summary>
        [Browsable(true)]
        [DefaultValue(false)]
        [Themeable(true)]
        public bool SubHeadersAsError { get; set; }

        /// <summary>
        /// Whether it is ok to close all panes
        /// </summary>
        [Browsable(true)]
        [DefaultValue(false)]
        [Description("Whether it is ok to close all panes")]
        [Category("Behavior")]
        public bool Collapsible
        {
            get
            {
                return ClientOptions.Get<bool>("collapsible", true);
            }
            set
            {
                this.ClientOptions.Set("collapsible", value, false);
                //this.ClientOptions.Add("collapsible", value);
            }
        }

        /// <summary>
        /// The index of the pane to open by default.
        /// If  Collapsible=true, you can also set this to -1 if you do not want any pane open
        /// </summary>
        /// <remarks>
        /// If the pane which should open depends on business logic, you can set this property through code.
        /// To avoid hardwiring the index in your code, you can detrmine the index of a particular <see cref="JPanel"/>
        /// using code similar to this:
        /// <code>
        /// <![CDATA[
        /// <jquery:Accordion runat="server" ID="accSteps" EnableViewState="true" Collapsible="true" AutoHeight="false" 
        /// SubHeadersAsError="true">
        ///      <jquery:JPanel runat="server" ID="jpAssignCarriers" HeaderText="Step 1: Assign Carriers" EnableViewState="true">
        ///      </jquery:JPanel>
        ///         ......
        ///  </jquery:Accordion>
        /// ]]>
        /// </code>
        /// <code>
        /// <![CDATA[
        ///     accSteps.SelectedIndex = accSteps.Controls.IndexOf(jpAssignCarriers);
        ///     ]]>
        /// </code>
        /// </remarks>
        [Browsable(true)]
        [Category("Behavior")]
        [Description("Index of the AccordionPane to be displayed")]
        [DefaultValue(0)]
        public int SelectedIndex
        {
            get;
            set;
        }

        /// <summary>
        /// Whether all panes should be of the same height
        /// </summary>
        [Browsable(true)]
        [Category("Behavior")]
        [Description("Whether all panes should be of the same height")]
        [DefaultValue(false)]
        public bool AutoHeight
        {
            get
            {
                return ClientOptions.Get<bool>("autoHeight", true);
            }
            set
            {
                this.ClientOptions.Set("autoHeight", value, true);
            }
        }

        /// <summary>
        /// Javascript function to call when selected accordion pane changes
        /// </summary>
        /// <remarks>
        /// <para>
        /// The function is passed a <c>ui</c> object which contains this information:
        /// </para>
        /// <code>
        /// <![CDATA[
        /// function(event, ui) {
        ///  ui.newHeader // jQuery object, activated header
        ///  ui.oldHeader // jQuery object, previous header
        ///  ui.newContent // jQuery object, activated content
        ///  ui.oldContent // jQuery object, previous content
        ///})
        /// ]]>
        /// </code>
        /// </remarks>
        [Browsable(true)]
        [Category("Behavior")]
        [Description("Javascript function to call when selected accordion pane changes")]
        [DefaultValue("")]
        public string OnClientChange
        {
            get
            {
                return this.ClientEvents["accordionchange"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["accordionchange"] = value;
            }
        }

        /// <summary>
        /// Disable animations if you have tab control or highly dynicamic content within accordion panes
        /// </summary>
        [Browsable(true)]
        [Category("Behavior")]
        [Description("Whether to apply animations when displaying the panel")]
        [DefaultValue(true)]
        public bool Animated { get; set; }

        /// <summary>
        /// Ensure that only <c>JPanel</c> can be added as a child
        /// </summary>
        /// <param name="obj"></param>
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

        /// <summary>
        /// Add disabled class if necessary
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            if (!this.IsEnabled)
            {
                cssClasses.Add("ui-state-disabled");
            }
            base.AddAttributesToRender(attributes, cssClasses);
        }

        /// <summary>
        /// Render the headers of each visible JPanel
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderChildren(HtmlTextWriter writer)
        {
            foreach (JPanel p in this.Controls.OfType<JPanel>().Where(p => p.Visible))
            {
                writer.RenderBeginTag(HtmlTextWriterTag.H3);
                writer.AddAttribute(HtmlTextWriterAttribute.Href, "#");
                writer.AddAttribute(HtmlTextWriterAttribute.Title, p.ToolTip);
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.Write(p.HeaderText);

                if (!string.IsNullOrEmpty(p.SubHeaderText))
                {
                    List<string> cssClasses = new List<string>(2);
                    cssClasses.Add("ui-accordion-subheader");
                    if (this.SubHeadersAsError)
                    {
                        cssClasses.Add("ui-state-error");
                    }
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, string.Join(" ", cssClasses.ToArray()));
                    writer.RenderBeginTag(HtmlTextWriterTag.Span);
                    writer.Write(p.SubHeaderText);
                    writer.RenderEndTag();          // span
                }
                writer.RenderEndTag();          // a
                writer.RenderEndTag();          // h3

                p.RenderControl(writer);
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            JQueryScriptManager.Current.AddTopLevelFocusable(this);
            base.OnPreRender(e);
        }
        /// <summary>
        /// Set the accordion options
        /// </summary>
        protected override void PreCreateScripts()
        {
            ClientOptions.Add("header", "> h3");
            if (this.SelectedIndex == -1)
            {
                ClientOptions.Add("active", false);
            }
            else
            {
                ClientOptions.Add("active", this.SelectedIndex);
            }
            if (this.Animated)
            {
                ClientOptions.Add("animated", "slide");
            }
            else
            {
                ClientOptions.Add("animated", false);
            }
            ClientOptions.AddRaw("change", @"function(event, ui) {
$(':focusable:first', ui.newContent).focus();
}");
        }

        #region IFocusable Members

        private IFocusable _focusControl;

        /// <summary>
        /// Returns the focus priority of the first control in the selected pane
        /// </summary>
        public FocusPriority FocusPriority
        {
            get
            {
                // It is possible that no accordion pane is open
                if (_focusControl == null && this.SelectedIndex >= 0)
                {
                    _focusControl = this.Controls[this.SelectedIndex].Descendants().OfType<IFocusable>()
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

        /// <summary>
        /// Delegates focus to the focus control which was selected in FocusPriority
        /// </summary>
        public override void Focus()
        {
            _focusControl.Focus();
        }

        #endregion
    }
}

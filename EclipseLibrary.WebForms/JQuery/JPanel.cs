using System.Collections.Generic;
using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery.Input;


namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// A simple container for other controls designed to be used by widgets such as <see cref="Tabs"/>
    /// and <see cref="Accordion"/>. It also serves as a <c>ValidationContainer</c>
    /// </summary>
    [ParseChildren(false)]
    [PersistChildren(true)]
    public class JPanel:WidgetBase, IValidationContainer
    {
        public JPanel():base(string.Empty)
        {
            //this.ClientIdRequired = true;
        }

        protected override void OnInit(System.EventArgs e)
        {
            ButtonEx.RegisterValidationContainer(this);
            base.OnInit(e);
        }

        protected override void PreCreateScripts()
        {
            // No scripts needed
        }
        /// <summary>
        /// This class by itself does nothing with the <c>HeaderText</c>. Enclosing containers
        /// such as <see cref="Tabs"/> render it as the header of their panel
        /// </summary>
        [Browsable(true)]
        public string HeaderText
        {
            get
            {
                return ((string)ViewState["HeaderText"]) ?? string.Empty;
            }
            set
            {
                ViewState["HeaderText"] = value;
            }
        }

        /// <summary>
        /// <see cref="Accordion"/> can display additional detail in the header.
        /// </summary>
        [Browsable(true)]
        public string SubHeaderText { get; set; }

        /// <summary>
        /// The height of this panel. If specified, adds the height style attribute
        /// </summary>
        public Unit Height { get; set; }

        ///// <summary>
        ///// One or more space seperated Css classes to apply to the panel
        ///// </summary>
        //public string CssClass { get; set; }

        /// <summary>
        /// This class by itself does nothing with the <c>ToolTip</c>. Enclosing containers
        /// such as <see cref="Tabs"/> may render it as the tool tip of their header.
        /// </summary>
        [Browsable(true)]
        public string ToolTip { get; set; }

        private Dictionary<HtmlTextWriterStyle, string> _styles;

        /// <summary>
        /// Allows containing widgets to add styles which should be rendered
        /// </summary>
        public IDictionary<HtmlTextWriterStyle, string> Style
        {
            get
            {
                if (_styles == null)
                {
                    _styles = new Dictionary<HtmlTextWriterStyle, string>();
                }
                return _styles;
            }

        }

        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            if (this.IsValidationContainer)
            {
                cssClasses.Add(JQueryScriptManager.CssClassValidationContainer);
            }
            base.AddAttributesToRender(attributes, cssClasses);
        }

        protected override void AddStylesToRender(IDictionary<HtmlTextWriterStyle, string> styles, IDictionary<string, string> stylesSpecial)
        {
            if (this.Height != Unit.Empty)
            {
                styles.Add(HtmlTextWriterStyle.OverflowY, "auto");
            }
            if (_styles != null)
            {
                foreach (var item in _styles)
                {
                    styles.Add(item.Key, item.Value);
                }
            }
            base.AddStylesToRender(styles, stylesSpecial);
        }

        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Div;
            }
        }

        #region IValidationContainer Members

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        public bool IsValidationContainer
        {
            get;
            set;
        }

        #endregion

        public override string ToString()
        {
            return string.Format("JPanel ID={0}; Tag: {1}; IsValidationContainer: {2}", this.ID, this.TagKey, this.IsValidationContainer);
        }
    }
}

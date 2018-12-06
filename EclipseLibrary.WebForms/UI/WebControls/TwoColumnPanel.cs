/* $Id: TwoColumnPanel.cs 37951 2010-11-25 14:21:41Z ssinghal $ */
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery;
using EclipseLibrary.Web.JQuery.Input;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// Defines the properties needed to serve as the left column of TwoColumnPanel
    /// </summary>
    internal interface ILeftColumn
    {
        /// <summary>
        /// Whether the corresponding right column should be treated as invisible also
        /// </summary>
        bool RowVisible
        {
            get;
            set;
        }

        /// <summary>
        /// Whether the left column should span to include the right column
        /// </summary>
        bool Span
        {
            get;
            set;
        }
    }

    /// <summary>
    /// This column can serve as a hot key for the first input control in the corresponding right column.
    /// The hot key is chosen from the Text displayed by the control. The control which implements this must have the
    /// ability to render the HTML label tag.
    /// </summary>
    /// <remarks>
    /// Sharad 15 Jul 2009: If Left label text is not specified, it is automatically set to the associated control's friendly name.
    /// Sharad 31 Jul 2009: Never let space become an access key
    /// Sharad 6 Aug 2009: If the associated control is invisible, we make the whole row invisible
    /// </remarks>
    internal interface IHotKeyLeftColumn:ILeftColumn, ITextControl
    {
        /// <summary>
        /// The access key which the control should try to display as highlighted
        /// </summary>
        string AccessKey
        {
            get;
            set;
        }

        /// <summary>
        /// The control which should receive focus when the hot key is used
        /// </summary>
        string AssociatedControlID
        {
            get;
            set;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// 
    [ParseChildren(false)]
    [PersistChildren(true)]
    [Designer(typeof(System.Web.UI.Design.ContainerControlDesigner))]
    [ToolboxData(@"
<{0}:TwoColumnPanel runat=""server"">
    <{0}:LeftLabel runat=""server"" Text=""LeftLabel"" />
</{0}:TwoColumnPanel>
")]
    [Themeable(true)]
    public sealed class TwoColumnPanel:Control, IValidationContainer
    {
        /// <summary>
        /// 
        /// </summary>
        public TwoColumnPanel()
        {
            this.Caption = string.Empty;
        }

        protected override void OnInit(EventArgs e)
        {
            ButtonEx.RegisterValidationContainer(this);
            base.OnInit(e);
        }

        #region Properties

        private string _leftCssClass = string.Empty;

        /// <summary>
        /// Css class to apply to the left column
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Description("Style to apply to the left column")]
        [Category("Style")]
        [Themeable(true)]
        public string LeftCssClass
        {
            get { return _leftCssClass; }
            set { _leftCssClass = value; }
        }

        private string _rightCssClass = string.Empty;

        /// <summary>
        /// The css class to apply to the right column
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Description("Style to apply to the right column")]
        [Category("Style")]
        [Themeable(true)]
        public string RightCssClass
        {
            get { return _rightCssClass; }
            set { _rightCssClass = value; }
        }


        private string _cssClass = string.Empty;

        /// <summary>
        /// Css class to apply to the table
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Description("Style to apply to the outer table")]
        [Category("Style")]
        [Themeable(true)]
        public string CssClass
        {
            get { return _cssClass; }
            set { _cssClass = value; }
        }

        /// <summary>
        /// Themable false because we expect that this will be different for each panel
        /// </summary>
        [Browsable(true)]
        [Description("Width of the left column")]
        [Category("Appearance")]
        [Themeable(false)]
        [DefaultValue(typeof(Unit), "")]
        public Unit WidthLeft { get; set; }

        /// <summary>
        /// Themable false because we expect that this will be different for each panel
        /// </summary>
        [Browsable(true)]
        [Description("Width of the right column")]
        [Category("Appearance")]
        [Themeable(false)]
        [DefaultValue(typeof(Unit), "")]
        public Unit WidthRight { get; set; }

        /// <summary>
        /// Height of the panel
        /// </summary>
        [Browsable(true)]
        [Description("Width of the right column")]
        [Category("Appearance")]
        [Themeable(false)]
        [DefaultValue(typeof(Unit), "")]
        public Unit Height { get; set; }

        /// <summary>
        /// Caption of the panel. Renders as the <c>caption</c> element of the <c>table</c>
        /// </summary>
        [Browsable(true)]
        [Description("Caption of the two column table")]
        [Category("Appearance")]
        [Themeable(false)]
        [DefaultValue("")]
        public string Caption { get; set; }

        #endregion

        /// <summary>
        /// Enables specifying of <c>SkinID</c> in markup
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

        /// <summary>
        /// Assign hot keys
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            IHotKeyLeftColumn ll = null;

            // Do not use D because browsers use it to go to address bar
            //P is also used by browser to show Page menu
            string usedKeys = "D P";
            foreach (Control ctl in Controls)
            {
                if (ctl is IHotKeyLeftColumn)
                {
                    ll = ctl as IHotKeyLeftColumn;
                }
                IFilterInput info = ctl as IFilterInput;
                if (info != null)
                {
                    //if (this.AutoFocus)
                    //{
                    //    ctl.PreRender += new EventHandler(tb_PreRender);
                    //}
                    if (ll != null)
                    {
                        // If left label text has not been specified, set the control's friendly name to the text
                        // InputControlBase shows ID if friendly name has not been specified
                        if (string.IsNullOrEmpty(info.FriendlyName) || info.FriendlyName == ctl.ID)
                        {
                            info.FriendlyName = ll.Text;
                        }
                        else if (string.IsNullOrEmpty(ll.Text))
                        {
                            ll.Text = info.FriendlyName;
                        }
                        // Find the first unused letter
                        if (string.IsNullOrEmpty(ll.AccessKey))
                        {
                            for (int i = 0; i < ll.Text.Length; ++i)
                            {
                                //changed the character case to upper so that we can compare the characters .
                                // Never let space become an access key
                                if (usedKeys.IndexOf(ll.Text[i].ToString().ToUpper()) == -1)
                                {
                                    if (string.IsNullOrEmpty(ctl.ID))
                                    {
                                    }
                                    else
                                    {
                                        ll.AccessKey = new string(ll.Text[i], 1);
                                        ll.AssociatedControlID = ctl.ID;
                                        //info.ClientIdRequired = true;
                                        usedKeys += ll.AccessKey.ToUpper();
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }

        //private bool _bFocusSet;
        //void tb_PreRender(object sender, EventArgs e)
        //{
        //    if (!_bFocusSet)
        //    {
        //        Control ctl = (Control)sender;
        //        string script = string.Format("$('#{0}').focus();", ctl.ClientID);
        //        //ctl.Focus();
        //        JQueryScriptManager.Current.RegisterReadyScript(script);
        //        _bFocusSet = true;
        //    }
        //}

        #region Rendering

        /// <summary>
        /// If the associated control is invisible, we make the whole row invisible
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Select left labels whose associated controls are invisible
            var query = from ll in this.Controls.OfType<IHotKeyLeftColumn>()
                        where !string.IsNullOrEmpty(ll.AssociatedControlID) &&
                        !this.NamingContainer.FindControl(ll.AssociatedControlID).Visible
                        select ll;
            foreach (IHotKeyLeftColumn ll in query)
            {
                ll.RowVisible = false;
            }
        }

        /// <summary>
        /// Renders the table base markup
        /// </summary>
        /// <param name="writer"></param>
		protected override void Render(HtmlTextWriter writer)
        {
            List<string> cssClasses = new List<string>();
            cssClasses.Add("tcp_CssClass");
            if (!string.IsNullOrEmpty(this.CssClass))
            {
                cssClasses.Add(this.CssClass);
            }
            if (this.IsValidationContainer)
            {
                cssClasses.Add(JQueryScriptManager.CssClassValidationContainer);
            }
            writer.AddAttribute(HtmlTextWriterAttribute.Class, string.Join(" ", cssClasses.ToArray()));
            if (this.Height != Unit.Empty)
            {
                writer.AddStyleAttribute(HtmlTextWriterStyle.Height, this.Height.ToString());
            }
            if (!string.IsNullOrEmpty(this.ID))
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Id, this.ClientID);
            }
            writer.RenderBeginTag(HtmlTextWriterTag.Table);

            if (!string.IsNullOrEmpty(Caption))
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Caption);
                writer.Write(this.Caption);
                writer.RenderEndTag();      //Caption
            }

            base.Render(writer);
            writer.RenderEndTag();              // table
        }

        /// <summary>
        /// Renders each row of the table
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderChildren(HtmlTextWriter writer)
        {
            bool bFirstRow = true;
            bool bIgnoring = false;
            foreach (Control ctl in this.Controls)
            {
                ILeftColumn ll = ctl as ILeftColumn;
                if (ll != null)
                {
                    if (!bFirstRow && !bIgnoring)
                    {
                        // Close the row in progress
                        writer.RenderEndTag();      // td
                        writer.RenderEndTag();      // tr
                    }
                    if (!ll.RowVisible)
                    {
                        // Ignore this and all subsequent controls until the next visible LeftLabel
                        bIgnoring = true;
                        continue;
                    }
                    bIgnoring = false;
                    writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                    if (ll.Span)
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Colspan, "2");
                    }
                    if (string.IsNullOrEmpty(this.LeftCssClass))
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, "tcp_leftColumn");
                    }
                    else
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, this.LeftCssClass);
                    }
                    if (this.WidthLeft != Unit.Empty)
                    {
                        writer.AddStyleAttribute(HtmlTextWriterStyle.Width, WidthLeft.ToString());
                    }
                    writer.RenderBeginTag(HtmlTextWriterTag.Td);
                    ctl.RenderControl(writer);
                    writer.RenderEndTag();      // td
                    if (ll.Span)
                    {
                        writer.RenderEndTag();      // tr
                        bFirstRow = true;
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(this.RightCssClass))
                        {
                            writer.AddAttribute(HtmlTextWriterAttribute.Class, "tcp_rightColumn");
                        }
                        else
                        {
                            writer.AddAttribute(HtmlTextWriterAttribute.Class, "tcp_rightColumn " + this.RightCssClass);
                        }
                        if (this.WidthRight != Unit.Empty)
                        {
                            writer.AddStyleAttribute(HtmlTextWriterStyle.Width, WidthRight.ToString());
                        }
                        writer.RenderBeginTag(HtmlTextWriterTag.Td);
                        bFirstRow = false;
                    }
                }
                else if (!bIgnoring)
                {
                    if (bFirstRow)
                    {
                        if (ctl is LiteralControl)
                        {
                            // Ignore it
                        }
                        else
                        {
                            throw new InvalidOperationException("The first control must be a Left Label 1");
                        }
                    }
                    else
                    {
                        ctl.RenderControl(writer);
                    }
                }
            }

            if (bFirstRow)
            {
                if (this.DesignMode)
                {
                    writer.Write("Add controls within this panel");
                }
            }
            else if (!bIgnoring)
            {
                // Close the last row being rendered
                writer.RenderEndTag();      // td
                writer.RenderEndTag();      // tr
            }
        }
 	    #endregion 

    
        #region IValidationContainer Members
        /// <summary>
        /// Applies the <see cref="P:EclipseLibrary.Web.JQuery.JQueryScriptManager.CssClassValidationContainer"/>
        /// css class to the panel
        /// </summary>
        public bool IsValidationContainer
        {
            get;
            set;
        }

        #endregion
    }
}

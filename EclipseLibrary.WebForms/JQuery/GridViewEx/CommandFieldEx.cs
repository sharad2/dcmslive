using System;
using System.ComponentModel;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery.Input;
using System.Web.UI;
using EclipseLibrary.Web.UI;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Behaves same as CommandField, except that it uses gridviewex_submit() instead of __doPostBack(). The latter is
    /// not AJAX friendly.
    /// </summary>
    /// <remarks>
    /// <para>
    /// You can make a Delete link visible in each row by setting <see cref="ShowDeleteButton"/>
    /// to true. The system will prompt for confirmation if <see cref="DeleteConfirmationText"/>
    /// is set. The confirmation text can contain row specific information by setting
    /// <see cref="DataFields"/>.
    /// </para>
    /// <para>
    /// You can make the CommandField visible only if the user belongs to specific roles by setting the
    /// <see cref="RolesRequired"/> property.
    /// </para>
    /// </remarks>
    public class CommandFieldEx: DataControlField
    {
        /// <summary>
        /// 
        /// </summary>
        public CommandFieldEx()
        {
            this.InsertButtonText = "Insert";
            this.EditLinkText = "Edit";
            this.UpdateButtonText = "Update";
            this.CancelLinkText = "Cancel";
            this.ShowEditButton = true;
        }
        #region Properties

        /// <summary>
        /// The text to show for the Insert button
        /// </summary>
        [Browsable(true)]
        [DefaultValue("Insert")]
        public string InsertButtonText { get; set; }

        /// <summary>
        /// The text to show for the update button
        /// </summary>
        [Browsable(true)]
        [DefaultValue("Update")]
        public string UpdateButtonText { get; set; }

        /// <summary>
        /// The text to show for the Edit link
        /// </summary>
        [Browsable(true)]
        [DefaultValue("Edit")]
        public string EditLinkText { get; set; }

        /// <summary>
        /// The text to show for the cancel link
        /// </summary>
        [Browsable(true)]
        [DefaultValue("Cancel")]
        public string CancelLinkText { get; set; }

        /// <summary>
        /// Whether the edit button should be displayed when the row is in read only mode
        /// </summary>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool ShowEditButton { get; set; }

        /// <summary>
        /// Whether the delete button should be displayed when the row is in read only mode
        /// </summary>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool ShowDeleteButton { get; set; }

        /// <summary>
        /// The action buttons will be visible only if the user is in one of these roles.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The behavior of this property is identical to the behavior of <see cref="ButtonEx.RolesRequired"/> property.
        /// </para>
        /// <example>
        /// <para>
        /// The following markup specifies that the button should be visible only if the user belongs to
        /// the <c>PayrollOperator</c> role.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        /// <jquery:CommandFieldEx ShowDeleteButton="true" RolesRequired="PayrollOperator" DeleteConfirmationText="Adjustment will be deleted. Are you sure you want to delete Adjustment?">
        /// </jquery:CommandFieldEx>
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
        /// If set, the user will be asked to confirm before a row is deleted
        /// </summary>
        /// <remarks>
        /// The text can contain placeholders which will be substituted by values of 
        /// <see cref="DataFields"/>.
        /// </remarks>
        /// <example>
        /// <code>
        /// <![CDATA[
        /// <jquery:GridViewExInsert runat="server" ID="gvFamilyMembers">
        /// <Columns>
        ///     <jquery:CommandFieldEx ShowDeleteButton="true" DeleteConfirmationText="Family Member {0} will be deleted."
        ///        DataFields="FullName" />
        ///     ...
        /// </Columns>
        /// </jquery:GridViewExInsert>
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [DefaultValue("")]
        public string DeleteConfirmationText { get; set; }

        /// <summary>
        /// The DataField values can be used as place holder in <see cref="DeleteConfirmationText"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Comma seperated list of data fields")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] DataFields { get; set; }

        /// <summary>
        /// Additional CSS clas to apply to the Insert Button. Useful if you want to write client script for this
        /// button.
        /// </summary>
        /// <remarks>
        /// If you specify CssClassInsertButton="myclass", then you can select all insert buttons and
        /// perhaps bind to their click event
        /// <example>
        /// $(':col(Command) input.myclass', $('#mygrid')).click(function(e) {...});
        /// </example>
        /// </remarks>
        public string CssClassInsertButton { get; set; }
        #endregion

        #region Overrides
        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <returns></returns>
        protected override DataControlField CreateField()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Does nothing to indicate that call backs are supported
        /// </summary>
        public override void ValidateSupportsCallback()
        {
            //base.ValidateSupportsCallback();
        }

        /// <summary>
        /// Prevenst the notification from getting raises
        /// </summary>
        protected override void OnFieldChanged()
        {
            //base.OnFieldChanged();
        }

        /// <summary>
        /// Initialize can be called multiple times so we need to maintain this flag
        /// </summary>
        private bool _bInitialized;
        public override bool Initialize(bool sortingEnabled, Control control)
        {
            if (!_bInitialized)
            {
                // Become invisble if security conditions are not met
                if (this.Visible)
                {
                    this.Visible = ButtonEx.IsUserInAnyRole(control.Page.User, this.RolesRequired);
                }
                control.PreRender += new EventHandler(gv_PreRender);
                _bInitialized = true;
            }
            return base.Initialize(sortingEnabled, control);
        }

        void gv_PreRender(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.DeleteConfirmationText))
            {
                GridViewEx gv = (GridViewEx)sender;
                string script = string.Format(@"$('#{0} a.gvex-delete-link')
.unbind('click.CommandFieldEx')
.bind('click.CommandFieldEx', function(e) {{
    return confirm($(this).attr('title') + ' Press Ok to confirm.');
}});", gv.ClientID);
                JQueryScriptManager.Current.RegisterReadyScript(script);
            }
        }

        /// <summary>
        /// Hooks up cell events depending on the state of the row
        /// </summary>
        /// <param name="cell"></param>
        /// <param name="cellType"></param>
        /// <param name="rowState"></param>
        /// <param name="rowIndex"></param>
        public override void InitializeCell(DataControlFieldCell cell, DataControlCellType cellType, DataControlRowState rowState, int rowIndex)
        {
            switch (cellType)
            {
                case DataControlCellType.DataCell:
                    // Secretly store the row index in cell text
                    //cell.Text = rowIndex.ToString();
                    if ((rowState & DataControlRowState.Edit) == DataControlRowState.Edit)
                    {
                        cell.Init += new EventHandler(cellEdit_Init);
                    }
                    else if ((rowState & DataControlRowState.Insert) == DataControlRowState.Insert)
                    {
                        cell.Init += new EventHandler(cellInsert_Init);
                    }
                    else
                    {
                        cell.DataBinding += new EventHandler(cell_DataBinding);
                    }
                    break;

                case DataControlCellType.Footer:
                    break;
                case DataControlCellType.Header:
                    break;
                default:
                    break;
            }
            base.InitializeCell(cell, cellType, rowState, rowIndex);
        }


        #endregion

        #region Cell events
        void cell_DataBinding(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;
            if (this.ShowEditButton)
            {
                cell.Text = string.Format("<a href='#' class='gvex-edit-link'>{0}</a>",
                    this.EditLinkText);
            }
            if (this.ShowDeleteButton)
            {
                string str = MultiBoundField.GetCellText(row.DataItem, this.DeleteConfirmationText, this.DataFields);
                cell.Text += string.Format(" <a href='#' title='{0}' class='gvex-delete-link'>Delete</a>",
                    str);
            }
        }

        void cellEdit_Init(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;
            GridViewEx gv = (GridViewEx)row.NamingContainer;
            ButtonEx btn = new ButtonEx();
            btn.ID = "Update";
            btn.CausesValidation = true;
            btn.Action = ButtonAction.Submit;
            btn.Text = this.UpdateButtonText;
            btn.CausesValidation = true;
            // row.ID is always null
            row.CssClass += " gvex-edit-link " + JQueryScriptManager.CssClassValidationContainer;
            btn.Click += new EventHandler(btnUpdate_Click);
            cell.Controls.Add(btn);

            AddCancelLink(cell, gv);
        }

        void cellInsert_Init(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;
            GridViewEx gv = (GridViewEx)row.NamingContainer;
            ButtonEx btn = new ButtonEx();
            btn.ID = "Insert";
            btn.CausesValidation = true;
            btn.Text = this.InsertButtonText;
            btn.CausesValidation = true;
            row.CssClass += " gvex-edit-link " + JQueryScriptManager.CssClassValidationContainer;
            btn.Action = ButtonAction.Submit;
            //TODO: Figure out what to do
            //btn.ValdiationContainerID = row.ID;

            if (!string.IsNullOrEmpty(this.CssClassInsertButton))
            {
                btn.AddCssClass(this.CssClassInsertButton);
            }
            btn.Click += new EventHandler(btnInsert_Click);
            cell.Controls.Add(btn);

            AddCancelLink(cell, gv);
        }

        private void AddCancelLink(DataControlFieldCell cell, GridViewEx gv)
        {
            Literal lit = new Literal();
            lit.Text = "<br/>";
            cell.Controls.Add(lit);

            HyperLink hlCancel = new HyperLink();
            //hlCancel.NavigateUrl = string.Format("javascript:gridviewex_submit('{0}', '{1}', 'Cancel${2}')",
            //    cell.Page.Form.ClientID, gv.UniqueID, cell.Text);
            hlCancel.Text = this.CancelLinkText;
            hlCancel.NavigateUrl = "#";
            hlCancel.CssClass = "gvex-cancel-link";
            cell.Controls.Add(hlCancel);
        }
        #endregion

        #region Click events

        void btnUpdate_Click(object sender, EventArgs e)
        {
            ButtonEx btn = (ButtonEx)sender;
            GridViewRow row = (GridViewRow)btn.NamingContainer;
            GridViewEx gv = (GridViewEx)row.NamingContainer;
            if (!btn.IsPageValid())
            {
                return;
            }
            else
            {
                gv.UpdateRow(row.RowIndex, false);
            }
        }

        void btnInsert_Click(object sender, EventArgs e)
        {
            ButtonEx btn = (ButtonEx)sender;
            GridViewRow row = (GridViewRow)btn.NamingContainer;
            GridViewExInsert gv = (GridViewExInsert)row.NamingContainer;
            if (!btn.IsPageValid())
            {
                return;
            }
            else
            {
                gv.InsertRow(row.RowIndex);
            }
        }
        #endregion

        

    }
}

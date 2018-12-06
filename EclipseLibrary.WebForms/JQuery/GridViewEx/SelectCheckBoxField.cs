using System;
using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Displays a checkbox in the row. When the checkbox is selected, the row gets selected and vice versa.
    /// Displays a checkbox in the header as well which can be used to select/unselect all rows.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Use this field if you want the user to be able to select a grid row by checking unchecking a checkbox. It only
    /// works within <see cref="GridViewEx"/>. All selected rows are available after postback through the
    /// <see cref="GridViewEx.SelectedIndexes"/> property.
    /// </para>
    /// <para>
    /// To check the checkbox using client script use the method <c>selectRows</c> of <c>gridViewEx</c> widget as
    /// shown in the example below. The checkbox can be unselected using the <c>unselectRows</c> method of
    /// <c>gridViewEx</c> widget.
    /// </para>
    /// <para>
    /// If you specify the header text, then it is displayed, otherwise a check box is displayed in the header.
    /// This check box will select/unselect all rows.
    /// If the row is not Enabled, or ui-state-disabled is one of the classes applied to it,
    /// the check box is not rendered because the
    /// row is not selectable.
    /// </para>
    /// <para>
    /// Do not use this field in a single selection grid.
    /// </para>
    /// <para>
    /// Sharad 15 Sep 2010: The check box created has tabindex=-1 so that it is not part of the tabbing order. Currently there is
    /// no way to override this.
    /// </para>
    /// <para>
    /// Sharad 12 Nov 2010: The checkbox is not displayed in insert and edit rows since it does not make sense to select them.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// Sample markup for a grid which allows the user to enter data in a textbox and check the checkbox to indicate that the
    /// value should be saved in the database. Additionally, whenever the user
    /// changes something in a textbox, the checkbox in the corresponding row is automatically checked.
    /// </para>
    /// <code lang="XML">
    /// <![CDATA[
    ///<jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" DataSourceID="ds"
    ///    DataKeyNames="PackageActivityId ClientIdSameAsId="true">
    ///    <Columns>  
    ///        <jquery:SelectCheckBoxField />    
    ///        <asp:TemplateField HeaderText="Progress Data" AccessibleHeaderText="ProgressData"
    ///            ItemStyle-HorizontalAlign="Right">
    ///            <ItemTemplate>
    ///                <i:TextBoxEx ID="tbPackageActivityData" runat="server" Text='<%#Bind("PackageActivtiyData") %>'
    ///                    FriendlyName='<%#  Eval("Description", " for Description {0}") %>'>
    ///                    <Validators>
    ///                        <i:Value ValueType="Decimal" MaxLength="15" />
    ///                    </Validators>
    ///                </i:TextBoxEx>
    ///            </ItemTemplate>
    ///        </asp:TemplateField>
    ///    </Columns>
    ///</jquery:GridViewEx>
    ///<i:ButtonEx runat="server" Text="Save" ID="btnSaveProgress" Icon="Refresh"
    ///     CausesValidation="true"
    ///     OnClick="btnSaveProgress_Click" Action="Submit" />
    /// ]]>
    /// </code>
    /// <para>
    /// When the user presses the save button, the following server side event handler updates all selected rows.
    /// </para>
    /// <code lang="C#">
    /// <![CDATA[
    /// protected void btnSaveProgress_Click(object sender, EventArgs e)
    /// {
    ///    foreach (int i in gv.SelectedIndexes)
    ///    {
    ///       int packageActivityId = (int)gv.DataKeys[i]["PackageActivityId"];
    ///       // You can now update the database row corresponding to this packageActivityId.
    ///    }
    /// }
    /// ]]>
    /// </code>
    /// <para>
    /// The javascript below selects the corresponding grid row whenever a value in a text box changes.
    /// </para>
    /// <code lang="javascript">
    /// <![CDATA[
    ///$(document).ready(function() {
    ///    $('#gv input:text').bind('change', function(e) {
    ///        $('#gv').gridViewEx('selectRows', e, $(this).closest('tr'));
    ///    })
    ///});
    ///]]>
    /// </code>
    /// </example>
    public class SelectCheckBoxField : DataControlField
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public SelectCheckBoxField()
        {
            this.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
            this.HeaderStyle.HorizontalAlign = HorizontalAlign.Center;
            this.HeaderText = "<input type='checkbox' class='gvex-header-checkbox' />";
        }

        /// <summary>
        /// Not Implemented
        /// </summary>
        /// <returns></returns>
        protected override DataControlField CreateField()
        {
            throw new NotImplementedException();
        }

        private GridViewEx _gv;

        /// <summary>
        /// Hooks to the PreRender event of the grid.
        /// </summary>
        /// <param name="sortingEnabled"></param>
        /// <param name="control"></param>
        /// <returns></returns>
        public override bool Initialize(bool sortingEnabled, Control control)
        {
            _gv = (GridViewEx)control;
            // If we are not visible, do not modify the selectable status of the grid
            if (this.Visible)
            {
                _gv.Selectable.IsSelectable = true;
            }
            _gv.PreRender += new EventHandler(_gv_PreRender);
            return base.Initialize(sortingEnabled, control);
        }

        /// <summary>
        /// Generates the scripts which keep the check box check state in sync with the row selection state
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void _gv_PreRender(object sender, EventArgs e)
        {
            if (this.Visible)
            {
                _gv.ClientEvents.Add("selectableselecting", @"function(event, ui) {
$('.gvex-row-checkbox', ui.selecting).attr('checked', true);
                }");
                // Uncheck the checkbox in the main header. Also the checkbox in the master section
                // from where something is being unselected
                _gv.ClientEvents.Add("selectableunselecting", @"function(event, ui) {
$('.gvex-row-checkbox', ui.unselecting).removeAttr('checked');
$('> thead > tr > th > input.gvex-header-checkbox', this).removeAttr('checked');
$('> tr > th > input.gvex-header-checkbox', $(ui.unselecting).closest('tbody')).removeAttr('checked');
                }");
                _gv.ClientEvents.Add("click", "SelectCheckBoxField_GridClick");
            }
            JQueryScriptManager.Current.RegisterScriptBlock("SelectCheckBoxFieldScripts",
                Properties.Resources.SelectCheckBoxFieldScripts);
        }

        /// <summary>
        /// Hooks to the PreRender event of the cell
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
                    if (!rowState.HasFlag(DataControlRowState.Edit) && !rowState.HasFlag(DataControlRowState.Insert))
                    {
                        // Do not display in edit or insert rows
                        cell.PreRender += new EventHandler(cell_PreRender);
                    }
                    break;

                case DataControlCellType.Footer:
                    break;

                case DataControlCellType.Header:
                    cell.Text = "<input type='checkbox' class='gvex-header-checkbox' />";
                    break;

                default:
                    break;
            }
            base.InitializeCell(cell, cellType, rowState, rowIndex);
        }

        /// <summary>
        /// We check row style and alternating row style also to ensure that the row has not been disabled.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cell_PreRender(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;
            bool bRender = row.Enabled && !row.CssClass.Contains("ui-state-disabled");
            if (bRender)
            {
                switch (row.RowState)
                {
                    case DataControlRowState.Normal:
                        bRender = !_gv.RowStyle.CssClass.Contains("ui-state-disabled");
                        break;

                    case DataControlRowState.Alternate:
                        bRender = !_gv.AlternatingRowStyle.CssClass.Contains("ui-state-disabled");
                        break;
                }

                if (bRender)
                {
                    if (_gv.SelectedIndexes.Contains(row.DataItemIndex) ||
                        (row.RowState & DataControlRowState.Selected) == DataControlRowState.Selected)
                    {
                        cell.Text = "<input type='checkbox' class='gvex-row-checkbox' checked='checked' tabindex='-1' />";
                    }
                    else
                    {
                        cell.Text = "<input type='checkbox' class='gvex-row-checkbox' tabindex='-1' />";
                    }
                }
            }
        }
    }
}

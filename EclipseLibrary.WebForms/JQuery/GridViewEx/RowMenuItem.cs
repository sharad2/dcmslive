using System.Web.UI;
using System.ComponentModel;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery.Input;


namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Base class for all row menu items
    /// </summary>
    public abstract class RowMenuItemBase
    {
        public RowMenuItemBase()
        {
            this.Visible = true;
        }

        /// <summary>
        /// The text to display for the menu item
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// The tooltip to display for the menu item
        /// </summary>
        public string ToolTip { get; set; }

        /// <summary>
        /// The property to show/hide MenuItem
        /// </summary>
        /// <remarks>
        /// If <see cref="RowMenuItem"/> is set to false then it won't be visible
        /// </remarks>
        /// <example>
        /// <code>
        /// <![CDATA[
        ///  if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["tweaks"]))
        ///    {
        ///      gvBoxes.RowMenuItems.Where(p => p.Text.Equals("Show MPC")).First().Visible = false;
        ///    }
        ///  ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool Visible
        {
            get;
            set;
        }

        /// <summary>
        /// The menu item is displayed only if the user belongs to one of these roles
        /// </summary>
        /// <remarks>
        /// <para>
        /// <see cref="GridViewEx"/> is responsible for checking these roles before the row menu is displayed
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Security")]
        [Description("Comma seperated list of roles")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] RolesRequired { get; set; }

        internal abstract string GetClientFunction(GridViewEx gv);
    }

    /// <summary>
    /// Represents a row menu within <see cref="GridViewEx"/>
    /// </summary>
    /// <include file='GridViewEx.xml' path='GridViewEx/doc[@name="PopupRowMenu"]/*'/>
    public class RowMenuItem : RowMenuItemBase
    {
        /// <summary>
        /// The action to perform when the menu item is clicked
        /// </summary>
        public string OnClientClick { get; set; }

        internal override string GetClientFunction(GridViewEx gv)
        {
            return this.OnClientClick;
        }
    }

    /// <summary>
    /// Navigates to the specified <see cref="NavigateUrl"/> and passes
    /// all the data key values for the clicked row as query string.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Data key values of the clicked row can be passed as query string along with the Url as shown in
    /// the first example. The second example demonstrates you to modify the url through code.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// Example1: Basic usage. The data key values of the clicked row is passed as query string along
    /// with the Url.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <jquery:GridViewEx ID="frmViewPickslipsOfBucket_gv" runat="server" DefaultSortExpression="Pickslip_Id"
    ///    AutoGenerateColumns="False" DataKeyNames="Pickslip_Id,warehouse_location,picking_status"
    ///    DataSourceID="dsPickslip">
    ///    <RowMenuItems>
    ///        <jquery:RowMenuNavigate NavigateUrl="../../SkuManager/SkuList.aspx?pickslip_id={0}&volume_per_dozen=V" Text="SKU Weights and Volumes" />
    ///    </RowMenuItems>
    ///    <Columns>
    ///        <eclipse:MultiBoundField DataFields="Pickslip_Id" HeaderText="Pickslip" SortExpression="Pickslip_Id"
    ///            HeaderToolTip="Pickslip ID" />
    ///    </Columns>
    ///</jquery:GridViewEx>
    /// ]]>
    /// </code>
    /// <para>
    /// Example 2: You may want to append additional query string parameters.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <jquery:GridViewEx ID="frmViewPickslipsOfBucket_gv" runat="server" DefaultSortExpression="Pickslip_Id"
    ///    AutoGenerateColumns="False" DataKeyNames="Pickslip_Id,warehouse_location,picking_status"
    ///    DataSourceID="dsPickslip">
    ///    <RowMenuItems>
    ///        <jquery:RowMenuNavigate NavigateUrl="../../SkuManager/SkuList.aspx?pickslip_id={0}&volume_per_dozen=V" Text="SKU Weights and Volumes" />
    ///    </RowMenuItems>
    ///    <Columns>
    ///        <eclipse:MultiBoundField DataFields="Pickslip_Id" HeaderText="Pickslip" SortExpression="Pickslip_Id"
    ///            HeaderToolTip="Pickslip ID" />
    ///    </Columns>
    ///</jquery:GridViewEx>
    /// ]]>
    /// </code>
    /// <para>
    /// The following code adds the <c>bucket_id</c> as a query string to the <see cref="NavigateUrl"/> of 
    /// <see cref="RowMenuNavigate"/> from the code-behind.
    /// </para>
    /// <code>
    /// <![CDATA[
    ///     RowMenuNavigate rmn = (RowMenuNavigate)frmViewPickslipsOfBucket_gv.RowMenuItems[0];
    ///     rmn.NavigateUrl += string.Format("&bucket_id={0}", Request.QueryString["bucket_id"]);
    /// ]]>
    /// </code>
    /// </example>
    public class RowMenuNavigate : RowMenuItemBase
    {
        /// <summary>
        /// The Url to navigate to when the menu item is clicked.
        /// </summary>
        [UrlProperty("*.aspx")]
        public string NavigateUrl { get; set; }

        internal override string GetClientFunction(GridViewEx gv)
        {
            string str = string.Format(@"function(keys) {{
            window.location = $.validator.format('{0}', keys);
            }}", gv.Page.ResolveClientUrl(this.NavigateUrl));
            return str;
        }
    }

    public enum RowMenuPostBackType
    {
        Edit,
        Delete
    }

    /// <summary>
    /// Posts back the form so that the grid knows that the user has requested
    /// editing of the clicked row.
    /// </summary>
    /// <remarks>
    /// <para>
    /// BUG: You must still use a <see cref="CommandFieldEx"/> to show the Update
    /// and cancel buttons when the row is in edit mode.
    /// </para>
    /// <para>
    /// TODO: Ask for confirmation while deleting
    /// </para>
    /// </remarks>
    public class RowMenuPostBack : RowMenuItemBase
    {
        public RowMenuPostBackType PostBackType { get; set; }

        internal override string GetClientFunction(GridViewEx gv)
        {
            string str = string.Format(@"function(keys) {{
var rowIndex = $(this).gridViewEx('keyIndex', keys);
$(this).gridViewEx('submitForm', '{0}$' + rowIndex);
            }}", this.PostBackType);
            return str;
        }
    }
}

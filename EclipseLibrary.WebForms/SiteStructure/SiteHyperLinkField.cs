using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery;
using EclipseLibrary.Web.UI;

namespace EclipseLibrary.Web.SiteStructure
{
    /// <summary>
    /// Same as <see cref="System.Web.UI.WebControls.HyperLinkField"/> except that 
    /// <see cref="DataNavigateUrlFormatString"/> need not specify the full path.
    /// </summary>
    /// <remarks>
    /// <para>
    /// If you are using <see cref="System.Web.UI.WebControls.HyperLinkField"/>, then you must specify the full or relative URL
    /// in <see cref="DataNavigateUrlFormatString"/>. This means that the link will break if the page is moved to a different 
    /// location. If the sitemap provider for your project is <see cref="AutoSiteMapProvider"/>, then you can use
    /// <c>SiteHyperLinkField</c> and reference the URL by using its sitemap key. So instead of writing
    /// <c>DataNavigateUrlFormatString = "/Reports/Category10/R110_3.aspx?area=SHL"</c>, you can simply write
    /// <c>DataNavigateUrlFormatString = "R110_3.aspx?area=SHL"</c>. At run time, <c>SiteHyperLinkField</c> will query
    /// <see cref="AutoSiteMapProvider"/> for a node whose key is <c>R110_3.aspx</c>. If the node is found, then 
    /// <c>R110_3.aspx</c> portion of
    /// <c>DataNavigateUrlFormatString</c> will be replaced with the URL of the found node.
    /// </para>
    /// <para>
    /// If the sitemap node for <c>R110_3.aspx</c> is not found, the value of <c>DataNavigateUrlFormatString</c> remains
    /// unchanged. An error style is applied to the cell to indicate that we may be potentially navigating to a broken link.
    /// </para>
    /// <para>
    /// The page on which this control is placed must be one of the pages which the <see cref="AutoSiteMapProvider"/>
    /// is aware of. If this page is not part of the site map, then <c>SiteHyperLinkField</c> behaves identically to
    /// <c>HyperlinkField</c>.
    /// </para>
    /// <para>
    /// You can optionally specify the ID of an <see cref="AppliedFilters"/> control for the property <see cref="AppliedFiltersControlID"/>
    /// to automatically append the filters
    /// defined by this control to the query string.
    /// </para>
    /// <para>
    /// You can also show column totals by specifying <see cref="DataSummaryCalculation"/>.
    /// </para>
    /// </remarks>
    /// <example>
    /// <code lang="xml">
    ///     <![CDATA[
    /// <eclipse:SiteHyperLinkField DataTextField="total_quantity" HeaderText="Pcs Qty"
    ///     DataNavigateUrlFormatString="R30_101.aspx?area={0}&vwh_id={1}&warehouse_location={2}&area_type={3}"
    ///     DataNavigateUrlFields="area,vwh_id,warehouse_location,area_type">
    ///</eclipse:SiteHyperLinkField>
    ///]]>
    ///     </code>
    /// </example>
    public class SiteHyperLinkField : HyperLinkField, INeedsSummaries, IHasHeaderToolTip
    {
        /// <summary>
        /// Id of the report we are interested in
        /// </summary>
        private string _reportId;

        /// <summary>
        /// Format string of the relative Url to the report. Will be empty if the report does not exist
        /// </summary>
        private string _navigateUrlFormatString;

       

        /// <summary>
        ///     If set, the query string parameters returned by this control will be added to the url.
        ///     The applied filters control must be in the same naming container as the grid.
        /// </summary>
        /// <remarks>
        ///     This property can be used in case it is required to have all the filters applied be passed 
        ///     to the query string.
        /// </remarks>
        /// <example>
        ///     <para> We will consider the sample data mention herein below - 
        ///     </para>
        ///      <table>
         ///    <tr>
         ///        <th colspan="2">
         ///            Warehouse Location : FDC1
         ///        </th>    
         ///        <th>
         ///            3 Rows
         ///        </th>
         ///    </tr>
         ///    <tr>
         ///        <th>
         ///            Area
         ///        </th>
         ///        <th>
         ///            Pieces
         ///        </th>
         ///        <th>
         ///            VWh
         ///        </th>
         ///    </tr>
         ///    <tr>
         ///        <td>
         ///            AWL
         ///        </td>
         ///        <td style="text-align:right">
         ///            <a href="#"> 61,002</a>
         ///        </td>
         ///        <td>
         ///            15
         ///        </td>
         ///    </tr>
         ///    <tr>
         ///        <td>
         ///            AWO
         ///        </td>
         ///        <td style="text-align:right">
         ///            <a href="#"> 600</a>
         ///        </td>
         ///        <td>
         ///            15
         ///        </td>
         ///    </tr>
         ///    <tr>
         ///        <td>
         ///            AWS
         ///        </td>
         ///        <td style="text-align:right">
         ///            <a href="#">396</a>
         ///        </td>
         ///        <td>
         ///            15
         ///        </td>
         ///    </tr>
         ///    <tr>
         ///        <td>
         ///            <strong>Total</strong>
         ///        </td>
         ///        <td  style="text-align:right">
         ///            <strong> 61,998</strong>
        ///        </td>
        ///        <td>
        ///        </td>
        ///    </tr>
        ///    </table>
        ///     <para>
        ///         Below are the applied filters.
        ///     </para>
        ///     <table>
        ///         <tr>
        ///             <td colspan="2"><strong>Applied Filter</strong></td>
        ///         </tr>
        ///         <tr>
        ///             <td>Virtual Warehouse</td>
        ///             <td>15: US</td>
        ///         </tr>
        ///         <tr>
        ///             <td>Warehouse Location</td>
        ///             <td>FDC1: New Location Of FDC</td>
        ///         </tr>
        ///     </table>
        ///     <para>
        ///         Following will be the markup to specify <c>AppliedFiltersControlID</c>.
        ///         As you can see, here <c>AppliedFiltersControlID</c> has been specified as 
        ///         <c>AppliedFiltersControlID="ctlButtonBar$af"</c> where <c>ctlButtonBar</c> is 
        ///         any user control which is having <c>af</c> as <c>AppliedFilter</c> in it.
        ///     </para>
        ///     <code>
        ///         <![CDATA[
        ///         <eclipse:SiteHyperLinkField DataTextField="total_quantity" HeaderText="Pcs Qty" SortExpression="total_quantity"
        ///             DataNavigateUrlFormatString="R30_101.aspx" AppliedFiltersControlID="ctlButtonBar$af"
        ///             DataNavigateUrlFields="area,vwh_id,warehouse_location,area_type" DataSummaryCalculation="ValueSummation"
        ///             DataFooterFormatString="Pieces: {0:N0}" HeaderToolTip="Total Pieces in current Area and Warehouse location">
        ///         </eclipse:SiteHyperLinkField>
        ///          ]]>
        ///     </code>
        /// </example>

        public string AppliedFiltersControlID { get; set; }

        /// <summary>
        /// Compute the format string which represents the relative U
        /// </summary>
        /// <param name="enableSorting"></param>
        /// <param name="control"></param>
        /// <returns></returns>
        public override bool Initialize(bool enableSorting, Control control)
        {
            string[] fields = this.DataNavigateUrlFormatString.Split('?');
            SiteMapNode node;
            // If the containing page is not part of the sitemap, do not attempt to resolve the Url.
            if (SiteMap.Enabled && SiteMap.CurrentNode != null)
            {
                node = SiteMap.Provider.FindSiteMapNodeFromKey(fields[0]);
            }
            else
            {
                node = null;
            }
            if (node == null)
            {
                _reportId = fields[0];
                if (SiteMap.CurrentNode == null)
                {
                    _navigateUrlFormatString = this.DataNavigateUrlFormatString;
                    if (!string.IsNullOrEmpty(this.AppliedFiltersControlID))
                    {
                        AppliedFilters af = (AppliedFilters)control.NamingContainer.FindControl(this.AppliedFiltersControlID);
                        _navigateUrlFormatString = af.AddQueryString(_navigateUrlFormatString);
                    }
                }
                else
                {
                    _navigateUrlFormatString = string.Empty;
                }
            }
            else
            {
                _navigateUrlFormatString = this.DataNavigateUrlFormatString.Replace(fields[0], node.Url);
                if (!string.IsNullOrEmpty(this.AppliedFiltersControlID))
                {
                    AppliedFilters af = (AppliedFilters)control.NamingContainer.FindControl(this.AppliedFiltersControlID);
                    _navigateUrlFormatString = af.AddQueryString(_navigateUrlFormatString);
                }
            }
            return base.Initialize(enableSorting, control);
        }
        /// <summary>
        /// The Sitemap node key to navigate to when the value is clicked
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property will be used to specify the url to navigate. This will contain the sitemap key and the 
        /// query string.
        /// For example,
        /// if <c>DataNavigateUrlFormatString</c> is <c>R110_03.aspx?a=b&amp;c=d</c>, then the sitemap key is
        /// <c>R110_03.aspx</c>. If the string does not contain any <c>?</c> character, then the whole string is treated as the
        /// key.
        /// Everything specified before the <c>?</c> character is interpreted as the sitemap node key. 
        /// </para>
        /// </remarks>
        /// <example>
        /// For an example, see <see cref="SiteHyperLinkField"/> class overview.
        /// </example>
        public override string DataNavigateUrlFormatString
        {
            get
            {
                return base.DataNavigateUrlFormatString;
            }
            set
            {
                if (_navigateUrlFormatString != null)
                {
                    throw new NotSupportedException("DataNavigateUrlFormatString must be set during or begore grid's DataBinding event");
                }
                base.DataNavigateUrlFormatString = value;
            }
        }

        /// <summary>
        /// Hook to cell's prerender event
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
                    if (SiteMap.CurrentNode == null || string.IsNullOrEmpty(_navigateUrlFormatString))
                    {
                        cell.Style.Add("border-bottom", "0.5mm dotted red");
                        cell.ToolTip = string.Format("Report {0} is not available", _reportId);
                    }
                    break;
            }
            base.InitializeCell(cell, cellType, rowState, rowIndex);
        }

        /// <summary>
        /// Create the hyperlink using the url from the site map provider.
        /// </summary>
        /// <param name="dataUrlValues"></param>
        /// <returns></returns>
        protected override string FormatDataNavigateUrlValue(object[] dataUrlValues)
        {
            return string.Format(_navigateUrlFormatString, dataUrlValues);
        }

        /// <summary>
        /// Prevent grid from rebinding if we are made invisible
        /// </summary>
        protected override void OnFieldChanged()
        {
            //base.OnFieldChanged();
        }

        #region INeedsSummaries Members

        /// <summary>
        /// Whether summaries should be calculated by the data source or by us.
        /// </summary>
        /// <remarks>
        /// Set it to one of the values of the enumeration <see cref="SummaryCalculationType"/>. For more information,
        /// see the documentation of <see cref="INeedsSummaries.DataSummaryCalculation"/>.
        /// </remarks>
        [Browsable(true)]
        public SummaryCalculationType DataSummaryCalculation
        {
            get;
            set;
        }

        private string[] _dataFooterFields;

        /// <exclude />
        /// <summary>
        /// The field whose total should be displayed.
        /// If not specified, default to DataTextField
        /// </summary>
        /// <remarks>
        /// In most cases, you will not specify a value for this since you will probably want to show totals for the
        /// field which you are displaying in each cell. Thus inherited <c>DataTextField</c> default should serve your purpose.
        /// If someday we deceide to allow multiple fields in <c>DataTextField</c>, this property might actually become useful.
        /// </remarks>
        [Browsable(false)]
        [Category("Data")]
        [Description("Comma seperated list of data fields to display in footer")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] DataFooterFields
        {
            get
            {
                if (_dataFooterFields == null)
                {
                    return new string[] { this.DataTextField };
                }
                else
                {
                    return _dataFooterFields;
                }
            }
            set
            {
                _dataFooterFields = value;
            }
        }

        private string _footerFormatString;

        /// <summary>
        /// Format string to use for displaying summary.
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Format string to use for footer text")]
        [Themeable(false)]
        public string DataFooterFormatString
        {
            get
            {
                if (string.IsNullOrEmpty(_footerFormatString))
                {
                    return this.DataTextFormatString;
                }
                else
                {
                    return _footerFormatString;
                }
            }
            set
            {
                _footerFormatString = value;
            }
        }
        /// <summary>
        /// Specify tooltip for the field
        /// </summary>
        public string FooterToolTip
        {
            get;
            set;
        }
        /// <summary>
        /// Undefined
        /// </summary>
        [Browsable(false)]
        public decimal?[] SummaryValues
        {
            get;
            set;
        }
        /// <summary>
        /// Undefined
        /// </summary>
        [Browsable(false)]
        public int[] SummaryValuesCount { get; set; }

        #endregion

        #region IHasHeaderToolTip Members

        /// <summary>
        /// Specify tooltip for the field.
        /// </summary>
        public string HeaderToolTip
        {
            get;
            set;
        }

        #endregion

    }
}

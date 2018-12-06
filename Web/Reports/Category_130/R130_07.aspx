<%@ Page Title="Inventory Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="EclipseLibrary.Web.JQuery" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace=" EclipseLibrary.Web.UI.Matrix" %>


<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6313 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_07.aspx $
 *  $Id: R130_07.aspx 6313 2013-12-03 11:20:12Z skumar $
 * Version Control Template Added.
--%>
<%--Header Summary Pattern--%>
<script runat="server">
    /// <summary>
    /// handling OnInit declaring events for the gridview.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        gv.DataBinding += new System.EventHandler(gv_DataBinding);
        //gv.DataBound += new EventHandler(gv_DataBound);
        gv.RowDataBound += new GridViewRowEventHandler(gv_RowDataBound);
        base.OnInit(e);
    }


    void gv_DataBinding(object sender, System.EventArgs e)
    {
        _listSummary = new List<SummaryInfo>();
    }

    /// <summary>
    /// Index of the row in which data for SHL is being displayed
    /// </summary>
    //private int _shlRowIndex = -1;

    /// <summary>
    /// Contains properties which must be displayed in the summary table
    /// </summary>
    private class SummaryInfo
    {
        public string VwhId { get; set; }

        /// <summary>
        /// Number of pieces in the area containing max pieces
        /// </summary>
        public int PiecesInMaxArea { get; set; }

        /// <summary>
        /// Area containing max pieces
        /// </summary>
        public string MaxArea { get; set; }

        /// <summary>
        /// Total pieces in the Vwh
        /// </summary>
        public int TotalPieces { get; set; }

        /// <summary>
        /// Total SHL-A pieces in this vwh
        /// </summary>
        public int ShlaPieces
        {
            get
            {
                return ShlPieces - (TotalPieces - ShlPieces);
            }
        }

        public int ShlPieces { get; set; }
    }

    /// <summary>
    /// List containing the summary info we will display in summary grid
    /// </summary>
    private List<SummaryInfo> _listSummary;


    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        string vwh;

        MatrixRow mr;
        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                mr = e.Row.Controls.OfType<MatrixRow>().Single();
                string area = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "area"));
                foreach (var cell in mr.MatrixCells.Where(p => p.DisplayColumn.MatrixColumn.ColumnType == MatrixColumnType.CellValue))
                {
                    //cell.Text = "Sharad";
                    vwh = DataBinder.Eval(cell.DataItem, "VWH_ID", "{0}");
                    SummaryInfo info = _listSummary.FirstOrDefault(p => p.VwhId == vwh);
                    if (info == null)
                    {
                        // First time this vwh is coming
                        info = new SummaryInfo();
                        info.VwhId = vwh;
                        _listSummary.Add(info);
                    }
                    int pieces = Convert.ToInt32(DataBinder.Eval(cell.DataItem, "TOTAL_QUANTITY"));
                    if (pieces > info.PiecesInMaxArea)
                    {
                        info.MaxArea = area;
                        info.PiecesInMaxArea = pieces;

                    }
                    if (pieces < 0)
                    {
                        info.MaxArea="SHL";
                    }
                    if (area == "SHL")
                    {
                        info.ShlPieces = pieces;
                        //info.MaxArea = area;
                    }
                }
                break;

            case DataControlRowType.Footer:
                mr = e.Row.Controls.OfType<MatrixRow>().Single();
                foreach (var cell in mr.MatrixCells.Where(p => p.DisplayColumn.MatrixColumn.ColumnType == MatrixColumnType.CellValue))
                {
                    vwh = Convert.ToString(DataBinder.Eval(cell.DataItem, "VWH_ID"));
                    SummaryInfo info = _listSummary.Single(p => p.VwhId == vwh);
                    info.TotalPieces = Convert.ToInt32(DataBinder.Eval(cell.DataItem, "TOTAL_QUANTITY")); ;
                }
                gvSummary.DataSource = _listSummary;
                gvSummary.DataBind();
                // Managing visibility of the summary gridview
                gvSummary.Visible = gv.Rows.Count > 0;
                break;
        }
    }

    /// <summary>
    /// Retrieving total for the summary and assigning datasource to the summary grid.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
   



</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays total inventory available for each shelf area for each Virtual Warehouse. 
    You can further drill down to see inventory of SKUs by clicking on quantity shown for the respective virtual warehouse and  its area." />
    <meta name="ReportId" content="130.07" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_07.aspx 6313 2013-12-03 11:20:12Z skumar $" />
    <meta name="ChangeLog" content="Now, report is ready for separate picking area for each Building." />
</asp:Content>
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ToolTip="Choose virtual warehouse" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <div style="margin-bottom: 2em">
        <%--GridView showing summary--%>
        <jquery:GridViewEx runat="server" ID="gvSummary" AutoGenerateColumns="false" DefaultSortExpression="1"
            PreSorted="true" ShowFooter="true" Caption="Summary by Virtual Warehouse">
            <Columns>
                <eclipse:MultiBoundField DataFields="VwhId" HeaderText="VWh" HeaderToolTip="Virtual Warehouse" />
                <eclipse:MultiBoundField DataFields="ShlaPieces" HeaderText="Quantity In SHL-A" DataSummaryCalculation="ValueSummation"
                    DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"/>
                <eclipse:MultiBoundField DataFields="MaxArea" HeaderText="Max Inventory|Area" DataFormatString="{0:N0}"
                    ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                <eclipse:MultiBoundField DataFields="PiecesInMaxArea" HeaderText="Max Inventory|Pieces"
                    DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" />
                <eclipse:MultiBoundField DataFields="TotalPieces" HeaderText="Total Inventory" DataSummaryCalculation="ValueSummation"
                    DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right"
                    FooterStyle-HorizontalAlign="Right" />
            </Columns>
        </jquery:GridViewEx>
    </div>
    <%--DataSource--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
               WITH shl8_inventory AS 
        ( 
        SELECT /*+index(iac iacont_iacontent_type_id_i) INDEX(ialoc ialoc_pk) */
         max(i.short_name || ':' || i.short_description) as area,
         iac.ia_id AS area_id,
         ialoc.vwh_id AS vwh_id,
         SUM(iac.number_of_units) AS TOTAL_QUANTITY
          FROM ialoc_content iac
          LEFT OUTER JOIN  ialoc ialoc  ON ialoc.ia_id = iac.ia_id
                                                 AND ialoc.location_id =
                                                     iac.location_id
          LEFT OUTER join ia i on
            i.ia_id=ialoc.ia_id
         WHERE NVL(I.SHORT_NAME,ialoc.ia_id) != :ScrapArea
           AND iac.iacontent_type_id = :SkuTypeStorageArea
           <if>AND ialoc.vwh_id=:vwh_id</if>
         GROUP BY ialoc.vwh_id, iac.ia_id
        UNION
        SELECT /*+ INDEX(box box_ia_id_copy_i)*/
         max(ia.short_name || ':' || ia.short_description) as area,
         box.ia_id AS area_id,
         box.vwh_id AS VWH_ID,
         SUM(nvl(boxdet.current_pieces, 0)) AS TOTAL_QUANTITY
          FROM box box
          left outer join boxdet boxdet on box.ucc128_id = boxdet.ucc128_id
                                             and box.pickslip_id = boxdet.pickslip_id
         LEFT OUTER join ia on box.ia_id = ia.ia_id
         WHERE box.ia_id IS NOT NULL
           AND boxdet.stop_process_date IS NULL
           AND box.stop_process_date IS NULL
           <if>AND box.vwh_id=:vwh_id</if>
         GROUP BY box.ia_id, box.vwh_id
        ), 
        shl_inventory AS 
        (
        SELECT MAX(rawinv.sku_storage_area) AS area,
               MAX(rawinv.sku_storage_area) AS area_id,
                              rawinv.vwh_id AS vwh_id,
                              SUM(rawinv.quantity) AS total_quantity
        FROM master_raw_inventory rawinv
        WHERE rawinv.sku_storage_area = :shelfArea
        <if>AND rawinv.vwh_id=:vwh_id</if>
        GROUP BY rawinv.vwh_id
        )
        SELECT  max(shl8.area) as area,
                shl8.area_id as area_id,
                shl8.vwh_id as vwh_id,
                SUM(shl8.total_quantity)  AS total_quantity
        FROM shl8_inventory shl8
            GROUP BY shl8.area_id,
                shl8.vwh_id
        UNION
        SELECT  shl.area,
                shl.area_id,
                shl.vwh_id,
                shl.total_quantity
        FROM shl_inventory shl
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" />
            <asp:Parameter DbType="String" Name="shelfArea" DefaultValue="<%$ Appsettings:ShelfArea %>" />
            <asp:Parameter DbType="String" Name="SkuTypeStorageArea" DefaultValue="<%$ Appsettings:SkuTypeStorageArea %>" />
            <asp:Parameter DbType="String" Name="ScrapArea" DefaultValue="<%$ Appsettings:ScrapArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="area" DataKeyNames="area">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="area" HeaderText="Area" SortExpression="area"
                ItemStyle-HorizontalAlign="Left" HeaderToolTip="Area containing inventory" />
            <m:MatrixField DataCellFields="TOTAL_QUANTITY" DataHeaderFields="VWH_ID" DataMergeFields="area"
                HeaderText="Total Pieces In VWh" GroupByColumnHeaderText="false" RowTotalHeaderText="Total">
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="CellValue" DisplayColumnTotal="true" DataHeaderFormatString="{0}"
                        DataCellFormatString="{0:N0}">
                        <ItemTemplate>
                            <eclipse:SiteHyperLink ID="SiteHyperLink1" runat="server" SiteMapKey="R30_03.aspx"
                                NavigateUrl='<%# Eval("area_id", "area_id={0}") + Eval("VWH_ID", "&vwh_id={0}") + Eval("area", "&area={0}") %>'
                                Text='<%# Eval("TOTAL_QUANTITY", "{0:N0}") %>' ToolTip='<%# string.Format("Click to view the SKUs of {0} and Virtual Warehouse {1}",Eval("area", "{0}"),Eval("VWH_ID", "{0}")) %>' />
                        </ItemTemplate>
                    </m:MatrixColumn>
                    <m:MatrixColumn DataCellFormatString="{0:N0}" DisplayColumnTotal="true" ColumnType="RowTotal" />
                </MatrixColumns>
            </m:MatrixField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

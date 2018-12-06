<%@ Page Title="Inventory in Area SHL-A" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%--
Author HKV
TODO: How to convert to full outer join

1. Write intent clearly in the report.
2. UPCCode tool tip should say: Click to view the shipping details of last three days.
--%>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6474 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_13.aspx $
 *  $Id: R130_13.aspx 6474 2014-03-20 07:16:10Z skumar $
 * Version Control Template Added.
 *
--%>

<script runat="server">
    /// <summary>
    /// Handling event of declare events of the gv and ds.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        gv.RowDataBound += new GridViewRowEventHandler(gv_RowDataBound);
        base.OnInit(e);
    }
    /// <summary>
    /// Event handled to specify tooltip of the upc_code column.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        DataControlField dcf = (DataControlField)(from DataControlField dcf1 in gv.Columns
                                                  where dcf1.AccessibleHeaderText == "UPC_CODE"
                                                  select dcf1).Single();
        object objUpcCode = DataBinder.Eval(e.Row.DataItem, "UPC_CODE");
        if (objUpcCode != null)
        {
            e.Row.Cells[gv.Columns.IndexOf(dcf)].Attributes.Add("title", string.Format("Click to view the shipping detail for last thirty days of - {0}", objUpcCode.ToString()));
        }  
    }
</script>

<asp:Content ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays the entire inventory in shelf area for a specified label or virtual warehouse. Additionally there is an option to see only negetive inventory in SHL-A." />
    <meta name="ReportId" content="130.13" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_13.aspx 6474 2014-03-20 07:16:10Z skumar $" />
    <meta name="ChangeLog" content="Fixed the bug, which was showing negative SHL-A for a particular VWH." />
</asp:Content>
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" />
                <d:StyleLabelSelector runat="server" ID="ctlStyleLabel" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ToolTip="Choose Label" QueryString="label_id" FriendlyName="Label"
                    ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>"  />
                <br />
                <i:CheckBoxEx ID="cbShowNegative" runat="server" Text="Show only Negative SHL-A"
                    ToolTip="Check to view negative SHL-A" CheckedValue="Y" QueryString="show_negative"
                    Checked="false" FriendlyName="Negative SHL" />
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" QueryString="vwh_id" ToolTip="Select Virtual Warehouse" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide the sort control --%>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 runat="server" ID="ctlButtonBar" />
    <%--Data Source--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true">
<SelectSql>
    WITH SHL AS
 (SELECT mri.sku_id, MRI.VWH_ID AS VWH_ID, SUM(MRI.QUANTITY) AS SHL_QUANTITY
    FROM MASTER_RAW_INVENTORY MRI
   WHERE mri.sku_storage_area = CAST(:shelfArea as varchar2(255))
   <if>AND mri.vwh_id=CAST(:vwh_id as varchar2(255))</if>
   GROUP BY mri.sku_id, MRI.VWH_ID),
ALL_SHL8 AS
 (SELECT IO.VWH_ID AS VWH_ID,
         msku.sku_id,
         SUM(IOC.NUMBER_OF_UNITS) AS PIECES,
         SYS.STRAGG(UNIQUE IOC.LOCATION_ID || ', ') AS LOCATION_ID
    FROM IALOC IO
   inner JOIN IALOC_CONTENT IOC
      ON IOC.IA_ID = IO.IA_ID
     AND IOC.LOCATION_ID = IO.LOCATION_ID
   inner join master_sku msku
      on msku.upc_code = ioc.iacontent_id
    INNER JOIN IA ON 
    IOC.IA_ID = IA.IA_ID
  where IA.CONSOLIDATED_UPC_CODE IS NULL
  <if>AND io.vwh_id = CAST(:vwh_id as varchar2(255))</if>
    AND IOC.NUMBER_OF_UNITS &lt;&gt; 0
   GROUP BY msku.sku_id, IO.VWH_ID
  UNION ALL
  SELECT B.VWH_ID AS VWH_ID,
         BD.Sku_Id AS Sku_Id,
         SUM(BD.CURRENT_PIECES) AS PIECES,
         NULL AS LOCATION_ID
    FROM BOX B
   INNER JOIN BOXDET BD
      ON BD.UCC128_ID = B.UCC128_ID
     AND BD.PICKSLIP_ID = B.PICKSLIP_ID
   WHERE BD.CURRENT_PIECES > 0
 <if>AND B.vwh_id = CAST(:vwh_id as varchar2(255))</if>
     AND B.IA_ID IS NOT NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
   GROUP BY BD.sku_id, B.VWH_ID),
SHL8 AS
 (SELECT ALL_SHL8.sku_id AS sku_id,
         MAX(ALL_SHL8.LOCATION_ID) AS LOCATION_ID,
         ALL_SHL8.VWH_ID AS VWH_ID,
         SUM(ALL_SHL8.PIECES) AS RINGSCANNER_QUANTITY
    FROM ALL_SHL8
   GROUP BY ALL_SHL8.sku_id, ALL_SHL8.VWH_ID)
SELECT nvl(SHL.VWH_ID,shl8.vwh_id) AS VWH_ID,
       msku.UPC_CODE AS UPC_CODE,
       NVL(SHL8.LOCATION_ID,'No Location Assigned') AS LOCATION_ID,
       msku.STYLE AS STYLE,
       msku.COLOR AS COLOR,
       msku.DIMENSION AS DIMENSION,
       msku.SKU_SIZE AS SKU_SIZE,
       NVL(SHL.SHL_QUANTITY, 0) - NVL(SHL8.RINGSCANNER_QUANTITY, 0) AS SHL_A_QUANTITY,
       SHL.SHL_QUANTITY AS SHL_QUANTITY,
       NVL(SHL8.RINGSCANNER_QUANTITY, 0) AS RINGSCANNER_QUANTITY
  FROM SHL
  FULL OUTER JOIN SHL8
    ON SHL8.sku_id = SHL.sku_id
   AND SHL8.VWH_ID = SHL.VWH_ID
    INNER JOIN MASTER_SKU MSKU
    ON MSKU.SKU_ID = SHL.SKU_ID
    OR MSKU.SKU_ID = SHL8.SKU_ID
 INNER JOIN MASTER_STYLE MST
    ON MSKU.STYLE = MST.STYLE
 WHERE 1=1
<if>and mst.label_id =:label_id</if>
 <if c="$showNegative">and (nvl(shl.SHL_QUANTITY, 0) - nvl(shl8.RINGSCANNER_QUANTITY, 0)) &lt; 0</if>
   <else>and (nvl(shl.SHL_QUANTITY, 0) - nvl(shl8.RINGSCANNER_QUANTITY, 0)) &lt;&gt; 0</else>
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlStyleLabel" DbType="String" Name="label_id" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="cbShowNegative" DbType="String" Name="showNegative" />
            <asp:Parameter DbType="String" Name="shelfArea" DefaultValue="<%$ Appsettings:ShelfArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--GridView--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="VWH_ID;UPC_CODE">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" HeaderToolTip="Virtual Warehouse"
                SortExpression="VWH_ID" />
            <eclipse:SiteHyperLinkField AccessibleHeaderText="UPC_CODE" DataTextField="UPC_CODE"
                DataNavigateUrlFields="UPC_CODE,VWH_ID" DataNavigateUrlFormatString="R130_107.aspx?upc_code={0}&vwh_id={1}"
                HeaderText="UPC Code" SortExpression="UPC_CODE" ItemStyle-HorizontalAlign="Left"
                AppliedFiltersControlID="ctlButtonBar$af" />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" HeaderToolTip="Style"
                SortExpression="STYLE" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" HeaderToolTip="Color"
                SortExpression="COLOR" />
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim" HeaderToolTip="Dimension"
                SortExpression="DIMENSION" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" HeaderToolTip="SKU Size"
                SortExpression="SKU_SIZE" />
            <eclipse:MultiBoundField DataFields="SHL_QUANTITY" HeaderText="Quantity|In SHL" SortExpression="SHL_QUANTITY"
                DataSummaryCalculation="ValueSummation" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" HeaderToolTip="Quantity of inventory in SHL"
                FooterToolTip="Total quantity of inventory in SHL" />
            <eclipse:MultiBoundField DataFields="RINGSCANNER_QUANTITY" HeaderText="Quantity|In Ringscanner"
                SortExpression="RINGSCANNER_QUANTITY" DataSummaryCalculation="ValueSummation"
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" HeaderToolTip="Quantity of inventory in Ringscanner"
                FooterToolTip="Total quantity of inventory in Ringscanner" />
            <eclipse:MultiBoundField DataFields="SHL_A_QUANTITY" HeaderText="Quantity|In SHL-A"
                SortExpression="SHL_A_QUANTITY" DataSummaryCalculation="ValueSummation" ItemStyle-HorizontalAlign="Right" 
                FooterStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                HeaderToolTip="Quantity of inventory in SHL-A" FooterToolTip="Total quantity of inventory in SHL-A" />
            <eclipse:MultiBoundField AccessibleHeaderText="LOCATION_ID" DataFields="LOCATION_ID"
                HeaderText="Location" SortExpression="LOCATION_ID" HeaderToolTip="Location of SKUs" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKU Inventory" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3572 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_105.aspx $
 *  $Id: R130_105.aspx 3572 2012-05-14 12:05:13Z skumar $
 *  Version Control Template Added.
 *
--%>
<script runat="server">
   
    private string _VWh;
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //MatrixRow mr;
        string shl = ConfigurationManager.AppSettings["ShelfArea"];
        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                //mr = e.Row.Controls.OfType<MatrixRow>().Single();
                if (string.IsNullOrEmpty(_VWh))
                {
                    foreach (DataControlField dc in gv.Columns)
                    {
                        if (dc.AccessibleHeaderText == "VWhvisible")
                        {
                            dc.Visible = true;
                        }
                    }
                }
                break;

            default:
                break;
        }
    }

  

    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        _VWh = (string)e.Command.Parameters["vwh_id"].Value;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.105" />
    <meta name="Browsable" content="false" />
    <meta name="Description" content="For a given SKU and virtual warehouse the report shows 
                                        the quantity of active SKUs in each SHL area." />
    <meta name="Version" content="$Id: R130_105.aspx 3572 2012-05-14 12:05:13Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Style" />
                <i:TextBoxEx ID="tbStyle" runat="server" QueryString="style" FriendlyName="Style"
                    ToolTip="Please enter the style(It is required)">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Color" />
                <i:TextBoxEx ID="tbColor" runat="server" QueryString="color" FriendlyName="Color"
                    ToolTip="Please enter the color" />
                <eclipse:LeftLabel runat="server" Text="Dimension" />
                <i:TextBoxEx ID="tbDimension" runat="server" QueryString="dimension" FriendlyName="Dimension"
                    ToolTip="Please enter the Dimension" />
                <eclipse:LeftLabel runat="server" Text="Sku Size" />
                <i:TextBoxEx ID="tbSkuSize" runat="server" QueryString="sku_size" FriendlyName="Sku Size"
                    ToolTip="Please enter the Size" />
                <eclipse:LeftLabel runat="server" Text="Quality Code" />
                <i:TextBoxEx ID="tbQualityCode" runat="server" QueryString="quality_code" FriendlyName="Quality Code"
                    ToolTip="Please enter the Quality Code" />
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ToolTip="By default, inventory of all Virtual Warehouse is shown for passed SKU. If your focus is on the inventory in a particular Virtual Warehouse, Specify that Virtual Warehouse."
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting">
        <SelectSql>
          /*Please note before you interpret this query:
Total_pieces and shl_a columns are calculated fileds.
You need to pick one value from multiple values against 
particular sku of particular vwh_id of these fields
*/
WITH sku_inventory AS

 (
 SELECT /*+ INDEX(box box_ia_id_copy_i)*/
         ms.upc_code AS UPC_CODE,
         ms.color AS COLOR,
         ms.dimension AS DIMENSION,
         ms.sku_size AS sku_size,
         max((select tq.quality_code from tab_quality_code tq
        where tq.order_quality='Y'
        )) as quality_code,
         SUM(boxdet.current_pieces) AS QUANTITY,
         NULL AS Pieces,
         box.vwh_id AS WAREHOUSE_ID,
         box.ia_id AS AREA
    FROM boxdet boxdet
   INNER JOIN box
      ON BOX.UCC128_ID = BOXDET.UCC128_ID
     AND BOX.PICKSLIP_ID = BOXDET.PICKSLIP_ID
    LEFT OUTER JOIN master_sku ms
      ON boxdet.upc_code = ms.upc_code
      <if>CROSS JOIN (SELECT QUALITY_CODE
                 FROM TAB_QUALITY_CODE A
                WHERE A.ORDER_QUALITY = 'Y'
                  AND ROWNUM &lt; 2
                  AND QUALITY_CODE = :quality_code)</if>
   WHERE ms.inactive_flag IS NULL
     AND boxdet.STOP_PROCESS_DATE is null
     AND box.ia_id &lt; &gt; CAST(:CancelArea as varchar2(255))
     AND box.ia_id IS NOT NULL
     AND box.ia_id_copy IS NOT NULL
     AND ms.style = CAST(:style as varchar2(255))
     <if>AND box.vwh_id = CAST(:vwh_id as varchar2(255))</if>
     <if>AND ms.color = CAST(:color as varchar2(255))</if>
     <if>AND ms.dimension = CAST(:dimension as varchar2(255))</if>
     <if>AND ms.sku_size = CAST(:sku_size as varchar2(255))</if>
   GROUP BY ms.upc_code,
            ms.color,
            ms.dimension,
            ms.sku_size,
            box.vwh_id,
            box.ia_id
  UNION ALL
  
 
  SELECT sku.upc_code AS UPC_CODE,
         sku.color AS COLOR,
         sku.dimension AS DIMENSION,
         sku.sku_size AS sku_size,
         max((select tq.quality_code from tab_quality_code tq
        where tq.order_quality='Y'
       )) as quality_code,
         SUM(iacont.number_of_units) AS QUANTITY,
         NULL AS Pices,
         ia.vwh_id AS WAREHOUSE_ID,
         iacont.ia_id AS AREA
    FROM ialoc_content iacont
    LEFT OUTER JOIN ialoc ia
      ON ia.ia_id = iacont.ia_id
     AND ia.location_id = iacont.location_id
    LEFT OUTER JOIN master_sku sku
      ON iacont.iacontent_id = sku.upc_code
      <if>CROSS JOIN (SELECT QUALITY_CODE
                 FROM TAB_QUALITY_CODE A
                WHERE A.ORDER_QUALITY = 'Y'
                  AND ROWNUM &lt; 2
                  AND QUALITY_CODE = :quality_code)</if>
   WHERE iacont.ia_id IN (CAST(:PickingArea as varchar2(255)), CAST(:CancelArea as varchar2(255)))
     AND iacont.iacontent_type_id = CAST(:SkuArea as varchar2(255))
     AND sku.style = CAST(:style as varchar2(255))
     <if>AND ia.vwh_id = CAST(:vwh_id as varchar2(255))</if>
     <if>AND sku.color = CAST(:color as varchar2(255))</if>
     <if>AND sku.dimension = CAST(:dimension as varchar2(255))</if>
     <if>AND sku.sku_size = CAST(:sku_size as varchar2(255))</if>     
   GROUP BY iacont.ia_id,
            ia.vwh_id,
            sku.upc_code,
            sku.color,
            sku.dimension,
            sku.sku_size,
            sku.style

union all
  SELECT MAX(ms.upc_code) AS UPC_CODE,
         rawinv.color AS COLOR,
         rawinv.dimension AS DIMENSION,
         rawinv.sku_size AS sku_size,
         max(rawinv.quality_code) AS quality_code,
         NULL AS quantity,
         SUM(rawinv.quantity) AS Pieces,
         rawinv.vwh_id AS WAREHOUSE_ID,
         rawinv.sku_storage_area AS AREA
    FROM master_raw_inventory rawinv
    LEFT OUTER JOIN tab_inventory_area tabinv
      ON tabinv.inventory_storage_area = rawinv.sku_storage_area
    LEFT OUTER JOIN master_sku ms
      ON rawinv.style = ms.style
     AND rawinv.color = ms.color
     AND rawinv.dimension = ms.dimension
     AND rawinv.sku_size = ms.sku_size
   WHERE rawinv.sku_storage_area = CAST(:Area as varchar2(255))
     AND tabinv.unusable_inventory IS NULL
     AND ms.inactive_flag IS NULL
     AND rawinv.style = CAST(:style as varchar2(255))
     <if>AND rawinv.vwh_id = CAST(:vwh_id as varchar2(255))</if>
    <if>AND rawinv.color = CAST(:color as varchar2(255))</if>
     <if>AND rawinv.dimension = CAST(:dimension as varchar2(255))</if>
     <if>AND rawinv.sku_size = CAST(:sku_size as varchar2(255))</if>
     <if>and rawinv.quality_code=:quality_code</if>
   
     
   GROUP BY rawinv.color,
            rawinv.dimension,
            rawinv.sku_size,
            rawinv.sku_storage_area,
            rawinv.vwh_id,
            rawinv.style           
 
            )
SELECT si.COLOR AS COLOR,
       si.DIMENSION AS DIMENSION,
       si.sku_size AS sku_size,
       si.upc_code as upc_code,
       si.quality_code as quality_code,
       si.Area AS ia_id,
       si.WAREHOUSE_ID AS vwh_id,
       SUM(si.quantity) OVER(PARTITION BY si.upc_code, si.area,si.WAREHOUSE_ID) AS quantity,
       SUM(si.Pieces) OVER(PARTITION BY si.upc_code,si.WAREHOUSE_ID) AS total_pieces,
       SUM(nvl(si.Pieces, 0)) OVER(PARTITION BY si.upc_code,si.WAREHOUSE_ID) -SUM(nvl(si.quantity, 0)) OVER(PARTITION BY si.upc_code,si.WAREHOUSE_ID) AS SHLA,
       i.process_flow_sequence AS process_flow_sequence
  FROM sku_inventory SI
  LEFT OUTER JOIN ia i ON i.ia_id = SI.area
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbStyle" Type="String" Direction="Input" Name="style" />
            <asp:ControlParameter ControlID="tbColor" Type="String" Direction="Input" Name="color" />
            <asp:ControlParameter ControlID="tbDimension" Type="String" Direction="Input" Name="dimension" />
            <asp:ControlParameter ControlID="tbSkuSize" Type="String" Direction="Input" Name="sku_size" />
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="tbQualityCode" Type="String" Direction="Input" Name="quality_code" />
            <asp:Parameter Name="Area" Type="String" Direction="Input" DefaultValue="<%$ AppSettings: ShelfArea %>" />
            <asp:Parameter Name="PickingArea" Type="String" Direction="Input" DefaultValue="<%$ AppSettings: PickingArea %>" />
            <asp:Parameter Name="CancelArea" Type="String" Direction="Input" DefaultValue="<%$ AppSettings: CancelArea %>" />
            <asp:Parameter Name="SkuArea" Type="String" Direction="Input" DefaultValue="<%$ AppSettings: SkuTypeStorageArea %>" />
          
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" DataSourceID="ds"
        AllowSorting="true" DefaultSortExpression="color;dimension;sku_size;vwh_id;"
        DisplayMasterRow="false" ShowFooter="true" OnRowDataBound="gv_RowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="SKU Color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim." SortExpression="dimension"
                HeaderToolTip="SKU Dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="SKU Size" />
            <eclipse:MultiBoundField DataFields="upc_code" HeaderText="UPC Code" SortExpression="upc_code" />
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code" />
            <eclipse:MultiBoundField DataFields="SHLA" SortExpression="SHLA" HeaderText="SHL-A"
                HeaderToolTip="Pieces in SHL area - Pieces in SHL-8 area" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <m:MatrixField DataHeaderFields="ia_id" DataCellFields="quantity" DataMergeFields="color,dimension,sku_size,VWH_ID,upc_code"
                HeaderText="Quantity in">
                <MatrixColumns>
                    <m:MatrixColumn DisplayColumnTotal="true" VisibleExpression="$ ia_id!='SHL'" DataCellFormatString="{0:N0}">
                        <ItemTemplate>
                            <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex='<%# Eval("ia_id", "{0}") == ConfigurationManager.AppSettings["PickingArea"]? 0 : 1 %>'>
                                <asp:View ID="View1" runat="server">
                                    <eclipse:SiteHyperLink ID="SiteHyperLink1" runat="server" SiteMapKey="R130_106.aspx"
                                        NavigateUrl='<%# Eval("upc_code", "UPC={0}") + Eval("VWH_ID", "&vwh_id={0}") %>'
                                        Text='<%# Eval("quantity", "{0:N0}") %>'>
                                    </eclipse:SiteHyperLink>
                                </asp:View>
                                <asp:View ID="View2" runat="server">
                                    <asp:Label ID="Label1" runat="server" Text='<%# Eval("quantity") %>' />
                                </asp:View>
                            </asp:MultiView>
                        </ItemTemplate>
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="total_pieces" HeaderText="Total(in pieces)"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" SortExpression="total_pieces"
                DataSummaryCalculation="ValueSummation" HeaderToolTip="Total pieces in SHL area">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                Visible="false" AccessibleHeaderText="VWhvisible" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

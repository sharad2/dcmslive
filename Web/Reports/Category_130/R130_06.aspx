 <%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKU Inventory" %>

<%@ Import Namespace="EclipseLibrary.Web.Utilities" %>
<%--Skumar: We are creating hardwired column in this report because user want to see all areas. --%>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7052 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_06.aspx $
 *  $Id: R130_06.aspx 7052 2014-07-16 11:30:03Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Hyperlink in Matrix field--%>
<script runat="server">
    protected void gv_OnDataBound(object send, EventArgs e)
    {
        var Style = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "Style" ? i : -1)
           .Single(p => p >= 0);


        if(gv.Rows.Count >1)
        { 
            for (int tempIndex = 0; tempIndex <= gv.Rows.Count - 1; tempIndex++)
        {
            if (gv.Rows[tempIndex].Cells[Style].Text == "XXXXX")
            {
                gv.Rows[tempIndex].Visible = false;

            }
        }
        }
        
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For each SKU and warehouse the report displays the quantity of pieces in each inventory area" />
    <meta name="ReportId" content="130.06" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_06.aspx 7052 2014-07-16 11:30:03Z skumar $" />
    <meta name="ChangeLog" content="Now report will show all inventory areas irrespective of  whether inventory is available there or not.|Style parameter is now optional.| Provided label filter so that user can see SKU inventory for the passed label.|Report  will not show suspense carton inventory in a separate column. This quantity will be collectively displayed with the area quantity.|Added new column for showing Style." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel  runat="server" />
                <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" FriendlyName="Label" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>"
                    ToolTip="By default, inventory of all label. If your focus is on the inventory in a particular label, Specify that label." />
                <eclipse:LeftLabel runat="server" Text="Style" />
                 <i:TextBoxEx ID="tbStyle" runat="server" FriendlyName="Style" ToolTip="Please enter the style">
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Color" />
                <i:TextBoxEx ID="tbColor" runat="server" FriendlyName="Color" ToolTip="Please enter the color" />
                <eclipse:LeftLabel runat="server" Text="Dimension" />
                <i:TextBoxEx ID="tbDimension" runat="server" FriendlyName="Dimension" ToolTip="Please enter the Dimension" />
                <eclipse:LeftLabel runat="server" Text="Sku Size" />
                <i:TextBoxEx ID="tbSkuSize" runat="server" FriendlyName="Sku Size" ToolTip="Please enter the Size" />
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ToolTip="By default, inventory of all Virtual Warehouse. If your focus is on the inventory in a particular Virtual Warehouse, Specify that Virtual Warehouse."
                    ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
        ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>">
        <SelectSql>
WITH ALL_AREAS AS
 (SELECT T.INVENTORY_STORAGE_AREA AS AREA_ID,
         T.SHORT_NAME AS AREA,
         'CTN' AS AREA_TYPE,
         T.WAREHOUSE_LOCATION_ID AS BUILDING
    FROM TAB_INVENTORY_AREA T
   WHERE T.UNUSABLE_INVENTORY IS NULL
  UNION
  SELECT IA.IA_ID AS AREA_ID,
         IA.SHORT_NAME AS AREA,
         'SHL' AS AREA_TYPE,
         IA.WAREHOUSE_LOCATION_ID AS BUILDING
    FROM IA
   WHERE (IA.PICKING_AREA_FLAG = 'Y' OR IA.SHORT_NAME = :CANArea)
  UNION
  SELECT 'BOX' AS AREA_ID,
         'BOX' AS AREA,
         'SHL' AS AREA_TYPE,
         NULL AS BUILDING
    FROM DUAL),
ALL_INVENTORY AS
 (SELECT SC.VWH_ID,         
         SCD.SKU_ID,
         MAX(SCD.STYLE) AS STYLE,
         MAX(SCD.COLOR) AS COLOR,
         MAX(SCD.DIMENSION) AS DIMENSIONS,
         MAX(SCD.SKU_SIZE) AS SKU_SIZE,
         MAX(MS.UPC_CODE) AS UPC_CODE,
         SUM(SCD.QUANTITY) AS QUANTITY,
         NULL AS SHLQTY,
         NULL AS BOXQTY,
         SC.CARTON_STORAGE_AREA AS AREA_ID,
         SC.QUALITY_CODE,
         NVL(TIA.WAREHOUSE_LOCATION_ID, MSL.WAREHOUSE_LOCATION_ID) AS BUILDING
    FROM SRC_CARTON SC
   INNER JOIN SRC_CARTON_DETAIL SCD
      ON SC.CARTON_ID = SCD.CARTON_ID
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
     AND SC.LOCATION_ID = MSL.LOCATION_ID
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON TIA.INVENTORY_STORAGE_AREA = SC.CARTON_STORAGE_AREA
    LEFT OUTER JOIN MASTER_SKU MS
      ON SCD.SKU_ID = MS.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MST ON SCD.STYLE = MST.STYLE
   WHERE 1 = 1
    <if>AND SCD.style =:style</if>
    <if>AND SCD.color =:Color</if>
    <if>AND SCD.sku_size =:sku_size</if>
    <if>AND SCD.dimension =:Dimension</if>
    <if>AND MST.LABEL_ID =:label_id</if>
    <if>AND SC.vwh_id = :vwh_id</if>
   GROUP BY SC.VWH_ID,
            SCD.SKU_ID,
            SC.CARTON_STORAGE_AREA,
            NVL(TIA.WAREHOUSE_LOCATION_ID, MSL.WAREHOUSE_LOCATION_ID),
            SC.QUALITY_CODE  
  UNION ALL
  SELECT MRI.VWH_ID,
         MRI.SKU_ID,
         MAX(MRI.STYLE) AS STYLE,
         MAX(MRI.COLOR) AS COLOR,
         MAX(MRI.DIMENSION) AS DIMENSIONS,
         MAX(MRI.SKU_SIZE) AS SKU_SIZE,
         MAX(MS.UPC_CODE) AS UPC_CODE,
         SUM(MRI.QUANTITY) AS QUANTITY,
         SUM(CASE
               WHEN MRI.SKU_STORAGE_AREA = 'SHL' THEN
                MRI.QUANTITY
             END) AS SHLQTY,
         NULL AS BOXQTY,
         MRI.SKU_STORAGE_AREA,
         MRI.QUALITY_CODE,
         TIA.WAREHOUSE_LOCATION_ID AS BUILDING
    FROM MASTER_RAW_INVENTORY MRI
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON MRI.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
    LEFT OUTER JOIN MASTER_SKU MS
      ON MRI.SKU_ID = MS.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MST ON MRI.STYLE = MST.STYLE
   WHERE TIA.STORES_WHAT = 'SKU'
     AND TIA.UNUSABLE_INVENTORY IS NULL
    <if>AND MRI.style =:style</if>
    <if>AND MRI.color =:Color</if>
    <if>AND MRI.sku_size =:sku_size</if>
    <if>AND MRI.dimension =:Dimension</if>
    <if>AND MST.LABEL_ID =:label_id</if>
    <if>AND MRI.vwh_id = :vwh_id</if>
   GROUP BY MRI.VWH_ID,
            MRI.SKU_ID,
            MRI.SKU_STORAGE_AREA,
            MRI.QUALITY_CODE,
            TIA.WAREHOUSE_LOCATION_ID
  UNION ALL
  SELECT B.VWH_ID,
         MS.SKU_ID,
         MAX(MS.STYLE) AS STYLE,
         MAX(MS.COLOR) AS COLOR,
         MAX(MS.DIMENSION) AS DIMENSIONS,
         MAX(MS.SKU_SIZE) AS SKU_SIZE,
         MAX(BD.UPC_CODE) AS UPC_CODE,
         SUM(BD.CURRENT_PIECES) AS QUANTITY,
         NULL AS SHLQTY,
         SUM(BD.CURRENT_PIECES) AS BOXQTY,
         'BOX' AS AREA_ID,
         '01' AS QUALITY_CODE,
         NULL AS BUILDING
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_SKU MS
      ON MS.UPC_CODE = BD.UPC_CODE
    LEFT OUTER JOIN MASTER_STYLE MST ON MS.STYLE = MST.STYLE
   WHERE MS.INACTIVE_FLAG IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND B.IA_ID IS NOT NULL
     AND B.IA_ID_COPY IS NOT NULL
    <if>AND MS.style =:style</if>
    <if>AND MS.color =:Color</if>
    <if>AND MS.sku_size =:sku_size</if>
    <if>AND MS.dimension =:Dimension</if>
    <if>AND MST.LABEL_ID =:label_id</if>
    <if>AND B.vwh_id = :vwh_id</if>
   GROUP BY B.VWH_ID, MS.SKU_ID
  UNION ALL
  SELECT I.VWH_ID,
         MS.SKU_ID,
         MAX(MS.STYLE) AS STYLE,
         MAX(MS.COLOR) AS COLOR,
         MAX(MS.DIMENSION) AS DIMENSIONS,
         MAX(MS.SKU_SIZE) AS SKU_SIZE,
         MAX(IC.IACONTENT_ID) AS UPC_CODE,
         SUM(IC.NUMBER_OF_UNITS) AS QUANTITY,
         NULL AS SHLQTY,
         SUM(IC.NUMBER_OF_UNITS) AS BOXQTY,
         I.IA_ID AS AREA_ID,
         '01' AS QUALITY_CODE,
         I.WAREHOUSE_LOCATION_ID AS BUILDING
    FROM IALOC I
   INNER JOIN IALOC_CONTENT IC
      ON I.LOCATION_ID = IC.LOCATION_ID
    LEFT OUTER JOIN MASTER_SKU MS
      ON IC.IACONTENT_ID = MS.UPC_CODE  
    LEFT OUTER JOIN MASTER_STYLE MST ON MS.STYLE = MST.STYLE 
   WHERE IC.IACONTENT_TYPE_ID = 'SKU'
     AND i.location_type ='RAIL'
    <if>AND MS.style =:style</if>
    <if>AND MS.color =:Color</if>
    <if>AND MS.sku_size =:sku_size</if>
    <if>AND MS.dimension =:Dimension</if>
    <if>AND MST.LABEL_ID =:label_id</if>
    <if>AND I.vwh_id = :vwh_id</if>
   GROUP BY I.VWH_ID,
            MS.SKU_ID,
            I.IA_ID,
            I.WAREHOUSE_LOCATION_ID),
 FINAL_QUERY AS
 (SELECT AI.VWH_ID AS VWH_ID,
         AI.SKU_ID AS SKU_ID,
         NVL(AI.STYLE,'XXXXX') AS STYLE,
         AI.COLOR,
         AI.DIMENSIONS,
         AI.SKU_SIZE,
         AI.UPC_CODE,
         SUM(NVL(AI.QUANTITY, 0))OVER() AS OVERALL_INVENTORY,
         NVL(AI.QUANTITY, 0) AS QUANTITY,
         NVL(AI.QUALITY_CODE, '01') AS QUALITY_CODE,
         CASE WHEN AA.AREA_TYPE ='SHL' THEN
             AA.AREA_ID
            ELSE
            NULL
            END AS AREA_ID,
         AA.AREA  AS AREA,
         SUM(NVL(AI.SHLQTY, 0)) OVER(PARTITION BY AI.SKU_ID, AI.VWH_ID, QUALITY_CODE) AS SHLQTY,
         SUM(NVL(AI.SHLQTY, 0)) OVER(PARTITION BY AI.SKU_ID, AI.VWH_ID, QUALITY_CODE) - SUM(NVL(BOXQTY, 0)) OVER(PARTITION BY AI.SKU_ID, AI.VWH_ID, QUALITY_CODE) AS SHLA,
         SUM(NVL(AI.QUANTITY, 0)) OVER(PARTITION BY AI.SKU_ID, AI.VWH_ID, QUALITY_CODE) - SUM(NVL(AI.SHLQTY, 0)) OVER(PARTITION BY AI.SKU_ID, AI.VWH_ID, QUALITY_CODE) AS TOTAL_PIECES,
         AA.AREA_TYPE,
         CASE
           WHEN AA.AREA = 'BOX' THEN
            NULL
           ELSE
            COALESCE(AI.BUILDING, AA.BUILDING, 'Unknown')
         END AS BUILDING
    FROM ALL_AREAS AA
    LEFT OUTER JOIN ALL_INVENTORY AI
      ON AA.AREA_ID = AI.AREA_ID)
SELECT *
  FROM FINAL_QUERY FQ  
  WHERE FQ.OVERALL_INVENTORY &lt;&gt;0
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbStyle" Direction="Input" Type="String" Name="style" />
            <asp:ControlParameter ControlID="tbColor" Direction="Input" Type="String" Name="Color" />
            <asp:ControlParameter ControlID="tbDimension" Direction="Input" Type="String" Name="Dimension" />
            <asp:ControlParameter ControlID="tbSkuSize" Direction="Input" Type="String" Name="sku_size" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
             <asp:ControlParameter ControlID="ls" Direction="Input" Name="label_id" Type="String" />
            <asp:Parameter Name="CANArea" DbType="String" DefaultValue="<%$  AppSettings: CancelArea  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AllowSorting="false" AllowPaging="true" PageSize="500" DataSourceID="ds" ShowFooter="true"  PagerSettings-Visible="false" OnDataBound="gv_OnDataBound" AutoGenerateColumns="false" DefaultSortExpression="style;color;dimensions;sku_size;quality_code;VWH_ID;building;area;area_id"
        >
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="STYLE" HeaderText="Style" ItemStyle-HorizontalAlign="Left" SortExpression="STYLE" AccessibleHeaderText="Style" />
            <asp:BoundField DataField="color" HeaderText="Color" SortExpression="color" />
            <asp:BoundField DataField="dimensions" HeaderText="Dim" SortExpression="dimensions" />
            <asp:BoundField DataField="sku_size" HeaderText="Size" SortExpression="sku_size" />
            <asp:BoundField DataField="quality_code" HeaderText="Quality" SortExpression="quality_code" ItemStyle-HorizontalAlign="left" />   
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWH" SortExpression="vwh_id" ItemStyle-HorizontalAlign="Right"/>      
            <m:MatrixField DataMergeFields="style,color,dimensions,sku_size,quality_code,VWH_ID" DataHeaderFields="building,area,area_id,AREA_TYPE"
                DataCellFields="Quantity" HeaderText="{1}<br>{0}" GroupByColumnHeaderText="true">
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="CellValue" DataCellFormatString="{0:#,###}" ColumnTotalFormatString="{0:#,###}" DataHeaderFormatString="{0::$AREA_TYPE ='CTN': Carton Area Quantity: Pick/Ship}"   VisibleExpression ="$area !='SHL'"  DisplayColumnTotal="true">
                    <ItemTemplate>
                            <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex='<%# Eval("AREA_TYPE", "{0}") == "SHL"? 0 : 1 %>'>
                                <asp:View ID="View1" runat="server">
                                    <eclipse:SiteHyperLink ID="SiteHyperLink1" runat="server" SiteMapKey="R130_106.aspx"
                                        Text='<%# Eval("quantity", "{0:#,###}") %>' NavigateUrl='<%# string.Format("UPC={0}&vwh_id={1}&area={2}",Eval("UPC_CODE"),Eval("vwh_id"),Eval("AREA_ID"))%>'></eclipse:SiteHyperLink>
                                </asp:View>
                                <asp:View ID="View2" runat="server">
                                    <asp:Label ID="Label1" runat="server" Text='<%# Eval("quantity", "{0:#,###}") %>' />
                                </asp:View>
                            </asp:MultiView>
                        </ItemTemplate>
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="SHLQTY" HeaderText="SHL" SortExpression="SHLQTY" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"  DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation"/>
            <eclipse:MultiBoundField DataFields="SHLA" HeaderText="SHL-A" SortExpression="SHLA" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation" />   
            <eclipse:MultiBoundField DataFields="TOTAL_PIECES" HeaderText="Total Pieces" SortExpression="TOTAL_PIECES" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation"/>
            </Columns>       
    </jquery:GridViewEx>
</asp:Content>

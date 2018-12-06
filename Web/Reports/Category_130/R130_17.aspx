<%@ Page Title="QTY in BIR against specific Style(s)" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5916 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_17.aspx $
 *  $Id: R130_17.aspx 5916 2013-08-08 06:38:07Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For a specified style passed in the report, the report displays the SKU wise stock details for various 
    season codes in BIR and also displays the quantity in FPK area. This report displays SKUs details only for those cartons which are not 
    assigned to any request. " />
    <meta name="ReportId" content="130.17" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_17.aspx 5916 2013-08-08 06:38:07Z skumar $" />
    <meta name="ChangeLog" content="Now, report is ready for separate picking area for each Building." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <%-- Filter panel  --%>
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="Style" />
                <i:TextBoxEx ID="tbStyle" runat="server" QueryString="style" ToolTip="Enter Style, of which you want to see quantity in various season codes and FPK.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <br />
                Enter one or more styles with comma (,) as a separator.
                <eclipse:LeftPanel runat="server" Span="true">
                    <i:CheckBoxEx runat="server" ID="cbMultipleLocation" QueryString="has_multiple_locations" FriendlyName="Multiple Locations"
                        Text="SKUs having multiple locations" ToolTip="Check to see SKUs, which are in multiple locations."
                        CheckedValue="Y" />
                </eclipse:LeftPanel>
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ToolTip="Choose Virtual Warehouse" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- Sort panel --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Button bar to put all the buttons, it will the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 runat="server" />
    <%-- Data source --%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
       
        <SelectSql>
          WITH PSC_SKU_Inventory
 AS
 (
 SELECT /*+Rule*/
   sum(cd.quantity) AS QUANTITY,
   c.price_season_code AS PRICE_SEASON_CODE,
   cd.STYLE AS STYLE,
   cd.COLOR AS COLOR,
   cd.DIMENSION AS DIM,
   c.vwh_id AS VWH_ID,
   cd.SKU_SIZE AS SKU_SIZE,
   COALESCE(TIA.WAREHOUSE_LOCATION_ID,MSL.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID
   FROM src_carton_detail cd
   LEFT OUTER JOIN src_carton c ON c.carton_id = cd.carton_id
   INNER JOIN master_sku ms ON ms.style = cd.style
                                 AND ms.color = cd.color
                                 AND ms.dimension = cd.dimension
                                 AND ms.sku_size = cd.sku_size
   INNER JOIN TAB_INVENTORY_AREA TIA ON 
   C.CARTON_STORAGE_AREA = INVENTORY_STORAGE_AREA
   LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL ON
   C.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
   AND C.LOCATION_ID =MSL.LOCATION_ID
   WHERE CD.REQ_PROCESS_ID IS NULL
 AND TIA.STORES_WHAT ='CTN'
   <if c="$style">AND cd.STYLE IN (<a sep=','>:style</a>)</if>
   AND TIA.SHORT_NAME = :CartonReserveArea
   <if>AND c.vwh_id=:vwh_id</if>
   
   <if c="$has_multiple_location">AND exists (SELECT 1 AS UPC_CODE
          FROM ialoc i
         WHERE i.assigned_upc_code = ms.upc_code
         GROUP BY i.assigned_upc_code, i.vwh_id
        HAVING count(i.assigned_upc_code) &gt;= 2)</if>
  GROUP BY c.vwh_id,
           c.price_season_code,
           cd.STYLE,
           cd.COLOR,
           cd.DIMENSION,
           cd.SKU_SIZE,
            COALESCE(TIA.WAREHOUSE_LOCATION_ID,MSL.WAREHOUSE_LOCATION_ID,'Unknown')
  ),
  FPK_QTY AS
  (            
/* Quantity of a specific SKU in FPK area*/              
SELECT ioc.iacontent_id AS IACONTENT_ID,
              sum(ioc.number_of_units) AS FPK_QUANTITY,
              il.vwh_id AS VWH_ID,
              ms.style AS STYLE,
              ms.COLOR AS COLOR,
              ms.dimension AS DIM,
              ms.sku_size AS SKU_SIZE,
              NVL(IL.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID
              FROM ialoc_content ioc
              LEFT OUTER JOIN ialoc il ON ioc.ia_id = il.ia_id
              AND ioc.location_id = il.location_id
              LEFT OUTER JOIN master_sku ms 
              ON ms.UPC_CODE = ioc.IACONTENT_ID
              INNER JOIN IA ON 
               ia.ia_id =il.ia_id
              WHERE ia.PICKING_AREA_FLAG ='Y'
              AND ms.inactive_flag IS NULL
              <if c="$style">AND ms.STYLE IN (<a sep=','>:style</a>)</if>
              <if>AND il.vwh_id=:vwh_id</if>
              
              <if c="$has_multiple_location">AND exists (SELECT 1 AS UPC_CODE
                                                    FROM ialoc i
                                                     WHERE i.assigned_upc_code = ms.upc_code
                                                     GROUP BY i.assigned_upc_code, i.vwh_id
                                                    HAVING count(i.assigned_upc_code) &gt;= 2)</if>
              GROUP BY ioc.iacontent_id,
              il.vwh_id,
              ms.style,
              ms.COLOR,
              ms.dimension,
              ms.sku_size,
              NVL(IL.WAREHOUSE_LOCATION_ID,'Unknown')
   )
   SELECT nvl(psi.STYLE,fpk.STYLE) AS STYLE,
          nvl(psi.COLOR,fpk.COLOR) AS COLOR,
          nvl(psi.DIM,fpk.DIM) AS DIM,
          nvl(psi.SKU_SIZE,fpk.SKU_SIZE) AS SKU_SIZE,
          psi.PRICE_SEASON_CODE AS PRICE_SEASON_CODE,
          psi.QUANTITY AS PSC_QTY,
          fpk.FPK_QUANTITY AS FPK_QUANTITY,
          nvl(psi.VWH_ID,fpk.VWH_ID) AS VWH_ID,
          nvl(PSI.WAREHOUSE_LOCATION_ID,FPK.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID
     FROM PSC_SKU_Inventory psi
     FULL OUTER JOIN FPK_QTY fpk ON fpk.STYLE = psi.STYLE
                                AND fpk.COLOR = psi.COLOR
                                AND fpk.DIM = psi.DIM
                                AND fpk.SKU_SIZE = psi.SKU_SIZE
                                and fpk.vwh_id = psi.vwh_id 
                                AND FPK.WAREHOUSE_LOCATION_ID = PSI.WAREHOUSE_LOCATION_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbStyle" DbType="String" Name="style" />
            <asp:ControlParameter ControlID="cbMultipleLocation" Type="String" Name="has_multiple_location" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" />
            <asp:Parameter Type="String" Name="CartonReserveArea" DefaultValue="<%$ Appsettings:CartonReserveArea %>" />
            <asp:Parameter Type="String" Name="PickingArea" DefaultValue="<%$ Appsettings:PickingArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--GridView--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="WAREHOUSE_LOCATION_ID;$;STYLE;COLOR;DIM;SKU_SIZE;VWH_ID">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building" SortExpression="WAREHOUSE_LOCATION_ID"/>
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE"
                HeaderToolTip="Style" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR"
                HeaderToolTip="Color" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="DIM" HeaderText="Dim" SortExpression="DIM" HeaderToolTip="Dimension"
                ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE"
                HeaderToolTip="Sku Sizes" ItemStyle-HorizontalAlign="Left" />
            <%-- <jquery:MatrixField DataHeaderFields="PRICE_SEASON_CODE" DataValueFields="PSC_QTY"
                HeaderText="Quantity For Season Code" DataMergeFields="STYLE,COLOR,DIM,SKU_SIZE,VWH_ID"
                DataValueFormatString="{0:N0}" DataHeaderSortFields="PRICE_SEASON_CODE" DataTotalFormatString="{0:N0}"
                DisplayColumnTotals="true" DataHeaderFormatString="{0::$PRICE_SEASON_CODE:~:No Season}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </jquery:MatrixField>--%>
            <m:MatrixField DataHeaderFields="PRICE_SEASON_CODE" DataCellFields="PSC_QTY" DataMergeFields="STYLE,COLOR,DIM,SKU_SIZE,VWH_ID,WAREHOUSE_LOCATION_ID" headertext="Quantity For Season Code">
                <MatrixColumns>
                    <m:MatrixColumn DataCellFormatString="{0:N0}"  ColumnType="CellValue" DisplayColumnTotal="true" DataHeaderFormatString="{0::$PRICE_SEASON_CODE:~:No Season} "
                             ColumnTotalFormatString="{0:N0}"                        
                        />
                </MatrixColumns>
                <ItemStyle HorizontalAlign ="Right" />
                <FooterStyle HorizontalAlign="Right" />  
                 
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="FPK_QUANTITY" HeaderText="Quantity in|Picking Area" ItemStyle-HorizontalAlign="Right"
                FooterStyle-HorizontalAlign="Right" SortExpression="FPK_QUANTITY" HeaderToolTip="Quantity in Picking Area"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" DataFormatString="{0:N0}" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
                HeaderToolTip="Virtual Warehouse" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

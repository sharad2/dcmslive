<%@ Page Title="QTY against a label in given area" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6887 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_15.aspx $
 *  $Id: R130_15.aspx 6887 2014-05-29 13:44:40Z skumar $
 * Version Control Template Added.
 * Note: The old report in DcmsLive 2009 was wrong and the current is right
--%>
<script runat="server">
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is showing carton quantity on the basis of SKU, quality, price season code, area, virtual warehouse and building. This report helps user to see # Allocated carton/pieces along  with # Unallocated Cartons / pcs. User also has the option to display those SKUs which are assigned on multiple SKU locations. " />
    <meta name="ReportId" content="130.15" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Provide check box to select/unselect all Buildings.|Earlier this report was only listing those carton which were not assigned to any request. Now report is showing all the cartons whether they are assigned or not assigned to any request. Now report is showing # Allocated cartons / pcs along with # Unallocated Cartons / pcs." />
    <meta name="Version" content="$Id: R130_15.aspx 6887 2014-05-29 13:44:40Z skumar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
                $('#cbAll').attr('checked', 'checked');
            };

        });
        function cbAll_OnClientChange(event, ui) {
            if ($('#cbAll').is(':checked')) {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').removeAttr('checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" Value="(Please Select)"
                    FriendlyName="Label" ToolTip="Select Label for which you want to display records">
                    <Validators>
                       
                        <i:Required />
                    </Validators>
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" UsableInventoryAreaOnly="true"
                    ShowAll="true" StorageAreaType="CTN" ToolTip="Select Area for which you want to disply records"
                    QueryString="area_id">
                </d:InventoryAreaSelector>
                <eclipse:LeftLabel ID="leftLabel2" runat="server" Text="" />
                <i:CheckBoxEx runat="server" ID="cbShowMultipleLocations" Text="SKU having multiple locations"
                    CheckedValue="Y" FriendlyName="Show Multiple Locations" ToolTip="If checked, only those SKUs will be displayed which are assigned on multiple SKU locations" />
                <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Select Virtual Warehouse for which you want to display records"
                    QueryString="vwh_id" />

                <eclipse:LeftLabel ID="lblQuality" runat="server" Text="Quality" />
                <oracle:OracleDataSource ID="dsQuality" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                            select tqc.quality_code as qualitycode ,
                            tqc.description as qualitydescription
                            from tab_quality_code tqc
                            order by tqc.quality_rank asc
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlQualityCode" runat="server" ToolTip="Select Quality for which you want to display records" DataSourceID="dsQuality" DataFields="qualitycode,qualitydescription"
                    DataTextFormatString="{0}:{1}" DataValueFormatString="{0}" QueryString="quality_code">
                    <Items>
                        <eclipse:DropDownItem Text="(All)" Value="" Persistent="Always" />
                    </Items>
                    </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
              <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel2" runat="server">
                     <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server"  Text="Building"/>
                     <br />
                     <br />
                    <i:CheckBoxEx ID="cbAll" runat="server" FriendlyName="Select All" OnClientChange="cbAll_OnClientChange">                     
                    </i:CheckBoxEx>
                     Click to Select/UnSelect all
                </eclipse:LeftPanel>
               <%-- <i:CheckBoxEx ID="cbAll" runat="server" Text="Select All" OnClientChange="cbAll_OnClientChange" ></i:CheckBoxEx>--%>
                <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                              WITH Q1 AS
                                    (SELECT TWL.WAREHOUSE_LOCATION_ID, TWL.DESCRIPTION
                                     FROM TAB_WAREHOUSE_LOCATION TWL
   
                                     UNION
                                     SELECT 'Unknown' AS WAREHOUSE_LOCATION_ID, 'Unknown' AS DESCRIPTION
                                     FROM TAB_WAREHOUSE_LOCATION TWL)
                                     SELECT Q1.WAREHOUSE_LOCATION_ID,
                                     (Q1.WAREHOUSE_LOCATION_ID || ':' || Q1.DESCRIPTION) AS DESCRIPTION
                                      FROM Q1
                            ORDER BY 1
                    </SelectSql>
                </oracle:OracleDataSource>

                <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                    QueryString="warehouse_location_id">
                </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
      <%--  <if c="$multiloc">WITH assigned_sku AS (
    SELECT MS.SKU_ID, I.VWH_ID,  NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID
      FROM IALOC I
     INNER JOIN MASTER_SKU MS
        ON I.ASSIGNED_UPC_CODE = MS.UPC_CODE
     WHERE 1= 1
   <if>AND I.VWH_ID = CAST(:vwh as varchar2(255))</if>
   <if>AND <a pre="NVL(I.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
       AND I.ASSIGNED_UPC_CODE IS NOT NULL
     GROUP BY MS.SKU_ID, I.VWH_ID, NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown')
    HAVING COUNT(I.ASSIGNED_UPC_CODE) >= 2
)</if>
SELECT SCD.STYLE AS STYLE,
       SCD.COLOR AS COLOR,
       SCD.DIMENSION AS DIMENSION,
       SCD.SKU_SIZE AS SKU_SIZE,
       MAX(TIA.SHORT_NAME) AS SHORT_NAME,
       SC.CARTON_STORAGE_AREA,
       SC.QUALITY_CODE,
       SC.VWH_ID,
       SC.PRICE_SEASON_CODE AS PRICE_SEASON_CODE,
       SUM(COUNT(CASE
                   WHEN SCD.REQ_PROCESS_ID IS NOT NULL THEN
                    SCD.CARTON_ID
                 END)) OVER(PARTITION BY SC.VWH_ID, SCD.STYLE, SCD.COLOR, SCD.DIMENSION, SCD.SKU_SIZE, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS ALLOCATED_CTN,
       SUM(COUNT(CASE
                   WHEN SCD.REQ_PROCESS_ID IS NULL THEN
                    SCD.CARTON_ID
                 END)) OVER(PARTITION BY SC.VWH_ID, SCD.STYLE, SCD.COLOR, SCD.DIMENSION, SCD.SKU_SIZE, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS UNLLOCATED_CTN,
       SUM(SUM(CASE
                 WHEN SCD.REQ_PROCESS_ID IS NOT NULL THEN
                  SCD.QUANTITY
               END)) OVER(PARTITION BY SC.VWH_ID, SCD.STYLE, SCD.COLOR, SCD.DIMENSION, SCD.SKU_SIZE, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS ALLOCATED_QTY,
       SUM(SUM(CASE
                 WHEN SCD.REQ_PROCESS_ID IS NULL THEN
                  SCD.QUANTITY
               END)) OVER(PARTITION BY SC.VWH_ID, SCD.STYLE, SCD.COLOR, SCD.DIMENSION, SCD.SKU_SIZE, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS UNLLOCATED_QTY,
       COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                MSLOC.WAREHOUSE_LOCATION_ID,
                'Unknown') AS WAREHOUSE_LOCATION_ID,
       MAX(MST.LABEL_ID) AS LABEL_ID,
       SUM(SCD.QUANTITY) AS TOTAL_PIECES
  FROM SRC_CARTON SC
 INNER JOIN SRC_CARTON_DETAIL SCD
    ON SC.CARTON_ID = SCD.CARTON_ID
  LEFT OUTER JOIN MASTER_STYLE MST
    ON SCD.STYLE = MST.STYLE
  LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
    ON TIA.INVENTORY_STORAGE_AREA = SC.CARTON_STORAGE_AREA
  LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSLOC
    ON SC.CARTON_STORAGE_AREA = MSLOC.STORAGE_AREA
   AND SC.LOCATION_ID = MSLOC.LOCATION_ID
            <if c="$multiloc">INNER JOIN assigned_sku a ON SC.vwh_id = a.vwh_id
                          AND SCD.SKU_ID = A.SKU_ID
      AND A.warehouse_location_id =
       NVL(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID)
                           </if>
 WHERE 1=1
<if>AND SC.vwh_id = CAST(:vwh as varchar2(255))</if>
  <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, msloc.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND SC.carton_storage_area = CAST(:area as varchar(255))</if>
   <if>AND mst.label_id = CAST(:label as varchar2(255))</if>
   <if>And sc.quality_code=:quality_code</if>
 GROUP BY SCD.STYLE,
          SCD.COLOR,
          SCD.DIMENSION,
          SCD.SKU_SIZE,
          SC.QUALITY_CODE,
          SC.CARTON_STORAGE_AREA,
          SC.PRICE_SEASON_CODE,
          COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                   MSLOC.WAREHOUSE_LOCATION_ID,
                   'Unknown'),SC.VWH_ID--%>

<if c="$multiloc">WITH ASSIGNED_SKU AS
 (SELECT I.ASSIGNED_UPC_CODE AS UPC_CODE,
         I.VWH_ID,
         NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID
    FROM IALOC I
   WHERE 1 = 1
 <if>AND I.VWH_ID = CAST(:vwh as varchar2(255))</if>
 <if>AND <a pre="NVL(I.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
     AND I.ASSIGNED_UPC_CODE IS NOT NULL  
     AND i.location_type ='RAIL'
   GROUP BY I.ASSIGNED_UPC_CODE,
            I.VWH_ID,
            NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown')
  HAVING COUNT(I.ASSIGNED_UPC_CODE) >= 2)</if>
SELECT SC.VWH_ID,
       SCD.SKU_ID,
       SC.QUALITY_CODE,
       SC.CARTON_STORAGE_AREA,
       SC.PRICE_SEASON_CODE AS PRICE_SEASON_CODE,
       MAX(SCD.STYLE) AS STYLE,
       MAX(SCD.COLOR) AS COLOR,
       MAX(SCD.DIMENSION) AS DIMENSION,
       MAX(SCD.SKU_SIZE) AS SKU_SIZE,
       MAX(TIA.SHORT_NAME) AS SHORT_NAME,
       SUM(COUNT(CASE
                   WHEN SCD.REQ_PROCESS_ID IS NOT NULL THEN
                    SCD.CARTON_ID
                 END)) OVER(PARTITION BY SC.VWH_ID, SCD.SKU_ID, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS ALLOCATED_CTN,
       SUM(COUNT(CASE
                   WHEN SCD.REQ_PROCESS_ID IS NULL THEN
                    SCD.CARTON_ID
                 END)) OVER(PARTITION BY SC.VWH_ID, SCD.SKU_ID, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS UNLLOCATED_CTN,
       SUM(SUM(CASE
                 WHEN SCD.REQ_PROCESS_ID IS NOT NULL THEN
                  SCD.QUANTITY
               END)) OVER(PARTITION BY SC.VWH_ID, SCD.SKU_ID, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS ALLOCATED_QTY,
       SUM(SUM(CASE
                 WHEN SCD.REQ_PROCESS_ID IS NULL THEN
                  SCD.QUANTITY
               END)) OVER(PARTITION BY SC.VWH_ID, SCD.SKU_ID, SC.CARTON_STORAGE_AREA, COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), SC.QUALITY_CODE) AS UNLLOCATED_QTY,
       COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                MSLOC.WAREHOUSE_LOCATION_ID,
                'Unknown') AS WAREHOUSE_LOCATION_ID,
       MAX(MST.LABEL_ID) AS LABEL_ID,
       SUM(SCD.QUANTITY) AS TOTAL_PIECES
  FROM SRC_CARTON SC
 INNER JOIN SRC_CARTON_DETAIL SCD
    ON SC.CARTON_ID = SCD.CARTON_ID
 INNER JOIN MASTER_SKU MS
    ON MS.STYLE = SCD.STYLE
   AND MS.COLOR = SCD.COLOR
   AND MS.DIMENSION = SCD.DIMENSION
   AND MS.SKU_SIZE = SCD.SKU_SIZE
  LEFT OUTER JOIN MASTER_STYLE MST
    ON MS.STYLE = MST.STYLE
  LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSLOC
    ON SC.LOCATION_ID = MSLOC.LOCATION_ID
 INNER JOIN TAB_INVENTORY_AREA TIA
    ON SC.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
  <if c="$multiloc">INNER JOIN ASSIGNED_SKU A
    ON SC.VWH_ID = A.VWH_ID
   AND MS.UPC_CODE = A.UPC_CODE
   AND A.WAREHOUSE_LOCATION_ID =
       COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                MSLOC.WAREHOUSE_LOCATION_ID,
                'Unknown')</if>
 WHERE 1=1
   <if>AND SC.vwh_id = CAST(:vwh as varchar2(255))</if>
   <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, msloc.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND SC.carton_storage_area = CAST(:area as varchar(255))</if>
   <if>AND mst.label_id = CAST(:label as varchar2(255))</if>
   <if>And sc.quality_code=:quality_code</if>
   AND TIA.STORES_WHAT = 'CTN'
 GROUP BY SC.VWH_ID,
          SCD.SKU_ID,
          SC.QUALITY_CODE,
          SC.CARTON_STORAGE_AREA,
          SC.PRICE_SEASON_CODE,
          COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                   MSLOC.WAREHOUSE_LOCATION_ID,
                   'Unknown')
          
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlLabel" Type="String" Direction="Input" Name="label" />
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Direction="Input" Name="vwh" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="ctlCtnArea" Type="String" Direction="Input" Name="area" />
            <asp:ControlParameter ControlID="cbShowMultipleLocations" Type="String" Direction="Input"
                Name="multiloc" />
       <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input"
                Name="quality_code" />
             </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="false"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="SHORT_NAME;warehouse_location_id;$;style;color;dimension;sku_size;vwh_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" />
            <eclipse:MultiBoundField DataFields="SHORT_NAME" HeaderText="Area"
                SortExpression="SHORT_NAME" />
            <eclipse:MultiBoundField DataFields="vwh_id" SortExpression="vwh_id" HeaderText="VWh" HeaderToolTip="Virtual Warehouse of the SKU" />
            <eclipse:MultiBoundField DataFields="style" SortExpression="style" HeaderText="Style" ItemStyle-HorizontalAlign="Left" HeaderToolTip="Style of the SKU"/>
            <eclipse:MultiBoundField DataFields="color" SortExpression="color" HeaderText="Color"  HeaderToolTip="Color of the SKU"/>
            <eclipse:MultiBoundField DataFields="dimension" SortExpression="dimension" HeaderText="Dim"  HeaderToolTip="Dimension of the SKU"/>
            <eclipse:MultiBoundField DataFields="sku_size" SortExpression="sku_size" HeaderText="Size" HeaderToolTip="Size of the SKU" />
            <eclipse:MultiBoundField DataFields="Label_id" SortExpression="Label_id" HeaderText="Label" HeaderToolTip="Label of the SKU" />      
            <eclipse:MultiBoundField DataFields="quality_code" SortExpression="quality_code" HeaderText="Quality" ItemStyle-HorizontalAlign="Left" HeaderToolTip="Quality of the SKU"/>  
             <m:MatrixField DataHeaderFields="price_season_code"  DataCellFields="TOTAL_PIECES" DataMergeFields="style,color,dimension,sku_size,vwh_id,SHORT_NAME, warehouse_location_id,quality_code"
                HeaderText="Quantity for Season Code">
                <MatrixColumns>
                    
                    <m:MatrixColumn ColumnType="CellValue" DataHeaderFormatString="{0::$price_season_code:~:No Season}"
                        DisplayColumnTotal="true" DataCellFormatString="{0:#,###}" >
                        
                    </m:MatrixColumn>
                </MatrixColumns>
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="RowTotal" DisplayColumnTotal="true" DataCellFormatString="{0:N0}">
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="ALLOCATED_QTY" SortExpression="ALLOCATED_QTY" HeaderText="Quantity|Allocated"  DataSummaryCalculation="ValueSummation" HeaderToolTip="Total Quantity of the SKU which are assigned to any request"
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"/>
            <eclipse:MultiBoundField DataFields="UNLLOCATED_QTY" SortExpression="UNLLOCATED_QTY" HeaderText="Quantity|Unallocated "  DataSummaryCalculation="ValueSummation" HeaderToolTip="Total Quantity of the SKU which are not assigned to any request."
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"/> 
            <eclipse:MultiBoundField DataFields="ALLOCATED_CTN" HeaderText="No. Of Carton|Allocated" SortExpression="ALLOCATED_CTN"  DataSummaryCalculation="ValueSummation"
                ItemStyle-HorizontalAlign="Right" HeaderToolTip="No. of cartons which are assigned to any request" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"/>
            <eclipse:MultiBoundField DataFields="UNLLOCATED_CTN" SortExpression="UNLLOCATED_CTN" HeaderToolTip="No. of cartons which are not assigned to any request" HeaderText="No. Of Carton|Unallocated "  DataSummaryCalculation="ValueSummation"
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"/>
             </Columns>
    </jquery:GridViewEx>
</asp:Content>

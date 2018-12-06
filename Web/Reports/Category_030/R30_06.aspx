<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKUs to be Pulled" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6351 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_030/R30_06.aspx $
 *  $Id: R30_06.aspx 6351 2014-02-07 11:43:38Z skumar $
 * Version Control Template Added.
--%>
<%--Standard Pattern--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays a list of SKUs which can be pulled from the specified carton area" />
    <meta name="ReportId" content="30.06" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R30_06.aspx 6351 2014-02-07 11:43:38Z skumar $" />
    <meta name="ChangeLog" content="Provided UPC parameter  so that user can see pullable area for specific SKU." />
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
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Destination Area" />
                <%-- <eclipse:EnhancedTextBox ID="tbDestinationArea" runat="server" SkinID="Area" />--%>
                <oracle:OracleDataSource ID="dsDestArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                <SelectSql>
                 select inventory_storage_area as inventory_storage_area,
                               short_name || ':' || description as description,
                               CASE
                                 WHEN t.stores_what = 'CTN' THEN
                                  'Carton Areas'
                                 ELSE
                                  'SKU Area'
                               END as area_type,
                               1 AS option_sort_sequence
                          from tab_inventory_area t
                         WHERE unusable_inventory IS NULL
                        union
                        select ia_id, short_name||':'||short_description, 'Shipping Areas', 2
                          from ia
                         where ia.shipping_area_flag = 'Y'
                         order by 1
                </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ctlDestCtnArea" runat="server" DataSourceID="dsDestArea" ToolTip="Destination Area" DataFields="inventory_storage_area,description"   
                  DataTextFormatString="{1}" QueryString="destination_area" DataValueFormatString="{0}">
                 <Items>
                 <eclipse:DropDownItem Text="(All)" Value="" Persistent="Always" />   
                 </Items> 
                 </i:DropDownListEx2>
                <eclipse:LeftLabel runat="server" Text="Specify Source Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" StorageAreaType="CTN"
                    UsableInventoryAreaOnly="true" FriendlyName="Source Carton Area" Value="<%$ AppSettings:CartonReserveArea %>"
                    ToolTip="Choose source area" QueryString="inventory_storage_area" />
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Choose virtual warehouse" QueryString="vwh_id" />
                 <eclipse:LeftLabel runat="server" Text="UPC" />
                <i:TextBoxEx ID="tbProcessId" runat="server" QueryString="upc_code" FriendlyName="UPC">
                </i:TextBoxEx>
                 </eclipse:TwoColumnPanel>
            <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server"  Text="Building"/>
                     <br />
                     <br />
                    <i:CheckBoxEx ID="cbAll" runat="server" FriendlyName="Select All" OnClientChange="cbAll_OnClientChange" FilterDisabled="true">                     
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
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                  <SelectSql>     
                   with Q1 AS(SELECT ctn.vwh_id AS vwh_id,
                      CTNDET.SKU_ID,
               ctn.quality_code as quality_code,
               SUM(ctndet.quantity) AS pieces,
               ctndet.req_process_id AS process_id,
               MIN(ctndet.req_assign_date) AS min_assign_date,
               MAX(ctndet.req_assign_date) AS max_assign_date,
               COUNT(distinct priority) AS priority_count,
               MAX(reqdet.priority) AS max_priority,
               MIN(reqdet.priority) AS min_priority,
               reqdet.destination_inv_storage_area AS destination_inv_storage_area,
               MAX(TIA.SHORT_NAME) AS SHORT_NAME,
               COALESCE(TIA.WAREHOUSE_LOCATION_ID,
               MSLOC.WAREHOUSE_LOCATION_ID,
               'Unknown') AS WAREHOUSE_LOC,
               MAX(reqdet.location_id) AS restock_aisle
          FROM src_carton ctn
          INNER JOIN src_carton_detail ctndet ON ctn.carton_id =
                                                      ctndet.carton_id
          INNER JOIN src_req_detail reqdet ON ctndet.req_process_id =
                                                   reqdet.req_process_id
                                               AND ctndet.req_module_code =
                                                   reqdet.req_module_code
                                               AND ctndet.req_line_number =
                                                   reqdet.req_line_number
          left outer join master_sku ms on 
                      ctndet.sku_id= ms.sku_id
          left outer JOIN TAB_INVENTORY_AREA TIA
          ON reqdet.destination_inv_storage_area = TIA.INVENTORY_STORAGE_AREA
          LEFT OUTER JOIN master_storage_location msloc ON ctn.carton_storage_area =
                                                                 msloc.storage_area
                                                             AND ctn.location_id =
                                                                 msloc.location_id
         WHERE ctn.carton_storage_area = :inventory_storage_area
         <if>AND ctn.vwh_id = :vwh_id</if>
             AND ctn.suspense_date IS NULL
                     <if c="$req_module_code">AND CTNDET.REQ_MODULE_CODE ='REQ2'</if>
                      <if>and ms.upc_code =:upc_code</if>
         <if>AND reqdet.destination_inv_storage_area = :destination_area</if>
         <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
          GROUP BY ctn.vwh_id,
                     CTNDET.SKU_ID,
                  ctn.quality_code,
                  ctndet.req_process_id,
                  reqdet.location_id,
                  reqdet.destination_inv_storage_area,
                 COALESCE(TIA.WAREHOUSE_LOCATION_ID,
               MSLOC.WAREHOUSE_LOCATION_ID,
               'Unknown') 
                               
                  UNION All

SELECT PS.VWH_ID AS VWH_ID,
       BDET.sku_id,
       '01' AS QUALITY_CODE,
       SUM(BDET.EXPECTED_PIECES) AS PIECES,
       BKT.BUCKET_ID AS PROCESS_ID,
       MIN(BOX.DATE_CREATED) AS MIN_ASSIGN_DATE,
       MAX(BOX.DATE_CREATED) AS MAX_ASSIGN_DATE,
      NULL AS PRIORITY_COUNT,
       TO_NUMBER((SELECT MAX(SP.SPLH_VALUE)
                   FROM SPLH SP
                  WHERE SP.SPLH_ID = '$SHPPULPRI')) AS MAX_PRIORITY,
       TO_NUMBER((SELECT MIN(SP.SPLH_VALUE)
                   FROM SPLH SP
                  WHERE SP.SPLH_ID = '$SHPPULPRI')) AS MIN_PRIORITY,
       (BKT.SHIP_IA_ID) AS DESTINATION_INV_STORAGE_AREA,
       MAX(IA.SHORT_NAME) AS SHORT_NAME,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOC,
       NULL AS RESTOCK_AISLE
  FROM BOX BOX
INNER JOIN BOXDET BDET
    ON BOX.UCC128_ID = BDET.UCC128_ID
   AND BOX.PICKSLIP_ID = BDET.PICKSLIP_ID
INNER JOIN PS PS
    ON BOX.PICKSLIP_ID = PS.PICKSLIP_ID
INNER JOIN BUCKET BKT
    ON PS.BUCKET_ID = BKT.BUCKET_ID
LEFT OUTER JOIN IA  ON 
BKT.SHIP_IA_ID = IA.IA_ID
 WHERE BOX.CARTON_ID IS NOT NULL
   AND BOX.IA_ID IS NULL
   AND BOX.STOP_PROCESS_DATE IS NULL
   AND BDET.STOP_PROCESS_DATE IS NULL
   <if c="$req_module_code">AND PS.TRANSFER_DATE IS NOT NULL</if>
                      <else>AND PS.TRANSFER_DATE IS NULL</else>
   <if>and ps.vwh_id=:vwh_id</if>
                      <if>and bdet.upc_code =:upc_code</if>
   <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>and bkt.pull_carton_area = :inventory_storage_area</if>
   <if>and bkt.ship_ia_id =:destination_area </if> 
GROUP BY PS.VWH_ID,
         BDET.sku_id,
         BKT.BUCKET_ID,
         PS.WAREHOUSE_LOCATION_ID,
         BKT.SHIP_IA_ID)
SELECT Q1.VWH_ID                       AS VWH_ID,
       Q1.SKU_ID                       AS SKU_ID,
       MSKU.STYLE                      AS STYLE,
       MSKU.COLOR                      AS COLOR,
       MSKU.DIMENSION                  AS DIMENSION,
       MSKU.SKU_SIZE                   AS SKU_SIZE,
       MST.LABEL_ID                    AS LABEL_ID,
       Q1.QUALITY_CODE                 AS QUALITY_CODE,
       Q1.PIECES                       AS PIECES,
       Q1.PROCESS_ID                   AS PROCESS_ID,
       Q1.min_assign_date              AS min_assign_date,
       Q1.max_assign_date              AS max_assign_date,
       Q1.MIN_PRIORITY                 AS MIN_PRIORITY,
       Q1.MAX_PRIORITY                 AS MAX_PRIORITY,
       Q1.DESTINATION_INV_STORAGE_AREA AS DESTINATION_INV_STORAGE_AREA,
       Q1.SHORT_NAME                   AS SHORT_NAME,
       Q1.WAREHOUSE_LOC                AS WAREHOUSE_LOC,
       Q1.RESTOCK_AISLE                AS RESTOCK_AISLE
  FROM Q1
  LEFT OUTER JOIN MASTER_SKU MSKU
    ON Q1.SKU_ID = MSKU.SKU_ID
  LEFT OUTER JOIN MASTER_STYLE MST
    ON MSKU.STYLE = MST.STYLE
 
                                  
                  </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlDestCtnArea" Direction="Input" Name="destination_area"
                Type="String" PropertyName="Value" ConvertEmptyStringToNull="true" />
            <asp:ControlParameter ControlID="ctlWhLoc" Direction="Input" Name="warehouse_location_id"
                Type="String" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
            <asp:ControlParameter ControlID="tbProcessId" Direction="Input" Name="upc_code" Type="String" />
            <asp:QueryStringParameter Name="req_module_code" QueryStringField="req_module_code" Direction="Input" />
            <asp:ControlParameter ControlID="ctlCtnArea" Direction="Input" Name="inventory_storage_area" Type="String" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx AllowPaging="false" runat="server" ID="gv" AutoGenerateColumns="false"
        AllowSorting="true" DataSourceID="ds" ShowFooter="true" Visible="true" DefaultSortExpression="warehouse_loc;$;max_priority {0:I};style;color;dimension;sku_size;quality_code">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="process_id" HeaderText="Process /Bucket ID" SortExpression="process_id"
                HeaderToolTip="Process Id" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension"
                HeaderToolTip="Dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="Sizes" />
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality" />
            <eclipse:MultiBoundField DataFields="pieces" HeaderText="Pieces" SortExpression="pieces"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Pieces"
                FooterToolTip="Total Pieces of all SKUs displayed." />
            <eclipse:MultiBoundField DataFields="min_assign_date" DataFormatString="{0:dd MMMM yyyy hh:mm:ss tt}"
                HeaderText="Assign Date | Min" SortExpression="min_assign_date" ItemStyle-CssClass="DateColumn"
                HeaderToolTip="Minimum assign Date." />
            <eclipse:MultiBoundField DataFields="max_assign_date" DataFormatString="{0:dd MMMM yyyy hh:mm:ss tt}"
                HeaderText="Assign Date | Max" SortExpression="max_assign_date" ItemStyle-CssClass="DateColumn"
                HeaderToolTip="Maximum Assign Date" />
            <eclipse:MultiBoundField DataFields="max_priority" HeaderText="Priority | Max" SortExpression="max_priority"
                ItemStyle-HorizontalAlign="Left" HeaderToolTip="Maximum Priority" />
            <eclipse:MultiBoundField DataFields="min_priority" HeaderText="Priority | Min" SortExpression="min_priority"
                ItemStyle-HorizontalAlign="Left" HeaderToolTip="Minimum Priority" />
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label ID" />
            <eclipse:MultiBoundField DataFields="SHORT_NAME" HeaderText="Dest. Area"
                SortExpression="SHORT_NAME" HeaderToolTip="Destination Area" />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual Warehouse" />
            <eclipse:MultiBoundField DataFields="warehouse_loc" HeaderText="Building" SortExpression="warehouse_loc"
                HeaderToolTip="Warehouse Locations" />
            <eclipse:MultiBoundField DataFields="restock_aisle" HeaderText="RST Aisle" SortExpression="restock_aisle"
                ItemStyle-HorizontalAlign="Left" HeaderToolTip="Restock Aisle" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

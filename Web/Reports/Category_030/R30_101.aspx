<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKU Detail for Area" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5625 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_030/R30_101.aspx $
 *  $Id: R30_101.aspx 5625 2013-07-11 09:45:30Z skumar $
 * Version Control Template Added.
--%>
<%--MultiView Pattern--%>
<script runat="server">    
    /// <summary>
    /// Decide which view to show based on the stores what of the selected carton area
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        // ctlCtnArea.SelectedStorageAreaType is All then the query will not execute so it 
        switch (ctlCtnArea.SelectedStorageAreaType)
        {
            case InventoryAreaSelector.StoresWhat.CTN:
                mvSkuDetails.SetActiveView(vwCTN);
                btnGo.GridViewId = gvCartonArea.ID;
                break;

            case InventoryAreaSelector.StoresWhat.SKU:
                mvSkuDetails.SetActiveView(vwSKU);
                btnGo.GridViewId = gvSkuArea.ID;
                break;

            case InventoryAreaSelector.StoresWhat.All:
                // No area has been selected. Query will be cancelled and so it does not matter
                // which view we make active
                mvSkuDetails.SetActiveView(vwCTN);
                btnGo.GridViewId = gvCartonArea.ID;
                break;

            default:
                throw new NotImplementedException();
        }
        base.OnLoad(e);
    }
    

</script>
<asp:Content ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report gives the sku details with price season code and total quantities for a given area." />
    <meta name="ReportId" content="30.101" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R30_101.aspx 5625 2013-07-11 09:45:30Z skumar $" />
</asp:Content>
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filter">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="vwh_id"
                    ToolTip="Choose Virtual Warehouse">
                </d:VirtualWarehouseSelector>
                <eclipse:LeftLabel runat="server" />
                <d:BuildingSelector ID="ctlWHLoc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="warehouse_location"
                    FriendlyName="Warehouse Location" ToolTip="Choose Warehouse Location" ShowAll="false">
                     <Items>
                     <eclipse:DropDownItem Text="All" Value = ""  Persistent="Always" />
                     <eclipse:DropDownItem Text="Unknown" Value = "Unknown" Persistent="Always" />
                    </Items>
                </d:BuildingSelector>
                <eclipse:LeftLabel runat="server" Text="Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" StorageAreaType="All"
                    QueryString="area" ToolTip="Choose Carton Area" />
                <eclipse:LeftLabel runat="server" Text="Quality Code" />
                <i:TextBoxEx runat="server" ID="tbQualityCode" QueryString="quality_code" ToolTip="Please enter the Quality Code" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="btnGo" runat="server" />
    <asp:MultiView ID="mvSkuDetails" runat="server">
        <asp:View ID="vwCTN" runat="server">
            <oracle:OracleDataSource ID="dsCartonArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                WITH sku_info AS
(
SELECT SUM(NVL(CTNDET.QUANTITY, 0)) AS TOTAL_QUANTITY,
      MAX(MSKU.STYLE) AS STYLE,
       MAX(MSKU.COLOR) AS COLOR,
       CTNDET.SKU_ID AS SKU_ID,
       CTN.LOCATION_ID AS LOCATION_ID,
       MAX(MSKU.DIMENSION) AS DIMENSION,
       MAX(MSKU.SKU_SIZE) AS SKU_SIZE,
       tps.price_season_code as price_season_code,
      nvl(WLOC.WAREHOUSE_LOCATION_ID,'Unknown')  AS WAREHOUSE_LOC,
      ctn.quality_code as quality_code
  FROM SRC_CARTON        CTN
   LEFT OUTER JOIN SRC_CARTON_DETAIL CTNDET ON CTNDET.CARTON_ID = CTN.CARTON_ID
   INNER JOIN MASTER_SKU MSKU ON MSKU.SKU_ID=CTNDET.SKU_ID
  INNER JOIN master_style MS ON MS.style = MSKU.style
  INNER JOIN tab_label_group TBL ON TBL.label_id = MS.label_id
                                AND TBL.vwh_id = CTN.vwh_id
  INNER JOIN warehouseloc WLOC ON WLOC.label_group = tbl.label_group
  LEFT OUTER JOIN TAB_PRICE_SEASON TPS ON TPS.PRICE_SEASON_CODE =  CTN.Price_Season_Code
 WHERE CTN.CARTON_STORAGE_AREA != CAST(:CartonReserveArea AS VARCHAR2(255))
 <if>AND ctn.vwh_id = CAST(:vwh_id AS VARCHAR2(255))</if>
       AND CTN.CARTON_STORAGE_AREA = CAST(:area AS VARCHAR2(255))
       <if c="$warehouse_location != 'Unknown'">AND WLOC.Warehouse_Location_Id = :warehouse_location</if>
         <if c="$warehouse_location ='Unknown'">and WLOC.Warehouse_Location_Id is null</if> 
       <if>AND ctn.quality_code = CAST(:quality_code AS VARCHAR2(255))</if>
    GROUP BY 
          CTNDET.SKU_ID,
          WLOC.WAREHOUSE_LOCATION_ID,
          tps.price_season_code,
          ctn.location_id,
          ctn.quality_code
HAVING SUM(CTNDET.QUANTITY) &lt;&gt; 0
              
    UNION
    
SELECT SUM(CTNDET.QUANTITY) AS TOTAL_QUANTITY,
       MAX(MSKU.STYLE) AS STYLE,
       MAX(MSKU.COLOR) AS COLOR,
       CTNDET.SKU_ID AS SKU_ID,
       MSLOC.LOCATION_ID AS LOCATION_ID,
       MAX(MSKU.DIMENSION) AS DIMENSION,
       MAX(MSKU.SKU_SIZE) AS SKU_SIZE,
       tps.price_season_code as price_season_code,
        nvl(MSLOC.WAREHOUSE_LOCATION_ID,'Unknown')  AS WAREHOUSE_LOC,
       ctn.quality_code as quality_code
  FROM SRC_CARTON              CTN
    INNER JOIN src_carton_detail ctndet ON ctndet.carton_id = ctn.carton_id
     INNER JOIN MASTER_SKU MSKU ON MSKU.SKU_ID=CTNDET.SKU_ID
    LEFT OUTER JOIN TAB_PRICE_SEASON TPS ON TPS.PRICE_SEASON_CODE =
                                            CTN.Price_Season_Code
    LEFT OUTER JOIN master_storage_location msloc ON ctn.carton_storage_area =
                                                     msloc.storage_area
                                                 AND ctn.location_id =
                                                     msloc.location_id
 WHERE CTN.CARTON_STORAGE_AREA = CAST(:area AS VARCHAR2(255))
 <if>AND ctn.vwh_id = CAST(:vwh_id AS VARCHAR2(255))</if>
 <if c="$warehouse_location != 'Unknown'">AND msloc.Warehouse_Location_Id = :warehouse_location</if>
 <if c="$warehouse_location ='Unknown'">and msloc.Warehouse_Location_Id is null</if>  
   <if>AND ctn.quality_code = CAST(:quality_code AS VARCHAR2(255))</if>   
 GROUP BY CTNDET.SKU_ID,
          tps.price_season_code,
          nvl(MSLOC.WAREHOUSE_LOCATION_ID,'Unknown') ,
          MSLOC.LOCATION_ID,
          ctn.quality_code
HAVING SUM(CTNDET.QUANTITY) &lt;&gt; 0
)
SELECT SUM(info.TOTAL_QUANTITY) AS TOTAL_QUANTITY,
       MAX(info.STYLE) AS STYLE,
       MAX(info.COLOR) AS COLOR,
       MAX(info.DIMENSION) AS DIMENSION,
       MAX(info.SKU_SIZE) AS SKU_SIZE,
       info.price_season_code,
       info.WAREHOUSE_LOC,
       info.quality_code
  from sku_info info
 GROUP BY info.price_season_code,info.SKU_ID, info.WAREHOUSE_LOC, info.quality_code 
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="ctlWHLoc" Direction="Input" Type="String" Name="warehouse_location" />
                    <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
                    <asp:ControlParameter ControlID="ctlCtnArea" Direction="Input" Type="String" Name="area" />
                    <asp:Parameter Name="CartonReserveArea" Type="String" DefaultValue="<%$  AppSettings: CartonReserveArea %>" />
                    <asp:ControlParameter ControlID="tbQualityCode" Type="String" Direction="Input" Name="quality_code" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvCartonArea" runat="server" DataSourceID="dsCartonArea" AutoGenerateColumns="false"
                AllowSorting="true" ShowFooter="true" DefaultSortExpression="style;color;dimension;sku_size;WAREHOUSE_LOC">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="style" HeaderText="Style" HeaderToolTip="Style of the SKU"
                        SortExpression="style" ItemStyle-HorizontalAlign="Left" />
                    <eclipse:MultiBoundField DataFields="color" HeaderText="Color" HeaderToolTip="Color of the SKU"
                        SortExpression="color" />
                    <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dimension" HeaderToolTip="Dimension of the SKU"
                        SortExpression="dimension" />
                    <eclipse:MultiBoundField DataFields="sku_size" HeaderText="SKU Size" HeaderToolTip="Size of sku."
                        SortExpression="sku_size" />
                    <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" HeaderToolTip="Quality Code"
                        SortExpression="quality_code" />
                    
                    <m:MatrixField DataHeaderFields="price_season_code" DataCellFields="TOTAL_QUANTITY"
                        RowTotalHeaderText="Total Quantity" DataMergeFields="style,color,dimension,sku_size,WAREHOUSE_LOC"
                        HeaderText="Price Season Code">
                        <MatrixColumns>
                            <m:MatrixColumn ColumnType="CellValue" DisplayColumnTotal="true" DataHeaderFormatString="{0::$price_season_code:~:No Season}"
                                DataCellFormatString="{0:N0}" />
                        </MatrixColumns>
                        <MatrixColumns>
                            <m:MatrixColumn ColumnType="RowTotal" DisplayColumnTotal="true" DataCellFormatString="{0:N0}">
                            </m:MatrixColumn>
                        </MatrixColumns>
                    </m:MatrixField>
                    <eclipse:MultiBoundField DataFields="WAREHOUSE_LOC" HeaderText="Wh.Loc" HeaderToolTip="Location of SKU in Building"
                        SortExpression="WAREHOUSE_LOC" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View ID="vwSKU" runat="server">
            <oracle:OracleDataSource ID="dsSkuArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                SELECT SKU.STYLE AS STYLE,
          SKU.COLOR AS COLOR,
          SKU.DIMENSION AS DIMENSION,
          SKU.SKU_SIZE AS SKU_SIZE,
          MAX(SKU.INVENTORY_QUANTITY) AS tot_quantity_sku,
          WLOC.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOC,
          sku.quality_code as quality_code
     FROM V_SKU_INVENTORY SKU  
    INNER JOIN TAB_LABEL_GROUP tbl ON tbl.vwh_id = sku.vwh_id
    INNER JOIN MASTER_STYLE ms ON ms.style = sku.style
                              AND ms.label_id = tbl.label_id
     INNER JOIN WAREHOUSELOC wloc ON wloc.label_group = tbl.label_group
    WHERE SKU.VWH_ID = CAST(:vwh_id AS VARCHAR2(255))
      AND SKU.AREA_DESCRIPTION = CAST(:area AS VARCHAR2(255))
      AND WLOC.WAREHOUSE_LOCATION_ID = CAST(:warehouse_location AS VARCHAR2(255))
    GROUP BY SKU.COLOR,
             SKU.DIMENSION,
             SKU.SKU_SIZE,
             WLOC.WAREHOUSE_LOCATION_ID,
             SKU.STYLE,
             sku.quality_code
   HAVING SUM(SKU.INVENTORY_QUANTITY) &lt;&gt; 0
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="ctlWHLoc" Direction="Input" Type="String" Name="warehouse_location" />
                    <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
                    <asp:ControlParameter ControlID="ctlCtnArea" Direction="Input" Type="String" Name="area" />
                    <asp:ControlParameter ControlID="tbQualityCode" Type="String" Direction="Input" Name="quality_code" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvSkuArea" runat="server" DataSourceID="dsSkuArea" AutoGenerateColumns="false"
                AllowSorting="true" ShowFooter="true" DefaultSortExpression="style;color;dimension;sku_size;WAREHOUSE_LOC"
                DisplayMasterRow="false">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="style" HeaderText="SKU|Style" HeaderToolTip="Style of sku."
                        SortExpression="style" ItemStyle-HorizontalAlign="Left" />
                    <eclipse:MultiBoundField DataFields="color" HeaderText="SKU|Color" HeaderToolTip="Style of sku."
                        SortExpression="color" />
                    <eclipse:MultiBoundField DataFields="dimension" HeaderText="SKU|Dimension" HeaderToolTip="Style of sku."
                        SortExpression="dimension" />
                    <eclipse:MultiBoundField DataFields="sku_size" HeaderText="SKU|Size" HeaderToolTip="Style of sku."
                        SortExpression="sku_size" />
                    <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" HeaderToolTip="Quality Code"
                        SortExpression="quality_code" />
                    <eclipse:MultiBoundField DataFields="tot_quantity_sku" HeaderText="Total Quantity"
                        ItemStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="WAREHOUSE_LOC" HeaderText="Wh.Loc" HeaderToolTip="Location of SKU in warehouse"
                        SortExpression="WAREHOUSE_LOC" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

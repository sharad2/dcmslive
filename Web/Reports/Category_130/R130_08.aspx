<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Carton Suspense Report" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6332 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_08.aspx $
 *  $Id: R130_08.aspx 6332 2013-12-20 05:16:20Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        gv.RowDataBound += new GridViewRowEventHandler(gv_RowDataBound);
        base.OnInit(e);
    }

    void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {

    }

    protected void ctlCtnArea_PreRender(object sender, EventArgs e)
    {
        //if (!IsPostBack)
        //    ctlCtnArea.Value = ConfigurationManager.AppSettings["RestockingArea"].ToString();
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays a list of cartons in suspense for 
                                        the specified area. Report displays the cartons along with their SKU details.User can also see the suspense carton along with passed building." />
    <meta name="ReportId" content="130.08" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_08.aspx 6332 2013-12-20 05:16:20Z skumar $" />
    <meta name="ChangeLog" content="Fixed bug, report will not crash while performing sorting on the column 'carton_id'." />
     <script type="text/javascript">
         $(document).ready(function () {
             if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                 //Do nothing if any of checkbox is checked
             }
             else {
                 $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
             }
         });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Carton Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    StorageAreaType="CTN">
                </d:InventoryAreaSelector>             
            </eclipse:TwoColumnPanel>
             <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Building" />
                    <oracle:OracleDataSource ID="dsbuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
                        DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsbuilding" FriendlyName="Building"
                        QueryString="building">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
  SELECT   CTN.CARTON_ID AS CARTON_ID,
         MAX(TIA.SHORT_NAME) AS CARTON_STORAGE_AREA,
         MAX(MST.LABEL_ID) AS LABEL_ID,
         MAX(CTN.SUSPENSE_DATE) AS SUSPENSE_DATE,
         MAX(CTN.PALLET_ID) AS PALLET_ID,
         MAX(CTN.LOCATION_ID) AS carton_location,
         MAX(MSKU.STYLE) AS STYLE,
         MAX(MSKU.COLOR) AS COLOR,
         MAX(MSKU.DIMENSION) AS DIMENSION,
         MAX(MSKU.SKU_SIZE) AS SKU_SIZE,
         MAX(CTN.QUALITY_CODE) AS QUALITY_CODE,
         MAX(CTNDET.QUANTITY) AS QUANTITY,
         MIN(IFO.LOCATION_ID) AS MIN_FPK_LOCATION,
         MAX(IFO.LOCATION_ID) AS MAX_FPK_LOCATION,
         COUNT(DISTINCT IFO.LOCATION_ID) AS COUNT_FPK_LOCATION,
         MAX(CTN.VWH_ID) AS VWH_ID,
         MAX(CTN.MODIFIED_BY)AS operator_name,
         MAX(NVL(TIA.WAREHOUSE_LOCATION_ID,MSL.WAREHOUSE_LOCATION_ID)) AS WAREHOUSE_LOCATION_ID
    FROM SRC_CARTON CTN
    LEFT OUTER JOIN SRC_CARTON_DETAIL CTNDET
      ON CTN.CARTON_ID = CTNDET.CARTON_ID
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON MSKU.SKU_ID = CTNDET.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MST
      ON MST.STYLE = MSKU.STYLE
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA ON
    CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL ON
    CTN.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
    AND CTN.LOCATION_ID = MSL.LOCATION_ID
    LEFT OUTER JOIN IALOC IFO
      ON MSKU.UPC_CODE = IFO.ASSIGNED_UPC_CODE
    AND CTN.VWH_ID = IFO.VWH_ID   
    WHERE CTN.SUSPENSE_DATE IS NOT NULL
    <if>AND CTN.CARTON_STORAGE_AREA = :carton_storage_area</if>
    <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSL.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <%--<if c="$warehouse_location_id ='Unknown'">and (TIA.WAREHOUSE_LOCATION_ID is null and MSL.Warehouse_Location_Id is null)</if> --%>
    GROUP BY CTN.CARTON_ID 
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlCtnArea" Name="carton_storage_area" Type="String"
                PropertyName="Value" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="warehouse_location_id" Type="String"
                PropertyName="Value" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        ShowFooter="true" AllowSorting="true" DefaultSortExpression="warehouse_location_id;carton_storage_area;$;style;color;dimension;sku_size">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="carton_id" HeaderText="Carton" SortExpression="carton_id"
                HeaderToolTip="Suspense Carton ID" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" ItemStyle-Font-Bold="true" NullDisplayText="Unknown"
                HeaderToolTip="Warehouse Location" />
            <eclipse:MultiBoundField DataFields="carton_storage_area" HeaderText="Area" SortExpression="carton_storage_area"
                ItemStyle-Font-Bold="true" HeaderToolTip="Carton Storage Area" />
            <%-- <eclipse:MultiBoundField DataFields="carton_location,pallet_id" HeaderText="Location/<br />Pallet"
                SortExpression="carton_location,pallet_id" ItemStyle-HorizontalAlign="Left" HeaderToolTip="Carton Location"
                AccessibleHeaderText="LocationPallet" />--%>
            <asp:BoundField DataField="carton_location" HeaderText="Location" SortExpression="carton_location" />
            <asp:BoundField DataField="pallet_id" HeaderText="Pallet" SortExpression="pallet_id" />
            <asp:BoundField DataField="label_id" HeaderText="Label" SortExpression="label_id" />
            <asp:BoundField DataField="suspense_date" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}"
                HeaderText="Suspense Date" SortExpression="suspense_date" HeaderStyle-Wrap="false"
                ItemStyle-Wrap="false" ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField DataField="operator_name" HeaderText="Operator" SortExpression="operator_name" />
            <asp:BoundField DataField="style" HeaderText="Style" SortExpression="style" ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField DataField="color" HeaderText="Color" SortExpression="color" />
            <asp:BoundField DataField="dimension" HeaderText="Dim" SortExpression="dimension" />
            <asp:BoundField DataField="sku_size" HeaderText="Size" SortExpression="sku_size"
                ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField DataField="quality_code" HeaderText="Quality" SortExpression="quality_code" />
            <eclipse:MultiBoundField DataFields="quantity" SortExpression="quantity" HeaderText="Quantity"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Total Pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <asp:TemplateField HeaderText="Assigned FPK Location" HeaderStyle-Wrap="false" SortExpression="min_fpk_location">
                <ItemTemplate>
                    <eclipse:MultiValueLabel runat="server" DataFields="count_fpk_location, min_fpk_location, max_fpk_location" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" HeaderToolTip="Virtual Warehouse"
                SortExpression="vwh_id" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

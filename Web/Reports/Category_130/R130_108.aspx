<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Numbered Area Carton Details Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4829 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_108.aspx $
 *  $Id: R130_108.aspx 4829 2013-01-10 07:16:59Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (cbSpecificBuilding.Checked && string.IsNullOrEmpty(ctlWhLoc.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide select at least one building.";
            return;
        }
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.108" />
    <meta name="Description" content="This report will display the carton details along with 
                                        warehouse location and virtual warehouse for numbered 
                                        area for a particular label." />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R130_108.aspx 4829 2013-01-10 07:16:59Z skumar $" />
    <script type="text/javascript">
        function ctlWhLoc_OnClientChange(event, ui) {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {
                $('#cbSpecificBuilding').attr('checked', 'checked');
            } else {
                $('#cbSpecificBuilding').removeAttr('checked', 'checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="" />
                <%--<dcms:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    QueryString="vwh_id" />--%>
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    QueryString="vwh_id" ToolTip="Choose virtual warehouse" />
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Building" />
                <%--<d:BuildingSelector ID="ctlWarehouseLocation" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" FriendlyName="Building" ToolTip="Choose warehouse location" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    QueryString="warehouse_location_id">
                    <Items>
                        <eclipse:DropDownItem Text="Unknown" Value="Unknown" Persistent="Always" />
                    </Items>
                </d:BuildingSelector>--%>

                <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel5" runat="server"  Text="Check For Specific Building"/>
                    <i:CheckBoxEx ID="cbSpecificBuilding" runat="server" FriendlyName="Specific Building">
                        <Validators>
                            <i:Custom OnServerValidate="cbSpecificBuilding_OnServerValidate" />
                        </Validators>
                    </i:CheckBoxEx>
                </eclipse:LeftPanel>

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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Check For building In"
                    QueryString="building" OnClientChange="ctlWhLoc_OnClientChange">
                </i:CheckBoxListEx>

                <eclipse:LeftLabel runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlStyleLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="Label_Id"
                    ToolTip="Choose style label" FriendlyName="Label" />
                <eclipse:LeftLabel runat="server" Text="Quality Code" />
                <i:TextBoxEx runat="server" ID="tbQualityCode" QueryString="quality_code" ToolTip="Please enter the Quality Code" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
SELECT MAX(CTN.VWH_ID) AS VWH_ID,
       CTN.CARTON_ID AS CARTON_ID,
       MAX(CTN.PALLET_ID) AS PALLET_ID,
       MAX(CTN.LOCATION_ID) AS LOCATION_ID,
       MAX(CTN.SUSPENSE_DATE) AS SUSPENSE_DATE,
       MAX(CTNDET.REQ_PROCESS_ID) AS REQ_PROCESS_ID,
       MAX(CTNDET.REQ_MODULE_CODE) AS REQ_MODULE_CODE,
       SUM(CTNDET.QUANTITY) AS QUANTITY,
       MAX(MSKU.STYLE) AS STYLE,
       MAX(MSKU.COLOR) AS COLOR,
       MAX(MSKU.DIMENSION) AS DIMENSION,
       MAX(MSKU.SKU_SIZE) AS SKU_SIZE,
       MAX(CTN.QUALITY_CODE) AS QUALITY_CODE,
       MAX(MS.LABEL_ID) AS LABEL_ID,
       MAX(COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                    MSLOC.WAREHOUSE_LOCATION_ID,
                    'Unknown')) AS WAREHOUSE_LOCATION_ID
  FROM SRC_CARTON CTN
 INNER JOIN SRC_CARTON_DETAIL CTNDET
    ON CTN.CARTON_ID = CTNDET.CARTON_ID
 INNER JOIN MASTER_SKU MSKU
    ON CTNDET.SKU_ID = MSKU.SKU_ID
 LEFT OUTER JOIN MASTER_STYLE MS
    ON MSKU.STYLE = MS.STYLE
 LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSLOC
    ON CTN.CARTON_STORAGE_AREA = MSLOC.STORAGE_AREA
   AND CTN.LOCATION_ID = MSLOC.LOCATION_ID
 INNER JOIN TAB_INVENTORY_AREA TIA
    ON CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
 WHERE TIA.LOCATION_NUMBERING_FLAG = 'Y'
   <if> AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <%--<if c="$warehouse_location_id ='Unknown'">AND TIA.WAREHOUSE_LOCATION_ID IS NULL
   AND MSLOC.WAREHOUSE_LOCATION_ID IS NULL</if>--%>
   <if>AND CTN.VWH_ID = cast(:vwh_id as varchar2(255))</if>
   <if>AND MS.LABEL_ID = cast(:style_label as varchar2(255))</if>
   <if>AND ctn.quality_code = cast(:quality_code as varchar2(255))</if>
 GROUP BY CTN.CARTON_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID"
                Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlStyleLabel" Name="style_label" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbQualityCode" Name="quality_code" Type="String"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="WAREHOUSE_LOCATION_ID;VWH_ID;$;LOCATION_ID;CARTON_ID"
        AllowPaging="true" PageSize="<%$ AppSettings: PageSize %>">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="CARTON_ID" HeaderText="Carton" SortExpression="CARTON_ID"
                HeaderToolTip="Carton Id" />
            <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" SortExpression="PALLET_ID"
                HeaderToolTip="Pallet Id" />
            <eclipse:MultiBoundField DataFields="LOCATION_ID" HeaderText="Location" SortExpression="LOCATION_ID"
                HeaderToolTip="Location Id" />
            <eclipse:MultiBoundField DataFields="SUSPENSE_DATE" HeaderText="Suspense Date" SortExpression="SUSPENSE_DATE"
                DataFormatString="{0:d}" HeaderToolTip="Suspense Date" />
            <eclipse:MultiBoundField DataFields="REQ_PROCESS_ID" HeaderText="REQ Process ID"
                SortExpression="REQ_PROCESS_ID" HeaderToolTip="REQ Process ID" />
            <eclipse:MultiBoundField DataFields="REQ_MODULE_CODE" HeaderText="REQ Module Code"
                SortExpression="REQ_MODULE_CODE" HeaderToolTip="REQ Module Code" />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE"
                HeaderToolTip="Style of SKU" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR"
                HeaderToolTip="Color of SKU" />
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim" SortExpression="DIMENSION"
                HeaderToolTip="Dim of SKU" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE"
                HeaderToolTip="Size of SKU" />
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality Code" />
            <eclipse:MultiBoundField DataFields="QUANTITY" HeaderText="Quantity" SortExpression="QUANTITY"
                DataSummaryCalculation="ValueSummation" HeaderToolTip="Quantity stored for a carton"
                FooterToolTip="Total quantity for carton">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building"
                SortExpression="WAREHOUSE_LOCATION_ID" HeaderToolTip="Warehouse Location" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
                HeaderToolTip="Virtual Warehouse" />
            <eclipse:MultiBoundField DataFields="LABEL_ID" HeaderText="Label" SortExpression="LABEL_ID"
                HeaderToolTip="Label Id" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

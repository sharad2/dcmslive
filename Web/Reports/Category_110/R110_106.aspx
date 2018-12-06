<%@ Page Title="Pickslip Detail For Specific Customer" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5022 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_106.aspx $
 *  $Id: R110_106.aspx 5022 2013-02-19 11:03:54Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report Shows the Detail of pickslip for passed customer and pickslip status" />
    <meta name="ReportId" content="110.106" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_106.aspx 5022 2013-02-19 11:03:54Z skumar $" />
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
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Customer" />
                <i:TextBoxEx ID="tbcustomer" runat="server" QueryString="customer_id" />
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Status" />
                <i:TextBoxEx ID="tbstatus" runat="server" QueryString="reporting_status" />
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbdc" runat="server" QueryString="customer_dc_id" />
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="Customer Store" />
                <i:TextBoxEx ID="tbstore" runat="server" QueryString="customer_store_id" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Customer Order Type" />
                <i:RadioButtonListEx runat="server" ID="rblOrderType" QueryString="order_type" Value="A">
                    <Items>
                        <i:RadioItem Text="All" Value="A" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
                <%--<eclipse:LeftLabel ID="LeftLabel14" runat="server" />
                <d:BuildingSelector FriendlyName="Building" runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" QueryString="warehouse_location_id" ToolTip="Please Select building "
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />--%>
                <eclipse:LeftLabel ID="lblBuilding" runat="server" Text="Building" />
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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding"
                    QueryString="warehouse_location_id">
                </i:CheckBoxListEx>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbdeliverydate" Text="Delivery Date" CheckedValue="Y"
                        QueryString="delivery_date" FriendlyName="Delivery Date" Checked="false" />
                </eclipse:LeftPanel>
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Delivery Date"
                    QueryString="delivery_start_date" Text="-7">
                    <Validators>
                        <i:Filter DependsOn="cbdeliverydate" DependsOnState="Checked" />
                        <i:Date />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Delivery Date" QueryString="delivery_end_date"
                    Text="0">
                    <Validators>
                        <i:Filter DependsOn="cbdeliverydate" DependsOnState="Checked" />
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
  WITH Q1 AS
 (SELECT PS.PICKSLIP_ID AS PICKSLIP_ID,
         MAX(PS.PO_ID) AS PO_ID,
         SUM(BD.CURRENT_PIECES) AS SHIPPED_PIECES,
         SUM((BD.CURRENT_PIECES * BD.EXTENDED_PRICE)) AS SHIPPED_DOLLARS,
         MAX(PO.START_DATE) AS START_DATE,
         MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(PO.CANCEL_DATE) AS CANCEL_DATE,
         MAX(PS.TOTAL_QUANTITY_ORDERED) AS ORDER_QUANTITY,
         MAX(PS.TOTAL_DOLLARS_ORDERED) AS ORDER_DOLLARS,
         MAX(nvl(PS.WAREHOUSE_LOCATION_ID,'Unknown')) AS BUILDING
    FROM PS
    LEFT OUTER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
     AND B.STOP_PROCESS_DATE IS NULL
    LEFT OUTER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
     AND BD.STOP_PROCESS_DATE IS NULL
   WHERE PS.TRANSFER_DATE IS NULL
     AND PS.PICKSLIP_CANCEL_DATE IS NULL
   <if>AND PS.CUSTOMER_ID = :customer_id</if>
   <if c="$reporting_status != 'IN ORDER BUCKET'">and PS.REPORTING_STATUS =:REPORTING_STATUS</if> 
   <if c="$reporting_status = 'IN ORDER BUCKET'"> and 1=2</if>
   <if c="$customer_type='D'">AND PS.EXPORT_FLAG IS NULL</if>
   <if c="$customer_type='I'">AND PS.EXPORT_FLAG = 'Y'</if>
   <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
   <if>AND po.start_date &lt;= CAST(:delivery_end_date AS DATE)</if>
 <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
 <if>AND PS.CUSTOMER_STORE_ID = :customer_store_id</if>
  <%-- <if>AND ps.warehouse_location_id = :warehouse_location_id</if>--%>
    <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   GROUP BY PS.PICKSLIP_ID
  
  UNION ALL
  
  SELECT DP.PICKSLIP_ID AS PICKSLIP_ID,
         MAX(DP.CUSTOMER_ORDER_ID) AS PO_ID,
         NULL AS SHIPPED_PIECES,
         NULL AS SHIPPED_DOLLARS,
         MAX(DP.DELIVERY_DATE) AS START_DATE,
         MAX(DP.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(DP.CANCEL_DATE) AS CANCEL_DATE,
         SUM(DPD.EXTENDED_PRICE * DPD.QUANTITY_ORDERED) AS ORDER_DOLLARS,
         SUM(DPD.QUANTITY_ORDERED) AS ORDER_QUANTITY,
         MAX(NVL(DP.WAREHOUSE_LOCATION_ID,'Unknown')) AS BUILDING
    FROM DEM_PICKSLIP DP
    LEFT OUTER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DP.PICKSLIP_ID = DPD.PICKSLIP_ID
    WHERE DP.PS_STATUS_ID = 1 
   <if c="$reporting_status != 'IN ORDER BUCKET'"> and 1=2</if>
   <if c="$reporting_status = 'IN ORDER BUCKET'"> and 1=1</if>
   <if>AND DP.CUSTOMER_ID = :customer_id</if>
   <if>AND DP.customer_dist_center_id = :customer_dc_id</if>
   <if>AND DP.CUSTOMER_STORE_ID = :customer_store_id</if>
   <if c="$customer_type='D'">AND DP.EXPORT_FLAG IS NULL</if>
   <if c="$customer_type='I'">AND DP.EXPORT_FLAG = 'Y'</if>
   <if>AND DP.delivery_date &gt;= CAST(:delivery_start_date AS DATE)</if>         
   <if>AND DP.delivery_date &lt;= CAST(:delivery_end_date AS DATE)</if> 
   <if>AND DP.customer_dist_center_id =:customer_dc_id</if>
   <if>AND DP.CUSTOMER_STORE_ID =:customer_store_id</if>
  <%-- <if>AND DP.warehouse_location_id = :warehouse_location_id</if>--%>
            <if>AND <a pre="NVL(dp.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   GROUP BY DP.PICKSLIP_ID)
SELECT Q1.PICKSLIP_ID     AS PICKSLIP_ID,
       Q1.PO_ID           AS PO_ID,
       Q1.ORDER_QUANTITY  AS ORDER_QUANTITY,
       Q1.ORDER_DOLLARS   AS ORDER_DOLLARS,
       Q1.SHIPPED_PIECES  AS SHIPPED_PIECES,
       Q1.SHIPPED_DOLLARS AS SHIPPED_DOLLARS,
       Q1.START_DATE      AS START_DATE,
       Q1.DC_CANCEL_DATE  AS DC_CANCEL_DATE,
       Q1.CANCEL_DATE     AS CANCEL_DATE,
       Q1.BUILDING        AS BUILDING
  FROM Q1
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbcustomer" Type="String" Name="customer_id" />
            <asp:ControlParameter ControlID="tbstatus" Type="String" Name="REPORTING_STATUS" />
            <asp:ControlParameter ControlID="tbdc" Type="String" Name="customer_dc_id" />
            <asp:ControlParameter ControlID="tbstore" Type="String" Name="customer_store_id" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="delivery_start_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="delivery_end_date" />
            <asp:ControlParameter ControlID="rblOrderType" Type="String" Direction="Input" Name="customer_type" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="warehouse_location_id" Type="String"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" AllowPaging="true" PageSize="200" DataSourceID="ds" DefaultSortExpression="BUILDING;$;">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="BUILDING" HeaderText="Building" SortExpression="BUILDING" />
            <eclipse:MultiBoundField DataFields="PICKSLIP_ID" HeaderText="Pickslip" SortExpression="PICKSLIP_ID" />
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO" SortExpression="PO_ID" />
            <eclipse:MultiBoundField DataFields="START_DATE" DataFormatString="{0:d}" HeaderText="Date|Start"
                SortExpression="START_DATE" />
            <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="Date|DC Cancel"
                SortExpression="DC_CANCEL_DATE" />
            <eclipse:MultiBoundField DataFields="CANCEL_DATE" DataFormatString="{0:d}" HeaderText="Date|Cancel"
                SortExpression="CANCEL_DATE" />
            <eclipse:MultiBoundField DataFields="ORDER_QUANTITY" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right" HeaderText="Ordered|Pieces" SortExpression="ORDER_QUANTITY" />
            <eclipse:MultiBoundField DataFields="ORDER_DOLLARS" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:C2}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C2}"
                FooterStyle-HorizontalAlign="Right" HeaderText="Ordered|Dollars" SortExpression="ORDER_DOLLARS" />
            <eclipse:MultiBoundField DataFields="SHIPPED_PIECES" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right" HeaderText="Shipped|Pieces" SortExpression="SHIPPED_PIECES" />
            <eclipse:MultiBoundField DataFields="SHIPPED_DOLLARS" ItemStyle-HorizontalAlign="Right"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:C2}" DataFooterFormatString="{0:C2}"
                FooterStyle-HorizontalAlign="Right" HeaderText="Shipped|Dollars" SortExpression="SHIPPED_DOLLARS" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

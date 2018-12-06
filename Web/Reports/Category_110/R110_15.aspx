<%@ Page Title="Customer Open Order Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5029 $
 *  $Author: ssinghal $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_15.aspx $
 *  $Id: R110_15.aspx 5029 2013-02-26 13:20:51Z ssinghal $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report shows order status of customer. It also shows no.of SKU, pickslip belonging to various order status, total boxes in order as well as boxes scanned at UPS. Information shown can be further filtered by using customer DC, customer store, order type, delivery date and building." />
    <meta name="ReportId" content="110.15" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Provided count of boxes which are already scanned at UPS station. User can also drill down on this number.|Provided building filter for displaying customer order status list building wise.|You get to know amount shipped in column 'In Box Dollars' in drill down(R110.103 and 104).|Changed column names from PO ID, UPC CODE and Warehouse Location ID to PO, UPC and Building." />
    <meta name="Version" content="$Id: R110_15.aspx 5029 2013-02-26 13:20:51Z ssinghal $" />
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
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Customer ID" />
                <i:TextBoxEx ID="tbcustomer" runat="server" QueryString="customer_id">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbdc" runat="server" QueryString="customer_dc_id" />
                <eclipse:LeftLabel runat="server" Text="Customer Store" />
                <i:TextBoxEx ID="tbstore" runat="server" QueryString="customer_store_id" />
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Customer Order Type" />
                <i:RadioButtonListEx runat="server" ID="rblOrderType" QueryString="order_type" Value="A">
                    <Items>
                        <i:RadioItem Text="All" Value="A" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
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
                    QueryString="building">
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
WITH ORDERED_INFO(COUNT_PICKSLIPS,
REPORTING_STATUS,
SORT_SEQUENCE,
COUNT_SKU,
ORDER_QUANTITY,
ORDER_DOLLARS,
COUNT_PO,
WAREHOUSE_LOCATION_ID) AS
 (SELECT COUNT(DISTINCT PS.PICKSLIP_ID),
         PS.REPORTING_STATUS,
         MAX(TRS.SORT_SEQUENCE),
         COUNT(DISTINCT PD.UPC_CODE),
         SUM(PD.PIECES_ORDERED),
         SUM(PD.PIECES_ORDERED * PD.EXTENDED_PRICE), 
         COUNT(DISTINCT PS.PO_ID) AS COUNT_PO,
         PS.WAREHOUSE_LOCATION_ID
    FROM PS
    INNER JOIN PSDET PD
    ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
    <if c="$delivery_start_date or $delivery_end_date">
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION</if>
   INNER JOIN TAB_REPORTING_STATUS TRS
      ON TRS.REPORTING_STATUS = PS.REPORTING_STATUS
   WHERE PS.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
     AND PS.PICKSLIP_CANCEL_DATE IS NULL
 <if>AND PS.customer_id = :customer_id</if>
 <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
 <if>AND ps.CUSTOMER_STORE_ID =:customer_store_id</if>
 <if c="$customer_type='D'">AND PS.EXPORT_FLAG IS NULL</if>
 <if c="$customer_type='I'">AND PS.EXPORT_FLAG = 'Y'</if>
 <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
 <if>AND po.start_date &lt;= CAST(:delivery_end_date AS DATE)</if>
 <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:Building_id</a></if>
   GROUP BY PS.REPORTING_STATUS, PS.WAREHOUSE_LOCATION_ID),
PACKED_PIECES(REPORTING_STATUS,
TOTAL_BOXES,
UPS_SCAN_COUNT,
SHIPPED_PIECES,
SHIPPED_DOLLARS,
WAREHOUSE_LOCATION_ID) AS
 (SELECT PS.REPORTING_STATUS,
         COUNT(DISTINCT B.UCC128_ID),
         COUNT(DISTINCT(CASE
                          WHEN B.PRO_NUMBER IS NOT NULL THEN
                           B.UCC128_ID
                        END)),
         SUM(BD.CURRENT_PIECES),
         SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE),
         PS.WAREHOUSE_LOCATION_ID
    FROM PS
     <if c="$delivery_start_date or $delivery_end_date">
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION</if>
   INNER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     AND PS.PICKSLIP_CANCEL_DATE IS NULL
    <if>AND PS.customer_id = :customer_id</if>
 <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
 <if>AND ps.CUSTOMER_STORE_ID =:customer_store_id</if>
 <if c="$customer_type='D'">AND PS.EXPORT_FLAG IS NULL</if>
 <if c="$customer_type='I'">AND PS.EXPORT_FLAG = 'Y'</if>
 <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
 <if>AND po.start_date &lt;= CAST(:delivery_end_date AS DATE)</if>
 <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:Building_id</a></if>
   GROUP BY PS.REPORTING_STATUS,PS.WAREHOUSE_LOCATION_ID)
SELECT NVL(OI.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
       OI.REPORTING_STATUS      AS REPORTING_STATUS,
       OI.SORT_SEQUENCE         AS SORT_SEQUENCE,
       OI.COUNT_PO              AS COUNT_PO,
       OI.COUNT_PICKSLIPS       AS COUNT_PICKSLIPS,
       OI.COUNT_SKU             AS COUNT_SKU,
       SI.TOTAL_BOXES           AS TOTAL_BOXES,
       SI.UPS_SCAN_COUNT        AS UPS_SCAN_COUNT,
       OI.ORDER_QUANTITY        AS ORDER_QUANTITY,
       OI.ORDER_DOLLARS         AS ORDER_DOLLARS,
       SI.SHIPPED_PIECES        AS SHIPPED_PIECES,
       SI.SHIPPED_DOLLARS       AS SHIPPED_DOLLARS
  FROM ORDERED_INFO OI
  LEFT OUTER JOIN PACKED_PIECES SI
    ON SI.REPORTING_STATUS = OI.REPORTING_STATUS
   AND SI.WAREHOUSE_LOCATION_ID = OI.WAREHOUSE_LOCATION_ID

UNION ALL

SELECT NVL(DP.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
       'IN ORDER BUCKET' AS REPORTING_STATUS,
       1 AS SORT_SEQUENCE,
       COUNT(DISTINCT DP.CUSTOMER_ORDER_ID) AS COUNT_PO,
       COUNT(DISTINCT DP.PICKSLIP_ID) AS COUNT_PICKSLIPS,
       COUNT(DISTINCT DPD.UPC_CODE) AS COUNT_SKU,
       NULL AS TOTAL_BOXES,
       NULL AS UPS_SCAN_COUNT,
       SUM(DPD.QUANTITY_ORDERED) AS ORDER_QUANTITY,
       SUM(DPD.EXTENDED_PRICE * DPD.QUANTITY_ORDERED) AS ORDER_DOLLARS,
       NULL AS SHIPPED_PIECES,
       NULL AS SHIPPED_DOLLARS
  FROM DEM_PICKSLIP DP
  INNER JOIN DEM_PICKSLIP_DETAIL DPD
    ON DP.PICKSLIP_ID = DPD.PICKSLIP_ID
 WHERE DP.PS_STATUS_ID = 1
 <if>AND DP.customer_dist_center_id =:customer_dc_id</if>
 <if>AND DP.CUSTOMER_STORE_ID =:customer_store_id</if>
 <if c="$customer_type='D'">AND DP.EXPORT_FLAG IS NULL</if>
 <if c="$customer_type='I'">AND DP.EXPORT_FLAG = 'Y'</if>
 <if c="$customer_type='B'"></if>
 <if>AND DP.delivery_date &gt;= CAST(:delivery_start_date AS DATE)</if>         
 <if>AND DP.delivery_date &lt;= CAST(:delivery_end_date AS DATE)</if>  
 <if>AND DP.customer_id = :customer_id</if>
 <if>AND <a pre="NVL(DP.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:Building_id</a></if>
 GROUP BY NVL(DP.WAREHOUSE_LOCATION_ID,'Unknown')
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbcustomer" Type="String" Name="customer_id" />
            <asp:ControlParameter ControlID="tbdc" Type="String" Name="customer_dc_id" />
            <asp:ControlParameter ControlID="tbstore" Type="String" Name="customer_store_id" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="delivery_start_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="delivery_end_date" />
            <asp:ControlParameter ControlID="rblOrderType" Type="String" Direction="Input" Name="customer_type" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="Building_id" Type="String"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="warehouse_location_id;$;SORT_SEQUENCE">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" />
            <eclipse:MultiBoundField DataFields="REPORTING_STATUS" HeaderText="Status" SortExpression="REPORTING_STATUS" />
            <eclipse:SiteHyperLinkField DataTextField="COUNT_PO" DataNavigateUrlFields="REPORTING_STATUS,warehouse_location_id"
                HeaderText="No. Of|PO" DataNavigateUrlFormatString="R110_103.aspx?REPORTING_STATUS={0}&warehouse_location_id={1}"
                SortExpression="COUNT_PO" AppliedFiltersControlID="ButtonBar1$af">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="COUNT_PICKSLIPS" DataNavigateUrlFields="REPORTING_STATUS,warehouse_location_id"
                HeaderText="No. Of|Pickslip" DataNavigateUrlFormatString="R110_106.aspx?REPORTING_STATUS={0}&warehouse_location_id={1}"
                SortExpression="COUNT_PICKSLIPS" AppliedFiltersControlID="ButtonBar1$af">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="COUNT_SKU" ItemStyle-HorizontalAlign="Right"
                HeaderText="No. Of|SKU" SortExpression="COUNT_SKU" />
            <eclipse:MultiBoundField DataFields="TOTAL_BOXES" ItemStyle-HorizontalAlign="Right"
                HeaderText="Boxes|Count" SortExpression="TOTAL_BOXES" DataFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
            <eclipse:SiteHyperLinkField DataTextField="UPS_SCAN_COUNT" DataNavigateUrlFields="REPORTING_STATUS,warehouse_location_id"
                HeaderText="Boxes|Scanned At UPS" DataNavigateUrlFormatString="R110_105.aspx?REPORTING_STATUS={0}&warehouse_location_id={1}&UPSSCAN=Y"
                SortExpression="UPS_SCAN_COUNT" AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}"
                DataFooterFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="ORDER_QUANTITY" HeaderText="Ordered|Pieces"
                SortExpression="ORDER_QUANTITY" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="ORDER_DOLLARS" HeaderText="Ordered|Dollars"
                SortExpression="ORDER_DOLLARS" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C2}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C2}" FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="SHIPPED_PIECES" HeaderText="Shipped|Pieces"
                SortExpression="SHIPPED_PIECES" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="SHIPPED_DOLLARS" HeaderText="Shipped|Dollars"
                SortExpression="SHIPPED_DOLLARS" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:C2}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C2}" FooterStyle-HorizontalAlign="Right" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

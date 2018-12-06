<%@ Page Title="Open Orders Drilldown Report (Customer Wise) " Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Register Src="R110_08.ascx" TagName="R110_08" TagPrefix="uc1" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6554 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_08/R110_102.aspx $
 *  $Id: R110_102.aspx 6554 2014-03-26 05:43:08Z skumar $
 * Version Control Template Added.
--%>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {

        //if (!IsPostBack)
        //{
        //    // Display the filters
        //    ucFilters.Tabs.Selected = 0;
        //}
        var ddlStatus = (EclipseLibrary.Web.JQuery.Input.DropDownListEx2)ucFilters.FindControl("ddlStatus");
        ddlStatus.Visible = true;
        ddlStatus.FilterDisabled = false;
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbcustomer = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbcustomer");
        tbcustomer.Visible = true;
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbPiecesPerDay = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbPiecesPerDay");
        tbPiecesPerDay.FilterDisabled = true;
        base.OnLoad(e);

    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The Report Displays Details Of All Customers" />
    <meta name="ReportId" content="110.102" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_102.aspx 6554 2014-03-26 05:43:08Z skumar $" />

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <uc1:R110_08 ID="ucFilters" runat="server" />
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" FilterContainerId="ucFilters" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
WITH PSDATA AS
 (SELECT COUNT(DISTINCT PS.PICKSLIP_ID) AS PICKSLIP_ID,
         SUM(PD.PIECES_ORDERED) AS PIECES_ORDERED,
         COUNT(DISTINCT PD.UPC_CODE) AS TOTAL_SKU_ORDERED,
         SUM(PD.PIECES_ORDERED * PD.EXTENDED_PRICE) AS ORDERED_DOLLARS,
         PS.CUSTOMER_ID AS CUSTOMER_ID,
         COUNT(DISTINCT PS.PO_ID) AS PO_ID,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         PS.VWH_ID AS VWH_ID
    FROM PS PS
     <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">
     INNER JOIN po po ON 
     po.customer_id = ps.customer_id 
     and po.po_id = ps.po_id 
     and po.iteration = ps.iteration</if>
     INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
     and ps.pickslip_cancel_date IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>
      <if c="$vas"> 
       AND PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
       WHERE PV.VAS_ID IS NOT NULL
       <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>
       )</if>
     <if>and ps.customer_id =:customer_id</if>
     <if>AND ps.customer_dc_id = :customer_dc_id</if> 
      <if>AND ps.customer_store_id = :customer_store_id</if>      
     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
     <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
     <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>
     <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
     <if>AND po.start_date &lt; cast(:delivery_end_date as date) + 1</if>
     <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
     <if>AND po.dc_cancel_date &lt;cast(:dc_cancel_end_date as date) + 1</if>
     <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
     <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
     <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
     <if>AND ps.customer_id=:customer_id</if>
   GROUP BY PS.CUSTOMER_ID, PS.WAREHOUSE_LOCATION_ID, PS.VWH_ID
  UNION ALL
  SELECT COUNT(DISTINCT PS2.PICKSLIP_ID) AS PICKSLIP_ID,
         SUM(PS2.QUANTITY_ORDERED) AS PIECES_ORDERED,
         COUNT(DISTINCT PS2.UPC_CODE) AS TOTAL_SKU_ORDERED,
         SUM(PS2.EXTENDED_PRICE * PS2.QUANTITY_ORDERED) AS ORDERED_DOLLARS,
         PS1.CUSTOMER_ID AS CUSTOMER_ID,
         COUNT(DISTINCT PS1.CUSTOMER_ORDER_ID) AS PO_ID,
         NVL(PS1.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         PS1.VWH_ID AS VWH_ID
    FROM DEM_PICKSLIP PS1
   INNER JOIN DEM_PICKSLIP_DETAIL PS2
      ON PS1.PICKSLIP_ID = PS2.PICKSLIP_ID
   WHERE 1 = 1
        <if>and ps1.customer_id =:customer_id</if>
     <if>AND ps1.customer_dist_center_id = :customer_dc_id</if> 
      <if>AND ps1.customer_store_id = :customer_store_id</if> 
            <if c="$vas"> 
       AND PS1.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
       WHERE PV.VAS_ID IS NOT NULL
       <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>
       )</if>
      <if>AND ps1.vwh_id = :vwh_id</if>
      <if>AND <a pre="NVL(ps1.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
      <if c="$reporting_status = 'IN ORDER BUCKET'">AND PS1.PS_STATUS_ID = '1'</if>
      <if c="$reporting_status != 'IN ORDER BUCKET'">AND 1=2</if>
      <if>AND ps1.delivery_date &gt;= cast(:delivery_start_date as date)</if>
      <if>AND ps1.delivery_date &lt; cast(:delivery_end_date as date) + 1</if>
      <if>AND ps1.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
     <if>AND ps1.dc_cancel_date &lt;cast(:dc_cancel_end_date as date) + 1</if>
      <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps1.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
      <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps1.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
      <if c="$order_type='D'">AND ps1.Export_Flag IS NULL</if>
      <if c="$order_type='I'">AND ps1.Export_Flag IS NOT NULL</if>
      <if>AND ps1.customer_id=:customer_id</if>
   GROUP BY PS1.CUSTOMER_ID, PS1.WAREHOUSE_LOCATION_ID, PS1.VWH_ID),
ALL_CUST AS
 (SELECT SUM(PSDATA.PIECES_ORDERED) AS ORDERED_PIECES,
         SUM(PSDATA.TOTAL_SKU_ORDERED) AS TOTAL_SKU_ORDERED,
         ROUND(SUM(PSDATA.ORDERED_DOLLARS), 0) AS ORDERED_DOLLARS,
         PSDATA.CUSTOMER_ID AS CUSTOMER_ID,
         MAX(C.NAME) AS NAME,
         SUM(PSDATA.PO_ID) AS NO_OF_POS,
         PSDATA.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
         PSDATA.VWH_ID AS VWH_ID,
         SUM(PSDATA.PICKSLIP_ID) AS NO_OF_PICKSLIPS
    FROM CUST C
   INNER JOIN PSDATA PSDATA
      ON C.CUSTOMER_ID = PSDATA.CUSTOMER_ID
   GROUP BY PSDATA.WAREHOUSE_LOCATION_ID, PSDATA.CUSTOMER_ID, PSDATA.VWH_ID),
BOX_PICKSLIPS AS
 (SELECT PS.CUSTOMER_ID AS CUSTOMER_ID,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         PS.VWH_ID AS VWH_ID,
         SUM(BD.CURRENT_PIECES / NVL(SKU.PIECES_PER_PACKAGE, 1)) AS UNITS_SHIPPED,
         SUM(BD.CURRENT_PIECES) AS CURRENT_PIECES
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN PS PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
   <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">
     INNER JOIN po po ON 
     po.customer_id = ps.customer_id 
     and po.po_id = ps.po_id 
     and po.iteration = ps.iteration</if>
   INNER JOIN MASTER_SKU SKU
      ON BD.UPC_CODE = SKU.UPC_CODE
   WHERE BD.STOP_PROCESS_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND PS.TRANSFER_DATE IS NULL
     AND PS.PICKSLIP_CANCEL_DATE IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>
     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
     <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
     <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>
     <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
     <if>AND po.start_date &lt; cast(:delivery_end_date as date) + 1</if>
     <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
     <if>AND po.dc_cancel_date &lt;cast(:dc_cancel_end_date as date) + 1</if>
     <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
     <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
     <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
     <if>AND ps.customer_id=:customer_id</if> 
     <if>AND ps.customer_dc_id = :customer_dc_id</if> 
      <if>AND ps.customer_store_id = :customer_store_id</if> 
   GROUP BY PS.CUSTOMER_ID, PS.WAREHOUSE_LOCATION_ID, PS.VWH_ID)
SELECT AC.CUSTOMER_ID           AS CUSTOMER_ID,
       AC.NAME                  AS NAME,
       AC.ORDERED_PIECES        AS ORDERED_PIECES,
       AC.ORDERED_DOLLARS       AS ORDERED_DOLLARS,
       BP.CURRENT_PIECES        AS PIECES_IN_BOXES,
       BP.UNITS_SHIPPED         AS UNITS_SHIPPED,
       AC.NO_OF_PICKSLIPS       AS NO_OF_PICKSLIPS,
       AC.TOTAL_SKU_ORDERED     AS NO_OF_SKU,
       AC.NO_OF_POS             AS NO_OF_POS,
       AC.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       AC.VWH_ID                AS VWH_ID
  FROM ALL_CUST AC
  LEFT OUTER JOIN BOX_PICKSLIPS BP
    ON AC.CUSTOMER_ID = BP.CUSTOMER_ID
   AND AC.WAREHOUSE_LOCATION_ID = BP.WAREHOUSE_LOCATION_ID
   AND AC.VWH_ID = BP.VWH_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ucFilters$ddlStatus" Type="String" Direction="Input"
                Name="reporting_status" />
            <asp:ControlParameter ControlID="ucFilters$ctlVwh_id" Type="String" Direction="Input"
                Name="vwh_id" />
            <asp:ControlParameter ControlID="ucFilters$tbdc" Type="String" Direction="Input"
                Name="customer_dc_id" />
            <asp:ControlParameter ControlID="ucFilters$tbstore" Type="String" Direction="Input"
                Name="customer_store_id" />
            <asp:ControlParameter ControlID="ucFilters$ctlWhloc" Type="String" Direction="Input"
                Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="ucFilters$rblOrderType" Type="String" Direction="Input"
                Name="order_type" />
            <asp:ControlParameter ControlID="ucFilters$cblExclude" Type="String" Direction="Input"
                Name="restrict_type" />
            <asp:ControlParameter ControlID="ucFilters$tbFromDeliveryDate" Type="DateTime" Direction="Input"
                Name="delivery_start_date" />
            <asp:ControlParameter ControlID="ucFilters$tbToDeliveryDate" Type="DateTime" Direction="Input"
                Name="delivery_end_date" />
            <asp:ControlParameter ControlID="ucFilters$tbFromDcCancelDate" Type="DateTime" Direction="Input"
                Name="dc_cancel_start_date" />
            <asp:ControlParameter ControlID="ucFilters$tbToDcCancelDate" Type="DateTime" Direction="Input"
                Name="dc_cancel_end_date" />
            <asp:ControlParameter ControlID="ucFilters$tbcustomer" Type="String" Direction="Input"
                Name="customer_id" />
            <asp:ControlParameter ControlID="ucFilters$cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ucFilters$ddlvas" Type="String" Direction="Input" Name="vas_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false" DefaultSortExpression="WAREHOUSE_LOCATION_ID;$;ORDERED_DOLLARS {0:I}"
        ShowFooter="true" AllowPaging="true" PageSize="200" ShowHeader="true" AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id" HeaderToolTip="Virtual Warehouse of the Order" />
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building" SortExpression="WAREHOUSE_LOCATION_ID" HeaderToolTip="Building of the Orders"/>
            <eclipse:MultiBoundField DataFields="CUSTOMER_ID,NAME" HeaderText="Customer" SortExpression="CUSTOMER_ID " HeaderToolTip="Id with name of the customer"
                DataFormatString="{0}:{1}" />
            <eclipse:MultiBoundField DataFields="ORDERED_PIECES" HeaderText="Ordered|Pieces" HeaderToolTip="Displaying total pieces status wise of the  orders."
                SortExpression="ORDERED_PIECES" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ORDERED_DOLLARS" HeaderText="Ordered|Dollars" HeaderToolTip="Displaying total ordered dollars status wise of the  orders."
                SortExpression="ORDERED_DOLLARS" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:C0}" DataFooterFormatString="{0:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_IN_BOXES" HeaderText="In Box|Pieces" SortExpression="PIECES_IN_BOXES" HeaderToolTip="Total pieces in the box of the  orders."
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField> 
            <eclipse:MultiBoundField DataFields="UNITS_SHIPPED" HeaderText="In Box|Units" SortExpression="UNITS_SHIPPED"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_POS" HeaderText="Number Of|POs" DataNavigateUrlFields="CUSTOMER_ID"
                DataNavigateUrlFormatString="R110_103.aspx?customer_id={0}" AppliedFiltersControlID="ButtonBar1$af" HeaderToolTip="Number Of POs">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="NO_OF_PICKSLIPS " HeaderText="Number Of|Pickslips" HeaderToolTip="Number Of Pickslips"
                SortExpression="NO_OF_PICKSLIPS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_SKU" HeaderText="Number Of|SKUs" DataNavigateUrlFields="CUSTOMER_ID" HeaderToolTip="Number Of SKUs"
                DataNavigateUrlFormatString="R110_104.aspx?customer_id={0}" AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

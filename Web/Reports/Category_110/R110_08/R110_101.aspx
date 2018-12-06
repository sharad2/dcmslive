<%@ Page Title="Open Orders Drilldown Report (Bucket Wise)" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Register Src="R110_08.ascx" TagName="R110_08" TagPrefix="uc1" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6554 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_08/R110_101.aspx $
 *  $Id: R110_101.aspx 6554 2014-03-26 05:43:08Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        EclipseLibrary.Web.JQuery.Input.DropDownListEx2 ddlStatus = (EclipseLibrary.Web.JQuery.Input.DropDownListEx2)ucFilters.FindControl("ddlStatus");
        ddlStatus.Visible = true;
        ddlStatus.FilterDisabled = false;
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbPiecesPerDay = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbPiecesPerDay");
        tbPiecesPerDay.FilterDisabled = true;
        base.OnLoad(e);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Displays the Bucket Wise information of Open Orders." />
    <meta name="ReportId" content="110.101" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_101.aspx 6554 2014-03-26 05:43:08Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <uc1:R110_08 ID="ucFilters" runat="server" />
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" FilterContainerId="ucFilters" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true" >
<SelectSql>
with ordered_stats AS
 (SELECT /*+index (ps PS_P_REPORTING_STATUS_I) */
         sum(PD.PIECES_ORDERED) AS ORDERED_PIECES,
         count(DISTINCT pd.upc_code) as TOTAL_SKU_ORDERED,
         Round(sum(pd.pieces_ordered * pd.extended_price)) as ORDERED_DOLLARS,
         bkt.BUCKET_ID AS BUCKET_ID,
         MAX(BKT.NAME) AS NAME,
         COUNT(DISTINCT PS.PO_ID) AS NO_OF_POS,
         NVL(PS.warehouse_location_id,'Unknown') AS warehouse_location_id,
         PS.vwh_id AS vwh_id,
         count(distinct ps.pickslip_id) AS NO_OF_PICKSLIPS
    FROM BUCKET BKT
  LEFT OUTER join ps ps
      on ps.bucket_id = bkt.bucket_id
    <%--<if c="$vas">LEFT OUTER JOIN PS_VAS PV ON 
    PS.PICKSLIP_ID = PV.PICKSLIP_ID</if>--%>
        LEFT OUTER JOIN PSDET PD ON
      PS.PICKSLIP_ID=PD.PICKSLIP_ID
      <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">INNER JOIN po po ON po.customer_id = ps.customer_id and po.po_id = ps.po_id and po.iteration = ps.iteration</if>    
   WHERE ps.Transfer_date IS NULL
    and ps.pickslip_cancel_date IS NULL
   <if>AND ps.vwh_id = :vwh_id</if>
   <if>AND ps.reporting_status=:reporting_status</if>
     <if>and ps.customer_id =:customer_id</if>
     <if>AND ps.customer_dc_id = :customer_dc_id</if> 
      <if>AND ps.customer_store_id = :customer_store_id</if> 
   <if c="$vas"> 
       AND PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
       WHERE PV.VAS_ID IS NOT NULL
       <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>
       )</if>
   <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>
   <%--<if>AND ps.warehouse_location_id = :warehouse_location_id</if>   --%>
   <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
   <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
   <if>AND po.start_date &lt; cast(:delivery_end_date as date) + 1</if>
   <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
   <if>AND po.dc_cancel_date &lt;cast(:dc_cancel_end_date as date) +1</if>
   <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
   <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
   <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
   <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
   
   GROUP BY NVL(ps.warehouse_location_id,'Unknown'), bkt.bucket_id,PS.vwh_id),

box_stats AS
 (select  /*+ index (sku SKU_UK)*/
         NVL(ps.warehouse_location_id,'Unknown') as warehouse_location_id,
         ps.vwh_id,
         ps.bucket_id,
         SUM(BD.CURRENT_PIECES / NVL(SKU.PIECES_PER_PACKAGE, 1)) AS UNITS_SHIPPED,
         SUM(bd.current_pieces) AS current_pieces
    from boxdet bd
   inner join ps ps
      on ps.pickslip_id = bd.pickslip_id
   left outer JOIN master_sku sku
      ON BD.UPC_CODE = SKU.UPC_CODE
   where bd.stop_process_date is null
    AND ps.Transfer_date IS NULL   
    <if>AND ps.vwh_id = :vwh_id</if>
    <if>AND ps.reporting_status=:reporting_status</if>  
     <if>and ps.customer_id =:customer_id</if>
     <if>AND ps.customer_dc_id = :customer_dc_id</if> 
      <if>AND ps.customer_store_id = :customer_store_id</if> 
    <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
   group by NVL(ps.warehouse_location_id,'Unknown'), ps.bucket_id,ps.vwh_id)
SELECT PSDATA.BUCKET_ID AS BUCKET_ID,
       PSDATA.NAME AS NAME,
       PSDATA.ORDERED_PIECES AS ORDERED_PIECES,
       ROUND(PSDATA.ORDERED_DOLLARS,0) AS ORDERED_DOLLARS,
       bp.CURRENT_PIECES AS PIECES_IN_BOXES,
       ROUND(bp.UNITS_SHIPPED) AS UNITS_SHIPPED,
       ROUND(bp.CURRENT_PIECES / PSDATA.ORDERED_PIECES, 2) AS PERCENT_COMPLETE,
       PSDATA.NO_OF_PICKSLIPS       AS NO_OF_PICKSLIPS,
       PSDATA.TOTAL_SKU_ORDERED     AS NO_OF_SKU,
       PSDATA.NO_OF_POS             AS NO_OF_POS,
       PSDATA.warehouse_location_id AS warehouse_location_id,
       PSDATA.vwh_id                AS vwh_id
  FROM ordered_stats psdata
  left outer join box_stats bp
    on bp.bucket_id = psdata.bucket_id
   AND bp.warehouse_location_id = psdata.warehouse_location_id
   and bp.vwh_id = psdata.vwh_id
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="ucFilters$ddlStatus" Type="String" Direction="Input"
                Name="reporting_status" />
            <asp:ControlParameter ControlID="ucFilters$ctlVwh_id" Type="String" Direction="Input"
                Name="vwh_id" />
            <asp:ControlParameter ControlID="ucFilters$tbcustomer" Type="String" Direction="Input"
                Name="customer_id" />

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

            <asp:ControlParameter ControlID="ucFilters$cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ucFilters$ddlvas" Type="String" Direction="Input" Name="vas_id" />

        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"     
        ShowFooter="true" ShowHeader="true" AllowSorting="true" DefaultSortExpression="warehouse_location_id;$;ORDERED_DOLLARS {0:I}" >
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id" HeaderToolTip="Virtual warehouse of the order." /> 
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building" SortExpression="warehouse_location_id" HeaderToolTip="Building of the Orders" /> 
            <eclipse:MultiBoundField DataFields="BUCKET_ID,NAME" HeaderText="Bucket" SortExpression="BUCKET_ID"
                 DataFormatString="{0} : {1}"  HeaderToolTip="ID and description of the bucket"/>
            <eclipse:MultiBoundField DataFields="ORDERED_PIECES" HeaderText="Ordered|Pieces" HeaderToolTip="Pieces of the Orders"
                SortExpression="ORDERED_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ORDERED_DOLLARS" HeaderText="Ordered|Dollars" HeaderToolTip="Total dollars "
                SortExpression="ORDERED_DOLLARS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:C0}"
                DataFooterFormatString="{0:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_IN_BOXES" HeaderText="In Box|Pieces"
                SortExpression="PIECES_IN_BOXES" DataSummaryCalculation="ValueSummation" HeaderToolTip="Pieces Packed in the box">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="UNITS_SHIPPED" HeaderText="In Box|Units" SortExpression="UNITS_SHIPPED" DataSummaryCalculation="ValueSummation" HeaderToolTip="Unit Shipped Of the orders">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NO_OF_PICKSLIPS" HeaderText="Number Of|Pickslips"
                SortExpression="NO_OF_PICKSLIPS" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_POS" HeaderText="Number Of|POs"
                DataNavigateUrlFields="BUCKET_ID" DataNavigateUrlFormatString="R110_103.aspx?BUCKET_ID={0}"
                 AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_SKU" HeaderText="Number Of|SKUs"
                DataNavigateUrlFields="BUCKET_ID" DataNavigateUrlFormatString="R110_104.aspx?BUCKET_ID={0}"
                AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Title="Orders Drilldown Report (PO Wise)" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Register Src="R110_08.ascx" TagName="R110_08" TagPrefix="uc1" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7236 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_08/R110_103.aspx $
 *  $Id: R110_103.aspx 7236 2014-11-07 09:27:07Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    private bool _cancelQuery;
    protected override void OnLoad(EventArgs e)
    {

        //if (!IsPostBack)
        //{
        //    // Display the filters
        //    ucFilters.Tabs.Selected = 0;
        //}
        EclipseLibrary.Web.JQuery.Input.DropDownListEx2 ddlStatus = (EclipseLibrary.Web.JQuery.Input.DropDownListEx2)ucFilters.FindControl("ddlStatus");
        ddlStatus.Visible = true;
        ddlStatus.FilterDisabled = false;
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbcustomer = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbcustomer");
        tbcustomer.Visible = true;
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbbucket = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbbucket");
        tbbucket.Visible = true;
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(ddlStatus.Value) && string.IsNullOrEmpty(tbbucket.Text))
        {
            _cancelQuery = true;
            lblCancelled.Visible = true;
        }
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbPiecesPerDay = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbPiecesPerDay");
        tbPiecesPerDay.FilterDisabled = true;
        base.OnLoad(e);

    }
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (_cancelQuery)
        {
            e.Cancel = true;
        }
    }
   
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays details of all SKUs in the specified PO." />
    <meta name="ReportId" content="110.103" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_103.aspx 7236 2014-11-07 09:27:07Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <uc1:R110_08 ID="ucFilters" runat="server" />
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" FilterContainerId="ucFilters" />
    <asp:Label runat="server" ID="lblCancelled" Text="Must specify at least one of Customer or Bucket"
        ForeColor="Red" Visible="false" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        OnSelecting="ds_Selecting" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
 WITH PSDATA AS
 (SELECT count(distinct PS.PICKSLIP_ID) AS PICKSLIP_ID,
         sum(pd.pieces_ordered)as PIECES_ORDERED,
         count(DISTINCT pd.upc_code) as TOTAL_SKU_ORDERED,
         max(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         max(PO.START_DATE) AS START_DATE,
         MAX(PS.PICKSLIP_IMPORT_DATE) AS IMPORT_DATE,
         sum(pd.pieces_ordered * pd.extended_price) as ORDERED_DOLLARS,
         PO.PO_ID AS PO_ID,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         ps.vwh_id as vwh_id,
         CASE WHEN COUNT(UNIQUE PS.SALES_ORDER_ID) > 1 THEN
            '*****'
            ELSE
         TO_CHAR(max(ps.SALES_ORDER_ID))
            END as STO
    FROM PS PS
     inner join psdet pd on
     ps.pickslip_id=pd.pickslip_id
    INNER JOIN PO PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION=PO.ITERATION
     WHERE PS.TRANSFER_DATE IS NULL
      AND PD.TRANSFER_DATE IS NULL
      and ps.pickslip_cancel_date IS NULL
      <if c="$vas">AND PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
          WHERE PV.VAS_ID IS NOT NULL
           <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if> 
          )</if>
      <if>AND ps.vwh_id = :vwh_id</if>    
      <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
      <if>AND ps.customer_id=:customer_id</if>
      <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
      <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>    
      <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
      <if>AND po.start_date &lt;= cast(:delivery_end_date as date)</if>
      <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
      <if>AND po.dc_cancel_date &lt;=cast(:dc_cancel_end_date as date)</if>
      <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
      <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
      <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
      <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
      <if>AND ps.bucket_id=:BUCKET_ID</if>
      <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
      <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
      group by PO.PO_ID, NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown'), ps.vwh_id
      
       
  UNION ALL
  
  SELECT count(distinct PS2.PICKSLIP_ID) AS PICKSLIP_ID,
         sum(PS2.QUANTITY_ORDERED) AS PIECES_ORDERED,
         COUNT(DISTINCT PS2.UPC_CODE) AS TOTAL_SKU_ORDERED,
         max(PS1.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         max(PS1.DELIVERY_DATE) AS START_DATE,
         MAX(PS1.PICKSLIP_IMPORT_DATE) AS IMPORT_DATE,
         sum(PS2.Extended_Price * ps2.QUANTITY_ORDERED) AS ORDERED_DOLLARS,
         PS1.CUSTOMER_ORDER_ID AS PO_ID,
         NVL(PS1.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         ps1.vwh_id as vwh_id,
         CASE WHEN COUNT(UNIQUE PS1.SALES_ORDER_ID) > 1 THEN
            '*****'
            ELSE
         TO_CHAR(max(ps1.SALES_ORDER_ID))
            END as STO
    FROM DEM_PICKSLIP PS1
   INNER JOIN DEM_PICKSLIP_DETAIL PS2
      ON PS1.PICKSLIP_ID = PS2.PICKSLIP_ID
       WHERE 1=1
       <if c="$vas">AND PS1.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
          WHERE PV.VAS_ID IS NOT NULL
           <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if> 
          )</if>
       <if>AND ps1.vwh_id = :vwh_id</if>    
       <if>AND <a pre="NVL(ps1.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
       <if>AND ps1.customer_id=:customer_id</if>
       <if c="$reporting_status='IN ORDER BUCKET'">AND PS1.PS_STATUS_ID = 1</if>
       <if c="$reporting_status!='IN ORDER BUCKET'">AND 1=2</if>
       <if>AND ps1.delivery_date &gt;= cast(:delivery_start_date as date)</if>
       <if>AND ps1.delivery_date &lt;= cast(:delivery_end_date as date)</if>
       <if>AND ps1.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
       <if>AND ps1.dc_cancel_date &lt;=cast(:dc_cancel_end_date as date)</if>
       <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps1.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
       <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps1.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
       <if c="$order_type='D'">AND ps1.Export_Flag IS NULL</if>
       <if c="$order_type='I'">AND ps1.Export_Flag IS NOT NULL</if>
       <if c="$BUCKET_ID">AND 1=2</if>
       <if>AND ps1.customer_dist_center_id = :customer_dc_id</if>
       <if>AND ps1.CUSTOMER_STORE_ID = :customer_store_id</if>
       group by ps1.CUSTOMER_ORDER_ID,NVL(PS1.WAREHOUSE_LOCATION_ID,'Unknown'), ps1.vwh_id
       ),

ALL_CUST AS
 (SELECT SUM(PSDATA.Pieces_Ordered) AS ORDERED_PIECES,
         SUM(PSDATA.TOTAL_SKU_ORDERED) AS TOTAL_SKU_ORDERED,
         SUM(PSDATA.ORDERED_DOLLARS) AS ORDERED_DOLLARS,
         PSDATA.PO_ID AS PO_ID,
         MAX(PSDATA.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(PSDATA.START_DATE) AS START_DATE,
         MAX(PSDATA.IMPORT_DATE) AS IMPORT_DATE,
         PSDATA.warehouse_location_id AS warehouse_location_id,
         psdata.vwh_id as vwh_id,
         max(psdata.STO) as STO,
         MAX(distinct PSDATA.PICKSLIP_ID) AS NO_OF_PICKSLIPS
    FROM PSDATA PSDATA
   GROUP BY PSDATA.warehouse_location_id, PSDATA.PO_ID,psdata.vwh_id),

BOX_PICKSLIPS AS
 (SELECT /*+ index(ps PS_P_TRANSFER_DATE_I) */
         PS.PO_ID AS PO_ID,
         PS.CUSTOMER_ID AS CUSTOMER_ID,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         ps.vwh_id as vwh_id,
         SUM(BD.CURRENT_PIECES / NVL(SKU.PIECES_PER_PACKAGE, 1)) AS UNITS_SHIPPED,
         SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) AS SHIPPED_DOLLARS,
         SUM(BD.CURRENT_PIECES) AS CURRENT_PIECES
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN PS PS
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
      <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">INNER JOIN po po ON po.customer_id = ps.customer_id and po.po_id = ps.po_id and po.iteration = ps.iteration</if>
   inner JOIN master_sku sku
      ON BD.UPC_CODE = SKU.UPC_CODE
   WHERE BD.STOP_PROCESS_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND PS.TRANSFER_DATE IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>
     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
     <if>AND ps.customer_id=:customer_id</if>
     <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
     <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if> 
     <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
     <if>AND po.start_date &lt;= cast(:delivery_end_date as date)</if>
     <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
     <if>AND po.dc_cancel_date &lt;=cast(:dc_cancel_end_date as date)</if>
     <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
     <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
     <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
     <if c="$BUCKET_ID">AND ps.bucket_id=:BUCKET_ID</if>
     <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
     <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
   GROUP BY PS.PO_ID, NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown'),PS.CUSTOMER_ID,ps.vwh_id)
SELECT AC.PO_ID AS PO_ID, 
       AC.DC_CANCEL_DATE           AS DC_CANCEL_DATE, 
       AC.START_DATE               AS START_DATE, 
       AC.IMPORT_DATE              AS IMPORT_DATE,
       AC.ORDERED_PIECES           AS ORDERED_PIECES, 
       AC.ORDERED_DOLLARS          AS ORDERED_DOLLARS, 
       BP.CURRENT_PIECES           AS PIECES_IN_BOXES,
       BP.SHIPPED_DOLLARS          AS SHIPPED_DOLLARS,
       BP.UNITS_SHIPPED            AS UNITS_SHIPPED, 
       AC.NO_OF_PICKSLIPS          AS NO_OF_PICKSLIPS,
       AC.TOTAL_SKU_ORDERED        AS NO_OF_SKU, 
       AC.WAREHOUSE_LOCATION_ID    AS WAREHOUSE_LOCATION_ID,
       AC.Vwh_id                   AS vwh_id,
       AC.STO                      AS STO
  FROM ALL_CUST AC
  LEFT OUTER JOIN BOX_PICKSLIPS BP
    ON AC.PO_ID = BP.PO_ID  
    AND AC.WAREHOUSE_LOCATION_ID = BP.WAREHOUSE_LOCATION_ID
    and ac.vwh_id = bp.vwh_id


<%--WITH Q1 AS
 (SELECT PS.PICKSLIP_ID,
         PD.UPC_CODE,
         PD.PIECES_ORDERED,
         PD.EXTENDED_PRICE,
         PO.DC_CANCEL_DATE,
         PO.START_DATE,
         PS.PICKSLIP_IMPORT_DATE,
         PO.PO_ID AS PO_ID,
         NVL(PS.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
         PS.VWH_ID AS VWH_ID
    FROM PS
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
   INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
      <if>AND ps.vwh_id = :vwh_id</if>
      <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
      <if>AND ps.customer_id=:customer_id</if>
      <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
      <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>    
      <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
      <if>AND po.start_date &lt;cast(:delivery_end_date as date) + 1</if>
      <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
      <if>AND po.dc_cancel_date &lt;cast(:dc_cancel_end_date as date) + 1</if>
      <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
      <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
      <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
      <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
      <if>AND ps.bucket_id=:BUCKET_ID</if>
      <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
      <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
  UNION ALL
  SELECT DP.PICKSLIP_ID,
         DPD.UPC_CODE,
         DPD.QUANTITY_ORDERED     AS PIECES_ORDERED,
         DPD.EXTENDED_PRICE,
         DP.DC_CANCEL_DATE,
         DP.DELIVERY_DATE,
         DP.PICKSLIP_IMPORT_DATE,
         DP.CUSTOMER_ORDER_ID     AS PO_ID,
         DP.WAREHOUSE_LOCATION_ID,
         DP.VWH_ID
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DP.PICKSLIP_ID = DPD.PICKSLIP_ID
     WHERE 1=1
       <if>AND DP.vwh_id = :vwh_id</if>    
       <if>AND <a pre="NVL(DP.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
       <if>AND DP.customer_id=:customer_id</if>
       <if c="$reporting_status='IN ORDER BUCKET'">AND DP.PS_STATUS_ID = 1</if>
       <if c="$reporting_status!='IN ORDER BUCKET'">AND 1=2</if>
       <if>AND DP.delivery_date &gt;= cast(:delivery_start_date as date)</if>
       <if>AND DP.delivery_date &lt; cast(:delivery_end_date as date)+1</if>
       <if>AND DP.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
       <if>AND DP.dc_cancel_date &lt;cast(:dc_cancel_end_date as date)+1</if>
       <if c="$order_type='D' and contains($restrict_type, 'R')">AND DP.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
       <if c="$order_type='D' and contains($restrict_type, 'I')">AND DP.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
       <if c="$order_type='D'">AND DP.Export_Flag IS NULL</if>
       <if c="$order_type='I'">AND DP.Export_Flag IS NOT NULL</if>
       <if c="$BUCKET_ID">AND 1=2</if>
       <if>AND DP.customer_dist_center_id = :customer_dc_id</if>
       <if>AND DP.CUSTOMER_STORE_ID = :customer_store_id</if>),
Q2 AS
 (SELECT ROW_NUMBER() OVER(PARTITION BY Q1.PICKSLIP_ID, Q1.UPC_CODE ORDER BY Q1.PICKSLIP_ID, Q1.UPC_CODE) AS PICKSLIP_SEQUENCE,
         Q1.PICKSLIP_ID,
         Q1.UPC_CODE,
         Q1.PIECES_ORDERED,
         Q1.EXTENDED_PRICE,
         Q1.DC_CANCEL_DATE,
         Q1.START_DATE,
         Q1.PICKSLIP_IMPORT_DATE,
         Q1.PO_ID,
         Q1.WAREHOUSE_LOCATION_ID,
         Q1.VWH_ID
    FROM Q1
    <if c="$vas">LEFT OUTER JOIN PS_VAS PV
      ON Q1.PICKSLIP_ID = PV.PICKSLIP_ID</if>
            WHERE 1=1
            <if c="$vas"> 
              AND pv.vas_id is not null        
            <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
            </if>),
ALL_PSDATA AS
 (SELECT COUNT(UNIQUE Q1.PICKSLIP_ID) AS NO_OF_PICKSLIPS,
         COUNT(UNIQUE Q1.UPC_CODE) AS TOTAL_SKU_ORDERED,
         SUM(Q1.PIECES_ORDERED) AS ORDERED_PIECES,
         SUM(Q1.PIECES_ORDERED * Q1.EXTENDED_PRICE) AS ORDERED_DOLLARS,
         MAX(Q1.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(Q1.START_DATE) AS START_DATE,
         MAX(Q1.PICKSLIP_IMPORT_DATE) AS IMPORT_DATE,
         Q1.PO_ID,
         Q1.WAREHOUSE_LOCATION_ID,
         Q1.VWH_ID
    FROM Q2 Q1
   WHERE PICKSLIP_SEQUENCE = 1
   GROUP BY Q1.PO_ID, Q1.WAREHOUSE_LOCATION_ID, Q1.VWH_ID),
BOX_PICKSLIPS AS
 (SELECT /*+ index(ps PS_P_TRANSFER_DATE_I) */
   PS.PO_ID AS PO_ID,
   PS.CUSTOMER_ID AS CUSTOMER_ID,
   NVL(PS.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
   PS.VWH_ID AS VWH_ID,
   SUM(BD.CURRENT_PIECES / NVL(SKU.PIECES_PER_PACKAGE, 1)) AS UNITS_SHIPPED,
   SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) AS SHIPPED_DOLLARS,
   SUM(BD.CURRENT_PIECES) AS CURRENT_PIECES
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN PS PS
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
    <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">INNER JOIN po po ON po.customer_id = ps.customer_id and po.po_id = ps.po_id and po.iteration = ps.iteration</if>
   INNER JOIN MASTER_SKU SKU
      ON BD.UPC_CODE = SKU.UPC_CODE
   WHERE BD.STOP_PROCESS_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND PS.TRANSFER_DATE IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>
      <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
      <if>AND ps.customer_id=:customer_id</if>
      <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
      <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>    
      <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>
      <if>AND po.start_date &lt; cast(:delivery_end_date as date)+1</if>
      <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
      <if>AND po.dc_cancel_date &lt;cast(:dc_cancel_end_date as date)+1</if>
      <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
      <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
      <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
      <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
      <if>AND ps.bucket_id=:BUCKET_ID</if>
      <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
      <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
   GROUP BY PS.PO_ID,
            NVL(PS.WAREHOUSE_LOCATION_ID, 'Unknown'),
            PS.CUSTOMER_ID,
            PS.VWH_ID)
SELECT AC.PO_ID                 AS PO_ID,
       AC.DC_CANCEL_DATE        AS DC_CANCEL_DATE,
       AC.START_DATE            AS START_DATE,
       AC.IMPORT_DATE           AS IMPORT_DATE,
       AC.ORDERED_PIECES        AS ORDERED_PIECES,
       AC.ORDERED_DOLLARS       AS ORDERED_DOLLARS,
       BP.CURRENT_PIECES        AS PIECES_IN_BOXES,
       BP.SHIPPED_DOLLARS       AS SHIPPED_DOLLARS,
       BP.UNITS_SHIPPED         AS UNITS_SHIPPED,
       AC.NO_OF_PICKSLIPS       AS NO_OF_PICKSLIPS,
       AC.TOTAL_SKU_ORDERED     AS NO_OF_SKU,
       AC.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       AC.VWH_ID                AS VWH_ID
  FROM ALL_PSDATA AC
  LEFT OUTER JOIN BOX_PICKSLIPS BP
    ON AC.PO_ID = BP.PO_ID
   AND AC.WAREHOUSE_LOCATION_ID = BP.WAREHOUSE_LOCATION_ID
   AND AC.VWH_ID = BP.VWH_ID --%>




        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ucFilters$ctlVwh_id" Type="String" Direction="Input"
                Name="vwh_id" />
            <asp:ControlParameter ControlID="ucFilters$ctlWhloc" Type="String" Direction="Input"
                Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="ucFilters$ddlStatus" Type="String" Direction="Input"
                Name="reporting_status" />
            <asp:ControlParameter ControlID="ucFilters$tbFromDeliveryDate" Type="DateTime" Direction="Input"
                Name="delivery_start_date" />
            <asp:ControlParameter ControlID="ucFilters$tbToDeliveryDate" Type="DateTime" Direction="Input"
                Name="delivery_end_date" />
            <asp:ControlParameter ControlID="ucFilters$tbFromDcCancelDate" Type="DateTime" Direction="Input"
                Name="dc_cancel_start_date" />
            <asp:ControlParameter ControlID="ucFilters$tbToDcCancelDate" Type="DateTime" Direction="Input"
                Name="dc_cancel_end_date" />
            <asp:ControlParameter ControlID="ucFilters$rblOrderType" Type="String" Direction="Input"
                Name="order_type" />
            <asp:ControlParameter ControlID="ucFilters$cblExclude" Type="String" Direction="Input"
                Name="restrict_type" />
            <asp:ControlParameter ControlID="ucFilters$tbcustomer" Type="String" Direction="Input"
                Name="customer_id" />
            <asp:ControlParameter ControlID="ucFilters$tbbucket" Type="String" Direction="Input"
                Name="BUCKET_ID" />
            <asp:ControlParameter ControlID="ucFilters$tbdc" Type="String" Name="customer_dc_id" Direction="Input" />
            <asp:ControlParameter ControlID="ucFilters$tbstore" Type="String" Name="customer_store_id" Direction="Input" />
            <asp:ControlParameter ControlID="ucFilters$cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ucFilters$ddlvas" Type="String" Direction="Input" Name="vas_id" />

        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        ShowFooter="true" AllowPaging="true" PageSize="200" ShowHeader="true" AllowSorting="true"
        DefaultSortExpression="WAREHOUSE_LOCATION_ID;$;ORDERED_DOLLARS {0:I}">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id" HeaderToolTip="Virtual warehouse of the order" />
            <eclipse:MultiBoundField DataFields="Po_Id" HeaderText="PO" SortExpression="Po_Id"
                HeaderToolTip="Order Id of the customer" />
            <eclipse:MultiBoundField DataFields="STO" HeaderText="PO Attrib 1" HeaderStyle-Wrap="false" HeaderToolTip="PO's attribute# 1" SortExpression="STO" />
            <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" HeaderText="Date|DC Cancel " HeaderToolTip="Cancel date of the order"
                SortExpression="Dc_Cancel_Date" DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="START_DATE" HeaderText="Date|Start" SortExpression="Start_Date" HeaderToolTip="The expected delivery date of the order."
                DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="IMPORT_DATE" HeaderText="Date|Import" SortExpression="IMPORT_DATE" HeaderToolTip="The date on which pickslip was imported to DCMS."
                DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="ORDERED_PIECES" HeaderText="Ordered|Pieces" HeaderToolTip="Total pieces of the order"
                SortExpression="Ordered_Pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ORDERED_DOLLARS" HeaderText="Ordered|Dollars" HeaderToolTip="Total amount of the order"
                SortExpression="ORDERED_DOLLARS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:C2}"
                DataFooterFormatString="{0:C2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_IN_BOXES" HeaderText="In Box|Pieces"
                SortExpression="PIECES_IN_BOXES" HeaderToolTip="Pieces packed in the box" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHIPPED_DOLLARS" HeaderText="In Box|Dollars" HeaderToolTip="Total dollars of the order which are about to ship"
                SortExpression="SHIPPED_DOLLARS" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:C2}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C2}"
                FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="UNITS_SHIPPED" HeaderText="In Box|Units" SortExpression="Units_Shipped"
                HeaderToolTip="UNITS SHIPPED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NO_OF_PICKSLIPS" HeaderText="No Of|Pickslips"
                SortExpression="NO_OF_PICKSLIPS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_SKU" HeaderText="No Of|SKU" DataNavigateUrlFields="po_id,vwh_id"
                DataNavigateUrlFormatString="R110_104.aspx?po_id={0}&vwh_id={1}" AppliedFiltersControlID="ButtonBar1$af"
                DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

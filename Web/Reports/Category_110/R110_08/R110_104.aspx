<%@ Page Title="Open Orders Drilldown Report (SKU Wise) " Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Register Src="R110_08.ascx" TagName="R110_08" TagPrefix="uc1" %>
<%@ Import Namespace="EclipseLibrary.Web.JQuery.Input" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6605 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_08/R110_104.aspx $
 *  $Id: R110_104.aspx 6605 2014-03-31 11:04:49Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    
    private bool _cancelQuery;

    protected override void OnLoad(EventArgs e)
    {
        DropDownListEx2 ddlStatus = (DropDownListEx2)ucFilters.FindControl("ddlStatus");
        ddlStatus.Visible = true;
        ddlStatus.FilterDisabled = false;
        TextBoxEx tbcustomer = (TextBoxEx)ucFilters.FindControl("tbcustomer");
        tbcustomer.Visible = true;
        TextBoxEx tbbucket = (TextBoxEx)ucFilters.FindControl("tbbucket");
        tbbucket.Visible = true;
        TextBoxEx tbpo = (TextBoxEx)ucFilters.FindControl("tbpo");
        tbpo.Visible = true;
        TextBoxEx tbpickslip = (TextBoxEx)ucFilters.FindControl("tbpickslip");
        tbpickslip.Visible = true;
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbiteration = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbiteration");
        tbiteration.Visible = true;

        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbbucket.Text) && string.IsNullOrEmpty(tbpo.Text))
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
    <meta name="Description" content="This Report displays details of all SKUs for a given value of Customer,Bucket,PO or Iteration" />
    <meta name="ReportId" content="110.104" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_104.aspx 6605 2014-03-31 11:04:49Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <uc1:R110_08 ID="ucFilters" runat="server" />
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" FilterContainerId="ucFilters" />
    <asp:Label runat="server" ID="lblCancelled" Text="Must specify at least one of Customer, Bucket or PO"
        ForeColor="Red" Visible="false" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting"
        CancelSelectOnNullParameter="true">
        <SelectSql>


WITH PSDATA AS
 (SELECT PD.PICKSLIP_ID AS PICKSLIP_ID,
         PD.UPC_CODE AS UPC_CODE,
         SKU.STYLE AS STYLE,
         SKU.COLOR AS COLOR,
         SKU.DIMENSION AS DIMENSION,
         SKU.SKU_SIZE AS SKU_SIZE,
         PD.EXTENDED_PRICE AS EXTENDED_PRICE,
         PD.PIECES_ORDERED AS PIECES_ORDERED,
         PD.PIECES_ORDERED * PD.EXTENDED_PRICE AS DOLLARS_ORDERED,
         PS.VWH_ID AS VWH_ID,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID
    FROM PS PS
    <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">INNER JOIN po po ON po.customer_id = ps.customer_id and po.po_id = ps.po_id and po.iteration = ps.iteration</if>
      INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
      LEFT OUTER JOIN MASTER_SKU SKU
      ON PD.UPC_CODE = SKU.UPC_CODE
     <%--LEFT OUTER JOIN PS_VAS PV ON 
     PS.PICKSLIP_ID = PV.PICKSLIP_ID--%>
     WHERE PS.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
     and ps.pickslip_cancel_date IS NULL
     <if c="$vas">AND PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
                  WHERE PV.VAS_ID IS NOT NULL
     <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if> 
          )</if>
     <if>AND ps.vwh_id = :vwh_id</if>    
     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
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
     <if>AND ps.customer_id=:customer_id</if>
            <if>AND ps.pickslip_id =:pickslip_id</if>  
     <if>AND ps.po_id=:po_id</if>
     <if>AND ps.bucket_id=:BUCKET_ID</if>
     <if>AND ps.iteration=:iteration</if>
     <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
     <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
     <%--<if c="$vas"> 
              AND pv.vas_id is not null        
            <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
            </if>--%>
   
  UNION ALL
  SELECT DPD.PICKSLIP_ID AS PICKSLIP_ID,
         DPD.UPC_CODE AS UPC_CODE,
         DPD.STYLE AS STYLE,
         DPD.COLOR AS COLOR,
         DPD.DIMENSION AS DIMENSION,
         DPD.SKU_SIZE AS SKU_SIZE,
         DPD.EXTENDED_PRICE AS EXTENDED_PRICE ,
         DPD.QUANTITY_ORDERED AS QUANTITY_ORDERED,
         DPD.QUANTITY_ORDERED * DPD.EXTENDED_PRICE AS DOLLARS_ORDERED ,
         PS1.VWH_ID AS VWH_ID,
         NVL(PS1.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID
      FROM DEM_PICKSLIP PS1
      INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON PS1.PICKSLIP_ID = DPD.PICKSLIP_ID  
    <%--  LEFT OUTER JOIN PS_VAS PV ON 
      PS1.PICKSLIP_ID = PV.PICKSLIP_ID --%> 
      WHERE 1=1
      <if c="$vas">AND PS1.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
          WHERE PV.VAS_ID IS NOT NULL
      <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if> 
          )</if>
      <if>AND ps1.vwh_id = :vwh_id</if>
      <%--<if>AND ps1.warehouse_location_id = :warehouse_location_id</if>--%>
      <if>AND <a pre="NVL(ps1.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
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
            <if>AND ps1.pickslip_id =:pickslip_id</if>       
      <if>AND ps1.customer_id=:customer_id</if>
      <if>AND ps1.customer_order_id=:po_id</if>
      <if>AND ps1.customer_dist_center_id = :customer_dc_id</if>
      <if>AND ps1.CUSTOMER_STORE_ID = :customer_store_id</if>
      <if c="$BUCKET_ID">AND 1=2</if>   
     <%-- <if c="$vas"> 
              AND pv.vas_id is not null        
            <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
            </if> --%>                  
    ),
BOX_PICKSLIPS AS
 (SELECT BD.PICKSLIP_ID AS PICKSLIP_ID ,
         BD.UPC_CODE,
         SUM(BD.CURRENT_PIECES / NVL(SKU.PIECES_PER_PACKAGE, 1)) AS UNITS_SHIPPED,
         SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) AS SHIPPED_DOLLARS,
         SUM(BD.CURRENT_PIECES) AS CURRENT_PIECES
   FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
  <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">
   INNER JOIN PO PO
      ON PO.CUSTOMER_ID = PS.CUSTOMER_ID
     AND PO.PO_ID = PS.PO_ID
     AND PO.ITERATION = PS.ITERATION</if>
    LEFT OUTER JOIN MASTER_SKU SKU
      ON BD.UPC_CODE = SKU.UPC_CODE
   WHERE BD.STOP_PROCESS_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND PS.TRANSFER_DATE IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>    
    <%-- <if>AND ps.warehouse_location_id = :warehouse_location_id</if>--%>
     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
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
     <if>AND ps.customer_id=:customer_id</if>
     <if>AND ps.po_id=:po_id</if>
     <if>AND ps.pickslip_id =:pickslip_id</if>
     <if>AND ps.bucket_id=:BUCKET_ID</if>
     <if>AND ps.iteration=:iteration</if>
     <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
     <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
     AND BD.CURRENT_PIECES &gt; 0
   GROUP BY BD.UPC_CODE,BD.PICKSLIP_ID)
SELECT PSDATA.UPC_CODE AS UPC_CODE,
       MAX(PSDATA.STYLE) AS STYLE,
       MAX(PSDATA.COLOR) AS COLOR,
       MAX(PSDATA.DIMENSION) AS DIMENSION,
       MAX(PSDATA.SKU_SIZE) AS SKU_SIZE,
       MAX(PSDATA.EXTENDED_PRICE) AS PRICE,
       SUM(PSDATA.PIECES_ORDERED)AS PIECES_ORDERED,
       SUM(PSDATA.DOLLARS_ORDERED)AS DOLLARS_ORDERED,
       SUM(BP.CURRENT_PIECES) AS PIECES_IN_BOXES,
       ROUND(SUM(BP.UNITS_SHIPPED)) AS UNITS_SHIPPED,
       sum(BP.SHIPPED_DOLLARS) AS SHIPPED_DOLLARS,
       PSDATA.VWH_ID AS VWH_ID,
       PSDATA.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID
  FROM PSDATA PSDATA
  LEFT OUTER JOIN BOX_PICKSLIPS BP
    ON BP.UPC_CODE = PSDATA.UPC_CODE
    AND BP.PICKSLIP_ID = PSDATA.PICKSLIP_ID 
   GROUP BY PSDATA.UPC_CODE, PSDATA.VWH_ID, PSDATA.WAREHOUSE_LOCATION_ID


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
     <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
     <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>    
     <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>  
     <if>AND po.start_date &lt; cast(:delivery_end_date as date) + 1</if>
     <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
     <if>AND po.dc_cancel_date &lt; cast(:dc_cancel_end_date as date) + 1</if>
     <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
     <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
     <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
     <if>AND ps.customer_id=:customer_id</if>
     <if>AND ps.po_id=:po_id</if>
     <if>AND ps.bucket_id=:BUCKET_ID</if>
     <if>AND ps.iteration=:iteration</if>
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
      <if c="$reporting_status='IN ORDER BUCKET'">AND DP.PS_STATUS_ID = 1</if>
      <if c="$reporting_status!='IN ORDER BUCKET'">AND 1=2</if>
      <if>AND DP.delivery_date &gt;= cast(:delivery_start_date as date)</if>
      <if>AND DP.delivery_date &lt; cast(:delivery_end_date as date) + 1</if>
      <if>AND DP.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
      <if>AND DP.dc_cancel_date &lt; cast(:dc_cancel_end_date as date) + 1</if>
      <if c="$order_type='D' and contains($restrict_type, 'R')">AND DP.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
      <if c="$order_type='D' and contains($restrict_type, 'I')">AND DP.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
      <if c="$order_type='D'">AND DP.Export_Flag IS NULL</if>
      <if c="$order_type='I'">AND DP.Export_Flag IS NOT NULL</if>
      <if>AND DP.customer_id=:customer_id</if>
      <if>AND DP.customer_order_id=:po_id</if>
      <if>AND DP.customer_dist_center_id = :customer_dc_id</if>
      <if>AND DP.CUSTOMER_STORE_ID = :customer_store_id</if>
      <if c="$BUCKET_ID">AND 1=2</if> ),
Q2 AS
 (SELECT ROW_NUMBER() OVER(PARTITION BY Q1.PICKSLIP_ID, Q1.UPC_CODE ORDER BY Q1.PICKSLIP_ID, Q1.UPC_CODE) AS PICKSLIP_SEQUENCE,
         Q1.PICKSLIP_ID,
         Q1.UPC_CODE,
         MS.STYLE,
         MS.COLOR,
         MS.DIMENSION,
         MS.SKU_SIZE,
         Q1.PIECES_ORDERED,
         Q1.EXTENDED_PRICE,
         Q1.DC_CANCEL_DATE,
         Q1.START_DATE,
         Q1.PICKSLIP_IMPORT_DATE,
         Q1.PO_ID,
         Q1.WAREHOUSE_LOCATION_ID,
         Q1.VWH_ID
    FROM Q1
    LEFT OUTER JOIN PS_VAS PV
      ON Q1.PICKSLIP_ID = PV.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_SKU MS
      ON Q1.UPC_CODE = MS.UPC_CODE),
ALL_PSDATA AS
 (SELECT Q1.PICKSLIP_ID,
         Q1.UPC_CODE,
         MAX(Q1.STYLE) AS STYLE,
         MAX(Q1.COLOR) AS COLOR,
         MAX(Q1.DIMENSION) AS DIMENSION,
         MAX(Q1.SKU_SIZE) AS SKU_SIZE,
         SUM(Q1.PIECES_ORDERED) AS PIECES_ORDERED,
         SUM(Q1.PIECES_ORDERED * Q1.EXTENDED_PRICE) AS DOLLARS_ORDERED,
         SUM(Q1.EXTENDED_PRICE) AS EXTENDED_PRICE,
         MAX(Q1.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(Q1.START_DATE) AS DELIVERY_DATE,
         MAX(Q1.PICKSLIP_IMPORT_DATE) AS IMPORT_DATE,
         MAX(Q1.PO_ID) AS PO_ID,
         MAX(Q1.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID,
         MAX(Q1.VWH_ID) AS VWH_ID
    FROM Q2 Q1
   WHERE PICKSLIP_SEQUENCE = 1
   GROUP BY Q1.PICKSLIP_ID, Q1.UPC_CODE),
BOX_PICKSLIPS AS
 (SELECT BD.PICKSLIP_ID AS PICKSLIP_ID,
         BD.UPC_CODE,
         SUM(BD.CURRENT_PIECES / NVL(SKU.PIECES_PER_PACKAGE, 1)) AS UNITS_SHIPPED,
         SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) AS SHIPPED_DOLLARS,
         SUM(BD.CURRENT_PIECES) AS CURRENT_PIECES
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN MASTER_SKU SKU
      ON BD.UPC_CODE = SKU.UPC_CODE
   WHERE BD.STOP_PROCESS_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND PS.TRANSFER_DATE IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>    
     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
     <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
     <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>    
     <if>AND po.start_date &gt;= cast(:delivery_start_date as date)</if>  
     <if>AND po.start_date &lt; cast(:delivery_end_date as date) + 1</if>
     <if>AND po.dc_cancel_date &gt;=cast(:dc_cancel_start_date as date)</if>
     <if>AND po.dc_cancel_date &lt; cast(:dc_cancel_end_date as date) + 1</if>
     <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
     <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
     <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>
     <if>AND ps.customer_id=:customer_id</if>
     <if>AND ps.po_id=:po_id</if>
     <if>AND ps.bucket_id=:BUCKET_ID</if>
     <if>AND ps.iteration=:iteration</if>
     <if>AND PS.CUSTOMER_DC_ID = :customer_dc_id</if>
     <if>AND ps.CUSTOMER_STORE_ID = :customer_store_id</if>
     AND BD.CURRENT_PIECES > 0
   GROUP BY BD.UPC_CODE, BD.PICKSLIP_ID)
SELECT PSDATA.UPC_CODE AS UPC_CODE,
       MAX(PSDATA.STYLE) AS STYLE,
       MAX(PSDATA.COLOR) AS COLOR,
       MAX(PSDATA.DIMENSION) AS DIMENSION,
       MAX(PSDATA.SKU_SIZE) AS SKU_SIZE,
       MAX(PSDATA.EXTENDED_PRICE) AS PRICE,
       SUM(PSDATA.PIECES_ORDERED) AS PIECES_ORDERED,
       SUM(PSDATA.DOLLARS_ORDERED) AS DOLLARS_ORDERED,
       SUM(BP.CURRENT_PIECES) AS PIECES_IN_BOXES,
       ROUND(SUM(BP.UNITS_SHIPPED)) AS UNITS_SHIPPED,
       SUM(BP.SHIPPED_DOLLARS) AS SHIPPED_DOLLARS,
       PSDATA.VWH_ID AS VWH_ID,
       PSDATA.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID
  FROM ALL_PSDATA PSDATA
  LEFT OUTER JOIN BOX_PICKSLIPS BP
    ON BP.UPC_CODE = PSDATA.UPC_CODE
   AND BP.PICKSLIP_ID = PSDATA.PICKSLIP_ID
 GROUP BY PSDATA.UPC_CODE, PSDATA.VWH_ID, PSDATA.WAREHOUSE_LOCATION_ID--%>
 
            
            
                      
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ucFilters$ddlStatus" Type="String" Direction="Input"
                Name="reporting_status" />
            <asp:ControlParameter ControlID="ucFilters$ctlVwh_id" Type="String" Direction="Input"
                Name="vwh_id" />
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
            <asp:ControlParameter ControlID="ucFilters$tbbucket" Type="String" Direction="Input"
                Name="BUCKET_ID" />
            <asp:ControlParameter ControlID="ucFilters$tbpo" Type="String" Direction="Input"
                Name="po_id" />
            <asp:ControlParameter ControlID="ucFilters$tbiteration" Type="String" Direction="Input"
                Name="iteration" />
            <asp:ControlParameter ControlID="ucFilters$tbpickslip" Type="Int64" Direction="Input"
                Name="pickslip_id" />
                <asp:ControlParameter ControlID="ucFilters$tbdc" Type="String" Name="customer_dc_id"  Direction="Input"/>
            <asp:ControlParameter ControlID="ucFilters$tbstore" Type="String" Name="customer_store_id"  Direction="Input" />
        
            <asp:ControlParameter ControlID="ucFilters$cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ucFilters$ddlvas" Type="String" Direction="Input" Name="vas_id" />
        
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        ShowFooter="true" ShowHeader="true" AllowSorting="true" DefaultSortExpression="WAREHOUSE_LOCATION_ID;$;DOLLARS_ORDERED {0:I}">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"  HeaderToolTip="Virtaul Warehouse of the SKU"/>
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building" HeaderToolTip="Building of the SKU"
                SortExpression="WAREHOUSE_LOCATION_ID" />
            <eclipse:MultiBoundField DataFields="UPC_CODE" HeaderText="UPC" SortExpression="UPC_CODE"  HeaderToolTip="UPC of the SKU"/>
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="Style" HeaderToolTip="Style of the SKU"
                />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" HeaderToolTip="Color of the SKU"/>
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim" SortExpression="DIMENSION" HeaderToolTip="Dimension of the SKU"/>
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE" HeaderToolTip="Size of the SKU">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PRICE" HeaderText="Price" SortExpression="PRICE" HeaderToolTip="Price of the SKU/unit"
                DataFormatString="{0:C2}" DataFooterFormatString="{0:C2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_ORDERED" HeaderText="Ordered|Pieces" HeaderToolTip="Total Pieces of the SKU"
                SortExpression="PIECES_ORDERED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="DOLLARS_ORDERED" HeaderText="Ordered|Dollars" HeaderToolTip="Total Dollars of the SKU"
                SortExpression="DOLLARS_ORDERED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:C2}"
                DataFooterFormatString="{0:C2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_IN_BOXES" HeaderText="In Box|Pieces" HeaderToolTip="Total No. of SKU pieces in the box"
                SortExpression="PIECES_IN_BOXES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHIPPED_DOLLARS" HeaderText="In Box|Dollars" HeaderToolTip="Total Shipped Dollars of the SKU."
                SortExpression="SHIPPED_DOLLARS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:C2}"
                DataFooterFormatString="{0:C2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="UNITS_SHIPPED" HeaderText="In Box|Units" SortExpression="UNITS_SHIPPED"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

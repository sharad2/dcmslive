<%@ Page Title="Order Drill Down Report" Language="C#" MasterPageFile="~/MasterPage.master"
    EnableViewState="true" %>

<%@ Import Namespace="System.Linq" %>
<%@ Register Src="R110_08.ascx" TagName="R110_08" TagPrefix="uc1" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6554 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_08/R110_08.aspx $
 *  $Id: R110_08.aspx 6554 2014-03-26 05:43:08Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        if (!IsPostBack)
        {
            // Display the filters
            ucFilters.Tabs.Selected = 0;
        }
        EclipseLibrary.Web.JQuery.Input.TextBoxEx tbPiecesPerDay = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbPiecesPerDay");
        tbPiecesPerDay.Visible = true;
        tbPiecesPerDay.FilterDisabled = false;      
        base.OnLoad(e);
    }
    
   
    /// <summary>
    /// Calculating Process days.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
         

        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                //DataControlField dcfProcessDays = (from DataControlField dcf in gv.Columns.OfType<MultiBoundField>()
                //                                   where dcf.AccessibleHeaderText.Equals("process_days")
                //                                   select dcf).Single();
                var index = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "process_days" ? i : -1)
                    .Single(p => p >= 0);
                object objPcs = DataBinder.Eval(e.Row.DataItem, "PIECES_IN_BOXES");
                double dPcsInBox = objPcs != DBNull.Value ? Convert.ToDouble(objPcs) : 0;

                objPcs = DataBinder.Eval(e.Row.DataItem, "ORDERED_PIECES");
                double dPcsOrdered = objPcs != DBNull.Value ? Convert.ToDouble(objPcs) : 0;

                EclipseLibrary.Web.JQuery.Input.TextBoxEx tbPiecesPerDay = (EclipseLibrary.Web.JQuery.Input.TextBoxEx)ucFilters.FindControl("tbPiecesPerDay");  
                double dPcsPerDay = Convert.ToInt32(tbPiecesPerDay.Text);
                double dProcessDays = (dPcsOrdered - dPcsInBox) / dPcsPerDay;

                e.Row.Cells[index].Text = string.Format("{0:N4}", dProcessDays);
                e.Row.Cells[index].ToolTip = string.Format(
                    "(Ordered Pieces {0:N0} - Pieces in Box {1:N0}) / Pieces per day {2:N0}", dPcsOrdered, dPcsInBox, dPcsPerDay);
                break;

            default:
                break;
        }
        
      
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Displays summary of all open orders." />
    <meta name="ReportId" content="110.08" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Number of Pickslip column is now Click able. Check the list of pickslips which are involved here.|Number of PO column is now Click able. Check the list of POs which are involved here.|Following new filters are now avaliable in this report:- Customer , Customer Store and Customer DC" />
    <meta name="Version" content="$Id: R110_08.aspx 6554 2014-03-26 05:43:08Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <uc1:R110_08 ID="ucFilters" runat="server" />
   <%-- Pieces per day:--%>
   <%-- <i:TextBoxEx runat="server" ID="tbPiecesPerDay" ClientIDMode="Static"  FriendlyName="PiecesPerDay" Text="<%$ AppSettings:PiecesPerDay %>">
        <Validators> 
         
           <i:Required />
        </Validators>
    </i:TextBoxEx>--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" FilterContainerId="ucFilters" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true">
  <SelectSql>
  WITH open_pickslips AS
 (SELECT /*+ index (po  PO_PK)*/
         PS.PICKSLIP_ID AS PICKSLIP_ID,
         ps.reporting_status as reporting_status,
         TRS.SORT_SEQUENCE AS SORT_SEQUENCE,         
         PS.TOTAL_QUANTITY_ORDERED AS ORDERED_PIECES,        
         PS.TOTAL_DOLLARS_ORDERED AS ORDERED_DOLLARS,
         PS.BUCKET_ID AS BUCKET_ID,
         PS.CUSTOMER_ID AS CUSTOMER_ID,        
         PS.PO_ID              AS PO_ID,
         PS.VWH_ID             AS VWH_ID,
         NVL(PS.warehouse_location_id,'Unknown') AS warehouse_location_id
    FROM PS PS
    LEFT OUTER JOIN TAB_REPORTING_STATUS TRS ON TRS.REPORTING_STATUS = PS.Reporting_Status
    <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">INNER JOIN po po ON po.customer_id = ps.customer_id and po.po_id = ps.po_id and po.iteration = ps.iteration</if>
   WHERE ps.Transfer_date IS NULL
      and ps.pickslip_cancel_date IS NULL
     <if>AND ps.vwh_id = :vwh_id</if>
      <if>and ps.customer_id =:customer_id</if>
     <if>AND ps.customer_dc_id = :customer_dc_id</if> 
      <if>AND ps.customer_store_id = :customer_store_id</if>    
      <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>  
     <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
     <if>AND po.start_date &lt;= CAST(:delivery_end_date AS DATE)</if>       
     <if>AND po.dc_cancel_date &gt;=CAST(:dc_cancel_start_date AS DATE)</if>
     <if>AND po.dc_cancel_date &lt;=CAST(:dc_cancel_end_date AS DATE)</if> 
     <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>      
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>       
     <if c="$order_type='D'">AND ps.Export_Flag IS NULL</if>
     <if c="$order_type='I'">AND ps.Export_Flag IS NOT NULL</if>

  UNION ALL
  SELECT ps1.pickslip_id,
         'IN ORDER BUCKET' STATUS,
         1 SEQUENCE,        
         PS1.TOTAL_QUANTITY_ORDERED AS ORDERED_PIECES,
         PS1.TOTAL_DOLLARS_ORDERED AS ORDERED_DOLLARS,
         NULL as bucket_id,
         ps1.CUSTOMER_ID,
         PS1.CUSTOMER_ORDER_ID,
         PS1.VWH_ID AS VWH_ID,
         NVL(PS1.warehouse_location_id,'Unknown')
    FROM DEM_PICKSLIP PS1
   where ps1.ps_status_id = 1
   <if>AND ps1.vwh_id = :vwh_id</if>
   <if>AND PS1.customer_id =:customer_id</if>
   <if>AND PS1.customer_dist_center_id =:customer_dc_id</if>
   <if>AND PS1.Customer_Store_Id =:customer_store_id</if>
   <if>AND <a pre="NVL(ps1.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>      
   <if>AND ps1.delivery_date &gt;= CAST(:delivery_start_date AS DATE)</if>         
   <if>AND ps1.delivery_date &lt; CAST(:delivery_end_date AS DATE) + 1</if>         
   <if>AND ps1.dc_cancel_date &gt;=CAST(:dc_cancel_start_date AS DATE)</if>         
   <if>AND ps1.dc_cancel_date &lt;CAST(:dc_cancel_end_date AS DATE) + 1</if>
   <if c="$order_type='D' and contains($restrict_type, 'R')">AND ps1.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'RTL')</if>                  
   <if c="$order_type='D' and contains($restrict_type, 'I')">AND ps1.customer_id NOT IN (select c.customer_id from cust c WHERE account_type = 'IDC')</if>
   <if c="$order_type='D'">AND ps1.Export_Flag IS NULL</if>
   <if c="$order_type='I'">AND ps1.Export_Flag IS NOT NULL</if>
   ),
box_pickslips AS
 (select bd.pickslip_id,
         SUM(bd.current_pieces) AS current_pieces,
         SUM(bd.current_pieces *
              BD.extended_price) as current_dollars
    from box b
    INNER JOIN BOXDET BD ON 
      B.UCC128_ID = BD.UCC128_ID
      AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   where bd.stop_process_date is null
      AND B.STOP_PROCESS_DATE IS NULL
     and bd.current_pieces &gt; 0
   group by bd.pickslip_id)
SELECT PSDATA.reporting_status,
       MAX(PSDATA.SORT_SEQUENCE) AS SEQUENCE,       
       SUM(PSDATA.ORDERED_PIECES) AS ORDERED_PIECES,
       ROUND(SUM(PSDATA.ORDERED_DOLLARS),0) AS ORDERED_DOLLARS,
       SUM(bp.CURRENT_PIECES) AS PIECES_IN_BOXES,
       ROUND(SUM(bp.current_dollars),0) as Estimated_Dollar_Shipped,
       ROUND(SUM(bp.CURRENT_PIECES) / SUM(PSDATA.ORDERED_PIECES), 4) AS PERCENT_COMPLETE,
       COUNT(DISTINCT PSDATA.BUCKET_ID) AS NO_OF_BUCKETS,
       COUNT(DISTINCT PSDATA.CUSTOMER_ID) AS NO_OF_CUSTOMERS,
       COUNT(DISTINCT PSDATA.PICKSLIP_ID) AS NO_OF_PICKSLIPS,
       COUNT(DISTINCT
             RPAD(PSDATA.CUSTOMER_ID, 10) || RPAD(PSDATA.PO_ID, 25)) AS NO_OF_POS,
       PSDATA.VWH_ID AS VWH_ID,
       PSDATA.warehouse_location_id AS warehouse_location_id
  FROM open_pickslips psdata
  LEFT OUTER JOIN box_pickslips bp
    on bp.pickslip_id = psdata.pickslip_id
      <if c="$vas">WHERE PSDATA.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
          WHERE PV.VAS_ID IS NOT NULL
           <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if> 
          )</if>
 GROUP BY PSDATA.reporting_status,PSDATA.VWH_ID, PSDATA.warehouse_location_id
  </SelectSql> 
        <SelectParameters>
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
        ShowFooter="true" ShowHeader="true" AllowSorting="true" OnRowDataBound="gv_RowDataBound"
        DefaultSortExpression="warehouse_location_id;$;VWH_ID;SEQUENCE;ORDERED_DOLLARS {0:I}" ShowExpandCollapseButtons="false">
        <Columns>
            <eclipse:SequenceField />
           
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building" HeaderToolTip="Building of the orders"
                SortExpression="warehouse_location_id" />
            <eclipse:MultiBoundField DataFields="reporting_status" HeaderText="Status" SortExpression="SEQUENCE" HeaderToolTip="Indicates the processing stage of the pickslip." />
            <eclipse:MultiBoundField DataFields="ORDERED_PIECES" HeaderText="Ordered|Pieces" HeaderToolTip="Total Pieces of the orders"
                SortExpression="ORDERED_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ORDERED_DOLLARS" HeaderText="Ordered|Dollars" HeaderToolTip="Total amount of the orders"
                SortExpression="ORDERED_DOLLARS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:C0}"
                DataFooterFormatString="{0:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_IN_BOXES" HeaderText="Shipped|Pieces" HeaderToolTip="Pieces packed in the box."
                SortExpression="PIECES_IN_BOXES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Estimated_Dollar_Shipped" HeaderText="Shipped|Estimated Dollar" HeaderToolTip="Total dollars of the order which are about to ship"
                SortExpression="Estimated_Dollar_Shipped" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:C0}" DataFooterFormatString="{0:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PERCENT_COMPLETE" HeaderText="% Complete" SortExpression="PERCENT_COMPLETE" HeaderToolTip="Total Ordered pieces * 100 / Total shipped pieces"
                 DataFormatString="{0:P2}" >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_BUCKETS" HeaderText="Number Of|Buckets" AccessibleHeaderText="Number Of Buckets" 
                DataNavigateUrlFields="reporting_status,vwh_id,warehouse_location_id" DataNavigateUrlFormatString="R110_101.aspx?reporting_status={0}&vwh_id={1}&warehouse_location_id={2}"
                 AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}"
                >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_CUSTOMERS" HeaderText="Number Of|Customers"
                DataNavigateUrlFields="reporting_status,vwh_id,warehouse_location_id" DataNavigateUrlFormatString="R110_102.aspx?reporting_status={0}&vwh_id={1}&warehouse_location_id={2}"
                AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}"
                >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <%--<eclipse:MultiBoundField DataFields="NO_OF_PICKSLIPS" HeaderText="Number Of|Pickslips"
                SortExpression="NO_OF_PICKSLIPS" HeaderToolTip="PICKSLIPS" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>--%>
           <%-- <eclipse:MultiBoundField DataFields="NO_OF_POS" HeaderText="Number Of|PO" SortExpression="NO_OF_POS"
                 DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>--%>
            <eclipse:SiteHyperLinkField DataTextField="NO_OF_PICKSLIPS" HeaderText="Number Of|Pickslip"  SortExpression="NO_OF_PICKSLIPS"
                DataNavigateUrlFields="reporting_status,vwh_id,warehouse_location_id" DataNavigateUrlFormatString="R110_10.aspx?reporting_status={0}&vwh_id={1}&warehouse_location_id={2}"
                 AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}"
                >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>

            <eclipse:SiteHyperLinkField DataTextField="NO_OF_POS" HeaderText="Number Of|PO"  SortExpression="NO_OF_POS"
                DataNavigateUrlFields="reporting_status,vwh_id,warehouse_location_id" DataNavigateUrlFormatString="R110_103.aspx?reporting_status={0}&vwh_id={1}&warehouse_location_id={2}"
                 AppliedFiltersControlID="ButtonBar1$af" DataTextFormatString="{0:#,###}"
                >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
             <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID" HeaderToolTip="Virtual Warehouse of the orders"
                >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="" HeaderText="Process Days" AccessibleHeaderText="process_days"
                HeaderToolTip="(OrderedPieces - CurrentPieces) / PiecesPerDay">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

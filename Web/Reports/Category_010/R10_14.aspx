<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Weekly Shipping Report" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *  $Revision: 6181 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_010/R10_14.aspx $
 *  $Id: R10_14.aspx 6181 2013-09-27 07:09:52Z skumar $
 * Version Control Template Added.
 
 TODO: 
 1. Intent of the report should be clear. NM We have corrected
 2. We are currently showing quantity and cost together. In my view it should be a seperate column.
 3. Old report had summary at the top. It should be included in new report as well. NM We have added.
 
 Future Enhancement:
 1. I will suggest summary information to include total pieces shipped and total order processed
  
 
--%>

<script runat="server">
    /// <summary>
    /// Showing pieces and dollars cancelled on pass ship date and total pieces and dollars cancelled from week start date to 
    /// previous day of pass ship date.
    /// </summary>
    private int _cumulativeTotalPiecesCancelledWeek;
    private int _cumulativeTotalDollarsCancelledWeek;
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Calculate the total pieces and dollars cancelled from week start date to previous day of passed ship date.                    
           
                var val = DataBinder.Eval(e.Row.DataItem, "can_pieces_week");
                if (val != DBNull.Value)
                {
                    _cumulativeTotalPiecesCancelledWeek += Convert.ToInt32(val);
                }
                val = DataBinder.Eval(e.Row.DataItem, "can_dollars_week");
                if (val != DBNull.Value)
                {
                    _cumulativeTotalDollarsCancelledWeek += Convert.ToInt32(val);
                }
                var OrderedPieces = DataBinder.Eval(e.Row.DataItem, "ordered_PIECES_TODAY");
                var objPiecesToday = DataBinder.Eval(e.Row.DataItem, "SHIPPED_pieces_today");
                if (objPiecesToday != DBNull.Value)
                {
                    var pcsToday = Convert.ToInt32(objPiecesToday);
                    if (pcsToday != 0)
                    {
                        var WeightImportDays = DataBinder.Eval(e.Row.DataItem, "weighted_import_days_today");
                        if (WeightImportDays != DBNull.Value)
                        {
                            var lbl = (Label)e.Row.FindControl("AvDaysImport");
                            lbl.Text = string.Format("{0:N2}", Convert.ToDouble(WeightImportDays) / pcsToday);
                        }
                        var WeightDeliveryDays = DataBinder.Eval(e.Row.DataItem, "weighted_delivery_days_today");
                        if (WeightDeliveryDays != DBNull.Value)
                        {
                            var lbl = (Label)e.Row.FindControl("AvDaysDelivery");
                            lbl.Text = string.Format("{0:N2}", Convert.ToDouble(WeightDeliveryDays) / pcsToday);
                        }
                        if (WeightImportDays != DBNull.Value && WeightDeliveryDays != DBNull.Value)
                        {
                            var MinimumAfterDeliveryDays = (Label)e.Row.FindControl("MinimumDayAfterDelivery");
                            if (Convert.ToDouble(WeightImportDays) / pcsToday < Convert.ToDouble(WeightDeliveryDays) / pcsToday)
                            {
                                MinimumAfterDeliveryDays.Text = string.Format("{0:N2}", Convert.ToDouble(WeightImportDays) / pcsToday);

                            }
                            else
                            {
                                MinimumAfterDeliveryDays.Text = string.Format("{0:N2}", Convert.ToDouble(WeightDeliveryDays) / pcsToday);
                            }
                        }


                    }

                }
                if (OrderedPieces != DBNull.Value)
                {
                    var OrderToday = Convert.ToInt32(OrderedPieces);
                    if (OrderToday != 0)
                    {
                        if (objPiecesToday != DBNull.Value)
                        {
                            var lbl = (Label)e.Row.FindControl("ShippedPercent");
                            lbl.Text = string.Format("{0:P2}", Convert.ToDouble(objPiecesToday) / OrderToday);
                        }
                    }
                }
                // Extract sums from columns
                lblTotalPiecesCancelled.Text = string.Format("Total Pieces Cancelled: {0:N0}", _cumulativeTotalPiecesCancelledWeek );
                lblTotalDollarsCancelled.Text = string.Format("Total Dollars Cancelled: {0:C0}", _cumulativeTotalDollarsCancelledWeek);
        }
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays weakly shipping details for each customer type and virtual warehouse on the basis 
    of passed date." />
    <meta name="ReportId" content="10.14" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R10_14.aspx 6181 2013-09-27 07:09:52Z skumar $" />
    <meta name="ChangeLog" content="Dividing by zero is now handled in the report.|Now, user can see cancelled pieces/dollars in week and month." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="tcpFilters" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Shipped Date" />
                <d:BusinessDateTextBox ID="dtShipDate" runat="server" FriendlyName="Shipped Date"
                    QueryString="ship_date" Text="0">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" QueryString="vwh_id" ShowAll="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:VirtualWarehouseSelector>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
     <%-- with pickslip_customer_types as  (
SELECT ps.pickslip_id as pickslip_id,
	   tct.description || decode(tct.subgroup_flag, 'Y', ('-' || tsl.description)) AS customer_type,
	   (CASE
          WHEN ps.cancel_reason_code = :cancel_reason_code AND ps.ps_status_id = 10 THEN 
            10
          ELSE 
            ps.ps_status_id
         END) AS ship_status,
        trunc(ps.upload_date) AS upload_date,
       DECODE(PS.TOTAL_QUANTITY_SHIPPED,
                0,
                NULL,
                PS.TOTAL_QUANTITY_SHIPPED) AS TOTAL_QUANTITY_SHIPPED,
         DECODE(PS.TOTAL_QUANTITY_ORDERED,
                0,
                NULL,
                PS.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
         ROUND(DECODE(PS.TOTAL_DOLLARS_ORDERED,
                      0,
                      NULL,
                      PS.TOTAL_DOLLARS_ORDERED),
               2) AS TOTAL_DOLLARS_ORDERED,
         ROUND(DECODE(PS.TOTAL_DOLLARS_SHIPPED,
                      0,
                      NULL,
                      PS.TOTAL_DOLLARS_SHIPPED),
               2) AS TOTAL_DOLLARS_SHIPPED,
        trunc(ps.pickslip_import_date) AS pickslip_import_date,
        trunc(ps.delivery_date) AS delivery_date,
        ps.vwh_id AS vwh_id,
        decode(tct.subgroup_flag, 'Y', ps.pickslip_type) as label_id,
        ps.upload_date as ship_date,
        tct.customer_type as cust_type
   FROM dem_pickslip ps
   LEFT OUTER JOIN master_customer mc ON ps.customer_id = mc.customer_id
   LEFT OUTER JOIN tab_customer_type tct ON mc.customer_type = tct.customer_type
   LEFT OUTER JOIN tab_style_label tsl ON tsl.label_id = ps.pickslip_type
  WHERE ps.upload_date BETWEEN :month_start_date AND least(:week_end_date, :ship_date) + 1
    AND PS.Ps_Status_Id = DECODE(PS.CANCEL_REASON_CODE, :cancel_reason_code, 10, 8) 
    <if>AND ps.vwh_id = :vwh_id</if>
 ), 
pickslip_info AS (
SELECT pct.customer_type,
	   SUM(CASE
		     WHEN pct.ship_status = 8 AND pct.upload_date = :ship_date THEN
		   	   pct.total_quantity_shipped
		    END) AS pieces_shipped_ship_date,
	   SUM(CASE
			 WHEN pct.ship_status = 8 AND pct.upload_date BETWEEN :week_start_date AND :ship_date THEN
			   pct.total_quantity_shipped
			 END) AS pieces_shipped_wtd,
	 SUM(CASE
		   WHEN pct.ship_status = 8 AND pct.upload_date BETWEEN :month_start_date AND :ship_date THEN
	         pct.total_quantity_shipped
		  END) AS pieces_shipped_mtd,
	 SUM(CASE
		   WHEN pct.ship_status = 8 AND pct.upload_date = :ship_date THEN
		     pct.total_dollars_shipped
		  END) AS dollars_shipped_ship_date,
	 SUM(CASE
		   WHEN pct.ship_status = 8 AND pct.upload_date BETWEEN :week_start_date AND :ship_date THEN
			 pct.total_dollars_shipped
		  END) AS dollars_shipped_wtd,
	 SUM(CASE
		   WHEN pct.ship_status = 8 AND pct.upload_date BETWEEN :month_start_date AND :ship_date THEN
             pct.total_dollars_shipped
		  END) AS dollars_shipped_mtd,
	 COUNT(CASE
			 WHEN pct.upload_date = :ship_date THEN
			   pct.pickslip_id
			END) AS count_pickslips_ship_date,
	 SUM(CASE
		   WHEN pct.ship_status = 10 AND pct.upload_date = :ship_date THEN
		   	 pct.total_quantity_ordered
		  END) AS pieces_cancelled_ship_date,
	 SUM(CASE
				 WHEN pct.ship_status = 10 AND pct.upload_date = :ship_date THEN
					pct.total_dollars_ordered
			 END) AS dollars_cancelled_ship_date,
	 SUM(CASE
		   WHEN pct.ship_status = 10 AND pct.upload_date BETWEEN :week_start_date AND :ship_date -1 THEN
		   	 pct.total_quantity_ordered
		  END) AS pieces_cancelled_week_date,
	 SUM(CASE
				 WHEN pct.ship_status = 10 AND pct.upload_date BETWEEN :week_start_date AND :ship_date -1 THEN
					pct.total_dollars_ordered
			 END) AS dollars_cancelled_week_date,
	 SUM(CASE
				 WHEN pct.upload_date = :ship_date THEN
					pct.total_quantity_ordered
			 END) AS pieces_ordered_ship_date,
	 SUM(CASE
				 WHEN pct.ship_status = 8 AND pct.upload_date = :ship_date THEN
					(pct.upload_date - pct.pickslip_import_date) * pct.total_quantity_shipped
			 END) AS weighted_days_past_import,
	 SUM(CASE
				 WHEN pct.ship_status = 8 AND pct.upload_date = :ship_date THEN
					(pct.upload_date - pct.delivery_date) * pct.total_quantity_shipped
			 END) AS weighted_days_past_delivery,
	 pct.vwh_id AS vwh_id,
	 max(pct.label_id) as label_id,
	 max(case when pct.upload_date = :ship_date then
	 pct.ship_date
	 end) as ship_date,
	 max(pct.cust_type) as cust_type
FROM pickslip_customer_types pct
GROUP BY pct.vwh_id, 
         pct.customer_type
)
	SELECT pi.customer_type AS customer_type,
		   pi.pieces_shipped_ship_date AS pieces_today,
		   round(pi.dollars_shipped_ship_date,0) AS dollars_today,
		   pi.pieces_shipped_wtd AS pieces_wtd,
		   round(pi.dollars_shipped_wtd,0) AS dollars_wtd,
		   pi.pieces_shipped_mtd AS pieces_mtd,
		   round(pi.dollars_shipped_mtd,0) AS dollars_mtd,
		   nvl(pi.pieces_cancelled_ship_date,0) AS can_pieces_today,
		   round(nvl(pi.dollars_cancelled_ship_date,0),0) AS can_dollars_today,
		   nvl(pi.pieces_cancelled_week_date,0) AS can_pieces_week,
		   round(nvl(pi.dollars_cancelled_week_date,0),0) AS can_dollars_week,
		   round(pi.pieces_shipped_ship_date / pi.pieces_ordered_ship_date, 4) AS pct_pieces_complete_ship_date,
		   pi.count_pickslips_ship_date AS no_of_pickslip,
		   round(pi.weighted_days_past_import / pi.pieces_shipped_ship_date, 4) AS av_days_after_import,
		   round(pi.weighted_days_past_delivery / pi.pieces_shipped_ship_date, 4) AS av_days_after_delivery,
		   CASE
		     WHEN round(pi.weighted_days_past_import / pi.pieces_shipped_ship_date, 4) &lt;
			      round(pi.weighted_days_past_delivery / pi.pieces_shipped_ship_date, 4) THEN
				    round(pi.weighted_days_past_import / pi.pieces_shipped_ship_date, 4)
			 ELSE
			   		round(pi.weighted_days_past_delivery / pi.pieces_shipped_ship_date, 4)
		   END minimum_days_after_delivery,
		   round(SUM(pi.pieces_shipped_ship_date)
					         over() / SUM(pi.pieces_ordered_ship_date) over(),
					         4) AS tot_pct_pieces_com_ship_date,
		   round(SUM(pi.weighted_days_past_import)
					         over() / SUM(pi.pieces_shipped_ship_date) over(),
					         2) AS tot_av_days_after_import,
		   round(SUM(pi.weighted_days_past_delivery)
					         over() / SUM(pi.pieces_shipped_ship_date) over(),
					         2) AS tot_av_days_after_delivery,
		   least((round(SUM(pi.weighted_days_past_import)
						    over() / SUM(pi.pieces_shipped_ship_date) over(),
						    2)),
		   (round(SUM(pi.weighted_days_past_delivery)
						    over() / SUM(pi.pieces_shipped_ship_date) over(),
						    2))) AS tot_min_days_after_date,
	       pi.vwh_id as vwh_id,
	       pi.label_id as label_id,
	       pi.ship_date as ship_date,
	       pi.cust_type as cust_type
      FROM pickslip_info pi --%>


with shipped_orders as
(select TCT.DESCRIPTION || CASE
           WHEN TCT.SUBGROUP_FLAG = 'Y' THEN
            ('-' || TSL.DESCRIPTION)
         END AS CUSTOMER_TYPE,
         P.VWH_ID AS VWH_ID,
         max(case when tct.subgroup_flag = 'Y' THEN p.label_id end) as label_id,
         SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) then
                bd.current_pieces
             end) AS SHIPPED_PIECES_TODAY,
         SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) then
                bd.current_pieces * bd.extended_price
             end) as SHIPPED_DOLLARS_TODAY,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :week_start_date AND :ship_date then 
                bd.current_pieces
             end) AS SHIPPED_PIECES_WTD,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :week_start_date AND :ship_date then 
                bd.current_pieces * bd.extended_price
             end) AS SHIPPED_DOLLARS_WTD,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :month_start_date AND :ship_date then 
                bd.current_pieces
             end) AS SHIPPED_PIECES_MTD,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :month_start_date AND :ship_date then 
                bd.current_pieces * bd.extended_price
             end) AS SHIPPED_DOLLARS_MTD,
            SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) then
                round(p.transfer_date - p.pickslip_import_date, 2) * bd.current_pieces
             end) as weighted_import_days_today,
             SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) then
                round(p.transfer_date - po.start_date, 2) * bd.current_pieces
             end) as  weighted_delivery_days_today,
          max(tct.customer_type) as cust_type,
        max(case when trunc(p.transfer_date) = trunc(:ship_date) then
          p.transfer_date
         end ) as ship_date
    from ps p
    LEFT OUTER JOIN MASTER_CUSTOMER MC
      ON P.CUSTOMER_ID = MC.CUSTOMER_ID
    LEFT OUTER JOIN TAB_CUSTOMER_TYPE TCT
      ON MC.CUSTOMER_TYPE = TCT.CUSTOMER_TYPE
    LEFT OUTER JOIN tab_style_label tsl ON tsl.label_id = p.label_id
   INNER JOIN BOX B
      ON P.PICKSLIP_ID = B.PICKSLIP_ID
   INNER JOIN BOXDET BD
      ON b.PICKSLIP_ID = BD.PICKSLIP_ID
     and b.ucc128_id = bd.ucc128_id
    left outer JOIN PO
      ON P.CUSTOMER_ID = PO.CUSTOMER_ID
     AND P.PO_ID = PO.PO_ID
     AND P.ITERATION = PO.ITERATION
   where p.cancel_reason_code is null
     AND P.PICKSLIP_CANCEL_DATE IS NULL
     AND P.TRANSFER_DATE BETWEEN :month_start_date AND :ship_date + 1
     and bd.stop_process_date BETWEEN :month_start_date AND :ship_date + 1
     and b.stop_process_reason = '$XREF'
     and b.stop_process_date BETWEEN :month_start_date AND :ship_date + 1    
     <if>AND p.vwh_id = :vwh_id</if>   
   group by TCT.DESCRIPTION || CASE
              WHEN TCT.SUBGROUP_FLAG = 'Y' THEN
               ('-' || TSL.DESCRIPTION)
            END,
            P.VWH_ID),
all_orders as
(select  TCT.DESCRIPTION || CASE
           WHEN TCT.SUBGROUP_FLAG = 'Y' THEN
            ('-' || TSL.DESCRIPTION)
         END AS CUSTOMER_TYPE,
         P.VWH_ID AS VWH_ID,
         max(case when tct.subgroup_flag = 'Y' THEN p.label_id end) as label_id,
         MAX(tct.description) as customer_type_description,
         max(case when tct.subgroup_flag = 'Y' THEN tsl.description end) as label_description,
         SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) and p.cancel_reason_code is null then
                p.total_quantity_ordered
             end) as ordered_PIECES_TODAY,
         SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) and p.cancel_reason_code is not null then
                p.total_quantity_ordered
             end) as CAN_PIECES_TODAY,
         SUM(case
               when trunc(p.transfer_date) = trunc(:ship_date) and p.cancel_reason_code is not null
          then
                p.total_dollars_ordered
             end) as CAN_DOLLARS_TODAY,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :week_start_date AND :ship_date and p.cancel_reason_code is not null then 
                p.total_quantity_ordered
             end) as CAN_PIECES_WTD,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :week_start_date AND :ship_date
          and p.cancel_reason_code is not null
           then 
                p.total_dollars_ordered
             end) as CAN_DOLLARS_WTD,
        SUM(case
               when TRUNC(p.transfer_date) BETWEEN :month_start_date AND :ship_date and p.cancel_reason_code is not null then 
                p.total_quantity_ordered
             end) as CAN_PIECES_MTD,
         SUM(case
               when TRUNC(p.transfer_date) BETWEEN :month_start_date AND :ship_date
          and p.cancel_reason_code is not null
           then 
                p.total_dollars_ordered
             end) as CAN_DOLLARS_MTD,
         count(unique case
                 when trunc(p.transfer_date) = trunc(:ship_date)
          then
                  p.pickslip_id
               end) as no_of_pickslip
              from ps p
    LEFT OUTER JOIN MASTER_CUSTOMER MC
      ON P.CUSTOMER_ID = MC.CUSTOMER_ID
    LEFT OUTER JOIN TAB_CUSTOMER_TYPE TCT
      ON MC.CUSTOMER_TYPE = TCT.CUSTOMER_TYPE
    LEFT OUTER JOIN tab_style_label tsl ON tsl.label_id = p.label_id
   where P.TRANSFER_DATE BETWEEN :month_start_date AND :ship_date + 1 
     <if>AND p.vwh_id = :vwh_id</if>
   group by TCT.DESCRIPTION || CASE
              WHEN TCT.SUBGROUP_FLAG = 'Y' THEN
               ('-' || TSL.DESCRIPTION)
            END,
            P.VWH_ID)
SELECT C.CUSTOMER_TYPE AS CUSTOMER_TYPE,
       C.VWH_ID AS VWH_ID,
       C.label_id AS label_id,
       S.SHIPPED_PIECES_TODAY AS SHIPPED_PIECES_TODAY,
       S.SHIPPED_DOLLARS_TODAY AS SHIPPED_DOLLARS_TODAY,
       S.SHIPPED_PIECES_WTD AS SHIPPED_PIECES_WTD,
       S.SHIPPED_DOLLARS_WTD AS SHIPPED_DOLLARS_WTD,
       S.SHIPPED_PIECES_MTD AS SHIPPED_PIECES_MTD,
       S.SHIPPED_DOLLARS_MTD AS SHIPPED_DOLLARS_MTD,
       C.CAN_PIECES_TODAY AS CAN_PIECES_TODAY,
       C.CAN_DOLLARS_TODAY AS CAN_DOLLARS_TODAY,
       C.CAN_PIECES_WTD AS CAN_PIECES_WEEK,
       C.CAN_DOLLARS_WTD AS CAN_DOLLARS_WEEK,
       C.CAN_PIECES_MTD AS CAN_PIECES_MONTH,
       C.CAN_DOLLARS_MTD AS CAN_DOLLARS_MONTH,
       C.NO_OF_PICKSLIP AS NO_OF_PICKSLIP,
       C.ORDERED_PIECES_TODAY,
       S.WEIGHTED_IMPORT_DAYS_TODAY,
       S.WEIGHTED_DELIVERY_DAYS_TODAY,
       S.CUST_TYPE,
       S.SHIP_DATE
  FROM ALL_ORDERS C
  LEFT OUTER JOIN SHIPPED_ORDERS S
    ON C.CUSTOMER_TYPE = S.CUSTOMER_TYPE
   AND C.VWH_ID = S.VWH_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="DateTime" Name="business_month_start_date"
                PropertyName="MonthStartDate" />
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="DateTime" Name="ship_date"
                PropertyName="Text" />
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="Int32" Name="days_from_week_start"
                PropertyName="DaysFromWeekStart" />
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="DateTime" Name="month_start_date"
                PropertyName="MonthStartDate" />
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="DateTime" Name="week_start_date"
                PropertyName="WeekStartDate" />
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="DateTime" Name="week_end_date"
                PropertyName="WeekEndDate" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:Parameter Name="cancel_reason_code" Type="String" DefaultValue="<%$  AppSettings: CancelReasonCode  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <br />
    <div class="ui-widget">
        <b>
            <asp:Label runat="server" ID="lblTotalPiecesCancelled" />
            <br />
            <asp:Label runat="server" ID="lblTotalDollarsCancelled" /></b>
    </div>
    <br />
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" DataSourceID="ds"
        ShowFooter="true" AllowSorting="true" DefaultSortExpression="customer_type;vwh_id"
        OnRowDataBound="gv_RowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <asp:TemplateField HeaderText="Customer Type" SortExpression="customer_type">
                <ItemTemplate>
                    <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex='<%# Eval("SHIPPED_pieces_today") == DBNull.Value ? 1 : 0 %>'>
                        <asp:View runat="server">
                            <eclipse:SiteHyperLink ID="SiteHyperLink1" runat="server" Text='<%# Eval("CUSTOMER_TYPE") %>' SiteMapKey="R10_101.aspx"
                                NavigateUrl='<%# string.Format("ship_date={0:d}&cust_type={1}&label_id={2}&vwh_id={3}", Eval("ship_date"),Eval("cust_type"),Eval("label_id"),Eval("vwh_id"))%>'>
                            </eclipse:SiteHyperLink>
                        </asp:View>
                        <asp:View runat="server">
                            <asp:Label ID="Label1" runat="server" Text='<%# Eval("CUSTOMER_TYPE") %>'></asp:Label>
                        </asp:View>
                    </asp:MultiView>
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="SHIPPED_pieces_today,SHIPPED_dollars_today" HeaderText="Pieces/Price Shipped|Today"
                SortExpression="SHIPPED_pieces_today,SHIPPED_dollars_today" DataFormatString="{0:N0}<br />{1:C0}"
                HeaderToolTip="Click to sort by pieces" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}<br />{1:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHIPPED_pieces_wtd,SHIPPED_dollars_wtd" HeaderText="Pieces/Price Shipped|Week To Date"
                SortExpression="SHIPPED_pieces_wtd,SHIPPED_dollars_wtd" DataFormatString="{0:N0}<br/>{1:C0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}<br/>{1:C0}"
                HeaderToolTip="Click to sort by pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHIPPED_pieces_mtd,SHIPPED_dollars_mtd" HeaderText="Pieces/Price Shipped|Month To Date"
                SortExpression="SHIPPED_pieces_mtd,SHIPPED_dollars_mtd" DataFormatString="{0:N0}<br/>{1:C0}"
                HeaderToolTip="Click to sort by pieces" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}<br />{1:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="no_of_pickslip" HeaderText="Orders Processed"
                SortExpression="no_of_pickslip" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="can_pieces_today,can_dollars_today" HeaderText="Pieces/Price Cancelled|Today"
                SortExpression="can_pieces_today,can_dollars_today" DataFormatString="{0:N0}<br/>{1:C0}"
                HeaderToolTip="Click to sort by pieces" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}<br/>{1:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="CAN_PIECES_WEEK,can_dollars_WEEK" HeaderText="Pieces/Price Cancelled|Week To Date"
                SortExpression="can_pieces_WEEK,can_dollars_WEEK" DataFormatString="{0:N0}<br/>{1:C0}" 
                HeaderToolTip="Click to sort by pieces" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}<br/>{1:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="can_pieces_MONTH,can_dollars_MONTH" HeaderText="Pieces/Price Cancelled|Month To Date"
                SortExpression="can_pieces_MONTH,can_dollars_MONTH" DataFormatString="{0:N0}<br/>{1:C0}"
                HeaderToolTip="Click to sort by pieces" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}<br/>{1:C0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <asp:TemplateField HeaderText="Percent Complete">
                <ItemTemplate>
                    <asp:Label ID="ShippedPercent" runat="server"></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Average Days To Upload|After Import">
                <ItemTemplate>
                    <asp:Label ID="AvDaysImport" runat="server"></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Average Days To Upload|After Delivery">
                <ItemTemplate>
                    <asp:Label ID="AvDaysDelivery" runat="server"></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Average Days To Upload|Minimum">
                <ItemTemplate>
                    <asp:Label ID="MinimumDayAfterDelivery" runat="server"></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

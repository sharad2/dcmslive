<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKUs in a Purchase Order" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6439 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_09.aspx $
 *  $Id: R110_09.aspx 6439 2014-03-15 10:25:25Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Calculating summary to display at top. Constructing a report hyper link with query string to display on top--%>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (Page.IsPostBack)
        {
            if (!dtFrom.ValueAsDate.HasValue && dtTo.ValueAsDate.HasValue)
            {
                dtFrom.Text = dtTo.ValueAsDate.Value.ToShortDateString();
            }

        }
    }

    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.Footer:
                // Extract sums from columns
                MultiBoundField mbf = (from MultiBoundField dcf in gv.Columns.OfType<MultiBoundField>()
                                       where dcf.DataFields[0] == "total_quantity_ordered"
                                       select dcf).Single();
                decimal sumQtyOrdered = mbf.SummaryValues[0] ?? 0;
                mbf = (from MultiBoundField abc in gv.Columns.OfType<MultiBoundField>()
                       where abc.DataFields[0] == "shortage_in_pieces"
                       select abc).Single();
                decimal sumQtyShort = mbf.SummaryValues[0] ?? 0;
                decimal sumQtyPicked = sumQtyOrdered - sumQtyShort;
                if (sumQtyOrdered > 0)
                {
                    lblPercentComplete.Text = string.Format("{0:N0} of {1:N0} pieces = {2:P2} is picked for PO {3}.",
                        sumQtyPicked, sumQtyOrdered, sumQtyPicked / sumQtyOrdered, tbPo.Text);
                }
                break;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="110.09" />
    <meta name="Description" content="This report displays details of all SKUs in the specified PO. 
    The report displays a detailed status of ordered SKUs customer wise and how much quantity is short for particular SKU along with the Virtual Warehouse. You can further restrict the SKUs included by specifying optional filters." />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R110_09.aspx 6439 2014-03-15 10:25:25Z skumar $" />
    <meta name="ChangeLog" content="Now the report will not show the cancelled pickslips." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <%-- <ol>
        <li>What is % Complete it should be explained may be in tool tip</li>
        <li>Query of the report is not correct.</li>
    </ol>--%>
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="PO" />
                <i:TextBoxEx ID="tbPo" runat="server" QueryString="po_id" ToolTip="Purchase Order">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Customer Id" />
                <i:TextBoxEx ID="tbCustId" runat="server" QueryString="customer_id" ToolTip="Customer ID." />
                <eclipse:LeftLabel runat="server" Text="Pickslip Import Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Pickslip Import Date"
                    QueryString="min_pickslip_import_date" ToolTip="Must enter the date by which you see the information of customer order from this date." />
                   
                    
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Pickslip Import Date"
                    QueryString="max_pickslip_import_date" ToolTip="Enter the date by which you see the information of customer order upto this date. Please Enter only 1 year as date range.">
                   <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Ship Date" />
                <d:BusinessDateTextBox ID="dtShipDate" runat="server" QueryString="ship_date" FriendlyName="Ship Date"
                    ToolTip="Enter the Ship date by which you see the information.">
                    </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlvwh_id" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="More Filters" ToolTip="This is additional Filter which is passed from another report.">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="Customer Order Type" />
                <i:RadioButtonListEx runat="server" ID="rblOrderType" ToolTip="Choose Customer Order Type"
                    QueryString="order_type" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="All" Value="A" Enabled="true" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text="DC Cancel Date" />
                From
                <d:BusinessDateTextBox ID="dtFromDcCancel" runat="server" FriendlyName="From DC cancel date"
                    QueryString="from_dc_cancel_date" ToolTip="Must enter the date by which you see the information of customer order from this date.">
                    </d:BusinessDateTextBox>
                    
                To
                <d:BusinessDateTextBox ID="dtToDcCancel" runat="server" FriendlyName="To DC cancel date"
                    QueryString="to_dc_cancel_date" ToolTip="Enter the date by which you see the information of customer order upto this date. Please Enter only 1 year as date range.">
                  <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel8" runat="server" />
                <d:StyleLabelSelector ID="ctlLabelSelector" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    FriendlyName="Label" ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="label_id">
                </d:StyleLabelSelector>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" ID="ctlButtonBar" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  CancelSelectOnNullParameter="true">
          <SelectSql>
           with all_ordered as (
        SELECT psdet.upc_code AS upc_code,
         psdet.pieces_ordered AS pieces_ordered,
               ps.vwh_id AS vwh_id,
               ps.customer_id AS customer_id
        FROM psdet
         INNER JOIN ps ON ps.pickslip_id = psdet.pickslip_id
           <if c="$from_dc_cancel_date">INNER JOIN po ON po.PO_ID = ps.PO_ID
                                             AND po.customer_id = ps.customer_id
                                             AND po.iteration = ps.iteration</if>                                  
         WHERE ps.PO_ID = :PO_ID
           AND ps.transfer_date is NULL
           and ps.pickslip_cancel_date is null
           <if>AND ps.customer_id = :customer_id</if>
           <if>AND ps.vwh_id = :vwh_id</if>
           <if>AND ps.reporting_status = :reporting_status</if>
           <if>AND ps.iteration = :iteration</if>
           <if>AND ps.pickslip_import_date &gt;= :min_pickslip_import_date</if>
           <if>AND ps.pickslip_import_date &lt; :max_pickslip_import_date +1</if>
           <if>AND po.dc_cancel_date &gt;= :from_dc_cancel_date</if>
           <if>AND po.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
           <if>AND ps.pickslip_prefix = :pickslip_prefix</if>
           <if>AND ps.label_id = :label_id</if>
           <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
           <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>                
        UNION ALL
        SELECT dempsdet.upc_code AS upc_code,
         dempsdet.quantity_ordered AS pieces_ordered,
               dps.vwh_id AS vwh_id,
               dps.customer_id AS customer_id
        FROM dem_pickslip_detail dempsdet
         INNER JOIN dem_pickslip dps ON dps.pickslip_id = dempsdet.pickslip_id
         WHERE dps.ps_status_id = 1
         AND dps.customer_order_id = :PO_ID
         <if>AND dps.customer_id = :customer_id</if>
          <if>AND dps.pickslip_import_date &gt;=:min_pickslip_import_date</if> 
           <if>AND dps.pickslip_import_date &lt; :max_pickslip_import_date +1</if>
           <if>AND dps.vwh_id = :vwh_id</if>
           <if>AND dps.dc_cancel_date &gt;= :from_dc_cancel_date</if>
           <if>AND dps.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
           <if>AND dps.pickslip_prefix = :pickslip_prefix</if>
           <if>AND dps.pickslip_type = :label_id</if>
           <if c="$customer_type='D'">AND dps.export_flag IS NULL</if>
           <if c="$customer_type='I'">AND dps.export_flag = 'Y'</if>
        ),
        sku_ordered AS (
        SELECT upc_code AS upc_code,
               SUM(pieces_ordered) AS pieces_ordered,
               vwh_id AS vwh_id,
               customer_id AS customer_id
          FROM all_ordered
         GROUP BY upc_code, vwh_id, customer_id
        ),
        sku_shipped AS (
        SELECT boxdet.upc_code AS upc_code,
               SUM(boxdet.current_pieces) AS current_pieces,
               ps.vwh_id AS vwh_id,
               ps.customer_id AS customer_id
          FROM boxdet
         INNER JOIN ps ON ps.pickslip_id = boxdet.pickslip_id
         INNER JOIN box ON box.pickslip_id = ps.pickslip_id
             AND box.ucc128_id = boxdet.ucc128_id
             <if c="$from_dc_cancel_date">INNER JOIN po ON po.PO_ID = ps.PO_ID
                                             AND po.customer_id = ps.customer_id
                                             AND po.iteration = ps.iteration</if>
             <if c="$ship_date">LEFT OUTER JOIN ship ON ps.shipping_id = ship.shipping_id</if>                                
         WHERE ps.PO_ID = :PO_ID
           AND PS.TRANSFER_DATE IS NULL
           <if>AND ps.customer_id = :customer_id</if>
           <if>AND ship.ship_date Between trunc(:ship_date) and trunc(:ship_date + 1)</if>
           <if>AND ps.vwh_id = :vwh_id</if>
           <if>AND ps.iteration = :iteration</if>
           <if>AND ps.pickslip_import_date &gt;= :min_pickslip_import_date</if>
           <if>AND ps.pickslip_import_date &lt; :max_pickslip_import_date +1</if>
           <if>AND po.dc_cancel_date &gt;= :from_dc_cancel_date</if>
           <if>AND po.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
           <if>AND ps.pickslip_prefix = :pickslip_prefix</if>
           <if>AND ps.label_id = :label_id</if>
           <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
           <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>
           AND ps.transfer_date is null
           AND box.stop_process_date is null
           AND boxdet.stop_process_date is null           
         GROUP BY boxdet.upc_code,
                  ps.vwh_id,
                  ps.customer_id
         ),
        ialoc_info AS 
        (
        SELECT il.assigned_upc_code assigned_upc_code,
               il.vwh_id vwh_id,
               <%--min(il.location_id) as min_fpk_location_id,
               MAX(il.location_id) as max_fpk_location_id,
              count(distinct il.location_id) as fpk_location_count--%>
              rtrim(sys.stragg(unique il.location_id||', '),', ') as location_id
          FROM ialoc il
         GROUP BY il.assigned_upc_code,
                  il.vwh_id
        )
        SELECT skuo.vwh_id AS vwh_id,
               skuo.customer_id AS customer_id,
               skuo.upc_code,
               nvl(skuo.pieces_ordered, 0)  AS total_quantity_ordered,
               nvl(skus.current_pieces, 0) as current_pieces,
               nvl(skuo.pieces_ordered, 0) - nvl(skus.current_pieces, 0) AS shortage_in_pieces,
               cust.NAME AS customer_name,
               sku.style AS style,
               sku.color AS color,
               sku.dimension AS dimension,
               sku.sku_size AS sku_size,
               location_id AS location_id
       FROM sku_ordered skuo
       LEFT OUTER JOIN sku_shipped skus ON skuo.upc_code = skus.upc_code
                             AND skuo.vwh_id = skus.vwh_id
                         AND skuo.customer_id = skus.customer_id
          LEFT OUTER JOIN master_sku sku ON sku.upc_code = skuo.upc_code
          LEFT OUTER JOIN ialoc_info iloc ON iloc.assigned_upc_code = skuo.upc_code
                                         AND iloc.vwh_id = skuo.vwh_id
          LEFT OUTER JOIN cust cust ON cust.customer_id = skuo.customer_id
          </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPo" Type="String" Direction="Input" Name="PO_ID" />
            <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="min_pickslip_import_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="max_pickslip_import_date" />
            <asp:ControlParameter ControlID="dtShipDate" Type="DateTime" Direction="Input" Name="ship_date" />
            <asp:ControlParameter ControlID="ctlvwh_id" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter Name="customer_type" Type="String" Direction="Input" ControlID="rblOrderType" />
            <asp:ControlParameter Name="label_id" Type="String" Direction="Input" ControlID="ctlLabelSelector" />
            <asp:ControlParameter Name="from_dc_cancel_date" Type="DateTime" Direction="Input"
                ControlID="dtFromDcCancel" />
            <asp:ControlParameter Name="to_dc_cancel_date" Type="DateTime" Direction="Input"
                ControlID="dtToDcCancel" />
            <asp:QueryStringParameter Name="iteration" Direction="Input" Type="Int16" QueryStringField="iteration" />
            <asp:QueryStringParameter Name="reporting_status" Direction="Input" Type="String"
                QueryStringField="reporting_status" />
            <asp:QueryStringParameter Name="pickslip_prefix" Direction="Input" Type="String"
                QueryStringField="pickslip_prefix" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <br />
    <div class="ui-widget">
        <eclipse:SiteHyperLink ID="SiteHyperLink1" runat="server" Text="See pickslips in Current PO"
            SiteMapKey="R110_10.aspx" AppliedFiltersControlID="ctlButtonBar$af" />
        <br />
        <br />
        <asp:Label runat="server" ID="lblPercentComplete" />
    </div>
    <br />
    <br />
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="customer_id;vwh_id;$;location_id"
        AutoGenerateColumns="false" ShowFooter="true" ShowHeader="true" OnRowDataBound="gv_RowDataBound"
        AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="customer_id,customer_name" HeaderText="Customer" SortExpression="customer_id"
                HeaderToolTip="Customer Id" DataFormatString="{0} : {1}" ItemStyle-Font-Bold="true"/>
  <%--          <eclipse:MultiBoundField DataFields="customer_name" HeaderText="Customer Name" SortExpression="customer_name"
                HeaderToolTip="Customer name" />--%>
            <eclipse:MultiBoundField DataFields="upc_code" HeaderText="UPC" SortExpression="upc_code"
                HeaderToolTip="UPC Code" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style of the SKU" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color of the SKU" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension"
                HeaderToolTip="Dimension of the SKU" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="Size of the SKU" />
            <eclipse:MultiBoundField DataFields="total_quantity_ordered" HeaderText="Quantity|Ordered"
                SortExpression="total_quantity_ordered" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" FooterToolTip="Sum of quantity ordered">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="shortage_in_pieces" HeaderText="Quantity|Short"
                SortExpression="shortage_in_pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of quantity short">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="location_id" NullDisplayText="No Location" HeaderText="Assigned FPK Location"
              SortExpression="location_id" />
            <%--  <asp:TemplateField HeaderText="Assigned FPK Location" HeaderStyle-Wrap="false"  SortExpression="min_fpk_location_id">
                <ItemTemplate>
                    <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="fpk_location_count,min_fpk_location_id,max_fpk_location_id" />
                </ItemTemplate>
            </asp:TemplateField>--%>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id" ItemStyle-Font-Bold="true"
                HeaderToolTip="Virtual warehouse Id" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Pickslip Details for given Customer/PO/Status" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7236 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_10.aspx $
 *  $Id: R110_10.aspx 7236 2014-11-07 09:27:07Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Link to current PO at top--%>

<script runat="server">
    protected void ds1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (string.IsNullOrEmpty(tbCustomer_id.Text) && string.IsNullOrEmpty(tbpo_id.Text) && string.IsNullOrEmpty(ddlStatus.Value))
        {
            e.Cancel = true;

        }
        return;
    }
    protected void gv1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            div1.Visible = true;

            div2.Visible = true;

        }
    }

    protected void tbcustomer_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (string.IsNullOrEmpty(tbCustomer_id.Text) && string.IsNullOrEmpty(tbpo_id.Text) && string.IsNullOrEmpty(ddlStatus.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide at least one filter from 'Pickslips Of' filter group.";
            return;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays detail of the pickslips for the given Customer or PO or Status. You can also see VAS related pickslip details through  this report. Same report can also be used for manual routing of EDI orders." />
    <meta name="ReportId" content="110.10" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Now report will show STO against a PO. This additional information will be displayed under a new column 'PO Attrib 1'." />
    <meta name="Version" content="$Id: R110_10.aspx 7236 2014-11-07 09:27:07Z skumar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
                $('#cbAll').attr('checked', 'checked');
            };

        });
        function cbAll_OnClientChange(event, ui) {
            if ($('#cbAll').is(':checked')) {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').removeAttr('checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">

            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftPanel runat="server" Span="true">
                    <fieldset>
                        <legend class="ui-widget-header">Pickslips Of(Pass at least one filter)</legend>
                        <br />
                        <fieldset>
                            <legend></legend>
                            <eclipse:TwoColumnPanel ID="TCP" runat="server">
                                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="PO" />
                                <i:TextBoxEx ID="tbpo_id" runat="server" QueryString="po_id" ToolTip="Purchase Order">
                                </i:TextBoxEx>
                                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Customer Id" />
                                <i:TextBoxEx ID="tbCustomer_id" runat="server" QueryString="customer_id" ToolTip="Customer ID.">
                                    <Validators>
                                        <i:Custom OnServerValidate="tbcustomer_OnServerValidate" />
                                    </Validators>
                                </i:TextBoxEx>
                                <eclipse:LeftLabel runat="server" Text="Reporting Status" />
                                <oracle:OracleDataSource ID="dsReportingStatus" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                                    <SelectSql>
                             SELECT trs.reporting_status AS reporting_status
                             FROM tab_reporting_status trs
                             ORDER BY trs.sort_sequence
                                    </SelectSql>
                                </oracle:OracleDataSource>
                                <i:DropDownListEx2 ID="ddlStatus" runat="server" QueryString="reporting_status" ToolTip="Indicate the status of the order" DataFields="reporting_status"
                                    FriendlyName="Reporting Status" DataSourceID="dsReportingStatus" DataTextFormatString="{0}">
                                    <Items>
                                        <eclipse:DropDownItem Text="All" Value="" Persistent="Always" />
                                        <eclipse:DropDownItem Text="IN ORDER BUCKET" Value="IN ORDER BUCKET" Persistent="Always" />
                                    </Items>
                                </i:DropDownListEx2>
                            </eclipse:TwoColumnPanel>
                        </fieldset>

                    </fieldset>
                </eclipse:LeftPanel>
                <br />
                
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Pickslip Import Date" />
                Form
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Pickslip Import Date"
                    QueryString="min_pickslip_import_date" ToolTip="Must enter the date by which you see the information of customer order from this date." />
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Pickslip Import Date"
                    QueryString="max_pickslip_import_date" ToolTip="Enter the date by which you see the information of customer order upto this date. Please Enter only 1 year as date range.">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Ship Date" />
                <d:BusinessDateTextBox ID="dtShip_Date" runat="server" FriendlyName="Ship Date" QueryString="ship_date"
                    ToolTip="Enter the Ship date by which you see the information." />
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwh_id" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Choose virtaul warehouse" />
                <eclipse:LeftPanel ID="LeftPanel7" runat="server">
                    <i:CheckBoxEx runat="server" ID="chkOrderRequiredRouting" Text="Orders Required Routing" CheckedValue="Y"
                        QueryString="unrouted" FriendlyName="Orders Required Routing" Checked="false" />
                </eclipse:LeftPanel>Check this option if you want to see  orders which are not routed yet.
                <eclipse:LeftPanel ID="LeftPanel5" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbvas" Text="Orders Required VAS" CheckedValue="Y"
                        QueryString="vas" FriendlyName="Orders Required VAS" Checked="false" />
                </eclipse:LeftPanel>
                <%--<asp:Label runat="server" Text="Vas"></asp:Label>--%>
                <oracle:OracleDataSource ID="DsVas" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %> ">
                    <SelectSql>                    
                      SELECT TV.VAS_CODE, TV.DESCRIPTION FROM TAB_VAS TV
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlvas" runat="server" DataSourceID="DsVas"
                    DataFields="VAS_CODE, DESCRIPTION" DataTextFormatString="{0}:{1}"
                    DataValueFormatString="{0}" ToolTip="Choose VAS tag" FriendlyName="VAS TYPE" QueryString="vas_id">
                    <Items>
                        <eclipse:DropDownItem Text="All VAS" Value="vas" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Filter DependsOn="cbvas" DependsOnState="Value" DependsOnValue="Y" />
                    </Validators>
                </i:DropDownListEx2>
                <br />
                If you want to see orders that require some specific VAS then please choose it form this drop down list.
            </eclipse:TwoColumnPanel>
            <asp:Panel runat="server">
                <eclipse:TwoColumnPanel runat="server">
                    <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                        <eclipse:LeftLabel ID="LeftLabel9" runat="server" Text="Building" />
                        <br />
                        <br />
                        <i:CheckBoxEx ID="cbAll" runat="server" FriendlyName="Select All" FilterDisabled="true" OnClientChange="cbAll_OnClientChange">
                        </i:CheckBoxEx>
                        Click to Select/UnSelect all
                    </eclipse:LeftPanel>
                    <%-- <i:CheckBoxEx ID="cbAll" runat="server" Text="Select All" OnClientChange="cbAll_OnClientChange" ></i:CheckBoxEx>--%>
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
                    <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION" ToolTip="Building of the order"
                        DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                        QueryString="warehouse_location_id">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="More Filters" ToolTip="This is additional Filter which is passed from another report.">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="Customer Order Type" />
                <i:RadioButtonListEx runat="server" ID="rblOrderType" ToolTip="Choose Customer Order Type"
                    QueryString="order_type" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="All" Value="A" Enabled="true" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftLabel runat="server" Text="Delivery Date" />
                Form
                <d:BusinessDateTextBox ID="dtfromdeliverydate" runat="server" FriendlyName="From Delivery Date"
                    QueryString="from_delivery_date" />
                To
                <d:BusinessDateTextBox ID="dttodeliverydate" runat="server" FriendlyName="To Delivery Date"
                    QueryString="to_delivery_date">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>


                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text="DC Cancel Date" />
                From
                <d:BusinessDateTextBox ID="dtFromDcCancel" runat="server" FriendlyName="From DC cancel date"
                    QueryString="from_dc_cancel_date" ToolTip="Must enter the date by which you see the information of customer order from this date." />
                To
                <d:BusinessDateTextBox ID="dtToDcCancel" runat="server" FriendlyName="To DC cancel date"
                    QueryString="to_dc_cancel_date" ToolTip="Enter the date by which you see the information of customer order upto this date. Please Enter only 1 year as date range.">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel8" runat="server" />
                <d:StyleLabelSelector ID="ctlLabelSelector" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ToolTip="Choose label of the style"
                    FriendlyName="Label" ShowAll="true" QueryString="label_id" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:StyleLabelSelector>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />

    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader" OnSelecting="ds1_Selecting">
        <SelectSql>
WITH Q1 AS
 (SELECT unique PS.CUSTOMER_ID, 
         PS.PICKSLIP_ID,
         PS.TOTAL_QUANTITY_ORDERED,
         PS.TOTAL_DOLLARS_ORDERED,
         PS.CUSTOMER_DC_ID,
         PS.CUSTOMER_STORE_ID
    FROM PS
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
     LEFT OUTER JOIN ps_vas pv
     ON pv.pickslip_id = ps.pickslip_id   
     <if c="$ship_date">left outer join ship ship on ps.shipping_id = ship.shipping_id</if>
   WHERE PS.TRANSFER_DATE IS NULL
     AND PS.PICKSLIP_CANCEL_DATE IS NULL
     <if>AND ps.po_id = :po_id</if>
            <if c="$Customer_id">And ps.Customer_id = :Customer_id</if>
            <if c="$FromDate">AND ps.pickslip_import_date &gt;= :FromDate AND ps.pickslip_import_date &lt; :ToDate + 1</if>
	        <if c="$ship_date">AND ship.ship_date &gt;= :ship_date</if>
            <if c="$ship_date">AND ship.ship_date &lt; :ship_date + 1</if>
            <if>AND ps.vwh_id = :vwh_id</if>
            <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
            <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>
            <if>AND ps.iteration = :iteration</if>
            <if>AND po.dc_cancel_date &gt;= :from_dc_cancel_date</if>
            <if>AND po.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
            <if>AND ps.pickslip_prefix = :pickslip_prefix</if>
            <if>AND ps.label_id = :label_id</if>
            <if>AND PO.START_DATE &gt;= :from_delivery_date</if>
            <if>AND PO.START_DATE &lt; :to_delivery_date + 1</if>
            <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
            <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
            <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>
            <if c="$customer_dc_id">AND ps.customer_dc_id = :customer_dc_id</if> 
            <if c="$customer_store_id">AND ps.customer_store_id = :customer_store_id</if>  
            <if c="$vas"> 
                and pv.vas_id is not null        
                 <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
             </if> 
               <if c="$unrouted"> and not exists (select 1
            from edi_753_754_ps eps
           where eps.pickslip_id = ps.pickslip_id
             and eps.Edi753_Sent_On is not null)
     and ps.edi_pickslip = 'Y'
   </if> 
               
  UNION ALL
  SELECT DP.CUSTOMER_ID,
         DP.PICKSLIP_ID,
         DP.TOTAL_QUANTITY_ORDERED,
         DP.TOTAL_DOLLARS_ORDERED,
         DP.CUSTOMER_DIST_CENTER_ID AS CUSTOMER_DC_ID,
         DP.CUSTOMER_STORE_ID
    FROM DEM_PICKSLIP DP
   WHERE 1=1
       <if c="$vas"> AND 1=2</if>     
     <if>AND DP.CUSTOMER_ORDER_ID = :po_id</if>
            <if c="$Customer_id">And DP.Customer_id = :Customer_id</if>
            <if c="$FromDate">AND DP.pickslip_import_date &gt;= :FromDate AND DP.pickslip_import_date &lt; :ToDate + 1</if>
            <if>AND DP.vwh_id = :vwh_id</if>
            <if>AND DP.dc_cancel_date &gt;= :from_dc_cancel_date</if>
            <if>AND DP.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
            <if>AND DP.pickslip_prefix = :pickslip_prefix</if>
            <if>AND DP.PICKSLIP_TYPE = :label_id</if>
            <if>AND dp.delivery_date &gt;= :from_delivery_date</if>
            <if>AND dp.delivery_date &lt; :to_delivery_date +1</if>
            <if c="$reporting_status != 'IN ORDER BUCKET'">AND 1=2</if>
            <else>AND DP.PS_STATUS_ID = '1'</else>
            <if c="$customer_dc_id">AND DP.customer_dist_center_id =:customer_dc_id</if>
            <if c="$customer_store_id">AND DP.Customer_Store_Id =:customer_store_id</if>
            <if c="$customer_type='D'">AND DP.export_flag IS NULL</if>
            <if c="$customer_type='I'">AND DP.export_flag = 'Y'</if>  
            <if>AND <a pre="NVL(dp.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if> 
            )
SELECT Q1.CUSTOMER_ID, 
       MAX(C.NAME) AS CUSTOMER_NAME,
       COUNT(UNIQUE Q1.PICKSLIP_ID) AS PICKSLIP_COUNT,
       SUM(Q1.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
       SUM(Q1.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
       COUNT(UNIQUE CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
       COUNT(UNIQUE CUSTOMER_STORE_ID) AS CUSTOMER_STORE_ID
  FROM Q1
  LEFT OUTER JOIN CUST C ON Q1.CUSTOMER_ID = C.CUSTOMER_ID
  WHERE 1=1
                      <if c="$order_type='D' and contains($restrict_type, 'R')">ANd account_type NOT IN ('RTL')</if>      
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND account_type NOT IN ('IDC')</if>  
 GROUP BY Q1.CUSTOMER_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbpo_id" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbCustomer_id" Type="String" Direction="Input" Name="Customer_id" />
            <asp:ControlParameter ControlID="dtShip_Date" Type="DateTime" Direction="Input" Name="ship_date" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FromDate" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="ToDate" />
            <asp:ControlParameter ControlID="dtfromdeliverydate" Type="DateTime" Direction="Input" Name="from_delivery_date" />
            <asp:ControlParameter ControlID="dttodeliverydate" Type="DateTime" Direction="Input" Name="to_delivery_date" />
            <asp:ControlParameter ControlID="ctlVwh_id" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter Name="from_dc_cancel_date" Type="DateTime" Direction="Input" ControlID="dtFromDcCancel" />
            <asp:ControlParameter Name="to_dc_cancel_date" Type="DateTime" Direction="Input" ControlID="dtToDcCancel" />
            <asp:ControlParameter Name="label_id" Type="String" Direction="Input" ControlID="ctlLabelSelector" />
            <asp:ControlParameter Name="customer_type" Type="String" Direction="Input" ControlID="rblOrderType" />
            <asp:QueryStringParameter Name="iteration" Direction="Input" Type="Int16" QueryStringField="iteration" />
            <asp:ControlParameter Name="reporting_status" Direction="Input" Type="String" ControlID="ddlStatus" />
            <asp:ControlParameter Name="warehouse_location_id" Direction="Input" Type="String" ControlID="ctlWhLoc" />
            <asp:QueryStringParameter Name="pickslip_prefix" Direction="Input" Type="String" QueryStringField="pickslip_prefix" />
            <asp:QueryStringParameter Name="customer_store_id" Direction="Input" Type="String" QueryStringField="customer_store_id" />
            <asp:QueryStringParameter Name="customer_dc_id" Direction="Input" Type="String" QueryStringField="customer_dc_id" />
            <asp:QueryStringParameter Name="order_type" Direction="Input" Type="String" QueryStringField="order_type" />
            <asp:QueryStringParameter Name="restrict_type" Direction="Input" Type="String" QueryStringField="restrict_type" />
            <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
            <asp:ControlParameter ControlID="chkOrderRequiredRouting" Type="String" Direction="Input" Name="unrouted" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
        id="div1" visible="false">
        <i>Summary of the customers</i>
    </div>
    <jquery:GridViewEx ID="gv1" runat="server" DataSourceID="ds1" DefaultSortExpression="CUSTOMER_ID;"
        AutoGenerateColumns="false" AllowSorting="false" ShowFooter="true" OnRowDataBound="gv1_RowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="CUSTOMER_ID,CUSTOMER_NAME" HeaderText="Customer" HeaderToolTip="Shows ID and name of the customer."
                SortExpression="CUSTOMER_ID" DataFormatString="{0} : {1}" />
            <eclipse:MultiBoundField DataFields="PICKSLIP_COUNT" HeaderText="No. Of Pickslip" HeaderToolTip="Total no. of pickslip of the customer"
                SortExpression="PICKSLIP_COUNT" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" />
            <eclipse:MultiBoundField DataFields="TOTAL_QUANTITY_ORDERED" HeaderText="Ordered|Pieces" HeaderToolTip="Total ordered pieces of the customer"
                SortExpression="TOTAL_QUANTITY_ORDERED" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" />
            <eclipse:MultiBoundField DataFields="TOTAL_DOLLARS_ORDERED" HeaderText="Ordered|Dollars" HeaderToolTip="Total amount of the customer."
                SortExpression="TOTAL_DOLLARS_ORDERED" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFooterFormatString="{0:C0}" DataFormatString="{0:C0}" DataSummaryCalculation="ValueSummation" />
            <eclipse:MultiBoundField DataFields="CUSTOMER_DC_ID" HeaderText="No. Of Customer|DCs" HeaderToolTip="Total no. of DC" ItemStyle-HorizontalAlign="Right"
                SortExpression="CUSTOMER_DC_ID" />
            <eclipse:MultiBoundField DataFields="CUSTOMER_STORE_ID" HeaderText="No. Of Customer|Stores" HeaderToolTip="Total no. of store." ItemStyle-HorizontalAlign="Right"
                SortExpression="CUSTOMER_STORE_ID" />
        </Columns>
    </jquery:GridViewEx>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader"
        CancelSelectOnNullParameter="false">
        <SelectSql>
  WITH OPEN_PICKSLIP_DATA AS
 (SELECT PS.PICKSLIP_ID            AS PICKSLIP_ID,
         PS.PO_ID                  AS PO_ID,
         PS.CUSTOMER_ID            AS CUSTOMER_ID,
         PS.CUSTOMER_STORE_ID      AS CUSTOMER_STORE_ID,
         PS.CUSTOMER_DC_ID         AS CUSTOMER_DC_ID,
         PS.REPORTING_STATUS       AS REPORTING_STATUS,
         PS.PRINT_DATE             AS PRINT_DATE,
         PS.ONLOT_NUMBER           AS ONLOT_NUMBER,
         PS.VWH_ID                 AS VWH_ID,
         PO.START_DATE             AS START_DATE,
         PO.DC_CANCEL_DATE         AS DC_CANCEL_DATE,
         PO.CANCEL_DATE            AS CANCEL_DATE,
         PS.TOTAL_QUANTITY_ORDERED AS TOTAL_QUANTITY_ORDERED,
         PS.TOTAL_DOLLARS_ORDERED  AS TOTAL_DOLLARS_ORDERED,
         PS.WAREHOUSE_LOCATION_ID  AS WAREHOUSE_LOCATION_ID,
         PD.UPC_CODE               AS UPC_CODE,
         PS.BUCKET_ID              AS BUCKET_ID,
         PS.SALES_ORDER_ID         AS STO
    FROM PS
   left outer JOIN PO
      ON PS.PO_ID = PO.PO_ID
     AND PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.ITERATION = PO.ITERATION
   left outer JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
   <if c="$ship_date">left outer join ship ship on ps.shipping_id = ship.shipping_id</if>
   WHERE PS.TRANSFER_DATE IS NULL
     and PD.transfer_date is null 
     and PS.pickslip_cancel_date is null
    <if>AND ps.po_id = :po_id</if>
            <if c="$Customer_id">And ps.Customer_id = :Customer_id</if>
            <if c="$FromDate">AND ps.pickslip_import_date &gt;= :FromDate AND ps.pickslip_import_date &lt; :ToDate + 1</if>
	        <if c="$ship_date">AND ship.ship_date &gt;= :ship_date</if>
            <if c="$ship_date">AND ship.ship_date &lt; :ship_date + 1</if>
            <if>AND PO.START_DATE &gt;= :from_delivery_date</if>
            <if>AND PO.START_DATE &lt; :to_delivery_date + 1</if>
            <if>AND ps.vwh_id = :vwh_id</if>
            <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
            <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>
            <if>AND ps.iteration = :iteration</if>
            <if>AND po.dc_cancel_date &gt;= :from_dc_cancel_date</if>
            <if>AND po.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
            <if>AND ps.pickslip_prefix = :pickslip_prefix</if>
            <if>AND ps.label_id = :label_id</if>
            <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
            <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
            <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>
             <if c="$customer_dc_id">AND ps.customer_dc_id = :customer_dc_id</if> 
            <if c="$customer_store_id">AND ps.customer_store_id = :customer_store_id</if>
            <if c="$unrouted"> and not exists (select 1
                            from edi_753_754_ps eps
                             where eps.pickslip_id = ps.pickslip_id
                               and eps.Edi753_Sent_On is not null)
                            and ps.edi_pickslip = 'Y'
            </if>  

  UNION ALL
  SELECT DP.PICKSLIP_ID AS PICKSLIP_ID,
         DP.CUSTOMER_ORDER_ID AS PO_ID,
         DP.CUSTOMER_ID AS CUSTOMER_ID,
         DP.CUSTOMER_STORE_ID AS CUSTOMER_STORE_ID,
         DP.CUSTOMER_DIST_CENTER_ID AS CUSTOMER_DC_ID,
         'IN ORDER BUCKET' AS REPORTING_STATUS,
         DP.PRINT_DATE AS PRINT_DATE,
         DP.ONLOT_NUMBER AS ONLOT_NUMBER,
         DP.VWH_ID AS VWH_ID,
         DP.DELIVERY_DATE AS START_DATE,
         DP.DC_CANCEL_DATE AS DC_CANCEL_DATE,
         DP.CANCEL_DATE AS CANCEL_DATE,
         DP.TOTAL_QUANTITY_ORDERED AS TOTAL_QUANTITY_ORDERED,
         DP.TOTAL_DOLLARS_ORDERED AS TOTAL_DOLLARS_ORDERED,
         DP.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
         DPD.UPC_CODE AS UPC_CODE,
         NULL AS BUCKET_ID,
         DP.SALES_ORDER_ID AS STO
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DP.PICKSLIP_ID = DPD.PICKSLIP_ID
   WHERE 1 = 1
         <if c="$vas"> AND 1=2</if>
     <if>AND dp.delivery_date &gt;= :from_delivery_date</if>
    <if>AND dp.delivery_date &lt; :to_delivery_date + 1</if>
            <if>AND DP.CUSTOMER_ORDER_ID = :po_id</if>
            <if c="$Customer_id">And DP.Customer_id = :Customer_id</if>
            <if c="$FromDate">AND DP.pickslip_import_date &gt;= :FromDate AND DP.pickslip_import_date &lt; :ToDate + 1</if>
            <if>AND DP.vwh_id = :vwh_id</if>
            <if>AND DP.dc_cancel_date &gt;= :from_dc_cancel_date</if>
            <if>AND DP.dc_cancel_date &lt; :to_dc_cancel_date+1</if>
            <if>AND DP.pickslip_prefix = :pickslip_prefix</if>
            <if>AND DP.PICKSLIP_TYPE = :label_id</if>
            <if c="$reporting_status != 'IN ORDER BUCKET'">AND 1=2</if>
            <else>AND DP.PS_STATUS_ID = '1'</else>
            <if c="$customer_type='D'">AND DP.export_flag IS NULL</if>
            <if c="$customer_type='I'">AND DP.export_flag = 'Y'</if>  
            <if c="$customer_dc_id">AND DP.customer_dist_center_id =:customer_dc_id</if>
            <if c="$customer_store_id">AND DP.Customer_Store_Id =:customer_store_id</if>
            <if>AND <a pre="NVL(dp.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if> 
                 ),
PICKSLIP_DETAIL AS
 (SELECT OPD.PICKSLIP_ID,
         MAX(OPD.STO) AS STO,
         COUNT(UNIQUE OPD.UPC_CODE) AS UPC_CODE,
         MIN(OPD.PO_ID) AS PO_ID,
         MIN(OPD.CUSTOMER_ID) AS CUSTOMER_ID,
         MIN(C.NAME) AS CUSTOMER_NAME,
         MIN(OPD.CUSTOMER_STORE_ID) AS CUSTOMER_STORE_ID,
         MIN(OPD.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         MIN(OPD.REPORTING_STATUS) AS REPORTING_STATUS,
         MIN(OPD.PRINT_DATE) AS PRINT_DATE,
         MIN(OPD.ONLOT_NUMBER) AS ONLOT_NUMBER,
         MIN(OPD.VWH_ID) AS VWH_ID,
         MIN(OPD.START_DATE) AS START_DATE,
         MIN(OPD.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MIN(OPD.CANCEL_DATE) AS CANCEL_DATE,
         MIN(OPD.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID,
         MAX(OPD.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
         MAX(OPD.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         RTRIM(SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION,
                                      (TV.DESCRIPTION || ', '),
                                      ''))),
               ', ') AS VAS,
         MAX(OPD.BUCKET_ID) AS BUCKET_ID
    FROM OPEN_PICKSLIP_DATA OPD
    LEFT OUTER JOIN PS_VAS PV
      ON OPD.PICKSLIP_ID = PV.PICKSLIP_ID
    LEFT OUTER JOIN TAB_VAS TV
      ON PV.VAS_ID = TV.VAS_CODE
    LEFT OUTER JOIN CUST C
      ON OPD.CUSTOMER_ID = C.CUSTOMER_ID
  WHERE 1=1
      <if c="$vas"> 
                and pv.vas_id is not null        
                 <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
             </if>
           <if c="$order_type='D' and contains($restrict_type, 'R')">ANd account_type NOT IN ('RTL')</if>      
     <if c="$order_type='D' and contains($restrict_type, 'I')">AND account_type NOT IN ('IDC')</if>   
   GROUP BY OPD.PICKSLIP_ID),
BOX_DETAIL AS
 (SELECT MAX(B.PICKSLIP_ID) AS PICKSLIP_ID,
         B.UCC128_ID AS UCC128_ID,
         SUM(BD.CURRENT_PIECES) AS TOTAL_PIECES_IN_BOX,
         SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) AS ESTIMATED_DOLLARS,
         MAX(SC.EMPTY_WT) +
         SUM((MSKU.WEIGHT_PER_DOZEN / 12) * NVL(BD.CURRENT_PIECES,bd.expected_pieces)) AS TOTAL_BOX_WEIGHT,
         MAX(SC.OUTER_CUBE_VOLUME) AS BOX_VOLUME
    FROM BOX B
   INNER JOIN SKUCASE SC
      ON B.CASE_ID = SC.CASE_ID
   INNER JOIN PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN MASTER_SKU MSKU
      ON BD.SKU_ID = MSKU.SKU_ID
   WHERE ps.transfer_date is null 
     AND  B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
      <if>AND ps.vwh_id = :vwh_id</if>
            <if c="$reporting_status != 'IN ORDER BUCKET'">AND PS.REPORTING_STATUS=:reporting_status</if>
            <if c="$reporting_status = 'IN ORDER BUCKET'">AND 1 = 2</if>
            <if>AND ps.iteration = :iteration</if>
              <if>AND ps.po_id = :po_id</if>
            <if c="$Customer_id">And ps.Customer_id = :Customer_id</if>
            <if>AND ps.pickslip_prefix = :pickslip_prefix</if>
            <if>AND ps.label_id = :label_id</if>
            <if>AND ps.vwh_id = :vwh_id</if>
            <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
            <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
            <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>
             <if c="$customer_dc_id">AND ps.customer_dc_id = :customer_dc_id</if> 
            <if c="$customer_store_id">AND ps.customer_store_id = :customer_store_id</if>
   GROUP BY B.UCC128_ID)
SELECT PDET.PICKSLIP_ID as pickslip_id,
       max(PDET.STO) AS STO,
       MAX(PDET.UPC_CODE) AS TOTAL_UPC,
       MAX(PDET.PO_ID) as po_id,
       MAX(PDET.CUSTOMER_ID) as customer_id,
       MAX(PDET.CUSTOMER_NAME) as customer_name,
       MAX(PDET.CUSTOMER_STORE_ID) as customer_store_id,
       MAX(PDET.CUSTOMER_DC_ID) as customer_dc_id,
       MAX(PDET.REPORTING_STATUS) as reporting_status,
       MAX(PDET.PRINT_DATE) as print_date,
       MAX(PDET.ONLOT_NUMBER) as onlot_number,
       MAX(PDET.VWH_ID) as vwh_id,
       MAX(PDET.START_DATE) as start_date,
       MAX(PDET.DC_CANCEL_DATE) as dc_cancel_date,
       MAX(PDET.CANCEL_DATE) as cancel_date,
       MAX(PDET.WAREHOUSE_LOCATION_ID) as warehouse_location_id,
       MAX(PDET.VAS) as vas,
       MAX(PDET.TOTAL_QUANTITY_ORDERED) as total_quantity_ordered,
       MAX(PDET.TOTAL_DOLLARS_ORDERED) as total_dollars_ordered,
       MAX(PDET.BUCKET_ID) as bucket_id,
       COUNT(UNIQUE BDET.UCC128_ID) AS TOTAL_PICKSLIP_BOXES,
       SUM(BDET.TOTAL_PIECES_IN_BOX) AS TOTAL_PIECES_IN_PICKSLIP,
       SUM(BDET.ESTIMATED_DOLLARS) AS TOTAL_ESTIMATED_DOLLARS,
       ROUND(SUM(BDET.TOTAL_BOX_WEIGHT), 4) AS TOTAL_PICKSLIP_WEIGHT,
       ROUND(SUM(BDET.BOX_VOLUME), 4) AS PICKSLIP_VOLUME
  FROM PICKSLIP_DETAIL PDET
  LEFT OUTER JOIN BOX_DETAIL BDET
    ON PDET.PICKSLIP_ID = BDET.PICKSLIP_ID
 GROUP BY PDET.PICKSLIP_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbpo_id" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbCustomer_id" Type="String" Direction="Input" Name="Customer_id" />
            <asp:ControlParameter ControlID="dtShip_Date" Type="DateTime" Direction="Input" Name="ship_date" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FromDate" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="ToDate" />
            <asp:ControlParameter ControlID="dtfromdeliverydate" Type="DateTime" Direction="Input" Name="from_delivery_date" />
            <asp:ControlParameter ControlID="dttodeliverydate" Type="DateTime" Direction="Input" Name="to_delivery_date" />
            <asp:ControlParameter ControlID="ctlVwh_id" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter Name="from_dc_cancel_date" Type="DateTime" Direction="Input" ControlID="dtFromDcCancel" />
            <asp:ControlParameter Name="to_dc_cancel_date" Type="DateTime" Direction="Input" ControlID="dtToDcCancel" />
            <asp:ControlParameter Name="label_id" Type="String" Direction="Input" ControlID="ctlLabelSelector" />
            <asp:ControlParameter Name="customer_type" Type="String" Direction="Input" ControlID="rblOrderType" />
            <asp:ControlParameter Name="reporting_status" Direction="Input" Type="String" ControlID="ddlStatus" />
            <asp:ControlParameter Name="warehouse_location_id" Direction="Input" Type="String" ControlID="ctlWhLoc" />
            <asp:QueryStringParameter Name="pickslip_prefix" Direction="Input" Type="String" QueryStringField="pickslip_prefix" />
            <asp:QueryStringParameter Name="customer_store_id" Direction="Input" Type="String" QueryStringField="customer_store_id" />
            <asp:QueryStringParameter Name="customer_dc_id" Direction="Input" Type="String" QueryStringField="customer_dc_id" />
            <asp:QueryStringParameter Name="order_type" Direction="Input" Type="String" QueryStringField="order_type" />
            <asp:QueryStringParameter Name="restrict_type" Direction="Input" Type="String" QueryStringField="restrict_type" />
            <asp:QueryStringParameter Name="iteration" Direction="Input" Type="Int16" QueryStringField="iteration" />
            <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
        <asp:ControlParameter ControlID="chkOrderRequiredRouting" Type="String" Direction="Input" Name="unrouted" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
        id="div2" visible="false">
        <i>Details of the customer</i>
    </div>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="WAREHOUSE_LOCATION_ID;customer_id;reporting_status;$;PICKSLIP_ID"
        AutoGenerateColumns="false" AllowSorting="true" AllowPaging="true" PageSize="1000" PagerSettings-Visible="false" CaptionAlign="Top" Caption="List Of Pickslips(Showing only 1000 rows but while exporting data to excel all rows resulting from the applied filters will get exported.)" ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building" HeaderToolTip="Building of the pickslip"
                SortExpression="WAREHOUSE_LOCATION_ID" ItemStyle-Font-Bold="true" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="Vwh" HeaderToolTip="Virtual warehouse of the pickslip"
                SortExpression="VWH_ID" />
            <eclipse:MultiBoundField DataFields="customer_id,CUSTOMER_NAME" HeaderText="Customer" SortExpression="customer_id"
                DataFormatString="{0} :   {1}" ItemStyle-Font-Bold="true" HeaderToolTip="Shows ID and name of the customer." />
            <eclipse:SiteHyperLinkField DataTextField="pickslip_id" HeaderText="Pickslip" SortExpression="pickslip_id" HeaderToolTip="Pickslip ID"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFields="pickslip_id,customer_id,warehouse_location_id"
                DataNavigateUrlFormatString="R110_03.aspx?pickslip_id={0}&customer_id={1}&warehouse_location_id={2}" />
            <eclipse:SiteHyperLinkField DataTextField="PO_ID" HeaderText="PO" SortExpression="PO_ID" HeaderToolTip="Purchase Order"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFields="po_id,customer_id"
                DataNavigateUrlFormatString="R110_09.aspx?po_id={0}&customer_id={1}" />
            <eclipse:MultiBoundField DataFields="STO" HideEmptyColumn="true" HeaderStyle-Wrap="false" HeaderText="PO Attrib 1" HeaderToolTip="PO's attribute # 1" SortExpression="STO" />
            <eclipse:MultiBoundField DataFields="VAS" HideEmptyColumn="true" HeaderText="VAS" HeaderToolTip="Value Added Service Required"
                SortExpression="VAS" />
            <eclipse:MultiBoundField DataFields="TOTAL_QUANTITY_ORDERED" HeaderText="Ordered|Pieces" DataFormatString="{0:N0}" HeaderToolTip="Total pieces of pickslip"
                SortExpression="TOTAL_QUANTITY_ORDERED" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="TOTAL_DOLLARS_ORDERED" HeaderText="Ordered|Dollars" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C0}" DataFormatString="{0:C0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                SortExpression="TOTAL_DOLLARS_ORDERED" HeaderToolTip="Total dollars of the quantity ordered" />
            <eclipse:MultiBoundField DataFields="TOTAL_PICKSLIP_BOXES" HeaderText="No. Of Boxes" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                SortExpression="TOTAL_PICKSLIP_BOXES" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" HeaderToolTip="Total No. Of boxes of the Pickslip" />
            <eclipse:MultiBoundField DataFields="TOTAL_PIECES_IN_PICKSLIP" HeaderText="In Box|Pieces" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                SortExpression="TOTAL_PIECES_IN_PICKSLIP" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" HeaderToolTip="Pieces packed in the box." />
            <eclipse:MultiBoundField DataFields="TOTAL_ESTIMATED_DOLLARS" HeaderText="In Box|Dollars" DataFormatString="{0:C0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                SortExpression="TOTAL_ESTIMATED_DOLLARS" HeaderToolTip="Total estimated dollars of the pickslip." />
            <eclipse:MultiBoundField DataFields="customer_store_id" HeaderText="Customer|Store" HeaderToolTip="Store id for the customer."
                SortExpression="customer_store_id" />
            <eclipse:MultiBoundField DataFields="customer_dc_id" HeaderText="Customer|DC" SortExpression="customer_dc_id" HeaderToolTip="Dc of the customer" />
            <eclipse:MultiBoundField DataFields="reporting_status" HeaderText="Status" SortExpression="reporting_status" ItemStyle-Font-Bold="true" HeaderToolTip="Reporting status of the pickslip." />
            <eclipse:MultiBoundField DataFields="start_date" HeaderText="Date|Delivery" DataFormatString="{0:d}" HeaderToolTip="The expected delivery date of the order."
                SortExpression="start_date" />
            <eclipse:MultiBoundField DataFields="dc_cancel_date" HeaderText="Date|DC Cancel" HeaderToolTip="Cancel date of the order"
                DataFormatString="{0:d}" SortExpression="dc_cancel_date" />
            <eclipse:MultiBoundField DataFields="cancel_date" HeaderText="Date|Cancel" DataFormatString="{0:d}"
                SortExpression="cancel_date" HeaderToolTip="Order Cancel Date" />
            <eclipse:MultiBoundField DataFields="print_date" HeaderText="Date|Print" DataFormatString="{0:d}"
                SortExpression="print_date" HeaderToolTip="Pickslip print date" />
            <eclipse:MultiBoundField DataFields="onlot_number" HeaderText="ONLOT Number" SortExpression="onlot_number" HeaderToolTip="">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="BUCKET_ID" HeaderText="Bucket" SortExpression="BUCKET_ID" HeaderToolTip="Bucket Number" />
            <eclipse:MultiBoundField DataFields="PICKSLIP_VOLUME" HeaderText="Volume" DataFormatString="{0:N4}" SortExpression="PICKSLIP_VOLUME" HeaderToolTip="Volume of the Pickslip" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="TOTAL_PICKSLIP_WEIGHT" HeaderText="Weight" DataFormatString="{0:N4}" SortExpression="TOTAL_PICKSLIP_WEIGHT" HeaderToolTip="Weight of the Pickslip" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="TOTAL_UPC" HeaderText="No. Of SKUs" SortExpression="TOTAL_UPC"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFields="pickslip_id,customer_id,reporting_status" DataTextFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                DataNavigateUrlFormatString="R110_104.aspx?pickslip_id={0}&customer_id={1}&reporting_status={2}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="This column is showing number of SKUs pickslip wise." />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

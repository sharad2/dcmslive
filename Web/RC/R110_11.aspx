<%@ Page Title="Active orders for a given Start Date or DC Cancel Date" Language="C#"
    MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4224 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R110_11.aspx $
 *  $Id: R110_11.aspx 4224 2012-08-14 13:06:59Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">

    [WebMethod]
    public static AutoCompleteItem[] GetCustomers(string term)
    {

        AutoCompleteItem[] items;

        using (OracleDataSource ds = new OracleDataSource())
        {
            ds.ConnectionString = ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString;
            ds.ProviderName = ConfigurationManager.ConnectionStrings["dcmslive"].ProviderName;
            ds.SysContext.ModuleName = "Customer Selector";

            ds.SelectSql = @"
                select cust.customer_id as customer_id, 
                       cust.name as customer_name
                from cust cust
                where 1 = 1
                <if c='$keywords'>AND (cust.customer_id like '%' || CAST(:keywords as VARCHAR2(25)) || '%' or UPPER(cust.name) like '%' || upper(CAST(:keywords as VARCHAR2(25))) || '%')</if>
                ";

            string[] tokens = term.Split(',');
            ds.SelectParameters.Add("keywords", TypeCode.String, tokens[tokens.Length - 1].Trim());

            items = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                     select new AutoCompleteItem()
                     {
                         Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_id"), DataBinder.Eval(cst, "customer_name")),
                         Value = DataBinder.Eval(cst, "customer_id", "{0}")
                     }).Take(20).ToArray();
        }
        return items;
    }
    [WebMethod]
    public static AutoCompleteItem[] GetLabels(string term)
    {

        AutoCompleteItem[] items;

        using (OracleDataSource ds = new OracleDataSource())
        {
            ds.ConnectionString = ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString;
            ds.ProviderName = ConfigurationManager.ConnectionStrings["dcmslive"].ProviderName;
            ds.SysContext.ModuleName = "Label Selector";

            ds.SelectSql = @"
                SELECT tsl.label_id as label_id, tsl.label_id ||' - ' || tsl.description as description
                FROM tab_style_label tsl
               WHERE tsl.inactive_flag IS NULL 
                <if c='$keywords'>AND (tsl.label_id like '%' || CAST(:keywords as VARCHAR2(25)) || '%' or UPPER(tsl.description) like '%' || upper(CAST(:keywords as VARCHAR2(25))) || '%')</if>
                ORDER BY tsl.description
                ";

            string[] tokens = term.Split(',');
            ds.SelectParameters.Add("keywords", TypeCode.String, tokens[tokens.Length - 1].Trim());

            items = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                     select new AutoCompleteItem()
                     {
                         Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "label_id"), DataBinder.Eval(cst, "description")),
                         Value = DataBinder.Eval(cst, "label_id", "{0}")
                     }).Take(20).ToArray();
        }
        return items;
    }
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //sets  first date of previous year           
            string str = DateTime.Now.AddDays(7).ToShortDateString();
            if (!string.IsNullOrEmpty(dtTo1.Text))
            {
                // Do not modify date if it is being passed via query string
                dtTo1.Text = str;
            }
            if (!string.IsNullOrEmpty(dtTo.Text))
            {
                dtTo.Text = str;
            }
        }
        base.OnLoad(e);
    }
 
</script>
<%--mutually exclusive pattern--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays list of Active orders for passed DC Cancel date or Start date on the basis of Export or domestic orders and optionally for a Label ID and Virtual Warehouse. The user has option to filter out the data on the basis of selecting the value of customer group or for the specific customer or exclude specific customer." />
    <meta name="ReportId" content="110.11" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="A new filter for Start Date has been provided, report can be run either for Start Date or for DC Cancel Date.|Report can be run for all customers.
     |Report shows Import Date instead of Min or Max PD_import_date columns because whole PO should import in a day.|Check mark was displayed if PO contains SKUs of PopPant label, Instead of this now we are showing Label for all POs|Expand and Collapse buttons are removed.
     |Customer filter is enhanced, customer can be selected by typing either customer name or customer ID"/>
    <meta name="Version" content="$Id: R110_11.aspx 4224 2012-08-14 13:06:59Z skumar $" />
    <script type="text/javascript">
        function tbCustomer_OnSelect(event, ui) {
            //   this.value = this.value.split(/,\s*/).pop();           
            var terms = this.value.split(/,\s*/);
            // remove the current input
            terms.pop();
            // add the selected item
            terms.push(ui.item.Value);
            // add placeholder to get the comma-and-space at the end
            terms.push("");
            this.value = terms.join(", ");
            return false;
        }
        function tbExcludeCustomer_OnSelect(event, ui) {
            //   this.value = this.value.split(/,\s*/).pop();           
            var terms = this.value.split(/,\s*/);
            // remove the current input
            terms.pop();
            // add the selected item
            terms.push(ui.item.Value);
            // add placeholder to get the comma-and-space at the end
            terms.push("");
            this.value = terms.join(", ");
            return false;
        }
        function tbLabels_OnSelect(event, ui) {
            //   this.value = this.value.split(/,\s*/).pop();           
            var terms = this.value.split(/,\s*/);
            // remove the current input
            terms.pop();
            // add the selected item
            terms.push(ui.item.Value);
            // add placeholder to get the comma-and-space at the end
            terms.push("");
            this.value = terms.join(", ");
            return false;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Customer Order Type" />
                <i:RadioButtonListEx runat="server" ID="rblOrderType" ToolTip="Choose Customer Order Type"
                    QueryString="order_type" Value="D">
                    <Items>
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                        <i:RadioItem Text="Both" Value="B" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftPanel ID="LeftPanel3" runat="server" Span="true">
                    <i:RadioButtonListEx runat="server" ID="rblOptions" Visible="false" Value="startDate" />
                </eclipse:LeftPanel>
                <eclipse:LeftPanel ID="LeftPanel4" runat="server">
                    <i:RadioItemProxy ID="rbItemStartDate" runat="server" Text="Start date" CheckedValue="startDate"
                        FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel ID="Panel1" runat="server">
                From
                    <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Start Date"
                        Text="0">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="startDate" />
                            <i:Required DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="startDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                    To
                    <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Start Date" Text="0">
                        <Validators>
                            <i:Date DateType="ToDate" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="startDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                </asp:Panel>
                From state date required when radio button is checked
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:RadioItemProxy runat="server" Text="Dc Cancel Date" ID="rbDcCancelDate" CheckedValue="dcCancelDate"
                        FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel runat="server" ID="p_receipt">
                From
                    <d:BusinessDateTextBox ID="dtFrom1" runat="server" FriendlyName="From Cancel Date"
                        Text="0">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="dcCancelDate" />
                            <i:Required DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="dcCancelDate" />
                        </Validators>
                        
                    </d:BusinessDateTextBox>
                   To 
                    <d:BusinessDateTextBox ID="dtTo1" runat="server" FriendlyName="To Cancel Date" Text="0">
                        <Validators>
                            <i:Date DateType="ToDate" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="dcCancelDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                </asp:Panel>
                From Dc Cancel date required when radio button is checked
                <eclipse:LeftLabel runat="server" />
                 <i:AutoComplete runat="server" ID="tbLabels" ClientIDMode="Static" WebMethod="GetLabels"
                    FriendlyName="Labels" QueryString="label_id" Delay="4000" OnClientSelect="tbLabels_OnSelect"
                    ToolTip="The label by which you see the information of customer order." Width="200">
                    <%--<Validators>
                        <i:Filter DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="I" />
                    </Validators>--%>
                </i:AutoComplete>
               <%-- <i:TextBoxEx ID="tbLabels" runat="server" ClientIDMode="Static" FriendlyName="Labels"
                    ToolTip="The label by which you see the information of customer order." QueryString="label_id"
                    CaseConversion="UpperCase">
                </i:TextBoxEx>
                <i:ButtonEx runat="server" Icon="Search" OnClientClick="function(e){
                $('#dlgLabelTypes').ajaxDialog('load');
                }" />--%>
                <br />
                You can pass multiple Label IDs separated by a comma (,).
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlvwh_id" runat="server" QueryString="vwh_id" ShowAll="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ToolTip="Virtual Warehouse">
                </d:VirtualWarehouseSelector>
                <i:RadioButtonListEx runat="server" ID="rblCustFilters" Value="custGroup" QueryString="customer_filter"
                    FriendlyName="Record For" ClientIDMode="Static" />
                <eclipse:LeftPanel ID="LeftLabel3" runat="server">
                    <i:RadioItemProxy runat="server" Text="Customer Group" QueryString="customer_filter"
                        CheckedValue="custGroup" />
                </eclipse:LeftPanel>
                <oracle:OracleDataSource ID="dsSpHandling" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %> ">
                    <SelectSql>                    
                      SELECT distinct customer_group_id as group_id FROM customer_group 
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlSpHandling" runat="server" DataSourceID="dsSpHandling"
                    DataFields="group_id" ToolTip="Special Group of Customer" FriendlyName="Customer Group">
                    <Items>
                        <eclipse:DropDownItem Text="All Customers" Value="" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Filter DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="custGroup" />
                    </Validators>
                </i:DropDownListEx2>
                <eclipse:LeftPanel runat="server">
                    <i:RadioItemProxy runat="server" Text="Specific Customers" QueryString="customer_filter"
                        CheckedValue="I" />
                </eclipse:LeftPanel>
                <i:AutoComplete runat="server" ID="tbCustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Specific Customers" QueryString="customer_id" Delay="1200" OnClientSelect="tbCustomer_OnSelect"
                    ToolTip="The customers whose purchase order you are interested in." Width="200">
                    <Validators>
                        <i:Filter DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="I" />
                        <i:Required DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="I" />
                    </Validators>
                </i:AutoComplete>
                <br />
                You can pass multiple Customer IDs separated by a comma (, ).
                <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <i:RadioItemProxy runat="server" Text="Exclude Customers" QueryString="customer_filter"
                        CheckedValue="E" />
                </eclipse:LeftPanel>
                <i:AutoComplete runat="server" ID="tbExcludeCustomers" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Exclude Customers" QueryString="customer_id" Delay="4000" OnClientSelect="tbExcludeCustomer_OnSelect"
                    ToolTip="The customers whose purchase order you are interested in." Width="200">
                    <Validators>
                        <i:Filter DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="E" />
                         <i:Required DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="E" />
                    </Validators>
                </i:AutoComplete>
                <br />
                You can pass multiple Customer IDs separated by a comma (,).
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
        ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
                   SELECT 
                     COUNT(ps.pickslip_id) AS no_of_pickslip,
                     ps.customer_id AS customer_id,
                     MAX(c.name) AS customer_name,
                     ps.po_id AS po_id,
                     ps.iteration AS iteration,
                     MAX(ps.pickslip_prefix) AS pickslip_prefix,
                     ps.label_id AS label_id,
                     SUM(ps.total_quantity_ordered) AS total_quantity_ordered,
                     SUM(round(ps.total_dollars_ordered)) AS total_dollars_ordered,
                     MIN(trunc(ps.pickslip_import_date)) AS min_pickslip_import_date,
                     MAX(trunc(ps.pickslip_import_date)) AS max_pickslip_import_date,
                     count(distinct trunc(ps.pickslip_import_date)) AS count_pickslip_import_date,
                     ps.reporting_status AS reporting_status,
                     MIN(po.start_date) AS delivery_date,
                     MIN(po.dc_cancel_date) AS dc_cancel_date,
                     MIN(po.cancel_date) AS cancel_date,
                     ps.vwh_id AS vwh_id
                FROM ps
               INNER JOIN po
                  ON ps.customer_id = po.customer_id
                 AND ps.po_id = po.po_id
                 AND ps.iteration = po.iteration
               INNER JOIN cust c
                  ON ps.customer_id = c.customer_id
               <if c="$group_id">INNER JOIN customer_group cg on ps.customer_id = cg.customer_id</if>
               WHERE ps.reporting_status IS NOT NULL
               and ps.transfer_date is null
               <if>AND po.dc_cancel_date &gt;= cast(:FromDate1 as date)
                 AND po.dc_cancel_date &lt; cast(:ToDate1 as date) +1</if>
                 <if>AND po.start_date &gt;= cast(:FromDate as date)
                 AND po.start_date &lt; cast(:ToDate as date) +1</if>
                 <a pre="AND ps.label_id in  (" sep="," post=")">:label_id</a>
                 <a pre="AND ps.customer_id in  (" sep="," post=")" >:IncludeCustomer</a>
                 <a pre="AND ps.customer_id not in  (" sep="," post=")">:ExcludeCustomer</a>
                 <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
                 <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>
                 <if c="$customer_type='B'"></if>
                 <if>AND ps.vwh_id= cast(:Vwh_id as varchar2(255))</if>
                 <if c="$group_id">AND (cg.attribute_customer_id IS NULL OR cg.attribute_customer_id = ps.attribute_customer_id)
                  AND (cg.customer_dc_id IS NULL OR cg.customer_dc_id = ps.customer_dc_id)
                  AND (cg.customer_store_id IS NULL OR cg.customer_store_id = ps.customer_store_id)
                  AND cg.customer_group_id = cast(:group_id as varchar2(255))</if>
               GROUP BY ps.reporting_status,
                        ps.customer_id,
                        ps.po_id,
                        ps.iteration,
                        ps.vwh_id,
                        ps.label_id
                UNION ALL
                SELECT /*+ INDEX (dps ps_pdstat_fk_i) */
                       COUNT(dps.pickslip_id) as no_of_pickslip,
                       dps.customer_id as customer_id,
                       MAX(ct.name)as customer_name,
                       dps.customer_order_id as po_id,
                       1 as iteration,
                       MAX(dps.pickslip_prefix)as pickslip_prefix,
                       dps.pickslip_type as label_id,
                       SUM(dps.total_quantity_ordered)as total_quantity_ordered,
                       SUM(round(dps.total_dollars_ordered))as total_dollars_ordered,
                       MIN(trunc(dps.pickslip_import_date))as min_pickslip_import_date,
                       MAX(trunc(dps.pickslip_import_date))as max_pickslip_import_date,
                       count(distinct trunc(dps.pickslip_import_date)) AS count_pickslip_import_date,
                       'IN ORDER BUCKET'as reporting_status,
                       MIN(dps.delivery_date) as delivery_date,
                       MIN(dps.dc_cancel_date) as dc_cancel_date,
                       MIN(dps.cancel_date) as cancel_date,
                       dps.vwh_id as vwh_id           
                  FROM dem_pickslip dps
                 INNER JOIN cust ct
                    ON dps.customer_id = ct.customer_id
                 <if c="$group_id">INNER JOIN customer_group cg on dps.customer_id = cg.customer_id </if>
                 WHERE dps.ps_status_id = 1
                   <if>AND dps.dc_cancel_date &gt;= cast(:FromDate1 as date)
                   AND dps.dc_cancel_date &lt; cast(:ToDate1 as date) +1</if>
                   <if>AND dps.delivery_date &gt;= cast(:FromDate as date)
                   AND dps.delivery_date &lt; cast(:ToDate as date) +1</if>
                   <a pre="AND dps.pickslip_type in (" sep="," post=")">:label_id</a>
                   <a pre="AND dps.customer_id in  (" sep="," post=")">:IncludeCustomer</a>
                   <a pre="AND dps.customer_id not in  (" sep="," post=")">:ExcludeCustomer</a>
                   <if c="$customer_type='D'">AND dps.export_flag IS NULL</if>
                   <if c="$customer_type='I'">AND dps.export_flag = 'Y'</if>
                   <if c="$customer_type='B'"></if>
                   <if>AND dps.vwh_id= cast(:Vwh_id as varchar2(255))</if>
                   <if c="$group_id"> AND cg.attribute_customer_id IS NULL
                    AND (cg.customer_dc_id IS NULL OR cg.customer_dc_id = dps.customer_dist_center_id)
                    AND (cg.customer_store_id IS NULL OR cg.customer_store_id = dps.customer_store_id)
                    AND cg.customer_group_id = cast(:group_id as varchar2(255))</if>
                 GROUP BY dps.customer_id,
                          dps.customer_order_id,
                          dps.pickslip_type,
                          dps.vwh_id
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbLabels" Type="String" Direction="Input" Name="label_id" PropertyName="Text" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FromDate" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="ToDate" />
            <asp:ControlParameter ControlID="dtFrom1" Type="DateTime" Direction="Input" Name="FromDate1" />
            <asp:ControlParameter ControlID="dtTo1" Type="DateTime" Direction="Input" Name="ToDate1" />
            <asp:ControlParameter ControlID="ctlvwh_id" Type="String" Direction="Input" Name="Vwh_id" />
            <asp:ControlParameter ControlID="rblOrderType" Type="String" Direction="Input" Name="customer_type" />
            <asp:ControlParameter ControlID="tbExcludeCustomers" Type="String" Direction="Input"
                Name="ExcludeCustomer"  PropertyName="Text" />
            <asp:ControlParameter ControlID="tbCustomer" Type="String" Direction="Input" Name="IncludeCustomer"
                PropertyName="Text" />
            <asp:ControlParameter ControlID="ddlSpHandling" Type="String" Direction="Input" Name="group_id" />
            <asp:Parameter Name="special_label_id" Type="String" DefaultValue="<%$  AppSettings: SpecialLabelId  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
    ShowExpandCollapseButtons="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="customer_name;customer_id;$;po_id;pickslip_prefix">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" SortExpression="vwh_id" HeaderText="VWh" />
            <eclipse:MultiBoundField DataFields="customer_id" HeaderText="Customer ID" SortExpression="customer_id" />
            <eclipse:MultiBoundField DataFields="customer_name" HeaderText="Customer Name" SortExpression="customer_name" />
            <eclipse:MultiBoundField DataFields="pickslip_prefix" HeaderText="Profile" SortExpression="pickslip_prefix" />
            <eclipse:MultiBoundField DataFields="po_id" HeaderText="PO" SortExpression="po_id" />
            <eclipse:MultiBoundField DataFields="reporting_status" HeaderText="Status" SortExpression="report_status_sequence" />
            <asp:TemplateField HeaderText="Date|Imported" HeaderStyle-Wrap="false" SortExpression="min_pickslip_import_date">
                <ItemTemplate>
                    <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="count_pickslip_import_date,min_pickslip_import_date,max_pickslip_import_date"
                        DataSingleValueFormatString="{1:d}" DataTwoValueFormatString="{1:d} and {2:d}"
                        DataMultiValueFormatString="{1:d} to {2:d}" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="delivery_date" HeaderText="Date|Start" SortExpression="delivery_date"
                DataFormatString="{0:d}" HeaderToolTip="Delivery Date Of Order" />
            <eclipse:MultiBoundField DataFields="dc_cancel_date" HeaderText="Date|DC Cancel"
                SortExpression="dc_cancel_date" DataFormatString="{0:d}" HeaderToolTip="DC Cancel date of Order" />
            <eclipse:SiteHyperLinkField DataTextField="no_of_pickslip" SortExpression="no_of_pickslip"
                DataSummaryCalculation="ValueSummation" HeaderText="#Pickslips" AppliedFiltersControlID="ctlButtonBar$af"
                DataNavigateUrlFormatString="R110_10.aspx?po_id={0}&customer_id={1}&vwh_id={2}&reporting_status={3}&pickslip_prefix={4}&iteration={5}&label_id={6}"
                DataNavigateUrlFields="po_id,customer_id,vwh_id,reporting_status,pickslip_prefix,iteration,label_id"
                DataTextFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="total_dollars_ordered" SortExpression="total_dollars_ordered"
                HeaderText="$Value" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:C0}"
                DataFormatString="{0:C0}" HeaderToolTip="Total Dollors ordered">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_quantity_ordered" HeaderText="Pieces Ordered"
                SortExpression="total_quantity_ordered" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" HeaderToolTip="Total Pieces ordered">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
             <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id" />
        </Columns>
    </jquery:GridViewEx>
    <jquery:Dialog ID="dlgLabelTypes" runat="server" DialogStyle="Picker" Width="750"
        AutoOpen="false" ClientIDMode="Static" Title="Select Label Type" Position="Top">
        <Ajax Url="~/PickersAndServices/LabelTypePicker.aspx" OnAjaxDialogLoading="function(e) {
        $(this).ajaxDialog('option', 'data', {label_id: $('#tbLabels').textBoxEx('getval')});        
                    }" OnAjaxDialogClosing="function(event,ui){
            $('#tbLabels').textBoxEx('setval', ui.data);
            }" />
        <Buttons>
            <jquery:RemoteSubmitButton RemoteButtonSelector="#ltp_btnGo" Text="Ok" />
            <jquery:CloseButton Text="Cancel" />
        </Buttons>
    </jquery:Dialog>
    <jquery:Dialog ID="dlgCustomerPicker" runat="server" DialogStyle="Picker" Width="420"
        AutoOpen="false" ClientIDMode="Static" Title="Select Customers" Position="Top">
        <Ajax Url="~/PickersAndServices/MultiCustomerPicker.aspx" OnAjaxDialogLoading="function(e) {
            $(this).ajaxDialog('option', 'data', {customer_list: $tb_customers.textBoxEx('getval')});
        }" OnAjaxDialogClosing="function(event,ui){
            $tb_customers.textBoxEx('setval', ui.data);
            $('#rblCustFilters').radioButtonListEx('setValue', _radioValue);
        }" />
        <Buttons>
            <jquery:RemoteSubmitButton RemoteButtonSelector="#btnMcpOk" Text="Ok" />
            <jquery:CloseButton Text="Cancel" />
        </Buttons>
    </jquery:Dialog>
</asp:Content>

<%@ Page Title="Active orders for a given Start Date or DC Cancel Date" Language="C#"
    MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7236 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_11.aspx $
 *  $Id: R110_11.aspx 7236 2014-11-07 09:27:07Z skumar $
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
    protected void tbExcludeCustomers_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (!string.IsNullOrEmpty(tbExcludeCustomers.Text))
        {
            e.ControlToValidate.IsValid = true;
            return;
        }
    }

    protected void tbCustomer_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (!string.IsNullOrEmpty(tbCustomer.Text))
        {
            e.ControlToValidate.IsValid = true;
            return;
        }
    }
</script>
<%--mutually exclusive pattern--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays list of Active orders for passed DC Cancel date or Start date on the basis of Export or domestic orders and optionally for a Label ID and Virtual Warehouse. The user has option to filter out the data on the basis of selecting the value of customer group or for the specific customer or exclude specific customer." />
    <meta name="ReportId" content="110.11" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Now report will show STO against a PO. This additional information will be displayed under a new column 'PO Attrib 1'." />
    <meta name="Version" content="$Id: R110_11.aspx 7236 2014-11-07 09:27:07Z skumar $" />
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
                        Text="0" QueryString="from_delivery_date">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="startDate" />
                            <i:Required DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="startDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                    To
                    <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Start Date" Text="0" QueryString="to_delivery_date">
                        <Validators>
                            <i:Date DateType="ToDate" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="startDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                </asp:Panel>
                From state date required when radio button is checked
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:RadioItemProxy runat="server" Text="DC Cancel Date" ID="rbDcCancelDate" CheckedValue="dcCancelDate"
                        FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel runat="server" ID="p_receipt">
                    From
                    <d:BusinessDateTextBox ID="dtFrom1" runat="server" FriendlyName="From Cancel Date" QueryString="from_dc_cancel_date"
                        Text="0">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="dcCancelDate" />
                            <i:Required DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="dcCancelDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                    To 
                    <d:BusinessDateTextBox ID="dtTo1" runat="server" FriendlyName="To Cancel Date" Text="0" QueryString="to_dc_cancel_date">
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
                </i:AutoComplete>
                <br />
                You can pass multiple Label IDs separated by a comma (,).
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlvwh_id" runat="server" QueryString="vwh_id" ShowAll="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ToolTip="Virtual Warehouse">
                </d:VirtualWarehouseSelector>
               
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
                     DataValueFormatString="{0}" ToolTip="Vas ID" FriendlyName="VAS TYPE" QueryString="vas_id">
                    <Items>
                        <eclipse:DropDownItem Text="All VAS" Value="vas" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Filter DependsOn="cbvas" DependsOnState="Value" DependsOnValue="Y" />
                    </Validators>
                </i:DropDownListEx2>
                 <br />
                           If you want to see orders that require some specific VAS then please choose it form this drop down list.

                <eclipse:LeftLabel runat="server" />
                <i:RadioButtonListEx runat="server" ID="rblCustFilters" Value="custGroup" QueryString="customer_filter"
                    FriendlyName="Record For" Visible="false" ClientIDMode="Static" />
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
                        CheckedValue="SC" />
                </eclipse:LeftPanel>

                <i:AutoComplete runat="server" ID="tbCustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Specific Customers" QueryString="customer_id" Delay="4000" OnClientSelect="tbCustomer_OnSelect"
                    ToolTip="The customers whose purchase order you are interested in." Width="200">
                    <Validators>
                        <i:Filter DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="SC" />
                        <i:Required DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="SC" OnServerValidate="tbCustomer_OnServerValidate" />
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
                        <i:Required DependsOn="rblCustFilters" DependsOnState="Value" DependsOnValue="E" OnServerValidate="tbExcludeCustomers_OnServerValidate" />
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
WITH Q1 AS
 (SELECT PS.PICKSLIP_ID,
         MAX(PS.SALES_ORDER_ID) AS STO,
         MAX(PS.CUSTOMER_ID) AS CUSTOMER_ID,
         MAX(PS.PO_ID) AS PO_ID,
         MAX(PS.LABEL_ID) AS LABEL_ID,
         MAX(PS.ITERATION) AS ITERATION,
         MAX(PS.PICKSLIP_PREFIX) AS PICKSLIP_PREFIX,
         MAX(PS.REPORTING_STATUS) AS REPORTING_STATUS,
         MAX(PS.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         MAX(PS.CUSTOMER_STORE_ID) AS CUSTOMER_STORE_ID,
         MAX(PS.ATTRIBUTE_CUSTOMER_ID) AS ATTRIBUTE_CUSTOMER_ID,
         MAX(PS.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
         MAX(PS.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         MAX(PS.PICKSLIP_IMPORT_DATE) AS PICKSLIP_IMPORT_DATE,
         MAX(PO.START_DATE) AS START_DATE,
         MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(PO.CANCEL_DATE) AS CANCEL_DATE,
         MAX(PS.VWH_ID) AS VWH_ID,
         PV.VAS_ID AS VAS_ID,
         MAX(TV.DESCRIPTION) AS VAS
    FROM PS
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN PS_VAS PV
      ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
    left outer JOIN tab_vas tv on
            pv.vas_id = tv.vas_CODE
   WHERE PS.TRANSFER_DATE IS NULL
       and ps.pickslip_cancel_date is null
   <if>AND po.dc_cancel_date &gt;= cast(:FromDate1 as date)
        AND po.dc_cancel_date &lt; cast(:ToDate1 as date) +1</if>
    <if>AND po.start_date &gt;= cast(:FromDate as date)
        AND po.start_date &lt; cast(:ToDate as date) +1</if>
    <if><a pre="AND ps.label_id in  (" sep="," post=")">:label_id</a></if>
    <if c="$custGroup='SC'"><a pre="AND ps.customer_id in  (" sep="," post=")" >:IncludeCustomer</a></if>
    <if c="$custGroup ='E'"><a pre="AND ps.customer_id not in  (" sep="," post=")">:ExcludeCustomer</a></if>
    <if c="$customer_type='D'">AND ps.export_flag IS NULL</if>
    <if c="$customer_type='I'">AND ps.export_flag = 'Y'</if>
    <if c="$customer_type='B'"></if>
    <if>AND ps.vwh_id= cast(:Vwh_id as varchar2(255))</if> 
    <if c="$vas"> 
        and pv.vas_id is not null        
    <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    </if>  
   GROUP BY PS.PICKSLIP_ID, PV.VAS_ID
  UNION ALL
  SELECT DP.PICKSLIP_ID,
         MAX(DP.SALES_ORDER_ID) AS STO,
            MAX(DP.CUSTOMER_ID) AS CUSTOMER_ID,
         MAX(DP.CUSTOMER_ORDER_ID) AS PO_ID,
         MAX(DP.PICKSLIP_TYPE) AS LABEL_ID,
         1 AS ITERATION,
         MAX(DP.PICKSLIP_PREFIX) AS PICKSLIP_PREFIX,
         'IN ORDER BUCKET' AS REPORTING_STATUS,
         MAX(DP.CUSTOMER_DIST_CENTER_ID) AS CUSTOMER_DC_ID,
         MAX(DP.CUSTOMER_STORE_ID) AS CUSTOMER_STORE_ID,
         NULL AS ATTRIBUTE_CUSTOMER_ID,
         MAX(DP.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
         MAX(DP.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         MAX(DP.PICKSLIP_IMPORT_DATE) AS PICKSLIP_IMPORT_DATE,
         MAX(DP.DELIVERY_DATE) AS START_DATE,
         MAX(DP.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(DP.CANCEL_DATE) AS CANCEL_DATE,
         MAX(DP.VWH_ID) AS VWH_ID,
         PV.VAS_ID  AS VAS_id,
         MAX(TV.DESCRIPTION) AS VAS
    FROM DEM_PICKSLIP DP
    LEFT OUTER JOIN PS_VAS PV
      ON DP.PICKSLIP_ID = PV.PICKSLIP_ID
    LEFT OUTER JOIN tab_vas tv on
            pv.vas_id = tv.vas_CODE
   WHERE DP.PS_STATUS_ID = 1
   <if>AND DP.dc_cancel_date &gt;= cast(:FromDate1 as date)
       AND DP.dc_cancel_date &lt; cast(:ToDate1 as date) +1</if>
   <if>AND DP.delivery_date &gt;= cast(:FromDate as date)
       AND DP.delivery_date &lt; cast(:ToDate as date) +1</if>
   <a pre="AND DP.pickslip_type in (" sep="," post=")">:label_id</a>
   <if c="$custGroup ='SC'"><a pre="AND DP.customer_id in  (" sep="," post=")">:IncludeCustomer</a></if>
   <if c="$custGroup ='E'"><a pre="AND DP.customer_id not in  (" sep="," post=")">:ExcludeCustomer</a></if>
   <if c="$customer_type='D'">AND DP.export_flag IS NULL</if>
   <if c="$customer_type='I'">AND DP.export_flag = 'Y'</if>
   <if c="$customer_type='B'"></if>          
   <if c="$vas"> 
       and pv.vas_id is not null        
   <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    </if>            
   <if>AND DP.vwh_id= cast(:Vwh_id as varchar2(255))</if>
   GROUP BY DP.PICKSLIP_ID, PV.VAS_ID)
SELECT Q1.CUSTOMER_ID,
       MAX(C.NAME) AS customer_name,
       Q1.PO_ID,
       Q1.ITERATION,
       Q1.LABEL_ID,
       Q1.REPORTING_STATUS,
       Q1.VWH_ID,
      CASE
         WHEN COUNT(UNIQUE Q1.STO) > 1 THEN
          '*****'
         ELSE
          TO_CHAR(MAX(Q1.STO))
       END AS STO,
       COUNT(DISTINCT Q1.pickslip_id) AS no_of_pickslip,
       MAX(Q1.PICKSLIP_PREFIX) AS PICKSLIP_PREFIX,
       SYS.STRAGG(UNIQUE(NVL2(q1.VAS, (Q1.VAS || ','), ''))) AS VAS,
       SUM(Q1.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
       SUM(ROUND(Q1.TOTAL_DOLLARS_ORDERED)) AS TOTAL_DOLLARS_ORDERED,
       MIN(TRUNC(Q1.PICKSLIP_IMPORT_DATE)) AS MIN_PICKSLIP_IMPORT_DATE,
       MAX(TRUNC(Q1.PICKSLIP_IMPORT_DATE)) AS MAX_PICKSLIP_IMPORT_DATE,
       COUNT(DISTINCT TRUNC(Q1.PICKSLIP_IMPORT_DATE)) AS COUNT_PICKSLIP_IMPORT_DATE,
       MIN(Q1.START_DATE) AS DELIVERY_DATE,
       MIN(Q1.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MIN(Q1.CANCEL_DATE) AS CANCEL_DATE
  FROM Q1
  LEFT OUTER JOIN CUST C
    ON Q1.CUSTOMER_ID = C.CUSTOMER_ID
  <if c="$group_id"> LEFT OUTER JOIN CUSTOMER_GROUP CG
    ON Q1.CUSTOMER_ID = CG.CUSTOMER_ID</if>
WHERE 1 = 1
<if c="$group_id">
AND (cg.attribute_customer_id IS NULL OR cg.attribute_customer_id = q1.attribute_customer_id)
AND (cg.customer_dc_id IS NULL OR cg.customer_dc_id = q1.customer_dc_id)
AND (cg.customer_store_id IS NULL OR cg.customer_store_id = q1.customer_store_id)
AND cg.customer_group_id = cast(:group_id as varchar2(255))</if>
 GROUP BY Q1.CUSTOMER_ID,
          Q1.PO_ID,
          Q1.ITERATION,
          Q1.LABEL_ID,
          Q1.REPORTING_STATUS,
          Q1.VWH_ID
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
                Name="ExcludeCustomer" PropertyName="Text" />
            <asp:ControlParameter ControlID="tbCustomer" Type="String" Direction="Input" Name="IncludeCustomer"
                PropertyName="Text" />
            <asp:ControlParameter ControlID="ddlSpHandling" Type="String" Direction="Input" Name="group_id" />
            <asp:ControlParameter ControlID="rblCustFilters" Type="String" Direction="Input" Name="custGroup" />
            <asp:Parameter Name="special_label_id" Type="String" DefaultValue="<%$  AppSettings: SpecialLabelId  %>" />

            <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        ShowExpandCollapseButtons="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="customer_id;$;po_id;pickslip_prefix">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" SortExpression="vwh_id" HeaderText="VWh" />
            <eclipse:MultiBoundField DataFields="customer_id,customer_name" HeaderText="Customer" SortExpression="customer_id"
                DataFormatString="{0} : {1}" ItemStyle-Font-Bold="true" />
            <%--<eclipse:MultiBoundField DataFields="customer_name" HeaderText="Customer Name" SortExpression="customer_name" />--%>
            <eclipse:MultiBoundField DataFields="pickslip_prefix" HeaderText="Profile" SortExpression="pickslip_prefix" />
            <eclipse:MultiBoundField DataFields="po_id" HeaderText="PO" SortExpression="po_id" />
            <eclipse:MultiBoundField DataFields="STO" HeaderText="PO Attrib 1" SortExpression="STO"  HeaderToolTip="PO's attribute # 1"/>
            <eclipse:MultiBoundField DataFields="reporting_status" HeaderText="Status" SortExpression="reporting_status" />
            <asp:TemplateField HeaderText="Date|Import" HeaderStyle-Wrap="false" SortExpression="min_pickslip_import_date">
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
            <eclipse:MultiBoundField DataFields="VAS" HeaderText="VAS" HideEmptyColumn="true" HeaderToolTip="Value Added Service Required" SortExpression="VAS" />
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
</asp:Content>

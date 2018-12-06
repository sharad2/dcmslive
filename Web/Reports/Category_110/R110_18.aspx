<%@ Page Title="Suspense Shipping Carton Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4819 $
 *  $Author: sbist $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_18.aspx $
 *  $Id: R110_18.aspx 4819 2013-01-08 11:39:14Z sbist $
 * Version Control Template Added.
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
    public static AutoCompleteItem ValidateCustomer(string term)
    {
        if (string.IsNullOrEmpty(term))
        {
            return null;
        }
        const string QUERY = @"
select cust.customer_id as customer_id, 
                       cust.name as customer_name
                from cust cust
                where cust.inactive_flag is null <if>and  cust.customer_id = :customer_id</if>";
        OracleDataSource ds = new OracleDataSource(ConfigurationManager.ConnectionStrings["dcmslive"]);
        ds.SysContext.ModuleName = "CustomerValidator";
        ds.SelectParameters.Add("customer_id", TypeCode.String, string.Empty);
        try
        {
            ds.SelectSql = QUERY;
            if (term.Contains(":"))
            {
                term = term.Split(':')[0];
            }
            ds.SelectParameters["customer_id"].DefaultValue = term;
            AutoCompleteItem[] data = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                                       select new AutoCompleteItem()
                                       {
                                           Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_id"), DataBinder.Eval(cst, "customer_name")),
                                           Value = DataBinder.Eval(cst, "customer_id", "{0}")
                                       }).Take(5).ToArray();
            return data.Length > 0 ? data[0] : null;
        }
        finally
        {
            ds.Dispose();
        }
    }
    protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (cbSpecificBuilding.Checked && string.IsNullOrEmpty(ctlWhLoc.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide select at least one building.";
            return;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For the specified suspense date,days or date range the report displays the list of cartons along with their details 
        as well as the boxes which are in suspense for more than days. This 
        report can also be displayed with different combinations of the following 
        filters:-Days,Customer, purchase order and building.The report will not consider 
        Cancel Boxes." />
    <meta name="ReportId" content="110.18" />
    <meta name="Browsable" content="True" />
    <meta name="Version" content="$Id: R110_18.aspx 4819 2013-01-08 11:39:14Z sbist $" />
    <script type="text/javascript">
        function ctlWhLoc_OnClientChange(event, ui) {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {
                $('#cbSpecificBuilding').attr('checked', 'checked');
            } else {
                $('#cbSpecificBuilding').removeAttr('checked', 'checked');
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <i:RadioButtonListEx runat="server" ID="rblOptions" Visible="false" Value="ForDate"
                        QueryString="RadioGroup" />
                </eclipse:LeftPanel>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:RadioItemProxy ID="RadioItemProxy1" runat="server" Text="Suspense Date" CheckedValue="ForDate"
                        QueryString="RadioGroup" FilterDisabled="true" ToolTip="Check to view returned SKUs which are completely recieved to modified within specified dates" />
                </eclipse:LeftPanel>
                <asp:Panel ID="Panel1" runat="server">
                    <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Suspense Date"
                        Text="-7">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="ForDate" />
                            <i:Required />
                        </Validators>
                    </d:BusinessDateTextBox>
                    <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Suspense Date" Text="0">
                        <Validators>
                            <i:Date DateType="ToDate" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="ForDate" />
                        </Validators>
                    </d:BusinessDateTextBox>
                </asp:Panel>
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <i:RadioItemProxy runat="server" Text="Boxes in suspense area from" ID="rbdays" CheckedValue="DAY"
                        QueryString="RadioGroup" FilterDisabled="true" ToolTip="Check to view records of a specific day " />
                </eclipse:LeftPanel>
                <asp:Panel runat="server" ID="p_receipt">
                    <i:TextBoxEx ID="tbday" runat="server" FriendlyName="Boxes in suspense area from days: "
                        MaxLength="4" >
                        <Validators>
                            <i:Value ValueType="Integer" Min="0" Max="90" ClientMessage="Value must be integer and between (0 - 90)" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="DAY" />
                            <i:Required  DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="DAY"/>
                        </Validators>
                    </i:TextBoxEx>
                    (0 - 90) Days
                </asp:Panel>
                <eclipse:LeftLabel ID="LeftLabel5" Text="Customer" runat="server" />
                <i:AutoComplete runat="server" ID="tbcustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Customer" QueryString="customer_id" ToolTip="The customers whose purchase order you are interested in."
                    Delay="1200" AutoValidate="true" ValidateWebMethodName="ValidateCustomer" Width="200">
                </i:AutoComplete>
                <br />
                The customer for which you want to see suspense shipping cartons .
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Purchase Order" />
                <i:TextBoxEx ID="tbPO" runat="server" />
                <%--<eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Building" />
                <d:BuildingSelector runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" FriendlyName="Building" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:BuildingSelector>--%>
                <eclipse:LeftPanel ID="LeftPanel4" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Check For Specific Building" />
                    <i:CheckBoxEx ID="cbSpecificBuilding" runat="server" FriendlyName="Specific Building"></i:CheckBoxEx>
                </eclipse:LeftPanel>

                <oracle:OracleDataSource ID="dsAvailableInventory" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                               SELECT TWL.WAREHOUSE_LOCATION_ID,
                                 (TWL.WAREHOUSE_LOCATION_ID || ':' || TWL.DESCRIPTION) AS DESCRIPTION
                                           FROM TAB_WAREHOUSE_LOCATION TWL
                                     ORDER BY 1

                    </SelectSql>
                </oracle:OracleDataSource>

                <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsAvailableInventory" FriendlyName="Building "
                    QueryString="building" OnClientChange="ctlWhLoc_OnClientChange">
                </i:CheckBoxListEx>

                <br />
                Suspense boxes of customer will be shown for open order in this building.
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
   select MAX(B.IA_ID) AS ia_id , 
       B.UCC128_ID AS ucc128_id,
       max(P.WAREHOUSE_LOCATION_ID) AS Building,
       SUM(BD.CURRENT_PIECES) AS current_pieces,
       MAX(P.CUSTOMER_ID ||'     :     '|| c.name) AS customer,
       MAX(P.PO_ID)  AS po_id, 
       MAX(p.customer_dc_id) AS customer_dc_id,
       MAX(b.PICKSLIP_ID) AS pickslip_id,
       MAX(S.SHIP_DATE) AS ship_date,
       max(B.Pallet_id) as Pallet_id,
       max(B.location_id) as location_id,
       MAX(B.SUSPENSE_DATE) AS suspense_date,
       MAX(ba.created_by) AS User_name,
       MAX(TRUNC(SYSDATE) - TRUNC(B.SUSPENSE_DATE)) AS LAST_ADDED_DAY
       from  BOX B
LEFT OUTER JOIN box_audit ba
       ON b.ucc128_id = ba.ucc128_id
       AND b.suspense_date = ba.suspense_date
LEFT OUTER JOIN BOXDET BD ON 
       B.UCC128_ID = BD.UCC128_ID
       AND B.PICKSLIP_ID = BD.PICKSLIP_ID
LEFT OUTER JOIN PS P ON 
       B.PICKSLIP_ID = P.PICKSLIP_ID
LEFT OUTER JOIN SHIP S ON
       P.Shipping_Id = S.Shipping_Id
INNER JOIN CUST C ON
       P.CUSTOMER_ID = C.CUSTOMER_ID
 WHERE B.SUSPENSE_DATE IS NOT NULL
 AND B.STOP_PROCESS_DATE IS NULL
  <if>and b.suspense_date &gt;= :from_suspense_date</if>
  <if> and b.suspense_date &lt; :to_suspense_date + 1</if>
   <if>AND TRUNC(SYSDATE) - B.SUSPENSE_DATE  &lt;= :Days</if>
  <if> and p.customer_id = :customer_id</if>
  <if> AND p.po_id = :po_id</if>
 <%-- <if>and p.warehouse_location_id =:warehouse_location_id</if>--%>
       <if>AND <a pre="p.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:warehouse_location_id</a></if>
 GROUP BY b.ucc128_id
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="tbday" Type="String" Direction="Input" Name="Days" />
            <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbPO" Name="po_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="from_suspense_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="to_suspense_date" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="customer;Building;$;last_added_day {0:I}">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="ucc128_id" HeaderText="UCC" SortExpression="ucc128_id" />
            <eclipse:MultiBoundField DataFields="customer" HeaderText="Customer" ItemStyle-Font-Bold="true"
                SortExpression="customer" />
            <eclipse:MultiBoundField DataFields="Building" HeaderText="Building" NullDisplayText="Unknown"
                ItemStyle-Font-Bold="true" SortExpression="Building" />
            <eclipse:MultiBoundField DataFields="Pallet_id" HeaderText="Pallet" SortExpression="Pallet_id" />
            <eclipse:MultiBoundField DataFields="location_id" HeaderText="Location" SortExpression="location_id" />
            <eclipse:MultiBoundField DataFields="pickslip_id" HeaderText="Pickslip" SortExpression="pickslip_id" />
            <eclipse:MultiBoundField DataFields="po_id" HeaderText="PO" SortExpression="po_id" />
            <eclipse:MultiBoundField DataFields="customer_dc_id" HeaderText="DC" SortExpression="customer_dc_id" />
            <eclipse:MultiBoundField DataFields="ia_id" HeaderText="Area" SortExpression="ia_id" />
            <eclipse:MultiBoundField DataFields="ship_date" HeaderStyle-Wrap="false" HeaderText="Ship Date"
                ItemStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="ship_date" />
            <eclipse:MultiBoundField DataFields="suspense_date" HeaderStyle-Wrap="false" ItemStyle-Wrap="false"
                ItemStyle-HorizontalAlign="Right" HeaderText="Suspense|Date" SortExpression="suspense_date" />
            <eclipse:MultiBoundField DataFields="last_added_day" HeaderText="Suspense|No. Of Days"
                HeaderStyle-Wrap="false" SortExpression="last_added_day {0:I}" ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="User_name" HeaderText="User" SortExpression="User_name" />
            <eclipse:MultiBoundField DataFields="current_pieces" HeaderStyle-Wrap="false" HeaderText="Pieces"
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" SortExpression="current_pieces"
                DataSummaryCalculation="ValueSummation" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

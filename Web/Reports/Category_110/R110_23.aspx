<%@ Page Title="Open UPS Fedex Shipments Report" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6702 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R110_23.aspx 6702 2014-04-18 13:39:53Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        //ds.CommandParsing += new EventHandler<CommandParsingEventArgs>(ds_CommandParsing);
    }
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //sets  WeekStartDate and MonthEndDate current year.           
            string str1 = DateTime.Now.AddDays(-1*(int)(DateTime.Now.DayOfWeek)).ToShortDateString();
            if (string.IsNullOrEmpty(dtFromStartDate.Text))
            {
                 //Do not modify date if it is being passed via query string
                dtFromStartDate.Text = str1;
            }
            if (string.IsNullOrEmpty(dtfromcanceldate.Text))
            {
                dtfromcanceldate.Text = str1;
            }
            DateTime dtThisMonthEndDate = GetMonthEndDate(DateTime.Today);
            string str = string.Format("{0:d}", dtThisMonthEndDate);
            if (string.IsNullOrEmpty(dtToStartDate.Text))
            {
                dtToStartDate.Text = str;
            }
            if (string.IsNullOrEmpty(dttocanceldate.Text))
            {
                dttocanceldate.Text = str;
            }
        }
        base.OnLoad(e);
    }
    public static DateTime GetMonthEndDate(DateTime current)
    {
        // Accessing private variable using reflection to avoide the need to modify the library
        var __monthStartDates = (IEnumerable<DateTime>)typeof(BusinessDateTextBox).GetField(
            "__monthStartDates", System.Reflection.BindingFlags.NonPublic |
             System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.GetField).GetValue(null);
        var dt = __monthStartDates.OrderBy(p => p).FirstOrDefault(p => p >= current);
        // Assume calendar month end date if date not found
        if (dt == DateTime.MinValue)
        {
            dt = new DateTime(current.Year, current.Month, 1);
            dt.AddMonths(1).AddDays(-1);
            return dt;
        }
        else
        {
            return dt.AddDays(-1);
        }
    }
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
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        DateTime DCCancelDate;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DCCancelDate = Convert.ToDateTime(DataBinder.Eval(e.Row.DataItem, "DC_CANCEL_DATE"));
            
            var cellIndex = 0;
            if (DCCancelDate < System.DateTime.Today)
            {
                cellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "CancelDate" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.Cells[cellIndex].ToolTip= "Already expired The DC Cancel Date.";
                e.Row.Cells[cellIndex].BackColor = System.Drawing.Color.Red;
            }
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is for displaying only validated orders of small shipments. For each small shipment order this report shows all the information of validated boxes like how many boxes of SMS order is validated, how many boxes are scanned at UPS station and how many boxes are there that are validated but not yet scanned at UPS station. This will help users to consolidate shipments which are very urgent. By using different filter combinations of this report like Customer, Delivery Date and DC Cancel Date user can process priority shipments first with great efficiency." />
    <meta name="ReportId" content="110.23" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R110_23.aspx 6702 2014-04-18 13:39:53Z skumar $" />
    <meta name="ChangeLog" content="Fixed Bug:- Report was crashing when user drill down to see the remaining boxes." />
    <script type="text/javascript">
        function tbcustomer_OnClientSelect(event, ui) {
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
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                
                  <eclipse:LeftLabel ID="LeftLabel5" Text="Customer" runat="server" />
                                <i:AutoComplete runat="server" ID="tbcustomer" ClientIDMode="Static" WebMethod="GetCustomers" 
                                    FriendlyName="Customer" QueryString="customer_id" ToolTip="User can choose customer."
                                    Delay="1000" Width="137"  OnClientSelect="tbcustomer_OnClientSelect">
                                </i:AutoComplete>
                                <br />
                 You can pass multiple Customer IDs separated by a comma (, ).
                <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbstartdate" Text="Delivery Date" CheckedValue="Y" ToolTip="Show results for the given delivery date/range"
                        QueryString="Start_date" FriendlyName="Delivery Date" Checked="false" />
                </eclipse:LeftPanel>
                From
                            <d:BusinessDateTextBox ID="dtFromStartDate" runat="server" FriendlyName="From Delivery Date"
                                QueryString="from_start_date">
                                <Validators>
                                    <i:Filter DependsOn="cbstartdate" DependsOnState="Checked" />
                                    <i:Date />
                                </Validators>
                            </d:BusinessDateTextBox>
                To:
                            <d:BusinessDateTextBox ID="dtToStartDate" runat="server" FriendlyName="To Delivery Date"
                                QueryString="to_start_date" >
                                <Validators>
                                    <i:Filter DependsOn="cbstartdate" DependsOnState="Checked" />
                                    <i:Date DateType="ToDate" />
                                </Validators>
                            </d:BusinessDateTextBox>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbcanceldate" Text="DC Cancel Date" CheckedValue="Y"  ToolTip="Show results for the given DC cancel date/range"
                        QueryString="cancel_date" FriendlyName="DC Cancel Date" FilterDisabled="true" Checked="false" />
                </eclipse:LeftPanel>
                From
                            <d:BusinessDateTextBox ID="dtfromcanceldate" runat="server" FriendlyName="From DC Cancel Date"
                                QueryString="from_dc_cancel_date" >
                                <Validators>
                                    <i:Filter DependsOn="cbCanceldate" DependsOnState="Checked" />
                                    <i:Date />
                                </Validators>
                            </d:BusinessDateTextBox>
                To:
                            <d:BusinessDateTextBox ID="dttocanceldate" runat="server" FriendlyName="To DC Cancel Date"
                                QueryString="to_dc_cancel_date">
                                <Validators>
                                    <i:Filter DependsOn="cbCanceldate" DependsOnState="Checked" />
                                    <i:Date DateType="ToDate" />
                                </Validators>
                            </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
         <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv" EnableGroupBy="true" />
    </jquery:JPanel>
             </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true" >
        <SelectSql>
SELECT ps.po_id,
       ps.customer_id,
       ps.iteration,
       MAX(C.NAME) AS CUSTOMER_NAME,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(PO.START_DATE) AS START_DATE,
       COUNT(DISTINCT PS.PICKSLIP_ID) AS PICKSLIP_COUNT,
       count(distinct b.ucc128_id) AS total_boxes,
       COUNT(DISTINCT LS.UCC128_ID) AS UPS_SCANNED_BOXES,
       count(distinct b.ucc128_id) - COUNT(DISTINCT LS.UCC128_ID) as Remaining_boxes
  FROM PS
 INNER JOIN CUST C ON 
 PS.CUSTOMER_ID = C.CUSTOMER_ID
 INNER JOIN BOX B
    ON PS.PICKSLIP_ID = B.PICKSLIP_ID
 INNER JOIN MASTER_CARRIER MC
    ON PS.CARRIER_ID = MC.CARRIER_ID
  LEFT OUTER JOIN LOAD_SMSUPS LS
    ON B.UCC128_ID = LS.UCC128_ID
 INNER JOIN PO ON 
 PS.CUSTOMER_ID = PO.CUSTOMER_ID
 AND PS.PO_ID = PO.PO_ID
 AND PS.ITERATION = PO.ITERATION
 WHERE PS.TRANSFER_DATE IS NULL
   AND B.STOP_PROCESS_DATE IS NULL
   AND MC.SMALL_SHIPMENT_FLAG = 'Y'
   AND PS.REPORTING_STATUS = 'VALIDATED'
   AND NVL(LS.INDICATOR,'N') ='N'
   <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
   <if>and po.start_date &gt;= cast(:from_start_date as date)</if>
   <if>and po.start_date &lt; cast(:to_start_date as date) + 1</if>
   <if>and po.dc_cancel_date &gt;=cast(:from_cancel_date as date) </if>
   <if>and po.dc_cancel_date &lt;cast(:to_cancel_date as date) + 1</if>
 group by ps.customer_id, ps.po_id,ps.iteration
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" PropertyName="Text" />
            <asp:ControlParameter ControlID="dtFromStartDate" Name="from_start_date" Type="DateTime" />
            <asp:ControlParameter ControlID="dtToStartDate" Name="to_start_date" Type="DateTime" />
            <asp:ControlParameter ControlID="dtfromcanceldate" Name="from_cancel_date" Type="DateTime" />
            <asp:ControlParameter ControlID="dttocanceldate" Name="to_cancel_date" Type="DateTime" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds"  OnRowDataBound="gv_RowDataBound" DefaultSortExpression="CUSTOMER_NAME;$;DC_CANCEL_DATE">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField HeaderText="PO" DataFields="po_id" SortExpression="po_id" ToolTipFields="iteration" HeaderToolTip="The order no. of the customer" ToolTipFormatString="Iteration : {0}" />
            <eclipse:MultiBoundField HeaderText="Customer" DataFields="customer_id,CUSTOMER_NAME" SortExpression="CUSTOMER_NAME" DataFormatString="{0}:{1}"/>
            <eclipse:MultiBoundField HeaderText="# Validated Pickslips" HeaderStyle-Wrap="true" ToolTipFields="PICKSLIP_COUNT" ToolTipFormatString="{0:N0}:Validated Pickslips in this order"
                 DataFields="PICKSLIP_COUNT" SortExpression="PICKSLIP_COUNT" HeaderToolTip="No. of verified pickslips." DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"/>
            <eclipse:MultiBoundField HeaderText="No. Of Boxes|Validated" DataFields="total_boxes" SortExpression="total_boxes" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" HeaderToolTip="Number of verified boxes." 
                DataFooterFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField HeaderText="No. Of Boxes|Scanned At UPS" DataFields="UPS_SCANNED_BOXES" SortExpression="UPS_SCANNED_BOXES" 
                 HeaderToolTip="Number of verified boxes already scanned at UPS station." DataFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:#,###}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
            <eclipse:SiteHyperLinkField DataTextField="Remaining_boxes" DataNavigateUrlFields="po_id,customer_id" HeaderToolTip="No. of verified boxes which are not scanned at the UPS station."
                HeaderText="No. Of Boxes|Remaining" DataNavigateUrlFormatString="R110_107.aspx?po_id={0}&customer_id={1}" DataTextFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:#,###}" ItemStyle-HorizontalAlign="Right"
                FooterStyle-HorizontalAlign="Right" SortExpression="Remaining_boxes" AppliedFiltersControlID="ButtonBar1$af">
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField HeaderText="Date|Delivery" DataFields="START_DATE" SortExpression="START_DATE" HeaderToolTip="The date before which the order must not be shipped." DataFormatString="{0:d}"/>
            <eclipse:MultiBoundField HeaderText="Date|DC Cancel" DataFields="DC_CANCEL_DATE" SortExpression="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderToolTip="The date by which the order must be dispatched from the warehouse." AccessibleHeaderText="CancelDate"/>
             </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Control Language="C#" ClassName="R110_08" %>
<script runat="server">
    /// <summary>
    /// Provide access to the tabs control
    /// </summary>
    public Tabs Tabs
    {
        get
        {
            return tabs;
        }
    }

    const int NO_OF_DAYS = 1;

    /// <summary>
    /// ddlStatus is an optional filter and it is not visble by default
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //sets  first date of previous year           
            string str = new DateTime(DateTime.Now.Year - 1, 1, 1).ToShortDateString();
            if (string.IsNullOrEmpty(tbFromDeliveryDate.Text))
            {
                // Do not modify date if it is being passed via query string
                tbFromDeliveryDate.Text = str;
            }
            else
            {
                cbDeliverydate.Checked = true;
            }
            if (string.IsNullOrEmpty(tbFromDcCancelDate.Text))
            {
                tbFromDcCancelDate.Text = str;
            }
            else
            {
                cbDcCancelDate.Checked = true;
            }

            //DateTime nextMonthDate = DateTime.Today.AddMonths(1);
            //DateTime nextMonthStartDate = BusinessDateTextBox.GetMonthStartDate(nextMonthDate.Year, nextMonthDate.Month);
            //DateTime dtThisMonthEndDate = nextMonthStartDate.AddDays(-1);
            DateTime dtThisMonthEndDate = GetMonthEndDate(DateTime.Today);
            str = string.Format("{0:d}", dtThisMonthEndDate);
            if (string.IsNullOrEmpty(tbToDeliveryDate.Text))
            {
                tbToDeliveryDate.Text = str;
            }
            else
            {
                cbDeliverydate.Checked = true;
            }
            if (string.IsNullOrEmpty(tbToDcCancelDate.Text))
            {
                tbToDcCancelDate.Text = str;
            }
            else
            {
                cbDcCancelDate.Checked = true;
            }

        }
        if (rblOrderType.Value != "D")
        {
            cblExclude.FilterDisabled = true;
        }
        //rblOrderType.Value = "A";     
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
</script>
<style type="text/css">
    .AlignCheckbox
    {
        display: inline-block;
        vertical-align: top;
        margin-left: 10mm;
    }
</style>
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
<jquery:Tabs runat="server" ID="tabs" Selected="-1">
    <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
        <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
            <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                <fieldset>
                    <legend class="ui-widget-header">Order Type</legend>
                    <i:RadioButtonListEx ID="rblOrderType" runat="server" QueryString="order_type" Value="A" FriendlyName="Order Type"  ToolTip="User can check Domestic and international orders. "/>
                    <i:RadioItemProxy runat="server" ID="rbAll" Text="All" QueryString="order_type" CheckedValue="A" />
                    <br />
                    &nbsp;<i:RadioItemProxy runat="server" ID="rbDomestic" Text="Domestic" QueryString="order_type"
                        CheckedValue="D" ClientIDMode="Static" />
                    <i:CheckBoxListEx runat="server" ID="cblExclude" CssClasses="AlignCheckbox" QueryString="restrict_type"
                        FriendlyName="Exclude Orders From" OnClientChange="function(e) {
$(this).checkBoxListEx('values').length &gt; 0 && $('#rbDomestic').attr('checked', 'checked');
                        }">
                        <Items>
                            <i:CheckBoxItem Text="Retail" Value="R" />
                            <i:CheckBoxItem Text="IDC" Value="I" />
                        </Items>
                    </i:CheckBoxListEx>
                    <br />
                    &nbsp;<i:RadioItemProxy runat="server" ID="rbInternational" Text="International"
                        QueryString="order_type" CheckedValue="I" />
                </fieldset>
            </eclipse:LeftPanel>
            <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                <i:CheckBoxEx runat="server" ID="cbDeliverydate" Text="Delivery Date" CheckedValue="Y"
                    QueryString="delivery_date" FilterDisabled="true" ToolTip="Show results for the given delivery date / range"/>
            </eclipse:LeftPanel>
            From
            <d:BusinessDateTextBox ID="tbFromDeliveryDate" runat="server" FriendlyName=" From Delivery  Date"
                QueryString="delivery_start_date">
                <Validators>
                    <i:Filter DependsOn="cbDeliverydate" DependsOnState="Checked" />
                    <i:Date />
                </Validators>
            </d:BusinessDateTextBox>
            To
            <d:BusinessDateTextBox ID="tbToDeliveryDate" runat="server" FriendlyName=" To Delivery  Date"
                QueryString="delivery_end_date">
                <Validators>
                    <i:Filter DependsOn="cbDeliverydate" DependsOnState="Checked" />
                    <i:Date DateType="ToDate" />
                </Validators>
            </d:BusinessDateTextBox>
            <eclipse:LeftPanel runat="server">
                <i:CheckBoxEx runat="server" ID="cbDcCancelDate" Text="DC Cancel Date" CheckedValue="Y"
                    QueryString="dc_cancel_date" FilterDisabled="true"  ToolTip="Show results for the given DC Cancel date / range"/>
            </eclipse:LeftPanel>
            From
            <d:BusinessDateTextBox ID="tbFromDcCancelDate" runat="server" FriendlyName="From Dc Cancel  Date"
                QueryString="dc_cancel_start_date">
                <Validators>
                    <i:Filter DependsOn="cbDcCancelDate" DependsOnState="Checked" />
                    <i:Date />
                </Validators>
            </d:BusinessDateTextBox>
            To
            <d:BusinessDateTextBox ID="tbToDcCancelDate" runat="server" FriendlyName="To Dc Cancel Date"
                QueryString="dc_cancel_end_date">
                <Validators>
                    <i:Filter DependsOn="cbDcCancelDate" DependsOnState="Checked" />
                    <i:Date DateType="ToDate" />
                </Validators>
            </d:BusinessDateTextBox>
            <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Virtual Warehouse" />
            <d:VirtualWarehouseSelector ID="ctlVwh_id" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="vwh_id" ToolTip="Choose virtual warehouse"/>
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
                
            <eclipse:LeftLabel ID="lblpieces" runat="server" Text="Pieces Per Day" />
            <i:TextBoxEx runat="server" ID="tbPiecesPerDay" ClientIDMode="Static" FriendlyName="PiecesPerDay" ToolTip="Minimum '216000' pieces shipped per day."
                Text="<%$ AppSettings:PiecesPerDay %>" Visible="false">
                <Validators>
                    <%-- <i:Value ValueType="Integer" Min="0" />--%>
                    <i:Required />
                </Validators>
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" Text="Customer" />
            <i:TextBoxEx ID="tbcustomer" runat="server" QueryString="customer_id" ToolTip="Filter out the results for passed Customer Id.">
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="llbucket" Text="Bucket" />
            <i:TextBoxEx runat="server" ID="tbbucket" QueryString="BUCKET_ID" ToolTip="Filter out the results for passed Bucket Id." Size="20" MaxLength="10" Visible="false">
            <Validators>
            <i:Value ValueType="Integer" ClientMessage="Bucket should be numeric only" />
            </Validators>
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="llpo" Text="PO" />
            <i:TextBoxEx runat="server" ID="tbpo" QueryString="PO_ID" Visible="false" ToolTip="Filter out the results for passed Purchase Order">
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="lliteration" Text="Iteration" />
            <i:TextBoxEx runat="server" ID="tbiteration" QueryString="iteration" Size="20" MaxLength="10" Visible="false">
            <Validators>
            <i:Value ValueType="Integer" ClientMessage="Iteration should be numeric only" />
            </Validators>
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="lldc" Text="Customer DC" />
            <i:TextBoxEx runat="server" ID="tbdc" QueryString="customer_dc_id" ToolTip="Filter out the results for passed Customer DC Id.">
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="llstore" Text="Customer Store" />
            <i:TextBoxEx runat="server" ID="tbstore" QueryString="customer_store_id" ToolTip="Filter out the results for passed Customer Store Id.">
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="llpickslip" Text="Pickslip" />
            <i:TextBoxEx runat="server" ID="tbpickslip" QueryString="pickslip_id" MaxLength="11" Visible="false" ToolTip="Filter out the results for passed Pickslip Id.">
                <Validators>
                        <i:Value ValueType="Integer" ClientMessage="Pickslip should be numeric." />
                    </Validators>
            </i:TextBoxEx>
            <eclipse:LeftLabel runat="server" ID="llReportingStatus" Text="Reporting Status" /> 
            <oracle:OracleDataSource ID="dsReportingStatus" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" 
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                             SELECT trs.reporting_status AS reporting_status
                             FROM tab_reporting_status trs
                             ORDER BY trs.sort_sequence
                </SelectSql>
            </oracle:OracleDataSource>
            <i:DropDownListEx2 ID="ddlStatus" runat="server" QueryString="reporting_status" DataFields="reporting_status" ToolTip="Indicates the processing stage of the pickslip."
                FriendlyName="Reporting Status" FilterDisabled="true" Visible="false" DataSourceID="dsReportingStatus"
                DataTextFormatString="{0}">
                <Items>
                    <eclipse:DropDownItem Text="IN ORDER BUCKET" Value="IN ORDER BUCKET" Persistent="Always" />
                </Items>
            </i:DropDownListEx2>
        </eclipse:TwoColumnPanel>
        <asp:Panel runat="server">
            <eclipse:TwoColumnPanel runat="server">
                 <eclipse:LeftPanel ID="LeftPanel3" runat="server">
               <eclipse:LeftLabel ID="LeftLabel4" runat="server"  Text="Building"/>
                     <br />
                     <br />
                    <i:CheckBoxEx ID="cbAll" runat="server" FriendlyName="Select All" OnClientChange="cbAll_OnClientChange">                     
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
                  <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION" ToolTip=" Warehouse location ID."
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                    QueryString="warehouse_location_id">
                </i:CheckBoxListEx>
            </eclipse:TwoColumnPanel>
        </asp:Panel>
    </jquery:JPanel>
</jquery:Tabs>
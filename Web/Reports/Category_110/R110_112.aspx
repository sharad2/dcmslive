<%@ Page Title="PO List" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5296 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_112.aspx $
 *  $Id: R110_112.aspx 5296 2013-05-02 05:01:23Z skumar $
 * Version Control Template Added.
 
--%>
<%--Multiview pattern--%>


<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        ds.Selecting += new SqlDataSourceSelectingEventHandler(ds_Selecting);
        base.OnInit(e);
    }

    void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        //if (string.IsNullOrEmpty(this.tbBucket.Text))
        //{
        //    e.Command.CommandText = ds.CommandTexts["Query_DemPS"];
        //}
        //else
        //{
        //    e.Command.CommandText = ds.CommandTexts["Query_PS"];
        //}

    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report lists all PO for a particular Customer , bucket and start date or date range or customer_dc." />
    <meta name="ReportId" content="110.112" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_112.aspx 5296 2013-05-02 05:01:23Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server" WidthRight="30em">
                <eclipse:LeftLabel ID="lblCustomer" runat="server" Text="Customer" />
                <i:TextBoxEx ID="tbCustomer" runat="server" QueryString="Customer" ToolTip="Please enter the customer id.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="lblbucket" Text="Bucket" runat="server" />
                <i:TextBoxEx ID="tbBucket" runat="server" QueryString="BucketId" ToolTip="Enter the bucket number" />
                <eclipse:LeftLabel ID="lblCustDc" Text="Customer Dist Center" runat="server" />
                <i:TextBoxEx ID="tbCustDc" runat="server" QueryString="Customer_dc_id" ToolTip="Enter the customer dc" />
                <eclipse:LeftLabel ID="lblDateRange" runat="server" Text="From Date" />                
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Date"
                    Text="-7" ToolTip="Please select the From PO start date." QueryString="FromDate">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="lblToDate" runat="server" Text="To Date" />
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Date" Text="0"
                    ToolTip="Please select the To PO start date." QueryString="ToDate">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
        ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>">
        <%--<CommandTexts>
            <oracle:CommandText ID="Query_PS" Query="
   SELECT distinct (ps.po_id) AS PO_ID
  FROM ps ps, po po
 WHERE ps.customer_id = po.customer_id
   AND ps.po_id = po.po_id
   AND ps.iteration = po.iteration
   AND ps.reporting_status is not null
   [$:FromDate$AND po.start_date &gt;= :FromDate$]
   [$:ToDate$AND po.start_date &lt; :ToDate + 1$]
   [$:Customer_dc$AND ps.customer_dc_id = :Customer_dc$]
   [$:Customer_id$AND ps.Customer_id = :Customer_id$]
   AND ps.bucket_id = :bucket_id" />
            <oracle:CommandText ID="Query_DemPS" Query="SELECT DISTINCT (dps.customer_order_id) AS PO_ID
  FROM dem_pickslip dps
 WHERE dps.ps_status_id = '1'
   AND dps.upload_date IS NULL
   [$:FromDate$AND dps.delivery_date &gt;= :FromDate$]
   and dps.delivery_date &lt; :ToDate + 1
   [$:Customer_dc$AND dps.customer_dist_center_id = :Customer_dc$]
   [$:Customer_id$AND dps.customer_id = :Customer_id$]" />
        </CommandTexts>--%>
        <SelectSql>
        <if c="$bucket_id">
        SELECT distinct (ps.po_id) AS PO_ID
  FROM ps ps, po po
 WHERE ps.Customer_id = po.Customer_id
   AND ps.po_id = po.po_id
   AND ps.iteration = po.iteration
   AND ps.transfer_date is null 
   <if>AND po.start_date &gt;= :FromDate</if>
   <if>AND po.start_date &lt; :ToDate + 1</if>
   <if>AND ps.customer_dc_id = :Customer_dc</if>
   <if>AND ps.Customer_id = :Customer_id</if>
   AND ps.bucket_id = :bucket_id
   </if>
   <else>
   SELECT DISTINCT (dps.customer_order_id) AS PO_ID
  FROM dem_pickslip dps
  WHERE dps.ps_status_id = '1'
   AND dps.upload_date IS NULL
   <if>AND dps.delivery_date &gt;= CAST(:FromDate AS DATE)</if>
   and dps.delivery_date &lt; CAST(:ToDate AS DATE) + 1
   <if>AND dps.customer_dist_center_id = :Customer_dc</if>
   <if>AND dps.Customer_id = :Customer_id</if>
   </else>
        </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbCustomer" Direction="Input" Type="String" Name="Customer_id" />
            <asp:ControlParameter ControlID="tbCustDc" Direction="Input" Type="String" Name="Customer_dc" />
            <asp:ControlParameter ControlID="tbBucket" Direction="Input" Type="String" Name="bucket_id" />
            <asp:ControlParameter ControlID="dtFrom" Direction="Input" Type="DateTime" Name="FromDate" />
            <asp:ControlParameter ControlID="dtTo" Direction="Input" Type="DateTime" Name="ToDate" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="false" DefaultSortExpression="PO_ID">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO" SortExpression="PO_ID"
                HeaderToolTip="Purchase Order numbers" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

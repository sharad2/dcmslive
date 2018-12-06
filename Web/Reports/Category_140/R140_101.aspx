<%@ Page Title="Pickslips in Bucket" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1755 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_101.aspx $
 *  $Id: R140_101.aspx 1755 2011-12-03 05:56:35Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report shows pickslips for passed bucket along with picking status and customer id." />
    <meta name="ReportId" content="140.101" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R140_101.aspx 1755 2011-12-03 05:56:35Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id">
                    <Validators>
                    <i:Value ValueType="Integer" MaxLength="5" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Virtual Warehouse" />
                  <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true"
                   ConnectionString='<%$ ConnectionStrings:DCMSLIVE %>' ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString='<%$ ConnectionStrings:DCMSLIVE %>'
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label" QueryString="label_id" ToolTip="Select any label to see the order.">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Customer Id" />
                <i:TextBoxEx runat="server" ID="tbCustomerId" QueryString="customer_id" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
         SELECT ps.pickslip_id AS pickslip_id,
           MIN(ps.customer_id) AS customer_id,
           MAX(CASE
             WHEN ps.picking_status IS NULL AND
                  bkt.available_for_pitching IS NULL THEN
              'Not Available'
             ELSE
              (CASE
             WHEN ps.picking_status IS NULL AND
                  bkt.available_for_pitching = 'Y' THEN
              'Available'
             ELSE
              (CASE
             WHEN ps.picking_status = 'TRANSFERED' AND
                  bkt.available_for_pitching = 'Y' THEN
              'COMPLETED'
             ELSE
              ''
           END) END) END) AS picking_status
        FROM ps ps
        LEFT OUTER JOIN bucket bkt ON ps.bucket_id = bkt.bucket_id
        WHERE bkt.bucket_id = cast(:bucket_id as number(5))
         <if>AND ps.vwh_id = CAST(:vwh_id as varchar2(255))</if>
         <if>AND ps.label_id = CAST(:label_id as varchar2(255))</if>
         <if>AND ps.customer_id=CAST(:customer_id as varchar2(255))</if>  
              GROUP BY ps.pickslip_id, ps.vwh_id
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbBucketId" Direction="Input" Name="bucket_id" Type="Int32" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
            <asp:ControlParameter ControlID="ctlLabel" Direction="Input" Name="label_id" Type="String" />
            <asp:ControlParameter ControlID="tbCustomerId" Direction="Input" Name="customer_id"
                Type="String" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div style="padding:1em 0em 1em 1em">
  Building:<span id="sp" style="padding:2em"><asp:Label ID="Lblcategory" runat="server" Font-Bold="true"><%=Request.QueryString["warehouse_location_id"]%></asp:Label></span>
    </div>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="false" DataSourceID="ds" DefaultSortExpression="picking_status;$;pickslip_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="picking_status" SortExpression="picking_status"
                HeaderText="Picking Status" />
            <eclipse:SiteHyperLinkField DataTextField="pickslip_id" SortExpression="pickslip_id"
                HeaderText="Pickslip" DataSummaryCalculation="ValueSummation" AppliedFiltersControlID="ctlButtonBar$af"
                DataNavigateUrlFormatString="R140_104.aspx?pickslip_id={0}" DataNavigateUrlFields="pickslip_id" />
            <eclipse:MultiBoundField DataFields="customer_id" SortExpression="customer_id" HeaderText="Customer Id" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

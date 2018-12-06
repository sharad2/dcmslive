<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Lane Load Report"
    CompilerOptions="/warn:0" EnableViewState="false" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5453 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_160/R160_03.aspx $
 *  $Id: R160_03.aspx 5453 2013-06-17 09:23:28Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report will show the list of all the lanes along with all open unfrozen
     buckets and the boxes for each bucket which have not passed Sortation." />
    <meta name="ReportId" content="160.03" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R160_03.aspx 5453 2013-06-17 09:23:28Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filter">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Bucket Creation Date" />
                <%--<eclipse:DateTextBox ID="dtFrom" runat="server" FriendlyName="From" RelativeDate="0"
                    Required="true" />
                <eclipse:DateTextBox ID="dtTo" runat="server" AssociatedFromControlID="dtFrom" FriendlyName="To"
                    RelativeDate="0" />--%>
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From" Text="0">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To"
                    Text="0">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Warehouse location" />
                <%--<dcms:BuildingSelector runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" />--%>
                <d:BuildingSelector ID="ctlWhLoc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
   <%-- <uc:ButtonBar ID="ButtonBar1" runat="server" />--%>
   <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <%--    lane_info excludes boxes which have reached the shipping area. This is because it is possible that boxes may
    reach the shipping area without going through sort scan.
    --%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        DataSourceMode="DataReader" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true"><%-- SelectCommand=" 
           
WITH lane_info AS 
(
SELECT box.ucc128_id AS ucc128_id,
                bkt.bucket_id AS bucket,
                cust.NAME AS customer_name,
       pkg_lane.get_lane(box.ucc128_id, 'Y') as lane_id
  FROM box box
 INNER JOIN ps ON box.pickslip_id = ps.pickslip_id
  LEFT OUTER JOIN ia ON box.ia_id = ia.ia_id
 INNER JOIN bucket bkt ON ps.bucket_id = bkt.bucket_id
 INNER JOIN cust cust ON ps.customer_id = cust.customer_id
 WHERE box.stop_process_date IS NULL
   AND ps.transfer_date IS NULL
   AND bkt.freeze IS NULL
   AND bkt.date_created &gt;= CAST(:FromDate AS DATE)
   [$:ToDate$AND bkt.date_created &lt; CAST(:ToDate AS DATE)+ 1$]   
   [$:warehouse_location_id$AND ps.warehouse_location =:warehouse_location_id$]
  AND ia.shipping_area_flag IS NULL
  )
SELECT lane_info.lane_id,
       lane_info.bucket AS bucket_id,
       lane_info.customer_name AS customer_name,
       COUNT(distinct lane_info.ucc128_id) AS count_of_box,
 SUM(COUNT(distinct lane_info.ucc128_id)) over() as   footer_sum_count_of_box
              FROM lane_info
             GROUP BY lane_info.lane_id,
                      lane_info.bucket,
                      lane_info.customer_name

            "--%>
            <SelectSql>
            WITH lane_info AS 
(
SELECT box.ucc128_id AS ucc128_id,
                bkt.bucket_id AS bucket,
                cust.NAME AS customer_name,
       pkg_lane.get_lane(box.ucc128_id, 'Y') as lane_id
  FROM box box
 INNER JOIN ps ON box.pickslip_id = ps.pickslip_id
  LEFT OUTER JOIN ia ON box.ia_id = ia.ia_id
 INNER JOIN bucket bkt ON ps.bucket_id = bkt.bucket_id
 INNER JOIN cust cust ON ps.customer_id = cust.customer_id
 WHERE box.stop_process_date IS NULL
   AND ps.transfer_date IS NULL
   AND bkt.freeze IS NULL
   AND bkt.date_created &gt;= CAST(:FromDate AS DATE)
   <if c="$ToDate">AND bkt.date_created &lt; CAST(:ToDate AS DATE)+ 1</if>   
   <if>AND ps.warehouse_location =:warehouse_location_id</if>
  AND ia.shipping_area_flag IS NULL
  )
SELECT lane_info.lane_id,
       lane_info.bucket AS bucket_id,
       lane_info.customer_name AS customer_name,
       COUNT(distinct lane_info.ucc128_id) AS count_of_box,
 SUM(COUNT(distinct lane_info.ucc128_id)) over() as   footer_sum_count_of_box
              FROM lane_info
             GROUP BY lane_info.lane_id,
                      lane_info.bucket,
                      lane_info.customer_name

            </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FromDate" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="ToDate" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="lane_id;$;bucket_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="lane_id" HeaderText="Lane" HeaderToolTip="Lane where boxes being processed."
                SortExpression="lane_id" ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" HeaderToolTip="Bucket ID."
                SortExpression="bucket_id" ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="customer_name" HeaderText="Customer Name" HeaderToolTip="Name of the customer."
                SortExpression="customer_name" />
            <eclipse:MultiBoundField DataFields="count_of_box" SortExpression="count_of_box"
                HeaderText="No of Boxes(not passed Sortation)" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

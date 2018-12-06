<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Cartons on a Pallet" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1031 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_09.aspx $
 *  $Id: R40_09.aspx 1031 2011-06-15 05:35:26Z rverma $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For user specified pallet id, the report displays the information of the cartons lying on the pallet." />
    <meta name="ReportId" content="40.09" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R40_09.aspx 1031 2011-06-15 05:35:26Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
         <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Cartons Currently on Pallet" />
                <i:TextBoxEx ID="tbPallet" runat="server" FriendlyName="Cartons Currently on Pallet"
                    QueryString="pallet_id" ToolTip="Enter the pallet to display the cartons." CaseConversion="UpperCase">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        DataSourceMode="DataReader" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        >
  <SelectSql>
select
       b.carton_id           as carton_id,
       b.ucc128_id           as box_id,
       b.pallet_id           as pallet_id,
       b.pickslip_id         as pickslip_id,
       ps.customer_id        as customer_id,
       ps.bucket_id          as bucket_id,
       ps.warehouse_location as expacted_warehouse_location,
       b.ia_id               as area,
       NULL                  as last_pulled_date
  from box b
 inner join ps ps
    on b.pickslip_id = ps.pickslip_id
    where b.pallet_id=:pallet_id
union all
select sc.carton_id           as carton_id,
       NULL                   AS box_id,
       sc.pallet_id           as pallet_id,
       NULL                   as pickslip_id,
       NULL                   as customer_id,
       NULL                   as bucket_id,
       NULL                   as expacted_warehouse_location,
       sc.carton_storage_area as area,
       sc.last_pulled_date    as last_pulled_date
  from src_carton sc
  where sc.pallet_id=:pallet_id
  </SelectSql>
        <SelectParameters>
        <asp:ControlParameter ControlID="tbPallet" Name="pallet_id" Type="String" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="pallet_id"
        AllowSorting="true" AutoGenerateColumns="false">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="pallet_id" HeaderText="Pallet" SortExpression="pallet_id" />
            <asp:BoundField DataField="box_id" HeaderText="Box" SortExpression="box_id" />
            <asp:BoundField DataField="carton_id" HeaderText="Carton" SortExpression="carton_id" />
            <asp:BoundField DataField="pickslip_id" HeaderText="Pickslip id" SortExpression="pickslip_id" />
            <asp:BoundField DataField="area" HeaderText="Area" SortExpression="area" />
            <asp:BoundField DataField="expacted_warehouse_location" HeaderText="Expacted Warehouse Location" SortExpression="expacted_warehouse_location" />
            <asp:BoundField DataField="customer_id" HeaderText="Customer id" SortExpression="customer_id" />
            <asp:BoundField DataField="bucket_id" HeaderText="Bucket id" SortExpression="bucket_id" />
            <asp:BoundField DataField="last_pulled_date" HeaderText="Last Pulled Date" SortExpression="last_pulled_date" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

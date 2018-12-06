<%@ Page Title="Inventory in Area SHL-A" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 518 $
 *  $Author: rverma $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_107.aspx $
 *  $Id: R130_107.aspx 518 2011-03-16 08:58:52Z rverma $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays the pickslip's detail for passed SKUs which are shipped within last 999 days." />
    <meta name="ReportId" content="130.107" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R130_107.aspx 518 2011-03-16 08:58:52Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="UPC Code" />
                <i:TextBoxEx ID="tbUpcCode" runat="server" QueryString="upc_code" ToolTip="Enter UPC Code" />
                <eclipse:LeftLabel runat="server" Text="Label" />
                <d:StyleLabelSelector runat="server" ID="ctlStyleLabel" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" QueryString="label_id" FriendlyName="Label" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" QueryString="vwh_id" ToolTip="Select Virtual Warehouse" />
                <eclipse:LeftLabel runat="server" Text="No. Of Days Back" />
                <%--<jquery:IntegerSlider runat="server" ID="tbDays" Max="999" MaxLength="2" Min="1"
                    Required="true" Step="1" Text="30" ToolTip="Enter no. of days" />--%>
                <i:TextBoxEx runat="server" ID="tbDays" MaxLength="3" Text="30" ToolTip="Enter no. of days">
                    <Validators>
                        <i:Value ValueType="Integer" Min="1" Max="999" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- panel to provide the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Button bar to provide validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <%--DataSource--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
         SELECT PS.PICKSLIP_ID AS PICKSLIP_ID,
               PS.PO_ID AS PO_ID,
               ps.vwh_id AS VWH_ID,
               PS.CUSTOMER_ID AS CUSTOMER_ID,
               PS.CUSTOMER_DC_ID AS DC_ID,
               PS.CUSTOMER_STORE_ID AS STORE_ID,
               CUST.NAME AS CUSTOMER_NAME
         FROM ps ps 
         INNER JOIN psdet psdet on psdet.pickslip_id = ps.pickslip_id
         INNER JOIN cust cust on cust.customer_id = ps.customer_id
         INNER JOIN ship ship on ship.shipping_id = ps.shipping_id
         WHERE ps.picking_status = :pickcing_status 
         <if>AND PSDET.UPC_CODE = :upc_code</if>
              <if>AND ps.vwh_id = :vwh_id</if>
               <if>AND ps.label_id = :label_id</if>
               AND (SHIP.SHIP_DATE &gt;= (SYSDATE - :no_of_days))
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbUpcCode" DbType="String" Name="upc_code" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlStyleLabel" DbType="String" Name="label_id" />
            <asp:ControlParameter ControlID="tbDays" DbType="Int32" Name="no_of_days" />
            <asp:Parameter Name="pickcing_status" DbType="String" DefaultValue="<%$ Appsettings:PickStatusTrnsfrd %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--GridView--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        DataSourceID="ds" DefaultSortExpression="PICKSLIP_ID">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="PICKSLIP_ID" HeaderText="Pickslip" HeaderToolTip="Picklsip Id"
                SortExpression="PICKSLIP_ID" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO" HeaderToolTip="PO Id"
                SortExpression="PO_ID" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Customer" HeaderToolTip="Customer"
                ToolTipFields="CUSTOMER_ID" ToolTipFormatString="Customer Id: {0}" SortExpression="CUSTOMER_NAME" />
            <eclipse:MultiBoundField DataFields="DC_ID" HeaderText="DC" HeaderToolTip="DC Id"
                SortExpression="DC_ID" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="STORE_ID" HeaderText="Store" HeaderToolTip="Store Id"
                SortExpression="STORE_ID" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" HeaderToolTip="Virtual Warehouse"
                SortExpression="VWH_ID" ItemStyle-HorizontalAlign="Left" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

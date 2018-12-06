<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Cartons In Examining Area" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3933 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R30_03.aspx $
 *  $Id: R30_03.aspx 3933 2012-07-20 05:18:55Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="List of cartons which have stayed in the examining area for specified number of days or beyond, for a given virtual warehouse." />
    <meta name="ReportId" content="30.03" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="|This report shows the unshipped carton.|Provided the building and customer filter.|I want to create a report" />
    <meta name="Version" content="$Id: R30_03.aspx 3933 2012-07-20 05:18:55Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <ol>
        <%--<li>Query documentation part needs to be corrected. <strong>[Need Guidance].</strong></li>--%>
    </ol>
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="No of days" />
                <i:TextBoxEx ID="tbDays" runat="server" FriendlyName="Number of days" Text="0" >
                    <Validators>
                        <i:Required />
                        <i:Value ValueType="Integer" Max="180" Min="0" MaxLength="3" />
                    </Validators>
                </i:TextBoxEx>
                <br />
                The list will contain only those cartons which have stayed in the examining area
                for at least these many days.
                <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                 ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true">
       <SelectSql>
       SELECT src.vwh_id AS vwh_id,
			       src.carton_id AS carton_id,
			       src.style AS style,
			       src.color AS color,
			       src.dimension AS dimension,
			       src.sku_size AS sku_size,
			       trunc(SYSDATE - src.modified_date) AS days,
			       (nvl(src.quantity, 0) - nvl(src.quantity_removed, 0)) AS pieces,
			       src.pieces_per_package AS pieces_per_package,
			       src.packaging_preference AS packaging_preference,
			       src.sale_type_id AS sale_type_id,
			       src.price_season_code AS price_season_code
	          FROM src_bundle_inventory src
             WHERE src.sku_storage_area = :inventory_storage_area
               AND (nvl(src.quantity,0) - nvl(src.quantity_removed,0)) &gt;0 
               <if>AND src.vwh_id = :vwh_id</if>
               AND(SYSDATE - src.modified_date) &gt;= :days
       </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbDays" Direction="Input" Name="days" Type="Int32" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
            <asp:Parameter Direction="Input" Name="inventory_storage_area" Type="String" DefaultValue="<%$ Appsettings:ExaminingAreaCode %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="days {0:I};vwh_id;carton_id">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="vwh_id" HeaderText="VWh" SortExpression="vwh_id" />
            <asp:BoundField DataField="carton_id" HeaderText="Carton" SortExpression="carton_id" />
            <asp:BoundField DataField="style" HeaderText="Style" SortExpression="style" />
            <asp:BoundField DataField="color" HeaderText="Color" SortExpression="color" />
            <asp:BoundField DataField="dimension" HeaderText="Dimension" SortExpression="dimension" />
            <asp:BoundField DataField="sku_size" HeaderText="Size" SortExpression="sku_size" />
            <asp:BoundField DataField="days" HeaderText="Days" SortExpression="days" ItemStyle-HorizontalAlign="Right"  DataFormatString="{0:N0}"/>
            <eclipse:MultiBoundField DataFields="pieces" HeaderText="Carton|Pieces" SortExpression="pieces"
                DataSummaryCalculation="ValueSummation" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="pieces_per_package" HeaderText="Carton|Pcs/Pkg"
                SortExpression="pieces_per_package" HeaderToolTip="Pieces Per Package" DataSummaryCalculation="ValueSummation"
                ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" >
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="packaging_preference" HeaderToolTip="Packaging Preference"
                HeaderText="Pkg Pref" SortExpression="packaging_preference" />
            <asp:BoundField DataField="sale_type_id" HeaderText="Sale Type" SortExpression="sale_type_id" />
            <eclipse:MultiBoundField DataFields="price_season_code" HeaderToolTip="Price Season Code"
                HeaderText="Price Season" SortExpression="price_season_code" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

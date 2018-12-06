<%@ Page Title="Reserved Quantity Info Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5935 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_106.aspx $
 *  $Id: R140_106.aspx 5935 2013-08-08 11:50:17Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report gives the reservation information on the particular reservation date and time, for a particular bucket id and reserved pieces in it. " />
    <meta name="ReportId" content="140.106" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R140_106.aspx 5935 2013-08-08 11:50:17Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Area" />
                <oracle:OracleDataSource ID="dsArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                          SELECT DISTINCT resv.IA_ID,
                                 IA.SHORT_NAME||'-'||IA.WAREHOUSE_LOCATION_ID||':'||IA.SHORT_DESCRIPTION AS DESCRIPTION 
                          FROM resvdet resv 
                          left outer join ia ia on resv.ia_id = ia.ia_id
                          WHERE resv.reservation_type = 'I'
                          AND resv.reservation_id &lt;&gt; '$FULLFILLMENT'
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlArea" runat="server" QueryString="PICKING_AREA" DataFields="IA_ID,DESCRIPTION"
                    FriendlyName="Area" DataSourceID="dsArea"
                    DataTextFormatString="{1}" DataValueFormatString="{0}">
                    <Items>
                        <eclipse:DropDownItem Text="All" Value="" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel runat="server" Text="UPC Code" />
                <i:TextBoxEx ID="tbUPCCode" runat="server" QueryString="upc_code" />
                <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"/>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide you the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
        SELECT resv.reservation_id AS bucket_id,
       SUM(resv.pieces_reserved) AS quantity,
       MIN(resv.last_activity_date) AS reservation_date
  FROM resvdet resv 
       left outer join ia ia on resv.ia_id = ia.ia_id
 WHERE ia.picking_area_flag='Y'
   AND resv.reservation_type = 'I'
   <if>AND IA.IA_ID =:PICKING_AREA</if>
   AND resv.reservation_id &lt;&gt; '$FULLFILLMENT'
   <if>AND resv.upc_code = CAST(:upc_code as varchar2(255))</if>
  <if>AND resv.vwh_id = CAST(:vwh_id as varchar2(255))</if> 
 GROUP BY resv.reservation_id
            HAVING SUM(resv.pieces_reserved) &gt; 0 
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlArea" Name="PICKING_AREA" Direction="Input" Type="String" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Direction="Input" Type="String" />
            <asp:ControlParameter ControlID="tbUPCCode" Name="upc_code" Direction="Input" Type="String" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="bucket_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="bucket_id" SortExpression="bucket_id" HeaderText="Bucket" />
            <eclipse:MultiBoundField DataFields="quantity" SortExpression="quantity" HeaderText="Quantity"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="reservation_date" SortExpression="reservation_date"
                HeaderText="Reservation Date" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

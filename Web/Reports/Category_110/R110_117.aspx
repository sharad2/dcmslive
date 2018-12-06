<%@ Page Title="In Process Report - Sku Deatil " Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5452 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_117.aspx $
 *  $Id: R110_117.aspx 5452 2013-06-17 09:16:32Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="
    This report shows the detail information of sku for passed box" />
    <meta name="ReportId" content="110.117" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_117.aspx 5452 2013-06-17 09:16:32Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="Box ID" />
               <i:TextBoxEx runat="server" QueryString="ucc128_id" ID="tbUCC128Id" ToolTip="Box ID which you want to see the information" />
               <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlvwh_id" runat="server" QueryString="vwh_id"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--<uc:ButtonBar ID="ctlButtonBar" runat="server" />--%>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
        <SelectSql>
        SELECT BOX.UCC128_ID AS BOX_ID,
               SKU.STYLE AS STYLE,
               SKU.COLOR AS COLOR,
               SKU.DIMENSION AS DIMENSION,
               SKU.SKU_SIZE AS SKU_SIZE,
               SUM(BOXDET.EXPECTED_PIECES) AS EXPECTED_PIECES,
               SUM(BOXDET.CURRENT_PIECES) AS CURRENT_PIECES
          FROM BOX
         INNER JOIN BOXDET ON BOX.UCC128_ID = BOXDET.UCC128_ID
                           AND BOX.PICKSLIP_ID = BOXDET.PICKSLIP_ID
         INNER JOIN MASTER_SKU SKU ON BOXDET.UPC_CODE = SKU.UPC_CODE
         WHERE BOX.UCC128_ID = cast(:UCC128_ID as varchar2(255))
           AND BOX.VWH_ID = cast(:vwh_id as varchar2(255))
         GROUP BY BOX.UCC128_ID, SKU.STYLE, SKU.COLOR, SKU.DIMENSION, SKU.SKU_SIZE
        </SelectSql> 
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbUCC128Id" Type="String" Direction="Input" Name="UCC128_ID" />
            <asp:ControlParameter ControlID="ctlvwh_id" Type="String" Direction="Input" Name="vwh_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AllowSorting="true" DataSourceID="ds" AutoGenerateColumns="false"
        DefaultSortExpression="BOX_ID;$;STYLE;COLOR;DIMENSION;SKU_SIZE" DisplayMasterRow="true"
        ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="BOX_ID" HeaderText="Box ID" SortExpression="BOX_ID" />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" />
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dimension" SortExpression="DIMENSION" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Sku Size" SortExpression="SKU_SIZE" />
            <eclipse:MultiBoundField DataFields="EXPECTED_PIECES" HeaderText="Pieces|Expected"
                SortExpression="EXPECTED_PIECES" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="current_pieces" HeaderText="Pieces|Current"
                SortExpression="current_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

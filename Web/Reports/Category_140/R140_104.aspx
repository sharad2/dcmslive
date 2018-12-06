<%@ Page Title="Pickslip Details" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6605 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_104.aspx $
 *  $Id: R140_104.aspx 6605 2014-03-31 11:04:49Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
     //&lt;summary&gt;
     //When grid is load and main grid show the row then the form view visible ture
     //&lt;/summary&gt;
     //&lt;param name="sender"&gt;&lt;/param&gt;
     //&lt;param name="e"&gt;&lt;/param&gt;

    protected override void OnPreRender(EventArgs e)
    {
        if (gv.Rows.Count > 0)
        {
            fvTotalCountBox.Visible = true;
        }
        else
        {
            fvTotalCountBox.Visible = false;
        }
        base.OnPreRender(e);
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For a particular pickslip id, virtual warehouse, label and customer id this report shows the ordered SKU and their current pieces." />
    <meta name="ReportId" content="140.104" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R140_104.aspx 6605 2014-03-31 11:04:49Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Pickslip" />
                <i:TextBoxEx  ID="tbPickslipId" runat="server" QueryString="pickslip_id">
                    <Validators>
                    
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Customer Id" />
                <i:TextBoxEx ID="tbCustomerId" runat="server" QueryString="customer_id" ToolTip="Use this parameter to retreive data for specific customer" />
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
   <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
            <SelectSql>
            select 
              ps.warehouse_location_id as warehouse_location_id
        from box b
       inner join ps on ps.pickslip_id = b.pickslip_id
       inner join bucket bkt on bkt.bucket_id = ps.bucket_id
       where ps.pickslip_id = :pickslip_id
            </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPickslipId" Name="pickslip_id" Direction="Input" Type="Int64" />
        </SelectParameters>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
    </oracle:OracleDataSource>
    <asp:FormView runat="server" Visible="false" DataSourceID="ds1" ID="fvTotalCountBox"
        CssClass="ui-widget">
        <HeaderTemplate>
            <br />
        </HeaderTemplate>
        <ItemTemplate>
            &nbsp&nbsp&nbsp&nbsp Building :
            <span id="sk" style="padding:2em"><asp:Label ID="Label3" runat="server" Font-Bold="true" Text='<%# Eval("warehouse_location_id") %>' /></span>
        </ItemTemplate>
        <FooterTemplate>
            <br />
        </FooterTemplate>
    </asp:FormView>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
          select b.ucc128_id, 
               ms.style as style,
               ms.color as color,
               ms.dimension as dimension,
               ms.sku_size as sku_size,
               sum(bd.current_pieces) as current_pieces
          from boxdet bd
         inner join box b on bd.pickslip_id = b.pickslip_id
                         and bd.ucc128_id = b.ucc128_id
         inner join ps ps on ps.pickslip_id = b.pickslip_id
         inner join master_sku ms on bd.upc_code = ms.upc_code
         where ps.pickslip_id = :pickslip_id 
         <if>AND ps.label_id=cast(:label_id as varchar2(255))</if>
         <if>AND ps.vwh_id = CAST(:vwh_id as varchar2(255))</if> 
         <if>AND ps.customer_id=CAST(:customer_id as varchar2(255))</if> 
         group by b.ucc128_id, 
                  ms.style,
                  ms.color,
                  ms.dimension,
                  ms.sku_size
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPickslipId" Name="pickslip_id" Direction="Input"
                Type="Int64" />
            <asp:ControlParameter ControlID="ctlLabel" Name="label_id" Direction="Input" Type="String" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Direction="Input" Type="String" />
            <asp:ControlParameter ControlID="tbCustomerId" Type="String" Direction="Input" Name="customer_id" />
            </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="ucc128_id;$;style">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="ucc128_id" SortExpression="ucc128_id" HeaderText="Carton Id" />
            <eclipse:MultiBoundField DataFields="style" SortExpression="style" HeaderText="Style" />
            <eclipse:MultiBoundField DataFields="color" SortExpression="color" HeaderText="Color" />
            <eclipse:MultiBoundField DataFields="dimension" SortExpression="dimension" HeaderText="Dim" />
            <eclipse:MultiBoundField DataFields="sku_size" SortExpression="sku_size" HeaderText="Size" />
            <eclipse:MultiBoundField DataFields="current_pieces" SortExpression="current_pieces"
                HeaderText="Currtent Pieces" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

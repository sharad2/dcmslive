<%@ Page Title="Inventory Transaction Details" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3452 $
 *  $Author: rverma $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_104.aspx $
 *  $Id: R130_104.aspx 3452 2012-05-04 05:59:32Z rverma $
 * Version Control Template Added.
 *
--%>
<script runat="server">
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays the SKU level information for inventory transacted for particular reason code 
    and module code. The report output can be further retrieved by specifying inserted date and also a date range which is 7 days from the specified date. " />
    <meta name="ReportId" content="130.104" />
    <meta name="Version" content="$Id: R130_104.aspx 3452 2012-05-04 05:59:32Z rverma $" />
    <meta name="Browsable" content="false" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Specify date to summarize inventory activity" />
                <i:TextBoxEx ID="tbDate" runat="server" QueryString="insert_date" FriendlyName="Specify date to summarize inventory activity"
                 ToolTip="Enter date for which you wish to see the summary of inventory transaction. ">
                    <Validators>
                        <i:Required ClientMessage="Must specify any date" />
                        <i:Date DateType="Default" />
                    </Validators>
                 </i:TextBoxEx>
                 <br />
                 <i:CheckBoxEx ID="cbLastWeek" runat="server" QueryString="last_week" Text="Show last 7 days transactions"  CheckedValue="W" 
                 ToolTip="Check to see last week transaction with respect to the date specified above." FriendlyName="Show last 7 days transactions" Checked="false" />                  
                <eclipse:LeftLabel runat="server" Text="Reason Code" />
                <i:TextBoxEx ID="tbReasonCode" runat="server" QueryString="reason_code" FriendlyName="Reason Code"
                ToolTip="Enter the reason code for the inventory transaction." />                
                <eclipse:LeftLabel runat="server" Text="Module Code" />
                <i:TextBoxEx ID="tbModuleCode" runat="server" QueryString="module_code" FriendlyName="Module"
                ToolTip="Enter module code for the inventory transaction." />                
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwh" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Check to view records for virtual warehouses" >
                </d:VirtualWarehouseSelector>                
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- Panel to provide the sort control --%>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Button bar used for validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 runat="server" />
    <%--DataSource--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
        SELECT trans.reason_code    AS REASON_CODE,
              trans.module_code           AS MODULE_CODE,
              trans.inserted_by           AS INSERTED_BY,
              trans.insert_date           AS INSERT_DATE,
              trans.style                 AS STYLE,
              trans.color                 AS COLOR,
              trans.dimension             AS DIM,
              trans.sku_size              AS SKU_SIZE,
              trans.vwh_id                AS VWH_ID,
              transdet.transaction_pieces AS TRANSACTION_PCS
              FROM src_transaction trans
              LEFT OUTER JOIN src_transaction_detail transdet ON 
               trans.transaction_id = transdet.transaction_id
              WHERE transdet.transaction_pieces IS NOT NULL
              AND TRANS.REASON_CODE IS NOT NULL
              <if c="not($last_week)">AND trans.INSERT_DATE &gt;= cast(:insert_date as date) AND trans.INSERT_DATE &lt; cast(:insert_date as date) + 1</if>
              <if c="$last_week">AND (trans.INSERT_DATE &gt;= cast(:insert_date as date)- 7 AND trans.INSERT_DATE &lt; cast(:insert_date as date) + 1)</if>
              <if>AND trans.reason_code = cast(:reason_code as varchar2(255))</if>
              <if>AND trans.MODULE_CODE = cast(:module_code as varchar2(255))</if>
              <if>AND trans.VWH_ID = cast(:vwh_id as varchar2(255))</if>             
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbDate" Type="DateTime" Name="insert_date" Direction="Input" />
            <asp:ControlParameter ControlID="tbReasonCode" DbType="String" Name="reason_code" Direction="Input" />
            <asp:ControlParameter ControlID="tbModuleCode" DbType="String" Name="module_code" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" Direction="Input" />
        <asp:ControlParameter ControlID="cbLastWeek" DbType="String" Name="last_week" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--GridView--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="STYLE;COLOR;DIM;SKU_SIZE;INSERT_DATE" EnableViewState="false">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="REASON_CODE" HeaderText="Reason Code" HeaderToolTip="Reason Code" />
            <eclipse:MultiBoundField DataFields="MODULE_CODE" HeaderText="Module" HeaderToolTip="Module Code" />
            <eclipse:MultiBoundField DataFields="INSERTED_BY" HeaderText="Inserted By" SortExpression="INSERTED_BY"
             HeaderToolTip="Inserted By" />
            <eclipse:MultiBoundField DataFields="INSERT_DATE" HeaderText="Insert Date" SortExpression="INSERT_DATE"
             HeaderToolTip="Date inserted on"  /> 
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE"
             HeaderToolTip="Sku Style" /> 
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR"
             HeaderToolTip="Sku Color" /> 
            <eclipse:MultiBoundField DataFields="DIM" HeaderText="Dimension" SortExpression="DIM"
             HeaderToolTip="Sku Dimension" /> 
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE"
             HeaderToolTip="Sku Sizes" /> 
            <eclipse:MultiBoundField DataFields="TRANSACTION_PCS" HeaderText=" Transaction Pieces" SortExpression="TRANSACTION_PCS"
             HeaderToolTip="Transaction Pieces" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" 
             DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" FooterToolTip="Total transaction pieces." /> 
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
             HeaderToolTip="Virtual Warehouse" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

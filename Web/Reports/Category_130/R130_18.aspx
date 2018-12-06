<%@ Page Title="Inventory Transaction Summary " Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3450 $
 *  $Author: rverma $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_18.aspx $
 *  $Id: R130_18.aspx 3450 2012-05-04 05:58:37Z rverma $
 * Version Control Template Added.
 *
--%>
<%--Hyperlink in Matrix field--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays transaction details by reason code against all module codes for a specified date or last week transactions from the specified date." />
    <meta name="ReportId" content="130.18" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_18.aspx 3450 2012-05-04 05:58:37Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="Specify date to summarize inventory activity" />
                <d:BusinessDateTextBox ID="tbDate" runat="server" QueryString="insert_date" Text="0"
                    ToolTip="Enter date for which you wish to see the summary of inventory transaction. "
                    FriendlyName="Specify date to summarize inventory activity">
                    <Validators>
                        <i:Required ClientMessage="Must specify any date" />
                        <i:Date DateType="Default" />
                    </Validators>
                </d:BusinessDateTextBox>
                <br />
                <i:CheckBoxEx ID="cbLastWeek" runat="server" QueryString="last_week" Text="Show last week transactions"
                    ToolTip="Check to see last week transaction with respect to the date specified above."
                    Checked="false" FriendlyName="Show last seven days transactions" CheckedValue="W" />
                <%--Mutually Exclusive parameters--%>
                <eclipse:LeftLabel ID="lblVwh" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwh" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    FriendlyName="Virtual Warehouse" ToolTip="Check to view records for virtual warehouses">
                </d:VirtualWarehouseSelector>
                <eclipse:LeftLabel runat="server" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Button bar used for all the buttons--%>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
            SELECT trans.vwh_id AS VWH_ID,
            trans.reason_code AS REASON_CODE,
            trans.module_code AS MODULE_CODE,
            sum(transdet.transaction_pieces) AS QTY
        FROM src_transaction trans LEFT OUTER JOIN src_transaction_detail transdet
        ON trans.transaction_id = transdet.transaction_id
        WHERE trans.reason_code is not null
        <if c="not($last_week)">AND (trans.INSERT_DATE &gt;= cast(:insert_date as date) AND trans.INSERT_DATE &lt; cast(:insert_date as date) +1) </if>
        <if c="$last_week">AND (trans.INSERT_DATE &gt;= cast(:insert_date as date) - 7 AND trans.INSERT_DATE &lt; cast(:insert_date as date) + 1)</if>
        <if>AND trans.vwh_id = cast(:vwh_id as varchar2(255))</if>
        AND transdet.transaction_pieces is not null
        GROUP BY trans.vwh_id, trans.reason_code, trans.module_code
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbDate" Type="DateTime" Name="insert_date" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" Direction="Input" />
            <asp:ControlParameter ControlID="cbLastWeek" DbType="String" Name="last_week" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="REASON_CODE;MODULE_CODE;vwh_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="REASON_CODE" AppliedFiltersControlID="ctlButtonBar$af"
                HeaderText="Reason Code" HeaderToolTip="Reason Codes" DataNavigateUrlFields="REASON_CODE,MODULE_CODE,VWH_ID"
                DataNavigateUrlFormatString="R130_104.aspx?reason_code={0}&module_code={1}&vwh_id={2}"
                SortExpression="REASON_CODE" />
            <eclipse:MultiBoundField DataFields="MODULE_CODE" HeaderText="Module" HeaderToolTip="Module Code"
                SortExpression="MODULE_CODE" />
            <eclipse:MultiBoundField DataFields="QTY" HeaderText="Qty" HeaderToolTip="Transaction Pieces"
                DataSummaryCalculation="ValueSummation" FooterToolTip="Total Pieces" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                SortExpression="QTY" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" HeaderToolTip="Virtual Warehouse"
                SortExpression="VWH_ID" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

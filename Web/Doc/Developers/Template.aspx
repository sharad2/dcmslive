<%@ Page Title="Template" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 28752 $
 *  $Author: ssinghal $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: Template.aspx 28752 2009-11-24 03:46:15Z ssinghal $
 * Version Control Template Added.
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report serves as a template for following the basic design to be used by all the reports" />
    <meta name="ReportId" content="1.2" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: Template.aspx 28752 2009-11-24 03:46:15Z ssinghal $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="LeftLabel" />
                <i:TextBoxEx ID="EnhancedTextBox1" runat="server" QueryString="po_id">
                    <Validators>
                    <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowALl="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" />
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" />
                <d:BuildingSelector ID="BuildingSelector1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" />
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
    <%--Provide the data source for quering the data for the report, the datasource should always be placed above the display 
            control since query execution time is displayed where the data source control actaully is on the page,
            while writing the select query the alias name must match with that of database column names so as to avoid 
            any confusion, for details of control refer OracleDataSource.htm with in doc folder of EclipseLibrary.Oracle--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true" >
        <SelectSql>
        select * from tab_inventory_area
        </SelectSql>
        <SelectParameters>
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="true" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="inventory_storage_area">
        <Columns>
            <eclipse:SequenceField />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

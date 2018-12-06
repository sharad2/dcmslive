<%@ Page Title="V2P Productivity Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6852 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R150_09.aspx 6852 2014-05-19 12:02:57Z skumar $
 * Version Control Template Added.
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays VAS productivity for a given operation date or date range" />
    <meta name="ReportId" content="150.09" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R150_09.aspx 6852 2014-05-19 12:02:57Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel9" runat="server" Text="V2P Date" />
                From:
                <d:BusinessDateTextBox ID="dtfromvas" runat="server" FriendlyName="V2P Date From" QueryString="VAS Date From" ToolTip="You can specify the date or date range to see the V2P productivity for this date or date range."
                    Text="-7">
                    <Validators>
                        <i:Date />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                 <d:BusinessDateTextBox ID="dttovas" runat="server" FriendlyName="V2P Date To" QueryString="VAS Date To" ToolTip="You can specify the date or date range to see the V2P productivity for this date or date range."
                     Text="0">
                     <Validators>
                         <i:Date />
                     </Validators>
                 </d:BusinessDateTextBox>
                <br />
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
        CancelSelectOnNullParameter="true">
        <SelectSql>
      SELECT  trunc(A.DATE_CREATED) AS V2P_Date,
        A.CREATED_BY AS Operator,
        rtrim(SYS.STRAGG(UNIQUE B.description || ','),',') AS Applied_VAS,
        COUNT(DISTINCT A.UCC128_ID) AS Boxes_Scanned,
        MIN(A.DATE_CREATED) AS First_BOX_Scanned_on,
        MAX(A.DATE_CREATED) AS Last_BOX_Scanned_on,
        ROUND((MAX(A.DATE_CREATED) - MIN(A.DATE_CREATED)) * 24, 2) AS Hours,
        sum(bd.current_pieces) as total_pieces
   FROM BOX_VAS A
   left outer join boxdet bd
   on a.ucc128_id = bd.ucc128_id
   INNER JOIN tab_vas b
   ON a.BOX_PROCESS_CODE = b.vas_code
  WHERE 1=1 
     <if>and a.DATE_CREATED &gt; = CAST(:vas_date_from AS DATE)</if>
     <if>AND a.DATE_CREATED &lt; = CAST(:vas_date_to AS DATE) +1</if>
  GROUP BY TRUNC(A.DATE_CREATED), A.CREATED_BY
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtfromvas" Type="DateTime" Direction="Input" Name="vas_date_from" />
            <asp:ControlParameter ControlID="dttovas" Type="DateTime" Direction="Input" Name="vas_date_to" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="V2P_Date;$;First_BOX_Scanned_on">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="V2P_Date" HeaderText="V2P Date" SortExpression="V2P_Date" DataFormatString="{0:d}" HeaderToolTip="Date on which the VAS was applied."></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Operator" HeaderText="Operator" SortExpression="Operator" HeaderToolTip="Person who applied VAS."></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Applied_VAS" HeaderText="Applied VAS" SortExpression="Applied_VAS" HeaderToolTip="Description of the VAS type applied."></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="First_BOX_Scanned_on" HeaderText="First Box Scanned on" SortExpression="First_BOX_Scanned_on" HeaderToolTip="Date on which the first box was scanned."></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Last_BOX_Scanned_on" HeaderText="Last Box Scanned on" SortExpression="Last_BOX_Scanned_on" HeaderToolTip="Date on which the last box was scanned."></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Boxes_Scanned" HeaderText="V2P completed on |#Boxes" SortExpression="Boxes_Scanned" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="No. of boxes scanned." DataSummaryCalculation="ValueSummation"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_pieces" HeaderText="V2P completed on | Pieces" SortExpression="total_pieces" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="No. of pieces." DataSummaryCalculation="ValueSummation"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Hours" HeaderText="Hours" SortExpression="Hours" ItemStyle-HorizontalAlign="Right" HeaderToolTip="Hours between the first and last VAS was applied."></eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Title="R40_02.Cartons on location report." Language="C#" MasterPageFile="~/MasterPage.master" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3943 $
 *  $Author: hsingh $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_02.aspx $
 *  $Id: Template.aspx 28752 2009-11-24 03:46:15Z ssinghal $
 * Version Control Template Added.
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report serves as a template for following the basic design to be used by all the reports" />
    <meta name="ReportId" content="40.02"/>
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: Template.aspx 28752 2009-11-24 03:46:15Z ssinghal $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
           <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Start location" />
                <i:TextBoxEx ID="EnhancedTextBox1" FriendlyName="Start location" runat="server">
                    </i:TextBoxEx>
                    Till Location                                  
                    <i:TextBoxEx ID="TextBoxEx1" FriendlyName="End location" runat="server">
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
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true" >
        <SelectSql>
       SELECT MAX(MSL.STORAGE_AREA) AS AREA,
       MSL.LOCATION_ID AS WHOLE_LOCATION,
       (CASE
         WHEN MAX(T.LOCATION_ID) IS NULL THEN
          'EMPTY'
         ELSE
          'LOADED'
       END) AS LOCATION_id
  FROM SRC_CARTON T
RIGHT OUTER JOIN MASTER_STORAGE_LOCATION MSL
    ON T.LOCATION_ID = MSL.LOCATION_ID
   AND T.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
WHERE MSL.LOCATION_ID BETWEEN :Startlocation AND :Tilllocation
GROUP BY MSL.LOCATION_ID
        </SelectSql>
        <SelectParameters>
        <asp:ControlParameter Name="Startlocation" ControlID="EnhancedTextBox1" Direction="Input"  Type="String"/>
       
       <asp:ControlParameter Name="Tilllocation" ControlID="TextBoxEx1"  Direction="Input"  Type="String"/>
        </SelectParameters> 
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="LOCATION_id">
        <Columns>
            <eclipse:SequenceField />
             <eclipse:MultiBoundField DataFields="AREA" HeaderText="Area" SortExpression="AREA"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="WHOLE_LOCATION" HeaderText="Location" SortExpression="WHOLE_LOCATION"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="LOCATION_id" HeaderText="Empty location" SortExpression="LOCATION_id"></eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

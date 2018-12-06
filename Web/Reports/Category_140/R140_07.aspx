<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Corrugate Usage Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4832 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_07.aspx $
 *  $Id: R140_07.aspx 4832 2013-01-10 07:23:50Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">


    protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (string.IsNullOrEmpty(ctlWhLoc.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide select at least one building.";
            return;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report shows the corrugate used by the expeditor for given date range for the warehouse location." />
    <meta name="ReportId" content="140.07" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R140_07.aspx 4832 2013-01-10 07:23:50Z skumar $" />
    
<script type="text/javascript">
    function ctlWhLoc_OnClientChange(event, ui) {
        if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {
            $('#cbSpecificBuilding').attr('checked', 'checked');
        } else {
            $('#cbSpecificBuilding').removeAttr('checked', 'checked');
        }
    }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Check Date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From" Text="0">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To" Text="0">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <%--<eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Warehouse Location" />
                <d:BuildingSelector runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:BuildingSelector>--%>
              <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server"  Text="Check For Specific Building"/>
                    <i:CheckBoxEx ID="cbSpecificBuilding" runat="server" FriendlyName="Specific Building">
                         <Validators>
                            <i:Custom OnServerValidate="cbSpecificBuilding_OnServerValidate" />
                        </Validators>
                    </i:CheckBoxEx>
                </eclipse:LeftPanel>

                <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                             SELECT TWL.WAREHOUSE_LOCATION_ID,
                                   (TWL.WAREHOUSE_LOCATION_ID || ':' || TWL.DESCRIPTION) AS DESCRIPTION
                            FROM TAB_WAREHOUSE_LOCATION TWL
                            ORDER BY 1
                    </SelectSql>
                </oracle:OracleDataSource>
                
                <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                    QueryString="building" OnClientChange="ctlWhLoc_OnClientChange">
                </i:CheckBoxListEx>



            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" >
<SelectSql>
SELECT COUNT(distinct boxprod.ucc128_id) AS number_of_cartons,
       boxprod.case_id AS case_id,
       boxprod.warehouse_location_id AS warehouse_location_id
  FROM box_productivity boxprod
 WHERE boxprod.operation_code = '$CTNEXP'
   AND boxprod.operation_start_date &gt;= cast(:operation_start_date_from AS DATE)
   AND boxprod.operation_start_date &lt;
       cast(:operation_start_date_to AS DATE)  + 1
       <%--<if>AND boxprod.warehouse_location_id=:WhLoc</if>--%>
    <if>AND <a pre="BOXPROD.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WhLoc</a></if>
 GROUP BY boxprod.case_id, boxprod.warehouse_location_id
</SelectSql>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="WhLoc" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="warehouse_location_id;case_id"
        Visible="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="case_id" SortExpression="case_id" HeaderText="Carton Type"
                HeaderToolTip="Type of cartons">
            </eclipse:MultiBoundField>
             <eclipse:MultiBoundField DataFields="number_of_cartons" SortExpression="number_of_cartons"
                HeaderToolTip="Count of cartons available for given carton type" HeaderText="No. Of Cartons"
                 DataSummaryCalculation="ValueSummation" FooterToolTip="Sum of cartons" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="warehouse_location_id" SortExpression="warehouse_location_id"
                HeaderToolTip="Warehouse location of the carton type" HeaderText="Warehouse Location">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

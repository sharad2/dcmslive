<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Restock and Suspense Carton Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_103.aspx $
 *  $Id: R150_103.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Multiple data sources and grids.--%>
<script runat="server">            
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateWhere = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateWhere$", string.Format(" AND {0} = :{1}", strShiftDateWhere, "shift_start_date"));
    }
    protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (cbSpecificBuilding.Checked && string.IsNullOrEmpty(ctlWhLoc.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide select at least one building.";
            return;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This Report display the details of Restock and Suspense cartons on the basis of particular restocker,Warehouse ID, date and process id." />
    <meta name="ReportId" content="150.103" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_103.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Restocker" />
                <i:TextBoxEx runat="server" ID="tbRestocker" QueryString="operator">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Process ID" />
                <i:TextBoxEx runat="server" ID="tbProcessID" QueryString="process_id">
                    <Validators>
                        <i:Required />
                        <i:Value ValueType="Integer" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Restock Date" />
                <d:BusinessDateTextBox ID="dtRestockDate" runat="server" FriendlyName="Restock Date"
                    QueryString="shift_start_date" Text="0">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwhID" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    QueryString="vwh_id" ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:VirtualWarehouseSelector>
               <%-- <eclipse:LeftLabel ID="leftLabel5" runat="server" Text="Warehouse Loaction" />--%>
             <%--   <d:BuildingSelector ID="ctlWhloc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:BuildingSelector>  --%>
                <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server"  Text="Check For Specific Building"/>
                    <i:CheckBoxEx ID="cbSpecificBuilding" runat="server" FriendlyName="Specific Building">
                         <Validators>
                            <i:Custom OnServerValidate="cbSpecificBuilding_OnServerValidate" />
                        </Validators>
                    </i:CheckBoxEx>
                </eclipse:LeftPanel>

                <oracle:OracleDataSource ID="dsAvailableInventory" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                           SELECT TWL.WAREHOUSE_LOCATION_ID,
                                   (TWL.WAREHOUSE_LOCATION_ID || ':' || TWL.DESCRIPTION) AS DESCRIPTION
                            FROM TAB_WAREHOUSE_LOCATION TWL
                            ORDER BY 1

                    </SelectSql>
                </oracle:OracleDataSource>
                
                <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsAvailableInventory" FriendlyName="Building "
                    QueryString="building" OnClientChange="ctlWhLoc_OnClientChange">
                </i:CheckBoxListEx>


               
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <br />
    <oracle:OracleDataSource ID="ds" runat="server"
        ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
         CancelSelectOnNullParameter="true" OnSelecting="ds_Selecting"> 
<SelectSql>
SELECT /*+ index (bp BOXPROD_P_OPERTATION_START_I)*/
 sum(bp.num_of_pieces) AS num_of_pieces,
 bp.vwh_id AS vwh_id,
 max(bp.warehouse_location_id) AS warehouse_location_id,
 bp.ucc128_id AS ucc128_id,
 sum(bp.num_of_units) AS num_of_units,
 max(bp.label_id) AS label_id,
 bp.operation_end_date AS operation_end_date
  FROM box_productivity bp
 WHERE bp.outcome = 'RESTOCKED'
   AND bp.operation_code = '$RST'
   AND bp.operation_start_date between :shift_start_date -1 and :shift_start_date + 2
   <![CDATA[
    $ShiftDateWhere$                     
    ]]> 
   AND bp.operator = :operator
   AND bp.process_id = :process_id
   <if>AND bp.vwh_id = :vwh_id</if>
 <%-- <if>AND bp.warehouse_location_id = :warehouse_location_id</if>--%>
    <if>AND <a pre="bp.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
 GROUP BY bp.vwh_id, bp.ucc128_id, bp.operation_end_date
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbRestocker" Type="String" Direction="Input" Name="operator" />
            <asp:ControlParameter ControlID="dtRestockDate" Type="DateTime" Direction="Input"
                Name="shift_start_date" />
            <asp:ControlParameter ControlID="tbProcessID" Direction="Input" Type="Int32" Name="process_id" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DefaultSortExpression="operation_end_date"
        DataSourceID="ds" AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true"
        Caption="Following are Restocked Cartons:" CaptionAlign="Left">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual warehouse">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="operation_end_date" HeaderText="Scan Time" DataFormatString="{0:MM/dd/yyyy hh:mm tt}"
                HeaderToolTip="Restocking end time for a session" SortExpression="operation_end_date">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ucc128_id" HeaderText="Carton" SortExpression="ucc128_id"
                HeaderToolTip="Carton on which restock operation was performed">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label ID of the restocked SKUs">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="num_of_pieces" HeaderText="Number of Pieces"
                HeaderToolTip="These are the pieces which are restocked by a restocker on a particular date in all sessions"
                FooterToolTip="Sum of restocked pieces" SortExpression="num_of_pieces" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="num_of_units" HeaderText="Number of Units" SortExpression="num_of_units"
                HeaderToolTip="These are the units which are  restocked by a restocker on a particular date in all sessions"
                FooterToolTip="Sum of restocked units" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
    <br />
    <br />
    <oracle:OracleDataSource ID="ds1" runat="server"
        ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
         CancelSelectOnNullParameter="true" OnSelecting="ds_Selecting">
<SelectSql>
SELECT /*+ index (bp boxprod_operation_start_date_i)*/
 sum(bp.num_of_pieces) AS num_of_pieces,
 bp.ucc128_id AS ucc128_id,
 bp.vwh_id AS vwh_id,
 max(bp.warehouse_location_id) AS warehouse_location_id,
 sum(bp.num_of_units) AS num_of_units,
 bp.operation_end_date AS operation_end_date
  FROM box_productivity bp
 WHERE bp.outcome = 'CARTON IN SUSPENSE'
   AND bp.operation_code = '$RST'
   AND bp.operation_start_date between :shift_start_date -1 and :shift_start_date + 2
   <![CDATA[
    $ShiftDateWhere$                     
    ]]>
   AND bp.operator = :operator
   AND bp.process_id = :process_id
   <if>AND bp.vwh_id = :vwh_id</if>
<%--  <if>AND bp.warehouse_location_id = :warehouse_location_id</if>--%>
    <if>AND <a pre="bp.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
 GROUP BY bp.ucc128_id, bp.vwh_id, bp.operation_end_date
</SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbRestocker" Type="String" Direction="Input" Name="operator" />
            <asp:ControlParameter ControlID="dtRestockDate" Type="DateTime" Direction="Input"
                Name="shift_start_date" />
            <asp:ControlParameter ControlID="tbProcessID" Direction="Input" Type="String" Name="process_id" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
            </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv1" runat="server" DefaultSortExpression="operation_end_date"
        DataSourceID="ds1" AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true"
        Caption="Following are Suspense Cartons:" CaptionAlign="Left">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual warehouse">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="operation_end_date" HeaderText="Scan Time" DataFormatString="{0:MM/dd/yyyy hh:mm tt}"
                HeaderToolTip="Restocking end time for a session" SortExpression="operation_end_date">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ucc128_id" HeaderText="Carton" SortExpression="ucc128_id"
                HeaderToolTip="Carton on which restock operation was performed">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="num_of_pieces" HeaderText="Number of Pieces"
                HeaderToolTip="These are the pieces which are sent in suspense by a restocker in all sessions on a particular date"
                FooterToolTip="Sum of pieces in suspense" SortExpression="num_of_pieces" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="num_of_units" HeaderText="Number of Units" SortExpression="num_of_units"
                HeaderToolTip="These are the units which are sent in suspense by a restocker in all sessions on a particular date"
                FooterToolTip="Sum of units in suspense" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

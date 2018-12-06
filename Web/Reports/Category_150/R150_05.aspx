<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Checker Productivity Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_05.aspx $
 *  $Id: R150_05.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift and Master Detail pattern--%>
<script runat="server"> 
  
   
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhere, "shift_number"));
        }
         
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
    <meta name="Description" content="This report also shows the summary of each checker for a given date or date range and also on shift bases. " />
    <meta name="ReportId" content="150.05" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R150_05.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Operation date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From" Text="-7" ToolTip="Please specify a date or date range here.">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To" Text="0" ToolTip="Please specify a date or date range here. ">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <%-- From
                <dcms:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From"
                    Required="true" RelativeDate="-7" ToolTip="Please specify a date or date range here. " />
                To
                <dcms:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To"  AssociatedFromControlID="dtFrom"
                    RelativeDate="0" ToolTip="Please specify a date or date range here. " />--%>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
             <%--   <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Warehouse Loaction" />--%>
                <%--<d:BuildingSelector ID="ctlWhloc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true">
                </d:BuildingSelector>--%>
              <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server"  Text="Check For Specific Building"/>
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
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting" >
 <SelectSql>
 with Chk_Productivity AS (
SELECT bp.process_id,
       bp.ucc128_id,
       bp.operator,
       count(distinct bp.ucc128_id) OVER(PARTITION BY  bp.operator, bp.process_id) as count_cartons,
       count(distinct bp.pickslip_id) OVER(PARTITION BY  bp.operator, bp.process_id) as count_pickslips,
       min(bp.operation_start_date) OVER(PARTITION BY  bp.operator, bp.process_id) as start_time,
       max(bp.operation_end_date) OVER(PARTITION BY  bp.operator, bp.process_id) as end_time,
       max(bp.operation_start_date) OVER(PARTITION BY bp.operator, bp.process_id, bp.ucc128_id) as max_start_date,
       bp.num_of_pieces AS num_of_pieces,
       sum(bp.num_of_upc_scans) over(partition by bp.operator, bp.process_id) as sum_num_of_upc_scans,
       sum(bp.num_of_coo_scans) over(partition by bp.operator, bp.process_id) as sum_num_of_coo_scans,
       sum(bp.num_of_qty_mode_scans) over(partition by bp.operator, bp.process_id) as sum_num_of_qty_mode_scans,
       sum(bp.number_of_unscans) over(partition by bp.operator, bp.process_id) as sum_number_of_unscans,
       ROW_NUMBER() OVER(PARTITION BY bp.operator, bp.process_id, bp.ucc128_id ORDER BY bp.operation_start_date DESC) as row_sequence,
       max(au.created) OVER(PARTITION BY  bp.operator, bp.process_id) as user_setup_date   
  FROM box_productivity bp
  LEFT OUTER JOIN all_users au on au.username = bp.operator  
 WHERE bp.operation_code = '$CHECKING'
   AND bp.operation_start_date &gt;= CAST(:operation_start_date_from AS DATE)
   AND bp.operation_start_date &lt; CAST(:operation_start_date_to AS DATE) + 1
   <![CDATA[
   $ShiftNumberWhere$
   ]]>
  <%-- <if>AND bp.warehouse_location_id = :warehouse_location_id</if>--%>
     <if>AND <a pre="BP.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
)
SELECT cp.operator AS operator,
       cp.process_id AS process_id,      
       trunc(cp.max_start_date) AS max_start_date,
       MAX(cp.start_time) as start_time,
       MAX(cp.end_time) as end_time,
       NVL(MAX(cp.count_cartons),0) AS count_cartons,
       NVL(MAX(cp.count_pickslips),0) AS count_pickslips,
       NVL(SUM(cp.num_of_pieces),0) AS num_of_pieces,
       NVL(MAX(cp.sum_num_of_upc_scans),0) AS sum_num_of_upc_scans,
       NVL(MAX(cp.sum_num_of_coo_scans),0) AS sum_num_of_coo_scans,       
       NVL(MAX(cp.sum_num_of_qty_mode_scans),0) AS sum_num_of_qty_mode_scans, 
       NVL(MAX(cp.sum_number_of_unscans),0) AS sum_number_of_unscans,
       MAX(cp.user_setup_date) as user_setup_date  
  FROM Chk_Productivity cp
 WHERE cp.row_sequence = 1
 GROUP BY cp.operator, cp.process_id,trunc(cp.max_start_date)

 </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="False" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="operator;$;process_id" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="operator" HeaderText="Operator Name" SortExpression="operator" />
            <eclipse:MultiBoundField DataFields="process_id" HeaderText="Session ID" SortExpression="process_id"
                HeaderToolTip="Session ID of the checker">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
           <%-- <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Warehouse Location" SortExpression="warehouse_location_id"> 
            </eclipse:MultiBoundField>--%>
            <eclipse:MultiBoundField DataFields="max_start_date" HeaderText="Operation Date"
                SortExpression="max_start_date" DataFormatString="{0:d}" HeaderToolTip="Date on which checking operation was performaed" />
            <eclipse:MultiBoundField DataFields="start_time" HeaderText="Time|Start" SortExpression="start_time"
                DataFormatString="{0:HH:mm:ss}" HeaderToolTip="Checking start time for a session" />
            <eclipse:MultiBoundField DataFields="end_time" HeaderText="Time|End" SortExpression="end_time"
                DataFormatString="{0:HH:mm:ss}" HeaderToolTip="Checking end time for a session" />
            <eclipse:MultiBoundField DataFields="count_pickslips" HeaderText="Number of|PDs"
                HeaderToolTip="Number of pickslips checked by a particular checker on a particular date"
                DataFooterFormatString="{0:N0}" SortExpression="count_pickslips" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Count of pickslips">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="count_cartons" HeaderText="Number of|Boxes"
                HeaderToolTip="Number of boxes checked by a particular checker on a particular date"
                DataFooterFormatString="{0:N0}" SortExpression="count_cartons" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Count of boxes">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="num_of_pieces" HeaderText="Number of|Pieces"
                HeaderToolTip="Number of pieces checked by a particular checker on a particular date"
                DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" SortExpression="num_of_pieces"
                FooterToolTip="Sum of pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sum_num_of_upc_scans" HeaderText="Number of Scans|UPC"
                HeaderToolTip="Number of UPC scans done by a particular checker on a particular date"
                DataFooterFormatString="{0:N0}" SortExpression="sum_num_of_upc_scans" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Sum of UPC scans">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sum_num_of_coo_scans" HeaderText="Number of Scans|COO"
                DataFooterFormatString="{0:N0}" HeaderToolTip="Number of COO(Country Of Origin)scans done by a particular checker on a particular date"
                DataSummaryCalculation="ValueSummation" SortExpression="sum_num_of_coo_scans"
                FooterToolTip="Sum of COO scans">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sum_num_of_qty_mode_scans" HeaderText="Number of Scans|Qty"
                DataFooterFormatString="{0:N0}" HeaderToolTip="Number of quantity mode scans done by a particular checker on a particular date"
                SortExpression="sum_num_of_qty_mode_scans" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Sum of quantity scans">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sum_number_of_unscans" HeaderText="Number of Scans|UnScans"
                HeaderToolTip="Number of quantity mode unscans done by a particular checker on a particular date"
                SortExpression="sum_number_of_unscans" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of unscans">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date"
                HeaderToolTip="User created date" SortExpression="user_setup_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

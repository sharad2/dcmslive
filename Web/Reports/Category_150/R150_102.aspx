<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Expeditor Productivity Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_102.aspx $
 *  $Id: R150_102.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern --%>
<script runat="server"> 
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));
        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause, "shift_number"));
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
<asp:Content ID="Content3" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report shows the productivity of each expeditor 
    for a given date or date range. You can further filter, on the basis of Shift, first or 
    second shift of work and have the option of specifying custom date range. " />
    <meta name="ReportId" content="150.102" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_102.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
<asp:Content ID="Content4" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Expeditor" />
                <i:TextBoxEx runat="server" ID="tbExpeditor" QueryString="operator">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Operation Date" />
                <d:BusinessDateTextBox ID="dtOperation" runat="server" FriendlyName="Operation Date"
                    Text="0" QueryString="shift_start_date">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
               <%-- <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Warehouse Location" />
               d:BuildingSelector ID="ctlWhloc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                  >
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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsAvailableInventory" FriendlyName="Building"
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
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting">
<SelectSql>
with operator as
 (select
  max(bp.warehouse_location_id) as warehouse_location_id,
         bp.mpc_id as mpc_id,
         <![CDATA[
         $ShiftDateSelectClause$
         ]]>,
         min(bp.operation_start_date) AS operation_start_date,
         max(bp.operation_end_date) AS operation_end_date,
         (max(bp.operation_end_date) - min(bp.operation_start_date)) * 24 AS total_time_worked,
        
         COUNT(DISTINCT(CASE
                          WHEN bp.outcome = 'COMPLETED' THEN
                           bp.ucc128_id
                        END)) AS count_cartons,
         COUNT(DISTINCT(CASE
                          WHEN bp.outcome = 'UNDERPITCH' THEN
                           bp.ucc128_id
                        END)) AS underpitch_cartons,
         COUNT(CASE
                 WHEN bp.outcome = 'INVALIDSCAN' THEN
                  bp.ucc128_id
               END) AS unexpected_scans
  
    FROM box_productivity bp
   WHERE bp.operation_code = '$CTNEXP'
     AND bp.operator = :operator
     AND bp.operation_start_date &gt;= CAST(:operation_date AS DATE) 
     AND bp.operation_start_date &lt; CAST(:operation_date AS DATE)  + 2
     <![CDATA[
     $ShiftNumberWhere$
     ]]>
     <%--<if>AND bp.warehouse_location_id =:warehouse_location_id</if>--%>
    <if>AND <a pre="bp.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   group by  bp.operation_start_date, bp.mpc_id)
select 
max(operator.warehouse_location_id) as warehouse_location_id,
       operator.mpc_id as mpc_id,
       min(operator.operation_start_date) as operation_start_date,
       max(operator.operation_start_date) as operation_end_date,
        max(operator.shift_start_date) as shift_start_date,
       round(sum(operator.total_time_worked), 4) as total_time_worked,
       sum(operator.count_cartons) as count_cartons,
       sum(operator.underpitch_cartons) as underpitch_cartons,
       sum(operator.unexpected_scans) as unexcepted_scans
  from operator 
 WHERE operator.shift_start_date &gt;=CAST(:operation_date AS DATE) 
   AND operator.shift_start_date &lt; CAST(:operation_date AS DATE)  + 1
 group by operator.mpc_id
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtOperation" Type="DateTime" Direction="Input" Name="operation_date" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number"
                ConvertEmptyStringToNull="true" />
            <asp:ControlParameter ControlID="tbExpeditor" Type="String" Direction="Input" Name="operator" />
             <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="mpc_id;shift_start_date" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="mpc_id" HeaderText="MPC" SortExpression="mpc_id"
                HeaderToolTip="MPC on whcih expeditor worked">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
           <%-- <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Warehouse Location" SortExpression="warehouse_location_id">
            </eclipse:MultiBoundField>--%>
            <eclipse:MultiBoundField DataFields="operation_start_date" HeaderText="Start Time"
                SortExpression="operation_start_date" HeaderToolTip="Time when expeditor started work"
                DataFormatString="{0:MM/dd/yyyy HH:mm:ss}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="operation_end_date" HeaderText="End Time" SortExpression="operation_end_date"
                HeaderToolTip="Time when expeditor finished work" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_time_worked" FooterToolTip="Sum of total hours worked"
                HeaderText="Total Hrs. Worked" SortExpression="total_time_worked" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N4}" DataFooterFormatString="{0:N4}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="count_cartons" HeaderText="Number of|Cartons"
                SortExpression="count_cartons" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="underpitch_cartons" HeaderText="Number of|Underpitch Cartons"
                HeaderToolTip="Total underpitched cartons in MPC" SortExpression="underpitch_cartons"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" FooterToolTip="Sum of underpitched cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="unexcepted_scans" HeaderText="Number of|Unexcepted Scans"
                HeaderToolTip="Total unexcepted cartons scanned by the user" SortExpression="unexcepted_scans"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" FooterToolTip="Sum of unexcepted cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Restock Productivity Detail Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_101.aspx $
 *  $Id: R150_101.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern --%>
<script runat="server"> 
            
   
   
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateWhereClause = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateWhere$", string.Format("AND {0} = :{1}", strShiftDateWhereClause, "shift_start_date"));
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
    <meta name="Description" content="Report display the restock productivity details of the particular 
    restocker for the specific date,warehouse ID and shift. In this report you can see the work performed by 
    the restocker at session level. You can see how much time was spent in each restock session along with the 
    breakdown of pieces restocked per session. If some carton is in suspense already and the user put that 
    carton in suspense again then, this report claims that it will not consider these duplicate scans. That is, 
    this report will show just one suspense record for such carton. " />
    <meta name="ReportId" content="150.101" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_101.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
                <eclipse:LeftLabel runat="server" Text="Restocker" />
                <i:TextBoxEx runat="server" ID="tbRestocker" QueryString="operator">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Restock Date" />
                <d:BusinessDateTextBox ID="dtRestockDate" runat="server" FriendlyName="Restock Date"
                    QueryString="shift_start_date" Text="0">
                        <Validators>
                            <i:Required />
                        </Validators>
                    </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwhID" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    QueryString="vwh_id" ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:VirtualWarehouseSelector>
                <%-- <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Warehouse Location"  /> 
               <d:BuildingSelector ID="ctlWhloc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" >
                </d:BuildingSelector>--%>
               <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel5" runat="server"  Text="Check For Specific Building"/>
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
          with restock_prod as 
(
SELECT /*+index(bp BOXPROD_P_OPERTATION_START_I)*/bp.operator AS OPERATOR,
       bp.vwh_id AS VWH_ID,
       bp.process_id AS PROCESS_ID,     
       bp.operation_start_date AS operation_start_date,     
       MIN(bp.operation_start_date) over(partition by bp.operator, bp.vwh_id, bp.process_id, trunc(bp.operation_start_date), bp.outcome) AS PROCESS_START_TIME,
       MAX(bp.operation_end_date) over(partition by bp.operator, bp.vwh_id, bp.process_id, trunc(bp.operation_start_date), bp.outcome) AS PROCESS_END_TIME,
       decode(bp.outcome,'RESTOCKED',count(distinct bp.ucc128_id) over(partition by bp.operator,bp.vwh_id,bp.process_id,trunc(bp.operation_start_date),bp.outcome)) AS RESTOCKED_CARTONS,
       decode(bp.outcome,'RESTOCKED',sum(bp.num_of_pieces) over(partition by bp.operator,bp.vwh_id,bp.process_id,trunc(bp.operation_start_date),bp.outcome)) AS RESTOCKED_PIECES,
       decode(bp.outcome,'RESTOCKED',sum(bp.num_of_units) over(partition by bp.operator,bp.vwh_id,bp.process_id,trunc(bp.operation_start_date),bp.outcome)) AS RESTOCKED_UNITS,
       SUM((CASE
                 WHEN bp.outcome = 'RESTOCKED' AND
                      BP.label_id &lt;&gt; :special_label_id THEN
                  bp.num_of_units
               END)) over(partition by bp.operator, bp.vwh_id, bp.process_id, trunc(bp.operation_start_date), bp.outcome) AS restocked_non_mp_units,
       SUM((CASE
             WHEN BP.LABEL_ID = :special_label_id AND BP.OUTCOME = 'RESTOCKED' THEN
              BP.NUM_OF_UNITS
           END)) over(partition by bp.operator, bp.vwh_id, bp.process_id, trunc(bp.operation_start_date), bp.outcome) AS MP_UNITS,
       decode(bp.outcome,'CARTON IN SUSPENSE',count(distinct bp.ucc128_id) over(partition by bp.operator,bp.vwh_id,bp.process_id,trunc(bp.operation_start_date),bp.outcome)) AS CARTONS_IN_SUSPENSE,
       decode(bp.outcome,'CARTON IN SUSPENSE',sum(bp.num_of_pieces) over(partition by bp.operator,bp.vwh_id,bp.process_id,trunc(bp.operation_start_date),bp.outcome)) AS PIECES_IN_SUSPENSE,
       decode(bp.outcome,'CARTON IN SUSPENSE',sum(bp.num_of_units) over(partition by bp.operator,bp.vwh_id,bp.process_id,trunc(bp.operation_start_date),bp.outcome)) AS UNITS_IN_SUSPENSE,
       MAX(bp.label_id) over(partition by bp.operator, bp.vwh_id, bp.process_id, trunc(bp.operation_start_date), bp.outcome) AS LABEL_ID
  FROM box_productivity bp
    WHERE bp.outcome in ('RESTOCKED', 'CARTON IN SUSPENSE')
   AND bp.operation_code = '$RST'
   AND bp.operator = :operator
   AND bp.operation_start_date between :shift_start_date -1 and :shift_start_date + 2
    <![CDATA[
       $ShiftDateWhere$                     
     ]]>
   <![CDATA[
       $ShiftNumberWhere$                     
     ]]>
   <if>AND bp.vwh_id = :vwh_id</if>
   <%--<if>AND bp.warehouse_location_id = :warehouse_location_id</if>--%>
       <if>AND <a pre="bp.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
)
SELECT rp.VWH_ID AS VWH_ID,
       rp.operator AS OPERATOR,
       rp.process_id AS PROCESS_ID,      
       min(rp.process_start_time) AS PROCESS_START_TIME,
       max(rp.process_end_time) AS PROCESS_END_TIME,
       round((max(rp.process_end_time) - min(rp.process_start_time)) * 24,4) AS HOURS_WORKED,
       NVL(max(rp.restocked_cartons),0) AS RESTOCKED_CARTONS,
       NVL(max(rp.restocked_pieces),0) AS RESTOCKED_PIECES,
       NVL(max(rp.restocked_units),0) AS RESTOCKED_UNITS,
       NVL(max(rp.mp_units),0) AS MP_UNITS,
       NVL(max(rp.cartons_in_suspense),0) AS CARTONS_IN_SUSPENSE,
       NVL(max(rp.pieces_in_suspense),0) AS PIECES_IN_SUSPENSE,
       NVL(max(rp.units_in_suspense),0) AS UNITS_IN_SUSPENSE,
       max(rp.label_id) AS LABEL_ID,
       NVL(max(RP.restocked_non_mp_units),0) as NON_MP_UNITS,
       trunc(rp.operation_start_date) as operation_start_date
  FROM restock_prod rp
 GROUP BY rp.VWH_ID,
          rp.operator,
          rp.process_id,
          trunc(rp.operation_start_date)
          </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbRestocker" Type="String" Direction="Input" Name="operator" />
            <asp:ControlParameter ControlID="dtRestockDate" Type="DateTime" Direction="Input"
                Name="shift_start_date" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:Parameter Name="special_label_id" Type="String" DefaultValue="<%$  AppSettings: SpecialLabelId  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="process_id" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            
            <eclipse:MultiBoundField DataFields="process_id" HeaderText="Process" SortExpression="process_id"
                HeaderToolTip="Restock process ID">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="operation_start_date" HeaderText="Operation Date"
                HeaderToolTip="This is the date on which restock operation was performed" SortExpression="operation_start_date"
                DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
                HeaderToolTip="Virtual warehouse ID" > </eclipse:MultiBoundField>
           <%--<eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Warehouse Location" SortExpression="warehouse_location_id">
            </eclipse:MultiBoundField>--%>
          
            <eclipse:MultiBoundField DataFields="process_start_time" HeaderText="Start Time"
                HeaderToolTip="Restock start time for a session" SortExpression="process_start_time"
                DataFormatString="{0:HH:mm:ss}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="process_end_time" HeaderText="End Time" HeaderToolTip="Restock end time for a session"
                SortExpression="process_end_time" DataFormatString="{0:HH:mm:ss}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label id of the box which was restocked by the user">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="hours_worked" HeaderText="Total Hrs Worked"
                HeaderToolTip="This is the time which was spent by the particular restocker. This is calculated as (End time - Start time = total worked time)"
                SortExpression="hours_worked" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N4}"
                FooterToolTip="Sum of total time worked">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="restocked_cartons" HeaderText="Restocked|Ctns"
                HeaderToolTip="These are the cartons which are restocked by a particular restocker on a particular date in all session"
                SortExpression="restocked_cartons" DataNavigateUrlFormatString="R150_103.aspx?operator={0}&process_id={1}&vwh_id={2}"
                AppliedFiltersControlID="ButtonBar1$af" DataNavigateUrlFields="operator,process_id,vwh_id"
                DataSummaryCalculation="ValueSummation" FooterToolTip="Sum of restocked cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="restocked_pieces" HeaderText="Restocked|Pcs"
                HeaderToolTip="These are the pieces which are restocked by a restocker on a particular date in all session"
                SortExpression="restocked_pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of restocked pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="restocked_units" HeaderText="Restocked|Units"
                HeaderToolTip="These are the units which are restocked by a restocker on a particular date in all session"
                SortExpression="restocked_units" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of restocked units">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="non_mp_units" HeaderText="Restocked|Non MP Units"
                FooterToolTip="Sum of restocked units of non MP label" SortExpression="non_mp_units"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" HeaderToolTip="These are the units of those cartons which do not belong to label MP">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="mp_units" HeaderText="Restocked|MP Units Only"
                HeaderToolTip="These are the units of those cartons which belong to label MP"
                SortExpression="mp_units" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of restocked units of MP label">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="cartons_in_suspense" HeaderText="Suspense|Ctns"
                HeaderToolTip="These are the cartons which are sent in suspense by a restocker in all sessions on a particular date"
                SortExpression="cartons_in_suspense" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" FooterToolTip="Sum of cartons in suspense">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="pieces_in_suspense" HeaderText="Suspense|Pcs"
                HeaderToolTip="These are the pieces which are sent in suspense by a restocker in all sessions on a particular date"
                SortExpression="pieces_in_suspense" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of pieces in suspense">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="units_in_suspense" HeaderText="Suspense|Units"
                HeaderToolTip="These are the units which are sent in suspense by a restocker in all sessions on a particular date"
                SortExpression="units_in_suspense" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of units in suspense">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Restock Productivity Report" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_02.aspx $
 *  $Id: R150_02.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%@ Import Namespace="System.Linq" %>
<%--Shift Pattern --%>
<script runat="server"> 
            
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));


        string strShiftDateGroupClause = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause$", string.Format("{0}", strShiftDateGroupClause));

        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause, "shift_number"));
        }
        string strShiftDateWhereClause1 = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateWhere1$", string.Format("AND {0} >= {1}", strShiftDateWhereClause1, "cast(:operation_start_date_from AS DATE)"));
        string strShiftDateWhereClause2 = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateWhere2$", string.Format("AND {0} < {1}", strShiftDateWhereClause2,  "cast(:operation_start_date_to AS DATE) + 1"));
       
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
    <meta name="Description" content="This report shows productivity summary of each restocker for the past 7 days for all shifts. You have the option of specifying a custom date range or shift along with the virtual warehouse wise details of the restocker. " />
    <meta name="ReportId" content="150.02" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Report will not crash if sort on 'Number of Restock Pcs' column." />
    <meta name="Version" content="$Id: R150_02.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Restock date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Restock date"
                    Text="-7">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Restock date" Text="0">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <%--  From
                <dcms:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Restock date"
                    Required="true" RelativeDate="-7" />
                To
                <dcms:BusinessDateTextBox ID="dtTo" runat="server" AssociatedFromControlID="dtFrom"
                    FriendlyName="To Restock date" RelativeDate="0" />--%>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwhID" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:VirtualWarehouseSelector>
<%--                <eclipse:LeftLabel ID="Leftlabel4" runat="server" Text="Warehouse Loaction" /> --%>
               <%-- <d:BuildingSelector ID="ctlWhloc" runat="server"  ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
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
          SELECT /*+index(bp BOXPROD_OPERATION_START_DATE_I)*/
               bp.vwh_id AS vwh_id,
               bp.operator AS operator,              
               NVL(COUNT(CASE
                 WHEN bp.outcome = 'RESTOCKED' THEN
                  bp.ucc128_id
               END),0) AS restocked_cartons,
               NVL(SUM(CASE
                 WHEN bp.outcome = 'RESTOCKED' THEN
                  bp.num_of_pieces
               END),0) AS restocked_pieces,
               NVL(SUM (CASE
                 WHEN bp.outcome = 'RESTOCKED' THEN
                  bp.num_of_units
               END),0) AS restocked_num_of_units,
               NVL(SUM(CASE
                 WHEN bp.outcome = 'RESTOCKED' AND
                      BP.label_id &lt;&gt; :special_label_id THEN
                  bp.num_of_units
               END),0) AS restocked_non_mp_units,
               NVL(SUM(CASE
                 WHEN bp.outcome = 'RESTOCKED' AND
                      BP.label_id = :special_label_id THEN
                  bp.num_of_units
               END),0) AS restocked_mp_units,
               NVL(COUNT( DISTINCT CASE
                 WHEN bp.outcome = 'CARTON IN SUSPENSE' THEN
                  bp.ucc128_id
               END),0) AS cartons_in_suspense,
               NVL(SUM(CASE
                 WHEN bp.outcome = 'CARTON IN SUSPENSE' THEN
                  bp.num_of_pieces
               END),0) AS pieces_in_suspense,
               NVL(SUM(CASE
                 WHEN bp.outcome = 'CARTON IN SUSPENSE' THEN
                  bp.num_of_units
               END),0) AS units_in_suspense,
                max(au.CREATED) as user_setup_Date,
                <![CDATA[
                $ShiftDateSelectClause$                     
                ]]>
        FROM box_productivity bp
       
        LEFT OUTER JOIN all_users au on au.username = bp.operator
         WHERE bp.operation_code = '$RST'
         AND bp.operation_start_date &gt;= cast(:operation_start_date_from AS DATE)
         AND bp.operation_start_date &lt; cast(:operation_start_date_to AS DATE) + 2
         <if>AND bp.vwh_id = :vwh_id</if>
        <%-- <if>AND bp.warehouse_location_id = :warehouse_location_id</if>--%>
         <if>AND <a pre="BP.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
          <![CDATA[
                $ShiftNumberWhereClause$                     
                ]]>
                 <![CDATA[
                    $ShiftDateWhere1$                     
                 ]]>
                 <![CDATA[
                    $ShiftDateWhere2$                     
                 ]]>
          GROUP BY vwh_id,
          operator,<![CDATA[
                    $ShiftDateGroupClause$                     
                   ]]>
                   </SelectSql> 
                <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:Parameter Name="special_label_id" Type="String" DefaultValue="<%$  AppSettings: SpecialLabelId  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="operator"
        DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="operator" HeaderText="Restocker Name"
                SortExpression="operator" DataNavigateUrlFormatString="R150_101.aspx?operator={0}&shift_start_date={1:d}&vwh_id={2}"
                DataNavigateUrlFields="operator,shift_start_date,vwh_id" AppliedFiltersControlID="ButtonBar1$af" />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id {0} NULLS FIRST"
                HeaderToolTip="Virtual warehouse ID">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="Restock Date"
                HeaderToolTip="Shift date on which restock operation was performed" SortExpression="shift_start_date"
                DataFormatString="{0:d}" />
           
            <eclipse:MultiBoundField DataFields="restocked_cartons" HeaderText="Number of Restock|Ctns"
                HeaderToolTip="These are the cartons restocked by a restocker on a particular date in all session"
                SortExpression="restocked_cartons" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of restocked cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="restocked_pieces" HeaderText="Number of Restock|Pcs"
                HeaderToolTip="These are the pieces restocked by restocker on a particular date in all session"
                SortExpression="restocked_pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of restocked pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="restocked_non_mp_units" HeaderToolTip="These are the units of those cartons which does not belong to label MP. (Non MP Units = Units - MP Units Only)"
                HeaderText="Number of Restock|Non MP Units" SortExpression="restocked_non_mp_units"
                FooterToolTip="Sum of restocked non MP units" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="restocked_mp_units" HeaderText="Number of Restock|MP Units Only"
                HeaderToolTip="These are the units of those cartons which belong to label MP"
                SortExpression="restocked_mp_units" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of MP units">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="cartons_in_suspense" HeaderText="Number of Suspense|Ctns"
                HeaderToolTip="These are the cartons which are send in suspense by a restocker in all sessions on a particular date"
                SortExpression="cartons_in_suspense" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Sum of cartons in suspense" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="pieces_in_suspense" HeaderText="Number of Suspense|Pcs"
                HeaderToolTip="These are the pieces which are send in suspense by a restocker in all sessions on a particular date"
                SortExpression="pieces_in_suspense" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of pieces in suspense">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="units_in_suspense" HeaderText="Number of Suspense|Units"
                HeaderToolTip="These are the units which are send in suspense by a restocker in all sessions on a particular date"
                SortExpression="units_in_suspense" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                FooterToolTip="Sum of units in suspense">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date"
                SortExpression="user_setup_Date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

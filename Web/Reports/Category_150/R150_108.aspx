<%@ Page Title="Validation Productivity Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5215 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_108.aspx $
 *  $Id: R150_108.aspx 5215 2013-04-12 09:01:42Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern --%>
<script runat="server">
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("b.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));
        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("b.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause, "shift_number"));
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="150.108" />
    <meta name="Description" content="Shows details of the boxes scanned by a validator on a particular validation station on a particular day.  This can also be filtered on shift" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_108.aspx 5215 2013-04-12 09:01:42Z skumar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
        });

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcp" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Work Station" />
                <i:TextBoxEx runat="server" ID="tbWorkStation" QueryString="work_station" ToolTip="System Name on which validation was done." />
                <%--<eclipse:EnhancedTextBox runat="server" ID="tbWorkStation" QueryString="work_station"
                    ToolTip="System Name on which validation was done." />--%>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Operator" />
                <i:TextBoxEx runat="server" ID="tbOperator" QueryString="Operator" ToolTip="Enter the validator name" />
                <%--<eclipse:EnhancedTextBox runat="server" ID="tbOperator" QueryString="Operator" ToolTip="Enter the validator name" />--%>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Validation Date" />
                <d:BusinessDateTextBox ID="dtValidationDate" runat="server" FriendlyName=" Validation Date"
                    Text="0" QueryString="shift_start_date" ToolTip="Enter the date on which validation was done.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="You can select shift to see the validation productivity for the selected shift." />
               <%-- <eclipse:LeftLabel ID="Leftlabel5" runat="server" Text="Warehouse Location" />--%>
                <%--<d:BuildingSelector ID="ctlWhloc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    >
                </d:BuildingSelector>--%>
            </eclipse:TwoColumnPanel>
            <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Building" />
                    <oracle:OracleDataSource ID="dsbuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                        <SelectSql>
                               WITH Q1 AS
                                    (SELECT TWL.WAREHOUSE_LOCATION_ID, TWL.DESCRIPTION
                                     FROM TAB_WAREHOUSE_LOCATION TWL
   
                                     UNION
                                     SELECT 'Unknown' AS WAREHOUSE_LOCATION_ID, 'Unknown' AS DESCRIPTION
                                     FROM TAB_WAREHOUSE_LOCATION TWL)
                                     SELECT Q1.WAREHOUSE_LOCATION_ID,
                                     (Q1.WAREHOUSE_LOCATION_ID || ':' || Q1.DESCRIPTION) AS DESCRIPTION
                                      FROM Q1
                            ORDER BY 1
                        </SelectSql>
                    </oracle:OracleDataSource>

                    <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                        DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsbuilding" FriendlyName="Building"
                        QueryString="building">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>

            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
         OnSelecting="ds_Selecting">
                  <SelectSql>
WITH Q1 AS
 (SELECT B.PROCESS_ID AS PROCESS_ID,
         B.MPC_ID AS MPC_ID,
         B.UCC128_ID AS UCC128_ID,
         B.OPERATION_START_DATE AS OPERATION_START_DATE,
         B.OUTCOME AS OUTCOME,
         B.CARRIER_ID AS CARRIER_ID,
         B.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
         CASE
           WHEN (LAG(DECODE(B.OUTCOME, 'INVALIDATED', B.UCC128_ID))
                 OVER(PARTITION BY B.WORK_STATION,
                      B.OPERATOR, trunc(b.operation_start_date) ORDER BY B.WORK_STATION,
                      B.OPERATOR,
                      B.OPERATION_START_DATE)) IS NULL OR
                (LAG(DECODE(B.OUTCOME, 'INVALIDATED', B.UCC128_ID))
                 OVER(PARTITION BY B.WORK_STATION,
                      B.OPERATOR, trunc(b.operation_start_date) ORDER BY B.WORK_STATION,
                      B.OPERATOR,
                      B.OPERATION_START_DATE)) !=
                DECODE(B.OUTCOME, 'INVALIDATED', B.UCC128_ID) THEN
            DECODE(B.OUTCOME, 'INVALIDATED', B.UCC128_ID)
         END AS RED_BOXES,
         DECODE(B.OUTCOME, 'VALIDATED', B.UCC128_ID) AS GREEN_BOXES,
         <![CDATA[
               $ShiftDateSelectClause$
               ]]>
    FROM BOX_PRODUCTIVITY B
   WHERE B.OPERATION_CODE = '$CTNVERIFY'
     AND B.OUTCOME NOT IN ('INVALIDSCAN', 'VERIFIED')
    <if>AND B.work_station = :work_station</if>
	       <if>AND B.operator = :operator</if>
      <if>AND <a pre="B.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
	       AND B.operation_start_date &gt;= CAST(:validation_start_date AS DATE)
           AND B.operation_start_date &lt; CAST(:validation_start_date AS DATE) + 2
           <![CDATA[
           $ShiftNumberWhereClause$
           ]]>)
SELECT Q1.PROCESS_ID AS PROCESS_ID,
       DECODE(Q1.RED_BOXES, NULL, Q1.GREEN_BOXES, Q1.RED_BOXES) AS BOX_ID,
       DECODE(Q1.MPC_ID, NULL, 'Unknown', Q1.MPC_ID) AS MPC_ID,
       MAX(Q1.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID,
       MIN(Q1.OPERATION_START_DATE) AS SCAN_TIME,
       MIN(CASE
             WHEN Q1.OUTCOME = 'INVALIDATED' THEN
              'TRUE'
           END) AS RED_CARTON_COUNT,
       MIN(CASE
             WHEN q1.CARRIER_ID = '0472' THEN
              'TRUE'
           END) AS UPS_CARTON_COUNT,
       MIN(CASE
             WHEN Q1.OUTCOME = 'VALIDATED' THEN
              'TRUE'
           END) AS GREEN_CARTON_COUNT
  FROM Q1
 WHERE (Q1.RED_BOXES IS NOT NULL OR Q1.GREEN_BOXES IS NOT NULL)
   AND Q1.shift_start_date &gt;= CAST(:validation_start_date AS DATE)
   AND Q1.shift_start_date &lt; CAST(:validation_start_date AS DATE) + 1
 GROUP BY Q1.RED_BOXES, Q1.GREEN_BOXES, Q1.OPERATION_START_DATE,
          DECODE(Q1.MPC_ID, NULL, 'Unknown', Q1.MPC_ID),
          Q1.PROCESS_ID

                  </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbWorkStation" Type="String" Direction="Input" Name="work_station" />
            <asp:ControlParameter ControlID="dtValidationDate" Type="DateTime" Direction="Input"
                Name="validation_start_date" />
            <asp:ControlParameter ControlID="tbOperator" Type="String" Direction="Input" Name="operator" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="false" DefaultSortExpression="mpc_id;$;box_id" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            
                <eclipse:MultiBoundField DataFields="mpc_id" HeaderText="MPC" SortExpression="mpc_id">
                </eclipse:MultiBoundField>
                <eclipse:MultiBoundField DataFields="box_id" HeaderText="Box" SortExpression="box_id">
                    <itemstyle horizontalalign="Left" />
                </eclipse:MultiBoundField>
               <%-- <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="WareHouse Location"
                SortExpression="warehouse_location_id">
                </eclipse:MultiBoundField> --%>
                <eclipse:MultiBoundField DataFields="scan_time" HeaderText="Scan Time" SortExpression="scan_time"
                    DataFormatString="{0:T}" />
                <jquery:IconField DataField="ups_carton_count" HeaderText="Boxes|UPS" DataFieldValues="TRUE"
                    IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="ups_carton_count" />
                <jquery:IconField DataField="green_carton_count" HeaderText="Boxes|Green" DataFieldValues="TRUE"
                    IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="green_carton_count" />
                <jquery:IconField DataField="red_carton_count" HeaderText="Boxes|Red" DataFieldValues="TRUE"
                    IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="red_carton_count" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

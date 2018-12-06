<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Validation Productivity Report" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5215 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_03.aspx $
 *  $Id: R150_03.aspx 5215 2013-04-12 09:01:42Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern and Matrix Field--%>
<script runat="server">    
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("B.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS VALIDATION_DATE", strShiftDateSelectClause));


        string strShiftDateGroupClause = ShiftSelector.GetShiftDateClause("B.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause$", string.Format("{0}", strShiftDateGroupClause));

        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("B.operation_start_date");
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
    <meta name="Description" content="This report shows the Validation productivity of each validator for date or date range. You can also filter on the basis of first shift or second shift.. Validation productivity is measured by monitoring average cartons per hours validated by a validator." />
    <meta name="ReportId" content="150.03" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Replaced building filter dropdown with checkbox list." /> 
    <meta name="Version" content="$Id: R150_03.aspx 5215 2013-04-12 09:01:42Z skumar $" />
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
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Validation date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="Validation Start Date"
                    Text="-7" ToolTip="You can specify the date or date range to see the validation productivity for this date or date range.">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="Validation End Date"
                    Text="0">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="You can select shift to see the validation productivity for the selected shift." /> 
            </eclipse:TwoColumnPanel>
             <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Building" />
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
    
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting">
        <SelectSql>
WITh Q1 AS
 (SELECT B.OPERATOR,
         B.WORK_STATION,
         B.CASE_ID,
         B.PROCESS_ID,
         B.OPERATION_START_DATE,
         B.OPERATION_END_DATE,
         B.OUTCOME,
         B.UCC128_ID,
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
         END AS BOX_COUNT,
         B.REPITCHED_BOX,
         B.CARRIER_ID,
         B.MPC_ID,
         <![CDATA[$ShiftDateSelectClause$]]>
    FROM BOX_PRODUCTIVITY B
   WHERE B.OPERATION_CODE = '$CTNVERIFY'
     AND B.operation_start_date &gt;= cast(:operation_start_date_from as date)
     AND B.operation_start_date &lt; cast(:operation_start_date_to as date)+ 2
     <![CDATA[
        $ShiftNumberWhereClause$                     
     ]]>       
         <if>AND <a pre="B.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>    
            ),
Q2 AS
 (SELECT Q1.OPERATOR,
         Q1.WORK_STATION,
         Q1.VALIDATION_DATE,
         COUNT(DECODE(Q1.REPITCHED_BOX, 'Y', Q1.UCC128_ID)) AS REPITCH_CARTONS,
         COUNT(DECODE(Q1.CARRIER_ID, :carrier_id, Q1.UCC128_ID)) AS UPS_CARTON_COUNT,
         COUNT(DECODE(Q1.OUTCOME, 'VALIDATED', Q1.UCC128_ID)) AS GREEN_CARTON_COUNT,
         COUNT(CASE
                 WHEN Q1.OUTCOME = 'VERIFIED' OR Q1.OUTCOME = 'INVALIDSCAN' THEN
                  Q1.UCC128_ID
               END) AS BAD_SCAN_COUNT,
         COUNT(DISTINCT Q1.MPC_ID) AS MPC_COUNT,
         ROUND((MAX(Q1.OPERATION_END_DATE) - MIN(Q1.OPERATION_START_DATE)) * 24,
               4) AS TOTAL_HOURS_WORKED,
         COUNT(Q1.BOX_COUNT) AS RED
    FROM Q1
    WHERE Q1.validation_date &gt;= :operation_start_date_from
     AND Q1.validation_date &lt; :operation_start_date_to + 1
   GROUP BY Q1.OPERATOR, Q1.WORK_STATION, Q1.VALIDATION_DATE),
Q3 AS
 (SELECT Q1.OPERATOR,
         Q1.WORK_STATION,
         Q1.CASE_ID,
         Q1.VALIDATION_DATE,
         COUNT(DECODE(Q1.OUTCOME, 'VALIDATED', Q1.UCC128_ID)) AS grn_ctn_case_count   
    FROM Q1
    WHERE Q1.validation_date &gt;= :operation_start_date_from
     AND Q1.validation_date &lt; :operation_start_date_to + 1
   GROUP BY Q1.OPERATOR, Q1.WORK_STATION, Q1.CASE_ID, Q1.VALIDATION_DATE)
SELECT Q2.OPERATOR,
       Q2.WORK_STATION,
       Q2.VALIDATION_DATE,
       Q3.CASE_ID AS grn_ctn_case_id, 
       Q2.REPITCH_CARTONS,
       Q2.UPS_CARTON_COUNT AS ups_cartons,
       Q2.GREEN_CARTON_COUNT,
       Q3.grn_ctn_case_count AS GREEN_CARTONS,
       Q2.BAD_SCAN_COUNT AS BAD_SCAN_CARTONS,
       Q2.MPC_COUNT AS MPC_COUNT,
       Q2.TOTAL_HOURS_WORKED,
       Q2.RED AS red_cartons,
       round(CASE
               WHEN Q2.TOTAL_HOURS_WORKED = 0 THEN
                (Q2.GREEN_CARTON_COUNT + Q2.RED) * 3600
               ELSE
                round((Q2.GREEN_CARTON_COUNT + Q2.RED) / Q2.TOTAL_HOURS_WORKED, 2)
             END,
             2) CTN_HR,
       AU.CREATED AS USER_SETUP_DATE
  FROM Q2
  LEFT OUTER JOIN Q3
    ON Q2.OPERATOR = Q3.OPERATOR
   AND Q2.WORK_STATION = Q3.WORK_STATION
   AND Q2.VALIDATION_DATE = Q3.VALIDATION_DATE
  LEFT OUTER JOIN ALL_USERS AU
    ON AU.USERNAME = Q2.OPERATOR
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:Parameter Name="carrier_id" Type="String" DefaultValue="<%$  AppSettings: SpecialCarrierId  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="work_station;operator;validation_date"
        DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="work_station" HeaderText="Work Station" SortExpression="work_station" />
            <eclipse:SiteHyperLinkField DataTextField="operator" HeaderText="User" SortExpression="operator"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R150_108.aspx?work_station={0}&operator={1}&shift_start_date={2:d}"
                DataNavigateUrlFields="work_station,operator,validation_date" />
            <eclipse:MultiBoundField DataFields="validation_date" HeaderText="Validation Date"
                HeaderToolTip="Shift date when the validation started." SortExpression="validation_date"
                DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="total_hours_worked" HeaderText="Total Hrs. Worked"
                 DataFormatString="{0:N4}" >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="mpc_count" HeaderText="Total MPCs" 
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"  DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>            
            <m:MatrixField DataMergeFields="work_station,operator,validation_date" DataCellFields="green_cartons" DataHeaderFields="grn_ctn_case_id" HeaderText="#Green Boxes" RowTotalHeaderText="Total" SortExpression="green_cartons"   >            
                <MatrixColumns>
                    <m:MatrixColumn  ColumnType="CellValue" DisplayColumnTotal="true" />
                    <m:MatrixColumn ColumnType ="RowTotal"  DisplayColumnTotal="true" DataHeaderFormatString="" />   
                </MatrixColumns>
            </m:MatrixField>          
            <eclipse:MultiBoundField DataFields="ups_cartons" HeaderText="#Boxes|UPS" 
                DataFormatString="{0:N0}" HideEmptyColumn="true" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="red_cartons" HeaderText="#Boxes|Red" 
               DataFormatString="{0:N0}" HideEmptyColumn="true" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="repitch_cartons" HeaderText="#Boxes|Repitch"
                 DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" 
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="bad_scan_cartons" HeaderText="No. of Bad Scans"
                  DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ctn_hr" HeaderText="Boxes/Hrs." 
                DataFormatString="{0:N2}" HeaderToolTip="(Total Green # Boxes + Total Red # Boxes)/Total Hrs. Worked">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date"
                 DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

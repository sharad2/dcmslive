<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Expeditor Productivity Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_04.aspx $
 *  $Id: R150_04.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern and Matrix --%>
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
    <meta name="ReportId" content="150.04" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R150_04.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
                <eclipse:LeftLabel runat="server" Text="Specify date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From" Text="-7">
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
                <%--   From
                <dcms:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From" Required="true"
                    RelativeDate="-7" />
                To
                <dcms:BusinessDateTextBox ID="dtTo" runat="server" AssociatedFromControlID="dtFrom"
                    FriendlyName="To" RelativeDate="0" />--%>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
               <%-- <eclipse:LeftLabel ID="LeftLAbel3" runat="server" Text="Warehouse Location" />--%>
                <%--<d:BuildingSelector ID="ctlWhloc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true">
                </d:BuildingSelector>--%>
               <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server"  Text="Check For Specific Building"/>
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
with expeditor_prod as
(
SELECT /*+index(bp BOXPROD_OPERATION_START_DATE_I)*/
       bp.operation_start_date AS operation_start_date,
       min(bp.operator) AS operator,
       bp.process_id AS count_mpc,
       bp.UCC128_ID AS carton_id,      
       <![CDATA[
       $ShiftDateSelectClause$
       ]]>,
       COUNT(DISTINCT(CASE
                        WHEN bp.outcome = 'COMPLETED' OR bp.outcome = 'UNDERPITCH' THEN
                         bp.ucc128_id
                      END)) AS total_cartons,
              (MAX(bp.OPERATION_END_DATE) - MIN(bp.OPERATION_START_DATE)) * 24 AS TOTAL_TIME_WORKED,
       max(bp.bucket_id) AS bucket_id,
       max(bp.case_id) AS case_id   
  FROM box_productivity bp  
 WHERE bp.operation_code = '$CTNEXP'
   AND bp.operation_start_date &gt;= CAST(:operation_start_date_from AS DATE)
   AND bp.operation_start_date &lt; CAST(:operation_start_date_to AS DATE) + 2
   <![CDATA[
    $ShiftNumberWhere$
    ]]>
    <%-- <if>AND bp.warehouse_location_id = :warehouse_location_id</if>--%>
    <if>AND <a pre="BP.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>

 GROUP BY bp.operation_start_date, bp.process_id, bp.ucc128_id
 )
  SELECT distinct exprod.operator AS operator,
       count(exprod.case_id) over(partition by exprod.operator, exprod.shift_start_date,case_id) AS count_case_id,
       count(distinct(exprod.COUNT_MPC)) over(partition by exprod.operator, exprod.shift_start_date) AS count_mpc,      
       sum(exprod.TOTAL_CARTONS) over(partition by exprod.operator,exprod.shift_start_date) AS total_cartons,
       NVL(round(sum(exprod.TOTAL_TIME_WORKED) over(partition by exprod.operator,exprod.shift_start_date),4),0) AS total_time_worked,
       count(distinct exprod.BUCKET_ID) over(partition by exprod.operator,exprod.shift_start_date) as count_bucket,
       exprod.shift_start_date as shift_start_date,
       max(exprod.case_id)over(partition by exprod.operator,exprod.shift_start_date,case_id) as case_id,
       au.created AS user_setup_date
  FROM expeditor_prod exprod
  LEFT OUTER JOIN all_users au ON au.username = exprod.operator
 WHERE exprod.shift_start_date &gt;= CAST(:operation_start_date_from AS DATE)
   AND exprod.shift_start_date &lt; CAST(:operation_start_date_to AS DATE) + 1
   
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="operator;shift_start_date;case_id" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="operator" HeaderText="Expeditor Name"
                HeaderToolTip="One who creates MPC" SortExpression="operator" DataNavigateUrlFormatString="R150_102.aspx?operator={0}&shift_start_date={1:d}"
                DataNavigateUrlFields="operator,shift_start_date" AppliedFiltersControlID="ButtonBar1$af">
                <HeaderStyle Wrap="true" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="MPC Creation Date"
                SortExpression="shift_start_date" HeaderToolTip="Shift date when work started on MPCs"
                DataFormatString="{0:d}" HeaderStyle-Wrap="true">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_time_worked" HeaderText="Total Hrs.<br/>Worked"
                HeaderToolTip="Total time worked by operator on MPC" SortExpression="total_time_worked"
                DataFormatString="{0:N4}">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="count_bucket" HeaderText="Number of|Processed Buckets"
                HeaderToolTip="Total buckets processed by the Expeditor" FooterToolTip="Sum of buckets processed"
                SortExpression="count_bucket" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="count_mpc" HeaderText="Number of|MPCs" SortExpression="count_mpc"
                HeaderToolTip="MPCs created by the Expeditor" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Total number of MPCs" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_cartons" HeaderText="Number of|Total Cartons"
                HeaderToolTip="No. of cartons and underpitched cartons scanned by the Expeditor"
                FooterToolTip="Sum of cartons and underpitched cartons scanned" SortExpression="total_cartons"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
             <%--<jquery:MatrixField  DataHeaderFields="case_id" DataValueFields="count_case_id" DisplayColumnTotals="true"
                DataMergeFields="warehouse_location_id,operator,shift_start_date">
            </jquery:MatrixField>--%>
            <m:MatrixField DataHeaderFields="case_id" DataCellFields="count_case_id" DataMergeFields="operator,shift_start_date"
                HeaderText=" " RowTotalHeaderText="Total">
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="CellValue" DisplayColumnTotal="true" DataHeaderFormatString="{0}">
                    </m:MatrixColumn>
                    <m:MatrixColumn ColumnType="RowTotal" DisplayColumnTotal="true" DataHeaderFormatString=""
                        DataCellFormatString="{0:N0}">
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date"
                HeaderToolTip="User created date" SortExpression="user_setup_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

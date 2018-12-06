<%@ Page Title="Pulling and Locating Productivity Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4655 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R40_25.aspx $
 *  $Id: R40_25.aspx 4655 2012-11-17 09:28:43Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause1 = ShiftSelector.GetShiftDateClause("CPROD.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause1$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause1));
        string strShiftDateGroupClause1 = ShiftSelector.GetShiftDateClause("CPROD.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause1$", string.Format("{0}", strShiftDateGroupClause1));
        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("CPROD.process_start_date");
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
    <meta name="Description" content="
    This report shows the productivity of each employee working in any area against some activity. The reports has a parameter of date range and user also has option to run this report on a single shift." />
    <meta name="ReportId" content="40.25" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R40_25.aspx 4655 2012-11-17 09:28:43Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcp" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Process Start Date" />
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Process Start Date"
                    Text="-7" QueryString="dtFrom">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Process Start Date"
                    Text="0" QueryString="dtTo">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" />
                <d:ShiftSelector ID="rbtnShift" runat="server" />
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Building" />
                <d:BuildingSelector ID="ctlWhloc" FriendlyName="Building" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true">
                </d:BuildingSelector>
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
WITH PRODUCTIVITY AS
(SELECT CPROD.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
         CPROD.MODULE_CODE AS MODULE_CODE,
         CPROD.ACTION_CODE AS ACTION_CODE,
         CPROD.OPERATOR_ID AS OPERATOR_ID,
         CPROD.PROCESS_ID AS PROCESS_ID,
         CPROD.PROCESS_START_DATE AS PROCESS_START_DATE,
         cprod.process_end_date AS process_end_date,
         CPROD.PALLET_ID AS PALLET_ID,
         CPROD.CARTON_ID AS CARTON_ID,
         cprod.carton_destination_area AS carton_destination_area,
        CASE WHEN  (LAG(CPROD.pallet_id) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) IS NULL OR 
                    (LAG(CPROD.pallet_id) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) != CPROD.pallet_id THEN
             CPROD.pallet_id END  AS pallet_count,
         CASE WHEN  (LAG(CPROD.aisle) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) IS NULL OR 
                    (LAG(CPROD.aisle) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) != CPROD.aisle THEN
             CPROD.aisle END  AS aisle_count,             
         CASE WHEN  (LAG(CPROD.carton_id) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) IS NULL OR 
                    (LAG(CPROD.carton_id) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) != CPROD.carton_id THEN
             CPROD.carton_id END  AS carton_count,
         CASE WHEN  (LAG(CPROD.carton_id) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) IS NULL OR 
                    (LAG(CPROD.carton_id) OVER(PARTITION BY CPROD.OPERATOR_ID, CPROD.WAREHOUSE_LOCATION_ID, CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE)) != CPROD.CARTON_ID THEN
             CPROD.CARTON_QUANTITY  END  AS carton_quantity,
         CPROD.AISLE AS AISLE,
          <![CDATA[
               $ShiftDateSelectClause1$
               ]]>
    FROM CARTON_PRODUCTIVITY CPROD
  WHERE   PROCESS_START_DATE  &gt;= CAST(:process_start_date_from AS DATE)
           AND PROCESS_START_DATE &lt; CAST(:process_start_date_to AS DATE) + 2
 <![CDATA[
           $ShiftNumberWhereClause$
           ]]>
    <if>AND CPROD.warehouse_location_id =:warehouse_location_id</if>) 
SELECT P.OPERATOR_ID AS Employee,
       P.WAREHOUSE_LOCATION_ID AS Building,
       P.MODULE_CODE AS Module_code,
       P.ACTION_CODE AS Action_code,
       ROUND((MAX(P.PROCESS_END_DATE) - MIN(P.PROCESS_START_DATE)) * 24, 4) AS SYSTEM_HOURS,
       p.carton_destination_area as DEST_AREA,
       sum(COUNT(p.pallet_count)) OVER(PARTITION BY p.operator_id, p.module_code, p.action_code,P.WAREHOUSE_LOCATION_ID,P.SHIFT_START_DATE) AS pallet_count,
       sum(COUNT(p.aisle_count)) OVER(PARTITION BY p.operator_ID, p.module_code, p.action_code,P.WAREHOUSE_LOCATION_ID,P.SHIFT_START_DATE) AS aisle_count,       
       sum(COUNT(p.carton_count)) OVER(PARTITION BY p.operator_ID, p.module_code, p.action_code,P.WAREHOUSE_LOCATION_ID,P.SHIFT_START_DATE) AS carton_count,       
       SUM(p.carton_quantity) AS quantity,
       SHIFT_START_DATE
  FROM PRODUCTIVITY P
  WHERE p.SHIFT_START_DATE &gt;= CAST(:process_start_date_from AS DATE)
  AND p.SHIFT_START_DATE &lt; CAST(:process_start_date_to AS DATE) + 1
GROUP BY P.WAREHOUSE_LOCATION_ID,
          P.MODULE_CODE,
          P.ACTION_CODE,
          P.OPERATOR_ID,
          P.SHIFT_START_DATE,
          p.carton_destination_area
</SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="process_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="process_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="module_code;action_code;building;$;Employee;shift_start_date"
        DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />

            <eclipse:MultiBoundField DataFields="module_code" HeaderText="Module" SortExpression="module_code" />
            <eclipse:MultiBoundField DataFields="action_code" HeaderText="Activity" SortExpression="action_code" />
            <eclipse:MultiBoundField DataFields="building" HeaderText="Building" SortExpression="building" />
            <eclipse:SiteHyperLinkField DataTextField="Employee" DataNavigateUrlFormatString="R40_102.aspx?Employee={0}&action_code={1}&start_date={2:d}&module_code={3:c10}&warehouse_location_id={4}"
                DataNavigateUrlFields="Employee,action_code,shift_start_date,module_code,building"
                AppliedFiltersControlID="ButtonBar1$af" HeaderText="Employee" SortExpression="employee" />
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="Process Date"
                SortExpression="shift_start_date" DataFormatString="{0:MM/dd/yyyy}" />
            <eclipse:MultiBoundField DataFields="System_Hours" HeaderText="System Hours" SortExpression="System_Hours"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N4}" />
            <eclipse:MultiBoundField DataFields="Pallet_Count" HeaderText="Total Number of|Pallets"
                SortExpression="Pallet_Count" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Aisle_Count" HeaderText="Total Number of|Aisles Visited"
                SortExpression="Aisle_Count" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Carton_Count" HeaderText="Total Number of|Cartons"
                SortExpression="Carton_Count" DataSummaryCalculation="ValueSummation" NullDisplayText="***" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <m:MatrixField DataHeaderFields="DEST_AREA" DataCellFields="quantity" DataMergeFields="action_code,employee,shift_start_date,building"
                HeaderText="Quantity in">
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="CellValue" DisplayColumnTotal="true" ColumnTotalFormatString="{0:N0}">
                        <ItemTemplate>
                            <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex='<%# Eval("action_code", "{0}") == ConfigurationManager.AppSettings["PullingActionCode"]? 0 : 1 %>'>
                                <asp:View ID="View1" runat="server">
                                    <eclipse:SiteHyperLink ID="SiteHyperLink1" runat="server" SiteMapKey="R40_104.aspx"
                                        Text='<%# Eval("quantity", "{0:N0}") %>' NavigateUrl='<%# string.Format("action_code={0}&shift_start_date={1:d}&EMPLOYEE={2}&dest_area={3}&shift={4}&building={5}&module_code={6}",Eval("action_code"),Eval("shift_start_date"),Eval("employee"),Eval("dest_area"),rbtnShift.Value,Eval("building"),Eval("module_code"))%>'></eclipse:SiteHyperLink>
                                </asp:View>
                                <asp:View ID="View2" runat="server">
                                    <asp:Label ID="Label1" runat="server" Text='<%# Eval("quantity", "{0:N0}") %>' />
                                </asp:View>
                            </asp:MultiView>
                        </ItemTemplate>
                    </m:MatrixColumn>
                </MatrixColumns>
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="RowTotal" DataCellFormatString="{0:N0}" ColumnTotalFormatString="{0:N0}" DisplayColumnTotal="true">
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

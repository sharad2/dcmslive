<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Pulling and Locating Detail Report " %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5730 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_102.aspx $
 *  $Id: R40_102.aspx 5730 2013-07-19 13:08:58Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern --%>
<script runat="server">   
   

    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("CPROD.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));

        string strShiftWhereClause = ShiftSelector.GetShiftDateClause("CPROD.PROCESS_START_DATE");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftWhereClause$", string.Format(" AND {0} = :{1}", strShiftWhereClause, "shift_start_date"));
        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("CPROD.PROCESS_START_DATE");
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
    The report displays detail information of each process for a given employee, process start date and module code. " />
    <meta name="ReportId" content="40.102" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R40_102.aspx 5730 2013-07-19 13:08:58Z skumar $" />
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
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" ID="JPanel" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcp" runat="server">
                <eclipse:LeftLabel runat="server" ID="lblModuleCode" Text="Module Code" />
                <i:TextBoxEx runat="server" ID="tbModuleCode" QueryString="module_code">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" ID="lblEmployee" Text="Employee" />
                <i:TextBoxEx runat="server" ID="tbEmployee" QueryString="EMPLOYEE">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" ID="lblProcessStartDate" Text="Process Start Date" />
                <d:BusinessDateTextBox runat="server" ID="ctlProcessStartDate" QueryString="start_date">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="lblShift" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="You can select shift to see the validation productivity for the selected shift." />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Activity" />
                <%--DataSource Fetching action_code--%>
                <i:TextBoxEx runat="server" ID="ctlAction" QueryString="action_code">
                </i:TextBoxEx>
            </eclipse:TwoColumnPanel>
            <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Building" />
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
                        QueryString="warehouse_location_id">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--<uc2:ButtonBar2 ID="ButtonBar" runat="server" />--%>
    <uc2:ButtonBar2 ID="ButtonBar" runat="server" />
    <oracle:OracleDataSource runat="server" ID="ds" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
         NVL(TIA.SHORT_NAME, CPROD.CARTON_DESTINATION_AREA) AS SHORT_NAME,
         cprod.carton_destination_area AS carton_destination_area,
         CASE
           WHEN (LAG(CPROD.pallet_id)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) IS NULL OR
                (LAG(CPROD.pallet_id)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) != CPROD.pallet_id THEN
            CPROD.pallet_id
         END AS pallet_count,
         CASE
           WHEN (LAG(CPROD.aisle)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE,
                      CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) IS NULL OR
                (LAG(CPROD.aisle)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE,
                      CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) != CPROD.aisle THEN
            CPROD.aisle
         END AS aisle_count,
         CASE
           WHEN (LAG(CPROD.carton_id)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE,
                      CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) IS NULL OR
                (LAG(CPROD.carton_id)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE,
                      CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) != CPROD.carton_id THEN
            CPROD.carton_id
         END AS carton_count,
         CASE
           WHEN (LAG(CPROD.carton_id)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE,
                      CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) IS NULL OR
                (LAG(CPROD.carton_id)
                 OVER(PARTITION BY CPROD.OPERATOR_ID,
                      CPROD.WAREHOUSE_LOCATION_ID,
                      CPROD.MODULE_CODE,
                      CPROD.PALLET_ID ORDER BY CPROD.PROCESS_START_DATE,
                      CPROD.MODULE_CODE)) != CPROD.CARTON_ID THEN
            CPROD.CARTON_QUANTITY
         END AS carton_quantity,
         CPROD.AISLE AS AISLE,
         <![CDATA[
               $ShiftDateSelectClause$
               ]]>
  
    FROM CARTON_PRODUCTIVITY CPROD
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON CPROD.CARTON_DESTINATION_AREA = TIA.INVENTORY_STORAGE_AREA
    WHERE CPROD.OPERATOR_ID = CAST(:operator AS VARCHAR2(255))
    AND CPROD.MODULE_CODE = CAST(:module_code AS VARCHAR2(255))
    AND CPROD.PROCESS_START_DATE &gt;= CAST(:shift_start_date AS DATE)
    AND CPROD.PROCESS_START_DATE &lt; CAST(:shift_start_date AS DATE) + 2 
    <if>AND CPROD.ACTION_CODE = :action_code</if>
  <![CDATA[
  $ShiftWhereClause$
  $ShiftNumberWhereClause$
  ]]>
   <if>AND <a pre="NVL(CPROD.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>  
            
  
  )
SELECT P.OPERATOR_ID AS OPERATOR_ID,
       NVL(P.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
       P.MODULE_CODE AS Module_code,
       P.ACTION_CODE AS Action_code,
       P.PROCESS_ID as PROCESS_ID,
       MIN(P.PROCESS_START_DATE) AS START_TIME,
       MAX(P.process_end_date) AS END_TIME, 
       ROUND((MAX(P.PROCESS_END_DATE) - MIN(P.PROCESS_START_DATE)) * 24, 4) AS SYSTEM_HOURS,
       p.carton_destination_area as carton_destination_area,
       sum(COUNT(p.pallet_count)) OVER(PARTITION BY p.operator_id, p.module_code, p.PROCESS_ID, p.carton_destination_area, p.action_code, P.WAREHOUSE_LOCATION_ID, P.SHIFT_START_DATE) AS pallet_count,
       sum(COUNT(p.aisle_count)) OVER(PARTITION BY p.operator_ID, p.module_code, p.action_code, p.PROCESS_ID, p.carton_destination_area, P.WAREHOUSE_LOCATION_ID, P.SHIFT_START_DATE) AS aisle_count,
       sum(COUNT(p.carton_count)) OVER(PARTITION BY p.operator_ID, p.module_code, p.action_code, p.PROCESS_ID, p.carton_destination_area, P.WAREHOUSE_LOCATION_ID, P.SHIFT_START_DATE) AS carton_count,
       SUM(p.carton_quantity) AS quantity,
       MAX(P.SHORT_NAME) AS SHORT_NAME,
       SHIFT_START_DATE
  FROM PRODUCTIVITY P
 where P.shift_start_date &gt;= CAST(:shift_start_date AS DATE)
  AND P.shift_start_date &lt; CAST(:shift_start_date AS DATE) + 1 
 GROUP BY P.WAREHOUSE_LOCATION_ID,
          P.MODULE_CODE,
          P.ACTION_CODE,
          P.OPERATOR_ID,
          p.PROCESS_ID,
          P.SHIFT_START_DATE,
          p.carton_destination_area
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbModuleCode" Name="module_code" Type="String" Direction="Input" />
            <%-- <asp:QueryStringParameter Name="module_code" Type="String" />--%>
            <asp:ControlParameter ControlID="tbEmployee" Name="operator" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlProcessStartDate" Name="shift_start_date" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="ctlAction" Name="action_code" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhloc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="OPERATOR_ID;MODULE_CODE;warehouse_location_id;$;PROCESS_ID;SHIFT_START_DATE;START_TIME">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="OPERATOR_ID" HeaderText="Employee" SortExpression="OPERATOR_ID" />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" NullDisplayText="Unknown" />
            <eclipse:MultiBoundField DataFields="MODULE_CODE" HeaderText="Module Code" SortExpression="MODULE_CODE" />
            <eclipse:MultiBoundField DataFields="PROCESS_ID" HeaderText="Session" SortExpression="PROCESS_ID" />
            <eclipse:MultiBoundField DataFields="SHIFT_START_DATE" HeaderText="Process Date"
                SortExpression="SHIFT_START_DATE" DataFormatString="{0:d}">
                <ItemStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="START_TIME" HeaderText="Time|Start" SortExpression="START_TIME"
                DataFormatString="{0:HH:mm:ss}" />
            <eclipse:MultiBoundField DataFields="END_TIME" HeaderText="Time|End" SortExpression="END_TIME"
                DataFormatString="{0:HH:mm:ss}" />
            <eclipse:MultiBoundField DataFields="SYSTEM_HOURS" HeaderText="System Hours" SortExpression="SYSTEM_HOURS"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N4}" />
            <eclipse:MultiBoundField DataFields="pallet_count" HeaderText="Total Number Of|Pallet"
                SortExpression="pallet_count" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="AISLE_COUNT" HeaderText="Total Number Of|Aisles Visited"
                SortExpression="AISLE_COUNT" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="CARTON_COUNT" HeaderText="Total Number Of|Cartons"
                SortExpression="CARTON_COUNT" DataFormatString="{0:N0}" NullDisplayText="***"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Total Number Of|Quantity"
                SortExpression="quantity" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHORT_NAME" HeaderText="Destination Area"
                SortExpression="SHORT_NAME" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

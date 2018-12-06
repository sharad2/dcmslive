<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Pulling and Locating Detail Report " %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4655 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R40_102.aspx $
 *  $Id: R40_102.aspx 4655 2012-11-17 09:28:43Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern --%>
<script runat="server">   
   

    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("CP.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));

        string strShiftWhereClause = ShiftSelector.GetShiftDateClause("CP.PROCESS_START_DATE");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftWhereClause$", string.Format(" AND {0} = :{1}", strShiftWhereClause, "shift_start_date"));
        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("CP.PROCESS_START_DATE");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause, "shift_number"));
        }
        string strShiftDateGroupClause = ShiftSelector.GetShiftDateClause("CP.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause$", string.Format("{0}", strShiftDateGroupClause));



    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="
    The report displays detail information of each process for a given employee, process start date and module code. " />
    <meta name="ReportId" content="40.102" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R40_102.aspx 4655 2012-11-17 09:28:43Z skumar $" />
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
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Building" />
                <d:BuildingSelector ID="ctlWhloc" runat="server" QueryString="warehouse_location_id"
                    FriendlyName="Building" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="false">
                    <Items>
                        <eclipse:DropDownItem Text="(All)" Value="" Persistent="Always" />
                        <eclipse:DropDownItem Text="Unknown" Value="Unknown" Persistent="Always" />
                    </Items>
                </d:BuildingSelector>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Activity" />
                <%--DataSource Fetching action_code--%>
                <oracle:OracleDataSource ID="dsActionCode" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %> ">
                    <SelectSql>
                     select distinct t.action_code as action_code,t.action_description as action_description
	                    from master_action_code t
                    </SelectSql>
                    <SelectParameters>
                    </SelectParameters>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ctlAction" QueryString="action_code" runat="server" DataSourceID="dsActionCode"
                    DataFields="action_code,action_description" DataTextFormatString="{1}" DataValueFormatString="{0}"
                    FriendlyName="Activity">
                    <Items>
                        <eclipse:DropDownItem Value="" Text="(All)" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
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
WITH Q1 AS
 (SELECT nvl(CP.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
         CP.MODULE_CODE AS MODULE_CODE,
         CP.ACTION_CODE AS ACTION_CODE,
         CP.OPERATOR_ID AS EMPLOYEE,
         CP.PROCESS_ID AS SESSION_ID,
          <![CDATA[
               $ShiftDateSelectClause$
               ]]>,
         TRUNC(MAX(CP.PROCESS_START_DATE)) AS PROCESS_START_DATE,
         MIN(CP.PROCESS_START_DATE) AS START_TIME,
         MAX(CP.PROCESS_END_DATE) AS END_TIME,
         cp.pallet_id AS Pallet_id,
         MAX(CP.AISLE) AS AISLE_COUNT,
         CP.CARTON_ID AS CARTONS_COUNT,
         CP.CARTON_DESTINATION_AREA AS DESTINATION_LOCATION,
         MAX(CP.CARTON_QUANTITY) AS TOTAL_QUANTITY
  
    FROM CARTON_PRODUCTIVITY CP
   WHERE CP.OPERATOR_ID = CAST(:operator AS VARCHAR2(255))
     AND upper(CP.MODULE_CODE) = upper(CAST(:module_code AS VARCHAR2(255)))
     AND CP.PROCESS_START_DATE &gt;= CAST(:shift_start_date AS DATE)
     AND CP.PROCESS_START_DATE &lt; CAST(:shift_start_date AS DATE) + 2 
     <if>AND CP.ACTION_CODE = :action_code</if>
  <![CDATA[
  $ShiftWhereClause$
  $ShiftNumberWhereClause$
  ]]>
   <if c="$warehouse_location_id != 'Unknown'">AND CP.Warehouse_Location_Id = :warehouse_location_id</if>
   <if c="$warehouse_location_id ='Unknown'">and CP.Warehouse_Location_Id is null</if> 
GROUP BY CP.WAREHOUSE_LOCATION_ID,
            <![CDATA[
            $ShiftDateGroupClause$
            ]]>,
            CP.MODULE_CODE,
            CP.OPERATOR_ID,
            CP.PROCESS_ID,
            CP.CARTON_ID,
            cp.pallet_id,
            CP.CARTON_DESTINATION_AREA,
            CP.ACTION_CODE)
SELECT Q1.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       Q1.MODULE_CODE AS MODULE_CODE,
       Q1.ACTION_CODE AS ACTION_CODE,
       Q1.EMPLOYEE AS EMPLOYEE,
       Q1.SESSION_ID AS SESSION_ID,
       MAX(Q1.PROCESS_START_DATE) AS PROCESS_START_DATE,
       MIN(Q1.START_TIME) AS START_TIME,
       MAX(Q1.END_TIME) AS END_TIME,
       ROUND((MAX(Q1.END_TIME) - MIN(Q1.START_TIME)) * 24,
             4) AS SYSTEM_HOURS,
       Q1.Pallet_id AS Pallet_id,
       COUNT(DISTINCT Q1.AISLE_COUNT) AISLE_COUNT,
       decode(COUNT(distinct Q1.CARTONS_COUNT),
              0,
              null,
              COUNT(distinct Q1.CARTONS_COUNT)) AS CARTONS_COUNT,
       Q1.DESTINATION_LOCATION AS DESTINATION_LOCATION,
       SUM(Q1.TOTAL_QUANTITY) AS TOTAL_QUANTITY
  FROM Q1
  where Q1.shift_start_date &gt;= CAST(:shift_start_date AS DATE)
     AND q1.shift_start_date &lt; CAST(:shift_start_date AS DATE) + 1 
 GROUP BY Q1.WAREHOUSE_LOCATION_ID,
          Q1.MODULE_CODE,
          Q1.EMPLOYEE,
          Q1.Pallet_id,
          Q1.SESSION_ID,
          Q1.DESTINATION_LOCATION,
          Q1.ACTION_CODE




<%--
SELECT CP.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       cp.module_code as module_code,
       CP.ACTION_CODE AS ACTION_CODE,
       CP.OPERATOR_ID AS EMPLOYEE,
       CP.PROCESS_ID AS SESSION_ID,
       TRUNC(MAX(CP.PROCESS_START_DATE)) AS PROCESS_START_DATE,
       min(CP.PROCESS_START_DATE) AS START_TIME,
       max(CP.PROCESS_END_DATE) AS END_TIME,
       ROUND((MAX(CP.PROCESS_END_DATE) - MIN(CP.PROCESS_START_DATE)) * 24,
             4) AS SYSTEM_HOURS,
       COUNT(DISTINCT CP.PALLET_ID) AS PALLET_COUNT,
       COUNT(DISTINCT CP.AISLE) AISLE_COUNT,
       COUNT(CP.CARTON_ID) AS CARTONS_COUNT,
       CP.CARTON_DESTINATION_AREA AS DESTINATION_LOCATION,
       SUM(CP.CARTON_QUANTITY) AS TOTAL_QUANTITY

  FROM CARTON_PRODUCTIVITY CP
 WHERE  CP.OPERATOR_ID = cast(:operator as varchar2(255))
           
  AND CP.process_start_date &gt;= CAST(:shift_start_date AS DATE)
  AND CP.process_start_date &lt; CAST(:shift_start_date AS DATE) + 1 
  AND CP.ACTION_CODE = cast(:action_code as varchar2(255))
  <![CDATA[
  $ShiftWhereClause$
  $ShiftNumberWhereClause$
  ]]>
  <if>AND CP.warehouse_location_id=:warehouse_location_id</if>
 GROUP BY CP.WAREHOUSE_LOCATION_ID,
          cp.module_code,
          CP.OPERATOR_ID,
          CP.PROCESS_ID,
        
          CP.CARTON_DESTINATION_AREA,
          CP.ACTION_CODE--%>
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
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="EMPLOYEE;MODULE_CODE;warehouse_location_id;$;SESSION_ID;PROCESS_START_DATE;START_TIME">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="EMPLOYEE" HeaderText="Employee" SortExpression="EMPLOYEE" />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" />
            <eclipse:MultiBoundField DataFields="MODULE_CODE" HeaderText="Module Code" SortExpression="MODULE_CODE" />
            <eclipse:MultiBoundField DataFields="SESSION_ID" HeaderText="Session" SortExpression="SESSION_ID" />
            <eclipse:MultiBoundField DataFields="PROCESS_START_DATE" HeaderText="Process Date"
                SortExpression="PROCESS_START_DATE" DataFormatString="{0:d}">
                <ItemStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="START_TIME" HeaderText="Time|Start" SortExpression="START_TIME"
                DataFormatString="{0:HH:mm:ss}" />
            <eclipse:MultiBoundField DataFields="END_TIME" HeaderText="Time|End" SortExpression="END_TIME"
                DataFormatString="{0:HH:mm:ss}" />
              <eclipse:MultiBoundField DataFields="SYSTEM_HOURS" HeaderText="System Hours" SortExpression="SYSTEM_HOURS"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N4}" />
            <%--  <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Warehouse Location" SortExpression="warehouse_location_id"
                />--%>
            <eclipse:SiteHyperLinkField DataTextField="Pallet_id" HeaderText="Pallet" SortExpression="Pallet_id"
                DataTextFormatString="{0:N0}" DataNavigateUrlFormatString="R40_23.aspx?Pallet_id={0}"
                DataNavigateUrlFields="Pallet_id" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="AISLE_COUNT" HeaderText="Total Number Of|Aisles Visited"
                SortExpression="AISLE_COUNT" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="CARTONS_COUNT" HeaderText="Total Number Of|Cartons"
                SortExpression="CARTONS_COUNT" DataFormatString="{0:N0}" NullDisplayText="***"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="TOTAL_QUANTITY" HeaderText="Total Number Of|Quantity"
                SortExpression="TOTAL_QUANTITY" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="DESTINATION_LOCATION" HeaderText="Destination Location"
                SortExpression="DESTINATION_LOCATION" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

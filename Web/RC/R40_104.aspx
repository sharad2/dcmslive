﻿<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Pulled Pallet Summary Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4655 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R40_104.aspx $
 *  $Id: R40_104.aspx 4655 2012-11-17 09:28:43Z skumar $
 * Version Control Template Added.
 *
--%>
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
    <meta name="Description" content="For the specified period range, the report displays the pallet, number of cartons on the pallet and the time when the last carton was pulled ." />
    <meta name="ReportId" content="40.104" />
    <meta name="Browsable" content="false" />
    <meta name="version" content="$Id: R40_104.aspx 4655 2012-11-17 09:28:43Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
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
                <eclipse:LeftLabel runat="server" ID="lblDestinationArea" Text="Destination Area" />
                <i:TextBoxEx runat="server" ID="tbDestinationArea" QueryString="AREA">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="lblShift" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" QueryString="shift" runat="server" ToolTip="You can select shift to see the validation productivity for the selected shift." />
                <eclipse:LeftLabel ID="lblWarehouse" runat="server" Text="Building" />
                <d:BuildingSelector ID="ctlWhloc" runat="server" QueryString="warehouse_location_id" FriendlyName="Building"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ShowAll="false">
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
                     select distinct t.action_code,t.action_description
	                    from master_action_code t
                     </SelectSql>
                    <SelectParameters>
                    </SelectParameters>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="tbActionCode" QueryString="action_code" runat="server" DataSourceID="dsActionCode" 
                DataFields="action_code,action_description" DataTextFormatString="{1}" DataValueFormatString="{0}" FriendlyName="Activity" >
                <Items>
                <eclipse:DropDownItem Value="" Text="(All)" Persistent="Always" />
                </Items>
                </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting"
        CancelSelectOnNullParameter="false">
        <SelectSql>
      with q1 as(SELECT nvl(CP.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
       CP.PALLET_ID AS pallet_id,
       MAX(CP.MODULE_CODE) AS MODULE_CODE,
       MAX(CP.ACTION_CODE) AS ACTION_CODE,
       MAX(CP.OPERATOR_ID) AS EMPLOYEE,
        max(CP.process_end_date) as max_time,
       <![CDATA[
       $ShiftDateSelectClause$
       ]]>, 
       MAX(CP.CARTON_DESTINATION_AREA) AS AREA,
       CP.CARTON_ID AS no_of_cartons,
       MAX(CP.CARTON_QUANTITY) AS quantity

  FROM CARTON_PRODUCTIVITY CP

 <if>WHERE    cp.module_code=cast(:module_code as varchar2(255))</if>
          <if>And CP.action_code = cast(:action_code as varchar2(255))</if>
          <if> AND CP.process_start_date &gt;= CAST(:shift_start_date AS DATE)
           AND CP.process_start_date &lt; CAST(:shift_start_date AS DATE) + 2 </if>
           <if>AND CP.operator_id = cast(:operator as varchar2(255))</if>
          <if> AND CP.carton_destination_area = cast(:carton_destination_area as varchar2(255))</if>
        <![CDATA[
        $ShiftNumberWhereClause$
        $ShiftWhereClause$
        ]]>
        <if c="$warehouse_location_id != 'Unknown'">AND CP.Warehouse_Location_Id = :warehouse_location_id</if>
   <if c="$warehouse_location_id ='Unknown'">and CP.Warehouse_Location_Id is null</if> 

 GROUP BY 
          CP.PALLET_ID,CP.CARTON_ID,
          CP.WAREHOUSE_LOCATION_ID,
          <![CDATA[
          $ShiftDateGroupClause$
          ]]>)
      select MAX(q1.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID,
       q1.PALLET_ID             AS pallet_id,
       MAX(q1.MODULE_CODE)           AS MODULE_CODE,
       MAX(q1.ACTION_CODE)           AS ACTION_CODE,
       MAX(q1.EMPLOYEE)              AS EMPLOYEE,
       MAX(q1.max_time)              as max_time,
       MAX(q1.AREA)                  AS AREA,
       DECODE(COUNT(DISTINCT q1.no_of_cartons),0,NULL,COUNT(DISTINCT q1.no_of_cartons))   AS no_of_cartons,
       SUM(q1.quantity)              AS quantity
  from q1
  <if>where q1.shift_start_date &gt;= CAST(:shift_start_date AS DATE)
           AND q1.shift_start_date &lt; CAST(:shift_start_date AS DATE) + 1</if>
           GROUP BY q1.PALLET_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbModuleCode" Name="module_code" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbActionCode" Name="action_code" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlProcessStartDate" Name="shift_start_date" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbEmployee" Name="operator" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbDestinationArea" Name="carton_destination_area"
                Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="rbtnShift" Name="shift_number" Type="Int32" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhloc" Name="warehouse_location_id" Type="String"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" ShowFooter="true"
        DataSourceID="ds" DefaultSortExpression="warehouse_location_id;$;pallet_id;"
        AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="pallet_id" HeaderText="Pallet" DataFooterFormatString="{0:N0}"
                SortExpression="pallet_id" HeaderToolTip="Pallet ID" DataNavigateUrlFormatString="R40_23.aspx?pallet_id={0}&warehouse_location_id={1}&EMPLOYEE={2}&ACTION_CODE={3}&AREA={4}&max_time={5:d}"
                DataNavigateUrlFields="pallet_id,warehouse_location_id,EMPLOYEE,ACTION_CODE,AREA,max_time" />
            <%--<eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Warehouse Location"
                SortExpression="warehouse_location_id">
            </eclipse:MultiBoundField>--%>
            <eclipse:MultiBoundField DataFields="no_of_cartons" HeaderText="# Cartons" NullDisplayText="***" SortExpression="no_of_cartons"
                HeaderToolTip="Number of cartons on the pallet" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Quantity" SortExpression="quantity"
                HeaderToolTip="Total quantity on the pallet" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" />
            <eclipse:MultiBoundField DataFields="max_time" HeaderText="Last Carton Pulled on"
                SortExpression="max_time" DataFormatString="{0:d}  {0:HH:mm:ss}" HeaderToolTip="The time when the last carton was pulled" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

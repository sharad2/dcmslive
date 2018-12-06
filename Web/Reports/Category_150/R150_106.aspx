<%@ Page Title="Pitcher Productivity Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6735 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_106.aspx $
 *  $Id: R150_106.aspx 6735 2014-05-03 07:13:31Z skumar $
 * Version Control Template Added.
--%>
<%--Shift pattern with master detail show\hide columns on the basis of passsed parameter value --%>
<script runat="server">
   
    //Added code to hide the Warehouse Location column when the warehouse location value is passed.
    private string _whareHouseLoc;
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.Header:
                if (string.IsNullOrEmpty(_whareHouseLoc))
                {
                    foreach (DataControlField dc in gv.Columns)
                    {
                        if (dc.AccessibleHeaderText == "wlocvisible")
                        {
                            dc.Visible = true;
                        }
                    }
                }

                break;
        }
    }

    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        _whareHouseLoc = (string)e.Command.Parameters["warehouse_location_id"].Value;
        string strShiftWhereClause1 = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftWhereClause1$", string.Format(" AND {0} = :{1}", strShiftWhereClause1, "shift_start_date"));
        string strShiftNumberWhereClause1 = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause1$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause1$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause1, "shift_number"));
        }

        string strShiftWhereClause2 = ShiftSelector.GetShiftDateClause("mp.operation_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftWhereClause2$", string.Format(" AND {0} = :{1}", strShiftWhereClause2, "shift_start_date"));
        string strShiftNumberWhereClause2 = ShiftSelector.GetShiftNumberClause("mp.operation_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause2$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause2$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause2, "shift_number"));
        }
    }
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="150.106" />
    <meta name="Description" content="This report displays the details for each MPC of the pitcher on that pitching date." />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_106.aspx 6735 2014-05-03 07:13:31Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcp" runat="server">
                <eclipse:LeftLabel runat="server" Text="Pitcher" />
                <i:TextBoxEx runat="server" ID="tbPitcher" QueryString="PITCHER_NAME">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Pitching Start Date" />
                <d:BusinessDateTextBox ID="dtPitchinStartDate" runat="server" FriendlyName="Pitching Start Date"
                    Text="0" QueryString="shift_start_date">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwhID" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" QueryString="vwh_id" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel runat="server"  Text="Building"/>
                <d:BuildingSelector runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                     ShowAll="true"  FriendlyName="Building"  ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <%--In the case of ALL (value of warehouse location parameter), so the report is showing the value of warehouse 
        location in the Wloc column. In the case of passed value of warehouse location parameter, so the report is 
        not showing the value of warehouse location in the column Wloc. Due to this resaon we have made single query 
        and used the table master_sku, master_style, tab_label_group and tab_warehouse_location.
    --%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader"
        CancelSelectOnNullParameter="true" OnSelecting="ds_Selecting">
       <SelectSql>
       WITH box_prod_info AS
        (
        SELECT /*+INDEX(bp BOXPROD_P_OPERTATION_START_I) */
               bp.operator AS pitcher_name,
	           bp.process_id AS mpc_id,
	           MIN(bp.operation_start_date) AS pitching_start_time,
	           MAX(bp.operation_start_date) AS pitching_end_time,
	           COUNT(bp.ucc128_id) AS cartons_scan,
	           COUNT(DISTINCT(bp.mpc_iteration || bp.location_sequence)) AS location_scan,
	           SUM(bp.num_of_pieces) AS pieces,
	           SUM(bp.num_of_units) AS units,
	           COUNT(DISTINCT bp.pitch_aisle_id) AS num_aisle_visited,
	           MAX(bp.warehouse_location_id) AS warehouse_location_id,
               MAX(bp.label_id) as label_id
	      FROM box_productivity bp
         WHERE bp.operator = :PITCHER_NAME
	       AND bp.operation_code = 'PITCH'
	       AND bp.operation_start_date between CAST(:shift_start_date AS DATE) -1 and CAST(:shift_start_date AS DATE) + 2
           <![CDATA[
           $ShiftWhereClause1$
           ]]>
	       <if>and bp.warehouse_location_id = :warehouse_location_id</if>
           <if>and bp.vwh_id = :vwh_id</if>
           <![CDATA[
           $ShiftNumberWhereClause1$
           ]]>          
        GROUP BY bp.operator,
			     bp.process_id
        ),
        mpc_prod_info AS 
        (
        SELECT /*+INDEX(mp mpcprod_operation_date_i) */
               mp.operator AS pitcher_name,
               mp.mpc_id AS mpc_id,
               MIN(mp.operation_date) AS pitching_start_time,
               MAX(mp.operation_date) AS pitching_end_time,
               (CASE
      	         WHEN MAX(mp.repitch_mpc) = 'Y' THEN
      		        0
      	         ELSE
      		        SUM(mp.num_of_red_cartons)
               END) AS red_cartons,
               (CASE
      	         WHEN MAX(mp.repitch_mpc) = 'Y' THEN
      		        0
      	         ELSE
      		        SUM(mp.num_of_green_cartons)
               END) AS green_cartons,
               round(SUM(mp.seconds_worked) / 3600, 4) AS system_hours,
               SUM(mp.num_of_good_scans) AS good_scans,            
               (CASE
      	         WHEN MAX(mp.repitch_mpc) = 'Y' THEN
      		        (SUM(mp.num_of_green_cartons) + SUM(mp.num_of_red_cartons))
      	         ELSE
      		        0
               END) AS repitch_cartons,
               MAX(mp.warehouse_location_id) AS warehouse_location_id 
	      FROM mpc_productivity mp
         WHERE mp.operation_code = 'MPC'
           AND mp.operator = :PITCHER_NAME
           AND mp.operation_date between CAST(:shift_start_date AS DATE) -1 and CAST(:shift_start_date AS DATE) + 2
           <![CDATA[
           $ShiftWhereClause2$
           ]]>
	       <if>and mp.vwh_id = :vwh_id</if>
	      <![CDATA[
          $ShiftNumberWhereClause2$
	      ]]>
         GROUP BY mp.operator,
				  mp.mpc_id
        ), mpc_detail_info AS 
        (
        SELECT m.pitcher_name AS pitcher_name,
			   m.mpc_id AS mpc_id,
			   MAX(m.pitching_start_time) AS pitching_start_time,
			   MAX(m.pitching_end_time) AS pitching_end_time,
			   MAX(m.red_cartons) AS red_cartons,
			   MAX(m.green_cartons) AS green_cartons,
			   MAX(m.system_hours) AS system_hours,
			   MAX(m.good_scans) AS good_scans,
			   MAX(m.repitch_cartons) AS repitch_cartons,
			   MAX(m.warehouse_location_id) AS warehouse_location_id
	      FROM mpc_prod_info m
         WHERE 1 = 1
         <if>AND m.warehouse_location_id = :warehouse_location_id</if>
         GROUP BY m.pitcher_name,
					        m.mpc_id
        )
        SELECT mpc.pitcher_name AS pitcher_name,
               SUM(mpc.mpc_id) AS mpc_id,
			   mpc.pitching_start_time AS pitching_start_time,
			   mpc.pitching_end_time AS pitching_end_time,
			   max(mpc.warehouse_location_id) AS warehouse_location_id,
			   SUM(mpc.system_hours) AS total_system_hours,
			   MAX(box.label_id) AS label_id,
			   SUM(mpc.green_cartons) AS total_green_cartons,
			   SUM(mpc.red_cartons) AS total_red_cartons,
			   SUM(mpc.repitch_cartons) AS total_repitch_cartons,
			   SUM(box.cartons_scan) AS total_cartons_scan,
			   SUM(mpc.good_scans) AS total_good_scans,
			   SUM(box.pieces) AS total_pieces,
			   SUM(box.units) AS total_units,
			   SUM(box.location_scan) AS total_location_scan,
			   SUM(box.num_aisle_visited) AS total_num_aisle_visited
	      FROM mpc_detail_info mpc
	      LEFT OUTER JOIN box_prod_info box ON mpc.pitcher_name = box.pitcher_name 
										   AND mpc.mpc_id = box.mpc_id
         GROUP BY mpc.pitcher_name,
				  mpc.pitching_start_time,
				  mpc.pitching_end_time
				  
       </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPitcher" Type="String" Direction="Input" Name="PITCHER_NAME" />
            <asp:ControlParameter ControlID="dtPitchinStartDate" Type="DateTime" Direction="Input"
                Name="shift_start_date" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="pitcher_name;$;pitching_start_time;mpc_id"
        DataSourceID="ds" OnRowDataBound="gv_RowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="pitcher_name" HeaderText="Pitcher Name" SortExpression="pitcher_name" />
            <eclipse:MultiBoundField DataFields="mpc_id" HeaderText="MPC" SortExpression="mpc_id">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="pitching_start_time" HeaderText="Pitching Date and Time|Start"
                SortExpression="pitching_start_time" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}" />
            <eclipse:MultiBoundField DataFields="pitching_end_time" HeaderText="Pitching Date and Time|End"
                SortExpression="pitching_end_time" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}" />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" Visible="false" AccessibleHeaderText="wlocvisible" />
            <eclipse:MultiBoundField DataFields="total_system_hours" HeaderText="Sys Hrs." SortExpression="total_system_hours"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N4}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Lbl" SortExpression="label_id">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_green_cartons" HeaderText="Number of Boxes|GRN"
                SortExpression="total_green_cartons" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_red_cartons" HeaderText="Number of Boxes|Red"
                SortExpression="total_red_cartons" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_repitch_cartons" HeaderText="Number of Boxes|Repitch"
                SortExpression="total_repitch_cartons" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_cartons_scan" HeaderText="Number of Boxes|Scan"
                SortExpression="total_cartons_scan" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_pieces" HeaderText="Number of|Pcs." SortExpression="total_pieces"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_units" HeaderText="Number of|Units" SortExpression="total_units"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_location_scan" HeaderText="Number of|Loc Scand."
                SortExpression="total_location_scan" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_num_aisle_visited" HeaderText="Number of|Aisle Vstd."
                SortExpression="total_num_aisle_visited" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Title="Pitcher Productivity Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6749 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_01.aspx $
 *  $Id: R150_01.aspx 6749 2014-05-03 09:06:06Z skumar $
 * Version Control Template Added.
--%>
<%--Shift pattern and Multiple queries within Single Data Source--%>
<script runat="server">
    
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        String strShiftDateSelectClause1 = ShiftSelector.GetShiftDateClause("mpprod.operation_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause1$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause1));
        
        String strShiftDateGroupClause1 = ShiftSelector.GetShiftDateClause("mpprod.operation_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause1$", string.Format("{0}", strShiftDateGroupClause1));

        string strShiftNumberWhereClause1 = ShiftSelector.GetShiftNumberClause("mpprod.operation_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause1$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhereClause1$", string.Format(" AND {0} = :{1}", strShiftNumberWhereClause1, "shift_number"));
        }
        String strShiftDateSelectClause2 = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause2$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause2));

        String strShiftDateGroupClause2 = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause2$", string.Format("{0}", strShiftDateGroupClause2));

        string strShiftNumberWhereClause2 = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
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
    <meta name="ReportId" content="150.01" />
    <meta name="Description" content="This report is showing summary as well as details
     of each Pitcher for a given date or date range. In summary it is showing the 
     information for each pitcher and has the drill down on pitcher to get the detail
     for each MPC of the pitcher on particular pitching date." />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R150_01.aspx 6749 2014-05-03 09:06:06Z skumar $" />
    <meta name="ChangeLog" content="When you drill to an user resulting report will show actual start time instead of calculated start time.|Vwh column has been removed.|Summary for columns 'Loc. to be Visited' and 'Loc. Scans' have been removed. " />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcp" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Pitching Start Date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Pitching Start Date"
                    Text="-7" QueryString="pitching_start_date">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Pitching Start Date"
                    Text="0" QueryString="pitching_end_date">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:ShiftSelector ID="rbtnShift" runat="server" />
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" />
                <d:BuildingSelector runat="server" ID="ctlWhLoc" FriendlyName="Building" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ToolTip="Choose warehouse location" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwhID" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ToolTip="Select any virtual warehouse to see the information" />
                
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader"
        CancelSelectOnNullParameter="true" OnSelecting="ds_Selecting" >
            <SelectSql>
 WITH mpc_prod_info AS
 (SELECT 
   mpprod.operator AS pitcher_name,
   mpprod.mpc_id AS mpc_id,
   round(SUM(mpprod.seconds_worked), 4) AS system_hours,
   SUM(decode(mpprod.repitch_mpc, NULL, mpprod.num_of_green_cartons, 0)) AS green_cartons,
   SUM(decode(mpprod.repitch_mpc, NULL, mpprod.num_of_red_cartons, 0)) AS red_cartons,
   SUM(decode(mpprod.repitch_mpc,
              'Y',
              ((mpprod.num_of_green_cartons) + (mpprod.num_of_red_cartons)),
              0)) AS repitch_cartons,
   COUNT(DISTINCT(mpprod.mpc_id)) AS mpc_count<%--,
   mpprod.vwh_id AS vwh_id, --%>,
  <![CDATA[$ShiftDateSelectClause1$]]>
    FROM mpc_productivity mpprod
   WHERE mpprod.operation_code = 'MPC'
     AND mpprod.operation_date &gt;= CAST(:operation_start_date_from as DATE)
     AND mpprod.operation_date &lt; CAST(:operation_start_date_to as DATE) + 2
     <if>AND mpprod.VWh_ID=:vwh_id </if>
     <if>AND mpprod.warehouse_location_id=:warehouse_location_id</if>
     <![CDATA[$ShiftNumberWhereClause1$]]>
   GROUP BY mpprod.operator,
           <![CDATA[$ShiftDateGroupClause1$]]>,
            mpprod.mpc_id),
mpc_info AS
 (SELECT mpi.pitcher_name AS pitcher_name,
         mpi.shift_start_date AS pitching_date,
         max(mpi.mpc_count) AS mpc_count,
         round(max(mpi.system_hours / 3600), 4) AS system_hours,
         max(mpi.green_cartons) AS green_cartons,
         max(mpi.red_cartons) AS red_cartons,
         max(mpi.repitch_cartons) AS repitch_cartons,
         mpi.mpc_id AS mpc_id,
         COUNT(DISTINCT mia.ia_location_id) AS mpc_location
    FROM mpc_prod_info mpi
    LEFT OUTER JOIN mpcialoc mia
      ON mpi.mpc_id = mia.mpc_id
   WHERE mpi.shift_start_date &gt;= CAST(:operation_start_date_from as DATE)
     AND mpi.shift_start_date &lt; CAST(:operation_start_date_to as DATE)+ 1
   GROUP BY mpi.pitcher_name, mpi.shift_start_date, mpi.mpc_id),
box_prod_info AS
 (SELECT 
   bp.operator AS pitcher_name,
   bp.process_id AS process_id,
   <![CDATA[$ShiftDateSelectClause2$]]>,
   COUNT(bp.ucc128_id) AS num_cartons_scan,
   COUNT(DISTINCT(bp.mpc_iteration || bp.location_sequence)) AS num_location_scan,
   SUM(bp.num_of_pieces) AS num_of_pieces,
   SUM(bp.num_of_units) AS num_of_units,
   COUNT(DISTINCT ial.pitch_aisle_id) AS num_aisle_visited
    FROM box_productivity bp
    LEFT OUTER JOIN ialoc ial
      ON bp.to_location_id = ial.location_id
   WHERE bp.operation_code = 'PITCH'
     AND bp.operation_start_date &gt;= CAST(:operation_start_date_from As DATE)
     AND bp.operation_start_date &lt; CAST(:operation_start_date_to as DATE) + 2
     <if>AND bp.Vwh_id=:vwh_id</if>
     <if>AND bp.warehouse_location_id=:warehouse_location_id</if>
     <![CDATA[$ShiftNumberWhereClause2$]]>
   GROUP BY bp.operator,
            bp.process_id,
            <![CDATA[$ShiftDateGroupClause2$]]>),
box_info AS
 (SELECT bpi.pitcher_name AS pitcher_name,
         bpi.shift_start_date AS pitching_date,
         SUM(bpi.num_cartons_scan) AS num_cartons_scan,
         SUM(bpi.num_location_scan) AS num_location_scan,
         SUM(bpi.num_of_pieces) AS num_of_pieces,
         SUM(bpi.num_of_units) AS num_of_units,
         nvl(SUM(num_aisle_visited), 0) AS num_aisle_visited,
         bpi.process_id AS process_id
    FROM box_prod_info bpi
   WHERE bpi.shift_start_date &gt;= CAST(:operation_start_date_from as DATE)
     AND bpi.shift_start_date &lt; CAST(:operation_start_date_to as DATE)+ 1
   GROUP BY bpi.pitcher_name,
            bpi.shift_start_date,
            bpi.process_id)
SELECT mi.pitcher_name AS pitcher_name, 
       mi.pitching_date AS shift_start_date, SUM(mi.system_hours) AS system_hours, SUM(mi.mpc_count) AS mpc_count, SUM(mi.green_cartons) AS green_cartons, SUM(mi.red_cartons) AS red_cartons, SUM(mi.repitch_cartons) AS repitch_cartons, nvl(SUM(mi.mpc_location), 0) AS mpc_location, nvl(SUM(bi.num_cartons_scan), 0) AS num_cartons_scan, nvl(SUM(bi.num_location_scan), 0) AS num_location_scan, nvl(SUM(bi.num_aisle_visited), 0) AS num_aisle_visited, nvl(SUM(bi.num_of_pieces), 0) AS num_of_pieces, nvl(SUM(bi.num_of_units), 0) AS num_of_units, MAX(au.created) AS user_setup_date
  FROM mpc_info mi
  LEFT OUTER JOIN box_info bi
    ON mi.pitcher_name = bi.pitcher_name AND mi.pitching_date = bi.pitching_date  AND mi.mpc_id = bi.process_id
  LEFT OUTER JOIN all_users au
    ON au.username = mi.pitcher_name
 GROUP BY mi.pitcher_name, mi.pitching_date
            </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true" 
        ShowFooter="true" DefaultSortExpression="PITCHER_NAME;shift_start_date {0:I}" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="PITCHER_NAME" HeaderText="Pitcher Name"
                SortExpression="PITCHER_NAME" DataNavigateUrlFormatString="R150_106.aspx?PITCHER_NAME={0}&shift_start_date={1:d}"
                DataNavigateUrlFields="PITCHER_NAME,shift_start_date" AppliedFiltersControlID="ctlButtonBar$af"
                HeaderToolTip="Pitcher Name" />
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="Pitching Date"
                SortExpression="shift_start_date" DataFormatString="{0:d}" HeaderToolTip="Shift Date on which Pitcher performe the Pitching opertation" />
            <eclipse:MultiBoundField DataFields="SYSTEM_HOURS" HeaderText="System Hrs." SortExpression="system_hours"
                ItemStyle-HorizontalAlign="Right" HeaderToolTip="System Hrs." />
            <eclipse:MultiBoundField DataFields="MPC_COUNT" HeaderText="Number of|MPC" SortExpression="MPC_COUNT"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                FooterToolTip="Sum of MPC count">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="GREEN_CARTONS" HeaderStyle-Wrap="false" HeaderText="Number of|GRN Boxes"
                SortExpression="GREEN_CARTONS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of green boxes.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="RED_CARTONS" HeaderText="Number of|Red Boxes"
                SortExpression="RED_CARTONS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of red boxes.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="REPITCH_CARTONS" HeaderText="Number of|Repitch Boxes"
                SortExpression="REPITCH_CARTONS" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of repitch boxes">
                <HeaderStyle Wrap="true" />
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NUM_CARTONS_SCAN" HeaderText="Number of|Box Scans"
                SortExpression="NUM_CARTONS_SCAN" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of scans boxes.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="mpc_location" HeaderText="Number of|Loc. to be Visited"
                SortExpression="mpc_location" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of location vistied.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NUM_LOCATION_SCAN" HeaderText="Number of|Loc. Scans"
                SortExpression="num_location_scan" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of loction scans.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NUM_AISLE_VISITED" HeaderText="Number of|Aisle Visited"
                SortExpression="NUM_AISLE_VISITED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Total no of aisle visited.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NUM_OF_PIECES" HeaderText="Number of|Pieces"
                SortExpression="NUM_OF_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="sum of pitched pieces.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="NUM_OF_UNITS" HeaderText="Number of|Units" SortExpression="NUM_OF_UNITS"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                FooterToolTip="Sum of Pitched units">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date"
                SortExpression="user_setup_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

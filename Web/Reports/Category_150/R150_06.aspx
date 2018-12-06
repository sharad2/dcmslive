<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Hourly Productivity Report" %>

<%@ Import Namespace="EclipseLibrary.Web.Extensions" %>
<%@ Import Namespace="DcmsDatabase.Web.Selectors" %>
<%@ Import Namespace="System.Configuration" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4812 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_06.aspx $
 *  $Id: R150_06.aspx 4812 2013-01-08 04:34:39Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern and calculating the moving average --%>
<script runat="server">
    private TimeSpan _breakDuration = TimeSpan.FromMinutes(Convert.ToDouble(ConfigurationManager.AppSettings["LunchHour"]));

    /// <summary>
    /// The breaks occur how many hours after start of first shift
    /// </summary>
    private DateTime _prevWorkingDayStart;

    private int _cumulativeTotalPieces;
    private double _cumSystemHours;

    // We make all rows of the same date the same color
    bool _bIsAlternate = true;
    protected override void OnInit(EventArgs e)
    {
        gv.DataBound += new EventHandler(gv_DataBound);
        base.OnInit(e);
    }
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                var Opcode = DataBinder.Eval(e.Row.DataItem, "operation_code");
                    DateTime curEndTime = (DateTime)DataBinder.Eval(e.Row.DataItem, "end_time");
                    DateTime curStartTime = (DateTime)DataBinder.Eval(e.Row.DataItem, "start_time");
                    DateTime curWorkingDayStart = rbtnShift.GetShiftStartTime(curEndTime);
                    DateTime curWorkingDayStart1 = new DateTime(curWorkingDayStart.Year, curWorkingDayStart.Month, curWorkingDayStart.Day,
                        curWorkingDayStart.Hour, 0, 0);
                    if (_prevWorkingDayStart == default(DateTime) || curWorkingDayStart != _prevWorkingDayStart)
                    {
                        // Working day has changed
                        _cumulativeTotalPieces = 0;
                        _prevWorkingDayStart = curWorkingDayStart;
                        _bIsAlternate = !_bIsAlternate;
                        _cumSystemHours = 0;
                    }
                    if (_bIsAlternate)
                    {
                        e.Row.RowState |= DataControlRowState.Alternate;
                    }
                    else
                    {
                        e.Row.RowState &= ~DataControlRowState.Alternate;
                    }
                    object objTimeSpan = DataBinder.Eval(e.Row.DataItem, "system_seconds");
                    if (objTimeSpan == DBNull.Value)
                    {
                        // If no system hours, do not show moving averages. This makes the column blank for RST
                        break;
                    }

                    Label lblMovingAverage = (Label)e.Row.FindControl("lblMovingAverage");
                    Label lblMovingSytemAverage = (Label)e.Row.FindControl("lblMovingSytemAverage");
                    // This is one way to truncate to hour
                    DateTime curEndHour = new DateTime(curEndTime.Year, curEndTime.Month, curEndTime.Day,
                        curEndTime.Hour, 0, 0);
                    curEndHour = curEndHour.AddHours(1);
                    TimeSpan spanClockHours = curEndHour - curWorkingDayStart1;
                    _cumulativeTotalPieces += Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "total_pieces"));

                    int nBreaks = rbtnShift.GetNumberofBreaks(spanClockHours);
                    //TimeSpan spanWorkingHours = spanClockHours - TimeSpan.FromMinutes(DcmsDatabase.Web.Selectors.ShiftSelector.BreakDuration.TotalMinutes * nBreaks);
                    TimeSpan spanWorkingHours = spanClockHours - TimeSpan.FromMinutes(_breakDuration.Minutes * nBreaks);

                    // Start time to be displayed
                    DateTime curWorkingDayStartDisplay = curWorkingDayStart;
                    if (string.IsNullOrEmpty(rbtnShift.Value) || rbtnShift.Value == "1")
                    {
                        // For the first shift, working hours are two hours less
                        spanWorkingHours -= TimeSpan.FromHours(2);
                        spanClockHours -= TimeSpan.FromHours(2);
                        curWorkingDayStartDisplay += TimeSpan.FromHours(2);
                    }
                    double? dWorkingHourAverage;
                    if (spanWorkingHours > TimeSpan.Zero)
                    {
                        dWorkingHourAverage = _cumulativeTotalPieces / spanWorkingHours.TotalHours;
                    }
                    else
                    {
                        dWorkingHourAverage = null;
                    }

                    lblMovingAverage.Text = string.Format("{0:N2}", dWorkingHourAverage);
                    lblMovingAverage.ToolTip = string.Format(
                        @"{0:t} - {1:t} = {2:N1} clock hours - {3} * {4} min breaks = {5:N1} working hours
                    Av Pieces = {6:N0} pieces / {5:N1} hours = {7:N2} pieces/hr
                    ", curWorkingDayStartDisplay, curEndHour, spanClockHours.Hours,
                       nBreaks, DcmsDatabase.Web.Selectors.ShiftSelector.BreakDuration.TotalMinutes,
                       spanWorkingHours.TotalHours, _cumulativeTotalPieces, dWorkingHourAverage);

                    //Calculating the system hours

                    Label lblSytemHour = (Label)e.Row.FindControl("lblSytemHour");
                    _cumSystemHours += Convert.ToDouble(objTimeSpan);
                    double f = _cumulativeTotalPieces / _cumSystemHours;
                    lblSytemHour.Text = string.Format("{0:N4}", _cumSystemHours);
                    lblMovingSytemAverage.Text = string.Format("{0:N2}", f);
                    lblMovingSytemAverage.ToolTip = string.Format("{0:N0} pieces / {1:N4} system hours = {2:N4}",
                        _cumulativeTotalPieces, _cumSystemHours, f);

                    if (curStartTime.Hour >= 5 && curStartTime.Hour < 7)
                    {
                        lblMovingAverage.Text = string.Empty;
                        lblMovingSytemAverage.Text = string.Empty;
                    }
                    if (curStartTime.Hour >= 2.3 && curStartTime.Hour < 5)
                    {
                        lblMovingAverage.Text = string.Empty;
                        lblMovingSytemAverage.Text = string.Empty;
                    }
                    break;
                

            case DataControlRowType.Footer:
                if (e.Row.Cells[0].Text == "Total")
                {
                    e.Row.Visible = false;
                }
                break;
        }
                
    }

    protected void gv_DataBound(object send, EventArgs e)
    {
          
        if (Page.IsPostBack)
        {

            var startTimeCellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "Start Time" ? i : -1)
             .Single(p => p >= 0);
            var vwhCellindex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "VWh" ? i : -1)
                        .Single(p => p >= 0);
            var piecesPerClockHourCellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "Running Av Pieces Per|Clock Hour" ? i : -1)
                        .Single(p => p >= 0);
            var piecesPerPitchHourCellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "Running Av Pieces Per|Pitch Hour" ? i : -1)
                        .Single(p => p >= 0);
            if (gv.Rows.Count > 1)
            {
                for (int tempIndex = 0; tempIndex <= gv.Rows.Count - 1; tempIndex++)
                {

                    int currentRowHour = Convert.ToDateTime(gv.Rows[tempIndex].Cells[startTimeCellIndex].Text).Hour;
                    int nextRowHour = Convert.ToDateTime(gv.Rows[tempIndex + 1].Cells[startTimeCellIndex].Text).Hour;
                    if (gv.Rows[tempIndex].Cells[vwhCellindex].Text != gv.Rows[tempIndex + 1].Cells[vwhCellindex].Text && (currentRowHour - nextRowHour == 0))
                    {
                        gv.Rows[tempIndex].Cells[piecesPerClockHourCellIndex].Text = string.Empty;
                        gv.Rows[tempIndex].Cells[piecesPerPitchHourCellIndex].Text = string.Empty;

                    }
                    if (gv.Rows.Count - tempIndex == 2)
                    {
                        break;
                    }

                }
            }
            
        }       
        
    }


    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause1 = ShiftSelector.GetShiftDateClause("BP.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause1$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause1));

        string strShiftDateSelectClause2 = ShiftSelector.GetShiftDateClause("mp.operation_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause2$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause2));

        string strShiftDateGroupClause = ShiftSelector.GetShiftDateClause("MI.operation_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause$", string.Format("{0}", strShiftDateGroupClause));

        string strShiftNumberWhere1 = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere1$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere1$", string.Format(" AND {0} = :{1}", strShiftNumberWhere1, "shift_number"));
        }
        string strShiftNumberWhere2 = ShiftSelector.GetShiftNumberClause("mp.operation_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere2$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere2$", string.Format(" AND {0} = :{1}", strShiftNumberWhere2, "shift_number"));
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
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays the pitching and restocking hourly productivity for a given operation date or date range. You can also filter on the basis of first shift,second shift or 
    all shifts along with the Vitual Warehouse and warehouse location. Displays the over all productivity within the DC(Distribution center).
    Also display running average of pitched pieces per clock hour and pieces to be piteched in one hour based on the scanning time." />
    <meta name="ReportId" content="150.06" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content=" $Id: R150_06.aspx 4812 2013-01-08 04:34:39Z skumar $" />
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
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Operation date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server"  FriendlyName="From operation date"
                    Text="0" ToolTip="Please specify a date or date range here.">
                    <Validators>
                        <i:Date />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To operation date"
                    Text="0" ToolTip="Please specify a date or date range here. ">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwhID" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true">
                </d:VirtualWarehouseSelector>
                <%--<eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Warehouse Location" />--%>
                <%--<d:BuildingSelector runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true">
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
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        OnSelecting="ds_Selecting" >
          <SelectSql>
            WITH BOX_MAIN AS
 (SELECT BP.OPERATION_CODE AS OPERATION_CODE,
         BP.OPERATION_START_DATE AS OPERATION_START_DATE,
         BP.OPERATION_START_DATE AS START_TIME,
         BP.OPERATION_START_DATE AS END_TIME,
         BP.NUM_OF_PIECES AS NUM_OF_PIECES,
         BP.NUM_OF_UNITS AS NUM_OF_UNITS,
         BP.VWH_ID AS VWH_ID,
         <![CDATA[
         $ShiftDateSelectClause1$
         ]]>
    FROM BOX_PRODUCTIVITY BP
   WHERE ((BP.OPERATION_CODE = '$RST' AND BP.OUTCOME = 'RESTOCKED') OR
         (BP.OPERATION_CODE = 'PITCH'))
         <![CDATA[
         $ShiftNumberWhere1$
         ]]>
     AND BP.OPERATION_START_DATE &gt;= CAST(:operation_start_date_from AS DATE)
     AND BP.OPERATION_START_DATE &lt; CAST(:operation_start_date_to AS DATE) + 2
     <if>AND <a pre="BP.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>),

BOX_INNER AS
 (SELECT DECODE(BPM.OPERATION_CODE, '$RST', 'RESTOCK', BPM.OPERATION_CODE) AS OPERATION_CODE,
         TRUNC(BPM.OPERATION_START_DATE, 'hh24') AS OPERATION_START_DATE,
         MIN(BPM.OPERATION_START_DATE) AS START_TIME,
         MAX(BPM.OPERATION_START_DATE) AS END_TIME,
         SUM(BPM.NUM_OF_PIECES) AS TOTAL_PIECES,
         SUM(BPM.NUM_OF_UNITS) AS TOTAL_UNITS,
         MAX(BPM.VWH_ID) AS VWH_ID,
         BPM.SHIFT_START_DATE AS SHIFT_START_DATE
    FROM BOX_MAIN BPM
   WHERE BPM.SHIFT_START_DATE &gt;= CAST(:operation_start_date_from AS DATE)
     AND BPM.SHIFT_START_DATE &lt; CAST(:operation_start_date_to AS DATE) + 1
     <if>AND BPM.VWH_ID =:VWH_ID</if>     
   GROUP BY BPM.OPERATION_CODE,
            TRUNC(BPM.OPERATION_START_DATE, 'hh24'),     
            BPM.SHIFT_START_DATE,
            BPM.VWH_ID
        ),
MPC_MAIN AS
 (SELECT MP.OPERATION_CODE AS OPERATION_CODE,
         MP.OPERATION_DATE AS OPERATION_DATE,
         MP.VWH_ID AS VWH_ID,
        <![CDATA[
        $ShiftDateSelectClause2$
        ]]>,
         MP.SECONDS_WORKED AS SECONDS_WORKED
    FROM MPC_PRODUCTIVITY MP  
   
   WHERE MP.OPERATION_DATE &gt;= CAST(:operation_start_date_from AS DATE)
     AND MP.OPERATION_DATE &lt; CAST(:operation_start_date_to AS DATE) + 2  

     <if>AND <a pre="MP.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>AND MP.VWh_id=:Vwh_id</if>
     <![CDATA[
     $ShiftNumberWhere2$
     ]]>                                       
     ),
MPC_INNER AS
 (SELECT MI.OPERATION_CODE AS OPERATION_CODE,
         TRUNC(MI.OPERATION_DATE, 'hh24') AS OPERATION_DATE_HOUR,
        MI.VWH_ID AS VWH_ID,
         MI.SHIFT_START_DATE AS SHIFT_START_DATE,
         sum(round(MI.SECONDS_WORKED/3600,4)) AS TOTAL_SYSTEM_SECONDS
    FROM MPC_MAIN MI
   WHERE MI.SHIFT_START_DATE &gt;= CAST(:operation_start_date_from AS DATE)
     AND MI.SHIFT_START_DATE &lt; CAST(:operation_start_date_to AS DATE) + 1       
   GROUP BY MI.OPERATION_CODE,
            MI.VWH_ID ,
            TRUNC(MI.OPERATION_DATE, 'hh24'),
             MI.SHIFT_START_DATE)
SELECT BI.OPERATION_CODE AS OPERATION_CODE,
       BI.OPERATION_START_DATE AS OPERATION_START_DATE,
       BI.START_TIME AS START_TIME,
       BI.END_TIME AS END_TIME,
       BI.TOTAL_PIECES AS TOTAL_PIECES,
       BI.TOTAL_UNITS AS TOTAL_UNITS,
       BI.VWH_ID AS VWH_ID,
       BI.SHIFT_START_DATE AS SHIFT_START_DATE,
       CASE
         WHEN BI.OPERATION_CODE = 'PITCH' THEN
          MPI.TOTAL_SYSTEM_SECONDS
       END AS SYSTEM_SECONDS
  FROM BOX_INNER BI
  LEFT OUTER JOIN MPC_INNER MPI
    ON BI.OPERATION_START_DATE = MPI.OPERATION_DATE_HOUR
   AND BI.SHIFT_START_DATE = MPI.SHIFT_START_DATE
   AND BI.VWH_ID = MPI.VWH_ID
  
          </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="ctlVwhID" Type="String" Direction="Input" Name="VWH_ID" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="WAREHOUSE_LOCATION_ID" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        OnRowDataBound="gv_RowDataBound" ShowFooter="true" ShowHeader="true"   DefaultSortExpression="operation_code;$;operation_start_date;vwh_id"
        DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" AccessibleHeaderText="VWh"  SortExpression="vwh_id"
                HeaderToolTip="Virtual warehouse ID" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="operation_code" HeaderText="Operation" SortExpression="operation_code">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="operation_start_date" HeaderText="Operation Date"
                HeaderToolTip="Displays operation start date of pieces/units for a particular operation date or data range during a particular hour"
                SortExpression="operation_start_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="start_time" HeaderText="Start Time" AccessibleHeaderText="Start Time"  SortExpression="start_time"
                HeaderToolTip="Displays start time of pieces/units pitched during a particular hour"
                DataFormatString="{0:HH:mm:ss}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="end_time" HeaderText="End Time" SortExpression="end_time"
                HeaderToolTip="Displays end time  of pieces/units for a particular operation date or data range during a particular hour"
                DataFormatString="{0:HH:mm:ss}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_pieces" HeaderText="Total Pieces" SortExpression="total_pieces"
                HeaderToolTip="Displays total pieces for a particular operation date or data range during a particular hour"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"  DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="total_units" HeaderText="Total Units" SortExpression="total_units"
                HeaderToolTip="Displays total units for a particular operation date or data range during a particular hour"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <asp:TemplateField HeaderText="Running Av Pieces Per|Clock Hour" AccessibleHeaderText="Running Av Pieces Per|Clock Hour" >
                <ItemStyle HorizontalAlign="Right" />
                <ItemTemplate>
                    <asp:Label runat="server" ID="lblMovingAverage" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Running Av Pieces Per|Pitch Hour" AccessibleHeaderText="Running Av Pieces Per|Pitch Hour" >
                <ItemStyle HorizontalAlign="Right" />
                <ItemTemplate>
                    <asp:Label runat="server" ID="lblMovingSytemAverage" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Pitch Hour" Visible="false">
                <ItemStyle HorizontalAlign="Right" />
                <ItemTemplate>
                    <asp:Label runat="server" ID="lblSytemHour" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

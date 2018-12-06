<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Picking Area Cycle Count Report" %>
<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3437 $
 *  $Author: rverma $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_21.aspx $
 *  $Id: R130_21.aspx 3437 2012-05-03 11:48:50Z rverma $
 * Version Control Template Added.
 *
--%>

<script runat="server">

    /// <summary>
    /// The event is used to hang to each event required in the report.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        gv.RowDataBound += new GridViewRowEventHandler(gv_RowDataBound);
        gv.DataBound += new EventHandler(gv_DataBound);
        dsUnscannedLoc.Selecting += new SqlDataSourceSelectingEventHandler(dsUnscannedLoc_Selecting);
        base.OnInit(e);
    }

    /// <summary>
    /// Queries on first load only if query string is there or when check box unscenned location is un checked 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void dsUnscannedLoc_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if ((!this.IsPostBack && this.Page.Request.QueryString.Count == 0) || (!cbUnscannedLoc.Checked))
        {
            e.Cancel = true;
            return;
        }
    }


    private decimal _countErrorLocations = 0;
    /// <summary>
    /// Fetched the number of error locations.
    /// For each row if scanned pieces does not matches 
    /// system pieces the error location is increased by 1.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                object objScannedPieces = DataBinder.Eval(e.Row.DataItem, "SCANNED_PIECES");
                object objSystemPieces = DataBinder.Eval(e.Row.DataItem, "SYSTEM_PIECES");
                if (!objScannedPieces.Equals(objSystemPieces))
                {
                    _countErrorLocations++;
                }
                break;
        }
    }

    /// <summary>
    /// Evaluates location accuracy and pieces accuracy.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void gv_DataBound(object sender, EventArgs e)
    {
        if (gv.Rows.Count == 0)
        {
            return;
        }
        decimal accuracy = (1 - (_countErrorLocations / gv.Rows.Count)) * 100;

        decimal countSystemPieces = (from MultiBoundField mf in gv.Columns.OfType<MultiBoundField>()
                                     where mf.DataFields[0] == "SYSTEM_PIECES"
                                     select mf).Single().SummaryValues[0].Value;

        decimal countScannedPieces = (from MultiBoundField mf in gv.Columns.OfType<MultiBoundField>()
                                      where mf.DataFields[0] == "SCANNED_PIECES"
                                      select mf).Single().SummaryValues[0].Value;

        decimal piecesAccuracy;
        if (countSystemPieces > 0)
        {
            piecesAccuracy = (1 - Math.Abs(countScannedPieces - countSystemPieces) / countSystemPieces) * 100;
            if (piecesAccuracy < 0 || piecesAccuracy > 100)
            {
                piecesAccuracy = -1;
            }
        }
        else
        {
            piecesAccuracy = -1;
        }

        spanSummary.Visible = true;
        tbTotalLocations.Text = gv.Rows.Count.ToString();
        tbErrorLocations.Text = _countErrorLocations.ToString();
        tbAccuracy.Text = accuracy.ToString("N2") + "%";
        tbSystemPieces.Text = countSystemPieces.ToString();
        tbScannedPieces.Text = countScannedPieces.ToString();
        tbPiecesAccuracy.Text = piecesAccuracy == -1 ? "NaN" : piecesAccuracy.ToString("N2") + "%";
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.21" />
    <meta name="Description" content="This report displays the cycle count accuracy of forward pick 
                                    locations for a specified period of time. Locations displayed can 
                                    be restricted by specifying pitch aisle or location range. You have 
                                    options to view discrepant locations only or locations not scanned" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_21.aspx 3437 2012-05-03 11:48:50Z rverma $" />
    <style type="text/css">
        .locationSummary
        {
            font-family: Arial;
            font-size: 10px;
            font-style: normal;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="CYC Date Range" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" Text="-7" FriendlyName="CYC From Date">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" Text="0" FriendlyName="CYC To Date">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <i:RadioButtonListEx ID="rbl" runat="server" Value="pitch" QueryString="customer_filter" />
                <eclipse:LeftPanel runat="server">
                    <i:RadioItemProxy runat="server" Text="Pitch Aisle" CheckedValue="pitch" QueryString="customer_filter"
                        FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel runat="server" ID="pnlPitchAisle">
                    <i:TextBoxEx ID="tbPitchAisle" runat="server" FriendlyName="Pitch Aisle">
                        <Validators>
                            <i:Filter DependsOn="rbl" DependsOnState="Value" DependsOnValue="pitch" />
                        </Validators>
                    </i:TextBoxEx>
                </asp:Panel>
                <eclipse:LeftPanel runat="server">
                    <i:RadioItemProxy runat="server" Text="Locations" CheckedValue="locations" QueryString="customer_filter"
                        FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel runat="server">
                    <eclipse:LeftLabel runat="server" Text="From Location" />
                    <i:TextBoxEx ID="tbFromLocation" runat="server" FriendlyName="From Location">
                        <Validators>
                            <i:Filter DependsOn="rbl" DependsOnState="Value" DependsOnValue="locations" />
                        </Validators>
                    </i:TextBoxEx>
                    <eclipse:LeftLabel runat="server" Text="To Location" />
                    <i:TextBoxEx ID="tbToLocation" runat="server" FriendlyName="To Location">
                        <Validators>
                            <i:Filter DependsOn="rbl" DependsOnState="Value" DependsOnValue="locations" />
                        </Validators>
                    </i:TextBoxEx>
                </asp:Panel>
            </eclipse:TwoColumnPanel>
            <i:CheckBoxEx ID="cbNoHideDiscpLoc" runat="server" CheckedValue="Y" Text="Hide No Discrepeant Locations" FriendlyName="Hide No Discrepeant Locations" />
            <br />
            <i:CheckBoxEx ID="cbUnscannedLoc" runat="server" Text="Show not Scanned Locations" FriendlyName="Show not Scanned Locations" />
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" >
<SelectSql>
SELECT ms.style               AS style,
               ms.color               AS color,
               ms.dimension           AS dimension,
               ms.sku_size            AS sku_size,
               cpd.location_id        AS location,
               cpd.upc_code           AS upc_code,
               cpd.new_pieces         AS scanned_pieces,
               cpd.original_pieces    AS system_pieces,
               cpd.cyc_start_date     AS cyc_start_date,
               cpd.cyc_end_date       AS cyc_end_date,
               cpd.process_iteration  AS iteration,
               cp.cyc_user            AS cyc_user,
               cpd.process_id         AS process_id,
               cpd.recount_process_id AS recount_process_id
          FROM cyc_process_detail cpd
          LEFT OUTER JOIN cyc_process cp
            ON cpd.process_id = cp.process_id
          LEFT OUTER JOIN master_sku ms
            ON cpd.upc_code = ms.upc_code
          <if c="$PITCH_AISLE_ID">LEFT OUTER JOIN ialoc ialoc ON cpd.location_id = ialoc.location_id</if>
         WHERE cpd.recount_process_id IS NULL
           AND cp.cyc_start_date &gt;= CAST(:CYC_START_DATE AS DATE)
           AND cp.cyc_start_date &lt; CAST(:CYC_END_DATE AS DATE)+ 1
           <if>AND ialoc.ia_id IN (SELECT ia_id FROM ia WHERE ia.picking_area_flag = 'Y') AND ialoc.pitch_aisle_id = CAST(:PITCH_AISLE_ID AS Varchar2(255))</if>
           <if c="$FROM_LOCATION">AND cpd.location_id &gt;= CAST(:FROM_LOCATION AS VARCHAR2(255)) AND cpd.location_id &lt;= CAST(:TO_LOCATION AS VARCHAR2(255))</if>
           <if c="$NO_HIDE">AND cpd.new_pieces &lt;&gt; cpd.original_pieces</if>
        UNION ALL
        SELECT ms.style               AS style,
               ms.color               AS color,
               ms.dimension           AS dimension,
               ms.sku_size            AS sku_size,
               cpd.location_id        AS location,
               cpd.upc_code           AS upc_code,
               cpd.new_pieces         AS scanned_pieces,
               cpd.original_pieces    AS system_pieces,
               cpd.cyc_start_date     AS cyc_start_date,
               cpd.cyc_end_date       AS cyc_end_date,
               cpd.process_iteration  AS iteration,
               cp.cyc_user            AS cyc_user,
               cpd.process_id         AS process_id,
               cpd.recount_process_id AS recount_process_id
          FROM cyc_process_detail cpd
          LEFT OUTER JOIN cyc_process cp
            ON cpd.recount_process_id = cp.process_id
          LEFT OUTER JOIN master_sku ms
            ON cpd.upc_code = ms.upc_code
            <if c="$pitch_aisle_id">LEFT OUTER JOIN ialoc ialoc ON cpd.location_id = ialoc.location_id</if>
         WHERE cpd.recount_process_id IS NOT NULL
           AND cp.cyc_start_date &gt;= CAST(:CYC_START_DATE AS DATE)
           AND cp.cyc_start_date &lt; CAST(:CYC_END_DATE AS DATE) + 1
           <if> AND ialoc.ia_id IN (SELECT ia_id FROM ia WHERE ia.picking_area_flag = 'Y') AND ialoc.pitch_aisle_id = CAST(:PITCH_AISLE_ID AS Varchar2(255))</if>
           <if c="$FROM_LOCATION"> AND cpd.location_id &gt;= CAST(:FROM_LOCATION AS VARCHAR2(255)) AND cpd.location_id &lt;= CAST(:TO_LOCATION AS VARCHAR2(255))</if>
           <if c="$NO_HIDE"> AND cpd.new_pieces &lt;&gt; cpd.original_pieces</if>
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Name="CYC_START_DATE" Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Name="CYC_END_DATE" Direction="Input" />
            <asp:ControlParameter ControlID="tbPitchAisle" Type="String" Name="PITCH_AISLE_ID"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbFromLocation" Type="String" Name="FROM_LOCATION"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbToLocation" Type="String" Name="TO_LOCATION" Direction="Input" />
            <asp:ControlParameter ControlID="cbNoHideDiscpLoc" Type="String" Name="No_Hide" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <span id="spanSummary" class="locationSummary" visible="false" runat="server"><i>Location
        Accuracy Detail:</i> <b>Total Locations:<asp:Label ID="tbTotalLocations" runat="server" />
            Error Locations:<asp:Label ID="tbErrorLocations" runat="server" />
            Accuracy:<asp:Label ID="tbAccuracy" runat="server" />
        </b>
        <br />
        <i>Pieces Accuracy Detail:</i> <b>System Pieces:<asp:Label ID="tbSystemPieces" runat="server" />
            Scanned Pieces:<asp:Label ID="tbScannedPieces" runat="server" />
            Pieces Accuracy:<asp:Label ID="tbPiecesAccuracy" runat="server" /></b> </span>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="LOCATION"
        AutoGenerateColumns="false" ShowFooter="true" AllowSorting="true" CaptionAlign="Left">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="LOCATION" HeaderText="Location" SortExpression="LOCATION" />
            <eclipse:MultiBoundField DataFields="CYC_START_DATE" HeaderText="CYC Start Date"
                SortExpression="CYC_START_DATE" HeaderToolTip="Cycle count start date" />
            <eclipse:MultiBoundField DataFields="CYC_END_DATE" HeaderText="CYC End Date" SortExpression="CYC_END_DATE"
                HeaderToolTip="Cycle count end date" />
            <asp:BoundField DataField="UPC_CODE" HeaderText="UPC Code" SortExpression="UPC_CODE" />
            <asp:BoundField DataField="STYLE" HeaderText="Style" SortExpression="STYLE" />
            <asp:BoundField DataField="COLOR" HeaderText="Color" SortExpression="COLOR" />
            <asp:BoundField DataField="DIMENSION" HeaderText="Dim" SortExpression="DIMENSION" />
            <asp:BoundField DataField="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE" />
            <eclipse:MultiBoundField DataFields="SYSTEM_PIECES" HeaderText="System Pieces" SortExpression="SYSTEM_PIECES"
                FooterToolTip="Total System Pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" HeaderToolTip="The quantity of SKU's reflected by the system">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SCANNED_PIECES" HeaderText="Scanned Pieces"
                HeaderToolTip="Actual quantity at the location(Manually counted)" SortExpression="SCANNED_PIECES"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" FooterToolTip="Total Scanned Pieces"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ITERATION" HeaderText="Iteration" SortExpression="ITERATION"
                ItemStyle-HorizontalAlign="Right" HeaderToolTip="Cycle Count Iteration" />
            <eclipse:MultiBoundField DataFields="CYC_USER" HeaderText="CYC User" SortExpression="CYC_USER"
                HeaderToolTip="The user who initiated the cycle count" />
        </Columns>
    </jquery:GridViewEx>
    <oracle:OracleDataSource ID="dsUnscannedLoc" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" >
         <SelectSql>
         SELECT IALOC.LOCATION_ID AS LOCATION_ID
          FROM IALOC IALOC
         WHERE IALOC.IA_ID IN (SELECT ia_id FROM ia WHERE ia.picking_area_flag = 'Y')
         <if c="$FROM_LOCATION">AND IALOC.LOCATION_ID &gt;= CAST(:FROM_LOCATION as varchar2(255)) AND IALOC.LOCATION_ID &lt;= cast(:TO_LOCATION as varchar2(255))</if>
         <if>AND IALOC.PITCH_AISLE_ID = CAST(:PITCH_AISLE_ID as varchar2(255))</if>
         AND NOT EXISTS
         (SELECT DISTINCT (CPD.LOCATION_ID) AS LOCATION
            FROM CYC_PROCESS_DETAIL CPD
           WHERE CPD.LOCATION_ID = IALOC.LOCATION_ID
             AND CPD.CYC_START_DATE &gt;= cast(:CYC_START_DATE as date)
             AND CPD.CYC_START_DATE &lt; cast(:CYC_END_DATE as date)+ 1)
         </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Name="CYC_START_DATE" Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Name="CYC_END_DATE" Direction="Input" />
            <asp:ControlParameter ControlID="tbFromLocation" Type="String" Name="FROM_LOCATION"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbToLocation" Type="String" Name="TO_LOCATION" Direction="Input" />
            <asp:ControlParameter ControlID="tbPitchAisle" Type="String" Name="PITCH_AISLE_ID"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <br />
    <jquery:GridViewEx ID="gvUnscannedLoc" runat="server" DataSourceID="dsUnscannedLoc"
        DefaultSortExpression="LOCATION_ID" AutoGenerateColumns="false" Caption="<b>Showing all not scanned locations</b>">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="LOCATION_ID" HeaderText="Location" SortExpression="LOCATION_ID" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

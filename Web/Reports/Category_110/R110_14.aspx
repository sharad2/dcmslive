<%@ Page Title="Box QC Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="EclipseLibrary.Web.Extensions" %>
<%@ Import Namespace="DcmsDatabase.Web.Selectors" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4899 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_14.aspx $
 *  $Id: R110_14.aspx 4899 2013-01-23 12:17:08Z rverma $
 * Version Control Template Added.
 *
--%>
<%--Shift pattern and calculating --%>
<script runat="server">

    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        decimal pctPieces = 0;
        int? PitchedPieces;
        int? ScanedPieces;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            PitchedPieces = DataBinder.Eval(e.Row.DataItem, "pitched_pieces") != DBNull.Value ?
                Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "pitched_pieces")) : 0;

            ScanedPieces = DataBinder.Eval(e.Row.DataItem, "scaned_pieces") != DBNull.Value ?
                Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "scaned_pieces")) : 0;

            if (PitchedPieces > 0)
            {
                pctPieces = Convert.ToDecimal(ScanedPieces) / Convert.ToDecimal(PitchedPieces);
            }


            Label lblPctCompleted = (Label)e.Row.FindControl("lblPctCompleted");
            lblPctCompleted.Text = string.Format("{0:P2}", pctPieces);
            lblPctCompleted.ToolTip = string.Format("{0:N0} Scanned Pieces / {1:N0} Pitched Pieces = {2:P2}",
                     ScanedPieces, PitchedPieces, pctPieces);
        }
    }

    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("bp.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));
        string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("bp.operation_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhere, "shift_number"));
        }
    }  
</script>
<asp:Content ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays the information of QC boxes for the specified operation date/date range with shift or both shift 
    and particular customer." />
    <meta name="ReportId" content="110.14" />
    <meta name="Browsable" content="True" />
    <meta name="ChangeLog" content="Replaced building filter dropdown with checkbox list.|Report performance has been fine tuned." />
    <meta name="Version" content="$Id: R110_14.aspx 4899 2013-01-23 12:17:08Z rverma $" />
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
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="Customer" />
                <i:TextBoxEx ID="tbCustomer_id" runat="server" QueryString="customer_id" />
                <eclipse:LeftLabel runat="server" Text="Operation Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From operation date"
                    Text="-7" ToolTip="Please specify a date or date range here.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To operation date"
                    Text="0" ToolTip="Please specify a date or date range here. ">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
                <eclipse:LeftLabel runat="server" Text="Building" />
                 <%--<eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel5" runat="server"  Text="Check For All Building"/>
                    <i:CheckBoxEx ID="cbAllBuilding" runat="server" Checked="true" OnClientChange="cbAllBuilding_OnClientChange" FriendlyName="All Buildings">                       
                   <Validators>
                       <i:Custom OnServerValidate="cbSpecificBuilding_OnServerValidate" />
                   </Validators>
                         </i:CheckBoxEx>
                </eclipse:LeftPanel>--%>

                <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding"
                    QueryString="building">
                </i:CheckBoxListEx>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader"
        CancelSelectOnNullParameter="true" OnSelecting="ds_Selecting">
        <SelectSql>
                WITH BOX_QC_PROD_INFO AS
 (SELECT /*+ index(bp boxprod_operation_start_date_i) */
   BP.OPERATOR AS OPERATOR,
   BP.UCC128_ID AS BOX,
   NVL(BP.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
   MAX(BP.CUSTOMER_ID) AS CUSTOMER_ID,
   MAX(C.NAME) AS CUSTOMER_NAME,
   MAX(BP.PO_ID) AS PO_ID,
   MAX(BP.LABEL_ID) AS LABEL_ID,
   BP.OPERATION_START_DATE AS OPERATION_START_DATE,
   MAX(BP.LAST_PITCHED_DATE) AS LAST_PITCH_DATE,
   SUM(BP.NUM_OF_PIECES) AS PITCHED_PIECES,
   SUM(BP.NUM_OF_ABNORMAL_PIECES) AS ABNORMAL_PIECES,
   <%--SUM(BP.NUM_OF_EPC_SCANS) AS TOTAL_EPC_PIECES,--%>
   CASE
     WHEN COUNT(DISTINCT BP.LAST_PITCHED_BY) > 1 THEN
      '*****'
     ELSE
      MAX(BP.LAST_PITCHED_BY)
   END AS PITCHER,
   MAX(BP.OUTCOME) AS SCAN_RESULT,
   CASE
     WHEN MAX(BP.OUTCOME) = 'PASSED QC' THEN
      NULL
     ELSE
      MAX(Q.DESCRIPTION)
   END AS ERROR_DESCRIPTIONS,
    <![CDATA[
                    $ShiftDateSelectClause$                 
                  ]]>
    FROM BOX_PRODUCTIVITY BP
    LEFT OUTER JOIN CUST C
      ON BP.CUSTOMER_ID = C.CUSTOMER_ID
    LEFT OUTER JOIN QCO Q
      ON BP.QCO_ID = Q.QCO_ID
   WHERE BP.OPERATION_CODE = '$BOXQC'
    <if>AND BP.customer_id = cast(:customer_id as varchar2(255))</if>
  AND bp.operation_start_date &gt;= cast(:operation_start_date_from as date)
             AND bp.operation_start_date &lt; cast(:operation_start_date_to as date) + 2
   <if>AND <a pre="NVL(BP.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
             <![CDATA[
                    $ShiftNumberWhere$                 
              ]]>
   GROUP BY BP.OPERATOR, BP.UCC128_ID, NVL(BP.WAREHOUSE_LOCATION_ID,'Unknown'), BP.OPERATION_START_DATE)
SELECT Q1.OPERATOR             AS OPERATOR,
       Q1.CUSTOMER_ID          AS CUSTOMER_ID,
       Q1.CUSTOMER_NAME        AS CUSTOMER_NAME,
       Q1.BOX                  AS BOX,
       Q1.PO_ID                AS PO_ID,
       Q1.LABEL_ID             AS LABEL_ID,
       Q1.OPERATION_START_DATE AS OPERATION_START_DATE,
       Q1.shift_start_date AS shift_start_date,
       Q1.LAST_PITCH_DATE      AS LAST_PITCH_DATE,
       Q1.PITCHED_PIECES       AS PITCHED_PIECES,
       Q1.ABNORMAL_PIECES      AS ABNORMAL_PIECES,
     <%--  Q1.TOTAL_EPC_PIECES     AS TOTAL_EPC_PIECES,--%>
       Q1.PITCHER              AS PITCHER,
       Q1.SCAN_RESULT          AS SCAN_RESULT,
       (Q1.PITCHED_PIECES - Q1.ABNORMAL_PIECES) AS SCANED_PIECES,
       Q1.ERROR_DESCRIPTIONS   AS ERROR_DESCRIPTIONS,
       AU.CREATED AS USER_SETUP_DATE
  FROM BOX_QC_PROD_INFO Q1
  LEFT OUTER JOIN ALL_USERS AU
    ON Q1.OPERATOR = AU.USERNAME
 WHERE Q1.SHIFT_START_DATE &gt;= cast(:operation_start_date_from as date)
 AND Q1.SHIFT_START_DATE &lt; cast(:operation_start_date_to as date) + 1
  <if>AND <a pre="NVL(Q1.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
                   </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbCustomer_id" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="operation_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="operation_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
        <asp:ControlParameter ControlID="ctlWhLoc" Direction="Input" Name="warehouse_location_id"
                Type="String" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="customer_id;customer_name;$;box"
        EnableMasterRowNewSequence="true" OnRowDataBound="gv_RowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="customer_id" HeaderText="Customer ID" SortExpression="customer_id" />
            <eclipse:MultiBoundField DataFields="customer_name" HeaderText="Customer Name" SortExpression="customer_name" />
            <eclipse:MultiBoundField DataFields="box" HeaderText="Box" SortExpression="box" />
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO" SortExpression="PO_ID" />
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id" />
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="Date|Operation"
                SortExpression="shift_start_date" DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="last_pitch_date" HeaderText="Date|Pitching"
                SortExpression="last_pitch_date" DataFormatString="{0:d} {0:T}" />
            <eclipse:MultiBoundField DataFields="OPERATOR" HeaderText="QC Operator" SortExpression="OPERATOR" />
            <eclipse:MultiBoundField DataFields="scan_result" HeaderText="Scan Result" SortExpression="scan_result" />
            <eclipse:MultiBoundField DataFields="ERROR_DESCRIPTIONS" HeaderText="Error Descriptions"
                SortExpression="ERROR_DESCRIPTIONS" />
            <eclipse:MultiBoundField DataFields="pitched_pieces" HeaderText="Pieces| Pitched"
                SortExpression="pitched_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="scaned_pieces" HeaderText="Pieces| Scanned "
                SortExpression="scaned_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <%--<eclipse:MultiBoundField DataFields="TOTAL_EPC_PIECES" HeaderText="Pieces| EPC Scanned"
                SortExpression="TOTAL_EPC_PIECES" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>--%>
            <asp:TemplateField HeaderText="Accurate" Visible="true">
                <ItemStyle HorizontalAlign="Right" />
                <ItemTemplate>
                    <asp:Label runat="server" ID="lblPctCompleted" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="pitcher" HeaderText="Pitcher" SortExpression="pitcher" />
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date"
                SortExpression="user_setup_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

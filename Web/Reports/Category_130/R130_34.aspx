<%@ Page Title="Received SKUs with no FPK location" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6673 $
 *  $Author: hsingh $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R130_34.aspx 6673 2014-04-07 09:33:08Z hsingh $
 * Version Control Template Added.
--%>
<script type="text/C#" runat="server">
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (string.IsNullOrEmpty(e.Row.Cells[10].Text))
                {
                    e.Row.Cells[10].BackColor = System.Drawing.Color.Red;
                }
            }
             if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (string.IsNullOrEmpty(e.Row.Cells[9].Text))
                {
                    e.Row.Cells[9].BackColor = System.Drawing.Color.Red;
                }
            }
             if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (string.IsNullOrEmpty(e.Row.Cells[6].Text))
                {
                    e.Row.Cells[6].BackColor = System.Drawing.Color.Red;
                }
            }
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is for displaying those SKUs which are received in last two months and yet not assigned to any forward pick location. User can limit this report to see only those un-assigend SKUs which are having at least desired number of cartons. By default this report will show
        those SKUs first which have maximun number of un-assigned SKU quantiy." />
    <meta name="ReportId" content="130.34" />
    <meta name="ChangeLog" content="The report is now able to show weight and volume of the SKU.| The report is also showing whether the SKU is required in any order or not." />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_34.aspx 6673 2014-04-07 09:33:08Z hsingh $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:CheckBoxEx runat="server" ID="chkCtnLimit" Text="SKUs which have at least" QueryString="CtnLimitOption" CheckedValue="Y" FriendlyName="Apply Carton Limit" ToolTip="This will filter out those SKUs which are having cartons less than passed value." />
                    <i:TextBoxEx ID="tbCtnLimit" runat="server" MaxLength="7" QueryString="CtnLimit" FriendlyName="SKUs having minimum cartons" Text="100">
                        <Validators>
                            <i:Value ValueType="Integer" />
                            <i:Filter DependsOn="chkCtnLimit" DependsOnState="Checked" />
                        </Validators>
                    </i:TextBoxEx>
                    cartons. 
                </eclipse:LeftPanel>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide you the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <%--Provide the data source for quering the data for the report, the datasource should always be placed above the display 
            control since query execution time is displayed where the data source control actaully is on the page,
            while writing the select query the alias name must match with that of database column names so as to avoid 
            any confusion, for details of control refer OracleDataSource.htm with in doc folder of EclipseLibrary.Oracle--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
       WITH UNASSIGNED_SKUS AS
 (SELECT SCI.VWH_ID AS VWH_ID,
         SCI.STYLE AS STYLE,
         SCI.COLOR AS COLOR,
         SCI.DIMENSION AS DIMENSION,
         SCI.SKU_SIZE AS SKU_SIZE,
         MAX(MS.UPC_CODE) AS UPC_CODE,
         COUNT(UNIQUE SCI.CARTON_ID) AS TOTAL_CARTONS,
         SUM(SCI.QUANTITY) AS TOTAL_PIECES,
         MAX(MS.VOLUME_PER_DOZEN) AS VOLUME_PER_DOZEN,
         MAX(MS.WEIGHT_PER_DOZEN) AS WEIGHT_PER_DOZEN
    FROM SRC_CARTON_INTRANSIT SCI
    inner JOIN MASTER_SKU MS
      ON SCI.STYLE = MS.STYLE
     AND SCI.COLOR = MS.COLOR
     AND SCI.DIMENSION = MS.DIMENSION
     AND SCI.SKU_SIZE = MS.SKU_SIZE
     WHERE  NOT EXISTS (SELECT *
            FROM IALOC I
           WHERE I.ASSIGNED_UPC_CODE = MS.UPC_CODE
             AND I.LOCATION_TYPE = 'RAIL'
            AND I.VWH_ID = SCI.VWH_ID)
   AND SCI.RECEIVED_DATE > SYSDATE - 60
   GROUP BY SCI.STYLE, SCI.COLOR, SCI.DIMENSION, SCI.SKU_SIZE, SCI.VWH_ID),
IN_PROCESS_SKU AS
 (SELECT PS.VWH_ID AS VWH_ID,
         PD.UPC_CODE AS UPC_CODE
    FROM PS
   INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
       WHERE PS.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
     AND PS.PICKSLIP_CANCEL_DATE IS NULL
     AND PS.PICKSLIP_IMPORT_DATE > SYSDATE - 60
   group by PS.VWH_ID, PD.UPC_CODE
  UNION
  SELECT DP.VWH_ID AS VWH_ID,
        
         DPD.UPC_CODE AS UPC_CODE
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DP.PICKSLIP_ID = DPD.PICKSLIP_ID
      WHERE DP.PS_STATUS_ID = 1
     AND DP.PICKSLIP_IMPORT_DATE > SYSDATE - 60
   group by DP.VWH_ID, DPD.UPC_CODE)
SELECT US.VWH_ID AS VWH,
       US.STYLE AS STYLE,
       US.COLOR  AS COLOR,
       US.DIMENSION AS DIMENSION,
       US.SKU_SIZE AS SKU_SIZE,
       US.UPC_CODE AS UPC_CODE,
       US.WEIGHT_PER_DOZEN AS weight,
       US.VOLUME_PER_DOZEN AS volume,
       US.TOTAL_CARTONS AS TotalCartons,
       US.TOTAL_PIECES AS Pieces,
       CASE
         WHEN nvl(US.UPC_CODE,0) != nvl(IPS.UPC_CODE,0) AND
              nvl(US.VWH_ID,0) != nvl(IPS.VWH_ID,0) THEN
          'N'
         ELSE
          'Y'
       END AS REQUIRED_IN_ORDER
      FROM UNASSIGNED_SKUS US
  left OUTER JOIN IN_PROCESS_SKU IPS
    ON US.VWH_ID = IPS.VWH_ID
   AND US.UPC_CODE = IPS.UPC_CODE
<if c="$CtnLimitOption ='Y'">where  US.TOTAL_CARTONS &gt;= :CtnLimit</if>
 <%--order by Pieces desc nulls last,VWH--%>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbCtnLimit" Name="CtnLimit" Type="Int32"
                Direction="Input" />
            <asp:ControlParameter ControlID="chkCtnLimit" Name="CtnLimitOption" Type="String"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" ShowFooter="true"
        ShowHeader="true"
        DataSourceID="ds" AllowSorting="true" OnRowDataBound="gv_RowDataBound" DefaultSortExpression="Pieces {0:I} nulls last;VWH;">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField HeaderText="Vwh" DataFields="VWH" SortExpression="VWH" HeaderToolTip="Virtual warehouse of the SKU." />
            <eclipse:MultiBoundField HeaderText="SKU|Style" DataFields="Style" SortExpression="Style" HeaderToolTip="Style of the SKU." />
            <eclipse:MultiBoundField HeaderText="SKU|Color" DataFields="Color" SortExpression="Color" HeaderToolTip="Color of the SKU." />
            <eclipse:MultiBoundField HeaderText="SKU|Dimension" DataFields="Dimension" SortExpression="Dimension" HeaderToolTip="Dimension of the SKU." />
            <eclipse:MultiBoundField HeaderText="SKU|Size" DataFields="SKU_Size" SortExpression="SKU_Size" HeaderToolTip="Size of the SKU." />
            <eclipse:MultiBoundField HeaderText="UPC" AccessibleHeaderText="UPC" DataFields="upc_code" SortExpression="upc_code" HeaderToolTip="UPC of the SKU" />
            <eclipse:MultiBoundField HeaderText="#Cartons" DataFields="TotalCartons" ItemStyle-HorizontalAlign="Right" SortExpression="TotalCartons" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Total no. of cartons of the SKU." FooterToolTip="Total no. of cartons of the SKU." />
            <eclipse:MultiBoundField HeaderText="#Pieces" DataFields="Pieces" ItemStyle-HorizontalAlign="Right" SortExpression="Pieces {0:I} nulls last" FooterStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" FooterToolTip="Total no. of pieces of the SKU." HeaderToolTip="Total no. of pieces of SKU." />
            <eclipse:MultiBoundField HeaderText="Weight" DataFields="weight" ItemStyle-HorizontalAlign="Right" SortExpression="weight" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Weight of the SKus." DataFormatString="{0:N4}"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField HeaderText="Volume" DataFields="volume" ItemStyle-HorizontalAlign="Right" SortExpression="volume" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Volume of the SKus." DataFormatString="{0:N4}"></eclipse:MultiBoundField>
            <jquery:IconField DataField="Required_in_order" HeaderText="Required in order" DataFieldValues="Y"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="Required_in_order" HeaderToolTip="Whether the SKU is required in any order." />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

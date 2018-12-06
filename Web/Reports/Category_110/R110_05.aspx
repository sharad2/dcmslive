<%@ Page Title="Box ID QC Audit Report (#)" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1377 $
 *  $Author: dpanwar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_05.aspx $
 *  $Id: R110_05.aspx 1377 2011-10-05 07:25:05Z dpanwar $
 * Version Control Template Added.
 * drill down added but not compleate
--%>
<script runat="server">
    
   
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("t.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format(" {0} AS OPERATION_DATE ", strShiftDateSelectClause,"mm/dd/yyy"));
        string strShiftDateGroupClause = ShiftSelector.GetShiftDateClause("t.operation_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateGroupClause$", string.Format("{0}", strShiftDateGroupClause));
        string strShiftNumberWhereClause = ShiftSelector.GetShiftNumberClause("t.operation_start_date");
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
    <meta name="Description" content="For the specified audit date/date range the report displays 
	the details for each pitcher. 	 
" />
    <meta name="ReportId" content="110.05" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R110_05.aspx 1377 2011-10-05 07:25:05Z dpanwar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <a href="R110_05.aspx">R110_05.aspx</a>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Operation Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From operation date"
                    Text="-7" ToolTip="Please specify a date or date range here."
                    QueryString="min_operation_date">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To operation date"
                    Text="0" ToolTip="Please specify a date or date range here. " QueryString="max_operation_date">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar2" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
        ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" OnSelecting="ds_Selecting">
<SelectSql>

  WITH BOXQC_OPERATION AS
(SELECT MAX(T.OPERATOR) AS OPERATOR,
         T.UCC128_ID AS UCC128_ID,
         <![CDATA[
                    $ShiftDateSelectClause$                 
                  ]]>,
         SUM(T.NUM_OF_PIECES) AS PITCHED_PIECES,
         SUM(T.NUM_OF_ABNORMAL_PIECES) AS NUM_OF_ABNORMAL_PIECES,
         MAX(T.LAST_PITCHED_DATE) AS PITCH_DATE
    FROM BOX_PRODUCTIVITY T
   WHERE T.OPERATION_CODE = '$BOXQC'
     AND T.NUM_OF_PIECES &gt; 0
     AND T.OPERATION_START_DATE &gt;= CAST(:min_operation_date AS DATE)
     AND T.OPERATION_START_DATE 
         &lt; CASt(:max_operation_date AS DATE) + 1
     <![CDATA[
                    $ShiftNumberWhereClause$                 
                  ]]> 
   GROUP BY T.UCC128_ID,t.OPERATION_START_DATE
  
  ),
PITCH_OPERATION AS
(SELECT MAX(T.OPERATOR) AS PITCHER_NAME,
         T.UCC128_ID AS UCC128_ID,
         max(T.LAST_PITCHED_DATE) AS PITCH_DATE
         FROM BOX_PRODUCTIVITY T
   INNER JOIN BOXQC_OPERATION BOXQCOP
      ON BOXQCOP.UCC128_ID = T.UCC128_ID
   WHERE T.OPERATION_CODE = 'PITCH'
     And T.OPERATION_START_DATE &gt;= CAST(:min_operation_date As DATE)-:Days
   AND T.OPERATION_START_DATE  &lt;= CASt(:max_operation_date AS DATE) + 1
   GROUP BY T.UCC128_ID)
SELECT Y.PITCHER_NAME AS PITCHER_NAME,
       MAX(X.OPERATION_DATE) AS OPERATION_DATE,
       SUM(X.PITCHED_PIECES) AS PITCHED_PIECES,
       SUM(X.PITCHED_PIECES - X.NUM_OF_ABNORMAL_PIECES) AS SCANED_PIECES,
       ROUND(((1 -
             (SUM(X.PITCHED_PIECES) -
             SUM(X.PITCHED_PIECES - X.NUM_OF_ABNORMAL_PIECES)) /
             DECODE(SUM(X.PITCHED_PIECES), 0, 1, SUM(X.PITCHED_PIECES)))* 100),
             2) || '%' AS ACCURATE,/*),
             4) AS ACCURATE,*/
          MAX(y.PITCH_DATE) AS PITCH_DATE,
          MAX(:min_operation_date) AS MIN_OPERATION_DATE,
          MAX(:max_operation_date) AS MAX_OPERATION_DATE
  FROM BOXQC_OPERATION X
 inner JOIN PITCH_OPERATION Y
  ON X.UCC128_ID=Y.UCC128_ID
GROUP BY Y.PITCHER_NAME,x.OPERATION_DATE
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="min_operation_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="max_operation_date" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:Parameter Name="Days" Type="String" DefaultValue="<%$ AppSettings:PitchingDays%>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" DataSourceID="ds"
        ShowFooter="true" DefaultSortExpression="PITCHER_NAME;OPERATION_DATE" AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
              <eclipse:SiteHyperLinkField DataTextField="PITCHER_NAME" DataNavigateUrlFields="PITCHER_NAME,OPERATION_DATE,MIN_OPERATION_DATE,MAX_OPERATION_DATE"
                HeaderText="Pitcher" DataNavigateUrlFormatString="R110_118.aspx?PITCHER_NAME={0}&OPERATION_DATE={1:d}&MIN_OPERATION_DATE={2:d}&MAX_OPERATION_DATE={3:d}"
                SortExpression="PITCHER_NAME"  HeaderToolTip="Pitcher name" >
            </eclipse:SiteHyperLinkField>
            
            <eclipse:MultiBoundField DataFields="OPERATION_DATE" HeaderText="Audit Date" SortExpression="OPERATION_DATE"
                HeaderToolTip="Date of pitching" DataFormatString="{0:d}"   />
            <eclipse:MultiBoundField DataFields="PITCH_DATE" HeaderText="Pitching Date" DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="PITCHED_PIECES" HeaderText="Pieces| Pitched"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterToolTip="Sum of pitched pieces " HeaderToolTip="Pitched pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SCANED_PIECES" HeaderText="Pieces| Scanned"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterToolTip="Sum of scanned pieces" HeaderToolTip="Scanned pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ACCURATE" HeaderText="Percentage Accurate" ItemStyle-HorizontalAlign="Right"
                HeaderToolTip="Percentage of accurate" DataFormatString="{0:P2}"/>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

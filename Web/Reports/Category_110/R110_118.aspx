<%@ Page Title="Box QC Audit Report (#)" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1382 $
 *  $Author: dpanwar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_118.aspx $
 *  $Id: R110_118.aspx 1382 2011-10-05 08:42:28Z dpanwar $
 * Version Control Template Added.
 * drill down added but not compleate
--%>
<script runat="server">

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report can be helpful for showing the audited carton detail
     for that pitcher with in operation date/date range." />
    <meta name="ReportId" content="110.118" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_118.aspx 1382 2011-10-05 08:42:28Z dpanwar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Pitcher" />
                <i:TextBoxEx runat="server" ID="tbPitcher" QueryString="PITCHER_NAME" ToolTip="Pitcher">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Operation Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From operation date"
                    Text="-7" ToolTip="Please specify a date or date range here." QueryString="OPERATION_DATE">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To operation date"
                    Text="0" ToolTip="Please specify a date or date range here." QueryString="OPERATION_DATE">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
        ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>">
        <SelectSql>
        
WITH BOX1 AS
(SELECT BP.UCC128_ID AS CARTON,
         SUM(BP.NUM_OF_PIECES) AS NORMALPIECES,
         SUM(BP.NUM_OF_ABNORMAL_PIECES) AS ABNORMALPIECES,
         MAX(BP.OUTCOME) AS SCANRESULT,
         MAX(CUST.NAME) AS CUSTOMERNAME,
         MAX(QC.DESCRIPTION) AS DESCRIPTION,
         MAX(TO_CHAR(TRUNC(BP.OPERATION_START_DATE), 'MM/DD/YYYY')) AS OPERATION_DATE
    FROM BOX_PRODUCTIVITY BP
    LEFT OUTER JOIN PS PS
      ON BP.PICKSLIP_ID = PS.PICKSLIP_ID
    LEFT OUTER JOIN CUST CUST
      ON PS.CUSTOMER_ID = CUST.CUSTOMER_ID
    LEFT OUTER JOIN QCO QC
      ON BP.QCO_ID = QC.QCO_ID
   WHERE BP.OPERATION_CODE = '$BOXQC'
     AND BP.NUM_OF_PIECES &gt; 0
      AND bp.OPERATION_START_DATE &gt;= cast(:min_operation_date as DATE) 
     AND bp.OPERATION_START_DATE &lt; cast(:max_operation_date as DATE) + 1
     GROUP BY BP.UCC128_ID),

BOX2 AS
(SELECT
   BP.UCC128_ID AS BOX_ID,
   MAX(BP.OPERATOR) AS PITCHER,
   MAX(TO_CHAR(TRUNC(BP.OPERATION_START_DATE), 'MM/DD/YYYY')) AS OPERATION_DATE_PITCH
    FROM BOX_PRODUCTIVITY BP
   WHERE BP.OPERATION_CODE = 'PITCH'
     AND BP.OPERATOR =:PITCHER_NAME
       AND bp.OPERATION_START_DATE &gt;= cast(:FROM_OPERATION_DATE as DATE) -:Days
     AND bp.OPERATION_START_DATE &lt; cast(:TO_OPERATION_DATE as DATE) + 1
     GROUP BY BP.UCC128_ID)

SELECT MAX(B2.PITCHER),
       SUM(B1.NORMALPIECES) AS PITCHED_PIECES,
       SUM(B1.NORMALPIECES - B1.ABNORMALPIECES) AS SCANNED_PIECES,
       B1.CARTON,
       ROUND(((1 - (SUM(B1.NORMALPIECES) -
             SUM(B1.NORMALPIECES - B1.ABNORMALPIECES)) /
             DECODE(SUM(B1.NORMALPIECES), 0, 1, SUM(B1.NORMALPIECES)))),
             4) AS ACCURATE,
       B2.OPERATION_DATE_PITCH AS OPERATION_DATE_PITCH,
       MAX(B1.SCANRESULT) AS SCAN_RESULT,
       MAX(B1.CUSTOMERNAME) AS CUSTOMER,
       MAX(B1.DESCRIPTION) AS ERROR_DESCRIPTION
  FROM BOX1 B1
INNER JOIN BOX2 B2
    ON B1.CARTON = B2.BOX_ID
GROUP BY B1.CARTON, B2.OPERATION_DATE_PITCH

     

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPitcher" Type="String" Direction="Input" Name="PITCHER_NAME" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="min_operation_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="max_operation_date" />
            <asp:QueryStringParameter Name="FROM_OPERATION_DATE" QueryStringField="MIN_OPERATION_DATE"
                Type="DateTime" Direction="Input" />
            <asp:QueryStringParameter Name="TO_OPERATION_DATE" QueryStringField="MAX_OPERATION_DATE"
                Type="DateTime" Direction="Input" />
            <asp:Parameter Name="Days" Type="String" DefaultValue="<%$ AppSettings:PitchingDays%>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        DefaultSortExpression="carton;$;operation_date_Pitch" AllowSorting="true" ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="carton" HeaderText="Box" SortExpression="carton"
                HeaderToolTip="Box" />
            <eclipse:MultiBoundField DataFields="customer" HeaderText="Customer Name" HeaderToolTip="Customer name" />
            <eclipse:MultiBoundField DataFields="operation_date_Pitch" HeaderText="Date of Pitching"
                SortExpression="operation_date_Pitch" HeaderToolTip="Operation date" />
            <eclipse:MultiBoundField DataFields="scan_result" HeaderText="Scan Result" HeaderToolTip="Scan result" />
            <eclipse:MultiBoundField DataFields="error_description" HeaderText="Error Descriptions"
                HeaderToolTip="Error descriptions which is occur" />
            <eclipse:MultiBoundField DataFields="pitched_pieces" HeaderText="Pitched Pieces"
                HeaderToolTip="Pitched pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of pitched pieces ">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="scanned_pieces" HeaderText="Scanned Pieces"
                HeaderToolTip="Scanned pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterToolTip="Sum of scanned pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="accurate" HeaderText="Percentage Accurate" ItemStyle-HorizontalAlign="Right"
                HeaderToolTip="Percentage of accurate" DataFormatString="{0:P2}" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Receiving Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *  $Revision: 5338 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_07.aspx $
 *  $Id: R40_07.aspx 5338 2013-05-15 05:58:27Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="40.07" />
    <meta name="Description" content="Report gets the detail of process through which the carton is received in DC for the specified date/date range." />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Provided filter of receiving area.|Report performance has been fine tuned." />
    <meta name="Version" content="$Id: R40_07.aspx 5338 2013-05-15 05:58:27Z skumar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlArea').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlArea').find('input:checkbox').attr('checked', 'checked');
            }
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Receiving Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" Text="-7" runat="server" FriendlyName="Receiving From Date"
                    QueryString="recieve_date_from">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" Text="0" FriendlyName="Receiving To Date" QueryString="recieve_date_to">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Receiving Area" />
                <oracle:OracleDataSource ID="dsArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                          SELECT DISTINCT s.receiving_area_id AS AREA, NVL(T.SHORT_NAME,  s.receiving_area_id)|| ':' || NVL(T.DESCRIPTION,s.receiving_area_id) AS DESCRIPTION FROM src_carton_process s
                        LEFT OUTER JOIN TAB_INVENTORY_AREA T
                        ON S.RECEIVING_AREA_ID = T.INVENTORY_STORAGE_AREA
                        where s.receiving_area_id is not null
                            ORDER BY 1

                    </SelectSql>
                </oracle:OracleDataSource>
                <i:CheckBoxListEx ID="ctlArea" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="AREA" DataSourceID="dsArea" FriendlyName="Check For Receiving In"
                    QueryString="area_id">
                    
                </i:CheckBoxListEx>
                Primary receiving area where process is received. 
               
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
            WITH Q1 AS
 (SELECT S.INSHIPMENT_ID AS PROCESS_ID, 
         S.SEWING_PLANT_CODE, 
         S.CARTON_ID
    FROM SRC_CARTON S
   WHERE  S.insert_date &gt;= CAST(:FromDate as date) 
  AND S.insert_date &lt; CAST(:ToDate as date) + 1
     AND S.INSHIPMENT_ID IS NOT NULL
  
  UNION ALL
  
  SELECT SOP.INSHIPMENT_ID AS PROCESS_ID,
         SOP.SEWING_PLANT_CODE,
         SOP.CARTON_ID
    FROM SRC_OPEN_CARTON SOP
     WHERE SOP.receipt_date &gt;= CAST(:FromDate as date) 
  AND SOP.receipt_date &lt; CAST(:ToDate as date) + 1
     AND SOP.INSHIPMENT_ID IS NOT NULL),
Q2 AS
 (SELECT SCP.PROCESS_ID,
         SCP.OPERATOR_NAME,
         COUNT(DISTINCT SCP.PRO_NUMBER) OVER() TOTAL_SHIPMENT,
         SCP.PRO_NUMBER AS PRO_NUMBER,
         SCP.PRO_DATE,
         MIN(SCP.PROCESS_START_DATE) OVER(PARTITION BY Q1.PROCESS_ID) AS PROCESS_START_DATE,
         MAX(SCP.PROCESS_END_DATE) OVER(PARTITION BY Q1.PROCESS_ID) AS PROCESS_END_DATE,
         SCP.CARRIER_ID,
         CAR.DESCRIPTION, 
         Q1.SEWING_PLANT_CODE,
         Q1.CARTON_ID
    FROM Q1
   INNER JOIN SRC_CARTON_PROCESS SCP
      ON Q1.PROCESS_ID = SCP.PROCESS_ID
    LEFT OUTER JOIN MASTER_CARRIER CAR
      ON SCP.CARRIER_ID = CAR.CARRIER_ID
     WHERE 1=1
    <if>AND <a pre="SCP.receiving_area_id IN (" sep="," post=")">:area_id</a></if> )
SELECT Q2.PROCESS_ID,
       COUNT(Q2.CARTON_ID) AS TOTAL_CARTONS_RECEIVED,
       Q2.SEWING_PLANT_CODE,
       MAX(Q2.OPERATOR_NAME) AS OPERATOR_NAME,
       MAX(Q2.TOTAL_SHIPMENT) AS TOTAL_SHIPMENT_COUNT,
       MAX(Q2.PRO_NUMBER) AS PRO_NUMBER,
       MAX(Q2.PRO_DATE) AS PRO_DATE,
       MIN(Q2.PROCESS_START_DATE)  AS PROCESS_START_DATE,
       MAX(Q2.PROCESS_END_DATE)  AS PROCESS_END_DATE,
       MAX(Q2.CARRIER_ID) AS CARRIER_ID,
       MAX(Q2.DESCRIPTION) AS DESCRIPTION
  FROM Q2
 GROUP BY Q2.PROCESS_ID, Q2.SEWING_PLANT_CODE 

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Name="FromDate" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Name="ToDate" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="ctlArea"  Name="area_id" Type="String"  Direction="Input"  />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AllowSorting="true" AutoGenerateColumns="false"
        DefaultSortExpression="TOTAL_SHIPMENT_COUNT;$;PROCESS_ID" ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="PROCESS_ID" HeaderText="Process" SortExpression="PROCESS_ID"
                HeaderToolTip="Process ID for the receiving process"  DataNavigateUrlFormatString="R40_103.aspx?PROCESS_ID={0}&SEWING_PLANT_CODE={1}"
                DataNavigateUrlFields="process_id,SEWING_PLANT_CODE"   AppliedFiltersControlID="ctlButtonBar1$af"/>
            <eclipse:MultiBoundField DataFields="PROCESS_START_DATE" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}"
                HeaderText="Process Start Time" SortExpression="PROCESS_START_DATE" HeaderToolTip="Time when receiving process was started"
                ItemStyle-Wrap="false">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PROCESS_END_DATE" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}"
                HeaderText="Process End Time" SortExpression="PROCESS_END_DATE" HeaderToolTip="Time when receiving process was ended"
                ItemStyle-Wrap="false">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="OPERATOR_NAME" HeaderText="User" SortExpression="OPERATOR_NAME"
                HeaderToolTip="Operator name">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SEWING_PLANT_CODE" HeaderText="Sewing Plant Code"
                SortExpression="SEWING_PLANT_CODE" HeaderToolTip="Sewing plant code of the process">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PRO_NUMBER" HeaderText="Pro No." SortExpression="PRO_NUMBER"
                HeaderToolTip="Pro date on which the receiving processs was executed">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PRO_DATE" DataFormatString="{0:d}" HeaderText="Pro Date"
                SortExpression="PRO_DATE">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="CARRIER_ID,DESCRIPTION" HeaderText="Carrier" SortExpression="CARRIER_ID"
                DataFormatString="{0} : {1}" />
            <eclipse:MultiBoundField DataFields="TOTAL_CARTONS_RECEIVED" DataFormatString="{0:N0}"
                HeaderText="#Cartons" SortExpression="TOTAL_CARTONS_RECEIVED" DataFooterFormatString="{0:N0}"
                HeaderToolTip="Number of cartons received through the process" DataSummaryCalculation="ValueSummation"
                FooterToolTip="Sum of cartons received through the process">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="TOTAL_SHIPMENT_COUNT" HeaderText="Total Shipment Received"
                SortExpression="TOTAL_SHIPMENT_COUNT">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

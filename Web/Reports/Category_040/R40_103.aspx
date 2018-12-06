<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Receiving Detail for the selected Process ID" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *  $Revision: 6804 $
 *  $Author: hsingh $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_103.aspx $
 *  $Id: R40_103.aspx 6804 2014-05-14 09:58:26Z hsingh $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report get the Summary of the Shipments as well as cartons received under the given Process ID.It also displays the shipments which are partially received. Now the report will show all the original shipments which are partially received as well with the latest shipment." />
    <meta name="ReportId" content="40.103" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R40_103.aspx 6804 2014-05-14 09:58:26Z hsingh $" />
     <meta name="ChangeLog" content="Fixed bug where in a receiving process if a shipment is partially received with other shipments then this report was showing the latest received shipment only. Now in this case report will show all the original shipments which are partially received as well." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Process ID" />
                <i:TextBoxEx ID="tbProcessID" runat="server" QueryString="process_id" ToolTip="Passed the process id. It is required">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Sewing plant Code" />
                <i:TextBoxEx ID="tbsewingplant" runat="server" QueryString="SEWING_PLANT_CODE" />
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Receiving Date" />
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
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
          
WITH Q1 AS
 (SELECT CTN.Inshipment_Id AS PROCESS_ID,
         CTN.CARTON_ID AS CARTON_ID,
         CTN.SEWING_PLANT_CODE AS SEWING_PLANT_CODE,
         CTNINT.original_shipment_id AS SHIPMENT_ID,
         CTN.INSERT_DATE AS RECEIVED_DATE,
         CTNINT.SOURCE_ORDER_PREFIX AS SOURCE_ORDER_PREFIX,
         CTNINT.SOURCE_ORDER_ID AS SOURCE_ORDER_ID
    FROM SRC_CARTON CTN
    INNER JOIN SRC_CARTON_INTRANSIT CTNINT
      ON CTN.CARTON_ID = CTNINT.CARTON_ID
   WHERE CTN.inshipment_id  = CAST(:process_id as varchar2(255))
     <if>AND CTN.SEWING_PLANT_CODE = :SEWING_PLANT_CODE</if>
     AND CTN.insert_date &gt;= CAST(:FromDate as date) 
     AND CTN.insert_date &lt; CAST(:ToDate as date) + 1
  UNION
  SELECT SOC.INSHIPMENT_ID AS PROCESS_ID,
         SOC.CARTON_ID AS CARTON_ID,
         SOC.SEWING_PLANT_CODE AS SEWING_PLANT_CODE,
         CTNINT.original_shipment_id AS SHIPMENT_ID,
         SOC.receipt_date AS RECEIVED_DATE,
         CTNINT.SOURCE_ORDER_PREFIX AS SOURCE_ORDER_PREFIX,
         CTNINT.SOURCE_ORDER_ID AS SOURCE_ORDER_ID
   FROM SRC_OPEN_CARTON SOC
   INNER JOIN SRC_CARTON_INTRANSIT CTNINT
      ON SOC.CARTON_ID = CTNINT.CARTON_ID
   WHERE SOC.INSHIPMENT_ID  = CAST(:process_id as varchar2(255))
     <if>AND SOC.SEWING_PLANT_CODE = :SEWING_PLANT_CODE</if>
         AND SOC.receipt_date &gt;= CAST(:FromDate as date) 
         AND SOC.receipt_date &lt; CAST(:ToDate as date) + 1    
            )
SELECT Q1.PROCESS_ID AS PROCESS_ID,
       COUNT(DISTINCT Q1.CARTON_ID) AS CARTON_COUNT,
       MAX(Q1.SEWING_PLANT_CODE) AS SEWING_PLANT_CODE,
       Q1.SHIPMENT_ID AS SHIPMENT_ID,
       MAX(Q1.RECEIVED_DATE) AS RECEIVED_DATE,
       Q1.SOURCE_ORDER_PREFIX AS SOURCE_ORDER_PREFIX,
       Q1.SOURCE_ORDER_ID AS SOURCE_ORDER_ID
  FROM Q1
 GROUP BY Q1.PROCESS_ID,
          Q1.SOURCE_ORDER_PREFIX,
          Q1.SOURCE_ORDER_ID,Q1.SHIPMENT_ID
 HAVING COUNT(DISTINCT Q1.CARTON_ID) > 0
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbProcessID" Direction="Input" Type="String" Name="process_id" />
            <asp:ControlParameter ControlID="tbsewingplant" Direction="Input" Type="String" Name="SEWING_PLANT_CODE" />
            <asp:ControlParameter ControlID="dtFrom" Name="FromDate" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Name="ToDate" Type="DateTime" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DefaultSortExpression="sewing_plant_code;shipment_id;source_order_prefix;source_order_id"
        DataSourceID="ds" AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true"
        Caption="Summary of the Shipments, which are received under this Process ID:"
        CaptionAlign="Left">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="sewing_plant_code" HeaderText="Sewing Plant Code"
                SortExpression="sewing_plant_code" HeaderToolTip="Sewing plant code for the process">
                <ItemStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="shipment_id" HeaderText="Shipment" SortExpression="shipment_id"
                HeaderToolTip="Shipment id, for which shipments are received in a process">
                <ItemStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="source_order_prefix" HeaderText="Source Order Prefix"
                SortExpression="source_order_prefix">
                <ItemStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="source_order_id" HeaderText="Source Order Number"
                SortExpression="source_order_id" HeaderToolTip="Sorce order line number">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="received_date" HeaderText="Received Date" SortExpression="received_date"
                DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Right" HeaderToolTip="Date on which shipments are received">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="CARTON_COUNT" HeaderText="No of Cartons" SortExpression="CARTON_COUNT"
                HeaderToolTip="Number of cartons received for the process" FooterToolTip="Total number of cartons received for the process"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
    <br />
    <br />
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
 SELECT SCI.original_shipment_id AS SHIPMENT_ID,
        COUNT(SCI.CARTON_ID) AS unreceived_cartons_count
 FROM SRC_CARTON_INTRANSIT SCI
 WHERE SCI.SHIPMENT_ID IN
       (SELECT s.SHIPMENT_ID
 FROM SRC_CARTON S
 WHERE S.INSHIPMENT_ID = :process_id
  <if>AND S.SEWING_PLANT_CODE = :SEWING_PLANT_CODE</if>
    AND  S.insert_date &gt;= CAST(:FromDate as date) 
  AND S.insert_date &lt; CAST(:ToDate as date) + 1         
            )
 AND SCI.RECEIVED_DATE IS NULL
 GROUP BY SCI.original_shipment_id

 UNION

 SELECT SCI.original_shipment_id AS SHIPMENT_ID,
        COUNT(SCI.CARTON_ID) AS unreceived_cartons_count
 FROM SRC_CARTON_INTRANSIT SCI
 WHERE SCI.SHIPMENT_ID IN
       (SELECT SOC.SHIPMENT_ID
 FROM SRC_OPEN_CARTON SOC
 WHERE SOC.INSHIPMENT_ID = :process_id
<if>AND SOC.SEWING_PLANT_CODE = :SEWING_PLANT_CODE</if>
    AND SOC.receipt_date &gt;= CAST(:FromDate as date) 
    AND SOC.receipt_date &lt; CAST(:ToDate as date) + 1           
            )
 AND SCI.RECEIVED_DATE IS NULL
 GROUP BY SCI.original_shipment_id
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbProcessID" Direction="Input" Type="String" Name="process_id" />
            <asp:ControlParameter ControlID="tbsewingplant" Direction="Input" Type="String" Name="SEWING_PLANT_CODE" />
            <asp:ControlParameter ControlID="dtFrom" Name="FromDate" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Name="ToDate" Type="DateTime" Direction="Input" />

        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv1" runat="server" DefaultSortExpression="shipment_id" DataSourceID="ds1"
        AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true" Caption="Following Shipment are partially received:"
        CaptionAlign="Left">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField HeaderText="Shipment" DataField="shipment_id" SortExpression="shipment_id"
                ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="unreceived_cartons_count" HeaderText="No of Unreceived Cartons"
                SortExpression="unreceived_cartons_count" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" HeaderToolTip="Number of cartons unreceived for the process"
                FooterToolTip="Total number of cartons unreceived for the process">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
    <br />
    <br />
    <oracle:OracleDataSource ID="ds2" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
 WITH RECIEVED_CARTONS AS
(SELECT CTN.SEWING_PLANT_CODE AS SEWING_PLANT_CODE,
        CTN.INSERT_DATE       AS RECEIVED_DATE,
        CTN.CARTON_ID         AS CARTON_ID
 FROM SRC_CARTON CTN
 WHERE CTN.INSHIPMENT_ID = :process_id
 <if>AND CTN.SEWING_PLANT_CODE = :SEWING_PLANT_CODE</if>
     AND CTN.insert_date &gt;= CAST(:FromDate as date) 
     AND CTN.insert_date &lt; CAST(:ToDate as date) + 1
         UNION

 SELECT SOC.SEWING_PLANT_CODE AS SEWING_PLANT_CODE,
        SOC.INSERT_DATE       AS RECEIVED_DATE,
        SOC.CARTON_ID         AS CARTON_ID
 FROM SRC_OPEN_CARTON SOC
 WHERE SOC.INSHIPMENT_ID = :process_id
 <if>AND SOC.SEWING_PLANT_CODE = :SEWING_PLANT_CODE</if>
     AND SOC.receipt_date &gt;= CAST(:FromDate as date) 
     AND SOC.receipt_date &lt; CAST(:ToDate as date) + 1
             )
SELECT Q1.SEWING_PLANT_CODE,
       Q1.RECEIVED_DATE,
       Q1.CARTON_ID,
       SCI.ORIGINAL_SHIPMENT_ID as shipment_id
  FROM RECIEVED_CARTONS Q1
 INNER JOIN SRC_CARTON_INTRANSIT SCI
    ON Q1.CARTON_ID = SCI.CARTON_ID
   
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbProcessID" Direction="Input" Type="String" Name="process_id" />
            <asp:ControlParameter ControlID="tbsewingplant" Direction="Input" Type="String" Name="SEWING_PLANT_CODE" />
            <asp:ControlParameter ControlID="dtFrom" Name="FromDate" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Name="ToDate" Type="DateTime" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv2" runat="server" DefaultSortExpression="shipment_id;$;carton_id" DataSourceID="ds2"
        AutoGenerateColumns="false" AllowSorting="true" Caption="Following Cartons are received under this Process ID:"
        CaptionAlign="Left" ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField HeaderText="Sewing Plant Code" DataField="sewing_plant_code" SortExpression="sewing_plant_code"
                ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Shipment" DataField="shipment_id" SortExpression="shipment_id"
                ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Carton" DataField="carton_id" SortExpression="carton_id"
                ItemStyle-HorizontalAlign="Left" />
            <asp:BoundField HeaderText="Received Date" DataField="received_date" DataFormatString="{0:d}" ItemStyle-HorizontalAlign="Right"
                SortExpression="received_date" ItemStyle-CssClass="DateColumn" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

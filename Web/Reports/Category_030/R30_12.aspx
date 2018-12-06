<%@ Page Title="Short Shipped SKUs" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6994 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R30_12.aspx 6994 2014-06-27 10:58:17Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Each customer/PO/Vwh, lists those SKUs which were short shipped during the provided date or date range. Report is also showing current inventory of each short shipped SKU in all the areas." />
    <meta name="ReportId" content="30.12" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R30_12.aspx 6994 2014-06-27 10:58:17Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                 <eclipse:LeftLabel runat="server" Text="Transfer Date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Transfer Start Date" ToolTip="Display list of SKUs for the desire transfer date range"
                    Text="-7" QueryString="transfer_start_date">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Transfer End Date"
                    Text="0" QueryString="transfer_end_date">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                       
                    </Validators>
                </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  DataSourceMode="DataSet"
        CancelSelectOnNullParameter="true" >
        <SelectSql>             
            WITH ORDERED_QUANTITY AS
 (SELECT PS.VWH_ID,
         PS.PO_ID,
         MS.SKU_ID,
         PS.CUSTOMER_ID,
         MAX(C.NAME) AS CUSTOMER_NAME,
         MAX(MS.UPC_CODE) AS UPC_CODE,
         MAX(MS.STYLE) AS STYLE,
         MAX(MS.COLOR) AS COLOR,
         MAX(MS.DIMENSION) AS DIMENSION,
         MAX(MS.SKU_SIZE) AS SKU_SIZE,
         SUM(PD.PIECES_ORDERED) AS PIECES_ORDERED
    FROM PS
   INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
   INNER JOIN MASTER_SKU MS
      ON PD.UPC_CODE = MS.UPC_CODE
    LEFT OUTER JOIN CUST C
      ON C.CUSTOMER_ID = PS.CUSTOMER_ID
   WHERE PS.PICKSLIP_CANCEL_DATE IS NULL
     <if>AND PS.TRANSFER_DATE &gt;= CAST(:transfer_start_date AS DATE)</if>      
     <if>AND PS.TRANSFER_DATE &lt; CAST(:transfer_end_date AS DATE) +1</if>
         AND pd.transfer_date IS NOT NULL
   GROUP BY PS.CUSTOMER_ID, PS.VWH_ID, PS.PO_ID, MS.SKU_ID),
SHIPPED_QUANITY AS
 (SELECT PS.VWH_ID,
         PS.PO_ID,
         BD.SKU_ID,
         PS.CUSTOMER_ID,
         SUM(BD.CURRENT_PIECES) AS PIECES_SHIPPED
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   INNER JOIN PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
   WHERE B.STOP_PROCESS_REASON = '$XREF'
     <if>AND B.STOP_PROCESS_DATE &gt;= CAST(:transfer_start_date AS DATE)</if>
     <if>AND B.STOP_PROCESS_DATE &lt; CAST(:transfer_end_date AS DATE) +1</if>
     AND PS.TRANSFER_DATE IS NOT NULL
     AND BD.STOP_PROCESS_DATE IS NOT NULL
   GROUP BY PS.CUSTOMER_ID, PS.VWH_ID, PS.PO_ID, BD.SKU_ID),
INVENTORY_AREAS AS
 (SELECT TIA.SHORT_NAME AS AREA,
         CTN.VWH_ID AS VWH_ID,
         SUM(NVL(CTNDET.QUANTITY, 0)) AS QUANTITY,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS WAREHOUSE_LOCATION_ID,
         CTNDET.SKU_ID
    FROM SRC_CARTON CTN
   INNER JOIN SRC_CARTON_DETAIL CTNDET
      ON CTN.CARTON_ID = CTNDET.CARTON_ID
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON CTN.LOCATION_ID = MSL.LOCATION_ID
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   WHERE TIA.STORES_WHAT = 'CTN'
     AND CTNDET.SKU_ID IN (SELECT OQ.SKU_ID FROM ORDERED_QUANTITY OQ)
   GROUP BY CTNDET.SKU_ID,
            TIA.SHORT_NAME,
            CTN.VWH_ID,
            COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                     MSL.WAREHOUSE_LOCATION_ID,
                     'Unknown')
  
  UNION
  
  SELECT TIA.SHORT_NAME AS AREA,
         MRI.VWH_ID AS VWH_ID,
         SUM(NVL(MRI.QUANTITY, 0)) AS QUANTITY,
         NVL(TIA.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
         MRI.SKU_ID
    FROM MASTER_RAW_INVENTORY MRI
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON MRI.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   WHERE TIA.STORES_WHAT = 'SKU'
     AND TIA.UNUSABLE_INVENTORY IS NULL
   GROUP BY MRI.SKU_ID,
            TIA.SHORT_NAME,
            MRI.VWH_ID,
            NVL(TIA.WAREHOUSE_LOCATION_ID, 'Unknown')
  
  UNION
  SELECT IA.SHORT_NAME AS SHORT_NAME,
         I.VWH_ID AS VWH_ID,
         SUM(NVL(IAC.NUMBER_OF_UNITS, 0)) AS NUMBER_OF_UNITS,
         NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
         BS.SKU_ID
    FROM IALOC_CONTENT IAC
   INNER JOIN IALOC I
      ON I.LOCATION_ID = IAC.LOCATION_ID
   INNER JOIN IA IA
      ON I.IA_ID = IA.IA_ID
   INNER JOIN MASTER_SKU BS
      ON BS.UPC_CODE = IAC.IACONTENT_ID
   WHERE I.LOCATION_TYPE = 'RAIL'
     AND I.CAN_ASSIGN_SKU = 1
     AND IAC.IACONTENT_TYPE_ID = 'SKU'
   GROUP BY BS.SKU_ID,
            IA.SHORT_NAME,
            I.VWH_ID,
            NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown'))
SELECT BS.CUSTOMER_ID,
       BS.CUSTOMER_NAME,
       BS.VWH_ID AS VWH_ID,
       BS.PO_ID,
       BS.STYLE AS STYLE,
       BS.COLOR AS COLOR,
       BS.DIMENSION AS DIMENSION,
       BS.SKU_SIZE AS SKU_SIZE,
       BS.UPC_CODE AS UPC_CODE,
       BS.PIECES_ORDERED,
       OS.PIECES_SHIPPED,
       (NVL(BS.PIECES_ORDERED, 0) - NVL(OS.PIECES_SHIPPED, 0)) AS DIFFERENCE,
       NVL(IDS.AREA,'NA') AS AREA,
       IDS.QUANTITY  AS QUANTITY,
       IDS.WAREHOUSE_LOCATION_ID
  FROM ORDERED_QUANTITY BS
  LEFT OUTER JOIN SHIPPED_QUANITY OS
    ON OS.SKU_ID = BS.SKU_ID
   AND OS.VWH_ID = BS.VWH_ID
   AND OS.PO_ID = BS.PO_ID
   AND OS.CUSTOMER_ID = BS.CUSTOMER_ID
  LEFT OUTER JOIN INVENTORY_AREAS IDS
    ON BS.SKU_ID = IDS.SKU_ID
   AND BS.VWH_ID = IDS.VWH_ID
   AND ids.quantity &lt;&gt; 0
 WHERE (NVL(BS.PIECES_ORDERED, 0) &gt; NVL(OS.PIECES_SHIPPED, 0))

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input"
                Name="transfer_start_date" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input"
                Name="transfer_end_date" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="false"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="CUSTOMER_ID;$;PO_ID;upc_code">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="CUSTOMER_ID,CUSTOMER_NAME" HeaderText="Customer" ItemStyle-Font-Bold="true" SortExpression="CUSTOMER_ID" DataFormatString="{0} : {1}" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWH" SortExpression="VWH_ID" HeaderToolTip="Virtual Warehouse of the SKU" />
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO" SortExpression="PO_ID" HeaderToolTip="Order ID of the Customer" />
            <eclipse:MultiBoundField DataFields="UPC_CODE" HeaderText="UPC" SortExpression="UPC_CODE" ItemStyle-HorizontalAlign="Left" HeaderToolTip="UPC Code of the SKU" />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" ItemStyle-HorizontalAlign="Left" SortExpression="STYLE" HeaderToolTip="Style of the SKU" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" HeaderToolTip="Color of the SKU"/>
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim" SortExpression="DIMENSION"  HeaderToolTip="Dimension of the SKU"/>
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE" HeaderToolTip="Size of the SKU" />
            <eclipse:MultiBoundField DataFields="PIECES_ORDERED" HeaderText="Pieces|Ordered" SortExpression="PIECES_ORDERED" DataSummaryCalculation="ValueSummation" HeaderToolTip="How many pieces ordered for this SKU"
             DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PIECES_SHIPPED" HeaderText="Pieces|Shipped" SortExpression="PIECES_SHIPPED" HeaderToolTip="How many pieces shipped for this SKU"
              DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"/>
            <eclipse:MultiBoundField DataFields="DIFFERENCE" HeaderText="Pieces|Shortage" SortExpression="DIFFERENCE" HeaderToolTip="Displaying shortage here, to calculate shortage using formula (ordered pieces – shipped pieces)"
             DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />           
            
             <m:MatrixField DataHeaderFields="WAREHOUSE_LOCATION_ID,AREA" DataMergeFields="customer_id,vwh_id,po_id,upc_code"
                DataCellFields="QUANTITY" HeaderText="{0}<br>{1}" GroupByColumnHeaderText="true" > 
                <MatrixColumns>
                    <m:MatrixColumn DataHeaderFormatString="Inventory Availabel In" DisplayColumnTotal="true"    VisibleExpression ="$AREA !='NA'" DataCellFormatString="{0:#,###}" ColumnTotalFormatString="{0:#,###}"  ColumnType="CellValue">
                        <FooterStyle  Font-Size ="0" />
                    </m:MatrixColumn> 
                </MatrixColumns>
            </m:MatrixField>
</Columns>
    </jquery:GridViewEx>
</asp:Content>

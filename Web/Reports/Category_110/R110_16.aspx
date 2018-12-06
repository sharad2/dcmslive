<%@ Page Title="Unshipped boxes by DC/PO/Bucket" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7236 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_16.aspx $
 *  $Id: R110_16.aspx 7236 2014-11-07 09:27:07Z skumar $
 * Version Control Template Added.
 
--%>
<%--Multiview pattern--%>

<script runat="server">

    protected override void OnLoad(EventArgs e)
    {
        if (rblListBy.Value == "B")
        {
            mv.ActiveViewIndex = 1;
            buttonBar2.GridViewId = gvByBucket.ID;
        }
        else
        {
            mv.ActiveViewIndex = 0;
            buttonBar2.GridViewId = gvByPo.ID;
        }

        base.OnLoad(e);
    }
    //protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    //{

    //    if (!string.IsNullOrEmpty(ctlWhLoc.Value))
    //    {
    //        cbAllBuilding.Checked = false;
    //    }
    //}
    //protected void ctlWhLoc_OnPreRender(object sender, EventArgs e)
    //{
    //    if (ctlWhLoc.Items.Any(p => p.Selected))
    //    {
    //        cbAllBuilding.Checked = false;
    //    }
    //}

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report lists all PO with no. of boxes for a particular Customer and start date or date range." />
    <meta name="ReportId" content="110.16" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R110_16.aspx 7236 2014-11-07 09:27:07Z skumar $" />
   <meta name="ChangeLog" content="Now report will show STO against a PO. This additional information will be displayed under a new column 'PO Attrib 1'." />
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
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server" WidthRight="40em">
                <eclipse:LeftLabel ID="lblCustomer" runat="server" Text="Customer" />
                <%--<eclipse:EnhancedTextBox ID="tbCustomer" runat="server" Required="true" QueryString="Customer"
                    ToolTip="Please enter the customer id." />--%>
                <i:TextBoxEx ID="tbCustomer" runat="server" QueryString="customer" ToolTip="Please enter the customer id.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="lblBuilding" runat="server" Text="Building" />

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

                <eclipse:LeftLabel ID="lblDateRange" runat="server" Text="Start Date" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From PO Start Date"
                    Text="-7" ToolTip="Please select the From PO start date." QueryString="FromDate">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server"
                    FriendlyName="To PO Start Date" Text="0" ToolTip="Please select the To PO start date."
                    QueryString="ToDate">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="List by Customer DC and" />
                <i:RadioButtonListEx runat="server" ID="rblListBy" ToolTip="Please select the view"
                    Value="P">
                    <Items>
                        <i:RadioItem Text="PO" Value="P" />
                        <i:RadioItem Text="Bucket (Recommended for PO Consolidation customers)" Value="B" />
                    </Items>
                </i:RadioButtonListEx>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Button-bar for the validation summary and Applied Filter--%>
    <uc2:ButtonBar2 ID="buttonBar2" runat="server" />
    <asp:MultiView runat="server" ID="mv" ActiveViewIndex="-1">
        <asp:View runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
                ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>">
                <SelectSql>
         <%-- WITH ACTIVE_PS AS
 (SELECT PS.PICKSLIP_ID            AS PICKSLIP_ID,
         PS.CUSTOMER_ID            AS CUSTOMER_ID,
         PS.PO_ID                  AS PO_ID,
         PS.TOTAL_DOLLARS_ORDERED  AS TOTAL_DOLLARS_ORDERED,
         PS.BUCKET_ID              AS BUCKET_ID,
         PS.LABEL_ID               AS LABEL_ID,
         PS.CUSTOMER_DC_ID         AS CUSTOMER_DC_ID,
         PS.TOTAL_QUANTITY_ORDERED AS TOTAL_QUANTITY_ORDERED,
         PS.PICKSLIP_IMPORT_DATE   AS PICK_SLIP_IMPORT_DATE,
         PO.START_DATE             AS START_DATE,
         PO.DC_CANCEL_DATE         AS DC_CANCEL_DATE,
				 PS.WAREHOUSE_LOCATION_ID  AS BUILDING
    FROM PS
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
   WHERE PS.TRANSFER_DATE IS NULL
     AND PS.CUSTOMER_ID = :Customer_id
	<if>AND PS.WAREHOUSE_LOCATION_ID = :Building_id</if>
     ---<if>AND <a pre="ps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Building_id</a></if>
      AND po.start_date &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND po.start_date &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1
  UNION ALL
  SELECT DPS.PICKSLIP_ID             AS PICKSLIP_ID,
         DPS.CUSTOMER_ID             AS CUSTOMER_ID,
         DPS.CUSTOMER_ORDER_ID       AS PO_ID,
         DPS.TOTAL_DOLLARS_ORDERED   AS TOTAL_DOLLARS_ORDERED,
         NULL                        AS BUCKET_ID,
         DPS.PICKSLIP_TYPE           AS LABEL_ID,
         DPS.CUSTOMER_DIST_CENTER_ID AS CUSTOMER_DC_ID,
         DPS.TOTAL_QUANTITY_ORDERED  AS TOTAL_QUANTITY_ORDERED,
         DPS.PICKSLIP_IMPORT_DATE    AS PICK_SLIP_IMPORT_DATE,
         DPS.DELIVERY_DATE           AS START_DATE,
         DPS.DC_CANCEL_DATE          AS DC_CANCEL_DATE,
				 DPS.WAREHOUSE_LOCATION_ID  AS BUILDING
    FROM DEM_PICKSLIP DPS
   WHERE DPS.PS_STATUS_ID = 1
     AND DPS.CUSTOMER_ID = :Customer_id
		<if> AND DPS.WAREHOUSE_LOCATION_ID = :Building_id</if>
    ---<if>AND <a pre="dps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Building_id</a></if>
     AND DPS.DELIVERY_DATE &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND DPS.DELIVERY_DATE &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1),
ORDER_INFO AS
 (SELECT RP.PICKSLIP_ID AS PICKSLIP,
         MAX(RP.BUCKET_ID) AS BUCKET,
         MAX(RP.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         MAX(RP.LABEL_ID) AS LABEL_ID,
         MAX(RP.PO_ID) AS PO,
         MAX(RP.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         MAX(RP.START_DATE) AS START_DATE,
         MAX(RP.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(RP.PICK_SLIP_IMPORT_DATE) AS IMPORT_DATE,
         MAX(RP.TOTAL_QUANTITY_ORDERED) AS PIECES,
         SUM(PD.PIECES_ORDERED * (MSKU.WEIGHT_PER_DOZEN / 12)) AS WEIGHT,
				 RP.BUILDING AS BUILDING
    FROM ACTIVE_PS RP
    LEFT OUTER JOIN PSDET PD
      ON RP.PICKSLIP_ID = PD.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON MSKU.UPC_CODE = PD.UPC_CODE
   GROUP BY RP.PICKSLIP_ID,RP.BUILDING),

ORDER_WITH_BOX AS
 (SELECT OI.PICKSLIP AS PICKSLIP_ID,
         MAX(OI.BUCKET) AS BUCKET,
         MAX(OI.PO) AS PO,
         MAX(OI.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         MAX(OI.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         MAX(OI.LABEL_ID) AS LABEL_ID,
         MAX(OI.START_DATE) AS START_DATE,
         MAX(OI.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(PIECES) AS PIECES,
         MAX(OI.IMPORT_DATE) AS IMPORT_DATE,
         COUNT(DISTINCT BOX.UCC128_ID) AS NO_OF_BOXES,
         MAX(WEIGHT) + NVL(SUM(SC.EMPTY_WT), 0) BOX_WEIGHT,
         SUM(SC.OUTER_CUBE_VOLUME) BOX_VOLUME,
				 OI.BUILDING AS BUILDING
    FROM ORDER_INFO OI
    LEFT OUTER JOIN BOX
      ON OI.PICKSLIP = BOX.PICKSLIP_ID
    LEFT OUTER JOIN SKUCASE SC
      ON BOX.CASE_ID = SC.CASE_ID
   WHERE BOX.STOP_PROCESS_DATE IS NULL
   GROUP BY OI.PICKSLIP,OI.BUILDING),
ORDER_SHIPPED AS
 (SELECT PS.PICKSLIP_ID AS PICKSLIP_ID,
         SUM(NVL(BD.CURRENT_PIECES, 0)) AS SHIPPED_PIECES,
         SUM(NVL(BD.CURRENT_PIECES, 0) * NVL(BD.EXTENDED_PRICE, 0)) AS DOLLARS_SHIPPED,
				 PS.WAREHOUSE_LOCATION_ID AS BUILDING
    FROM PS PS
   INNER JOIN PO PO
      ON PS.PO_ID = PO.PO_ID
     AND PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
    LEFT OUTER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND PS.PICKSLIP_ID = BD.PICKSLIP_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND PS.CUSTOMER_ID = :Customer_id
		---<if> AND PS.WAREHOUSE_LOCATION_ID = :Building_id</if>
     --<if>AND <a pre="ps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     AND po.start_date &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND po.start_date &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1
   GROUP BY PS.PICKSLIP_ID,PS.WAREHOUSE_LOCATION_ID)
SELECT OWB.CUSTOMER_DC_ID AS CUSTOMER_DC_ID,
       OWB.BUCKET AS BUCKET_ID,
       OWB.PO AS PO_ID,
       OWB.LABEL_ID AS LABEL_ID,
       COUNT(OWB.PICKSLIP_ID) AS NO_OF_PICKSLIP,
       SUM(OWB.NO_OF_BOXES) AS NO_OF_BOXES,
       SUM(PIECES) AS ORDERED_PIECES,
       ROUND(SUM(OWB.BOX_WEIGHT), 4) AS WEIGHT,
       ROUND(SUM(OWB.BOX_VOLUME), 4) AS MAX_VOLUME,
       TRUNC(OWB.IMPORT_DATE) AS IMPORT_DATE,
       ROUND(SUM(OWB.TOTAL_DOLLARS_ORDERED), 4) AS TOTAL_DOLLARS_ORDERED,
       SUM(O.SHIPPED_PIECES) AS SHIPPED_PIECES,
       SUM(O.DOLLARS_SHIPPED) AS DOLLARS_SHIPPED,
       MAX(OWB.START_DATE) AS START_DATE,
       MAX(OWB.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
			 OWB.BUILDING AS BUILDING
  FROM ORDER_WITH_BOX OWB
  LEFT OUTER JOIN ORDER_SHIPPED O
    ON OWB.PICKSLIP_ID = O.PICKSLIP_ID
 GROUP BY OWB.BUCKET,
          OWB.PO,
          OWB.CUSTOMER_DC_ID,
          OWB.LABEL_ID,
          TRUNC(OWB.IMPORT_DATE),
					OWB.BUILDING--%>
    WITH ACTIVE_PS AS
 (SELECT PS.PICKSLIP_ID           AS PICKSLIP_ID,
         PS.CUSTOMER_ID           AS CUSTOMER_ID,
         PS.PO_ID                 AS PO_ID,
         PS.LABEL_ID              AS LABEL_ID,
         PD.PIECES_ORDERED        AS PIECES_ORDERED,
         PS.BUCKET_ID             AS BUCKET_ID,
         PD.UPC_CODE              AS UPC_CODE,
         PS.CUSTOMER_DC_ID        AS CUSTOMER_DC_ID,
         PD.EXTENDED_PRICE        AS EXTENDED_PRICE,
         PS.PICKSLIP_IMPORT_DATE  AS PICK_SLIP_IMPORT_DATE,
         PO.START_DATE            AS START_DATE,
         PO.DC_CANCEL_DATE        AS DC_CANCEL_DATE,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS BUILDING,
         PS.SALES_ORDER_ID AS SALES_ORDER_ID
    FROM PS
   INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
   WHERE PS.TRANSFER_DATE IS NULL
     AND ps.pickslip_cancel_date IS NULL
     AND PS.CUSTOMER_ID = :Customer_id
 <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:Building_id</a></if>
     AND po.start_date &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND po.start_date &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1
  
  UNION ALL
  
  SELECT DPS.PICKSLIP_ID             AS PICKSLIP_ID,
         DPS.CUSTOMER_ID             AS CUSTOMER_ID,
         DPS.CUSTOMER_ORDER_ID       AS PO_ID,
         DPS.PICKSLIP_TYPE           AS LABEL_ID,
         DPD.QUANTITY_ORDERED        AS PIECES_ORDERED,
         NULL                        AS BUCKET_ID,
         DPD.UPC_CODE                AS UPC_CODE,
         DPS.CUSTOMER_DIST_CENTER_ID AS CUSTOMER_DC_ID,
         DPD.EXTENDED_PRICE          AS EXTENDED_PRICE,
         DPS.PICKSLIP_IMPORT_DATE    AS PICK_SLIP_IMPORT_DATE,
         DPS.DELIVERY_DATE           AS START_DATE,
         DPS.DC_CANCEL_DATE          AS DC_CANCEL_DATE,
         NVL(DPS.WAREHOUSE_LOCATION_ID,'Unknown')   AS BUILDING,
         DPS.SALES_ORDER_ID AS SALES_ORDER_ID
    FROM DEM_PICKSLIP DPS
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPS.PICKSLIP_ID = DPD.PICKSLIP_ID
   WHERE DPS.PS_STATUS_ID = 1
     AND DPS.CUSTOMER_ID = :Customer_id
 <if>AND <a pre="NVL(dps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:Building_id</a></if>
     AND DPS.DELIVERY_DATE &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND DPS.DELIVERY_DATE &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1),
ORDER_INFO AS
 (SELECT RP.PICKSLIP_ID AS PICKSLIP,
         MAX(RP.BUCKET_ID) AS BUCKET,
         MAX(RP.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         RP.LABEL_ID AS LABEL_ID,
         MAX(RP.PO_ID) AS PO,
         SUM(RP.PIECES_ORDERED) AS PIECES,
         MAX(RP.START_DATE) AS START_DATE,
         MAX(RP.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(RP.PICK_SLIP_IMPORT_DATE) AS IMPORT_DATE,
         SUM(RP.PIECES_ORDERED * RP.EXTENDED_PRICE) AS TOTAL_DOLLARS_ORDERED,
         SUM(RP.PIECES_ORDERED * (MSKU.WEIGHT_PER_DOZEN / 12)) AS WEIGHT,
         MAX(RP.BUILDING) AS BUILDING,
         MAX(RP.SALES_ORDER_ID) AS SALES_ORDER_ID
    FROM ACTIVE_PS RP
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON MSKU.UPC_CODE = RP.UPC_CODE
   GROUP BY RP.PICKSLIP_ID, RP.LABEL_ID),
ORDER_WITH_BOX AS
 (SELECT OI.PICKSLIP AS PICKSLIP_ID,
         MAX(OI.BUCKET) AS BUCKET,
         MAX(OI.PO) AS PO,
         MAX(OI.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         MAX(OI.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         OI.LABEL_ID AS LABEL_ID,
         MAX(OI.START_DATE) AS START_DATE,
         MAX(OI.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(PIECES) AS PIECES,
         MAX(OI.IMPORT_DATE) AS IMPORT_DATE,
         COUNT(DISTINCT B.UCC128_ID) AS NO_OF_BOXES,
         MAX(WEIGHT) + NVL(SUM(SC.EMPTY_WT), 0) BOX_WEIGHT,
         SUM(SC.OUTER_CUBE_VOLUME) BOX_VOLUME,
         MAX(OI.BUILDING) AS BUILDING,
         MAX(OI.SALES_ORDER_ID) AS SALES_ORDER_ID
    FROM ORDER_INFO OI
    LEFT OUTER JOIN BOX B
      ON OI.PICKSLIP = B.PICKSLIP_ID
    LEFT OUTER JOIN SKUCASE SC
      ON B.CASE_ID = SC.CASE_ID
   WHERE B.STOP_PROCESS_DATE IS NULL
   GROUP BY OI.PICKSLIP, OI.LABEL_ID),
ORDER_SHIPPED AS
 (SELECT PS.PICKSLIP_ID AS PICKSLIP_ID,
         SUM(NVL(BD.CURRENT_PIECES, 0)) AS SHIPPED_PIECES,
         SUM(NVL(BD.CURRENT_PIECES, 0) * NVL(BD.EXTENDED_PRICE, 0)) AS DOLLARS_SHIPPED,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS BUILDING
    FROM PS PS
   INNER JOIN PO PO
      ON PS.PO_ID = PO.PO_ID
     AND PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
    LEFT OUTER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND PS.PICKSLIP_ID = BD.PICKSLIP_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     AND ps.pickslip_cancel_date IS NULL
     AND PS.CUSTOMER_ID = :Customer_id
 <if>AND <a pre="ps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Building_id</a></if>
     AND po.start_date &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND po.start_date &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1
   GROUP BY PS.PICKSLIP_ID, PS.WAREHOUSE_LOCATION_ID)
SELECT OWB.CUSTOMER_DC_ID AS CUSTOMER_DC_ID,
       OWB.BUCKET AS BUCKET_ID,
       OWB.PO AS PO_ID,
       OWB.LABEL_ID AS LABEL_ID,
       COUNT(OWB.PICKSLIP_ID) AS NO_OF_PICKSLIP,
       SUM(OWB.NO_OF_BOXES) AS NO_OF_BOXES,
       SUM(PIECES) AS ORDERED_PIECES,
       ROUND(SUM(OWB.BOX_WEIGHT), 4) AS WEIGHT,
       ROUND(SUM(OWB.BOX_VOLUME), 4) AS MAX_VOLUME,
       TRUNC(OWB.IMPORT_DATE) AS IMPORT_DATE,
       ROUND(SUM(OWB.TOTAL_DOLLARS_ORDERED), 4) AS TOTAL_DOLLARS_ORDERED,
       SUM(OS.SHIPPED_PIECES) AS SHIPPED_PIECES,
       SUM(OS.DOLLARS_SHIPPED) AS DOLLARS_SHIPPED,
       MAX(OWB.START_DATE) AS START_DATE,
       MAX(OWB.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       OWB.BUILDING AS BUILDING,
       CASE WHEN COUNT(UNIQUE OWB.SALES_ORDER_ID) > 1 THEN
       '*****'
       ELSE
       TO_CHAR(MAX(OWB.SALES_ORDER_ID)) END AS SALES_ORDER_ID
  FROM ORDER_WITH_BOX OWB
  LEFT OUTER JOIN ORDER_SHIPPED OS
    ON OWB.PICKSLIP_ID = OS.PICKSLIP_ID
 GROUP BY OWB.BUCKET,
          OWB.PO,
          OWB.CUSTOMER_DC_ID,
          OWB.LABEL_ID,
          TRUNC(OWB.IMPORT_DATE),
          OWB.BUILDING
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="dtFrom" Type="String" Direction="Input" Name="FromDate" />
                    <asp:ControlParameter ControlID="dtTo" Type="String" Direction="Input" Name="ToDate" />
                    <asp:ControlParameter ControlID="tbCustomer" Type="String" Direction="Input" Name="Customer_id" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="Building_id" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvByPo" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
                AllowSorting="true" ShowFooter="true" DefaultSortExpression="customer_dc_id;BUILDING;$;start_date;bucket_id;po_id;dc_cancel_date">
                <Columns>
                    <eclipse:SequenceField FooterText="Total" />
                    <eclipse:MultiBoundField DataFields="customer_dc_id" HeaderText="Customer DC" SortExpression="customer_dc_id"
                        HeaderToolTip="Customer Distribution Center" />
                    <eclipse:MultiBoundField DataFields="BUILDING" HeaderText="Building" SortExpression="BUILDING" />
                    <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" SortExpression="bucket_id"
                        HeaderToolTip="Bucket Number">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="po_id" HeaderText="PO" SortExpression="po_id" 
                        HeaderToolTip="Purchase Order Number" />
                    <eclipse:MultiBoundField DataFields="SALES_ORDER_ID" HeaderText="PO Attrib1"  HeaderToolTip="PO's attribute # 1" SortExpression="SALES_ORDER_ID"
                         />
                    <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                        HeaderToolTip="Label" />
                    <eclipse:MultiBoundField DataFields="NO_OF_PICKSLIP" HeaderText="Number of|Pickslips"
                        SortExpression="NO_OF_PICKSLIP" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                        DataFooterFormatString="{0:N0}" HeaderToolTip="Number of Pickslips" FooterToolTip="Total Pickslips">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="NO_OF_BOXES" HeaderText="Number of|Boxes" SortExpression="NO_OF_BOXES"
                        DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                        HeaderToolTip="Number of Boxes" FooterToolTip="Total Boxes">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="ORDERED_PIECES" HeaderText="Total Ordered Pieces"
                        SortExpression="ORDERED_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                        DataFooterFormatString="{0:N0}" HeaderToolTip="Ordered Pieces" FooterToolTip="Total Ordered Pieces">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="TOTAL_DOLLARS_ORDERED" HeaderText="Total Dollars Ordered"
                        SortExpression="TOTAL_DOLLARS_ORDERED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}"
                        DataFooterFormatString="{0:N2}" HeaderToolTip="Total dollars ordered" FooterToolTip="Total dollars ordered">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="SHIPPED_PIECES" HeaderText="Total Shipped Pieces"
                        SortExpression="SHIPPED_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                        DataFooterFormatString="{0:N0}" HeaderToolTip="Shipped pieces" FooterToolTip="Shipped pieces">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="DOLLARS_SHIPPED" HeaderText="Total Dollars Shipped"
                        SortExpression="DOLLARS_SHIPPED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}"
                        DataFooterFormatString="{0:N2}" HeaderToolTip="Dollars shipped" FooterToolTip="Dollars shipped">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="WEIGHT" HeaderText="Weight (in lbs)" SortExpression="WEIGHT"
                        DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}" DataFooterFormatString="{0:N2}"
                        HeaderToolTip="Weight in lbs" FooterToolTip="Total Weight">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="MAX_VOLUME" HeaderText="Volume (in cc)" SortExpression="MAX_VOLUME"
                        DataFormatString="{0:N2}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N2}"
                        HeaderToolTip="Volume in cc" FooterToolTip="Total Volume">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="start_date" HeaderText="Start Date" SortExpression="start_date"
                        DataFormatString="{0:d}" HeaderToolTip="PO Start Date">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="dc_cancel_date" HeaderText="DC Cancel Date"
                        SortExpression="dc_cancel_date" DataFormatString="{0:d}" HeaderToolTip="DC Cancel Date">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="Import_Date" HeaderText="Import Date"
                        SortExpression="Import_Date" DataFormatString="{0:d}" HeaderToolTip="Pick Slip Import Date">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View runat="server">
            <oracle:OracleDataSource ID="dsModified" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                DataSourceMode="DataReader" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                <SelectSql>
WITH ACTIVE_PS AS
 (SELECT PS.PICKSLIP_ID           AS PICKSLIP_ID,
         PS.CUSTOMER_ID           AS CUSTOMER_ID,
         PS.PO_ID                 AS PO_ID,
         PS.LABEL_ID              AS LABEL_ID,
         PD.PIECES_ORDERED        AS PIECES_ORDERED,
         PS.BUCKET_ID             AS BUCKET_ID,
         PD.UPC_CODE              AS UPC_CODE,
         PS.CUSTOMER_DC_ID        AS CUSTOMER_DC_ID,
         PD.EXTENDED_PRICE        AS EXTENDED_PRICE,
         PS.PICKSLIP_IMPORT_DATE  AS PICK_SLIP_IMPORT_DATE,
         PO.START_DATE            AS START_DATE,
         PO.DC_CANCEL_DATE        AS DC_CANCEL_DATE,
         PS.WAREHOUSE_LOCATION_ID AS BUILDING<%--,
         PS.SALES_ORDER_ID AS SALES_ORDER_ID--%>
    FROM PS
   INNER JOIN PSDET PD
      ON PS.PICKSLIP_ID = PD.PICKSLIP_ID
   INNER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
   WHERE PS.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
     AND ps.pickslip_cancel_date IS NULL
     AND PS.CUSTOMER_ID = :Customer_id
 <if>AND <a pre="ps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Building_id</a></if>
     AND po.start_date &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND po.start_date &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1
  
  UNION ALL
  
  SELECT DPS.PICKSLIP_ID             AS PICKSLIP_ID,
         DPS.CUSTOMER_ID             AS CUSTOMER_ID,
         DPS.CUSTOMER_ORDER_ID       AS PO_ID,
         DPS.PICKSLIP_TYPE           AS LABEL_ID,
         DPD.QUANTITY_ORDERED        AS PIECES_ORDERED,
         NULL                        AS BUCKET_ID,
         DPD.UPC_CODE                AS UPC_CODE,
         DPS.CUSTOMER_DIST_CENTER_ID AS CUSTOMER_DC_ID,
         DPD.EXTENDED_PRICE          AS EXTENDED_PRICE,
         DPS.PICKSLIP_IMPORT_DATE    AS PICK_SLIP_IMPORT_DATE,
         DPS.DELIVERY_DATE           AS START_DATE,
         DPS.DC_CANCEL_DATE          AS DC_CANCEL_DATE,
         DPS.WAREHOUSE_LOCATION_ID   AS BUILDING<%--,
         DPS.SALES_ORDER_ID AS SALES_ORDER_ID--%>
    FROM DEM_PICKSLIP DPS
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPS.PICKSLIP_ID = DPD.PICKSLIP_ID
   WHERE DPS.PS_STATUS_ID = 1
         AND DPS.CUSTOMER_ID = :Customer_id
     <if>AND <a pre="dps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Building_id</a></if>
     AND DPS.DELIVERY_DATE &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND DPS.DELIVERY_DATE &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1              
                    ),
ORDER_INFO AS
 (SELECT RP.PICKSLIP_ID AS PICKSLIP,
         MAX(RP.BUCKET_ID) AS BUCKET,
         MAX(RP.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         RP.LABEL_ID AS LABEL_ID,
         MAX(RP.PO_ID) AS PO,
         SUM(RP.PIECES_ORDERED) AS PIECES,
         MAX(RP.START_DATE) AS START_DATE,
         MAX(RP.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(RP.PICK_SLIP_IMPORT_DATE) AS IMPORT_DATE,
         SUM(RP.PIECES_ORDERED * RP.EXTENDED_PRICE) AS TOTAL_DOLLARS_ORDERED,
         SUM(RP.PIECES_ORDERED * (MSKU.WEIGHT_PER_DOZEN / 12)) AS WEIGHT,
         MAX(RP.BUILDING) AS BUILDING<%--,
         max(RP.SALES_ORDER_ID) as SALES_ORDER_ID--%>
    FROM ACTIVE_PS RP
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON MSKU.UPC_CODE = RP.UPC_CODE
   GROUP BY RP.PICKSLIP_ID, RP.LABEL_ID),
ORDER_WITH_BOX AS
 (SELECT OI.PICKSLIP AS PICKSLIP_ID,
         MAX(OI.BUCKET) AS BUCKET,
         MAX(OI.PO) AS PO,
         MAX(OI.CUSTOMER_DC_ID) AS CUSTOMER_DC_ID,
         MAX(OI.TOTAL_DOLLARS_ORDERED) AS TOTAL_DOLLARS_ORDERED,
         OI.LABEL_ID AS LABEL_ID,
         MAX(OI.START_DATE) AS START_DATE,
         MAX(OI.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
         MAX(PIECES) AS PIECES,
         MAX(OI.IMPORT_DATE) AS IMPORT_DATE,
         COUNT(DISTINCT B.UCC128_ID) AS NO_OF_BOXES,
         MAX(WEIGHT) + NVL(SUM(SC.EMPTY_WT), 0) BOX_WEIGHT,
         SUM(SC.OUTER_CUBE_VOLUME) BOX_VOLUME,
         MAX(OI.BUILDING) AS BUILDING<%--,
         MAX(OI.SALES_ORDER_ID) as SALES_ORDER_ID--%>
    FROM ORDER_INFO OI
    LEFT OUTER JOIN BOX B
      ON OI.PICKSLIP = B.PICKSLIP_ID
    LEFT OUTER JOIN SKUCASE SC
      ON B.CASE_ID = SC.CASE_ID
   WHERE B.STOP_PROCESS_DATE IS NULL
   GROUP BY OI.PICKSLIP, OI.LABEL_ID),
ORDER_SHIPPED AS
 (SELECT PS.PICKSLIP_ID AS PICKSLIP_ID,
         SUM(NVL(BD.CURRENT_PIECES, 0)) AS SHIPPED_PIECES,
         SUM(NVL(BD.CURRENT_PIECES, 0) * NVL(BD.EXTENDED_PRICE, 0)) AS DOLLARS_SHIPPED,
         PS.WAREHOUSE_LOCATION_ID AS BUILDING
    FROM PS PS
   INNER JOIN PO PO
      ON PS.PO_ID = PO.PO_ID
     AND PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
    LEFT OUTER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND PS.PICKSLIP_ID = BD.PICKSLIP_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     AND ps.pickslip_cancel_date IS NULL
     AND PS.CUSTOMER_ID = :Customer_id
 <if>AND <a pre="ps.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Building_id</a></if>    
     AND po.start_date &gt;= to_date(:FromDate, 'mm/dd/yyyy')
     AND po.start_date &lt; to_date(:ToDate, 'mm/dd/yyyy') + 1
   GROUP BY PS.PICKSLIP_ID, PS.WAREHOUSE_LOCATION_ID)
SELECT OWB.CUSTOMER_DC_ID AS CUSTOMER_DC_ID,
       OWB.BUCKET AS BUCKET_ID,
       COUNT(DISTINCT OWB.PO) AS NO_OF_PO,
       OWB.LABEL_ID AS LABEL_ID,
       COUNT(OWB.PICKSLIP_ID) AS NO_OF_PICKSLIP,
       SUM(OWB.NO_OF_BOXES) AS NO_OF_BOXES,
       SUM(PIECES) AS ORDERED_PIECES,
       ROUND(SUM(OWB.BOX_WEIGHT), 4) AS box_weight,
       ROUND(SUM(OWB.BOX_VOLUME), 4) AS MAX_VOLUME,
       TRUNC(OWB.IMPORT_DATE) AS IMPORT_DATE,
       ROUND(SUM(OWB.TOTAL_DOLLARS_ORDERED), 4) AS TOTAL_DOLLARS_ORDERED,
       SUM(OS.SHIPPED_PIECES) AS SHIPPED_PIECES,
       SUM(OS.DOLLARS_SHIPPED) AS DOLLARS_SHIPPED,
       MAX(OWB.START_DATE) AS START_DATE,
       MAX(OWB.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       OWB.BUILDING AS BUILDING<%--,
       MAX(OWB.SALES_ORDER_ID) AS SALES_ORDER_ID--%>
  FROM ORDER_WITH_BOX OWB
  LEFT OUTER JOIN ORDER_SHIPPED OS
    ON OWB.PICKSLIP_ID = OS.PICKSLIP_ID
 GROUP BY OWB.BUCKET,
          OWB.CUSTOMER_DC_ID,
          OWB.LABEL_ID,
          TRUNC(OWB.IMPORT_DATE),
          OWB.BUILDING
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="dtFrom" Type="String" Direction="Input" Name="FromDate" />
                    <asp:ControlParameter ControlID="dtTo" Type="String" Direction="Input" Name="ToDate" />
                    <asp:ControlParameter ControlID="tbCustomer" Type="String" Direction="Input" Name="Customer_id" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="Building_id" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvByBucket" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                DataSourceID="dsModified" ShowFooter="true" Caption="<h2>Bucket Wise view Recommended for PO Consolidation</h2>"
                DefaultSortExpression="customer_dc_id;BUILDING;$;bucket_id; start_date; dc_cancel_date">
                <Columns>
                    <eclipse:SequenceField FooterText="Total" />
                    <eclipse:MultiBoundField DataFields="customer_dc_id" HeaderText="Customer DC" SortExpression="customer_dc_id"
                        HeaderToolTip="Customer Distribution Center" />
                    <eclipse:MultiBoundField DataFields="BUILDING" HeaderText="Building" SortExpression="BUILDING" />
                    <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" SortExpression="bucket_id"
                        HeaderToolTip="Bucket Number">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                        HeaderToolTip="Label" />
                    <eclipse:SiteHyperLinkField DataTextField="NO_OF_PO" DataNavigateUrlFields="bucket_id,customer_dc_id"
                        HeaderText="No. of POs" DataNavigateUrlFormatString="R110_112.aspx?BucketId={0}&Customer_DC_id={1}&"
                        DataSummaryCalculation="ValueSummation" SortExpression="NO_OF_PO" DataFooterFormatString="{0:N0}"
                        HeaderToolTip="Number of POs" FooterToolTip="Total POs" AppliedFiltersControlID="ButtonBar2$af">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:SiteHyperLinkField>
                    <eclipse:MultiBoundField DataFields="ORDERED_PIECES" HeaderText="Total Ordered Pieces"
                        SortExpression="ORDERED_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                        DataFooterFormatString="{0:N0}" HeaderToolTip="Ordered Pieces" FooterToolTip="Total Ordered Pieces">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="TOTAL_DOLLARS_ORDERED" HeaderText="Total Dollars Ordered"
                        SortExpression="TOTAL_DOLLARS_ORDERED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}"
                        DataFooterFormatString="{0:N2}" HeaderToolTip="Total dollars ordered" FooterToolTip="Total dollars ordered">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="SHIPPED_PIECES" HeaderText="Total Shipped Pieces"
                        SortExpression="SHIPPED_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                        DataFooterFormatString="{0:N0}" HeaderToolTip="Shipped pieces" FooterToolTip="Shipped pieces">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="DOLLARS_SHIPPED" HeaderText="Total Dollars Shipped"
                        SortExpression="DOLLARS_SHIPPED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}"
                        DataFooterFormatString="{0:N2}" HeaderToolTip="Dollars shipped" FooterToolTip="Dollars shipped">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="NO_OF_BOXES" HeaderText="No. of Boxes" SortExpression="NO_OF_BOXES"
                        DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                        HeaderToolTip="Number of Boxes" FooterToolTip="Total Boxes">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="box_weight" HeaderText="Weight (in lbs)" SortExpression="box_weight"
                        DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}" DataFooterFormatString="{0:N2}"
                        HeaderToolTip="Weight in lbs" FooterToolTip="Total Weight">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="max_volume" HeaderText="Volume (in cc)" SortExpression="max_volume"
                        DataFormatString="{0:N2}" DataFooterFormatString="{0:N2}" DataSummaryCalculation="ValueSummation"
                        HeaderToolTip="Volume in cc" FooterToolTip="Total Volume">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="start_date" HeaderText="Start Date" SortExpression="start_date"
                        DataFormatString="{0:d}" HeaderToolTip="PO Start Date">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="dc_cancel_date" HeaderText="DC Cancel Date"
                        SortExpression="dc_cancel_date" DataFormatString="{0:d}" HeaderToolTip="DC Cancel Date">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="Import_Date" HeaderText="Import Date"
                        SortExpression="Import_Date" DataFormatString="{0:d}" HeaderToolTip="Pick Slip Import Date">
                        <ItemStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

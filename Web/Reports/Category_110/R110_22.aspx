<%@ Page Title="Brazil loadsheet" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4105 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_22.aspx $
 *  $Id: R110_22.aspx 4105 2012-08-03 06:10:35Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report shows the unshipped order for Brazil customer" />
    <meta name="ReportId" content="110.22" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R110_22.aspx 4105 2012-08-03 06:10:35Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="PO" />
                <i:TextBoxEx ID="tbPO" runat="server" QueryString="po_id">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
       SELECT PS.PO_ID AS PO_ID,
       COUNT(DISTINCT B.UCC128_ID) AS BOX,
       SUM(BD.CURRENT_PIECES) AS PIECES,
       SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) AS AMOUNT,
       ROUND(SUM(NVL(BD.CURRENT_PIECES, 0) * (NVL(MSKU.WEIGHT_PER_DOZEN, 0) / 12)) +
       SUM(NVL(SKUCASE.EMPTY_WT, 0))) AS BOX_WEIGHT,
       MAX(CASE WHEN TS.SEWING_PLANT_CODE IS NOT NULL THEN 
           TS.SEWING_PLANT_CODE ||':'|| TS.SEWING_PLANT_NAME
           END) AS SEWING_PLANT_NAME ,
        MAX(tcry.name) AS Country_name,
       MAX(TC.DESCRIPTION) AS DESCRIPTION,
       PS.CUSTOMER_ID AS CUSTOMER,
       MSKU.STYLE AS STYLE,
       MSKU.COLOR AS COLOR
  FROM PS PS
  LEFT OUTER JOIN BOX B
    ON PS.PICKSLIP_ID = B.PICKSLIP_ID
 INNER JOIN BOXDET BD
    ON B.UCC128_ID = BD.UCC128_ID
   AND B.PICKSLIP_ID = BD.PICKSLIP_ID
 LEFT OUTER JOIN SRC_OPEN_CARTON SOP
    ON B.CARTON_ID = SOP.CARTON_ID
 LEFT OUTER JOIN TAB_SEWINGPLANT TS
    ON SOP.SEWING_PLANT_CODE = TS.SEWING_PLANT_CODE
 LEFT OUTER JOIN BOXDETCO BCO
    ON BD.UCC128_ID = BCO.UCC128_ID
   AND BD.UPC_CODE = BCO.UPC_CODE
   LEFT OUTER JOIN tab_country tcry ON
   bco.co_of_origin = tcry.country_id
 LEFT OUTER JOIN SKUCASE
    ON B.CASE_ID = SKUCASE.CASE_ID
 INNER JOIN MASTER_SKU MSKU
    ON BD.SKU_ID = MSKU.SKU_ID
 LEFT OUTER JOIN MASTER_STYLE_COLOR MSC
    ON MSKU.STYLE = MSC.STYLE
   AND MSKU.COLOR = MSC.COLOR
  LEFT OUTER JOIN TAB_CONTENT TC
    ON MSC.CONTENT_ID = TC.CONTENT_ID
 WHERE B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
   AND PS.TRANSFER_DATE IS NULL
  AND PS.po_id = :po_id
 GROUP BY MSKU.STYLE, MSKU.COLOR, PS.PO_ID,PS.CUSTOMER_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPO" Type="String" Name="po_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="CUSTOMER;PO_ID;$;">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" />
            <eclipse:MultiBoundField DataFields="DESCRIPTION" HeaderText="Description" SortExpression="DESCRIPTION" />
            <eclipse:MultiBoundField DataFields="BOX" HeaderText="Box" SortExpression="BOX" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="PIECES" HeaderText="Pieces" SortExpression="PIECES"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="AMOUNT" HeaderText="Amount" SortExpression="AMOUNT"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                 <eclipse:MultiBoundField DataFields="BOX_WEIGHT" HeaderText="Wgt" ItemStyle-HorizontalAlign="Right" SortExpression="BOX_WEIGHT" />
            <eclipse:MultiBoundField DataFields="CUSTOMER" HeaderText="Customer" SortExpression="CUSTOMER" />
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO" SortExpression="PO_ID" />
            <eclipse:MultiBoundField DataFields="Country_name" HeaderText="Ctry of Origion" HeaderStyle-Wrap="false" SortExpression="Country_name" />
            <eclipse:MultiBoundField DataFields="SEWING_PLANT_NAME" HeaderText="Sewing plant name"
                SortExpression="SEWING_PLANT_NAME" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

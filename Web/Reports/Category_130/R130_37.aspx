<%@ Page Title="Recasing Report" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7208 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R130_37.aspx 7208 2014-09-23 10:10:54Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
 [WebMethod]
    public static AutoCompleteItem[] GetCustomers(string term)
    {

        AutoCompleteItem[] items;

        using (OracleDataSource ds = new OracleDataSource())
        {
            ds.ConnectionString = ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString;
            ds.ProviderName = ConfigurationManager.ConnectionStrings["dcmslive"].ProviderName;
            ds.SysContext.ModuleName = "Customer Selector";

            ds.SelectSql = @"
                select cust.customer_id as customer_id, 
                       cust.name as customer_name
                from cust cust
                where 1 = 1
                <if c='$keywords'>AND (cust.customer_id like '%' || CAST(:keywords as VARCHAR2(25)) || '%' or UPPER(cust.name) like '%' || upper(CAST(:keywords as VARCHAR2(25))) || '%')</if>
                ";

            string[] tokens = term.Split(',');
            ds.SelectParameters.Add("keywords", TypeCode.String, tokens[tokens.Length - 1].Trim());

            items = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                     select new AutoCompleteItem()
                     {
                         Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_id"), DataBinder.Eval(cst, "customer_name")),
                         Value = DataBinder.Eval(cst, "customer_id", "{0}")
                     }).Take(20).ToArray();
        }
        return items;
    }

 [WebMethod]
 public static AutoCompleteItem ValidateCustomer(string term)
 {
     if (string.IsNullOrEmpty(term))
     {
         return null;
     }
     const string QUERY = @"
select cust.customer_id as customer_id, 
                       cust.name as customer_name
                from cust cust
                where cust.inactive_flag is null  <if>and cust.customer_id = :customer_id</if>";
     OracleDataSource ds = new OracleDataSource(ConfigurationManager.ConnectionStrings["dcmslive"]);
     ds.SysContext.ModuleName = "CustomerValidator";
     ds.SelectParameters.Add("customer_id", TypeCode.String, string.Empty);
     try
     {
         ds.SelectSql = QUERY;
         if (term.Contains(":"))
         {
             term = term.Split(':')[0];
         }
         ds.SelectParameters["customer_id"].DefaultValue = term;
         AutoCompleteItem[] data = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                                    select new AutoCompleteItem()
                                    {
                                        Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_id"), DataBinder.Eval(cst, "customer_name")),
                                        Value = DataBinder.Eval(cst, "customer_id", "{0}")
                                    }).Take(5).ToArray();
         return data.Length > 0 ? data[0] : null;
     }
     finally
     {
         ds.Dispose();
     }
 }
    </script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report lists all SKU with standard case quantity and inventory in all areas, it helps user to identify that how much pieces are there which needs to be re packed." />
    <meta name="ReportId" content="130.37" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_37.aspx 7208 2014-09-23 10:10:54Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tpFilters" runat="server">

                <eclipse:LeftLabel ID="LeftLabel5" Text="Customer" runat="server" />
                                <i:AutoComplete runat="server" ID="tbCustId" ClientIDMode="Static" WebMethod="GetCustomers"
                                    FriendlyName="Customer" QueryString="customer_id" ToolTip="The customers whose purchase order you are interested in."
                                    Delay="1000" Width="137" ValidateWebMethodName="ValidateCustomer"
                        AutoValidate="true">
                                    
                                </i:AutoComplete>
                <br />
              Order pieces will be shown for the passed customer only.
                 </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
WITH ORDERED_SKUS AS
 (SELECT DPD.UPC_CODE,
         DP.VWH_ID            AS VWH_ID,
         DPD.QUANTITY_ORDERED AS PIECES_ORDERED
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPD.PICKSLIP_ID = DP.PICKSLIP_ID
   WHERE DP.PS_STATUS_ID = 1
   <if>AND dp.customer_id =:customer_id</if>
  
  UNION ALL
  
  SELECT PD.UPC_CODE,
         P.VWH_ID          AS VWH_ID,
         PD.PIECES_ORDERED AS PIECES_ORDERED
    FROM PS P
   INNER JOIN PSDET PD
      ON P.PICKSLIP_ID = PD.PICKSLIP_ID
   WHERE P.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
     AND P.PICKSLIP_CANCEL_DATE IS NULL
 <if>AND p.customer_id =:customer_id</if>
            ),
Total_ordered_SKU AS
 (SELECT OS.UPC_CODE AS UPC_CODE,
         OS.VWH_ID,
         SUM(OS.PIECES_ORDERED) AS PIECES_ORDERED
    FROM ORDERED_SKUS OS
   GROUP BY OS.UPC_CODE, OS.VWH_ID),
Box_SKUs as
 (SELECT BD.UPC_CODE AS UPC_CODE,
         B.VWH_ID AS VWH_ID,
         sum(BD.Current_Pieces) AS PICKED_QUANTITY
    FROM BOXDET BD 
   INNER JOIN BOX B
      ON B.PICKSLIP_ID = BD.PICKSLIP_ID
     AND B.UCC128_ID = BD.UCC128_ID
   INNER JOIN PS P
      ON P.PICKSLIP_ID = B.PICKSLIP_ID
   WHERE P.TRANSFER_DATE IS NULL
     AND P.PICKSLIP_CANCEL_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
 <if>AND p.customer_id =:customer_id</if>
     AND NVL(BD.Current_Pieces, 0) &gt; 0
   group by BD.UPC_CODE, B.VWH_ID), ALL_INVENTORY_SKU AS
 (SELECT TIA.INVENTORY_STORAGE_AREA AS INVENTORY_AREA,
         TIA.SHORT_NAME AS AREA_NAME,
         msku.upc_code as upc_code,
         SC.VWH_ID AS VWH_ID,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS BUILDING_ID,
         SCD.QUANTITY AS QUANTITY,
         NULL AS FPK_QTY,
         CASE
           WHEN SC.PRICE_SEASON_CODE = 'TR' THEN
            SCD.QUANTITY
         END AS TRSEASON_PIECES,
         CASE
           WHEN tia.short_name = 'BIR' AND
                msku.STANDARD_CASE_QTY &lt;&gt; scd.quantity THEN
            scd.quantity
         END AS recase_quantity,
         TIA.STORES_WHAT AS AREA_TYPE
    FROM SRC_CARTON_DETAIL SCD
   INNER JOIN SRC_CARTON SC
      ON SC.CARTON_ID = SCD.CARTON_ID
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON SCD.SKU_ID = MSKU.SKU_ID
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.LOCATION_ID = MSL.LOCATION_ID
     AND SC.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON SC.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA  
   
  UNION ALL
  
  SELECT IL.IA_ID AS INVENTORY_AREA,
         IL.SHORT_NAME AS AREA_NAME,
         IL.UPC_CODE,
         IL.VWH_ID AS VWH_ID,
         NVL(IL.WAREHOUSE_LOCATION_ID, 'Unknowm'),
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.RESERVED_UNITS, 0) AS QUANTITY,
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.RESERVED_UNITS, 0) AS FPK_QTY,
         NULL TRSEASON_PIECES,
         NULL AS recase_quantity,
         'SKU' AS AREA_TYPE
    FROM (SELECT IAC.IA_ID AS IA_ID,
                 MAX(IA.SHORT_NAME) AS SHORT_NAME,
                 IAC.Iacontent_Id AS UPC_CODE,
                 I.VWH_ID AS VWH_ID,
                 NVL(IA.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
                 SUM(IAC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS
            FROM IALOC_CONTENT IAC
            LEFT OUTER JOIN IALOC I
              ON I.IA_ID = IAC.IA_ID
             AND I.LOCATION_ID = IAC.LOCATION_ID
            LEFT OUTER JOIN IA
              ON IA.IA_ID = IAC.IA_ID
           WHERE NVL(NUMBER_OF_UNITS, 0) &gt; 0
            AND IA.SHORT_NAME &lt;&gt;'SSS'  
           GROUP BY IAC.IA_ID,
                    IAC.Iacontent_Id,
                    I.VWH_ID,
                    NVL(IA.WAREHOUSE_LOCATION_ID, 'Unknown')) IL
    LEFT OUTER JOIN (SELECT RD.IA_ID AS IA_ID,
                           RD.UPC_CODE AS UPC_CODE,
                           SUM(RD.PIECES_RESERVED) RESERVED_UNITS,
                           RD.VWH_ID,
                           NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID
                      FROM RESVDET RD
                      LEFT OUTER JOIN IALOC_CONTENT IC
                        ON IC.IA_ID = RD.IA_ID
                       AND IC.LOCATION_ID = RD.LOCATION_ID
                      LEFT OUTER JOIN IALOC I
                        ON I.IA_ID = IC.IA_ID
                       AND I.LOCATION_ID = IC.LOCATION_ID
                     WHERE NVL(RD.PIECES_RESERVED, 0) &gt; 0
                     GROUP BY RD.UPC_CODE,
                              RD.VWH_ID,
                              RD.IA_ID,
                              NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown')) R
      ON IL.IA_ID = R.IA_ID
     AND IL.UPC_CODE = R.UPC_CODE
     AND IL.VWH_ID = R.VWH_ID
     AND IL.WAREHOUSE_LOCATION_ID = R.WAREHOUSE_LOCATION_ID
  
  ),
GROUPED_INVENTORY_SKU AS
 (SELECT AIS.UPC_CODE AS UPC_CODE,
         AIS.INVENTORY_AREA AS INVENTORY_AREA,
         MAX(AIS.AREA_NAME) AS AREA_NAME,
         AIS.VWH_ID AS VWH_ID,
         AIS.BUILDING_ID AS BUILDING_ID,
         SUM(AIS.QUANTITY) AS QUANTITY,
         sum(SUM(ais.recase_quantity)) OVER(PARTITION BY AIS.UPC_CODE, AIS.VWH_ID) AS recase_quantity,
         sum(SUM(AIS.TRSEASON_PIECES)) OVER(PARTITION BY AIS.UPC_CODE, AIS.VWH_ID) AS TRSEASON_PIECES,
         SUM(SUM(CASE
                   WHEN AIS.AREA_NAME = 'FPK' THEN
                    AIS.FPK_QTY
                 END)) OVER(PARTITION BY AIS.UPC_CODE, AIS.VWH_ID) AS FPK_QTY,
         MAX(AIS.AREA_TYPE) AS AREA_TYPE
    FROM ALL_INVENTORY_SKU AIS
   GROUP BY AIS.UPC_CODE, AIS.VWH_ID, AIS.INVENTORY_AREA, AIS.BUILDING_ID),
SKU_With_Inventory_AND_Ordered AS
 (SELECT NVL(SLWO.VWH_ID, GIS.VWH_ID) AS VWH_ID,
         NVL(SLWO.UPC_CODE, GIS.UPC_CODE) AS UPC_code,
         SLWO.PIECES_ORDERED AS PIECES_ORDERED,
         GIS.QUANTITY AS Inventory_In_DCMS,
         GIS.INVENTORY_AREA AS Area_ID,
         GIS.AREA_NAME AS Area_Name,
         GIS.BUILDING_ID AS Building,
         bs.PICKED_QUANTITY AS Picked_Quanity,
         GIS.TRSEASON_PIECES AS TRSEASON_PIECES,
         NVL(SLWO.PIECES_ORDERED, 0) - NVL(bs.PICKED_QUANTITY, 0) AS Unit_Left_To_Pick,
         gis.recase_quantity AS BIR_Recase_Quanity,
         GIS.FPK_QTY AS FPK_QTY,
         NVL(gis.recase_quantity, 0) + NVL(GIS.FPK_QTY, 0) AS TOTAL_RECASING,
         GIS.AREA_TYPE AS AREA_TYPE
    FROM Total_ordered_SKU SLWO
    FULL OUTER JOIN GROUPED_INVENTORY_SKU GIS
      ON SLWO.VWH_ID = GIS.VWH_ID
     AND SLWO.UPC_CODE = GIS.UPC_CODE
    left outer join Box_SKUs bs
      on slwo.vwh_id = bs.vwh_id
     and slwo.upc_code = bs.upc_code)
SELECT  aswi.VWH_ID,
       msku.style,
       msku.color,
       msku.dimension,
       msku.sku_size,
       aswi.UPC_code,
       MST.LABEL_ID,
       msku.standard_case_qty,
       aswi.PIECES_ORDERED,
       aswi.Inventory_In_DCMS,
       aswi.Area_ID,
       aswi.Area_Name,
       aswi.Building,
       aswi.Picked_Quanity,
       aswi.TRSEASON_PIECES,
       aswi.Unit_Left_To_Pick,
       aswi.BIR_Recase_Quanity,
       aswi.FPK_QTY,
       aswi.TOTAL_RECASING,
       AREA_TYPE
  FROM SKU_With_Inventory_AND_Ordered aswi
  LEFT OUTER JOIN MASTER_SKU MSKU
    on aswi.upc_code = msku.upc_code
  LEFT OUTER JOIN MASTER_STYLE MST
    ON MSKU.STYLE = MST.STYLE 
            
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="false" PagerSettings-Visible="false"
        ShowFooter="true" DataSourceID="ds" AllowPaging="true" PageSize="500" DefaultSortExpression="Style;Color;dimension;SKU_SIZE;UPC_code;VWH_ID">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="Vwh" SortExpression="VWH_ID" HeaderToolTip="Virtual Warehouse of the SKU"/>
            <eclipse:MultiBoundField DataFields="Style" ItemStyle-HorizontalAlign="Left" HeaderText="Style" SortExpression="Style" HeaderToolTip="Style of the SKU"/>
            <eclipse:MultiBoundField DataFields="Color" HeaderText="Color" SortExpression="Color" HeaderToolTip="Color of the SKU"/>
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" HeaderToolTip="Dimension of the SKU"/>
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE" HeaderToolTip="Size of the SKU"/>
            <eclipse:MultiBoundField DataFields="UPC_code" ItemStyle-HorizontalAlign="Left" HeaderText="UPC" SortExpression="UPC_code" />
            <eclipse:MultiBoundField DataFields="STANDARD_CASE_QTY" HeaderText="Std. Case Qty" SortExpression="STANDARD_CASE_QTY" HeaderToolTip="Standard Case Quantity of the SKU">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="LABEL_ID" HeaderText="Label" SortExpression="LABEL_ID" HeaderToolTip="Label of the Style"
                 />
            <eclipse:MultiBoundField DataFields="PIECES_ORDERED" HeaderText="Pieces|Ordered" HeaderToolTip="Ordered pieces of the SKU"
                SortExpression="PIECES_ORDERED" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Picked_Quanity" HeaderText="Pieces|Picked" HeaderToolTip="Pieces of the SKU which are picked"
                SortExpression="Picked_Quanity" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="Unit_Left_To_Pick" HeaderText="Pieces|UnPicked" HeaderToolTip="Pieces of the SKU which are still not picked"
                SortExpression="Unit_Left_To_Pick" DataSummaryCalculation="ValueSummation" DataFormatString="{0:#,###}"
                DataFooterFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <m:MatrixField DataMergeFields="Style,Color,dimension,SKU_SIZE,UPC_code,VWH_ID" DataHeaderFields="Building,Area_Name,Area_ID,AREA_TYPE"
                DataCellFields="Inventory_In_DCMS" HeaderText="{0}<br>{1}" GroupByColumnHeaderText="true">
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="CellValue" DataCellFormatString="{0:#,###}" ColumnTotalFormatString="{0:#,###}" DataHeaderFormatString="{0::$AREA_TYPE ='CTN': Carton Area Quantity: Picking Area Quantity}" VisibleExpression="$Area_Name !=''" DisplayColumnTotal="true">
                    </m:MatrixColumn>
                    <m:MatrixColumn ColumnType="RowTotal" DataCellFormatString="{0:#,###}" ColumnTotalFormatString="{0:#,###}" DataHeaderFormatString="All Areas Pieces" DisplayColumnTotal="true">
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="BIR_Recase_Quanity" HeaderText="Quantity To Be Recased|BIR"
                SortExpression="BIR_Recase_Quanity" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="FPK_QTY" HeaderText="Quantity To Be Recased|FPK"
                SortExpression="FPK_QTY" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="TOTAL_RECASING" HeaderText="Quantity To Be Recased|Total"
                SortExpression="TOTAL_RECASING" DataSummaryCalculation="ValueSummation" DataFormatString="{0:#,###}"
                DataFooterFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="TRSEASON_PIECES" HeaderText="TR Season Code Pieces"
                SortExpression="TRSEASON_PIECES" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

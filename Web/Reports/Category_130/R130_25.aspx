<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKUs In Shortage And Min Pullback Quantity" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5856 $
 *  $Author: sbist $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_25.aspx $
 *  $Id: R130_25.aspx 5856 2013-08-03 04:59:07Z sbist $
 * Version Control Template Added.
--%>
<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        ds.PostSelected += new EventHandler<PostSelectedEventArgs>(ds_PostSelected);
        // gv.DataBound += new EventHandler(gv_DataBound);
        base.OnInit(e);
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// <remarks>
    /// <para>
    /// This is the XML we ar trying to parse.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <PivotSet>
    /// <item>
    /// <column name = "CARTON_STORAGE_AREA">BIR</column>
    /// <column name = "WAREHOUSE_LOCATION_ID">FDC</column>
    /// <column name = "QUANTITY">576</column>
    /// </item>
    /// <item>
    /// <column name = "CARTON_STORAGE_AREA">BIR</column>
    /// <column name = "WAREHOUSE_LOCATION_ID">FDC1</column>
    /// <column name = "QUANTITY">972</column>
    /// </item>
    /// </PivotSet>
    /// ]]>
    /// </code>
    /// </remarks>
    void ds_PostSelected(object sender, PostSelectedEventArgs e)
    {
        var data = (System.Data.DataView)e.Result;
        if (data != null)
        {
            var list = new List<DataControlField>();
            var oldCount = gv.Columns.Count;
            foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["INVENTORY_AREA_WAREHOUSE_L_XML"] != DBNull.Value))
            {
                var items = XElement.Parse((string)row["INVENTORY_AREA_WAREHOUSE_L_XML"]).Elements("item");
                foreach (var item in items)
                {
                    var field = ParsePivotItem(data.Table, row, item);
                    if (field != null)
                    {
                        list.Add(field);
                    }
                }
            }
            var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "picked_pieces"));
            var addedColumns = from col in list
                               let tokens = col.AccessibleHeaderText.Split(',')
                               let building = tokens[0]
                               let area = tokens[1]
                               orderby building, area
                               select new
                               {
                                   Column = col,
                                   Area = area,
                                   Building = building,
                                   HeaderText = string.Format("Pieces in {0}|{1}", building, area)
                               };
            foreach (var col in addedColumns.Where(p => p.Building != "Unknown"))
            {

                ++index;
                gv.Columns.Insert(index, col.Column);

            }
            foreach (var col in addedColumns.Where(p => p.Building == "Unknown"))
            {

                ++index;
                col.Column.HeaderText = col.HeaderText;
                gv.Columns.Insert(index, col.Column);
            }
            //if (oldCount == gv.Columns.Count)
            //{
            //    divInfo.Visible = true;// No column was added to the grid
            //}
        }
    }
    private static DataControlField ParsePivotItem(System.Data.DataTable tbl, System.Data.DataRowView row, XElement pivotItem)
    {
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "INVENTORY_AREA").First().Value;
        var buildingId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
        var qty = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "PIECES_IN_AREA").First().Value;
        //var area_type = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "STORE_WHAT").First().Value;
        var colName = string.Format("{0}_{1}", areaId, buildingId);
        var col = tbl.Columns[colName];
        int pieces;
        DataControlField retVal = null;
        if (int.TryParse(qty, out pieces) && pieces > 0)
        {
            if (col == null && !string.IsNullOrEmpty(areaId))
            {
                col = tbl.Columns.Add(colName, typeof(int));

                var bf = new MultiBoundField
                {

                    HeaderText = string.Format("Pieces in {0}|{1}", buildingId, areaId),
                    DataFields = new[] { colName },
                    DataFormatString = "{0:N0}",
                    AccessibleHeaderText = string.Format("{0},{1}", buildingId, areaId),
                    DataSummaryCalculation = SummaryCalculationType.ValueSummation,
                    DataFooterFormatString = "{0:N0}"
                };
                bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                bf.FooterStyle.HorizontalAlign = HorizontalAlign.Right;
                //bf.ItemStyle.BackColor = System.Drawing.Color.LightGreen;
                retVal = bf;

            }

            row[colName] = pieces;
        }
        return retVal;


    }
    
    protected void gv_PreRender(object sender, EventArgs e)
    {
        DataControlField dcfCfd = (from DataControlField dcf in gv.Columns.OfType<MultiBoundField>()
                                   where dcf.AccessibleHeaderText.Equals("CfdPullBackQuantity")
                                   select dcf).First();
        DataControlField dcfOut = (from DataControlField dcf in gv.Columns.OfType<MultiBoundField>()
                                   where dcf.AccessibleHeaderText.Equals("OutPullBackQuantity")
                                   select dcf).First();

        switch (ddlPullbackArea.Value)
        {
            case "CFD":
                dcfCfd.Visible = true;
                break;
            case "OUT":
                dcfOut.Visible = true;
                break;
            default:
                break;
        }
    }
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
                where cust.inactive_flag is null <if>and  cust.customer_id = :customer_id</if>";
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
    <meta name="Description" content="The Report displays the Warehouse Location wise ordered 
                                        SKUs and for those SKUs the inventory area along 
                                        with the min pull back quantity details." />
    <meta name="ReportId" content="130.25" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_25.aspx 5856 2013-08-03 04:59:07Z sbist $" />
    <meta name="ChangeLog" content="Showing areas along with their building.|Replaced building filter dropdown with checkbox list." />
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
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Pull Back Area(CFD or OUT) ?" />
                <oracle:OracleDataSource ID="dsPullbackArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
        select tia.short_name AS storage_area,
                           tia.description  AS description,
                    tia.shippable_status AS shipable_status
                    from tab_inventory_area tia
where tia.shippable_status = 'R'
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 runat="server" ID="ddlPullbackArea" DataSourceID="dsPullbackArea"
                    DataFields="storage_area" DataTextFormatString="{0}">
                </i:DropDownListEx2>

                 <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Building" />
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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                    QueryString="building" >
                </i:CheckBoxListEx>
 <br />
                The Building for which you want to see the orders
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Click to choose Virtual Warehouse" />
               <br />
               The virtual warehouse for which you want to see the orders
                <eclipse:LeftLabel runat="server"/>
                <i:AutoComplete runat="server" ID="tbCustomers" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Orders Of Customer" QueryString="customer_id" Delay="4000"  AutoValidate="true"
                     ValidateWebMethodName="ValidateCustomer"
                    Width="200">
                   </i:AutoComplete>
                   <br />
                   The customer for which you want to see the orders.
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true" DataSourceMode="DataSet" >
        <SelectSql>
WITH ALL_ORDERED_SKU AS
 (SELECT /*+ rule */
   DPD.STYLE            AS STYLE,
   DPD.COLOR            AS COLOR,
   DPD.DIMENSION        AS DIMENSION,
   DPD.SKU_SIZE         AS SKU_SIZE,
   DP.PICKSLIP_TYPE     AS LABEL_ID,
   DP.VWH_ID            AS VWH_ID,
   DPD.QUANTITY_ORDERED AS QUANTITY_ORDERED,
   DP.WAREHOUSE_LOCATION_ID
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPD.PICKSLIP_ID = DP.PICKSLIP_ID
   WHERE DP.PS_STATUS_ID = 1
     <if>AND DP.VWH_ID =:VWH_ID</if>
     <if>AND <a pre="dp.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>and Dp.customer_id=:customer_id</if>
  UNION ALL
  SELECT MS.STYLE          AS STYLE,
         MS.COLOR          AS COLOR,
         MS.DIMENSION      AS DIMENSION,
         MS.SKU_SIZE       AS SKU_SIZE,
         P.LABEL_ID        AS LABEL_ID,
         P.VWH_ID          AS VWH_ID,
         PD.PIECES_ORDERED AS QUANTITY_ORDERED,
         P.WAREHOUSE_LOCATION_ID
    FROM PS P
   INNER JOIN PSDET PD
      ON P.PICKSLIP_ID = PD.PICKSLIP_ID
   INNER JOIN MASTER_SKU MS
      ON MS.UPC_CODE = PD.UPC_CODE
   INNER JOIN BUCKET BKT
      ON P.BUCKET_ID = BKT.BUCKET_ID
   WHERE BKT.AVAILABLE_FOR_MPC = 'Y'
     AND BKT.AVAILABLE_FOR_PITCHING IS NULL
     <if>AND P.VWH_ID = :VWH_ID</if>
     <if>AND <a pre="p.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>and p.customer_id=:customer_id</if>
     AND P.TRANSFER_DATE IS NULL
     AND PD.TRANSFER_DATE IS NULL
  UNION ALL
  SELECT MS.STYLE           AS STYLE,
         MS.COLOR           AS COLOR,
         MS.DIMENSION       AS DIMENSION,
         MS.SKU_SIZE        AS SKU_SIZE,
         P.LABEL_ID         AS LABEL_ID,
         B.VWH_ID           AS VWH_ID,
         BD.EXPECTED_PIECES AS QUANTITY_ORDERED,
         P.WAREHOUSE_LOCATION_ID
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.PICKSLIP_ID = BD.PICKSLIP_ID
     AND B.UCC128_ID = BD.UCC128_ID
   INNER JOIN PS P
      ON P.PICKSLIP_ID = B.PICKSLIP_ID
   INNER JOIN BUCKET BKT
      ON BKT.BUCKET_ID = P.BUCKET_ID
   INNER JOIN MASTER_SKU MS
      ON BD.UPC_CODE = MS.UPC_CODE
   WHERE B.IA_ID IS NULL
     <if>AND B.VWH_ID = :VWH_ID</if>
     <if>AND <a pre="p.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>and p.customer_id=:customer_id</if>
     AND BKT.AVAILABLE_FOR_PITCHING = 'Y'
     AND BKT.AVAILABLE_FOR_MPC = 'Y'
     AND P.TRANSFER_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL),
ALL_GROUPED_SKU AS
 (SELECT AO.STYLE AS STYLE,
         AO.COLOR AS COLOR,
         AO.DIMENSION AS DIMENSION,
         AO.SKU_SIZE AS SKU_SIZE,
         AO.VWH_ID AS VWH_ID,
         AO.WAREHOUSE_LOCATION_ID,
         SUM(AO.QUANTITY_ORDERED) AS QUANTITY_ORDERED,
         MAX(mt.LABEL_ID) AS LABEL_ID
    FROM ALL_ORDERED_SKU AO
    left outer join  master_style mt on
    AO.style=mt.style
    GROUP BY AO.STYLE, AO.COLOR, AO.DIMENSION, AO.SKU_SIZE, AO.VWH_ID, AO.WAREHOUSE_LOCATION_ID),
ALL_INVENTORY_SKU AS
 (SELECT NVL(TIA.SHORT_NAME, sc.carton_storage_area) AS INVENTORY_AREA,
         sc.carton_storage_area as ia_id,
         MS.STYLE              AS STYLE,
         MS.COLOR              AS COLOR,
         MS.DIMENSION          AS DIMENSION,
         MS.SKU_SIZE           AS SKU_SIZE,
         SC.VWH_ID              AS VWH_ID,
         SCD.QUANTITY           AS QUANTITY,
         TIA.SHIPPABLE_STATUS   AS SHIPPABLE_STATUS,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') as WAREHOUSE_LOCATION_ID
    FROM SRC_CARTON_DETAIL SCD
   INNER JOIN SRC_CARTON SC
      ON SC.CARTON_ID = SCD.CARTON_ID
    LEFT OUTER JOIN SRC_REQ_DETAIL SRD
      ON SRD.REQ_PROCESS_ID = SCD.REQ_PROCESS_ID
     AND SRD.REQ_MODULE_CODE = SCD.REQ_MODULE_CODE
     AND SRD.REQ_LINE_NUMBER = SCD.REQ_LINE_NUMBER
     LEFT OUTER JOIN MASTER_SKU MS
     ON MS.SKU_ID=SCD.SKU_ID
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.LOCATION_ID = MSL.LOCATION_ID
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON SC.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   WHERE (TIA.SHORT_NAME =:area OR SCD.REQ_PROCESS_ID IS NULL OR
         ((TIA.SHORT_NAME =:CartonReserveArea AND
         (TIA.SHORT_NAME =:RestockingArea or TIA.SHORT_NAME =:ShipDocBoxArea) or scd.req_module_code=:BoxpickModuleCode)))
     AND SC.SUSPENSE_DATE IS NULL
     AND (TIA.SHIPPABLE_STATUS = 'I' OR
         (TIA.SHIPPABLE_STATUS = 'R' AND TIA.SHORT_NAME = :area) or (TIA.SHIPPABLE_STATUS is null and TIA.stores_what=:store_what))
         <if>AND SC.VWH_ID=:VWH_ID</if>
  UNION ALL
  SELECT NVL(IL.short_name,IL.IA_ID) AS INVENTORY_AREA,
         IL.IA_ID AS IA_ID,
         IL.STYLE AS STYLE,
         IL.COLOR AS COLOR,
         IL.DIMENSION AS DIMENSION,
         IL.SKU_SIZE AS SKU_SIZE,
         IL.VWH_ID AS VWH_ID,
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.NUMBER_OF_UNITS, 0) AS QUANTITY,
         IL.SHIPPABLE_STATUS AS SHIPPABLE_STATUS,
         IL.WAREHOUSE_LOCATION_ID
    FROM (SELECT IAC.IA_ID      AS IA_ID,
                 MAX(IA.SHORT_NAME) AS SHORT_NAME,
                 MSKU.STYLE     AS STYLE,
                 MSKU.COLOR     AS COLOR,
                 MSKU.DIMENSION AS DIMENSION,
                 MSKU.SKU_SIZE  AS SKU_SIZE,
                 I.VWH_ID AS VWH_ID,
                 SUM(IAC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS,
                 'I' AS SHIPPABLE_STATUS,
                 I.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID
            FROM IALOC_CONTENT IAC
           INNER JOIN IALOC I
              ON I.IA_ID = IAC.IA_ID
             AND I.LOCATION_ID = IAC.LOCATION_ID
           INNER JOIN MASTER_SKU MSKU
              ON MSKU.UPC_CODE = IAC.IACONTENT_ID
           INNER JOIN IA ON 
            I.IA_ID = IA.IA_ID
           WHERE IA.PICKING_AREA_FLAG = 'Y'
             AND IAC.IACONTENT_TYPE_ID =:SkuTypeStorageArea
             <if>AND I.VWH_ID = :VWH_ID</if>
           GROUP BY IAC.IA_ID,
                    MSKU.STYLE,
                    MSKU.COLOR,
                    MSKU.DIMENSION,
                    MSKU.SKU_SIZE,
                    I.VWH_ID,
                    I.WAREHOUSE_LOCATION_ID) IL
    LEFT OUTER JOIN (SELECT RD.IA_ID AS IA_ID,
                            MSKU.STYLE AS STYLE,
                            MSKU.COLOR AS COLOR,
                            MSKU.DIMENSION AS DIMENSION,
                            MSKU.SKU_SIZE AS SKU_SIZE,
                            SUM(RD.PIECES_RESERVED) NUMBER_OF_UNITS,
                            RD.VWH_ID
                       FROM RESVDET RD
                      INNER JOIN MASTER_SKU MSKU
                         ON RD.UPC_CODE = MSKU.UPC_CODE
                      GROUP BY MSKU.STYLE,
                               MSKU.COLOR,
                               MSKU.DIMENSION,
                               MSKU.SKU_SIZE,
                               RD.VWH_ID,
                               RD.IA_ID) R
      ON IL.IA_ID = R.IA_ID
     AND IL.STYLE = R.STYLE
     AND IL.COLOR = R.COLOR
     AND IL.DIMENSION = R.DIMENSION
     AND IL.SKU_SIZE = R.SKU_SIZE
     AND IL.VWH_ID = R.VWH_ID),
GROUPED_INVENTORY_SKU AS
 (SELECT AIS.STYLE AS STYLE,
         AIS.COLOR AS COLOR,
         AIS.DIMENSION AS DIMENSION,
         AIS.SKU_SIZE AS SKU_SIZE,
         AIS.INVENTORY_AREA AS INVENTORY_AREA,
         AIS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
         AIS.VWH_ID AS VWH_ID,
         SUM(AIS.QUANTITY) AS QUANTITY,
         SUM(SUM(CASE
                   WHEN AIS.SHIPPABLE_STATUS = 'R'
                   <a pre="AND AIS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a> THEN
                    AIS.QUANTITY
                 END)) OVER(PARTITION BY AIS.STYLE, AIS.COLOR, AIS.DIMENSION, AIS.SKU_SIZE, AIS.VWH_ID) AS QUANTITY_REMOTE_AREAS,
         SUM(SUM(CASE
                   WHEN AIS.SHIPPABLE_STATUS = 'I'
                   <a pre="AND AIS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a> THEN
                    AIS.QUANTITY
                 END)) OVER(PARTITION BY AIS.STYLE, AIS.COLOR, AIS.DIMENSION, AIS.SKU_SIZE, AIS.VWH_ID) AS QUANTITY_IMEDIATE_AREAS
    FROM ALL_INVENTORY_SKU AIS
   GROUP BY AIS.STYLE,
            AIS.COLOR,
            AIS.DIMENSION,
            AIS.SKU_SIZE,
            AIS.VWH_ID,
            AIS.INVENTORY_AREA,
            AIS.WAREHOUSE_LOCATION_ID), FINAL_QUERY AS (
SELECT OS.STYLE AS STYLE,
       OS.COLOR AS COLOR,
       OS.DIMENSION AS DIMENSION,
       OS.SKU_SIZE AS SKU_SIZE,
       OS.LABEL_ID AS LABEL_ID,
       OS.VWH_ID AS VWH_ID,
       OS.QUANTITY_ORDERED AS ORDERED_QUANTITY,
       GIS.INVENTORY_AREA AS INVENTORY_AREA,
       GIS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       GIS.QUANTITY AS PIECES_IN_AREA,
       GIS.QUANTITY_REMOTE_AREAS AS QUANTITY_REMOTE_AREAS,
       GIS.QUANTITY_IMEDIATE_AREAS AS QUANTITY_IMEDIATE_AREAS,
       OS.QUANTITY_ORDERED - NVL(GIS.QUANTITY_IMEDIATE_AREAS, 0) AS SHORTAGE,
       LEAST(OS.QUANTITY_ORDERED - NVL(GIS.QUANTITY_IMEDIATE_AREAS, 0),
             NVL(GIS.QUANTITY_REMOTE_AREAS, 0)) AS MIN_PULLBACK_QUANTITY
  FROM ALL_GROUPED_SKU OS
  LEFT OUTER JOIN GROUPED_INVENTORY_SKU GIS
    ON GIS.STYLE = OS.STYLE
   AND GIS.COLOR = OS.COLOR
   AND GIS.DIMENSION = OS.DIMENSION
   AND GIS.SKU_SIZE = OS.SKU_SIZE
   AND GIS.VWH_ID = OS.VWH_ID
 WHERE OS.QUANTITY_ORDERED > NVL(GIS.QUANTITY_IMEDIATE_AREAS, 0))
            SELECT * FROM FINAL_QUERY 
pivot XML(sum(PIECES_IN_AREA) as PIECES_IN_AREA for (INVENTORY_AREA,WAREHOUSE_LOCATION_ID ) IN(ANY, ANY))

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlPullbackArea" Type="String" Name="area" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Name="VWH_ID" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Name="WAREHOUSE_LOCATION_ID"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbCustomers" Type="String" Name="customer_id" />
            <asp:Parameter Name="store_what" Type="String" DbType="String" DefaultValue="<%$ AppSettings:StoreWhatForCarton %>" />
            <asp:Parameter Name="CartonReserveArea" Type="String" DbType="String" DefaultValue="<%$ AppSettings:CartonReserveArea %>" />
            <asp:Parameter Name="RestockingArea" Type="String" DbType="String" DefaultValue="<%$ AppSettings:RestockingArea %>" />
            <asp:Parameter Name="BoxpickModuleCode" Type="String" DbType="String" DefaultValue="<%$ AppSettings:BoxpickModuleCode %>" />
            <asp:Parameter Name="SkuTypeStorageArea" Type="String" DbType="String" DefaultValue="<%$ AppSettings:SkuTypeStorageArea %>" />
            <asp:Parameter Name="ShipDocBoxArea" Type="String" DbType="String" DefaultValue="<%$ AppSettings:ShipDocBoxArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        DataSourceID="ds" ShowFooter="true" DefaultSortExpression="MIN_PULLBACK_QUANTITY {0:I};style;color;dimension;sku_size"
        OnPreRender="gv_PreRender">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="Vwh" SortExpression="VWH_ID" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size" />
            <eclipse:MultiBoundField DataFields="LABEL_ID" HeaderText="Label" SortExpression="LABEL_ID" />
            <eclipse:MultiBoundField DataFields="ordered_quantity" HeaderText="Ordered Pieces" AccessibleHeaderText="picked_pieces"/>
            <eclipse:MultiBoundField DataFields="shortage" HeaderText="Shortage" SortExpression="shortage"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField HeaderText="Min Pull Back Quantity|CFD" DataFields="MIN_PULLBACK_QUANTITY"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" AccessibleHeaderText="CfdPullBackQuantity"
                Visible="false" HeaderToolTip="Min Pullback Quantity" SortExpression="MIN_PULLBACK_QUANTITY {0:I}">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField HeaderText="Min Pull Back Quantity|OUT" DataFields="MIN_PULLBACK_QUANTITY"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" AccessibleHeaderText="OutPullBackQuantity"
                Visible="false"  HeaderToolTip="Min Pullback Quantity" SortExpression="MIN_PULLBACK_QUANTITY {0:I}">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

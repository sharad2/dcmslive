<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Non China Inventory in FDC" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5646 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_30.aspx $
 *  $Id: R130_30.aspx 5646 2013-07-15 12:07:18Z skumar $
 * Version Control Template Added.
 *
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
        foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["AREA_WAREHOUSE_LOCATION_ID_XML"] != DBNull.Value))
        {
            var items = XElement.Parse((string)row["AREA_WAREHOUSE_LOCATION_ID_XML"]).Elements("item");
            foreach (var item in items)
            {
                var field = ParsePivotItem(data.Table, row, item);
                if (field != null)
                {
                    list.Add(field);
                }
            }
        }
        var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "Qlty"));
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
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA").First().Value;
    var buildingId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
    var qty = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "QUANTITY").First().Value;
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
            retVal = bf;

        }

        row[colName] = pieces;
    }
    return retVal;


    }
 
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Displays detail of all the inventory 
                                        within carton area which has not been received from china. It only considers the inventory 
                                        for which there is no current order and is not in suspense." />
    <meta name="ReportId" content="130.30" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_30.aspx 5646 2013-07-15 12:07:18Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="Style" />
                <i:TextBoxEx ID="tbStyle" runat="server">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Color" />
                <i:TextBoxEx ID="tbColor" runat="server" />
                <eclipse:LeftLabel runat="server" Text="Dimension" />
                <i:TextBoxEx ID="tbDimension" runat="server" />
                <eclipse:LeftLabel runat="server" Text="SKU Size" />
                <i:TextBoxEx ID="tbSkuSize" runat="server" />
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
         DataSourceMode="DataSet">
        <SelectSql>
 WITH FINAL_QUERY AS
 (SELECT CTN.SEWING_PLANT_CODE AS SEWING_PLANT_CODE,
         TIA.SHORT_NAME AS AREA,
         CTN.VWH_ID AS VWH_ID,
         SUM(CASE
               WHEN TIA.LOCATION_NUMBERING_FLAG = 'Y' AND
                    CTNDET.REQ_MODULE_CODE IS NULL AND CTN.SUSPENSE_DATE IS NULL THEN
                CTNDET.QUANTITY
               WHEN TIA.LOCATION_NUMBERING_FLAG IS NULL THEN
                CTNDET.QUANTITY
             END) AS QUANTITY,
         MSKU.STYLE AS STYLE,
         MSKU.COLOR AS COLOR,
         MSKU.DIMENSION AS DIMENSION,
         MSKU.SKU_SIZE AS SKU_SIZE,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS WAREHOUSE_LOCATION_ID,
         CTN.quality_code AS quality_code
    FROM SRC_CARTON CTN
   INNER JOIN SRC_CARTON_DETAIL CTNDET
      ON CTNDET.CARTON_ID = CTN.CARTON_ID
   INNER JOIN MASTER_SKU MSKU
      ON MSKU.SKU_ID = CTNDET.SKU_ID
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON TIA.INVENTORY_STORAGE_AREA = CTN.CARTON_STORAGE_AREA
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON CTN.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
     AND CTN.LOCATION_ID = MSL.LOCATION_ID
   WHERE TIA.STORES_WHAT = 'CTN'
     AND CTN.SEWING_PLANT_CODE NOT IN
         (SELECT DISTINCT (RESV.SEWING_PLANT_CODE) AS SEWING_PLANT_CODE
            FROM CUSTCTNRESV RESV)
     AND MSKU.STYLE = :style
   <if>AND MSKU.color = :color</if>
 <if>AND MSKU.dimension = :dimension</if>
 <if>AND MSKU.SKU_SIZE = :sku_size</if>
 <if>AND CTN.vwh_id = :vwh_id</if>
   GROUP BY CTN.SEWING_PLANT_CODE,
            TIA.SHORT_NAME,
            CTN.VWH_ID,
            MSKU.STYLE,
            MSKU.COLOR,
            MSKU.DIMENSION,
            MSKU.SKU_SIZE,
            COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                     MSL.WAREHOUSE_LOCATION_ID,
                     'Unknown'),
            CTN.quality_code)
SELECT *
  FROM FINAL_QUERY PIVOT XML(SUM(QUANTITY) AS QUANTITY FOR(AREA, WAREHOUSE_LOCATION_ID) IN(ANY,
                                                                                           ANY))

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbStyle" Direction="Input" Type="String" Name="style" />
            <asp:ControlParameter ControlID="tbColor" Direction="Input" Type="String" Name="color" />
            <asp:ControlParameter ControlID="tbDimension" Direction="Input" Type="String" Name="dimension" />
            <asp:ControlParameter ControlID="tbSkuSize" Direction="Input" Type="String" Name="sku_size" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="STYLE;COLOR;DIMENSION;SKU_SIZE;quality_code;VWH_ID;SEWING_PLANT_CODE">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" SortExpression="VWH_ID" HeaderText="VWh"
                HeaderToolTip="Virtual Warehoue" />
            <eclipse:MultiBoundField DataFields="SEWING_PLANT_CODE" SortExpression="SEWING_PLANT_CODE"
                HeaderText="Sewing Plant<br /> Code" HeaderToolTip="Sewing Plant where inventory coming from" />
            <eclipse:MultiBoundField DataFields="STYLE" SortExpression="STYLE" HeaderText="Style"
                HeaderToolTip="SKU Style" />
            <eclipse:MultiBoundField DataFields="COLOR" SortExpression="COLOR" HeaderText="Color"
                HeaderToolTip="SKU Color" />
            <eclipse:MultiBoundField DataFields="DIMENSION" SortExpression="DIMENSION" HeaderText="Dim."
                HeaderToolTip="SKU Dimension" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" SortExpression="SKU_SIZE" HeaderText="Size"
                HeaderToolTip="SKU Size" />
            <eclipse:MultiBoundField DataFields="quality_code" SortExpression="quality_code"
                HeaderText="Quality" HeaderToolTip="Quality Code" AccessibleHeaderText="Qlty"/>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

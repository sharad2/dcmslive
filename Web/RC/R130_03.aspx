<%@ Page Title=" FPK Inventory Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4259 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R130_03.aspx $
 *  $Id: R130_03.aspx 4259 2012-08-17 11:08:53Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        ds.PostSelected += new EventHandler<PostSelectedEventArgs>(ds_PostSelected);
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
            foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["area_xml"] != DBNull.Value))
            {
                var items = XElement.Parse((string)row["area_xml"]).Elements("item");
                foreach (var item in items)
                {
                    var field = ParsePivotItem(data.Table, row, item);
                    if (field != null)
                    {
                        list.Add(field);
                    }
                }
            }
            var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "FPKqty"));
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

        }
    }
    private static DataControlField ParsePivotItem(System.Data.DataTable tbl, System.Data.DataRowView row, XElement pivotItem)
    {
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "SHORT_NAME").First().Value;
        var buildingId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
        var qty = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "QUANTITY").First().Value;
        var colName = string.Format("{0}_{1}", areaId, buildingId);
        var col = tbl.Columns[colName];
        int pieces;
        DataControlField retVal = null;
        if (int.TryParse(qty, out pieces) && pieces > 0)
        {
            if (col == null && !string.IsNullOrEmpty(areaId))
            {
                col = tbl.Columns.Add(colName, typeof(int));
                var bf = new BoundField
                {
                    HeaderText = string.Format("Pieces in {0}|{1}", buildingId, areaId),
                    DataField = colName,
                    DataFormatString = "{0:N0}",
                    AccessibleHeaderText = string.Format("{0},{1}", buildingId, areaId),
                };
                bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                retVal = bf;
            }
            row[colName] = pieces;
        }
        return retVal;

    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report lists Picking area inventory for passed label, it will also show the quantity in different carton areas irrespective of building for passed label. It will not consider cartons which are in suspense. " />
    <meta name="ReportId" content="130.03" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_03.aspx 4259 2012-08-17 11:08:53Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" />
                <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label" QueryString="label_id" ToolTip="Select any label to see the order." />
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" />
                <d:BuildingSelector FriendlyName="Building" runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="false" ToolTip="Please Select building " ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                    <Items>
                    <eclipse:DropDownItem Value="" Text="(Please Select)" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Required ClientMessage="Please select any Building" />
                    </Validators>
                    </d:BuildingSelector>
                    </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        DataSourceMode="DataSet">
        <SelectSql>
WITH ialoc_sku AS (
SELECT MSKU.SKU_ID AS SKU_ID,
       L.VWH_ID AS VWH_ID,
       LC.IA_ID as area,
       L.WAREHOUSE_LOCATION_ID AS Building,
       MIN(LC.LOCATION_ID) AS MIN_LOCATION_ID,
       MAX(LC.LOCATION_ID) AS MAX_LOCATION_ID,
       COUNT(DISTINCT LC.LOCATION_ID) AS COUNT_LOCATION_ID,
       MAX(LC.IACONTENT_ID) UPC_CODE,
       MAX(MSKU.STYLE) STYLE,
       MAX(MSKU.COLOR) COLOR,
       MAX(MSKU.DIMENSION) DIMENSION,
       MAX(MSKU.SKU_SIZE) SKU_SIZE,
       SUM(LC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS,
       SUM(NVL(L.ASSIGNED_UPC_MAX_PIECES, MSKU.PIECES_PER_RAIL)) AS CAPACITY
  FROM IALOC_CONTENT LC
 INNER JOIN IALOC L
    ON LC.IA_ID = L.IA_ID
   AND LC.LOCATION_ID = L.LOCATION_ID
 INNER JOIN MASTER_SKU MSKU
    ON LC.IACONTENT_ID = MSKU.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MSTYLE
    ON MSKU.STYLE = MSTYLE.STYLE
 WHERE LC.IA_ID &lt;&gt; 'SSS'
   AND LC.IACONTENT_TYPE_ID = 'SKU'
   <if>AND L.VWH_ID = :vwh_id</if>
   <if>AND MSTYLE.LABEL_ID = :label_id</if>
   <if>AND l.warehouse_location_id = :warehouse_location_id</if>
 GROUP BY MSKU.SKU_ID, L.VWH_ID,LC.IA_ID, L.WAREHOUSE_LOCATION_ID
HAVING SUM(LC.NUMBER_OF_UNITS) &gt; 0),
carton_sku AS (SELECT *
    from (SELECT MSKU.sku_id              AS sku_id,
                 c.vwh_id              AS vwh_id,
                 tia.SHORT_NAME as SHORT_NAME,
                 COALESCE(TIA.WAREHOUSE_LOCATION_ID,MSL.WAREHOUSE_LOCATION_ID,'Unknown') AS WAREHOUSE_LOCATION_ID,
                 d.quantity            as quantity
            from src_carton c
           INNER JOIN src_carton_detail d
              on c.carton_id = d.carton_id
            LEFT OUTER JOIN MASTER_SKU MSKU
                 ON D.SKU_ID = MSKU.SKU_ID
            LEFT OUTER JOIN MASTER_STYLE MS
                 ON MSKU.STYLE = MS.STYLE
           left outer join master_storage_location msl
              on msl.storage_area = c.carton_storage_area
             and msl.location_id = c.location_id
           left outer join tab_inventory_area tia on 
             c.carton_storage_area = tia.inventory_storage_area
             WHERE C.suspense_date IS NULL
              <if>AND C.vwh_id = :vwh_id</if>
              <if>and ms.label_id = :label_id</if>
             )
          pivot XML(SUM(quantity) as quantity for(SHORT_NAME, WAREHOUSE_LOCATION_ID) in(ANY, ANY))
)
SELECT ISKU.SKU_ID AS SKU_ID,
       isku.vwh_id as vwh_id,
       ISKU.STYLE AS STYLE,
       ISKU.COLOR AS COLOR,
       ISKU.DIMENSION AS DIMENSION,
       ISKU.SKU_SIZE AS SKU_SIZE,
       ISKU.CAPACITY AS CAPACITY,
       ISKU.MIN_LOCATION_ID AS MIN_LOCATION_ID,
       ISKU.MAX_LOCATION_ID AS MAX_LOCATION_ID,
       ISKU.COUNT_LOCATION_ID AS COUNT_LOCATION_ID,
       ISKU.NUMBER_OF_UNITS AS NUMBER_OF_UNITS,
       ISKU.UPC_CODE AS UPC_CODE,
       isku.area as area,
       CSKU.SHORT_NAME_WAREHOUSE_LOCAT_XML AS area_xml
       FROM ialoc_sku ISKU
LEFT OUTER JOIN carton_sku CSKU ON
ISKU.SKU_ID = CSKU.SKU_ID
and isku.vwh_id = csku.vwh_id
<%--where rownum &lt; = 1100--%>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ls" Name="label_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <asp:TemplateField HeaderText="Location" HeaderStyle-Wrap="false" SortExpression="MIN_LOCATION_ID">
                <ItemTemplate>
                    <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LOCATION_ID,MIN_LOCATION_ID,MAX_LOCATION_ID" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="UPC_CODE" HeaderText="UPC" SortExpression="UPC_CODE" />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" />
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim" SortExpression="DIMENSION" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE" />
            <eclipse:MultiBoundField DataFields="CAPACITY" ItemStyle-HorizontalAlign="Right"
                HeaderText="Capacity" SortExpression="CAPACITY" />
                 <m:MatrixField DataHeaderFields="area" HeaderStyle-Wrap="false" DataCellFields="NUMBER_OF_UNITS" AccessibleHeaderText="FPKqty"
                DataMergeFields="SKU_ID"  HeaderText="Pickin Area Quantity">
            </m:MatrixField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

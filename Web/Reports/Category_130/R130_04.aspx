<%@ Page Title="Aging of Inactive SKU in Picking area" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6026 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_04.aspx $
 *  $Id: R130_04.aspx 6026 2013-08-29 11:28:07Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">

    //protected override void OnInit(EventArgs e)
    //{
    //    ds.PostSelected += new EventHandler<PostSelectedEventArgs>(ds_PostSelected);
    //    base.OnInit(e);
    //}


    ///// <summary>
    ///// 
    ///// </summary>
    ///// <param name="sender"></param>
    ///// <param name="e"></param>
    ///// <remarks>
    ///// <para>
    ///// This is the XML we ar trying to parse.
    ///// </para>
    ///// <code>
    ///// <![CDATA[
    ///// <PivotSet>
    ///// <item>
    ///// <column name = "CARTON_STORAGE_AREA">BIR</column>
    ///// <column name = "WAREHOUSE_LOCATION_ID">FDC</column>
    ///// <column name = "QUANTITY">576</column>
    ///// </item>
    ///// <item>
    ///// <column name = "CARTON_STORAGE_AREA">BIR</column>
    ///// <column name = "WAREHOUSE_LOCATION_ID">FDC1</column>
    ///// <column name = "QUANTITY">972</column>
    ///// </item>
    ///// </PivotSet>
    ///// ]]>
    ///// </code>
    ///// </remarks>
    //void ds_PostSelected(object sender, PostSelectedEventArgs e)
    //{
    //    var data = (System.Data.DataView)e.Result;
    //    if (data != null)
    //    {
    //        var oldCount = gv.Columns.Count;
    //        foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["area_xml"] != DBNull.Value))
    //        {
    //            var items = XElement.Parse((string)row["area_xml"]).Elements("item");
    //            foreach (var item in items)
    //            {
    //                var areaId = item.Elements("column").Where(p => p.Attribute("name").Value == "CARTON_STORAGE_AREA").First().Value;
    //                var buildingId = item.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
    //                string colName;
    //                if (string.IsNullOrEmpty(buildingId))
    //                {
    //                    colName = areaId;
    //                }
    //                else
    //                {
    //                    colName = string.Format("{0}", areaId, buildingId);
    //                }
    //                var qty = item.Elements("column").Where(p => p.Attribute("name").Value == "QUANTITY").First().Value;
    //                var col = data.Table.Columns[colName];
    //                if (col == null)
    //                {
    //                    col = data.Table.Columns.Add(areaId, typeof(int));
    //                    var bf = new BoundField
    //                    {
    //                        HeaderText = string.Format("Pieces in {0}|{1}", buildingId, areaId),
    //                        DataField = areaId,
    //                        DataFormatString = "{0:N0}"
    //                    };
    //                    bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
    //                    gv.Columns.Add(bf);
    //                }
    //                row[areaId] = qty;
    //            }
    //        }

    //        if (oldCount == gv.Columns.Count)
    //        {
    //            divInfo.Visible = true;// No column was added to the grid
    //        }
    //    }
    //}

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
            var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "Units"));
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
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "CARTON_STORAGE_AREA").First().Value;
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
    <meta name="ReportId" content="130.04" />
    <meta name="Description" content="The report displays forward pick area locations which have not been touched within the specified time period.
     It lists SKUs at these locations and when the location was last touched. For each SKU, it lists the availability in various carton areas to building wise." />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_04.aspx 6026 2013-08-29 11:28:07Z skumar $" />
    <meta name="ChangeLog" content="Showing areas along with their building.|Now, Report is displaying building column as master column." />
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
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
             <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Building" />
                    <oracle:OracleDataSource ID="dsbuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
                        DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsbuilding" FriendlyName="Building"
                        QueryString="building">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>

            </asp:Panel>
            <eclipse:TwoColumnPanel ID="tcp" runat="server"> 
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Inactive SKUs in Picking area" />
                <i:TextBoxEx ID="tbDays" runat="server" Text="4" FriendlyName="Weeks" MaxLength="4" ToolTip="Enter the number of days from today to display the Inactive SKUs in FPK area.">
                    <Validators>
                        <i:Value ValueType="Integer" Max="2000" Min="0" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                weeks
                <br />
                A location is considered to be inactive if pieces have not been added or removed from the
                location.
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Exclude highly inactive locations" />
                <d:BusinessDateTextBox ID="dtExcludeTouchedBefore" runat="server"  />
                <br />
                This is useful if you have some locations which are rarely used. E.g. if you 
                 are not interested in locations which have been constantly inactive since 2007,
                 enter 1/12/2007 here.
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" />
                <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" FriendlyName="Label" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>"
                    ToolTip="Select the label to find the inactive SKUs lying in FPK area for a given days from today along with label details.(Optional)" />
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwhId" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>"
                    ToolTip="Select any virtual warehouse Id (optional)." />
                <eclipse:LeftLabel runat="server" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" CancelSelectOnNullParameter="true"
        DataSourceMode="DataSet">
        <SelectSql>
        with location_skus as
(SELECT  
ROW_NUMBER() OVER(ORDER BY LEAST(MIN(lc.LAST_UNITS_REMOVED_DATE), MIN(lc.LAST_UNITS_ADDED_DATE))) as row_number,
MSKU.sku_id AS sku_id,
         l.VWH_ID AS VWH_ID,
         NVL(l.warehouse_location_id,'Unknown') as warehouse_location_id,
         MIN(lc.LOCATION_ID) as min_LOCATION_ID,
         MAX(lc.LOCATION_ID) as max_LOCATION_ID,
         COUNT(lc.LOCATION_ID) as count_LOCATION_ID,
         max(lc.IACONTENT_ID) IACONTENT_ID,
         MAX(MSKU.STYLE) STYLE,
         MAX(MSKU.COLOR) COLOR,
         MAX(MSKU.DIMENSION) DIMENSION,
         MAX(MSKU.SKU_SIZE) SKU_SIZE,
         MAX(MSTYLE.LABEL_ID) LABEL_ID,
         SUM(lc.NUMBER_OF_UNITS) as NUMBER_OF_UNITS,
         max(l.assigned_upc_code) as assigned_upc_code,
         MAX(lc.LAST_UNITS_REMOVED_DATE) LAST_PICK_DATE,
         MAX(lc.LAST_UNITS_ADDED_DATE) LAST_ADDED_DATE,
         MAX(GREATEST(NVL(lc.LAST_UNITS_REMOVED_DATE, lc.LAST_UNITS_ADDED_DATE), NVL(lc.LAST_UNITS_ADDED_DATE, lc.LAST_UNITS_REMOVED_DATE))) as touch_date
    FROM IALOC_CONTENT lc
   INNER JOIN IALOC l
      ON lc.IA_ID = l.IA_ID
     AND lc.LOCATION_ID = l.LOCATION_ID
   INNER JOIN MASTER_SKU MSKU
      ON lc.IACONTENT_ID = MSKU.UPC_CODE
    LEFT OUTER JOIN MASTER_STYLE MSTYLE
      ON MSKU.STYLE = MSTYLE.STYLE
   inner JOIN ia ia
      ON lc.ia_id = ia.ia_id
   WHERE ia.picking_area_flag = 'Y'
     AND lc.IACONTENT_TYPE_ID = 'SKU'
     AND l.location_type = 'RAIL'
     <if>AND (SYSDATE - GREATEST(NVL(lc.LAST_UNITS_REMOVED_DATE, lc.LAST_UNITS_ADDED_DATE), NVL(lc.LAST_UNITS_ADDED_DATE, lc.LAST_UNITS_REMOVED_DATE))) &gt;= (:Days *7)</if>
     <if>AND GREATEST(NVL(lc.LAST_UNITS_REMOVED_DATE, lc.LAST_UNITS_ADDED_DATE), NVL(lc.LAST_UNITS_ADDED_DATE, lc.LAST_UNITS_REMOVED_DATE)) &gt;= CAST(:exclude_touched_before AS DATE)</if>
     <if>AND l.vwh_id = :vwh_id</if>
     <if>AND MSTYLE.label_id = :label_id</if> 
     <%--<if>AND l.warehouse_location_id = :warehouse_location_id</if>--%>
    <if>AND <a pre="l.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   GROUP BY MSKU.sku_id, l.VWH_ID, NVL(l.warehouse_location_id,'Unknown')
   HAVING SUM(lc.NUMBER_OF_UNITS) &gt; 0
   ),

pivot_carton_sku AS
(select *
    from (SELECT d.sku_id              AS sku_id,
                 c.vwh_id              AS vwh_id,
                 TIA.SHORT_NAME AS CARTON_STORAGE_AREA,
                 NVL(NVL(tia.warehouse_location_id, msl.warehouse_location_id),'Unknown') as warehouse_location_id,
                 d.quantity            as quantity
            from src_carton c
           INNER JOIN src_carton_detail d
              on c.carton_id = d.carton_id
           left outer join master_storage_location msl
              on msl.storage_area = c.carton_storage_area
             and msl.location_id = c.location_id
           left outer join tab_inventory_area tia on 
             c.carton_storage_area = tia.inventory_storage_area
             )
          pivot XML(SUM(quantity) as quantity for(carton_storage_area, WAREHOUSE_LOCATION_ID) in(ANY, ANY)))
select s.vwh_id,
       s.warehouse_location_id   as warehouse_location_id,
       s.min_location_id         AS min_location_id,
       s.max_location_id         AS max_location_id,
       s.count_location_id       AS count_location_id,
       s.iacontent_id            AS iacontent_id,
       s.style                   AS style,
       s.color                   AS color,
       s.dimension               AS dimension,
       s.sku_size                AS sku_size,
       s.touch_date AS touch_date,
       s.LAST_PICK_DATE as LAST_PICK_DATE,
       s.LAST_ADDED_DATE as LAST_ADDED_DATE,
       s.label_id                AS label_id,
       s.NUMBER_OF_UNITS         AS NUMBER_OF_UNITS,
       s.assigned_upc_code       AS assigned_upc_code,
       q.carton_storage_area_wareho_xml AS area_xml
  from location_skus s
  LEFT OUTER JOIN pivot_carton_sku q
    on s.sku_id = q.sku_id
   AND s.vwh_id = q.vwh_id
   where s.row_number &lt;= 1000
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="tbDays" Name="Days" Type="Int32"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtExcludeTouchedBefore" Name="exclude_touched_before"
                Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="ls" Name="label_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwhId" Name="vwh_id" Type="String" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div style="padding: 1em 0em 1em 1em; font-style:italic" runat="server" id="divInfo" visible="false">
        Carton areas are not being displayed because none of these Skus exist in any Carton area.
    </div>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="warehouse_location_id;$;touch_date;vwh_id;min_location_id"
        AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true" ShowExpandCollapseButtons="false"
        Caption="Max 1000 most inactive locations are displayed">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="touch_date" HeaderText="Touch Date" SortExpression="touch_date"
                DataFormatString="{0:d}" ToolTipFields="LAST_PICK_DATE,LAST_ADDED_DATE"
                ToolTipFormatString="Picked: {0:d}; Added: {1:d}" />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building" SortExpression="warehouse_location_id"
                HeaderToolTip="Warehouse Location ID"/>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual Warehouse"/>
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"/>
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"/>
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"/>
            <eclipse:MultiBoundField DataFields="assigned_upc_code" HeaderText="Assigned UPC"
                SortExpression="assigned_upc_code"/>
            <asp:TemplateField HeaderText="Location" HeaderStyle-Wrap="false" SortExpression="min_location_id">
                <ItemTemplate>
                    <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="count_location_id,min_location_id,max_location_id" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"/>
            <eclipse:MultiBoundField DataFields="NUMBER_OF_UNITS" HeaderText="Pieces at Location"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                SortExpression="NUMBER_OF_UNITS" AccessibleHeaderText="Units">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

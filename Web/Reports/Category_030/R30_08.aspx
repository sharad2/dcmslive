<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Inventory Summary report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6251 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_030/R30_08.aspx $
 *  $Id: R30_08.aspx 6251 2013-11-08 08:51:39Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        ds.PostSelected += new EventHandler<PostSelectedEventArgs>(ds_PostSelected);
        base.OnInit(e);
    }
    void ds_PostSelected(object sender, PostSelectedEventArgs e)
    {
        var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "building"));
        var data = (System.Data.DataView)e.Result;
        if (data != null)
        {
            var oldCount = gv.Columns.Count;
            foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["VWH_ID_xml"] != DBNull.Value))
            {
                var items = XElement.Parse((string)row["VWH_ID_xml"]).Elements("item");
                int total = 0;
                foreach (var item in items)
                {
                    var vwhId = item.Elements("column").Where(p => p.Attribute("name").Value == "VWH_ID").First().Value;
                    var quantity = item.Elements("column").Where(p => p.Attribute("name").Value == "TOTAL_QUANTITY").First().Value;
                    total = total + Convert.ToInt32(quantity);
                    var col = data.Table.Columns[vwhId];
                    if (col == null)
                    {
                        col = data.Table.Columns.Add(vwhId, typeof(int));
                        var bf = new SiteHyperLinkField
                        {
                            
                            DataTextField = vwhId,
                            DataTextFormatString = "{0:N0}",
                            DataNavigateUrlFields = new[] { "area_id", "warehouse_location_id", "area_type" },
                            HeaderText = string.Format("Pieces in| {0}", vwhId),
                            DataNavigateUrlFormatString = string.Format("R130_15.aspx?area_id={{0}}&warehouse_location_id={{1}}&show_all_pieces=Y&Vwh_Id={0}&quality_code={1}", vwhId, ddlQualityCode.Value),
                            AccessibleHeaderText = "Pieces",
                            DataSummaryCalculation=  SummaryCalculationType.ValueSummation 
                             
                        };
                        bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                        ++index;
                        gv.Columns.Insert(index, bf);
                    }
                    row[vwhId] = quantity;
                }
             
            }


        }
    }
    protected void gv_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                var area_type = (string)DataBinder.Eval(e.Row.DataItem, "area_type");
                if (area_type == "SKU")
                {
                    foreach (var cell in e.Row.Cells.Cast<DataControlFieldCell>().Where(p => p.ContainingField.AccessibleHeaderText == "Pieces"))
                    {
                        var SkuAreaCell = cell.Controls.OfType<HyperLink>().FirstOrDefault();
                        if (!string.IsNullOrEmpty(SkuAreaCell.ToString()))
                        {
                            SkuAreaCell.NavigateUrl = SkuAreaCell.NavigateUrl.Replace("Category_130/R130_15","Category_030/R30_03");
                        }
                       
                    }
                }
                break;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays the consolidated inventory totals in various storage areas of the Distribution Center along with the Virtual Warehouse and Building." />
    <meta name="ReportId" content="30.08" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R30_08.aspx 6251 2013-11-08 08:51:39Z skumar $" />
    <meta name="ChangeLog" content="Showing areas along with their building.|In case of no Building against any area,then we show 'Unknown' as building of that area.|This report using only quality code parameter for run the report instead of building and vwh-id.|Report output change , report is not  showing quality code column in the grid." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filter">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="lblQuality" runat="server" Text="Inventory Quality" />
                <oracle:OracleDataSource ID="dsQuality" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                            select tqc.quality_code as qualitycode ,
                            tqc.description as qualitydescription
                            from tab_quality_code tqc
                            order by tqc.quality_rank asc
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlQualityCode" runat="server" DataSourceID="dsQuality" DataFields="qualitycode,qualitydescription"
                    DataTextFormatString="{0}:{1}" DataValueFormatString="{0}" QueryString="quality_code">
                    <Items>
                        <eclipse:DropDownItem Text="(Please Select)" Value="" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        DataSourceMode="DataSet">
        <SelectSql>
          with q1 AS
 (SELECT skuinv.sku_storage_area AS area_id,
         tabinv.short_name AS  short_area,
         skuinv.quantity AS total_quantity,
        sum(skuinv.quantity) over(partition by skuinv.sku_storage_area,nvl(tabinv.warehouse_location_id, 'Unknown')) as totalqty,
         skuinv.vwh_id AS vwh_id,
         tabinv.stores_what AS area_type,
         nvl(tabinv.warehouse_location_id, 'Unknown') AS warehouse_location_id,
         skuinv.quality_code as quality_code
    FROM master_raw_inventory skuinv
    LEFT OUTER JOIN tab_inventory_area tabinv
      ON tabinv.Inventory_Storage_Area = skuinv.sku_storage_area
   WHERE tabinv.stores_what = 'SKU'
     and tabinv.Unusable_Inventory IS NULL
     <if>and skuinv.quality_code=:quality_code </if>   
     and skuinv.quantity &lt;&gt; 0
  UNION ALL
  SELECT ctn.carton_storage_area as area_id,
         tabinv.short_name AS short_area,
         ctndet.quantity AS total_quantity,
         sum(ctndet.quantity) over(partition by ctn.carton_storage_area, COALESCE(tabinv.WAREHOUSE_LOCATION_ID, msloc.WAREHOUSE_LOCATION_ID,'Unknown')) as totalqty,
         ctn.vwh_id AS vwh_id,
         tabinv.stores_what AS area_type,
         COALESCE(tabinv.WAREHOUSE_LOCATION_ID, msloc.WAREHOUSE_LOCATION_ID,
             'Unknown') AS warehouse_location_id,
         ctn.quality_code as quality_code
    FROM src_carton_detail ctndet
   INNER JOIN src_carton ctn
      ON ctn.carton_id = ctndet.carton_id
    LEFT OUTER JOIN master_storage_location msloc
      ON ctn.carton_storage_area = msloc.storage_area
     AND ctn.location_id = msloc.location_id
    left outer JOIN tab_inventory_area tabinv
      ON tabinv.inventory_storage_area = ctn.carton_storage_area
      where ctn.quality_code=:quality_code
      )
select *
  from q1 pivot XML(SUM(total_quantity) as total_quantity FOR(vwh_id) in(ANY))

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input"
                Name="quality_code" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="warehouse_location_id;$;short_area"
        OnRowDataBound="gv_OnRowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="short_area" HeaderText="Area" SortExpression="short_area">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                SortExpression="warehouse_location_id" HeaderToolTip="Warehouse Location of the SKUs" AccessibleHeaderText="building">
            </eclipse:MultiBoundField>
             <eclipse:MultiBoundField DataFields="totalqty" HeaderText="Total"
                SortExpression="totalqty" HeaderToolTip="This column dispalys total quantity per building and area." DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

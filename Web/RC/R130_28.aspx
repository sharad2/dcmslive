<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKUs In Shortage And Pullback Quantity (ANX3)" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4268 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R130_28.aspx $
 *  $Id: R130_28.aspx 4268 2012-08-18 06:20:48Z skumar $
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
        var data = (System.Data.DataView)e.Result;
        if (data == null)
        {
            return;
        }
        var list = new List<DataControlField>();
        foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["inventory_area_inventory_b_xml"] != DBNull.Value))
        {
            var items = XElement.Parse((string)row["inventory_area_inventory_b_xml"]).Elements("item");
            foreach (var item in items)
            {
                var field = ParsePivotItem(data.Table, row, item);
                if (field != null)
                {
                    list.Add(field);
                }
            }
        }
        var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "label_id"));

        //var multipleQualities = list.Select(p => p.AccessibleHeaderText.Split(',')[1]).Distinct().Count(p => !string.IsNullOrEmpty(p)) > 1;

        var addedColumns = from col in list
                           let tokens = col.AccessibleHeaderText.Split(',')
                           let building = tokens[0]
                           let quality = tokens[1]
                           let areaId = tokens[2]
                           let areaName = tokens[3]
                           orderby building, areaId
                           select new
                           {
                               Column = col,
                               Quality = quality,
                               AreaId = areaId,
                               AreaName=areaName,
                               Building = building,
                               HeaderText = string.Format("Pieces in {0}|{1}", building, areaName)
                           };


        // First display inventory of selected building
        // AccessibleHeaderText was set to building above
        foreach (var col in addedColumns.Where(p => p.Building == ctlWhLoc.Value && p.AreaId != "BOXES"))
        {

            col.Column.HeaderText = col.HeaderText;

            if (ctlAvailableInventoryArea.Value.Contains(col.AreaId))
            {
                col.Column.ItemStyle.BackColor = System.Drawing.Color.LightGreen;
            }

            if (ctlPullableInventoryArea.Value.Count() == 0 && !ctlAvailableInventoryArea.Value.Contains(col.AreaId))
            {
                col.Column.ItemStyle.BackColor = System.Drawing.Color.Yellow;

            }
            if (ctlPullableInventoryArea.Value.Contains(col.AreaId))
            {
                col.Column.ItemStyle.BackColor = System.Drawing.Color.Yellow;
            }


            ++index;
            gv.Columns.Insert(index, col.Column);

        }
        // Then display inventory of other buildings
        index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "shortage"));
        foreach (var col in addedColumns.Where(p => p.Building != ctlWhLoc.Value))
        {

            ++index;
           
            if (ctlAvailableInventoryArea.Value.Contains(col.AreaId))
            {
                col.Column.ItemStyle.BackColor = System.Drawing.Color.LightGreen;
            }

            if (ctlPullableInventoryArea.Value.Count() == 0 && !ctlAvailableInventoryArea.Value.Contains(col.AreaId))
            {
                col.Column.ItemStyle.BackColor = System.Drawing.Color.Yellow;

            }
            if (ctlPullableInventoryArea.Value.Contains(col.AreaId))
            {
                col.Column.ItemStyle.BackColor = System.Drawing.Color.Yellow;
            }
            col.Column.HeaderText = col.HeaderText;
            gv.Columns.Insert(index, col.Column);
        }
    }

    private static DataControlField ParsePivotItem(System.Data.DataTable tbl, System.Data.DataRowView row, XElement pivotItem)
    {
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "INVENTORY_AREA").First().Value;
        var areaName = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA_NAME").First().Value;
        var buildingId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "INVENTORY_BUILDING_ID").First().Value;
        var quality = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "QUALITY").First().Value;
        var area_type = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA_TYPE").First().Value;
        var colName = string.Format("{0}_{1}_{2}", areaName, buildingId, quality);

        var qty = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "PIECES_IN_AREA").First().Value;
        DataControlField retVal = null;
        if(!string.IsNullOrEmpty(areaName))
        {
        var col = tbl.Columns[colName];
        int pieces;

        if (int.TryParse(qty, out pieces) && pieces > 0)
        {
            if (col == null && !string.IsNullOrEmpty(areaName))
            {
                col = tbl.Columns.Add(colName, typeof(int));
                string reportUrl;
                if (string.IsNullOrEmpty(buildingId))
                {
                    reportUrl = string.Format("R40_24.aspx?style={{0}}&color={{1}}&dimension={{2}}&sku_size={{3}}&vwh_Id={{4}}&area={0}&quality_code={1}&building_id=Unknown&showunresvpieces=Y", areaId, quality);
                }
                else
                {
                    reportUrl = string.Format("R40_24.aspx?style={{0}}&color={{1}}&dimension={{2}}&sku_size={{3}}&vwh_Id={{4}}&area={0}&quality_code={1}&building_id={2}&showunresvpieces=Y", areaId, quality
                    , buildingId);
                }
                if (area_type == "CTN")
                {
                    var bf = new SiteHyperLinkField
                    {
                        //DataFields = new[] { colName },
                        DataTextField = colName,
                        DataTextFormatString = "{0:N0}",
                        // Used when we determine which building this column belongs to
                        AccessibleHeaderText = string.Format("{0},{1},{2},{3}", buildingId, quality, areaId,areaName),
                        HeaderToolTip = string.Format("Area {0} - Quality {1}", areaName, quality),
                        DataNavigateUrlFields = new[] { "style", "color", "dimension", "sku_size", "vwh_id" },

                        DataNavigateUrlFormatString = reportUrl,
                    };
                    bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                    //list.Add(bf);
                    retVal = bf;
                }
                else
                {
                    var bf = new SiteHyperLinkField
                    {
                        //DataFields = new[] { colName },
                        DataTextField = colName,
                        DataTextFormatString = "{0:N0}",
                        // Used when we determine which building this column belongs to
                        AccessibleHeaderText = string.Format("{0},{1},{2},{3}", buildingId, quality, areaId,areaName),
                        HeaderToolTip = string.Format("Area {0} - Quality {1}", areaName, quality),
                        DataNavigateUrlFields = new[] { "upc_code", "vwh_id" },

                        DataNavigateUrlFormatString = string.Format("R130_106.aspx?UPC={{0}}&vwh_id={{1}}&area={0}&showunresvpieces=Y", areaId),

                    };
                    bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                    //list.Add(bf);
                    retVal = bf;
                }
            }
            row[colName] = pieces;
        }
        
        }
        return retVal;
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
    protected void ctlPullableInventoryArea_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (string.IsNullOrEmpty(ctlWhLoc.Value) && string.IsNullOrEmpty(ctlVwh.Value) && string.IsNullOrEmpty(tbCustomers.Value) && string.IsNullOrEmpty(tbBucket.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please apply at least one filter to select orders";
            return;
        }
        var areas = ctlAvailableInventoryArea.Value.Split(',').Intersect(ctlPullableInventoryArea.Value.Split(',')).ToArray();
        e.ControlToValidate.IsValid = areas.Length == 0;
        var custom = (Custom)sender;
        e.ControlToValidate.ErrorMessage = string.Format("Areas {0} must either be Inventory Area or Pullable Areas, but not both",
            string.Join(", ", areas));
        return;
    }
    protected void gv_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                //int shortage = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "shortage"));
                var shortage = DataBinder.Eval(e.Row.DataItem, "shortage");
                var minPullBack = DataBinder.Eval(e.Row.DataItem, "MIN_PULLBACK_QUANTITY");
                var shortageColindex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "shortage" ? i : -1)
            .Single(p => p >= 0);
                if (shortage != null && minPullBack != null)
                    if (Convert.ToInt32(shortage) > Convert.ToInt32(minPullBack))
                    {
                        e.Row.Cells[shortageColindex].BackColor = System.Drawing.Color.FromArgb(255, 74, 74);

                    }
                break;

        }
    }
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {


            if (!string.IsNullOrEmpty(tbBucket.Text))
            {
                // check radio button if bucket is passed via query string
                rblOrderType.Value = "SB";
                rbSpecificBucket.CheckedValue = "SB";
            }

        }
        base.OnLoad(e);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content=" Displays Shortage and Min pull back quantity of ordered skus." />
    <meta name="ReportId" content="130.28" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Report is honouring customer and building filter while calculating picked inventory.| Fixed bug while passing correct area to drill down report 40.24" />
    <meta name="Version" content="$Id: R130_28.aspx 4268 2012-08-18 06:20:48Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <asp:Panel ID="pnlOrders" GroupingText="For Open Orders of" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Building" />
                    <d:BuildingSelector ID="ctlWhLoc" runat="server" ShowAll="false" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Click to choose Warehouse Location"
                        FriendlyName="Building" QueryString="building_id">
                        <Items>
                            <eclipse:DropDownItem Text="(Please Select)" Value="" Persistent="Always" />
                        </Items>
                    </d:BuildingSelector>
                    <br />
                    Shortages will be checked for open orders in this building.
                    <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                    <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Click to choose Virtual Warehouse"
                        QueryString="vwh_id" />
                    <eclipse:LeftLabel runat="server" ID="lblCustomer" Text="Customer" />
                    <i:AutoComplete runat="server" ID="tbCustomers" ClientIDMode="Static" WebMethod="GetCustomers"
                        FriendlyName="Customer" QueryString="customer_id" Delay="4000" Width="200" ValidateWebMethodName="ValidateCustomer"
                        AutoValidate="true">
                    </i:AutoComplete>
                    <br />
                    The customer for which you want to see the orders.
                    <eclipse:LeftLabel ID="lblLabel" runat="server" Text="Label" />
                    <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        QueryString="label_id" ShowAll="true" FriendlyName="Label" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                        ToolTip="Select Label" />
                    <br />
                    Orders of Label
                    <eclipse:LeftPanel ID="LeftPanel2" runat="server" Span="true">
                        <fieldset>
                            <legend class="ui-widget-header">Order Type</legend>
                            <i:RadioButtonListEx ID="rblOrderType" runat="server" QueryString="order_type" FriendlyName="Order Type"
                                Value="A" />
                            <i:RadioItemProxy runat="server" ID="rbAll" Text="All Orders" QueryString="order_type"
                                CheckedValue="A" />
                            <br />
                            &nbsp;<i:RadioItemProxy runat="server" ID="rbBucketOrders" Text="Orders of Buckets"
                                QueryString="order_type" CheckedValue="OB" ClientIDMode="Static" />
                            <br />
                            &nbsp;<i:RadioItemProxy runat="server" ID="rbSpecificBucket" Text="Orders of Specific Bucket"
                                QueryString="order_type" CheckedValue="SB" />
                            <i:TextBoxEx ID="tbBucket" FriendlyName="Bucket" runat="server" QueryString="bucket_id">
                                <Validators>
                                    <i:Filter DependsOn="rblOrderType" DependsOnState="Value" DependsOnValue="SB" />
                                    <i:Required DependsOn="rblOrderType" DependsOnState="Value" DependsOnValue="SB" />
                                </Validators>
                            </i:TextBoxEx>
                        </fieldset>
                    </eclipse:LeftPanel>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
            <eclipse:TwoColumnPanel ID="TwoColumnPanel2" runat="server">
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <oracle:OracleDataSource ID="dsAvailableInventory" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                        <SelectSql>
                            select inventory_storage_area as area,
                            short_name || '-' || warehouse_location_id || ':' || description  as description,
                            warehouse_location_id as building
                            from tab_inventory_area
                            where 1 = 1
                            AND stores_what ='CTN' 
                            union all
                            select ia.ia_id as area,
                            ia.ia_id || ':' || ia.short_description as description,
                            null as building
                            from ia ia
                            where ia.picking_area_flag='Y'
                            order by building,area
                        </SelectSql>
                    </oracle:OracleDataSource>
                    <div style="background-color: LightGreen;">
                        <i:CheckBoxListEx ID="ctlAvailableInventoryArea" runat="server" DataTextField="description"
                            DataValueField="area" DataSourceID="dsAvailableInventory" FriendlyName="Check For Inventory In"
                            QueryString="inventory_area">
                            <Validators>
                                <i:Required />
                            </Validators>
                        </i:CheckBoxListEx>
                    </div>
                    <br />
                    For shortage calculations, inventory in selected area is considered.
                </eclipse:LeftPanel>
                <eclipse:LeftPanel ID="lblPullableInventoryArea" runat="server" Span="true">
                    <oracle:OracleDataSource ID="dsPullableInventory" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                        <SelectSql>
                            select inventory_storage_area as area,
                            short_name || '-' || warehouse_location_id || ':' || description  as description,
                            warehouse_location_id as building
                            from tab_inventory_area
                            where 1 = 1
                            AND stores_what ='CTN' 
                            union all
                            select ia.ia_id as area,
                            ia.ia_id || ':' || ia.short_description as description,
                            null as building
                            from ia ia
                            where ia.picking_area_flag='Y'
                            order by building,area
                        </SelectSql>
                    </oracle:OracleDataSource>
                    <div style="background-color: Yellow;">
                        <i:CheckBoxListEx ID="ctlPullableInventoryArea" runat="server" DataTextField="description"
                            DataValueField="area" DataSourceID="dsPullableInventory" FriendlyName="Inventory Can Be Pulled From"
                            QueryString="replenishment_area">
                            <Validators>
                                <i:Custom OnServerValidate="ctlPullableInventoryArea_OnServerValidate" ClientMessage="Pullable areas must be different from inventory areas" />
                            </Validators>
                        </i:CheckBoxListEx>
                    </div>
                    <br />
                    To help you satisfy shortages, pullback quantity is computed by looking at available
                    inventory in areas of other buildings. To pullback from a specific area select it
                    above. <em>Known Issue</em>: Do not choose a multi building area, such as BIR, here.
                    <br />
                    <i:CheckBoxEx ID="cbPullableSKU" runat="server" CheckedValue="S" FriendlyName="Show Pullabel SKUs" />
                    Check this to show only pullable shortages.
                </eclipse:LeftPanel>
                <eclipse:LeftLabel ID="lblQuality" runat="server" Text="Quality Code" />
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
                </i:DropDownListEx2>
                <br />
                Quality of inventory which can be shipped against open orders. DCMS supports inventory
                of multiple qualities.
                <br />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel3" runat="server" HeaderText="Help">
            <p>
                For the given building, ordered SKU requirements are compared with inventory within
                the building. All short SKUs are listed.
            </p>
            <p>
                Inventory in buildings other than the chosen building is listed as well. This can
                help you determine whether it is possible to pull inventory from another building
                to satisfy the shortage. A report parameter enables you to list only those shortages
                which can be satisfied to some extent by pulling stock from another building.
            </p>
            <p>
                Pieces ordered include pieces which may already been picked.While calulating shoratge
                these picked pieces are deducted from ordered pieces. Box inventory is displayed
                under the pseudo area <em>BOXES</em> and shortage calculations take this inventory
                into consideration. All unreserved carton inventory is visible, regardless of whether
                the carton has been earmarked against pull requests.
            </p>
            <p>
                If inventory exists for multiple qualities, the quality code is suffixed to the
                carton area name.
            </p>
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide you the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <%--Provide the data source for quering the data for the report, the datasource should always be placed above the display 
            control since query execution time is displayed where the data source control actaully is on the page,
            while writing the select query the alias name must match with that of database column names so as to avoid 
            any confusion, for details of control refer OracleDataSource.htm with in doc folder of EclipseLibrary.Oracle--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        DataSourceMode="DataSet">
        <SelectSql>
 WITH ALL_ORDERED_SKU AS
 (
 <if c="$order_type='A'">
 SELECT /*+ INDEX(dp ps_pdstat_fk_i) INDEX(dpd psdet_ps_fk_i) */ msku.sku_id,
         DP.VWH_ID            AS VWH_ID,
         DPD.QUANTITY_ORDERED AS QUANTITY_ORDERED,
         null as Bucket_id
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPD.PICKSLIP_ID = DP.PICKSLIP_ID
   inner join master_sku msku
      on msku.style = dpd.style
     and msku.color = dpd.color
     and msku.dimension = dpd.dimension
     and msku.sku_size = dpd.sku_size
   WHERE DP.PS_STATUS_ID = 1
    <if> AND DP.VWH_ID = :VWH_ID</if>
     <if>and dp.customer_id=:customer_id</if>
     <if>AND DP.WAREHOUSE_LOCATION_ID = :warehouse_location_id</if>
  UNION ALL
  </if>
  SELECT ms.sku_id,
         P.VWH_ID          AS VWH_ID,
         PD.PIECES_ORDERED AS QUANTITY_ORDERED,
         p.bucket_id as Bucket_id
    FROM PS P
   INNER JOIN PSDET PD
      ON P.PICKSLIP_ID = PD.PICKSLIP_ID
   INNER JOIN MASTER_SKU MS
      ON MS.UPC_CODE = PD.UPC_CODE
   WHERE P.TRANSFER_DATE IS NULL
     <if>AND P.WAREHOUSE_LOCATION_ID = :warehouse_location_id</if>
     <if>AND P.VWH_ID = :VWH_ID</if>
      <if>and p.customer_id=:customer_id</if>
      <if>and p.bucket_id=:bucket_id</if>
     AND PD.TRANSFER_DATE IS NULL
     and pd.upc_code not in (select bksu.upc_code from bucketsku bksu where bksu.underpitch_flag = 'Y' and p.bucket_id=bksu.bucket_id )),
ALL_GROUPED_SKU AS
 (SELECT AO.sku_id AS sku_id,
         AO.VWH_ID AS VWH_ID,
         SUM(AO.QUANTITY_ORDERED) AS QUANTITY_ORDERED,
         count(distinct Ao.bucket_id) as bucket_count
    FROM ALL_ORDERED_SKU AO
    GROUP BY sku_id, AO.VWH_ID),

ALL_INVENTORY_SKU AS
 (SELECT tia.inventory_storage_area AS INVENTORY_AREA,
         tia.short_name as AREA_NAME,
         scd.sku_id as sku_id,
         SC.VWH_ID AS VWH_ID,
         NVL(tia.warehouse_location_id, MSL.WAREHOUSE_LOCATION_ID) as building_id,
         SCD.QUANTITY AS QUANTITY,
         SC.quality_code as QUALITY,
         tia.stores_what as area_type       
    FROM SRC_CARTON_DETAIL SCD
   INNER JOIN SRC_CARTON SC
      ON SC.CARTON_ID = SCD.CARTON_ID
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.LOCATION_ID = MSL.LOCATION_ID
     and sc.carton_storage_area = msl.storage_area
    left outer JOIN TAB_INVENTORY_AREA TIA
      ON sc.carton_storage_area = TIA.INVENTORY_STORAGE_AREA
   WHERE sc.suspense_date is null
   <if>and SC.VWH_ID = :VWH_ID </if>
   <if> and sc.quality_code=:quality_code</if>   
 and scd.req_process_id is null
   
  UNION ALL

 SELECT  IL.IA_ID,
         IL.IA_ID as area_name,
         IL.sku_id,
         IL.VWH_ID AS VWH_ID,
         IL.WAREHOUSE_LOCATION_ID,
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.RESERVED_UNITS, 0) AS NUMBER_OF_UNITS,
         null as quality,
         'SKU' as area_type
    FROM (SELECT IAC.IA_ID      AS IA_ID,
                 msku.sku_id as sku_id,
                 I.VWH_ID AS VWH_ID,
                 I.WAREHOUSE_LOCATION_ID as WAREHOUSE_LOCATION_ID,
                 SUM(IAC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS
            FROM IALOC_CONTENT IAC
           INNER JOIN IALOC I
              ON I.IA_ID = IAC.IA_ID
             AND I.LOCATION_ID = IAC.LOCATION_ID
          
           INNER JOIN MASTER_SKU MSKU
              ON MSKU.UPC_CODE = IAC.IACONTENT_ID
          
           WHERE 1=1
             
             <if>AND I.VWH_ID = :VWH_ID</if>
           GROUP BY IAC.IA_ID,
                    msku.sku_id,
                    I.VWH_ID,
                    I.WAREHOUSE_LOCATION_ID) IL
    LEFT OUTER JOIN (SELECT RD.IA_ID AS IA_ID,
                            msku.sku_id as sku_id,
                            SUM(RD.PIECES_RESERVED) RESERVED_UNITS,
                            RD.VWH_ID,
                            iac.warehouse_location_id as warehouse_location_id
                            FROM RESVDET RD
                            INNER JOIN MASTER_SKU MSKU
                            ON RD.UPC_CODE = MSKU.UPC_CODE
                             left outer join ialoc iac on
                            iac.ia_id=rd.ia_id
                            and iac.location_id=rd.location_id
 GROUP BY msku.sku_id, RD.VWH_ID, RD.IA_ID,iac.warehouse_location_id) R
      ON IL.IA_ID = R.IA_ID
     AND IL.Sku_id=R.sku_id
     AND IL.VWH_ID = R.VWH_ID
     and Il.warehouse_location_id=R.warehouse_location_id

  UNION ALL
  SELECT 'BOXES',
         'BOXES' as area_name,
         MS.sku_id               AS sku_id,
         B.VWH_ID                AS VWH_ID,
         P.WAREHOUSE_LOCATION_ID,
        (case
           when b.carton_id is not null then
                BD.expected_pieces 
          
          WHEN b.carton_id is null AND
               b.ia_id is not null THEN
 
          bd.expected_pieces end)  AS PICKED_QUANTITY,
         null as QUALITY,
         null as area_type
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.PICKSLIP_ID = BD.PICKSLIP_ID
     AND B.UCC128_ID = BD.UCC128_ID
   INNER JOIN PS P
      ON P.PICKSLIP_ID = B.PICKSLIP_ID
   INNER JOIN MASTER_SKU MS
      ON BD.UPC_CODE = MS.UPC_CODE
   WHERE P.TRANSFER_DATE IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     <if>and p.customer_id=:customer_id</if>
     <if>AND p.VWH_ID = :VWH_ID</if>
     <if>AND P.WAREHOUSE_LOCATION_ID = :warehouse_location_id</if>
     <if>and p.bucket_id=:bucket_id</if>
     ),
GROUPED_INVENTORY_SKU AS
 (SELECT AIS.sku_id AS sku_id,
         AIS.INVENTORY_AREA AS INVENTORY_AREA,
         max(AIS.AREA_NAME) AS AREA_NAME,
         AIS.VWH_ID AS VWH_ID,
         ais.building_id as building_id,
         SUM(AIS.QUANTITY) AS QUANTITY,
         <a pre="SUM(SUM(case
                   when  ais.INVENTORY_AREA IN (" sep="," post=")">(:myInventoryArea)</a> THEN
                    AIS.QUANTITY
                 END)) OVER(partition by AIS.sku_id, AIS.VWH_ID)
                  AS QUANTITY_my_areas,

         <if c="$pullbaleInventoryArea"><a pre="
                 SUM(SUM(case
                   when  ais.INVENTORY_AREA in (" sep="," post=")">:pullbaleInventoryArea</a> THEN
                    AIS.QUANTITY
                 END)) OVER(partition by AIS.sku_id, AIS.VWH_ID) AS QUANTITY_other_areas,
         </if>
                 <else><a pre="SUM(SUM(case
                   when ais.INVENTORY_AREA not in ('BOXES'," sep="," post=")">:myInventoryArea</a>THEN
                    AIS.QUANTITY
                 END)) OVER(partition by AIS.sku_id, AIS.VWH_ID) AS QUANTITY_other_areas,
                 </else> 
          AIS.QUALITY as QUALITY ,
          SUM(SUM(case
                   when ais.INVENTORY_AREA ='BOXES' THEN
                    AIS.QUANTITY
                 END)) OVER(partition by AIS.sku_id, AIS.VWH_ID) AS BOXQUANTITY ,
                 max(ais.area_type) as area_type                   
    FROM ALL_INVENTORY_SKU AIS
   GROUP BY AIS.sku_id, AIS.VWH_ID, AIS.INVENTORY_AREA, ais.building_id, AIS.QUALITY),
final_query as
 (SELECT OS.sku_id AS sku_id,
         OS.VWH_ID AS VWH_ID,
         sty.label_id as label_id,
         os.bucket_count as bucket_count,
         msku.style as style ,
         msku.color as color,
         msku.dimension as dimension,
         msku.sku_size as sku_size,
         msku.upc_code as upc_code,
         gis.building_id as inventory_building_id,
         OS.QUANTITY_ORDERED AS ORDERED_QUANTITY,
         GIS.INVENTORY_AREA AS INVENTORY_AREA,
         GIS.AREA_NAME AS AREA_NAME,
         GIS.QUANTITY AS PIECES_IN_AREA,
         GIS.QUANTITY_my_areas as QUANTITY_my_areas,
         gis.QUANTITY_other_areas as QUANTITY_other_areas,
         OS.QUANTITY_ORDERED - NVL(BOXQUANTITY, 0) - NVL(GIS.QUANTITY_my_areas, 0)  AS SHORTAGE,
         LEAST(OS.QUANTITY_ORDERED - NVL(BOXQUANTITY, 0) - NVL(GIS.QUANTITY_my_areas, 0), NVL(gis.QUANTITY_other_areas, 0)) AS MIN_PULLBACK_QUANTITY,
         GIS.QUALITY as QUALITY,
        gis.BOXQUANTITY  as BOXQUANTITY,
        gis.area_type as area_type
    FROM ALL_GROUPED_SKU OS
   inner join master_sku msku
      on msku.sku_id = os.sku_id
    left outer join master_style sty
      on sty.style = msku.style
    LEFT OUTER JOIN GROUPED_INVENTORY_SKU GIS
      ON GIS.sku_id = OS.sku_id
     AND GIS.VWH_ID = OS.VWH_ID
 WHERE 1=1 
 and 
 OS.QUANTITY_ORDERED - NVL(BOXQUANTITY, 0) - NVL(GIS.QUANTITY_my_areas, 0) &gt; 0
 <if> and sty.label_id=:label_id</if>
 <if c="$showPullabelSku">And gis.QUANTITY_other_areas &gt; 0</if>
   )
select *
  from final_query
   pivot XML(sum(PIECES_IN_AREA) as PIECES_IN_AREA for (INVENTORY_AREA, inventory_building_id,QUALITY,area_type,AREA_NAME) IN(ANY, ANY,ANY,ANY,ANY))

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Name="VWH_ID" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Name="warehouse_location_id"
                Direction="Input" />
            <asp:ControlParameter ControlID="cbPullableSKU" Type="String" Name="showPullabelSku" />
            <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input"
                Name="quality_code" />
            <asp:ControlParameter ControlID="ctlAvailableInventoryArea" Type="String" Name="myInventoryArea"
                Direction="Input" />
            <asp:ControlParameter ControlID="ctlPullableInventoryArea" Type="String" Name="pullbaleInventoryArea" />
            <asp:ControlParameter ControlID="tbCustomers" Type="String" Name="customer_id" />
            <asp:ControlParameter ControlID="tbBucket" Type="String" Name="bucket_id" />
            <asp:ControlParameter ControlID="ctlLabel" Type="String" Name="label_id" />
            <asp:ControlParameter ControlID="rblOrderType" Type="String" Direction="Input" Name="order_type" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        DataSourceID="ds" ShowFooter="true" DefaultSortExpression="SHORTAGE {0:I};STYLE;color;dimension;sku_size"
        OnRowDataBound="gv_OnRowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="Vwh" SortExpression="VWH_ID" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="STYLE" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size" />
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                AccessibleHeaderText="label_id" />
            <eclipse:SiteHyperLinkField DataTextField="bucket_count" HeaderText="Bucket Count"
                SortExpression="bucket_count" AccessibleHeaderText="bucket_count" DataNavigateUrlFields="upc_code,vwh_id"
                DataNavigateUrlFormatString="R130_109.aspx?upc_code={0}&vwh_id={1}" AppliedFiltersControlID="ButtonBar1$af"
                DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="ORDERED_QUANTITY" HeaderText="Total|Ordered"
                SortExpression="ORDERED_QUANTITY" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                AccessibleHeaderText="TotalOrdred" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="BOXQUANTITY" HeaderText="Total|Picked" SortExpression="BOXQUANTITY"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                HeaderToolTip="Pieces picked or guaranteed to be picked because of reservation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="QUANTITY_my_areas" HeaderText="Total|Available"
                SortExpression="QUANTITY_my_areas" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" AccessibleHeaderText="quantity_my_areas">
                <ItemStyle HorizontalAlign="Right" BackColor="LightGreen" />
                <FooterStyle HorizontalAlign="Right" />
                <ControlStyle BackColor="DarkBlue" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHORTAGE" HeaderText="Total|Shortage" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" SortExpression="SHORTAGE"
                AccessibleHeaderText="shortage" HeaderToolTip="Shortage=Ordered Pieces-(Picked Pieces + Available Pieces)">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="QUANTITY_other_areas" HeaderText="Total Pullable"
                SortExpression="QUANTITY_other_areas" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" BackColor="Yellow" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="MIN_PULLBACK_QUANTITY" HeaderText="Min Pullback Pieces"
                SortExpression="MIN_PULLBACK_QUANTITY" DataSummaryCalculation="ValueSummation"
                AccessibleHeaderText="minpullbackqty" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

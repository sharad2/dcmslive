<%@ Page Title="Picking Area Quantity against Buckets" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5825 $
 *  $Author: sbist $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_109.aspx $
 *  $Id: R130_109.aspx 5825 2013-08-01 07:54:25Z sbist $
 * Version Control Template Added.
--%>
<script runat="server">
    //protected override void OnInit(EventArgs e)
    //{
    //    ds.PostSelected += new EventHandler<PostSelectedEventArgs>(ds_PostSelected);
    //    base.OnInit(e);
    //}

    //void ds_PostSelected(object sender, PostSelectedEventArgs e)
    //{
    //    var data = (System.Data.DataView)e.Result;
    //    if (data != null)
    //    {
    //        var list = new List<MultiBoundField>();
    //        foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["INVENTORY_AREA_WAREHOUSE_L_XML"] != DBNull.Value))
    //        {
    //            var items = XElement.Parse((string)row["INVENTORY_AREA_WAREHOUSE_L_XML"]).Elements("item");
    //            var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "picked_pieces"));
    //            foreach (var item in items)
    //            {
    //                var areaId = item.Elements("column").Where(p => p.Attribute("name").Value == "INVENTORY_AREA").First().Value;
    //                var qty = item.Elements("column").Where(p => p.Attribute("name").Value == "PIECES_IN_AREA").First().Value;
    //                var buildingId = item.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
    //                var col = data.Table.Columns[areaId];
    //                if (col == null)
    //                {
    //                    col = data.Table.Columns.Add(areaId, typeof(int));
    //                    var bf = new MultiBoundField

    //                    {
    //                        HeaderText = string.Format("Pieces in|{0}", areaId),
    //                        DataFields = new[] { areaId },
    //                        DataFormatString = "{0:N0}",
    //                        AccessibleHeaderText = string.Format("{0},{1}", areaId, buildingId),
    //                    };
    //                    bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
    //                    bf.ItemStyle.BackColor = System.Drawing.Color.LightGreen;
    //                    //gv.Columns.Add(bf);
    //                    if (!string.IsNullOrEmpty(areaId))
    //                    {
    //                        gv.Columns.Insert(index, bf);
    //                    }
    //                }
    //                if (!string.IsNullOrEmpty(areaId))
    //                {
    //                    row[areaId] = qty;
    //                }
    //            }
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
            foreach (var row in data.Cast<System.Data.DataRowView>().Where(p => p["SHORT_NAME_WAREHOUSE_LOCAT_XML"] != DBNull.Value))
            {
                var items = XElement.Parse((string)row["SHORT_NAME_WAREHOUSE_LOCAT_XML"]).Elements("item");
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
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "SHORT_NAME").First().Value;
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
                bf.ItemStyle.BackColor = System.Drawing.Color.LightGreen;
                retVal = bf;

            }

            row[colName] = pieces;
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
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The Report lists the Buckets and available pieces against them in picking area." />
    <meta name="ReportId" content="130.109" />
    <meta name="Browsable" content="false" />
    <meta name="ChangeLog" content="Replaced building filter dropdown with checkbox list." />
    <meta name="Version" content="$Id: R130_109.aspx 5825 2013-08-01 07:54:25Z sbist $" />
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
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
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
                    QueryString="building_id">
                </i:CheckBoxListEx>

                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    QueryString="vwh_id" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ToolTip="Select any virtual warehouse(optional)" />
                <eclipse:LeftLabel runat="server" ID="lblCustomer" Text="Customer" />
                <i:AutoComplete runat="server" ID="tbCustomers" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Customer" QueryString="customer_id" Delay="4000" Width="200" ValidateWebMethodName="ValidateCustomer"
                    AutoValidate="true">
                </i:AutoComplete>
                <br />
                The customer for which you want to see the Buckets.
                <eclipse:LeftLabel ID="lblBucket" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucket" runat="server" QueryString="bucket_id" />
                <eclipse:LeftLabel runat="server" Text="UPC Code" />
                <i:TextBoxEx ID="tbUpCode" runat="server" QueryString="upc_code" FriendlyName="UPC Code" />
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
                            nvl(IA.SHORT_NAME,ia.ia_id)||'-'||warehouse_location_id|| ':' || ia.short_description as description,
                            warehouse_location_id as building
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
                    <Items>
                        <eclipse:DropDownItem Value="" Text="(Any)" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <br />
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbStartdate" Text="Start Date" CheckedValue="Y"
                        QueryString="start_date" FriendlyName="Start Date" Checked="false" />
                </eclipse:LeftPanel>
                From
                            <d:BusinessDateTextBox ID="dtFromStart" runat="server" FriendlyName="From Start Date"
                                QueryString="from_start_date" Text="0">
                                <Validators>
                                    <i:Filter DependsOn="cbStartdate" DependsOnState="Checked" />
                                    <i:Date />
                                </Validators>
                            </d:BusinessDateTextBox>
                To:
                            <d:BusinessDateTextBox ID="dtToStart" runat="server" FriendlyName="To Start Date"
                                QueryString="to_start_date" Text="7">
                                <Validators>
                                    <i:Filter DependsOn="cbStartdate" DependsOnState="Checked" />
                                    <i:Date DateType="ToDate" />
                                </Validators>
                            </d:BusinessDateTextBox>
                <eclipse:LeftPanel ID="LeftPanel4" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbCanceldate" Text="Cancel Date" CheckedValue="Y"
                        QueryString="cancel_date" FriendlyName="Cancel Date" Checked="false" />
                </eclipse:LeftPanel>
                From
                            <d:BusinessDateTextBox ID="dtFromCancel" runat="server" FriendlyName="From Cancel Date"
                                QueryString="from_cancel_date" Text="0">
                                <Validators>
                                    <i:Filter DependsOn="cbCanceldate" DependsOnState="Checked" />
                                    <i:Date />
                                </Validators>
                            </d:BusinessDateTextBox>
                To:
                            <d:BusinessDateTextBox ID="dtToCancel" runat="server" FriendlyName="To Cancel Date"
                                QueryString="to_cancel_date" Text="7">
                                <Validators>
                                    <i:Filter DependsOn="cbCanceldate" DependsOnState="Checked" />
                                    <i:Date DateType="ToDate" />
                                </Validators>
                            </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
        <SelectSql>
           SELECT
         DP.VWH_ID            AS VWH_ID,
         sum(DPD.QUANTITY_ORDERED) AS QUANTITY_ORDERED
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPD.PICKSLIP_ID = DP.PICKSLIP_ID
   WHERE DP.PS_STATUS_ID = 1
     <if>AND DP.DELIVERY_DATE &gt;= CAST(:FROM_START_DATE as DATE)</if>
     <if>AND DP.DELIVERY_DATE &lt; CAST(:TO_START_DATE as DATE)+1</if>
     <if>AND DP.CANCEL_DATE &gt;= CAST(:FROM_CANCEL_DATE as DATE)</if>
     <if>AND DP.CANCEL_DATE &lt; CAST(:TO_CANCEL_DATE as DATE) +1</if>
     <if>AND DP.VWH_ID = :vwh_id</if>
     <if>and dpd.Upc_code=:upc_code</if>
     <if>AND <a pre="NVL(DP.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>and dp.customer_id=:customer_id</if>
     group by dpd.upc_code,dp.vwh_id 
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbUpCode" DbType="String" Name="upc_code" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" Direction="Input" />
            <asp:ControlParameter ControlID="ctlwhloc" DbType="String" Name="warehouse_location_id"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbCustomers" Type="String" Name="customer_id" />
            <asp:ControlParameter ControlID="dtFromStart" Name="FROM_START_DATE" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtToStart" Name="TO_START_DATE" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="dtFromCancel" Name="FROM_CANCEL_DATE" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtToCancel" Name="TO_CANCEL_DATE" Type="DateTime" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        DataSourceMode="DataSet">
        <SelectSql>
  with bucket_sku_info as 
(
SELECT bucket.bucket_id AS BUCKET_ID,
       sum(psdet.pieces_ordered) AS REQUIRED_QUANTITY,
       max(psdet.upc_code) as upc_code
  FROM ps ps left outer join bucket bucket on ps.bucket_id = bucket.bucket_id
  left outer join psdet psdet on ps.pickslip_id = psdet.pickslip_id
  left outer join bucketsku bs on bs.bucket_id = bucket.bucket_id
                              and bs.upc_code = psdet.upc_code
  INNER JOIN PO ON
      Ps.CUSTOMER_ID = PO.CUSTOMER_ID
      AND Ps.PO_ID = PO.PO_ID
      AND Ps.ITERATION = PO.ITERATION
 WHERE 1=1
  AND PS.TRANSFER_DATE is null
  AND psdet.TRANSFER_DATE is null
 and psdet.upc_code not in (select bksu.upc_code from bucketsku bksu where bksu.underpitch_flag = 'Y' and ps.bucket_id=bksu.bucket_id )
   <if>AND ps.vwh_id =:vwh_id</if>
   <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <if>AND psdet.upc_code = :upc_code</if>
   <if>and ps.customer_id=:customer_id</if>
   <if>and ps.bucket_id=:bucket_id</if>
   <if>AND PO.START_DATE &gt;= CAST(:FROM_START_DATE as DATE)</if>
   <if>AND PO.START_DATE &lt; CAST(:TO_START_DATE as DATE)+1</if>
   <if>AND PO.CANCEL_DATE &gt;= CAST(:FROM_CANCEL_DATE as DATE)</if>
   <if>AND PO.CANCEL_DATE &lt; CAST(:TO_CANCEL_DATE as DATE) +1</if>
 GROUP BY bucket.bucket_id,ps.vwh_id
), 
ialoc_sku as 
(
  SELECT IL.UPC_CODE,
         IL.VWH_ID,
         NVL(IL.QUANTITY, 0) - NVL(R.NUMBER_OF_UNITS, 0) AS AREA_QUANTITY,
         IL.Inventory_area,
         IL.SHORT_NAME,
         IL.WAREHOUSE_LOCATION_ID
    FROM (SELECT IAC.ASSIGNED_UPC_CODE AS UPC_CODE,
                 IAC.VWH_ID AS VWH_ID,
                 SUM(IALC.NUMBER_OF_UNITS) AS QUANTITY,
                 IA.IA_ID AS INVENTORY_AREA,
                 MAX(IA.SHORT_NAME) AS SHORT_NAME,
                 NVL(IAC.WAREHOUSE_LOCATION_ID, 'Unknown') AS WAREHOUSE_LOCATION_ID,
                 MAX(MSKU.SKU_ID) AS SKU_ID
       FROM  ialoc iac 
  inner join ialoc_content ialc 
  on iac.ia_id = ialc.ia_id
  AND  iac.location_id = ialc.location_id
  inner join ia ia on
  ia.ia_id=iac.ia_id
  INNER JOIN MASTER_SKU MSKU
      ON MSKU.UPC_CODE = IALC.IACONTENT_ID
 WHERE 1=1<if>and iac.assigned_upc_code = :upc_code</if>
   <if>AND iac.vwh_id = :vwh_id</if>
            <if>AND <a pre="NVL(IAC.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <if>and <a pre="ia.ia_id IN (" sep="," post=")">(:inventory_area)</a></if>
  and ia.picking_area_flag='Y'
  and IAlC.IACONTENT_TYPE_ID = 'SKU'
 GROUP BY iac.assigned_upc_code, iac.vwh_id,ia.ia_id, NVL(IAC.WAREHOUSE_LOCATION_ID, 'Unknown')
       ) IL
    LEFT OUTER JOIN (SELECT RD.IA_ID AS IA_ID,
                            msku.sku_id as sku_id,
                            SUM(RD.PIECES_RESERVED) NUMBER_OF_UNITS,
                            RD.VWH_ID
                       FROM RESVDET RD
                      INNER JOIN MASTER_SKU MSKU
                         ON RD.UPC_CODE = MSKU.UPC_CODE
                      GROUP BY msku.sku_id,
                               RD.VWH_ID,
                               RD.IA_ID) R
      ON IL.Inventory_area = R.IA_ID
     AND IL.Sku_id=R.sku_id
     AND IL.VWH_ID = R.VWH_ID

union all
      
SELECT   msku.upc_code as upc_code,
         SC.VWH_ID AS VWH_ID,      
         sum(SCD.QUANTITY) AS AREA_QUANTITY, 
         sc.carton_storage_area as Inventory_area,
         MAX(TIA.SHORT_NAME) AS SHORT_NAME,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS WAREHOUSE_LOCATION_ID   
    FROM SRC_CARTON_DETAIL SCD
   INNER JOIN SRC_CARTON SC
      ON SC.CARTON_ID = SCD.CARTON_ID
      inner join master_sku msku on
      msku.sku_id=scd.sku_id
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.LOCATION_ID = MSL.LOCATION_ID
     and sc.carton_storage_area = msl.storage_area
    left outer JOIN TAB_INVENTORY_AREA TIA
      ON sc.carton_storage_area = TIA.INVENTORY_STORAGE_AREA
   WHERE sc.suspense_date is null
   and scd.req_process_id is null
   <if>and SC.VWH_ID = :VWH_ID </if>
    <if> and sc.quality_code=:quality_code</if> 
   <if> and  msku.upc_code=:upc_code</if>
   <if>and  <a pre="sc.carton_storage_area IN (" sep="," post=")">(:inventory_area)</a> </if>
   group by msku.upc_code,sc.vwh_id,sc.carton_storage_area,  COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown')
),
All_Inventory_SKU as
(
select ias.upc_code as upc_code,
ias.vwh_id as vwh_id,
sum(ias.AREA_QUANTITY) as AREA_QUANTITY,
ias.Inventory_area as Inventory_area,
MAX(IAS.SHORT_NAME) AS SHORT_NAME,
IAS.WAREHOUSE_LOCATION_ID,
 <a pre="SUM(SUM(case
                   when  ias.INVENTORY_AREA IN (" sep="," post=")">(:inventory_area)</a> THEN
                    ias.AREA_QUANTITY
                 END)) OVER(partition by ias.upc_code, ias.VWH_ID)
                  AS QUANTITY_picking_areas
 from ialoc_sku  ias

 group by ias.upc_code,ias.vwh_id,ias.Inventory_area, IAS.WAREHOUSE_LOCATION_ID
), 
 Picked_sku as
 (
   SELECT 
         max(BD.upc_code)             AS upc_code,
         B.VWH_ID                AS VWH_ID,
         sum (case
         when b.carton_id is not null then
          BD.expected_pieces
          when b.carton_id is null
          and b.ia_id is not null then
          bd.expected_pieces end) as picked_pieces,
         p.bucket_id as bucket_id
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
     <if>AND p.VWH_ID = :VWH_ID</if>
     <if>and bd.upc_code=:upc_code</if>
     group by b.vwh_id,p.bucket_id
 ), 
 final_query as
 (
select bsi.bucket_id as bucket_id,
       bsi.REQUIRED_QUANTITY as REQUIRED_QUANTITY,
       NVL(IAS.AREA_QUANTITY, 0) AS PICKINGAREA_QUANTITY,
       pksu.picked_pieces as picked_pieces,      
       IAS.SHORT_NAME AS SHORT_NAME,
       IAS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       ias.QUANTITY_picking_areas as QUANTITY_picking_areas   
  from bucket_sku_info bsi
  left outer join All_Inventory_SKU ias on bsi.upc_code = ias.upc_code
  left outer join picked_sku  pksu on pksu.bucket_id=bsi.bucket_id
  )
  select *
  from final_query
   pivot XML(sum(PickingArea_QUANTITY) as PIECES_IN_AREA for (SHORT_NAME,WAREHOUSE_LOCATION_ID) IN(ANY,ANY))
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbUpCode" DbType="String" Name="upc_code" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" Direction="Input" />
            <asp:ControlParameter ControlID="ctlwhloc" DbType="String" Name="WAREHOUSE_LOCATION_ID"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbCustomers" Type="String" Name="customer_id" />
            <asp:ControlParameter ControlID="tbBucket" Type="String" Name="bucket_id" />
            <asp:ControlParameter ControlID="ctlAvailableInventoryArea" Type="String" Name="inventory_area" />
            <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input"
                Name="quality_code" />

            <asp:ControlParameter ControlID="dtFromStart" Name="FROM_START_DATE" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtToStart" Name="TO_START_DATE" Type="DateTime" Direction="Input" />

            <asp:ControlParameter ControlID="dtFromCancel" Name="FROM_CANCEL_DATE" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtToCancel" Name="TO_CANCEL_DATE" Type="DateTime" Direction="Input" />

        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <asp:FormView runat="server" ID="fvTotalCountBox" DataSourceID="ds1" CssClass="ui-widget"
        Visible="true">
        <HeaderTemplate>
            <br />
        </HeaderTemplate>
        <ItemTemplate>
            <b>In Order Quantity :</b>
            <asp:Label ID="Label1" runat="server" Font-Bold="true" Text=' <%# Eval("QUANTITY_ORDERED") %>' />
        </ItemTemplate>
        <FooterTemplate>
            <br />
        </FooterTemplate>
    </asp:FormView>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="BUCKET_ID">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" HeaderToolTip="Bucket Id"
                SortExpression="bucket_id" AccessibleHeaderText="bucket" />
            <eclipse:MultiBoundField DataFields="REQUIRED_QUANTITY" HeaderText="Required Quantity"
                HeaderToolTip="Required Quantity of passed SKU in bucket." SortExpression="REQUIRED_QUANTITY"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>

            <eclipse:MultiBoundField DataFields="picked_pieces" HeaderText="Picked Quantity"
                HeaderToolTip="Picked Pieces against the ordered quantity" SortExpression="picked_pieces" AccessibleHeaderText="picked_pieces" DataSummaryCalculation="ValueSummation" FooterStyle-HorizontalAlign="Right">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Title="Replenishment Exception Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4824 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_33.aspx $
 *  $Id: R130_33.aspx 4824 2013-01-10 04:50:02Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        gv.DataBound += new EventHandler(gv_DataBound);
        base.OnInit(e);
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


    protected void gv_DataBound(object send, EventArgs e)
    {

        //if (Page.IsPostBack)
        //{

        var startTimeCellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "ImpurePalletsPieces" ? i : -1)
         .Single(p => p >= 0);
        var assignedLocationIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "AssignedLocation" ? i : -1)
         .Single(p => p >= 0);

        var impurePalletsCellindex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "ImpurePallets" ? i : -1)
                    .Single(p => p >= 0);
        var noLocationCellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "NoLocation" ? i : -1)
                    .Single(p => p >= 0);
        var noPalletCellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "NoPallet" ? i : -1)
                    .Single(p => p >= 0);
        if (gv.Rows.Count > 1)
        {
            for (int tempIndex = 0; tempIndex <= gv.Rows.Count - 1; tempIndex++)
            {

                if (gv.Rows[tempIndex].Cells[startTimeCellIndex].Text != string.Empty)
                {
                    gv.Rows[tempIndex].Cells[startTimeCellIndex].BackColor = System.Drawing.Color.FromArgb(255, 74, 74);
                    gv.Rows[tempIndex].Cells[startTimeCellIndex].ForeColor = System.Drawing.Color.White;

                }
                if (gv.Rows[tempIndex].Cells[assignedLocationIndex].Text.Contains("1"))
                {
                    gv.Rows[tempIndex].Cells[assignedLocationIndex].BackColor = System.Drawing.Color.FromArgb(255, 74, 74);
                }
                if (!string.IsNullOrEmpty(gv.Rows[tempIndex].Cells[impurePalletsCellindex].Text))
                {
                    string text = gv.Rows[tempIndex].Cells[impurePalletsCellindex].Text;
                    if (text != " ")
                    {
                        gv.Rows[tempIndex].Cells[impurePalletsCellindex].BackColor = System.Drawing.Color.FromArgb(255, 74, 74);
                        gv.Rows[tempIndex].Cells[impurePalletsCellindex].ForeColor = System.Drawing.Color.White;
                    }
                }
                if (!string.IsNullOrEmpty(gv.Rows[tempIndex].Cells[noLocationCellIndex].Text))
                {
                    gv.Rows[tempIndex].Cells[noLocationCellIndex].BackColor = System.Drawing.Color.FromArgb(255, 74, 74);
                    gv.Rows[tempIndex].Cells[noLocationCellIndex].ForeColor = System.Drawing.Color.White;

                }
                if (!string.IsNullOrEmpty(gv.Rows[tempIndex].Cells[noPalletCellIndex].Text))
                {
                    gv.Rows[tempIndex].Cells[noPalletCellIndex].BackColor = System.Drawing.Color.FromArgb(255, 74, 74);
                    gv.Rows[tempIndex].Cells[noPalletCellIndex].ForeColor = System.Drawing.Color.White;
                }

            }
            //}

        }

    }
    protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (cbSpecificBuilding.Checked && string.IsNullOrEmpty(ctlWhLoc.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide select at least one building.";
            return;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="If replenishemnt has to be done from one inventory area to another area then few exceptions prevent replenishment of SKU's. The report list these exceptions which prevent SKU's from replenishment." />
    <meta name="ReportId" content="130.33" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id:R130_33 Template.aspx 28752 2009-11-24 03:46:15Z ssinghal $" />
 <script type="text/javascript">
     function ctlWhLoc_OnClientChange(event, ui) {
         if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {
             $('#cbSpecificBuilding').attr('checked', 'checked');
         } else {
             $('#cbSpecificBuilding').removeAttr('checked', 'checked');
         }
     }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <asp:Panel ID="pnlOrders" GroupingText="Open Orders Of" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <%--<eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Building" />
                    <d:BuildingSelector ID="ctlWhLoc" runat="server" FriendlyName="Open Orders of Building"
                        QueryString="building_id" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="false">
                        <Items>
                            <eclipse:DropDownItem Text="(Please Select Building)" Value="" Persistent="Always" />
                        </Items>
                        <Validators>
                            <i:Required />
                        </Validators>
                    </d:BuildingSelector>--%>

                    <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Check For Specific Building" />
                    <i:CheckBoxEx ID="cbSpecificBuilding" runat="server" FriendlyName="Specific Building">
                        <Validators>
                            <i:Custom OnServerValidate="cbSpecificBuilding_OnServerValidate" />
                        </Validators>
                    </i:CheckBoxEx>
                </eclipse:LeftPanel>

                <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                            SELECT TWL.WAREHOUSE_LOCATION_ID,
                                   (TWL.WAREHOUSE_LOCATION_ID || ':' || TWL.DESCRIPTION) AS DESCRIPTION
                            FROM TAB_WAREHOUSE_LOCATION TWL
                            ORDER BY 1
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Check For building In"
                    QueryString="building" OnClientChange="ctlWhLoc_OnClientChange">
                     <Validators>
                        <i:Required />
                    </Validators>
                </i:CheckBoxListEx>
                    <br />
                    Building for which Open orders have to be replenished.
                    <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Virtual Warehouse" />
                    <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" FriendlyName='Open Orders of Virtual Warehouse'
                        ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                    <eclipse:LeftLabel ID="LeftLabel6" runat="server" />
                    <i:AutoComplete runat="server" ID="tbCustomers" ClientIDMode="Static" WebMethod="GetCustomers"
                        FriendlyName="Customer" QueryString="customer_id" Delay="4000" AutoValidate="true"
                        ValidateWebMethodName="ValidateCustomer" Width="200">
                    </i:AutoComplete>
                    <br />
                    The customer for which replenishment has to be done.
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Bucket" />
                    <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id" ToolTip="Use this parameter to retreive orders for specific bucket">
                        <Validators>
                            <i:Value ValueType="Integer" MaxLength="5" />
                        </Validators>
                    </i:TextBoxEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Location Are Assigned In" />
                <d:InventoryAreaSelector ID="ctlAvailableInventoryArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Click to choose area"
                    QueryString="inventory_area" UsableInventoryAreaOnly="true" StorageAreaType="CTN"
                    FriendlyName="Location Are Assigned In">
                    <Items>
                        <eclipse:DropDownItem Text="(Please Select Area)" Value="" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:InventoryAreaSelector>
                <br />
                Area with assigned location where replenishment has to be done.
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Replenishment Areas" />
                <d:InventoryAreaSelector ID="ctlReplenishmentInventoryArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Click to choose area"
                    QueryString="replenishment_area" UsableInventoryAreaOnly="true" StorageAreaType="CTN"
                    FriendlyName="Replenishment Areas">
                    <Items>
                        <eclipse:DropDownItem Text="(Please Select Area)" Value="" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:InventoryAreaSelector>
                <br />
                Area from where SKU can be replenished.
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide you the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <%--Provide the data source for quering the data for the report, the datasource should always be placed above the display 
            control since query execution time is displayed where the data source control actaully is on the page,
            while writing the select query the alias name must match with that of database column names so as to avoid 
            any confusion, for details of control refer OracleDataSource.htm with in doc folder of EclipseLibrary.Oracle--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
       WITH ALL_ORDERED_SKU(SKU_ID,bucket_id,
VWH_ID,
QUANTITY_ORDERED) AS
 (SELECT /*+ INDEX(dp ps_pdstat_fk_i) INDEX(dpd psdet_ps_fk_i) */
   MSKU.SKU_ID,null as bucket_id, DP.VWH_ID, DPD.QUANTITY_ORDERED
    FROM DEM_PICKSLIP DP
   INNER JOIN DEM_PICKSLIP_DETAIL DPD
      ON DPD.PICKSLIP_ID = DP.PICKSLIP_ID
   INNER JOIN MASTER_SKU MSKU
      ON MSKU.STYLE = DPD.STYLE
     AND MSKU.COLOR = DPD.COLOR
     AND MSKU.DIMENSION = DPD.DIMENSION
     AND MSKU.SKU_SIZE = DPD.SKU_SIZE
   WHERE DP.PS_STATUS_ID = 1
     <if>AND DP.VWH_ID = :vwh_id</if>
     <%--<if>AND DP.WAREHOUSE_LOCATION_ID = :WAREHOUSE_LOCATION_ID</if>--%>
<if>AND <a pre="dp.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>and Dp.customer_id=:customer_id</if>
  UNION ALL
  SELECT MS.SKU_ID,p.bucket_id as bucket_id,P.VWH_ID, PD.PIECES_ORDERED
    FROM PS P
   INNER JOIN PSDET PD
      ON P.PICKSLIP_ID = PD.PICKSLIP_ID
   INNER JOIN MASTER_SKU MS
      ON MS.UPC_CODE = PD.UPC_CODE
   WHERE P.TRANSFER_DATE IS NULL
     <%--<if>AND P.WAREHOUSE_LOCATION_ID = :WAREHOUSE_LOCATION_ID</if>--%>
            <if>AND <a pre="P.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>AND P.VWH_ID = :vwh_id</if>
     <if>and p.customer_id=:customer_id</if>
     AND PD.TRANSFER_DATE IS NULL),
GROUPED_ORDERED_SKU(SKU_ID,
VWH_ID,
QUANTITY_ORDERED) AS
 (SELECT AO.SKU_ID, AO.VWH_ID, SUM(AO.QUANTITY_ORDERED)
    FROM ALL_ORDERED_SKU AO
    left outer join bucket bk
    on bk.bucket_id=ao.bucket_id
    where 1=1 
    <if>and bk.bucket_id=:bucket_id</if> 
   GROUP BY SKU_ID, AO.VWH_ID),
ALL_ASSIGNED_SKUS(SKU_ID,
VWH_ID,
location_count) AS
 (SELECT msl.assigned_sku_id, msl.assigned_vwh_id, COUNT(msl.location_id)
    FROM MASTER_STORAGE_LOCATION MSL
   WHERE msl.assigned_sku_id IS NOT NULL
     <if>AND msl.storage_area = :STORAGE_AREA</if>
     <if>AND msl.assigned_vwh_id = :vwh_id</if>
    <%--<if> AND msl.warehouse_location_id = :WAREHOUSE_LOCATION_ID</if>--%>
            <if>AND <a pre="msl.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   group by msl.assigned_sku_id, msl.assigned_vwh_id),

mix_SKU_pallet(pallet_id,
sku_id,
VWH_ID,
count_sku_on_pallet,
pieces_on_pallet,
pieces_not_on_location) AS
 (SELECT A.PALLET_ID AS pallet_id,
         D.SKU_ID AS sku_id,
         A.VWH_ID AS VWH_ID,
         count(distinct 
         case
         when a.pallet_id is not null
         then
         d.sku_id
         end) over(partition by A.PALLET_ID),
         sum(d.quantity),
         sum(case
               when A.location_id is null then
                d.quantity
             end)
    FROM SRC_CARTON A
   INNER JOIN SRC_CARTON_DETAIL D
      ON A.CARTON_ID = D.CARTON_ID
 <if> WHERE A.CARTON_STORAGE_AREA = :CARTON_STORAGE_AREA</if>
     AND A.SUSPENSE_DATE IS NULL
   GROUP BY A.PALLET_ID, D.SKU_ID, A.VWH_ID),

unreplenishable_sku AS
 (SELECT msp.SKU_ID,
         msp.VWH_ID,
         count(distinct msp.pallet_id) as count_pallets,
         sum(msp.pieces_on_pallet) as pieces_on_all_pallets,
         MIN(msp.PALLET_ID) as min_pallet,
         MAX(msp.PALLET_ID) as max_pallet,
         count(distinct case
                 when count_sku_on_pallet > 1 then
                  msp.pallet_id
               end) as count_impure_pallets,
         sum(case
               when count_sku_on_pallet > 1 then
                msp.pieces_on_pallet
             end) as pieces_on_impure_pallets,
         MIN(case
               when count_sku_on_pallet > 1 then
                msp.PALLET_ID
             end) as min_impure_pallet,
         MAX(case
               when count_sku_on_pallet > 1 then
                msp.PALLET_ID
             end) as max_impure_pallet,
         
         SUM(msp.pieces_not_on_location) as pieces_not_on_location,
         SUM(case
               when msp.pallet_id is null then
                msp.pieces_on_pallet
             end) as pieces_not_on_pallet
    FROM mix_SKU_pallet msp
   group by msp.SKU_ID, msp.VWH_ID
  having sum(case when count_sku_on_pallet > 1 then msp.pieces_on_pallet end) > 0 OR SUM(case when msp.pallet_id is null then msp.pieces_on_pallet end) > 0 OR SUM(msp.pieces_not_on_location) is not null
  
  )

SELECT ags.sku_id,
       ags.vwh_id,
       msk.style,
       msk.color,
       msk.dimension,
       msk.sku_size,
       ags.QUANTITY_ORDERED,
       urs.pieces_on_impure_pallets as pieces_on_impure_pallets,
       urs.min_impure_pallet||' '||urs.max_impure_pallet AS SOME_of_impure_pallets,
       NVL2(aas.location_count, NULL, 1) as has_no_assigned_locations,
       urs.pieces_not_on_location,
       urs.pieces_not_on_pallet
  FROM GROUPED_ORDERED_SKU AGS
  LEFT OUTER JOIN master_sku msk
  on ags.sku_id = msk.sku_id
  LEFT OUTER JOIN ALL_ASSIGNED_SKUS AAS
    ON ags.sku_id = aas.sku_id
   AND ags.vwh_id = aas.vwh_id
  LEFT OUTER JOIN unreplenishable_sku urs
    ON ags.sku_id = urs.sku_id
   AND ags.vwh_id = urs.vwh_id
 where (aas.sku_id is null or urs.sku_id is not null)
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbBucketId" Type="Int32" Direction="Input" Name="bucket_id" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Name="WAREHOUSE_LOCATION_ID"
                Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Name="vwh_id" Direction="Input" />
            <asp:ControlParameter ControlID="tbCustomers" Type="String" Name="customer_id" />
            <asp:ControlParameter ControlID="ctlAvailableInventoryArea" Type="String" Name="STORAGE_AREA"
                Direction="Input" />
            <asp:ControlParameter ControlID="ctlReplenishmentInventoryArea" Type="String" Name="CARTON_STORAGE_AREA"
                Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DefaultSortExpression="style;color;dimension;sku_size" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="Vwh" SortExpression="VWH_ID" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size" />
            <eclipse:MultiBoundField DataFields="QUANTITY_ORDERED" HeaderText="Ordered Pieces"
                SortExpression="QUANTITY_ORDERED" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
            <jquery:IconField HeaderText="Location Assigned ?" DataField="has_no_assigned_locations"
                DataFieldValues="1" IconNames="ui-icon-closethick" HeaderToolTip="Does SKU has location in picking area."
                AccessibleHeaderText="AssignedLocation">
                <ItemStyle HorizontalAlign="Center" />
            </jquery:IconField>
            <eclipse:MultiBoundField DataFields="pieces_on_impure_pallets" HeaderToolTip="Distinct SKU Pieces on the same pallet."
                HeaderText="Pieces on Impure Pallet" SortExpression="pieces_on_impure_pallets"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" AccessibleHeaderText="ImpurePalletsPieces">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SOME_of_impure_pallets" HeaderText="Impure Pallets"
                HeaderToolTip="Pallet with more than one SKU" SortExpression="SOME_of_impure_pallets"
                AccessibleHeaderText="ImpurePallets" />
            <eclipse:MultiBoundField DataFields="pieces_not_on_location" HeaderText="Pieces in replenishment Area But|Not on Location"
                SortExpression="pieces_not_on_location" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right"
                AccessibleHeaderText="NoLocation" />
            <eclipse:MultiBoundField DataFields="pieces_not_on_pallet" HeaderText="Pieces in replenishment Area But|Not on Pallet"
                SortExpression="pieces_not_on_pallet" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right"
                AccessibleHeaderText="NoPallet" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

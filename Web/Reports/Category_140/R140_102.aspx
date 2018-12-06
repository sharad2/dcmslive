<%@ Page Title="Unprocessed SKU Detail Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7123 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_102.aspx $
 *  $Id: R140_102.aspx 7123 2014-08-07 04:49:14Z skumar $
 * Version Control Template Added.
--%>

<script runat="server">
    /// &lt;summary&gt;
    /// When grid is load and main grid show the row then the form view visible ture
    /// &lt;/summary&gt;
    /// &lt;param name="sender"&gt;&lt;/param&gt;
    /// &lt;param name="e"&gt;&lt;/param&gt;

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
            var index = gv.Columns.IndexOf(gv.Columns.OfType<DataControlField>().First(p => p.AccessibleHeaderText == "AreaQty"));
            var addedColumns = from col in list
                               let tokens = col.AccessibleHeaderText.Split(',')
                               let building = tokens[0]
                               let areaName = tokens[1]
                               orderby building, areaName
                               select new
                               {
                                   Column = col,
                                   AreaName = areaName,
                                   Building = building,
                                   HeaderText = string.Format("Pieces in {0}|{1}", building, areaName)
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
        var areaName = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA").First().Value;
        var buildingId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
        var qty = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "QUANTITY").First().Value;
        var area_type = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "STORE_WHAT").First().Value;
        var request = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "REQUEST").First().Value;
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA_ID").First().Value;
        var colName = string.Format("{0}_{1}", areaName, buildingId);
        var col = tbl.Columns[colName];
        int pieces;
        DataControlField retVal = null;
        if (int.TryParse(qty, out pieces) && pieces > 0)
        {
            if (col == null && !string.IsNullOrEmpty(areaName))
            {
                col = tbl.Columns.Add(colName, typeof(int));


                if (area_type == "CTN" && request == "REQUEST")
                {
                    //if ()
                    //{ 
                    var reportUrl = string.Format("R30_06.aspx?upc_code={{0}}&VWH_ID={{1}}&inventory_storage_area={0}&warehouse_location_id={1}&Req_module_code=REQ2", areaId, buildingId);
                    var bf = new SiteHyperLinkField
                    {

                        DataTextField = colName,
                        DataTextFormatString = "{0:#,###}",
                        HeaderText = string.Format("Pieces in {0}|{1}", buildingId, areaName),
                        AccessibleHeaderText = string.Format("{0},{1}", buildingId, areaName, areaId),
                        DataNavigateUrlFields = new[] { "UPC_CODE", "VWH_ID" },
                        DataNavigateUrlFormatString = reportUrl,
                        DataSummaryCalculation = SummaryCalculationType.ValueSummation,
                        //HeaderToolTip = string.Format("Area {0} - Building {1}", area, buildingId),
                    };
                    bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                    bf.FooterStyle.HorizontalAlign = HorizontalAlign.Right;
                    //list.Add(bf);
                    retVal = bf;

                }
                else
                {
                    var bf = new MultiBoundField
                    {

                        HeaderText = string.Format("Pieces in {0}|{1}", buildingId, areaName),
                        DataFields = new[] { colName },
                        DataFormatString = "{0:N0}",
                        AccessibleHeaderText = string.Format("{0},{1}", buildingId, areaName, areaId),
                        DataSummaryCalculation = SummaryCalculationType.ValueSummation,
                        DataFooterFormatString = "{0:N0}"
                    };
                    bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                    bf.FooterStyle.HorizontalAlign = HorizontalAlign.Right;
                    retVal = bf;
                }

            }

            row[colName] = pieces;
        }
        return retVal;


    }
    
    

    protected override void OnPreRender(EventArgs e)
    {
        if (gv.Rows.Count > 0)
        {
            fvTotalCountBox.Visible = true;
        }
        else
        {
            fvTotalCountBox.Visible = false;
        }
    }  
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report lists all the details of SKUs which belongs to unprocessed cartons(Boxes). This report also inform that fucket how many boxes are yet to be Expedite. The report excludes the SKUs which are marked as underpitch. Request module code is suffixed with carton areas , for SKU's which have request against them." />
    <meta name="ReportId" content="140.102" />
    <meta name="Browsable" content="false" />
    <meta name="ChangeLog" content="Added new column which will show standard case quantity of the SKU." />
    <meta name="Version" content="$Id: R140_102.aspx 7123 2014-08-07 04:49:14Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Bucket Id" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id" ToolTip="Enter ID of the bucket for which you want to see this report">
                    <Validators>
                    <i:Value ValueType="Integer" MaxLength="5" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  ToolTip="Choose the desired virtual warehouse for which you want to see this report" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
            <SelectSql>
   with Bucket_detail as(select max(NVL(p.warehouse_location_id,'Unknown')) as warehouse_location,
         max(b.name) as bucket_name,         
         0 as piecs,
         p.bucket_id as bucket_id
    from ps p
   inner join bucket b
      on p.bucket_id = b.bucket_id
   where p.vwh_id =:vwh_id
     and p.bucket_id =:bucket_id
     group by p.bucket_id
     ),
 Piece_detail as
  ( 
  select max(NVL(p.warehouse_location_id,'Unknown'))        as warehouse_location,
         max(bkt.name)        as bucket_name,
         nvl(count(distinct bx.ucc128_id),0) as pieces,
         p.bucket_id as bucket_id
    from box bx
   inner join ps p
      on p.pickslip_id = bx.pickslip_id
   inner join bucket bkt
      on bkt.bucket_id = p.bucket_id
     inner join boxdet bd on
        bx.ucc128_id=bd.ucc128_id
   where p.vwh_id =:vwh_id
     and p.bucket_id =:bucket_id
      and  bx.ia_id_copy = 'NOA'
     group by p.bucket_id
     )
select a1.warehouse_location as warehouse_location_id,
a1.bucket_name as bucket_name ,
nvl(b1.pieces,0) as count_box
from Bucket_detail a1
left outer join Piece_detail b1
on a1.bucket_id=b1.bucket_id        
            </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbBucketId" Name="bucket_id" Direction="Input" Type="Int32" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Direction="Input" Type="String" />
        </SelectParameters>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
    </oracle:OracleDataSource>
    <asp:FormView runat="server" ID="fvTotalCountBox" DataSourceID="ds1" CssClass="ui-widget"
        Visible="false">
        <HeaderTemplate>
            <br />
        </HeaderTemplate>
        <ItemTemplate>
            Bucket Name :
            <asp:Label ID="Label1" runat="server" Font-Bold="true" Text=' <%# Eval("bucket_name") %>' />
            &nbsp&nbsp&nbsp&nbsp Unprocessed Cartons:
            <asp:Label ID="Label2" runat="server" Font-Bold="true" Text=' <%# Eval("count_box", "{0:N0}") %>' />
         &nbsp&nbsp&nbsp&nbsp Building :
            <asp:Label ID="Label3" runat="server" Font-Bold="true" Text='<%# Eval("warehouse_location_id") %>' />
         </ItemTemplate>
        <FooterTemplate>
            <br />
        </FooterTemplate>
    </asp:FormView>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataSet" 
        CancelSelectOnNullParameter="false">
        <SelectSql> 
            with ORDERED_SKU AS
 (SELECT PS.VWH_ID AS VWH_ID,
         PSDET.UPC_CODE AS UPC_CODE,
         SUM(PSDET.PIECES_ORDERED) AS EXPECTED_PIECES,
         max(ms.style) as style,
         max(ms.color) as color,
         max(ms.dimension) as dimension,
         max(ms.sku_size) as sku_size,
         MAX(MS.STANDARD_CASE_QTY) AS standard_case_qty
    FROM PS PS
   INNER JOIN PSDET PSDET
      ON PS.PICKSLIP_ID = PSDET.PICKSLIP_ID
   INNER JOIN MASTER_SKU MS
      ON MS.UPC_CODE = PSdet.UPC_CODE
    LEFT OUTER JOIN BUCKETSKU BU
      ON PS.BUCKET_ID = BU.BUCKET_ID
     and MS.UPC_CODE = BU.UPC_CODE
   WHERE BU.UNDERPITCH_FLAG IS NULL
      <if>and PS.BUCKET_ID =:bucket_id </if>
   <if>AND PS.VWH_ID =:vwh_id</if>
     AND PS.TRANSFER_DATE IS NULL
     and ps.reporting_status = 'UNDER PROCESS'
   GROUP BY PS.VWH_ID, PSDET.UPC_CODE),
SKU_IN_BOXES AS
 (SELECT /*+index (box BOX_PS_FK_I) index(bd BOXDET_PK)*/
   PS.VWH_ID AS VWH_ID,
   BD.UPC_CODE AS UPC_CODE,
   SUM(BD.current_pieces) as picked_pieces,
   MIN(M.STYLE) AS STYLE,
   MIN(M.COLOR) AS COLOR,
   MIN(M.DIMENSION) AS DIMENSION,
   MIN(M.SKU_SIZE) AS SKU_SIZE,
   MIN(M.sku_id) as sku_id
    FROM BUCKET BUCKET
   INNER JOIN PS PS
      ON PS.BUCKET_ID = BUCKET.BUCKET_ID
   INNER JOIN BOX BOX
      ON BOX.PICKSLIP_ID = PS.PICKSLIP_ID
   INNER JOIN BOXDET BD
      ON BOX.UCC128_ID = BD.UCC128_ID
     AND BOX.PICKSLIP_ID = BD.PICKSLIP_ID
    LEFT OUTER JOIN BUCKETSKU BU
      ON BUCKET.BUCKET_ID = BU.BUCKET_ID
     AND BD.UPC_CODE = BU.UPC_CODE
   INNER JOIN MASTER_SKU M
      ON M.UPC_CODE = BD.UPC_CODE
   WHERE 1 = 1
 <if>AND PS.BUCKET_ID =:bucket_id</if> 
 <if>AND PS.VWH_ID =:vwh_id</if>
     AND BU.UNDERPITCH_FLAG IS NULL
     AND ps.reporting_status = 'UNDER PROCESS'
     AND box.stop_process_date IS NULL
     AND bd.stop_process_date IS NULL
     AND ps.transfer_date is null
   GROUP BY PS.VWH_ID, BD.UPC_CODE),
RESV_SKU AS
 (SELECT RESV.UPC_CODE AS UPC_CODE,
         RESV.VWH_ID AS VWH_ID,
         MAX(RESV.IA_ID) AS PICKING_AREA,
         SUM(RESV.PIECES_RESERVED) AS RESERVED_QUANTITY
    FROM RESVDET RESV
   WHERE resv.ia_id in
         (select pitch_ia_id from bucket where bucket_id = :bucket_id)
     <if>and RESV.VWH_ID =:vwh_id</if>
   GROUP BY RESV.UPC_CODE, RESV.VWH_ID),
IALOC_SKU AS
 (SELECT MAX(IA.LOCATION_ID) AS MAX_LOCATION_ID,
         MIN(IA.LOCATION_ID) AS MIN_LOCATION_ID,
         COUNT(DISTINCT IA.LOCATION_ID) AS LOCATION_COUNT,
         IA.ASSIGNED_UPC_CODE AS UPC_CODE,
         IA.VWH_ID AS VWH_ID,
         MAX(DECODE(IA.ASSIGNED_UPC_MAX_PIECES,
                    NULL,
                    '0',
                    IA.ASSIGNED_UPC_MAX_PIECES)) AS RAIL_CAPACITY,
         SUM(IA.ASSIGNED_UPC_MAX_PIECES) AS FPK_CAPACITY,
         SUM(IAC.NUMBER_OF_UNITS) AS FPK_QUANTITY,
         max(ia.freeze_flag) as is_location_freezed,
         MAX(ia.location_status) as cyc_marked
    FROM IALOC IA
    LEFT OUTER JOIN IALOC_CONTENT IAC
      ON IA.IA_ID = IAC.IA_ID
     AND IA.LOCATION_ID = IAC.LOCATION_ID
   WHERE 1 = 1
     <if>and IA.VWH_ID =:vwh_id</if>
     <if>AND NVL(IA.WAREHOUSE_LOCATION_ID,'Unknown') =:warehouse_location_id</if>
     AND IA.LOCATION_TYPE = 'RAIL'
     AND IA.CAN_ASSIGN_SKU = 1
   GROUP BY IA.ASSIGNED_UPC_CODE, IA.VWH_ID),
CTN_SKU AS
 (SELECT CTN.VWH_ID AS VWH_ID,
         NVL(TIA.SHORT_NAME,CTN.carton_storage_area) || DECODE(TIA.LOCATION_NUMBERING_FLAG,
                                  'Y',
                                  NVL2(RAC.CARTON_ID,
                                       '-RS',
                                       NVL2(CTNDET.REQ_MODULE_CODE,
                                            ('-' || CTNDET.REQ_MODULE_CODE),
                                            ''))) AS AREA,
         MAX(CTN.carton_storage_area) AS AREA_ID,
         CASE
              WHEN CTNDET.REQ_MODULE_CODE = 'REQ2'
                   AND TIA.LOCATION_NUMBERING_FLAG ='Y' THEN
               'REQUEST'
              ELSE
               'NOTREQUEST'
            END AS REQUEST,
         SUM(CTNDET.QUANTITY) AS QUANTITY,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,MSL.WAREHOUSE_LOCATION_ID,'Unknown') as WAREHOUSE_LOCATION_ID,
         MAX(TIA.STORES_WHAT) AS STORE_WHAT,
         OS.UPC_CODE AS UPC_CODE
    FROM SRC_CARTON CTN
    LEFT OUTER JOIN SRC_CARTON_DETAIL CTNDET
      ON CTN.CARTON_ID = CTNDET.CARTON_ID
    LEFT OUTER JOIN REPLENISH_AISLE_CARTON RAC
      ON CTN.CARTON_ID = RAC.CARTON_ID
     LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON CTN.carton_storage_area = msl.storage_area
     and CTN.LOCATION_ID = MSL.LOCATION_ID
      LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   LEFT OUTER JOIN TAB_QUALITY_CODE  TQC ON 
            CTN.QUALITY_CODE = TQC.QUALITY_CODE
   INNER JOIN ORDERED_SKU OS
      ON OS.STYLE = CTNDET.STYLE
     AND OS.COLOR = CTNDET.COLOR
     AND OS.DIMENSION = CTNDET.DIMENSION
     AND OS.SKU_SIZE = CTNDET.SKU_SIZE
  <if>WHERE CTN.VWH_ID   = CAST(:vwh_id AS VARCHAR2(255))</if>
      AND TQC.ORDER_QUALITY ='Y' 
   GROUP BY CTN.VWH_ID,
            NVL(TIA.SHORT_NAME, CTN.carton_storage_area) || DECODE(TIA.LOCATION_NUMBERING_FLAG,
                                     'Y',
                                     NVL2(RAC.CARTON_ID,
                                          '-RS',
                                          NVL2(CTNDET.REQ_MODULE_CODE,
                                               ('-' || CTNDET.REQ_MODULE_CODE),
                                               ''))),
            OS.UPC_CODE,CASE
              WHEN CTNDET.REQ_MODULE_CODE = 'REQ2'
                   AND TIA.LOCATION_NUMBERING_FLAG ='Y' THEN
               'REQUEST'
              ELSE
               'NOTREQUEST'
            END,
            COALESCE(TIA.WAREHOUSE_LOCATION_ID,MSL.WAREHOUSE_LOCATION_ID,'Unknown')
  
  UNION
  
  SELECT MRI.VWH_ID AS VWH_ID,
         TIA.SHORT_NAME AS AREA,
         MAX(MRI.SKU_STORAGE_AREA) AS AREA_ID,
         'REQUEST' as REQUEST,
         SUM(MRI.QUANTITY) AS QUANTITY,
         nvl(TIA.WAREHOUSE_LOCATION_ID,'Unknown') as warehouse_location_id,
         MAX(TIA.STORES_WHAT) AS STORE_WHAT,
         BS.UPC_CODE AS UPC_CODE
    FROM MASTER_RAW_INVENTORY MRI
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON MRI.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   INNER JOIN MASTER_SKU BS
      ON BS.STYLE = MRI.STYLE
     AND BS.COLOR = MRI.COLOR
     AND BS.DIMENSION = MRI.DIMENSION
     AND BS.SKU_SIZE = MRI.SKU_SIZE
   WHERE TIA.STORES_WHAT = 'SKU'
     AND TIA.UNUSABLE_INVENTORY IS NULL
      <if>AND MRI.VWH_ID   =:vwh_id</if>
   GROUP BY MRI.VWH_ID,
            TIA.SHORT_NAME,
            BS.UPC_CODE,
            nvl(TIA.WAREHOUSE_LOCATION_ID,'Unknown')
  UNION
  
  SELECT IL.VWH_ID AS VWH_ID,
         NVL(IL.SHORT_NAME,IL.AREA_ID) AS AREA,
         IL.AREA_ID AS AREA_ID,
         null as REQUEST,
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.RESERVED_UNITS, 0) AS Quantity,
         NVL(IL.WAREHOUSE_LOCATION_ID, 'Unknowm') as warehouse_location_id,
         'SKU' as area_type,
         il.upc_code
    FROM (SELECT IA.SHORT_NAME AS SHORT_NAME,
                 MAX(IA.IA_ID) AS AREA_ID,
                 msku.upc_code as upc_code,
                 I.VWH_ID AS VWH_ID,
                 NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown') as WAREHOUSE_LOCATION_ID,
                 SUM(IAC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS
            FROM IALOC_CONTENT IAC
           INNER JOIN IALOC I
              ON I.IA_ID = IAC.IA_ID
             AND I.LOCATION_ID = IAC.LOCATION_ID
             inner join ia ia 
               on i.ia_id = ia.ia_id
           INNER JOIN MASTER_SKU MSKU
              ON MSKU.UPC_CODE = IAC.IACONTENT_ID
           <if>WHERE I.VWH_ID =:vwh_id</if>
           GROUP BY IA.SHORT_NAME,
                    msku.upc_code,
                    I.VWH_ID,
                    NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown')) IL
    LEFT OUTER JOIN (SELECT RD.IA_ID AS IA_ID,
                            msku.upc_code as upc_code,
                            SUM(RD.PIECES_RESERVED) RESERVED_UNITS,
                            RD.VWH_ID,
                            NVL(iac.warehouse_location_id, 'Unknown') as warehouse_location_id
                       FROM RESVDET RD
                      INNER JOIN MASTER_SKU MSKU
                         ON RD.UPC_CODE = MSKU.UPC_CODE
                       left outer join ialoc iac
                         on iac.ia_id = rd.ia_id
                        and iac.location_id = rd.location_id
                      GROUP BY msku.upc_code,
                               RD.VWH_ID,
                               RD.IA_ID,
                               NVL(iac.warehouse_location_id, 'Unknown')) R
      ON IL.AREA_ID = R.IA_ID
     AND IL.upc_code = R.upc_code
     AND IL.VWH_ID = R.VWH_ID
     and Il.warehouse_location_id = R.warehouse_location_id),
FINAL_QUERY AS
 (SELECT OS.UPC_CODE AS UPC_CODE,
         OS.STYLE AS STYLE,
         OS.COLOR AS COLOR,
         OS.DIMENSION AS DIMENSION,
         OS.SKU_SIZE AS SKU_SIZE,
         OS.VWH_ID as VWH_ID,
         os.standard_case_qty as standard_case_qty,
         IAS.RAIL_CAPACITY AS RAIL_CAPACITY,
         OS.EXPECTED_PIECES AS EXPECTED_PIECES,
         os.expected_pieces - nvl(bs.picked_pieces, 0) as UNPROCESSED_PIECES,
         NVL(RS.RESERVED_QUANTITY, 0) AS ALLOCATED_QUANTITY,
         (NVL(IAS.FPK_QUANTITY, 0) - NVL(RS.RESERVED_QUANTITY, 0)) UNALLOCATTED_QTY,
         CS.AREA AS AREA,
         cs.area_id as area_id,
         cs.REQUEST as REQUEST,
         CS.QUANTITY AS QUANTITY,
         CS.STORE_WHAT AS STORE_WHAT,
         RS.PICKING_AREA,
         CS.WAREHOUSE_LOCATION_ID,
         GREATEST(0,
                  (os.expected_pieces - nvl(bs.picked_pieces, 0)) -
                  (NVL(IAS.FPK_QUANTITY, 0) - NVL(RS.RESERVED_QUANTITY, 0))) SHORTAGE_PIECES,
         IAS.MIN_LOCATION_ID AS MIN_FPK_LOCATION_ID,
         IAS.MAX_LOCATION_ID AS MAX_FPK_LOCATION_ID,
         IAS.LOCATION_COUNT AS FPK_LOCATION_COUNT,
         ias.is_location_freezed as is_location_freezed,
         nvl2(ias.cyc_marked,'Y','') as cyc_marked
    FROM ordered_sku os
    LEFT OUTER JOIN RESV_SKU RS
      ON os.VWH_ID = RS.VWH_ID
     AND os.UPC_CODE = RS.UPC_CODE
    LEFT OUTER JOIN IALOC_SKU IAS
      ON os.VWH_ID = IAS.VWH_ID
     AND os.UPC_CODE = IAS.UPC_CODE
    LEFT OUTER JOIN CTN_SKU CS
      ON os.VWH_ID = CS.VWH_ID
     AND os.UPC_CODE = CS.UPC_CODE
    left OUTER JOIN SKU_IN_BOXES bs
      ON OS.VWH_ID = BS.VWH_ID
     AND OS.UPC_CODE = BS.UPC_CODE
   where (os.expected_pieces - nvl(bs.picked_pieces, 0)) > 0
     )

SELECT *
  FROM FINAL_QUERY PIVOT XML(SUM(QUANTITY) AS QUANTITY FOR(AREA, WAREHOUSE_LOCATION_ID, STORE_WHAT,REQUEST,area_id) IN(ANY,
                                                                                                       ANY,
                                                                                                       ANY,ANY,ANY))
        </SelectSql> 
        <SelectParameters>
        <asp:ControlParameter ControlID="tbBucketId" Name="bucket_id" Direction="Input" Type="Int32" />
        <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Direction="Input" Type="String" />
        <asp:QueryStringParameter Name="warehouse_location_id" Type="String" QueryStringField="warehouse_location_id" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="false"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="shortage_pieces {0:I} NULLS LAST;upc_code;">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="upc_code" SortExpression="upc_code" ItemStyle-HorizontalAlign="Left" HeaderText="UPC" HeaderToolTip="UPC Code of the SKU" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="Style" ItemStyle-HorizontalAlign="Left" HeaderToolTip="Style of the SKU" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" HeaderToolTip="Color of the SKU"/>
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" HeaderToolTip="Dimension of the SKU" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" HeaderToolTip="Size of the SKU" />
            <eclipse:MultiBoundField DataFields="rail_capacity" HeaderToolTip="Capacity of the location where the SKU is assigned"
                HeaderText="Rail Capacity">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
              <eclipse:MultiBoundField DataFields="standard_case_qty" SortExpression="standard_case_qty" ItemStyle-HorizontalAlign="Right" HeaderText="Standard Case Qty" HeaderToolTip="Standard Case Quantity of the SKU" />
            <eclipse:MultiBoundField DataFields="expected_pieces" HeaderToolTip="Showing total pieces in the bucket for those pickslip which are under process."
                HeaderText="Bucket Quantity|Total" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" 
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="unprocessed_pieces" HeaderToolTip="Pieces of the SKU which are still not processed "
                HeaderText="Bucket Quantity|Unprocessed" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" 
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="allocated_quantity" HeaderToolTip="Total pieces which are already reserved."
                HeaderText="Pieces In|Allocated FPK" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataSummaryCalculation="ValueSummation" AppliedFiltersControlID="ctlButtonBar$af"
                DataNavigateUrlFormatString="R140_106.aspx?upc_code={0}&PICKING_AREA={1}" DataNavigateUrlFields="upc_code,PICKING_AREA">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="unallocatted_qty" AccessibleHeaderText="AreaQty" HeaderToolTip="Total pieces which are not reserved for any one."
                HeaderText="Pieces In|Unallocated FPK in Your Building" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="shortage_pieces" SortExpression="shortage_pieces {0:I} NULLS LAST" HeaderToolTip="The difference between the SKU unprocessed quantity and available quantity in Forward Pick Area."
                HeaderText="Shortage Pieces" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <asp:TemplateField HeaderText="Assigned Locations"  HeaderStyle-Wrap="true" SortExpression="min_fpk_location_id">
                <ItemTemplate>
                    <eclipse:MultiValueLabel  runat="server" ToolTip="Showing min and max location of the SKU" DataFields="fpk_location_count, min_fpk_location_id, max_fpk_location_id" />
                </ItemTemplate>
            </asp:TemplateField>
             <jquery:IconField DataField="is_location_freezed" HeaderText="Is Any Assigned Location Freeze?" HeaderToolTip="Indicating freeze SKU locaiton. If SKU is assigned to multiple locations and any of these assigned locations is freeze then freeze indicator will get displayed."
                DataFieldValues="Y" IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center"
                SortExpression="is_location_freezed"/>

             <jquery:IconField DataField="cyc_marked" HeaderText="Is Any Assigned Location Marked For CYC?" HeaderToolTip="Indicating CYC marked location. If SKU is assigned to multiple locations and any of these assigned locations is marked for CYC then CYC indicator will get displayed."
                DataFieldValues="Y" IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center"
                SortExpression="cyc_marked"/>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

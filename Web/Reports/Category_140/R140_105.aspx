<%@ Page Title="Forward Pick Shortage Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7123 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_105.aspx $
 *  $Id: R140_105.aspx 7123 2014-08-07 04:49:14Z skumar $
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
        }
    }
    private static DataControlField ParsePivotItem(System.Data.DataTable tbl, System.Data.DataRowView row, XElement pivotItem)
    {
        var areaName = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA").First().Value;
        var areaId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "AREA_ID").First().Value;
        var buildingId = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "WAREHOUSE_LOCATION_ID").First().Value;
        var qty = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "QUANTITY").First().Value;
        var area_type = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "STORE_WHAT").First().Value;
        var request = pivotItem.Elements("column").Where(p => p.Attribute("name").Value == "REQUEST").First().Value;
        var colName = string.Format("{0}_{1}", areaName, buildingId);
        DataControlField retVal = null;
        var col = tbl.Columns[colName];
        int pieces;

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
        base.OnPreRender(e);

    }
    protected void gv_OnRowDataBound(object sender, GridViewRowEventArgs e)    {
       string Location;      
      if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Location = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "min_fpk_location_id"));
        var cellIndex = 0;
                cellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "Location" ? i : -1)
                       .Single(p => p >= 0);
                e.Row.Cells[cellIndex].ToolTip = "Raja ";
        }    
        
    }   

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="It displays all SKUs in the boxes of bucket for which pieces are short in forward pick area.This report does not display the SKUs if they are marked as underpitch." />
    <meta name="ReportId" content="140.105" />
    <meta name="Browsable" content="false" />
    <meta name="ChangeLog" content="Added new column which will show standard case quantity of the SKU." />
    <meta name="Version" content="$Id: R140_105.aspx 7123 2014-08-07 04:49:14Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id" FriendlyName="Bucket" ToolTip="Enter ID of the bucket for which you want to see this report">
                    <Validators>
                        <i:Value ValueType="Integer" MaxLength="5" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Choose the desired virtual warehouse for which you want to see this report" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide you the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
        <SelectSql>
            select count(distinct b.ucc128_id) count_box, 
              max(bkt.name) as bucket_name,
              MAX(NVL(ps.warehouse_location_id,'Unknown')) as warehouse_location_id
        from box b
       inner join ps on ps.pickslip_id = b.pickslip_id
       inner join bucket bkt on bkt.bucket_id = ps.bucket_id
       where b.ia_id_copy = 'NOA'
         and bkt.bucket_id = cast(:bucket_id as number)
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbBucketId" Name="bucket_id" Direction="Input" Type="Int32" />
        </SelectParameters>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
    </oracle:OracleDataSource>
    <asp:FormView runat="server" Visible="false" DataSourceID="ds1" ID="fvTotalCountBox"
        CssClass="ui-widget">
        <HeaderTemplate>
            <br />
        </HeaderTemplate>
        <ItemTemplate>
            Bucket Name :
            <asp:Label ID="Label1" runat="server" Font-Bold="true" Text='<%# Eval("bucket_name") %>' />
            &nbsp&nbsp&nbsp&nbsp Unprocessed Cartons:
            <asp:Label ID="Label2" runat="server" Font-Bold="true" Text='<%# Eval("count_box", "{0:N0}") %>' />
            &nbsp&nbsp&nbsp&nbsp Building :
            <asp:Label ID="Label3" runat="server" Font-Bold="true" Text='<%# Eval("warehouse_location_id") %>' />

        </ItemTemplate>
        <FooterTemplate>
            <br />
        </FooterTemplate>
    </asp:FormView>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="false" DataSourceMode="DataSet">
        <SelectSql>   
  WITH BUCKET_SKU AS
 (SELECT /*+index (box BOX_PS_FK_I) index(bd BOXDET_PK)*/
   PS.VWH_ID AS VWH_ID,
   BD.UPC_CODE AS UPC_CODE,
   SUM(CASE
         WHEN BOX.IA_ID IS NULL THEN
          BD.EXPECTED_PIECES
       END) AS UNPROCESSED_PIECES,
   MIN(M.STYLE) AS STYLE,
   MIN(M.COLOR) AS COLOR,
   MIN(M.DIMENSION) AS DIMENSION,
   MIN(M.SKU_SIZE) AS SKU_SIZE,
   MAX(M.STANDARD_CASE_QTY) AS standard_case_qty
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
    <if>WHERE PS.BUCKET_ID = cast(:bucket_id as number(5))</if> 
   <if>AND PS.VWH_ID = CAST(:vwh_id as varchar2(255))</if>
     AND BU.UNDERPITCH_FLAG IS NULL
   GROUP BY PS.VWH_ID, BD.UPC_CODE),
ORDERED_SKU AS
 (SELECT PS.VWH_ID AS VWH_ID,
         PSDET.UPC_CODE AS UPC_CODE,
         SUM(PSDET.PIECES_ORDERED) AS EXPECTED_PIECES
    FROM PS PS
   INNER JOIN PSDET PSDET
      ON PS.PICKSLIP_ID = PSDET.PICKSLIP_ID
   <if>WHERE PS.BUCKET_ID = cast(:bucket_id as number(5))</if> 
   <if>AND PS.VWH_ID = CAST(:vwh_id as varchar2(255))</if>
   GROUP BY PS.VWH_ID, PSDET.UPC_CODE),
RESV_SKU AS
 (SELECT RESV.UPC_CODE AS UPC_CODE,
         RESV.VWH_ID AS VWH_ID,
         SUM(RESV.PIECES_RESERVED) AS RESERVED_QUANTITY
    FROM RESVDET RESV
   WHERE resv.ia_id in
         (select pitch_ia_id from bucket where bucket_id = :bucket_id)
       <if>AND RESV.VWH_ID = CAST(:vwh_id as varchar2(255))</if>
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
         max(ia.freeze_flag) as Is_Location_Freezed,
         max(ia.location_status) as cyc_marked
    FROM IALOC IA
    LEFT OUTER JOIN IALOC_CONTENT IAC
      ON IA.IA_ID = IAC.IA_ID
     AND IA.LOCATION_ID = IAC.LOCATION_ID
   <if>WHERE IA.VWH_ID = CAST(:vwh_id as varchar2(255))</if>
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
         BS.UPC_CODE AS UPC_CODE
    FROM SRC_CARTON CTN
    LEFT OUTER JOIN SRC_CARTON_DETAIL CTNDET
      ON CTN.CARTON_ID = CTNDET.CARTON_ID
    LEFT OUTER JOIN REPLENISH_AISLE_CARTON RAC
      ON CTN.CARTON_ID = RAC.CARTON_ID
     LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON CTN.carton_storage_area = msl.storage_area
     and CTN.LOCATION_ID = MSL.LOCATION_ID
       LEFT OUTER JOIN TAB_QUALITY_CODE  TQC ON 
            CTN.QUALITY_CODE = TQC.QUALITY_CODE
      LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   INNER JOIN BUCKET_SKU BS
      ON BS.STYLE = CTNDET.STYLE
     AND BS.COLOR = CTNDET.COLOR
     AND BS.DIMENSION = CTNDET.DIMENSION
     AND BS.SKU_SIZE = CTNDET.SKU_SIZE
   <if>WHERE CTN.VWH_ID   = CAST(:vwh_id AS VARCHAR2(255))</if>
     AND TQC.ORDER_QUALITY ='Y'
   GROUP BY CTN.VWH_ID,
            NVL(TIA.SHORT_NAME,CTN.carton_storage_area) || DECODE(TIA.LOCATION_NUMBERING_FLAG,
                                     'Y',
                                     NVL2(RAC.CARTON_ID,
                                          '-RS',
                                          NVL2(CTNDET.REQ_MODULE_CODE,
                                               ('-' || CTNDET.REQ_MODULE_CODE),
                                               ''))),
            BS.UPC_CODE, CASE
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
         'NOTREQUEST' AS REQUEST,
         SUM(MRI.QUANTITY) AS QUANTITY,
         NVL(TIA.WAREHOUSE_LOCATION_ID,'Unknown') as WAREHOUSE_LOCATION_ID,
         MAX(TIA.STORES_WHAT) AS STORE_WHAT,
         BS.UPC_CODE AS UPC_CODE
    FROM MASTER_RAW_INVENTORY MRI
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON MRI.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   INNER JOIN BUCKET_SKU BS
      ON BS.STYLE = MRI.STYLE
     AND BS.COLOR = MRI.COLOR
     AND BS.DIMENSION = MRI.DIMENSION
     AND BS.SKU_SIZE = MRI.SKU_SIZE
   WHERE TIA.STORES_WHAT = 'SKU'
     AND TIA.UNUSABLE_INVENTORY IS NULL
    <if>AND MRI.VWH_ID   = CAST(:vwh_id AS VARCHAR2(255))</if>
   GROUP BY MRI.VWH_ID,
            TIA.SHORT_NAME,
            BS.UPC_CODE,
            NVL(TIA.WAREHOUSE_LOCATION_ID,'Unknown')

        UNION
 
  SELECT IL.VWH_ID AS VWH_ID,
         NVL(IL.short_name, IL.AREA_ID) as AREA,
         IL.AREA_ID AS AREA_ID,
         'NOTREQUEST' AS REQUEST,
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.RESERVED_UNITS, 0) AS QUANTITY,
         NVL(IL.WAREHOUSE_LOCATION_ID, 'Unknowm') as warehouse_location_id,
         'SKU' as STORE_WHAT,
         il.upc_code AS UPC_CODE
    FROM (SELECT IA.short_name AS short_name,
                 MAX(ia.ia_id) as AREA_ID,
                 msku.upc_code as upc_code,
                 I.VWH_ID AS VWH_ID,
                 NVL(I.WAREHOUSE_LOCATION_ID, 'Unknown') as WAREHOUSE_LOCATION_ID,
                 SUM(IAC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS
            FROM IALOC_CONTENT IAC
           INNER JOIN IALOC I
              ON I.IA_ID = IAC.IA_ID
            inner join ia ia 
               on i.ia_id = ia.ia_id
             AND I.LOCATION_ID = IAC.LOCATION_ID
           INNER JOIN MASTER_SKU MSKU
              ON MSKU.UPC_CODE = IAC.IACONTENT_ID
          <if>WHERE I.VWH_ID = CAST(:vwh_id as varchar2(255))</if>
           GROUP BY IA.short_name,
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
     and Il.warehouse_location_id = R.warehouse_location_id                   
            ),
FINAL_QUERY AS
 (SELECT BS.UPC_CODE AS UPC_CODE,
         BS.STYLE AS STYLE,
         BS.COLOR AS COLOR,
         bs.VWH_ID as VWH_ID,
         BS.DIMENSION AS DIMENSION,
         BS.SKU_SIZE AS SKU_SIZE,
         IAS.RAIL_CAPACITY AS RAIL_CAPACITY,
         OS.EXPECTED_PIECES AS EXPECTED_PIECES,
         BS.UNPROCESSED_PIECES AS UNPROCESSED_PIECES,
         NVL(RS.RESERVED_QUANTITY, 0) AS ALLOCATED_QUANTITY,
         (NVL(IAS.FPK_QUANTITY, 0) - NVL(RS.RESERVED_QUANTITY, 0)) UNALLOCATTED_QTY,
         bs.standard_case_qty as standard_case_qty,
         IAS.FPK_QUANTITY AS FPK_QUANTITY,
         CS.AREA AS AREA,
         CS.AREA_ID AS AREA_ID,
         CS.REQUEST,
         CS.QUANTITY AS QUANTITY,
         CS.STORE_WHAT AS STORE_WHAT,
         CS.WAREHOUSE_LOCATION_ID,
         BS.UNPROCESSED_PIECES -
         (NVL(IAS.FPK_QUANTITY, 0) - NVL(RS.RESERVED_QUANTITY, 0)) SHORTAGE_PIECES,
         IAS.MIN_LOCATION_ID AS MIN_FPK_LOCATION_ID,
         IAS.MAX_LOCATION_ID AS MAX_FPK_LOCATION_ID,
         IAS.LOCATION_COUNT AS FPK_LOCATION_COUNT,
         ias.Is_Location_Freezed as Is_Location_Freezed,
         nvl2(ias.cyc_marked,'Y','') as cyc_marked
    FROM BUCKET_SKU BS
    LEFT OUTER JOIN RESV_SKU RS
      ON BS.VWH_ID = RS.VWH_ID
     AND BS.UPC_CODE = RS.UPC_CODE
    LEFT OUTER JOIN IALOC_SKU IAS
      ON BS.VWH_ID = IAS.VWH_ID
     AND BS.UPC_CODE = IAS.UPC_CODE
    LEFT OUTER JOIN CTN_SKU CS
      ON BS.VWH_ID = CS.VWH_ID
     AND BS.UPC_CODE = CS.UPC_CODE
    LEFT OUTER JOIN ORDERED_SKU OS
      ON OS.VWH_ID = BS.VWH_ID
     AND OS.UPC_CODE = BS.UPC_CODE
   WHERE BS.UNPROCESSED_PIECES -
         (NVL(IAS.FPK_QUANTITY, 0) - NVL(RS.RESERVED_QUANTITY, 0)) > 0)
SELECT *
  FROM FINAL_QUERY PIVOT XML(SUM(QUANTITY) AS QUANTITY FOR(AREA, WAREHOUSE_LOCATION_ID, STORE_WHAT,REQUEST,AREA_ID) IN(ANY,
                                                                                                       ANY,
                                                                                                       ANY,ANY,ANY))
      </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbBucketId" Name="bucket_id" Direction="Input" Type="Int32" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Direction="Input" Type="String" />
            <asp:QueryStringParameter Name="warehouse_location_id" Type="String" QueryStringField="warehouse_location_id" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="false" OnRowDataBound="gv_OnRowDataBound"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="upc_code;shortage_pieces {0:I} NULLS LAST">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="upc_code" SortExpression="upc_code" HeaderText="UPC"  HeaderToolTip="UPC Code of the SKU"  ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="Style" ItemStyle-HorizontalAlign="Left" HeaderToolTip="Style of the SKU" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" HeaderToolTip="Color of the SKU" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" HeaderToolTip="Dimension of the SKU" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" HeaderToolTip="Size of the SKU" />
            <eclipse:MultiBoundField DataFields="rail_capacity" HeaderToolTip="Capacity of the location where the SKU is assigned"
                HeaderText="Rail Capacity">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
             <eclipse:MultiBoundField DataFields="standard_case_qty" SortExpression="standard_case_qty" ItemStyle-HorizontalAlign="Right" HeaderText="Standard Case Qty" HeaderToolTip="Standard Case Quantity of the SKU" />
            <eclipse:MultiBoundField DataFields="expected_pieces"  HeaderToolTip="Showing under process pickslips pieces for the passed bucket."
                HeaderText="Bucket Quantity|Total" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="unprocessed_pieces"  HeaderToolTip="Pieces of the SKU which are still not processed " AccessibleHeaderText="Unprocessed"
                HeaderText="Bucket Quantity|Unprocessed" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" 
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ALLOCATED_QUANTITY" HeaderToolTip="Total pieces which are already reserved."
                HeaderText="Pieces In|Allocated FPK" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="unallocatted_qty" AccessibleHeaderText="AreaQty" HeaderToolTip="Total pieces which are not reserved."
                HeaderText="Pieces In|Unallocated FPK in Your Building" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="shortage_pieces" SortExpression="shortage_pieces {0:I} NULLS LAST" HeaderToolTip="The difference between the SKU unprocessed quantity and available quantity in Forward Pick Area."
                HeaderText="Shortage Pieces" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
             <asp:TemplateField HeaderText="Assigned Location" AccessibleHeaderText="Location" HeaderStyle-Wrap="true"  SortExpression="min_fpk_location_id" >
                <ItemTemplate>
                    <eclipse:MultiValueLabel  ID="MultiValueLabel1" runat="server" DataFields="fpk_location_count,min_fpk_location_id,max_fpk_location_id"  ToolTip="This field is showing min and max location of the SKU"/>
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

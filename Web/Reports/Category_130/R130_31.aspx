<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="No. Of cartons of each label in each building" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6928 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_31.aspx $
 *  $Id: R130_31.aspx 6928 2014-06-11 04:47:08Z skumar $
 * Version Control Template Added.
 *
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
               // int total = 0;
                foreach (var item in items)
                {
                    var vwhId = item.Elements("column").Where(p => p.Attribute("name").Value == "VWH_ID").First().Value;
                    var quantity = item.Elements("column").Where(p => p.Attribute("name").Value == "CARTON").First().Value;
                    var ctn_qty = item.Elements("column").Where(p => p.Attribute("name").Value == "CQ").First().Value;
                   // total = total + Convert.ToInt32(quantity);
                    var col = data.Table.Columns[vwhId];
                    if (col == null)
                    {
                        col = data.Table.Columns.Add(vwhId, typeof(string));
                        var bf = new SiteHyperLinkField
                        {

                            DataTextField = vwhId,
                            DataTextFormatString = "{0:N0}",
                            DataNavigateUrlFields = new[] { "LABEL_ID", "warehouse_location_id" },
                            HeaderText = string.Format("No. Of Cartons in| {0}", vwhId),
                            DataNavigateUrlFormatString = string.Format("R130_108.aspx?LABEL_ID={{0}}&warehouse_location_id={{1}}&Vwh_Id={0}&quality_code={1}", vwhId, ddlQualityCode.Value),
                            AccessibleHeaderText = "Pieces",
                            DataSummaryCalculation = SummaryCalculationType.None,
                            HeaderToolTip = "Number of cartons (total pieces in carton)"

                        };
                        bf.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                        bf.FooterStyle.HorizontalAlign = HorizontalAlign.Right;
                        ++index;
                        gv.Columns.Insert(index, bf);
                    }
                    quantity = quantity + "(" + ctn_qty + ")";
                    row[vwhId] = quantity;
                    
                }

            }
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.31" />
    <meta name="Description" content="Displays label wise carton count of specific inventory quality in numbered areas of all building." />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Changed name of column  from Wloc to Building.|If the building is not known then it will be addressed as unknown.|Only quality filter is required to run this report. It will show everything for the pass quality.|Changed report title from 'Numbered Area Carton Details Report' to 'No. Of cartons of each label in each building'." />
    <meta name="Version" content="$Id: R130_31.aspx 6928 2014-06-11 04:47:08Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
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
                        <eclipse:DropDownItem Text="(Please Select)" Value="" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        DataSourceMode="DataSet" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
WITH Q1 AS
 (SELECT CTN.VWH_ID AS VWH_ID,
         CTN.CARTON_ID AS CARTON,
         CTNDET.Quantity AS CARTON_QTY, 
         COUNT(DISTINCT CTN.CARTON_ID) OVER(PARTITION BY COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSLOC.WAREHOUSE_LOCATION_ID,
                  'Unknown'),MS.LABEL_ID) AS NO_OF_CARTONS,
        SUM(ctndet.quantity) OVER(PARTITION BY COALESCE(TIA.WAREHOUSE_LOCATION_ID, MSLOC.WAREHOUSE_LOCATION_ID, 'Unknown'), MS.LABEL_ID) AS QTY,
         MS.LABEL_ID AS LABEL_ID,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSLOC.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS WAREHOUSE_LOCATION_ID
    FROM SRC_CARTON CTN
   INNER JOIN SRC_CARTON_DETAIL CTNDET
      ON CTN.CARTON_ID = CTNDET.CARTON_ID
   INNER JOIN MASTER_SKU MSKU
      ON CTNDET.SKU_ID = MSKU.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MS
      ON MSKU.STYLE = MS.STYLE
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSLOC
      ON CTN.LOCATION_ID = MSLOC.LOCATION_ID
     AND CTN.CARTON_STORAGE_AREA = MSLOC.STORAGE_AREA
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   WHERE TIA.LOCATION_NUMBERING_FLAG = 'Y'
    <if>and ctn.quality_code=:quality_code</if>)
SELECT *
  FROM Q1 PIVOT XML(COUNT(DISTINCT CARTON) AS CARTON , SUM(CARTON_QTY) AS CQ FOR(VWH_ID) IN(ANY))
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input"
                Name="quality_code" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        DefaultSortExpression="WAREHOUSE_LOCATION_ID;$;LABEL_ID" ShowFooter="true" AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="LABEL_ID" HeaderText="Label" SortExpression="LABEL_ID"
                HeaderToolTip="Label Id" />
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building"
                SortExpression="WAREHOUSE_LOCATION_ID" HeaderToolTip="Warehouse Location" AccessibleHeaderText="building" />
            <eclipse:MultiBoundField DataFields="NO_OF_CARTONS" HeaderText="Total" SortExpression="NO_OF_CARTONS"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
              <eclipse:MultiBoundField DataFields="QTY" HeaderText="# Pieces" SortExpression="QTY"
                ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

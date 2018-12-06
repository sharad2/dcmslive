<%@ Page Title="Inventory Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6212 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_102.aspx $
 *  $Id: R130_102.aspx 6212 2013-10-30 07:20:29Z skumar $
 * Version Control Template Added.
 Feedback by PA on 11 Sep 09
 Query is need to be worked out, because there is master_sku as master tabel that should be box or ialoc. We are only intrested in SKUs
  for whom we have the inventory. Master_SKU is supporting table to get style, color etc.
--%>
<script runat="server">   

/// <summary>
/// This report is drill down to reports 30.08 and 130.07
/// When drilled from 130.07 area is passed in query string which we show in textbox for area. We do this as area is short_name not actual area_id.
/// Area_id is applied in filter via a query string parameter.
/// 30.08 doesn't have area in query string.  
/// </summary>
/// <param name="e"></param>

    protected override void OnLoad(EventArgs e)
    {
        if (Ckbox.Checked)
        {
            gv.DefaultSortExpression = "BUILDING;VWH_ID;STYLE;COLOR;DIMENSION;SKU_SIZE";
        }
        base.OnLoad(e);
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report helps to repack the carton from Examinig area as well as clear picture of the inventory that in this time how many pieces lying per SKU in this area. Now you can find out specific SKU with use SKU parameter(Style, color, dimension and SKU size) as well as you can see all SKU of specific label and VWH." />
    <meta name="ReportId" content="130.102" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_102.aspx 6212 2013-10-30 07:20:29Z skumar $" />
    <style type="text/css">
        #TCP {
            float: left;
            padding: 1em 0em 0.5em 0.5em;
        }

        #dv {
            float: left;
            font-size: 12px;
            padding: 1em 0em 0.5em 0.5em;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
                $('#cbAll').attr('checked', 'checked');
            };

        });
        function cbAll_OnClientChange(event, ui) {
            if ($('#cbAll').is(':checked')) {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').removeAttr('checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <fieldset>
                        <legend></legend>
                        <eclipse:TwoColumnPanel ID="TCP" runat="server">
                            <eclipse:LeftLabel ID="LeftLabel1" Text="Style" runat="server" />
                            <i:TextBoxEx ID="tbstyle" runat="server" QueryString="style" FriendlyName="Style" />
                            <eclipse:LeftLabel ID="LeftLabel2" Text="Color" runat="server" />
                            <i:TextBoxEx ID="tbcolor" runat="server" QueryString="color" FriendlyName="Color" />
                            <eclipse:LeftLabel ID="LeftLabel3" Text="Dimension" runat="server" />
                            <i:TextBoxEx ID="tbdimension" runat="server" QueryString="dimension" FriendlyName="Dimension" />
                            <eclipse:LeftLabel ID="LeftLabel4" Text="Size" runat="server" />
                            <i:TextBoxEx ID="tbsize" runat="server" QueryString="sku_size" FriendlyName="Size" />
                        </eclipse:TwoColumnPanel>
                        <div id="dv">
                            You can pass multiple values
                                <br />
                            separated by comma for<br />
                            all filters in this section.
                        </div>
                    </fieldset>
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
                        <eclipse:DropDownItem Text="(All)" Value="" Persistent="Always" />
                        <eclipse:DropDownItem Text="Unknown" Value="Unknown" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ToolTip="Choose virtual warehouse" QueryString="vwh_id" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
                <eclipse:LeftLabel runat="server" Text="Area" />
                <oracle:OracleDataSource ID="dsArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                          select inventory_storage_area as area,
                            short_name || '-' || warehouse_location_id || ':' || description  as description,
                            warehouse_location_id as building
                            from tab_inventory_area
                            union all
                            select ia.ia_id as area,
                            NVL(ia.short_name,IA.IA_ID) || '-' || ia.warehouse_location_id||':'|| ia.short_description as description,
                            ia.warehouse_location_id as building
                            from ia ia
                            order by area
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlArea" runat="server" QueryString="area_id" DataFields="area,DESCRIPTION"
                    FriendlyName="Area" DataSourceID="dsArea" Value="<%$ Appsettings:ExaminingAreaCode %>"
                    DataTextFormatString="{1}" DataValueFormatString="{0}">
                    <Items>
                        <eclipse:DropDownItem Text="(All)" Value="" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ddlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    QueryString="LABEL_ID" FriendlyName="Label">
                </d:StyleLabelSelector>
            </eclipse:TwoColumnPanel>
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <eclipse:LeftLabel runat="server" Text="Building" />
                    <br />
                    <br />
                    <i:CheckBoxEx ID="cbAll" runat="server" FriendlyName="Select All" OnClientChange="cbAll_OnClientChange" FilterDisabled="true">
                    </i:CheckBoxEx>
                    Click to Select/UnSelect all
                </eclipse:LeftPanel>
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
                    DataValueField="warehouse_location_id" DataSourceID="dsBuilding" FriendlyName="Building"
                    QueryString="building_id">
                </i:CheckBoxListEx>
                <eclipse:LeftLabel ID="labl" runat="server" />
                <i:CheckBoxEx runat="server" ID="Ckbox" FriendlyName="Are you not using master column" CheckedValue="Y"
                    Text="Check this if you want to see the details without using column as master column." />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
WITH Q1 AS (
SELECT MS.SKU_ID,
       PS.VWH_ID,
       MAX(MS.UPC_CODE) AS UPC,
       MAX(MS.STYLE) AS STYLE,
       MAX(MS.COLOR) AS COLOR,
       MAX(MS.DIMENSION) AS DIMENSION,
       MAX(MS.SKU_SIZE) AS SKU_SIZE,
       MAX(MST.LABEL_ID) AS LABEL_ID,
       MAX(MS.PIECES_PER_PACKAGE) AS PIECES_PER_PACKAGE,
       SUM(BD.CURRENT_PIECES) AS TOTAL_QUANTITY,
       'Unknown' AS QUALITY,
       PS.WAREHOUSE_LOCATION_ID AS BUILDING
  FROM PS 
  INNER JOIN BOX BOX ON 
   BOX.PICKSLIP_ID = PS.PICKSLIP_ID
  INNER JOIN BOXDET BD
    ON BOX.UCC128_ID = BD.UCC128_ID
   AND BOX.PICKSLIP_ID = BD.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_SKU MS
    ON BD.UPC_CODE = MS.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MST
    ON MS.STYLE = MST.STYLE
 WHERE BD.CURRENT_PIECES > 0
   AND BOX.IA_ID IS NOT NULL
   <if>AND box.ia_id = :area</if>
   <if>AND PS.vwh_id = :vwh_id</if>  
   AND box.ia_id &lt;&gt; :CancelArea
   AND box.stop_process_date IS NULL
   <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
   <if>and <a pre="MS.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MS.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MS.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MS.SKU_SIZE IN (" sep="," post=")">:Size</a></if>
   AND BOX.IA_ID_COPY IS NOT NULL
 GROUP BY MS.SKU_ID, PS.VWH_ID,  PS.WAREHOUSE_LOCATION_ID

            UNION

SELECT MS.SKU_ID,
       IA.VWH_ID,
       MAX(MS.UPC_CODE) AS UPC,
       MAX(MS.STYLE) AS STYLE,
       MAX(MS.COLOR) AS COLOR,
       MAX(MS.DIMENSION) AS DIMENSION,
       MAX(MS.SKU_SIZE) AS SKU_SIZE,
       MAX(MST.LABEL_ID) AS LABEL_ID,
       MAX(MS.PIECES_PER_PACKAGE) AS PIECES_PER_PACKAGE,
       SUM(IAC.NUMBER_OF_UNITS) AS TOTAL_QUANTITY,
       'Unknown' AS QUALITY,
       IA.WAREHOUSE_LOCATION_ID AS BUILDING
  FROM IALOC IA
  LEFT OUTER JOIN IALOC_CONTENT IAC
    ON IA.IA_ID = IAC.IA_ID
   AND IA.LOCATION_ID = IAC.LOCATION_ID
  LEFT OUTER JOIN MASTER_SKU MS
    ON IAC.IACONTENT_ID = MS.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MST
    ON MS.STYLE = MST.STYLE
 WHERE 1=1 
   <if>AND iac.ia_id = :area</if>
   <if>AND ia.vwh_id = :vwh_id</if>
    AND IAC.IACONTENT_TYPE_ID = :SkuTypeStorageArea
   <if c="$show_all_pieces">and iac.ia_id !=:scraparea</if>
   <if>AND <a pre="NVL(IA.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
   <if>and <a pre="MS.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MS.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MS.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MS.SKU_SIZE IN (" sep="," post=")">:Size</a></if>
 GROUP BY MS.SKU_ID, IA.VWH_ID, IA.WAREHOUSE_LOCATION_ID),
Q2 AS (
SELECT RAWINV.SKU_ID,
       RAWINV.VWH_ID,
       MAX(MS.UPC_CODE) AS UPC,
       MAX(RAWINV.STYLE) AS STYLE,
       MAX(RAWINV.COLOR) AS COLOR,
       MAX(RAWINV.DIMENSION) AS DIMENSION,
       MAX(RAWINV.SKU_SIZE) AS SKU_SIZE,
       MAX(MST.LABEL_ID) AS LABEL_ID,
       MAX(MS.PIECES_PER_PACKAGE) AS PIECES_PER_PACKAGE,
       SUM(RAWINV.QUANTITY) AS TOTAL_QUANTITY,
       MAX(nvl(RAWINV.QUALITY_CODE,'Unknown')) AS QUALITY,
       NVL(TIA.WAREHOUSE_LOCATION_ID, 'Unknown') AS BUILDING
  FROM MASTER_RAW_INVENTORY RAWINV
  LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
    ON RAWINV.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
  LEFT OUTER JOIN MASTER_SKU MS ON 
    RAWINV.SKU_ID = MS.SKU_ID
  LEFT OUTER JOIN MASTER_STYLE MST
      ON MS.STYLE = MST.STYLE
 WHERE 1 = 1
   <if>AND rawinv.sku_storage_area = :area</if>
   <if>AND rawinv.vwh_id = :vwh_id</if>
   <if>and NVL(rawinv.quality_code,'Unknown') = :quality_code</if>
   <if>AND <a pre="NVL(TIA.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
   <if>and <a pre="MS.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MS.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MS.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MS.SKU_SIZE IN (" sep="," post=")">:Size</a></if>
 GROUP BY RAWINV.SKU_ID,
          RAWINV.VWH_ID,
          NVL(TIA.WAREHOUSE_LOCATION_ID, 'Unknown')
HAVING(SUM(RAWINV.QUANTITY)) &lt;&gt;0)
select q1.STYLE,
       q1.COLOR,
       q1.DIMENSION,
       q1.SKU_SIZE,
       Q1.UPC,
       Q1.LABEL_ID,
       q1.quality,
       Q1.PIECES_PER_PACKAGE,
       q1.TOTAL_QUANTITY,
       q1.vwh_id,
       q1.building
       from Q1 q1
       where 1=1
       <if>and q1.quality =:quality_code</if>
       UNION
SELECT q2.STYLE,
       q2.COLOR,
       q2.DIMENSION,
       q2.SKU_SIZE,
       q2.UPC,
       Q2.LABEL_ID,
       q2.quality,
       Q2.PIECES_PER_PACKAGE,
       q2.TOTAL_QUANTITY,
       q2.VWH_ID,
       q2.building 
       from Q2 q2
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" DbType="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="ddlArea" Type="String" Direction="Input" Name="area" />
            <asp:Parameter DbType="String" Name="CancelArea" DefaultValue="<%$ Appsettings:CancelArea %>" />
            <asp:Parameter DbType="String" Name="SkuTypeStorageArea" DefaultValue="<%$ Appsettings:SkuTypeStorageArea %>" />
            <asp:Parameter DbType="String" Name="shelfArea" DefaultValue="<%$ Appsettings:ShelfArea %>" />
            <asp:Parameter DbType="String" Name="scraparea" DefaultValue="<%$ Appsettings:ScrapArea %>" />
            <asp:QueryStringParameter Name="quality_code" DbType="String" QueryStringField="quality_code" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="warehouse_location_id" Type="String" Direction="Input" />
            <asp:QueryStringParameter Name="show_all_pieces" Type="string" Direction="Input" QueryStringField="show_all_pieces" />
            <asp:ControlParameter ControlID="ddlLabel" Name="LABEL_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbstyle" Name="Style" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbcolor" Name="Color" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbdimension" Name="Dimension" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbsize" Name="Size" Type="String" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="BUILDING;VWH_ID;$;STYLE;COLOR;DIMENSION;SKU_SIZE">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="BUILDING" HeaderText="Building" SortExpression="BUILDING"
                HeaderToolTip="Style of the SKU" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
                HeaderToolTip="Style of the SKU" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="UPC" HeaderText="UPC" SortExpression="UPC"
                HeaderToolTip="UPC Code" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="SKU|Style" SortExpression="STYLE"
                HeaderToolTip="Style of the SKU" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="SKU|Color" SortExpression="COLOR"
                HeaderToolTip="Color of the SKU" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="SKU|Dim" SortExpression="DIMENSION"
                HeaderToolTip="Deminsion" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="SKU|Size" SortExpression="SKU_SIZE"
                HeaderToolTip="Sku Sizes" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="TOTAL_QUANTITY" HeaderText="SKU|Pieces" SortExpression="TOTAL_QUANTITY"
                HeaderToolTip="Total no. of pieces." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterToolTip="Total pieces in the specified area." />
            <eclipse:MultiBoundField DataFields="PIECES_PER_PACKAGE" HeaderText="SKU|Pcs/Pkg" SortExpression="PIECES_PER_PACKAGE"
                HeaderToolTip="Pieces per package of the SKU." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}"  />
            <eclipse:MultiBoundField DataFields="LABEL_ID" HeaderText="Label" SortExpression="LABEL_ID"
                HeaderToolTip="Label of the Style" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="quality" HeaderText="Quality" SortExpression="quality" HeaderToolTip="Quality Of the SKU" HideEmptyColumn="true"></eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

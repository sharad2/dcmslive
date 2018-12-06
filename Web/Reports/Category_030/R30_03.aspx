<%@ Page Title="SKU Inventory In Given Area" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6317 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_030/R30_03.aspx $
 *  $Id: R30_03.aspx 6317 2013-12-03 11:55:55Z skumar $
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
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is for showing sku wise inventory for given area. By default this report will get executed for EXM area. This report is also able to display outbound inventory in box areas. For this inventory which is not shipped yet will be displayed in the report. With the help of different filters users will be able to get desired picture of inventory for the given area." />
    <meta name="ReportId" content="30.03" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="As this report will now show area wise inventory so we have changed report name from 'Carton in Examining area' to 'Inventory in given area'. |Provided new filters :- Style, Color, Dimension, Size, vwh, Quality Code, Area, Label and Building. User can pass multiple values separated by comma in following filters Style, Color, Dimension, Size.|Provided new columns :- UPC, Label, Quality and Building.|This report will not show any carton related information like Days, Carton id, Price Season Code, Package Preference and Sale Type." />
    <meta name="Version" content="$Id: R30_03.aspx 6317 2013-12-03 11:55:55Z skumar $" />
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
                            union
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
                        <eclipse:DropDownItem Text="(Please Select Area)" Value="" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Required />
                    </Validators>
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
                    QueryString="warehouse_location_id">
                </i:CheckBoxListEx>
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
            WITH INVENTORY  AS
 (SELECT BD.SKU_ID,
         PS.VWH_ID,
         BD.UPC_CODE AS UPC,
         MSKU.STYLE AS STYLE,
         MSKU.COLOR AS COLOR,
         MSKU.DIMENSION AS DIMENSION,
         MSKU.SKU_SIZE AS SKU_SIZE,
         MST.LABEL_ID AS LABEL_ID,
         MSKU.PIECES_PER_PACKAGE AS PIECES_PER_PACKAGE,
         BD.CURRENT_PIECES AS TOTAL_QUANTITY,
         '01' AS QUALITY,
         NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') AS BUILDING
    FROM PS
   INNER JOIN BOX BOX
      ON BOX.PICKSLIP_ID = PS.PICKSLIP_ID
   INNER JOIN BOXDET BD
      ON BOX.UCC128_ID = BD.UCC128_ID
     AND BOX.PICKSLIP_ID = BD.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON BD.SKU_ID = MSKU.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MST
      ON MSKU.STYLE = MST.STYLE
   WHERE BOX.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     AND PS.TRANSFER_DATE IS NULL
     AND BD.CURRENT_PIECES &gt; 0
   <if>AND BOX.IA_ID = :area</if>
   <if>AND PS.vwh_id = :vwh_id</if>
   <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
   <if>and <a pre="MSKU.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MSKU.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MSKU.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MSKU.SKU_SIZE IN (" sep="," post=")">:Size</a></if>
  UNION ALL
  SELECT MSKU.SKU_ID,
         I.VWH_ID,
         IAC.IACONTENT_ID AS UPC,
         MSKU.STYLE AS STYLE,
         MSKU.COLOR AS COLOR,
         MSKU.DIMENSION AS DIMENSION,
         MSKU.SKU_SIZE AS SKU_SIZE,
         MST.LABEL_ID AS LABEL_ID,
         MSKU.PIECES_PER_PACKAGE AS PIECES_PER_PACKAGE,
         IAC.NUMBER_OF_UNITS AS TOTAL_QUANTITY,
         '01' AS QUALITY,
         NVL(I.WAREHOUSE_LOCATION_ID,'Unknown') AS BUILDING
    FROM IALOC_CONTENT IAC 
   LEFT OUTER JOIN IALOC I
      ON IAC.IA_ID = I.IA_ID
     AND IAC.LOCATION_ID = I.LOCATION_ID
   LEFT OUTER JOIN MASTER_SKU MSKU
      ON IAC.IACONTENT_ID = MSKU.UPC_CODE
    LEFT OUTER JOIN MASTER_STYLE MST
      ON MSKU.STYLE = MST.STYLE
    LEFT OUTER JOIN IA ON 
            I.IA_ID = IA.IA_ID
   WHERE IAC.IACONTENT_TYPE_ID = 'SKU'
       AND IAC.NUMBER_OF_UNITS &lt;&gt; 0
   <if>AND I.IA_ID = :area</if>
       AND nvl(ia.SHORT_NAME,I.IA_ID) !=:scraparea 
   <if>AND I.vwh_id = :vwh_id</if>
   <if>AND <a pre="NVL(I.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
   <if>and <a pre="MSKU.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MSKU.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MSKU.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MSKU.SKU_SIZE IN (" sep="," post=")">:Size</a></if>
   UNION ALL
  SELECT RAWINV.SKU_ID,
         RAWINV.VWH_ID,
         MSKU.UPC_CODE AS UPC,
         RAWINV.STYLE AS STYLE,
         RAWINV.COLOR AS COLOR,
         RAWINV.DIMENSION AS DIMENSION,
         RAWINV.SKU_SIZE AS SKU_SIZE,
         MST.LABEL_ID AS LABEL_ID,
         MSKU.PIECES_PER_PACKAGE AS PIECES_PER_PACKAGE,
         RAWINV.QUANTITY AS TOTAL_QUANTITY,
         NVL(RAWINV.QUALITY_CODE, 'Unknown') AS QUALITY,
         NVL(TIA.WAREHOUSE_LOCATION_ID, 'Unknown') AS BUILDING
    FROM MASTER_RAW_INVENTORY RAWINV
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON RAWINV.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON RAWINV.SKU_ID = MSKU.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MST
      ON MSKU.STYLE = MST.STYLE
   WHERE TIA.STORES_WHAT = 'SKU'
   <if>AND rawinv.sku_storage_area = :area</if>
       AND rawinv.sku_storage_area != 'RED'
   <if>AND rawinv.vwh_id = :vwh_id</if>
   <if>and NVL(rawinv.quality_code,'Unknown') = :quality_code</if>
   <if>AND <a pre="NVL(TIA.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
       AND RAWINV.QUANTITY  &lt;&gt; 0
   <if>and <a pre="MSKU.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MSKU.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MSKU.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MSKU.SKU_SIZE IN (" sep="," post=")">:Size</a></if>
  UNION ALL
  SELECT SCD.SKU_ID,
         SC.VWH_ID,
         MSKU.UPC_CODE AS UPC,
         MSKU.STYLE AS STYLE,
         MSKU.COLOR AS COLOR,
         MSKU.DIMENSION AS DIMENSION,
         MSKU.SKU_SIZE AS SKU_SIZE,
         MST.LABEL_ID AS LABEL_ID,
         MSKU.PIECES_PER_PACKAGE AS PIECES_PER_PACKAGE,
         SCD.QUANTITY AS TOTAL_QUANTITY,
         SC.QUALITY_CODE AS QUALITY,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS BUILDING
    FROM SRC_CARTON SC
   INNER JOIN SRC_CARTON_DETAIL SCD
      ON SC.CARTON_ID = SCD.CARTON_ID
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON SCD.SKU_ID = MSKU.SKU_ID
    LEFT OUTER JOIN MASTER_STYLE MST
      ON MSKU.STYLE = MST.STYLE
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
     AND SC.LOCATION_ID = MSL.LOCATION_ID
   INNER JOIN TAB_INVENTORY_AREA TIA
      ON SC.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
   WHERE TIA.STORES_WHAT = 'CTN'
       AND SCD.QUANTITY &gt; 0
   <if>AND SC.CARTON_STORAGE_AREA = :area</if>
   <if>AND SC.vwh_id = :vwh_id</if>
   <if>and NVL(SC.quality_code,'Unknown') = :quality_code</if>
   <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                     MSL.WAREHOUSE_LOCATION_ID,
                     'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
   <if>AND MST.LABEL_ID =:LABEL_ID</if>
   <if>and <a pre="MSKU.style IN (" sep="," post=")">:Style</a></if>
   <if>and <a pre="MSKU.Color IN (" sep="," post=")">:Color</a></if>
   <if>and <a pre="MSKU.Dimension IN (" sep="," post=")">:Dimension</a></if>
   <if>and <a pre="MSKU.SKU_SIZE IN (" sep="," post=")">:Size</a></if>  
            )
SELECT MAX(Q1.STYLE) AS STYLE,
       MAX(Q1.COLOR) AS COLOR,
       MAX(Q1.DIMENSION) AS DIMENSION,
       MAX(Q1.SKU_SIZE) AS SKU_SIZE,
       MAX(Q1.UPC) AS UPC,
       MAX(Q1.LABEL_ID) AS LABEL_ID,
       Q1.QUALITY,
       MAX(Q1.PIECES_PER_PACKAGE) AS PIECES_PER_PACKAGE,
       SUM(Q1.TOTAL_QUANTITY) AS TOTAL_QUANTITY,
       Q1.VWH_ID,
       Q1.BUILDING,
       Q1.SKU_ID
  FROM INVENTORY Q1
 WHERE 1=1
 <if>and NVL(Q1.quality,'Unknown') = :quality_code</if>
 GROUP BY Q1.BUILDING, Q1.VWH_ID, Q1.SKU_ID, Q1.QUALITY

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Name="vwh_id" Direction="Input" />
            <asp:ControlParameter ControlID="ddlArea" Type="String" Direction="Input" Name="area" />
            <asp:Parameter DbType="String" Name="CancelArea" DefaultValue="<%$ Appsettings:CancelArea %>" />
            <asp:Parameter DbType="String" Name="SkuTypeStorageArea" DefaultValue="<%$ Appsettings:SkuTypeStorageArea %>" />
            <asp:Parameter DbType="String" Name="scraparea" DefaultValue="<%$ Appsettings:ScrapArea %>" />
            <asp:ControlParameter ControlID="ddlQualityCode" Name="quality_code" Type="String" Direction="Input"/>
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
                HeaderToolTip="Warehouse Location ID" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
              ItemStyle-HorizontalAlign="Left" />
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
            <eclipse:MultiBoundField DataFields="PIECES_PER_PACKAGE" HeaderText="SKU|Pcs/Pkg" SortExpression="PIECES_PER_PACKAGE"
                HeaderToolTip="Pieces per package of the SKU." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}"  />
            <eclipse:MultiBoundField DataFields="LABEL_ID" HeaderText="Label" SortExpression="LABEL_ID"
                HeaderToolTip="Label of the Style" ItemStyle-HorizontalAlign="Left" />
            <eclipse:MultiBoundField DataFields="quality" HeaderText="Quality" SortExpression="quality" AccessibleHeaderText="Quality" HeaderToolTip="Quality Of the SKU" HideEmptyColumn="true"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="TOTAL_QUANTITY" HeaderText="Pieces" SortExpression="TOTAL_QUANTITY"
               DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" >
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

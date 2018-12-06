<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Perpetual Inventory" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6858 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_16.aspx $
 *  $Id: R130_35.aspx 6858 2014-05-20 05:48:16Z skumar $
 * Version Control Template Added.
--%>
<%--Shift Pattern--%>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="EclipseLibrary.Web.Extensions" %>
<script runat="server">
   
    //protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    //{
    //    string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("sc.MODIFIED_DATE");
    //    if (string.IsNullOrEmpty(rbtnShift.Value))
    //    {
    //        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Empty);
    //    }
    //    else
    //    {
    //        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhere, "shift_number"));
    //    }
    //}
   
              
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Displays the perpetual inventory of the DC at any particular time." />
    <meta name="ReportId" content="130.35" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Virtual Warehouse filter is now available in this report." />  
    <meta name="Version" content="$Id: R130_35.aspx 6858 2014-05-20 05:48:16Z skumar $" />
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
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server" >
                 <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <i:RadioButtonListEx runat="server" ID="rblfilter" Visible="false" Value="L"
                        QueryString="filter_type" />
                </eclipse:LeftPanel>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:RadioItemProxy ID="rbLabel" runat="server" Text="Label"
                        CheckedValue="L" QueryString="filter_type" FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel ID="Panel1" runat="server">
                    <d:StyleLabelSelector ID="ddlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                        QueryString="LABEL_ID" FriendlyName="Label">
                        <Validators>
                            <i:Filter DependsOn="rblfilter" DependsOnState="Value" DependsOnValue="L" />
                        </Validators>
                    </d:StyleLabelSelector>
                </asp:Panel>
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <i:RadioItemProxy runat="server" Text="Style" ID="rbStyle" CheckedValue="S"
                        QueryString="filter_type" FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel runat="server" ID="p_receipt">
                    <i:TextBoxEx ID="tbstyle" FriendlyName="Style" runat="server" QueryString="style">
                        <Validators>
                            <i:Filter DependsOn="rblfilter" DependsOnState="Value" DependsOnValue="S" />
                            <i:Required DependsOn="rblfilter" DependsOnState="Value" DependsOnValue="S" />
                        </Validators>
                    </i:TextBoxEx>
                </asp:Panel>
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
                <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ddlvwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                        QueryString="vwh_id" FriendlyName="Virtual Warehouse">
                </d:VirtualWarehouseSelector>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
WITH INV AS
     (SELECT CTN.VWH_ID,
             MAX(MSKU.STYLE) STYLE,
             MAX(MSKU.COLOR) COLOR,
             MAX(MSKU.SKU_SIZE) SKU_SIZE,
             MAX(MSKU.DIMENSION) AS DIMENSION,
             CTN.QUALITY_CODE AS QUALITY_CODE,
             SUM(CTNDET.QUANTITY) DCMS_QUANTITY,
             MAX(MSKU.UPC_CODE) AS UPC_CODE,
             MSKU.SKU_ID
        FROM SRC_CARTON CTN
       INNER JOIN SRC_CARTON_DETAIL CTNDET
          ON CTN.CARTON_ID = CTNDET.CARTON_ID
       INNER JOIN MASTER_SKU MSKU
          ON MSKU.SKU_ID = CTNDET.SKU_ID
       GROUP BY CTN.VWH_ID, CTN.QUALITY_CODE, MSKU.SKU_ID
      UNION ALL
      SELECT MRI.VWH_ID,
             MAX(MSKU.STYLE) STYLE,
             MAX(MSKU.COLOR) COLOR,
             MAX(MSKU.SKU_SIZE) SKU_SIZE,
             MAX(MSKU.DIMENSION) AS DIMENSION,
             MRI.QUALITY_CODE AS QUALITY_CODE,
             SUM(MRI.QUANTITY) DCMS_QUANTITY,
             MAX(MSKU.UPC_CODE) AS UPC_CODE,
             MSKU.SKU_ID
        FROM TAB_INVENTORY_AREA TIA
       INNER JOIN MASTER_RAW_INVENTORY MRI
          ON MRI.SKU_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
       INNER JOIN MASTER_SKU MSKU
          ON MRI.SKU_ID = MSKU.SKU_ID
       WHERE TIA.STORES_WHAT = 'SKU'
         AND TIA.UNUSABLE_INVENTORY IS NULL
       GROUP BY MRI.VWH_ID, MSKU.SKU_ID, MRI.QUALITY_CODE
      HAVING SUM(MRI.QUANTITY) != 0),
    Q2 AS
     (SELECT VWH_ID AS VWH_ID,
             MAX(MS.LABEL_ID) AS LABEL_ID,
             I.STYLE AS STYLE,
             I.COLOR AS COLOR,
             I.DIMENSION AS DIMENSION,
             I.SKU_SIZE AS SKU_SIZE,
             I.QUALITY_CODE   AS QUALITY_code,
             SUM(DCMS_QUANTITY) AS PIECES,
             MAX(I.UPC_CODE) AS UPC_CODE
        FROM INV I
        LEFT OUTER JOIN MASTER_STYLE MS
        ON I.STYLE = MS.STYLE
   WHERE 1 = 1
      <if>AND I.style = :style</if>
      <if>AND ms.Label_ID = :LABEL_ID</if>
      <if>and NVL(I.quality_code,'Unknown') = :quality_code</if>
      <if>and VWH_ID = :vwh_id</if>
       GROUP BY I.VWH_ID,
                I.STYLE,
                I.COLOR,
                I.DIMENSION,
                I.SKU_SIZE,
                I.QUALITY_CODE)
                SELECT * FROM q2 

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlLabel" Name="LABEL_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbStyle" Type="String" Direction="Input" Name="style" />
            <asp:ControlParameter ControlID="ddlQualityCode" Name="quality_code" Type="String" Direction="Input"/>
            <asp:ControlParameter ControlID="ddlvwh" Name="vwh_id" Type="String" Direction="Input"/>
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="style;color;dimension;sku_size;vwh_id"
        AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true" AllowPaging="true" PageSize="200" PagerSettings-Visible="false">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label assigned to the sku.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style of the sku." ItemStyle-HorizontalAlign="Left">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color of the sku.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dimension" SortExpression="dimension"
                HeaderToolTip="Dimension of the sku.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="Size of the sku.">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="upc_code" HeaderText="UPC" SortExpression="upc_code"
                HeaderToolTip="UPC code for the sku." ItemStyle-HorizontalAlign="Left">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="Vwh" SortExpression="vwh_id"
                HeaderToolTip="Virtual warehouse">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality of the sku.">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="pieces" HeaderText="Pieces" SortExpression="pieces"
                HeaderToolTip="Quantity in pieces of sku" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" FooterToolTip="Total pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

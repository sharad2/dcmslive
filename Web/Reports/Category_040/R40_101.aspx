<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Carton Aging Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5661 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_101.aspx $
 *  $Id: R40_101.aspx 5661 2013-07-17 05:40:13Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        ds.Selecting += new SqlDataSourceSelectingEventHandler(ds_Selecting);
    }

    void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string valueToPass = string.Empty;
        if (ctlDayRangeChooser.Value == "4")
        {
            valueToPass = "4,5";
        }
        else if (ctlDayRangeChooser.Value == "6")
        {
            valueToPass = "6,7";
        }
        else
        {
            valueToPass = ctlDayRangeChooser.Value == "" ? ctlDayRangeChooser.QueryString : ctlDayRangeChooser.Value;
        }
        e.Command.CommandText = string.Format(e.Command.CommandText, valueToPass);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For the specified period range, the report displays the cartons with thier SKU details, which are lying in the specified area." />
    <meta name="ReportId" content="40.101" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R40_101.aspx 5661 2013-07-17 05:40:13Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Specify Carton Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" QueryString="carton_storage_area"
                    StorageAreaType="CTN" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ShowAll="true"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" QueryString="vwh_id" ShowAll="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel runat="server" Text="Day Range" />
                <i:DropDownListEx2 ID="ctlDayRangeChooser" runat="server" QueryString="quarterly_year"
                    ToolTip="Day Range">
                    <Items>
                        <eclipse:DropDownItem Text="Last 89 days" Value="0" Persistent="Always" />
                        <eclipse:DropDownItem Text="90 to 179 days" Value="1" Persistent="Always" />
                        <eclipse:DropDownItem Text="180 to 269 days" Value="2" Persistent="Always" />
                        <eclipse:DropDownItem Text="270 to 359 days" Value="3" Persistent="Always" />
                        <eclipse:DropDownItem Text="360 to 539 days" Value="4" Persistent="Always" />
                        <eclipse:DropDownItem Text="540 to 719 days" Value="6" Persistent="Always" />
                        <eclipse:DropDownItem Text="720+ days" Value="8" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel runat="server" Text="Quality Code" />
                <i:TextBoxEx ID="tbQualityCode" runat="server" QueryString="quality_code">
                </i:TextBoxEx>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  CancelSelectOnNullParameter="true" >
   <SelectSql>
   SELECT CTN.carton_storage_area AS carton_storage_area,
       CTN.quality_code AS quality_code,
       CTN.carton_id         AS carton_id,
       CTN.price_season_code AS price_season_code,
       CTN.insert_date       AS receipt_date,
       DECODE(CTN.location_id,NULL,CTN.pallet_id,CTN.Location_Id)  AS carton_location,
       CTN.vwh_id            AS vwh_id,
       msku.style          AS style,
       msku.color          AS color,
       msku.dimension      AS dimension,
       msku.sku_size       AS sku_size,
       CTNDET.quantity       AS quantity,
       STY.label_id          AS label_id
FROM src_carton ctn
       LEFT OUTER JOIN src_carton_detail ctndet ON ctndet.carton_id = ctn.carton_id
       LEFT OUTER JOIN master_sku msku on msku.sku_id=ctndet.sku_id
       LEFT OUTER JOIN master_style sty ON sty.style = msku.style
 WHERE 1=1
 <if>AND ctn.carton_storage_area = :carton_storage_area</if>
 <if>AND ctn.vwh_id = :vwh_id</if>
 <if c="$EqualsTo != '8'">AND TRUNC((SYSDATE - ctn.insert_date) / 90) IN({0})</if>
 <if>AND ctn.quality_code = :quality_code</if>
 <if c="$GreaterThan = '8'">AND TRUNC((SYSDATE - ctn.insert_date) / 90) &gt;= :quarterly_year</if>
  
   </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlCtnArea" Direction="Input" Type="String" Name="carton_storage_area" />
            <asp:ControlParameter ControlID="ctlDayRangeChooser" Direction="Input" Type="String"
                Name="quarterly_year" />
            <asp:ControlParameter ControlID="ctlDayRangeChooser" Direction="Input" Type="String"
                Name="EqualsTo" PropertyName="Value" />
            <asp:ControlParameter ControlID="ctlDayRangeChooser" Direction="Input" Type="String"
                Name="GreaterThan" PropertyName="Value" />
            <asp:ControlParameter ControlID="tbQualityCode" Direction="Input" Type="String" Name="quality_code" PropertyName="Text" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" ShowFooter="true"
        DataSourceID="ds" DefaultSortExpression="style;color;dimension;sku_size;receipt_date"
        AllowSorting="true" AllowPaging="true" PageSize="<%$ AppSettings: PageSize %>">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="carton_id" HeaderText="Carton" DataFooterFormatString="{0:N0}"
                SortExpression="carton_id" HeaderToolTip="Carton ID">
            </eclipse:MultiBoundField>
          <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" 
                SortExpression="quality_code" HeaderToolTip="Quality Code">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label ID of the skus present in the carton">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="price_season_code" HeaderText="Season Code"
                SortExpression="price_season_code" HeaderToolTip="Price season code for the cartons">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="receipt_date" HeaderText="Receipt Date" SortExpression="receipt_date"
                HeaderToolTip="Date on which carton was received in the area" DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="carton_location" HeaderText="Location/<br />Pallet"
                SortExpression="carton_location" HeaderToolTip="Location or Pallet on which the cartons are lying."
                DataFormatString="{0:N0}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style of containing sku" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color of containing sku" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dimension" SortExpression="dimension"
                HeaderToolTip="Dimension of containing sku" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="Sku size of containing sku" />
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Qty" SortExpression="quantity"
                DataFooterFormatString="{0:N0}" HeaderToolTip="Number of skus in the carton"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" FooterToolTip="Total number of skus in area cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual warehouse id">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

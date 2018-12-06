<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Manifest by Plant Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 513 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_030/R30_19.aspx $
 *  $Id: R30_19.aspx 513 2011-03-16 08:54:44Z rverma $
 * Version Control Template Added.
 * drill down added but not compleate
--%>
<%--Multiview Pattern--%>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (cbDetails.Checked)
        {
            mv.ActiveViewIndex = 1;
            ButtonBar1.GridViewId = gvDetails.ID;
        }
        else
        {
            mv.ActiveViewIndex = 0;
            ButtonBar1.GridViewId = gv.ID;
        }

        base.OnLoad(e);
    }
  
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays carton details coming from sewing plant for a specific date or date range." />
    <meta name="ReportId" content="30.19" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R30_19.aspx 513 2011-03-16 08:54:44Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filter">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Specify Dates" />
                From:
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="Specify from date"
                    Text="-7">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="Specify to date" Text="0">
                    <Validators>
                        <i:Date DateType="ToDate" MaxRange="365" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="leftLabel2" runat="server" Text="Detail" />
                <i:CheckBoxEx runat="server" ID="cbDetails" FriendlyName="Detail" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <br />
    <asp:MultiView runat="server" ID="mv" ActiveViewIndex="-1">
        <asp:View runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                EnableViewState="false">
            <SelectSql>
            SELECT /*+ index (src CTNINTRAN_INSERT_DATE_I)*/src.sewing_plant_code AS sewing_plant_code,
       src.shipment_id AS shipment_id,
       trunc(src.insert_date) AS insert_date,
       count(distinct(src.carton_id)) AS no_of_cartons,
       sum(src.quantity) AS quantity
  FROM src_carton_intransit src
 WHERE src.insert_date &gt;= :FROM_DATE
   AND src.insert_date &lt; :TO_DATE + 1
 GROUP BY src.sewing_plant_code, src.shipment_id, trunc(src.insert_date)
            </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FROM_DATE" />
                    <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="TO_DATE" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                DataSourceID="ds" ShowFooter="true" DefaultSortExpression="sewing_plant_code;shipment_id">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="sewing_plant_code" HeaderText="Sewing Plant Code"
                        ItemStyle-HorizontalAlign="Left" HeaderToolTip="Sewing plant Id from where cartons are coming to DC." />
                    <eclipse:MultiBoundField DataFields="shipment_id" HeaderText="Shipment" SortExpression="shipment_id" />
                    <eclipse:MultiBoundField DataFields="insert_date" HeaderText="Process Date" SortExpression="insert_date"
                        DataFormatString="{0:d}" HeaderToolTip="Date when carton processed." ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="no_of_cartons" HeaderText="No.of Cartons" SortExpression="no_of_cartons"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" DataFormatString="{0:N0}"
                        ItemStyle-HorizontalAlign="Right" FooterToolTip="Total Cartons." FooterStyle-HorizontalAlign="Right"
                        HeaderToolTip="Number of cartons for a given shipment ID.">
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="quantity" HeaderText="Pieces" DataFormatString="{0:N0}"
                        SortExpression="quantity" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                        ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Quantities of SKUs."
                        FooterToolTip="Total Pieces.">
                    </eclipse:MultiBoundField>
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View runat="server">
            <oracle:OracleDataSource ID="dsDetails" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
                CancelSelectOnNullParameter="true" EnableViewState="false">
        <SelectSql>
        SELECT /*+ index (src CTNINTRAN_INSERT_DATE_I)*/ src.sewing_plant_code AS sewing_plant_code,
       src.shipment_id AS shipment_id,
       COUNT(distinct(src.carton_id)) AS no_of_cartons,
       SUM(src.quantity) AS pieces,
       src.style AS style,
       src.color AS color,
       src.dimension AS dimension,
       src.sku_size AS sku_size,
       src.source_order_prefix || src.source_order_id AS source_order 
  FROM src_carton_intransit src
 WHERE src.insert_date &gt;= :FROM_DATE
   AND src.insert_date &lt; :TO_DATE + 1
 GROUP BY src.sewing_plant_code ,
 src.shipment_id ,
 src.style ,
 src.color , 
 src.dimension ,
 src.sku_size , 
 src.source_order_prefix || src.source_order_id 
        </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FROM_DATE" />
                    <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="TO_DATE" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvDetails" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                DataSourceID="dsDetails" ShowFooter="true" DefaultSortExpression="sewing_plant_code;$;shipment_id"
                Caption="<strong>Inventory From Sewing Plants (In Details)</strong>" CaptionAlign="Left">
                <Columns>
                    <eclipse:SequenceField />
                    <asp:BoundField DataField="SEWING_PLANT_CODE" HeaderText="Sewing Plant Code" ItemStyle-HorizontalAlign="Left"
                        SortExpression="SEWING_PLANT_CODE" />
                    <asp:BoundField DataField="SHIPMENT_ID" HeaderText="Shipment" SortExpression="shipment_id" />
                    <asp:BoundField DataField="SOURCE_ORDER" HeaderText="Source Order" SortExpression="source_order" />
                    <asp:BoundField DataField="STYLE" HeaderText="SKU|Style" SortExpression="style" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField DataField="color" HeaderText="SKU|Color" SortExpression="color" />
                    <asp:BoundField DataField="DIMENSION" HeaderText="SKU|Dim" SortExpression="dimension" />
                    <asp:BoundField DataField="SKU_SIZE" HeaderText="SKU|Size" SortExpression="sku_size" />
                    <eclipse:MultiBoundField DataFields="no_of_cartons" HeaderText="No. of Carton" SortExpression="no_of_cartons"
                        ItemStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                        FooterStyle-HorizontalAlign="Right" HeaderToolTip="Number of cartons for a given shipment ID."
                        FooterToolTip="Total Cartons." />
                    <eclipse:MultiBoundField DataFields="PIECES" HeaderText="Pieces" DataFormatString="{0:N0}"
                        SortExpression="pieces" ItemStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation"
                        DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Quantities of SKUs."
                        FooterToolTip="Total Pieces." />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

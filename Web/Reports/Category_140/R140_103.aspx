<%@ Page Title="Red Carton Detail Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1755 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_103.aspx $
 *  $Id: R140_103.aspx 1755 2011-12-03 05:56:35Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays the SKU details along with the pieces which are expected to be lying in the box as well as the actual pieces lying in that area." />
    <meta name="ReportId" content="140.103" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R140_103.aspx 1755 2011-12-03 05:56:35Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id">
                    <Validators>
                    <i:Value ValueType="Integer" MaxLength="5" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString='<%$ ConnectionStrings:DCMSLIVE %>'
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label" QueryString="label_id" ToolTip="Select any label to see the order.">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
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
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
        SELECT /*+index (box BOX_PS_FK_I) index(boxdet BOXDET_PK) index(sku SKU_UK)*/sku.style AS style,
       sku.color AS color,
       sku.dimension AS dimension,
       sku.sku_size AS sku_size,
       sku.upc_code AS upc_code,
       SUM(boxdet.expected_pieces) AS expected_pieces,
       SUM(boxdet.current_pieces) AS current_pieces,
       box.ucc128_id AS ucc128_id,
       ps.vwh_id AS vwh_id
  FROM ps ps
   INNER JOIN box box
    ON ps.pickslip_id = box.pickslip_id
 INNER JOIN boxdet boxdet
    ON box.pickslip_id = boxdet.pickslip_id
   AND box.ucc128_id = boxdet.ucc128_id
 inner join master_sku sku    
    ON sku.upc_code = boxdet.upc_code
 WHERE box.ia_id = CAST(:RedBoxArea as varchar2(255))
         <if>AND ps.vwh_id = CAST(:vwh_id as varchar2(255))</if>
         <if>AND ps.label_id = CAST(:label_id as varchar2(255))</if>
         <if>AND ps.bucket_id = cast(:bucket_id as number(5))</if>
 GROUP BY sku.style,
          sku.color,
          sku.dimension,
          sku.sku_size,
          sku.upc_code,
          box.ucc128_id,
          ps.vwh_id
        </SelectSql>
        <SelectParameters>
            <asp:Parameter Direction="Input" Type="String" Name="RedBoxArea" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="tbBucketId" Direction="Input" Type="Int32" Name="bucket_id" />
            <asp:ControlParameter ControlID="ctlLabel" Direction="Input" Type="String" Name="label_id" />
            </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <div style="padding:1em 0em 1em 1em">
    Building :<span id="sp" style="padding:2em"><asp:Label ID="Lblcategory" runat="server" Font-Bold="true" >
    <%=Request.QueryString["warehouse_location_id"]%></asp:Label></span>
    </div><jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="ucc128_id;$;upc_code">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="ucc128_id" SortExpression="ucc128_id" HeaderText="Carton Id" />
            <eclipse:MultiBoundField DataFields="upc_code" SortExpression="upc_code" HeaderText="UPC Code" />
            <eclipse:MultiBoundField DataFields="style" SortExpression="style" HeaderText="Style" />
            <eclipse:MultiBoundField DataFields="color" SortExpression="color" HeaderText="Color" />
            <eclipse:MultiBoundField DataFields="dimension" SortExpression="dimension" HeaderText="Dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" SortExpression="sku_size" HeaderText="Size" />
            <eclipse:MultiBoundField DataFields="expected_pieces" SortExpression="expected_pieces"
                HeaderText="Expected Pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="current_pieces" SortExpression="current_pieces"
                HeaderText="Current Pieces" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Title="Weight and Cube Exception Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 953 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_32.aspx $
 *  $Id: R130_32.aspx 953 2011-06-01 10:59:19Z skumar $
 * Version Control Template Added.
 *
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report is displaying the all sku whose inventory is graeter than 0 and weight or Vloume is null or set to zero " />
    <meta name="ReportId" content="130.32" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_32.aspx 953 2011-06-01 10:59:19Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:PlaceHolder runat="server" ID="tabs" />

<uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">   
     <SelectSql>
SELECT MRI.STYLE AS STYLE,
       MRI.COLOR AS COLOR,
       MRI.DIMENSION AS DIMENSION,
       MRI.SKU_SIZE AS SKU_SIZE,
       MAX(MS.LABEL_ID) AS LABEL_ID,
       MAX(MS.DESCRIPTION) AS DESCR,
       MAX(MSKU.UPC_CODE) AS UPC_CODE,
       MAX(MSKU.WEIGHT_PER_DOZEN) AS WEIGHT,
       MAX(MSKU.VOLUME_PER_DOZEN) AS VOLUME
  FROM V_SKU_INVENTORY MRI
  LEFT OUTER JOIN MASTER_STYLE MS
    ON MRI.STYLE = MS.STYLE
  LEFT OUTER JOIN MASTER_SKU MSKU
    ON MRI.STYLE = MSKU.STYLE
   AND MRI.COLOR = MSKU.COLOR
   AND MRI.DIMENSION = MSKU.DIMENSION
   AND MRI.SKU_SIZE = MSKU.SKU_SIZE
 WHERE NVL(MRI.inventory_quantity, 0) &gt; 0
   AND (NVL(MSKU.WEIGHT_PER_DOZEN, 0) = 0 or NVL(MSKU.VOLUME_PER_DOZEN, 0) = 0)
 GROUP BY MRI.STYLE, MRI.COLOR, MRI.DIMENSION, MRI.SKU_SIZE
     </SelectSql>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true" AllowPaging="true"
       DataSourceID="ds" PagerSettings-Position="TopAndBottom" PageSize='<% $  AppSettings: PageSize  %>'  DefaultSortExpression="style;color;Dimension;SKU_SIZE">
       <Columns>
            <eclipse:SequenceField />
             <asp:BoundField DataField="style" HeaderText="Style" SortExpression="style" />
             <asp:BoundField DataField="color" HeaderText="Color" SortExpression="color" />
             <asp:BoundField DataField="dimension" HeaderText="Dimension" SortExpression="dimension" />
             <asp:BoundField DataField="SKU_SIZE" HeaderText="SKU Size" SortExpression="SKU_SIZE" />
             <asp:BoundField DataField="label_id" HeaderText="Label" SortExpression="label_id" />
             <asp:BoundField DataField="Upc_code" HeaderText="UPC Code" SortExpression="Upc_code" />
             <asp:BoundField DataField="DESCR" HeaderText="Style Description" SortExpression="DESCR" />
             <asp:BoundField DataField="Weight" HeaderText="Weight" SortExpression="Weight" />
             <asp:BoundField DataField="Volume" HeaderText="Cube" SortExpression="Volume" />             
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

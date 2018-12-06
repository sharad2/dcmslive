<%@ Page Title="Allocated and Unallocated Cartons" Language="C#" MasterPageFile="~/MasterPage.master" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7009 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R130_36.aspx 7009 2014-07-03 10:45:36Z skumar $
 * Version Control Template Added.
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displaying allocated and Unallocated cartons along with pieces on the basis of label. Also it is showing total number of carton and pieces for each label." />
    <meta name="ReportId" content="130.36" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_36.aspx 7009 2014-07-03 10:45:36Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:PlaceHolder runat="server" ID="tabs" />
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true" >
        <SelectSql>
        SELECT ms.label_id AS label_id, 
       count(unique cd.carton_id) AS Total_Cartons, 
       SUM(cd.quantity) AS Total_Pieces,
       count(CASE WHEN cd.req_process_id IS NOT NULL THEN cd.carton_id END) AS Allocated_Cartons, 
       SUM(CASE WHEN cd.req_process_id IS NOT NULL THEN cd.quantity END) AS Allocated_Pieces, 
       count(CASE WHEN cd.req_process_id IS NULL THEN cd.carton_id END) AS Unallocated_Cartons,
       SUM(CASE WHEN cd.req_process_id IS NULL THEN cd.quantity END) AS UnAllocated_Pieces
  FROM src_carton_detail cd
 LEFT OUTER JOIN master_style ms
   ON cd.style = ms.style
GROUP BY ms.label_id
        </SelectSql>
        <SelectParameters>
        </SelectParameters>
    </oracle:OracleDataSource>
    <br />
    <br />
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="label_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id" HeaderToolTip="Label of the style" DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}" FooterStyle-HorizontalAlign="Right"/>
            <eclipse:MultiBoundField DataFields="Allocated_Cartons" DataSummaryCalculation="ValueSummation" HeaderText="Cartons|Allocated" SortExpression="Allocated_Cartons" DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}"  ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="Number of cartons which are already reserved against any request"/>
            <eclipse:MultiBoundField DataFields="Unallocated_Cartons" DataSummaryCalculation="ValueSummation" HeaderText="Cartons|Unallocated" SortExpression="Unallocated_Cartons"  DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}"  ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"  HeaderToolTip="Number of cartons which are not reserved"/>
            <%--<eclipse:MultiBoundField DataFields="Total_Cartons" DataSummaryCalculation="ValueSummation" HeaderText="Cartons|Total" SortExpression="Total_Cartons" DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}"  ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderToolTip="How many carton of the each label"/>--%>
           
            <eclipse:SiteHyperLinkField DataTextField="Total_Cartons" DataNavigateUrlFields="label_id" HeaderToolTip="Total number of carton for each label."
                HeaderText="Cartons|Total" DataNavigateUrlFormatString="R40_16.aspx?label_id={0}" DataTextFormatString="{0:#,###}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:#,###}" ItemStyle-HorizontalAlign="Right"
                FooterStyle-HorizontalAlign="Right" SortExpression="Total_Cartons">
            </eclipse:SiteHyperLinkField>

             <eclipse:MultiBoundField DataFields="Allocated_Pieces" DataSummaryCalculation="ValueSummation" HeaderText="Pieces|Allocated" SortExpression="Allocated_Pieces"  DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}"  ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"  HeaderToolTip="Pieces which are in allocated cartons"/>
            <eclipse:MultiBoundField DataFields="UnAllocated_Pieces" DataSummaryCalculation="ValueSummation" HeaderText="Pieces|Unallocated" SortExpression="UnAllocated_Pieces"  DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}"  ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right"  HeaderToolTip="Pieces which are in unallocated cartons"/>
        <eclipse:MultiBoundField DataFields="Total_Pieces" DataSummaryCalculation="ValueSummation" HeaderText="Pieces|Total" 
            SortExpression="Total_Pieces"  DataFooterFormatString="{0:#,###}" DataFormatString="{0:#,###}"  ItemStyle-HorizontalAlign="Right"
             FooterStyle-HorizontalAlign="Right" HeaderToolTip="Total pieces for each label"/>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

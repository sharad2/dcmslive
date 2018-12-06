<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="DCMS to Richter Export Progress Report"  %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 512 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_010/R10_07.aspx $
 *  $Id: R10_07.aspx 512 2011-03-16 08:53:56Z rverma $
 * Version Control Template Added.
 *
--%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays the number of records that are being exported from DCMS to Richter." />
    <meta name="ReportId" content="10.07" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R10_07.aspx 512 2011-03-16 08:53:56Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <ol>
        <%--<li>In the Document some html tag is wrongly closed in short summary.</li>
<li>I found 1 behavior change in the document, what is the reason of it.</li>
<li>There is a section "Report Views" in the document what is the purpose of it</li>
<li>Query's Documentation part is in correct</li>
<li>What is the purpose of Data Tables used in this report section.</li>--%>
    </ol>
    <asp:PlaceHolder runat="server" ID="tabs" />
    <%--<uc:ButtonBar runat="server" />--%>
    <uc2:ButtonBar2  runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
   <SelectSql>
        SELECT 'LOAD_ISI_WM_CHRONO' AS record_type,
                 load.isi_wm_chro_record_name AS isi_wm_chro_record_name,
			     COUNT(*) AS record_count
	        FROM load_isi_wm_chrono load
        GROUP BY load.isi_wm_chro_record_name
        UNION ALL
         SELECT 'LOAD_ISI_WM_CHRONO_POC',
         load_poc.isi_wm_chro_record_name,
                COUNT(*)
           FROM load_isi_wm_chrono_poc load_poc
         GROUP BY load_poc.isi_wm_chro_record_name
   </SelectSql>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AllowSorting="true" ShowFooter="true" DefaultSortExpression="record_type;$;isi_wm_chro_record_name {0} NULLS LAST"
        DataSourceID="ds" AutoGenerateColumns="false">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="record_type" HeaderText="Record Type" SortExpression="record_type" />
            <asp:BoundField DataField="isi_wm_chro_record_name" HeaderText="Record Name" SortExpression="isi_wm_chro_record_name {0} NULLS LAST" />
            <eclipse:MultiBoundField DataFields="record_count" HeaderText="No. of Records" SortExpression="record_count"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

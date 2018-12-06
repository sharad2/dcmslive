<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Carton Aging Report" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5661 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_30.aspx $
 *  $Id: R40_30.aspx 5661 2013-07-17 05:40:13Z skumar $
 * Version Control Template Added.
 *
--%>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="EclipseLibrary.Web.Extensions" %>
<script runat="server">

    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        switch (e.Row.RowType)
        {
            case DataControlRowType.DataRow:
                int nIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.SortExpression == "quarterly_year" ? i : -1)
                    .Single(p => p >= 0);
                int quarterlyYear = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "quarterly_year"));
                if (quarterlyYear >= 8)
                {
                    e.Row.Cells[nIndex].Text = "720+ days";
                }
                else if (quarterlyYear >= 4 && quarterlyYear < 6)
                {
                    e.Row.Cells[nIndex].Text = "360 to 539 days";
                }
                else if (quarterlyYear >= 6 && quarterlyYear < 8)
                {
                    e.Row.Cells[nIndex].Text = "540 to 719 days";
                }
                else
                {
                    int nFrom = 90 * quarterlyYear;
                    int nTo = nFrom + 89;
                    if (nTo <= 89)
                    {
                        e.Row.Cells[nIndex].Text = string.Format("Last {1:N0} days",
                            nFrom, nTo);
                    }
                    else
                    {
                        e.Row.Cells[nIndex].Text = string.Format("{0:N0} to {1:N0} days",
                            nFrom, nTo);
                    }
                }
                break;
        }
    }        
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report displays the number of cartons and the quantity which are lying in the specified area and virtual warehouse ID" />
    <meta name="ReportId" content="40.30" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R40_30.aspx 5661 2013-07-17 05:40:13Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filter">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Specify Carton Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" StorageAreaType="CTN"
                    QueryString="carton_storage_area" Value="<%$ AppSettings:CartonReserveArea %>"
                    ShowAll="true">
                </d:InventoryAreaSelector>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" QueryString="vwh_id">
                </d:VirtualWarehouseSelector>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
<SelectSql> 
WITH carton_aging_details as
(SELECT CASE LEAST(TRUNC((SYSDATE - CTN.INSERT_DATE) / 90), 8)
				 WHEN 5 THEN
					4
				 WHEN 7 THEN
					6
				 ELSE
					LEAST(TRUNC((SYSDATE - CTN.INSERT_DATE) / 90), 8)
			 END AS quarterly_year,
       count(ctn.carton_id) AS no_of_cartons,
       ctn.quality_code AS quality_code,
       sum(ctndet.quantity) AS pieces
  FROM src_carton ctn
  LEFT OUTER JOIN src_carton_detail ctndet on ctn.carton_id = ctndet.carton_id
 WHERE 1=1 
 <if>AND ctn.carton_storage_area = :carton_storage_area</if>
 <if>AND ctn.vwh_id = :vwh_id</if>
 GROUP BY LEAST(trunc((sysdate - ctn.insert_date) / 90), 8), CTN.quality_code
)
 SELECT cad.quarterly_year as quarterly_year,
        cad.quality_code as quality_code,
        SUM(NVL(cad.no_of_cartons, 0)) as no_of_cartons,
        SUM(NVL(cad.pieces, 0)) as pieces
   FROM carton_aging_details cad
   GROUP BY cad.quarterly_year, cad.quality_code
</SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlCtnArea" Direction="Input" Type="String" Name="carton_storage_area" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="quarterly_year"
        OnRowDataBound="gv_RowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField HeaderText="Day Range" SortExpression="quarterly_year" HeaderToolTip="The range of days from currrent date">
                <ItemStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality code of cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="no_of_cartons" HeaderText="No Of Cartons"
                DataTextFormatString="{0:N0}" FooterToolTip="Total cartons" SortExpression="no_of_cartons"
                DataNavigateUrlFormatString="R40_101.aspx?quarterly_year={0}&quality_code={1}"
                HeaderToolTip="Number of cartons lying in the specified area" DataNavigateUrlFields="quarterly_year,quality_code"
                DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" AppliedFiltersControlID="ButtonBar1$af">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="pieces" HeaderText="Pieces" DataFooterFormatString="{0:N0}"
                SortExpression="pieces" HeaderToolTip="Number of pieces in cartons" FooterToolTip="Total number of pieces in the cartons"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

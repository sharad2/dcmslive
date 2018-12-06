<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Rework Productivity Report" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 520 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_08.aspx $
 *  $Id: R150_08.aspx 520 2011-03-16 09:01:00Z rverma $
 * Version Control Template Added.
 *
--%>

<%@ Import Namespace="System.Linq" %>

<%--Shift pattern --%>
<script runat="server">    
   
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("cp.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));

        string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("cp.process_start_date");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Empty);     
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhere, "shift_number"));     
        }     
    }    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays the productivity information of reworkers for specified period of time and shift. This will help in deciding the rework bonus for reworkers. This report can be drilled down on reworker field to see the carton details. " />
    <meta name="ReportId" content="150.08" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R150_08.aspx 520 2011-03-16 09:01:00Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Process Start date" />
                <d:BusinessDateTextBox ID="dtFrom" Text="-7" runat="server" FriendlyName="From">
                <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <d:BusinessDateTextBox ID="dtTo" Text="0" runat="server" FriendlyName="To">
                <Validators>
                        <i:Date DateType="ToDate" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  OnSelecting="ds_Selecting"  >
<SelectSql>
WITH rework_prod as (
SELECT CP.OPERATOR_ID AS OPERATOR_ID,
        <![CDATA[
        $ShiftDateSelectClause$
        ]]>,
       cp.process_start_date AS process_start_date,
       DECODE(CP.WORK_CODES, NULL, NULL, CP.CARTON_ID) AS CARTONS,
       DECODE(CP.WORK_CODES, NULL, CP.CARTON_ID) AS NO_REWORK_CARTONS,
       DECODE(CP.WORK_CODES, NULL, NULL, CP.CARTON_QUANTITY) AS PIECES,
       DECODE(CP.WORK_CODES,
                  NULL,
                  NULL,
                  CP.CARTON_QUANTITY / MS.PIECES_PER_PACKAGE) AS UNITS                 
  FROM carton_productivity cp
       left outer join MASTER_SKU MS
       on cp.upc_code = MS.UPC_CODE
 WHERE cp.module_code = :module_code
   AND cp.work_type = 'REWORK'
   AND cp.process_start_date &gt;= CAST(:process_start_date_from AS DATE)
   AND cp.process_start_date &lt; CAST(:process_start_date_to AS DATE) + 2
   <![CDATA[
   $ShiftNumberWhere$
   ]]>
)
SELECT rp.operator_id,
       count(rp.cartons) AS carton_count,
       count(rp.no_rework_cartons) AS no_rework_cartons_count,
       NVL(sum(rp.pieces),0) AS carton_quantity,
       NVL(sum(rp.units),0) AS units,      
       rp.shift_start_date as shift_start_date,
       max(au.created) as user_setup_date
  FROM rework_prod rp
  LEFT OUTER JOIN all_users au on au.username = rp.operator_id
  WHERE rp.shift_start_date &gt;= CAST(:process_start_date_from AS DATE)
   AND rp.shift_start_date &lt; CAST(:process_start_date_to AS DATE) + 1
Group BY rp.operator_id, rp.shift_start_date
</SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="process_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="process_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:Parameter Name="module_code" Type="String" DefaultValue="<%$  AppSettings: ReworkModuleCode  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="False" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="operator_id;shift_start_date">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="operator_id" HeaderText="Reworker" SortExpression="operator_id"
                DataNavigateUrlFormatString="R150_105.aspx?&operator_id={0}&shift_start_date={1:d}"
                DataNavigateUrlFields="operator_id,shift_start_date" AppliedFiltersControlID="ButtonBar1$af" />
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="Process Date"
                SortExpression="shift_start_date" DataFormatString="{0:d}" HeaderToolTip="Shift start date">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_count" HeaderText="Total|Cartons" SortExpression="carton_count" HeaderToolTip="Number of cartons reworked"
                AccessibleHeaderText="carton_count" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" FooterToolTip="Total cartons reworked"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="units" HeaderText="Total|Units" SortExpression="units" HeaderToolTip="Number of units reworked"
                AccessibleHeaderText="units" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" FooterToolTip="Total units reworked"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_quantity" HeaderText="Total|Pieces" SortExpression="carton_quantity" HeaderToolTip="Number of pieces reworked"  
                AccessibleHeaderText="carton_quantity" DataSummaryCalculation="ValueSummation" FooterToolTip="Total pieces reworked"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="no_rework_cartons_count" HeaderText="Total|No Rework Cartons" HeaderToolTip="Number of cartons on which no rework was performed"
                SortExpression="no_rework_cartons_count" AccessibleHeaderText="no_rework_cartons_count" FooterToolTip="Total cartons on which no rework performed"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Created Date"
                SortExpression="user_setup_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

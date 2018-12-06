<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Rework Productivity Report" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 619 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_105.aspx $
 *  $Id: R150_105.aspx 619 2011-03-30 06:28:20Z rverma $
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
        if(string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$",string.Empty);     
        }
        else 
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhere, "shift_number"));     
        }       
    } 
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report displays the productivity information for specified reworker for specified 
    day and shift. It displays the rework codes along with the reworked cartons, units and pieces. This will help in deciding on the Rework Bonus for reworkers. " />
    <meta name="ReportId" content="150.105" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_105.aspx 619 2011-03-30 06:28:20Z rverma $" />
    
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Reworker" />
                <i:TextBoxEx runat="server" ID="tbReworker" QueryString="operator_id">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Process date" />
                <d:BusinessDateTextBox ID="dtDate" Text="0" runat="server" FriendlyName="Process date" QueryString="shift_start_date">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" QueryString="shift_number" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
  <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  OnSelecting="ds_Selecting" >
    <SelectSql>
    WITH carton_details AS(
SELECT UPPER(cp.work_codes) AS work_codes,
        <![CDATA[
        $ShiftDateSelectClause$
        ]]>,
       cp.carton_id AS carton_id,
       cp.carton_quantity AS carton_quantity,
       (cp.carton_quantity / ms.pieces_per_package) AS pieces_per_package
  FROM carton_productivity cp 
  LEFT OUTER JOIN master_sku ms ON cp.upc_code = ms.upc_code  
 WHERE cp.module_code = :module_code
   AND cp.work_type = :work_type
   AND cp.operator_id = :operator
   AND cp.work_codes IS NOT NULL
   AND cp.process_start_date &gt;= (:process_start_date) 
   AND cp.process_end_date &lt; (:process_start_date) + 2
   <![CDATA[
   $ShiftNumberWhere$
   ]]>
)
 SELECT cd.work_codes as work_codes,
        cd.shift_start_date as shift_start_date,
        count(cd.carton_id) as carton_id,
        sum(NVL(cd.carton_quantity,0)) as carton_quantity,
        sum(NVL(cd.pieces_per_package,0)) as pieces_per_package
  FROM carton_details cd
  WHERE cd.shift_start_date &gt;= (:process_start_date) 
   AND cd.shift_start_date &lt; (:process_start_date) + 1
    GROUP BY work_codes,shift_start_date
    </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="tbReworker" Type="String" Direction="Input" Name="operator_id" />
            <asp:ControlParameter ControlID="dtDate" Type="DateTime" Direction="Input" Name="process_start_date" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:Parameter Name="module_code" Type="String" DefaultValue="<%$  AppSettings: ReworkModuleCode  %>" />
            <asp:ControlParameter ControlID="tbReworker" Type="String" Direction="Input" Name="operator" />
            <asp:Parameter Name="work_type" Type="String" DefaultValue="<%$  AppSettings: WorkType  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="False" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="work_codes">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="work_codes" HeaderText="Rework Codes" SortExpression="work_codes" 
                AccessibleHeaderText="work_codes" />
            <eclipse:MultiBoundField DataFields="carton_id" HeaderText="Total|Cartons" SortExpression="carton_id" HeaderToolTip="Total number of cartons reworked" FooterToolTip="Total cartons reworked"
                AccessibleHeaderText="carton_id" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_quantity" HeaderText="Total|Units" SortExpression="carton_quantity" HeaderToolTip="Total number of units reworked" FooterToolTip="Total units reworked"
                AccessibleHeaderText="carton_quantity" DataSummaryCalculation="ValueSummation"
                DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="pieces_per_package" HeaderText="Total|Pieces" HeaderToolTip="Total number of pieces reworked" FooterToolTip="Total pieces reworked"
                AccessibleHeaderText="pieces_per_package" SortExpression="pieces_per_package"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

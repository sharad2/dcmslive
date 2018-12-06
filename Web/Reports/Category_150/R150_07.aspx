<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Kitter Productivity Report" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1030 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_07.aspx $
 *  $Id: R150_07.aspx 1030 2011-06-15 05:20:14Z rverma $
 * Version Control Template Added.
 *
--%>
<%@ Import Namespace="System.Linq" %>
<%--Shift pattern --%>
<script runat="server">    
   
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        String strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("c.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));

        string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("c.process_start_date");
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
    <meta name="Description" content="This report displays the productivity information of the kitters for specified period of time and shift. This report can be drilled down on kitter field to see the carton details. " />
    <meta name="ReportId" content="150.07" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R150_07.aspx 1030 2011-06-15 05:20:14Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Process Start date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From" Text="-7">
                    <Validators>
                        <i:Date DateType="Default" />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To" Text="0">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
   <%-- <uc:ButtonBar ID="ButtonBar1" runat="server" />--%>
   <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        OnSelecting="ds_Selecting">
          <SelectSql>
          WITH kitter_prod AS
        (
        SELECT c.operator_id AS operator_id,
                <![CDATA[
                $ShiftDateSelectClause$
                ]]>,
               c.pallet_id AS pallet_id,
               c.carton_id AS carton_id,
               c.carton_quantity AS carton_quantity
          FROM carton_productivity c
         WHERE c.module_code = :module_code
           AND c.action_code = :action_code
           AND c.PROCESS_START_DATE &gt;= CAST(:process_start_date_from AS DATE) 
           AND c.PROCESS_START_DATE &lt; CAST(:process_start_date_to AS DATE) + 2
           <![CDATA[
           $ShiftNumberWhere$
           ]]>
        )
        SELECT kp.operator_id AS operator_id,
               NVL(COUNT(DISTINCT kp.pallet_id),0) AS count_pallet_id,
               NVL(COUNT(kp.carton_id),0) AS count_carton_id,
               NVL(SUM(kp.carton_quantity),0) AS sum_carton_quantity,
               kp.shift_start_date as shift_start_date,
               max(au.created) as user_setup_date
          FROM kitter_prod kp          
          LEFT OUTER JOIN all_users au on au.username = kp.operator_id
           AND kp.shift_start_date &gt;= CAST(:process_start_date_from AS DATE) 
           AND kp.shift_start_date &lt; CAST(:process_start_date_to AS DATE) + 1         
          GROUP BY kp.operator_id,shift_start_date
          </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="process_start_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="process_start_date_to" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:Parameter Name="module_code" Type="String" DefaultValue="<%$  AppSettings: K2PModuleCode  %>" />
            <asp:Parameter Name="action_code" Type="String" DefaultValue="<%$  AppSettings: K2PActionCode  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="operator_id;shift_start_date">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="operator_id" HeaderText="Kitter" SortExpression="operator_id"
                DataNavigateUrlFormatString="R150_104.aspx?shift_start_date={0:d}&operator_id={1}"
                DataNavigateUrlFields="shift_start_date,operator_id" AppliedFiltersControlID="ButtonBar1$af" />
            <eclipse:MultiBoundField DataFields="shift_start_date" HeaderText="Process Date" HeaderToolTip="Shift start date"
                SortExpression="shift_start_date" DataFooterFormatString="{0:N0}"
                DataFormatString="{0:d}">
            </eclipse:MultiBoundField>            
            <eclipse:MultiBoundField DataFields="count_pallet_id" HeaderText="Total|Pallets" HeaderToolTip="Total number of pallets whose cartons were scanned by the kitter"
                SortExpression="count_pallet_id" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterToolTip="Total number of pallets"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="count_carton_id" HeaderText="Total|Cartons" HeaderToolTip="Total number of cartons scanned by the kitter"
                SortExpression="count_carton_id" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterToolTip="Total number of cartons"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sum_carton_quantity" HeaderText="Total|Pieces" HeaderToolTip="Total number of pieces of the cartons scanned by the kitter"
                SortExpression="sum_carton_quantity" DataSummaryCalculation="ValueSummation" FooterToolTip="Total number of pieces"
                DataFooterFormatString="{0:N0}" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="user_setup_date" HeaderText="User Setup Date" HeaderToolTip="User created date"
                SortExpression="user_setup_date" DataFormatString="{0:d}">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

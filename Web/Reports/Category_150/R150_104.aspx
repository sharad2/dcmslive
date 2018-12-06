<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Kitter Productivity Report" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 617 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_150/R150_104.aspx $
 *  $Id: R150_104.aspx 617 2011-03-30 06:26:47Z rverma $
 * Version Control Template Added.
 *
--%>
<%@ Import Namespace="System.Linq" %>
<%--Shift pattern --%>
<script runat="server">        
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftDateSelectClause = ShiftSelector.GetShiftDateClause("C.process_start_date");
        e.Command.CommandText = e.Command.CommandText.Replace("$ShiftDateSelectClause$", string.Format("{0} AS shift_start_date", strShiftDateSelectClause));

        string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("C.process_start_date");
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
    <meta name="Description" content="Report displays the productivity information of the kitters for specified period of time and shift. This report can be drilled down on kitter field to see the carton details. " />
    <meta name="ReportId" content="150.104" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R150_104.aspx 617 2011-03-30 06:26:47Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Kitter" />
                <i:TextBoxEx ID="tbOperator" runat="server" QueryString="operator_id">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Process Start date" />
                <d:BusinessDateTextBox ID="dtFrom" Text="0" runat="server" FriendlyName="Process Date"
                    QueryString="shift_start_date">
                    <Validators>
                        <i:Date DateType="Default" />
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  OnSelecting="ds_Selecting" >
        <SelectSql>
        WITH kitter_productivity AS 
 (    
     SELECT UPPER(C.WORK_CODES) AS WORK_CODES,
           <![CDATA[
           $ShiftDateSelectClause$
           ]]>,
            C.process_start_date,
            C.carton_id AS carton_id,
            C.carton_quantity AS carton_quantity
       FROM CARTON_PRODUCTIVITY C
      WHERE C.MODULE_CODE = :module_code
        AND C.ACTION_CODE = :action_code
        AND C.OPERATOR_ID = :operator_id
        AND C.process_start_date &gt;= :process_start_date
        AND C.process_start_date &lt; :process_start_date + 2 
        <![CDATA[
        $ShiftNumberWhere$
        ]]>  
    )
 SELECT kp.WORK_CODES AS work_codes,
        count(kp.CARTON_ID) as carton_count,
        sum(kp.CARTON_QUANTITY) AS carton_quantity
  FROM kitter_productivity kp
  WHERE kp.shift_start_date &gt;= :process_start_date
    AND kp.shift_start_date &lt; :process_start_date + 1           
  GROUP BY work_codes       
        </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="process_start_date" />
            <asp:ControlParameter ControlID="tbOperator" Type="String" Direction="Input" Name="operator_id" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:Parameter Name="module_code" Type="String" DefaultValue="<%$  AppSettings: K2PModuleCode  %>" />
            <asp:Parameter Name="action_code" Type="String" DefaultValue="<%$  AppSettings: K2PActionCode  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" AutoGenerateColumns="False" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="work_codes">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="work_codes" HeaderText="Rework Codes" SortExpression="work_codes">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_count" HeaderText="Total|Cartons" DataSummaryCalculation="ValueSummation"
                SortExpression="carton_count" DataFormatString="{0:N0}" HeaderToolTip="Total number of cartons scanned by the kitter and which has above rework code(s)"
                DataFooterFormatString="{0:N0}" FooterToolTip="Total number of cartons">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_quantity" HeaderText="Total|Pieces" DataSummaryCalculation="ValueSummation"
                HeaderToolTip="Total number of pieces" SortExpression="carton_quantity" DataFormatString="{0:N0}"
                FooterToolTip="Total number of pieces" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

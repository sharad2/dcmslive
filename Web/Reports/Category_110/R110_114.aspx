<%@ Page Title="In Process Report - Box Detail" Language="C#" MasterPageFile="~/MasterPage.master"  %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7084 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_114.aspx $
 *  $Id: R110_114.aspx 7084 2014-07-21 13:43:24Z skumar $
 * Version Control Template Added.
--%>

<script runat="server">
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="
    This report is displaying box id along with expected pieces, current pieces  and  stop process reason in specified box area for passed customer id of un-transferred and un-cancelled orders. The user has option to filter out the data on the basis of specified PO , Customer DC, Pickslip, Label, Bucket and Box Area." />
    <meta name="ReportId" content="110.114" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_114.aspx 7084 2014-07-21 13:43:24Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="lblCustomer" runat="server" Text="Customer ID" />
                <i:TextBoxEx runat="server" QueryString="customer_id" ID="tbCustomer" ToolTip="Customer ID which you want to see the information" />
                <eclipse:LeftLabel ID="lblPo" runat="server" Text="PO" />
                <i:TextBoxEx runat="server" ID="tbPo" QueryString="po_id" ToolTip="Customer Purchase Order." />
                <eclipse:LeftLabel ID="lblCustomerDc" runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbCustomerDc" runat="server" QueryString="customer_dc_id" />
                <eclipse:LeftLabel ID="lblPickslip" runat="server" Text="Pickslip" />
                <i:TextBoxEx ID="tbPickslip" QueryString="pickslip_id" runat="server" ToolTip="Pickslip ID for Purchase Order" >
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:StyleLabelSelector ID="lsLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ShowAll="true" QueryString="label_id" FriendlyName="Label" ToolTip="Select any label to see the order.">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="lblBucket" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucket" runat="server" QueryString="bucket_id" MaxLength="5" ToolTip="Bucket ID which you want to see the information">
                    <Validators>
                        <i:Value ValueType="Integer" ClientMessage="Bucket should be numeric only" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="lblNoDays" runat="server" Text="Pickslip import days from today" />
                <i:TextBoxEx ID="tbNoDays" runat="server" QueryString="no_of_days" Text="60"
                    ToolTip="Pass the number of days. Report will show the information from the days passed till today. By default 60 no. of days.">
                    <Validators>
                    <i:Required />
                    <i:Value ValueType="Integer" Min="1" Max="1800" />
                    </Validators>
                    </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlvwh_id" runat="server" QueryString="vwh_id"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Area" />
                <oracle:OracleDataSource ID="dsAreas" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" >
                      <SelectSql>
                        select distinct (ia_id) as ia_id,
							 '(' || ia_id || ') ' || short_description as short_description,
                             'Physical Areas' AS option_group,							 
					         ia.process_flow_sequence as area_sequence
	                    from ia ia
                     order by area_sequence
                      </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlAreas" runat="server" DataSourceID="dsAreas" DataFields="ia_id,short_description,option_group"
                    QueryString="box_ia_id" FriendlyName="Box Area" DataOptionGroupFormatString="{2}" DataTextFormatString="{1}" 
                    ToolTip="Inventory Area where you see the carton count.">
                    <Items>
                        <eclipse:DropDownItem Text="Expediter Bucket" Value="EB" OptionGroup="Conceptual Areas" Persistent="Always"  />
                        <eclipse:DropDownItem Text="VAS" Value="VAS" OptionGroup="Conceptual Area" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                 <eclipse:LeftLabel ID="LeftLabel" runat="server" />
                <i:CheckBoxEx ID="cbVAS" runat="server" QueryString="vas_id" FriendlyName="Exclusive VAS"
                    CheckedValue="VASID" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
   <%-- <uc:ButtonBar ID="ctlButtonBar" runat="server" />--%>
   <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader"
        >
        <SelectSql>
        SELECT box.ucc128_id AS ucc128_id,
			   SUM(boxdet.expected_pieces) AS expected_pieces,
			   SUM(boxdet.current_pieces) AS current_pieces,
			   MIN(box.stop_process_reason) AS stop_process_reason
	      FROM ps
         INNER JOIN box ON ps.pickslip_id = box.pickslip_id
         INNER JOIN boxdet ON box.pickslip_id = boxdet.pickslip_id
						  AND box.ucc128_id = boxdet.ucc128_id        
         WHERE ps.transfer_date is null
	       AND ps.pickslip_import_date &gt;= CAST(SYSDATE AS DATE) - :no_of_days
	       AND ps.pickslip_import_date &lt; CAST(SYSDATE AS DATE) + 1
           <if c="$box_ia_id ='VAS'">AND ps.pickslip_id in (select pv.pickslip_id from ps_vas pv)
               and box.pallet_id is not null
               and box.Pitching_End_Date is not null
               AND BOX.STOP_PROCESS_DATE IS NULL
               and box.Verify_Date is null
           </if>
            <if c="$box_ia_id ='GRN'"> 
               and box.pallet_id is null
</if>
           
            <if c="$VASID">AND ps.pickslip_id in (select pv.pickslip_id from ps_vas pv)</if>
           <if>AND ps.customer_id=:customer_id</if>         
           <if>AND ps.po_id=:po_id</if>
           <if>AND ps.customer_dc_id=:customer_dc_id</if>
           <if>AND ps.pickslip_id=:pickslip_id</if>
           <if>AND ps.label_id=:label_id</if>
           <if>AND ps.bucket_id=:bucket_id</if>
           <if>AND ps.vwh_id=:vwh_id</if>
           <if c="$box_ia_id ='EB'">AND box.ia_id is null</if>          
           <else c="$box_ia_id !='VAS'">AND box.ia_id=:box_ia_id</else>
         GROUP BY box.ucc128_id
        </SelectSql> 
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPo" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbpickslip" Type="String" Direction="Input" Name="pickslip_id" />
            <asp:ControlParameter ControlID="tbCustomer" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="tbCustomerDc" Type="String" Direction="Input" Name="customer_dc_id" />
            <asp:ControlParameter ControlID="lsLabel" Type="String" Direction="Input" Name="label_id" />
            <asp:ControlParameter ControlID="tbBucket" Type="String" Direction="Input" Name="bucket_id" />
            <asp:ControlParameter ControlID="tbNoDays" Type="Int32" Direction="Input" Name="no_of_days" />
            <asp:ControlParameter ControlID="ctlvwh_id" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ddlAreas" Type="String" Direction="Input" Name="box_ia_id" />
            <asp:ControlParameter ControlID="cbVAS" Type="String" Direction="Input" Name="VASID" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AllowSorting="true" DataSourceID="ds" AutoGenerateColumns="false"
        DefaultSortExpression="ucc128_id" DisplayMasterRow="false" ShowFooter="true"
        AllowPaging="true" PageSize="<%$ AppSettings: PageSize %>">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="ucc128_id" HeaderText="Box" SortExpression="ucc128_id"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFields="ucc128_id" DataNavigateUrlFormatString="R110_117.aspx?&ucc128_id={0}" />
            <eclipse:MultiBoundField DataFields="expected_pieces" HeaderText="Pieces|Expected"
                SortExpression="expected_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="current_pieces" HeaderText="Pieces|Current"
                SortExpression="current_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="stop_process_reason" HeaderText="Stop Process Reason"
                SortExpression="stop_process_reason" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

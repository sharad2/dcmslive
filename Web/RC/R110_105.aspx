<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Location of Box in DC" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4254 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R110_105.aspx $
 *  $Id: R110_105.aspx 4254 2012-08-17 09:47:28Z skumar $
 * Version Control Template Added.
 * drill down added but not compleate
--%>
<%--MultiView Pattern--%>
<script runat="server">
    /// <summary>
    /// This report having multiple view for the same added the code.
    /// </summary>
    /// <param name="e"></param>

    protected override void OnLoad(EventArgs e)
    {
        if (ddlAreas.Value == ConfigurationManager.AppSettings["ShipDocBoxArea"])
        {
            mv.ActiveViewIndex = 1;
            ButtonBar1.GridViewId = gvADR.ID;
        }
        else
        {
            mv.ActiveViewIndex = 0;
            ButtonBar1.GridViewId = gvNotADR.ID;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays boxes of unshipped pickslips lying in specified area along with their SKU detail. Several optional filters are available 
    to help you focus on your orders of interest: PO, Pickslip, Customer, bucket, MPC, Label, DC, DC Cancel date, BOL, Customer Store and ATS date. Only in process pickslips will be
    considered in this report. You also have the option to focus on validated pickslips only. 
    Please Note: Boxes will be repeated in PO Consolidation case." />
    <meta name="ReportId" content="110.105" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_105.aspx 4254 2012-08-17 09:47:28Z skumar $" />
    <style type="text/css">
        /*The style to be applied to the div of template field. Which is a master field */.master_row_entry
        {
            display: inline-block;
            width: 30em;
            margin-top: 2mm;
            margin-bottom: 2mm;
        }
        
        .master_row_entry span
        {
            white-space: nowrap;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Area" />
                <%--DataSource Fetching Area--%>
                <oracle:OracleDataSource ID="dsAreas" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                    <SelectSql>
                      select distinct (ia_id) as ia_id,
							 '(' || ia_id || ') ' || short_description as short_description,						 
					         ia.process_flow_sequence as area_sequence
	                    from ia ia                      
                     order by area_sequence
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlAreas" runat="server" DataSourceID="dsAreas" DataFields="short_description,ia_id"
                    QueryString="box_area_id" FriendlyName="Inventory Area" ToolTip="Inventory Area where you see the carton count."
                    DataTextFormatString="{1}: {0}" DataValueFormatString="{1}">
                    <Items>
                        <eclipse:DropDownItem Text="All" Value="" Persistent="Always" />
                        <eclipse:DropDownItem Text="Non Physical Boxes" Value="Non Physical Boxes" Persistent="Always" />
                        <eclipse:DropDownItem Text="Expediter Bucket" Value="EB" Persistent="Always" />
                        <eclipse:DropDownItem Text="MPC Unstarted" Value="MU" Persistent="Always" />
                        <eclipse:DropDownItem Text="Unstarted Cancelled" Value="UC" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel runat="server" Text="PO" />
                <i:TextBoxEx ID="tbPoId" runat="server" ToolTip="To see carton count of a specific PO(Purchase order) plesae provide PO Id."
                    QueryString="po_id">
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Pickslip" />
                <i:TextBoxEx SkinID="PickslipId" ID="tbPickSlipId" runat="server" />
                <eclipse:LeftLabel runat="server" Text="Customer" />
                <i:TextBoxEx SkinID="CustomerId" ID="tbCustId" runat="server" QueryString="customer_id" />
                <eclipse:LeftLabel runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id">
                    <Validators>
                        <i:Value ValueType="String" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="MPC" />
                <i:TextBoxEx ID="tbMpcId" runat="server" QueryString="mpc_id">
                    <Validators>
                        <i:Value ValueType="Integer" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Store" />
                <i:TextBoxEx ID="tbstore" runat="server" QueryString="customer_store_id" />
                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text=" Bill Of Lading" />
                <i:TextBoxEx ID="tbShipping" runat="server" QueryString="Shipping_Id" FriendlyName="Bill Of Lading" />
                <eclipse:LeftLabel runat="server" />
                <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" FriendlyName="Label"
                    QueryString="label_id" ToolTip="Select any label to see the order." ShowAll="true" />
                <eclipse:LeftLabel runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbDcId" runat="server" QueryString="customer_dc_id" />
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" />
                <i:CheckBoxEx ID="cbValidated" runat="server" QueryString="report_status" FriendlyName="Only Validated Pickslips"
                    CheckedValue="VALIDATED" ToolTip="Check the checkbox to see the box count of only validated pickslips." />
                <eclipse:LeftLabel runat="server" Text="Customer Type" />
                <i:RadioButtonListEx runat="server" ID="rblCustomerType" ToolTip="Customer Type"
                    QueryString="customer_type" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="All" Value="" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftLabel ID="LeftLabel9" runat="server" Text="ATS Date" />
                <d:BusinessDateTextBox ID="dtATSDate" runat="server" FriendlyName="ATS Date" QueryString="ats_date"
                    Text="">
                    <Validators>
                        <i:Date />
                    </Validators>
                </d:BusinessDateTextBox>
                <br />
                Available to Ship date. For EDI orders only.
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbCanceldate" Text="DC Cancel Date" CheckedValue="Y"
                        QueryString="cancel_date" FriendlyName="DC Cancel Date" Checked="false" />
                </eclipse:LeftPanel>
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From DC Cancel Date"
                    QueryString="from_dc_cancel_date" Text="0">
                    <Validators>
                        <i:Filter DependsOn="cbCanceldate" DependsOnState="Checked" />
                        <i:Date />
                    </Validators>
                </d:BusinessDateTextBox>
                To:
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To DC Cancel Date"
                    QueryString="to_dc_cancel_date" Text="7">
                    <Validators>
                        <i:Filter DependsOn="cbCanceldate" DependsOnState="Checked" />
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" />
                <d:BuildingSelector FriendlyName="Building" runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" QueryString="WAREHOUSE_LOCATION_ID" ToolTip="Please Select building "
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <asp:MultiView runat="server" ID="mv" ActiveViewIndex="-1">
        <asp:View ID="View1" runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                <SelectSql>
                    SELECT box.ucc128_id AS ucc128_id,
			               MAX(box.location_id) AS location_id,
			               SUM(boxdet.expected_pieces) AS expected_pieces,
			               SUM(boxdet.current_pieces) AS current_pieces,
			               sku.style AS style,
			               sku.color AS color,
			               sku.dimension AS dimension,
			               sku.sku_size AS sku_size,
			               ps.customer_id AS customer_id,
			               ps.po_id AS po_id,
                           box.ia_id  as area,
			               MAX(ps.bucket_id) AS bucket_id
	                  FROM box box
	                  LEFT OUTER JOIN boxdet boxdet ON box.ucc128_id = boxdet.ucc128_id
								                   AND box.pickslip_id = boxdet.pickslip_id
	                  LEFT OUTER JOIN ps ON box.pickslip_id = ps.pickslip_id
                      left outer join edi_753_754_ps edips on
                                           ps.pickslip_id = edips.pickslip_id
                                           LEFT OUTER JOIN PO
                                           ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
                                           AND PS.PO_ID = PO.PO_ID
                                           AND PS.ITERATION = PO.ITERATION
	                  LEFT OUTER JOIN master_sku sku ON boxdet.upc_code = sku.upc_code
                      <if c="$mpc_id or ($box_area_id and ($box_area_id='MU' or $box_area_id=$work_ia_id_box))">LEFT OUTER JOIN mpcloc mpcloc ON box.ucc128_id = mpcloc.ucc128_id</if>
                      <if c="$box_area_id and ($box_area_id='MU' or $box_area_id=$work_ia_id_box)">LEFT OUTER JOIN mpc mpc ON mpc.mpc_id = mpcloc.mpc_id</if>
                     WHERE ps.reporting_status IS NOT NULL 
                     AND sku.inactive_flag IS NULL
                     <if c="$box_area_id and ($box_area_id !='EB' and $box_area_id !='UC' and $box_area_id !='MU' and $box_area_id != 'Non Physical Boxes' and $box_area_id !=$work_ia_id_box)">AND box.ia_id = :box_area_id</if>
                     <if c="$box_area_id and ($box_area_id ='EB' or $box_area_id='UC' or $box_area_id = 'Non Physical Boxes')">AND box.ia_id is null</if>
                     <if c="$box_area_id and ($box_area_id ='MU' or $box_area_id=$work_ia_id_box)">AND box.ia_id = :work_ia_id_box</if>
                     <if c="$box_area_id and $box_area_id ='EB' ">and box.stop_process_date IS NULL</if>
                     <if c="$box_area_id and $box_area_id ='UC'">and box.stop_process_date IS NOT NULL</if>
                     <if c="$box_area_id and $box_area_id ='MU' ">and mpc.pitching_start_date IS NULL</if>
                     <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
                     <if>AND ps.pickslip_id =CAST(:pickslip_id as NUMBER)</if>
                     <if>and <a pre="PS.customer_id IN (" sep="," post=")">(:customer_id)</a></if>
                     <if>and ps.customer_store_id =:customer_store_id</if>
                     <if>AND PS.SHIPPING_ID = :SHIPPING_ID</if>
                     <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:bucket_id)</a></if>
                     <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
                     <if>AND mpcloc.mpc_id =cast(:mpc_id as number)</if>
                     <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
                     <if>AND ps.label_id =cast(:label_id as varchar2(255))</if>
                     <if c="$ExpFlag = 'I'">AND ps.Export_Flag = 'Y'</if>
                     <if c="$ExpFlag = 'D'"> AND ps.export_flag is null</if>
                     <if c="$validated">AND ps.reporting_status = 'VALIDATED'</if>
                     <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE as DATE)</if>
                     <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE as DATE) +1</if>
                     <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
                     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
                     <if c="$BoxesInBucket">AND BOX.CARTON_ID IS NOT NULL
                   and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                 </if>
                     <if c="$BoxOnPallet">and box.pallet_id is null
                     and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                     </if> 
                     <else>
                     <if c="$box_area_id =$work_ia_id_box">and mpc.pitching_start_date IS NOT NULL</if>
                     </else>
                     GROUP BY box.ucc128_id,
					          sku.style,
					          sku.color,
					          sku.dimension,
					          sku.sku_size,
					          ps.customer_id,
					          ps.po_id,box.ia_id
                </SelectSql>
                <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
                </SysContext>
                <SelectParameters>
                    <asp:ControlParameter Name="box_area_id" ControlID="ddlAreas" PropertyName="value"
                        Type="String" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="tbPoId" Type="String" Direction="Input" Name="po_id" />
                    <asp:ControlParameter ControlID="tbPickSlipId" Type="Int32" Direction="Input" Name="pickslip_id" />
                    <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
                    <asp:ControlParameter ControlID="tbBucketId" Type="String" Direction="Input" Name="bucket_id" />
                    <asp:ControlParameter ControlID="tbMpcId" Type="Int32" Direction="Input" Name="mpc_id" />
                    <asp:ControlParameter ControlID="ls" Type="String" Direction="Input" Name="label_id" />
                    <asp:ControlParameter ControlID="tbDcId" Type="String" Direction="Input" Name="customer_dc_id" />
                    <asp:ControlParameter ControlID="rblCustomerType" Type="String" Direction="Input"
                        Name="ExpFlag" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="cbValidated" Type="String" Direction="Input" Name="validated" />
                    <asp:Parameter Name="work_ia_id_box" Type="String" DefaultValue="<%$  AppSettings: WIPAreaForBox  %>" />
                    <asp:Parameter Name="ia_id_box" Type="String" DefaultValue="MU" />
                    <asp:QueryStringParameter Name="BoxesInBucket" QueryStringField="BoxesInBucket" Direction="Input" />
                     <asp:QueryStringParameter Name="BoxOnPallet" QueryStringField="BoxOnPallet" Direction="Input" />
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                        <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                          <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvNotADR" runat="server" AutoGenerateColumns="false" ShowFooter="true"
                DataSourceID="ds" AllowSorting="true" DefaultSortExpression="customer_id,po_id,ucc128_id;$;location_id"
                AllowPaging="true" PageSize="<%$ AppSettings: PageSize %>">
                <Columns>
                    <eclipse:SequenceField />
                    <asp:TemplateField SortExpression="customer_id,po_id,ucc128_id">
                        <ItemTemplate>
                            <div class="master_row_entry">
                                <%# Eval("customer_id","<span><strong>Customer:</strong>{0}</span>")%>
                                &bull;
                                <%# Eval("po_id","<span><strong>PO:</strong>{0}</span>")%>
                                &bull;
                                <%# Eval("ucc128_id","<span><strong>Box:</strong>{0}</span>")%>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <eclipse:MultiBoundField DataFields="location_id" HeaderText="Location" SortExpression="location_id" />
                    <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" SortExpression="bucket_id" />
                    <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style" />
                    <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color" />
                    <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" />
                    <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size" />
                     <eclipse:MultiBoundField DataFields="area" HeaderText="Area" SortExpression="area" />
                    <eclipse:MultiBoundField DataFields="expected_pieces" HeaderText="Pieces|Expected"
                        SortExpression="expected_pieces" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="current_pieces" HeaderText="Pieces|Current"
                        SortExpression="current_pieces" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View ID="View2" runat="server">
            <oracle:OracleDataSource ID="dsAdr" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                <SelectSql>
                SELECT box.ucc128_id AS ucc128_id,
			         box.pallet_id AS pallet_id,
			         box.carton_id AS carton_id,
			         MAX(box.location_id) AS location_id,
			         SUM(boxdet.expected_pieces) AS expected_pieces,
			         SUM(boxdet.current_pieces) AS current_pieces,
			         sku.style AS style,
			         sku.color AS color,
			         sku.dimension AS dimension,
			         sku.sku_size  AS sku_size,
			         ps.customer_id AS customer_id,
			         ps.po_id AS po_id,
			         MAX(ps.bucket_id) AS bucket_id,
                     box.ia_id as area 
	            FROM box box
	            LEFT OUTER JOIN boxdet boxdet ON box.ucc128_id = boxdet.ucc128_id
							                 AND box.pickslip_id = boxdet.pickslip_id
	            LEFT OUTER JOIN master_sku sku ON boxdet.upc_code = sku.upc_code
	            LEFT OUTER JOIN ps ps ON box.pickslip_id = ps.pickslip_id
                left outer join edi_753_754_ps edips on
                ps.pickslip_id = edips.pickslip_id
                LEFT OUTER JOIN PO ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
                                           AND PS.PO_ID = PO.PO_ID
                                           AND PS.ITERATION = PO.ITERATION
                <if c="$mpc_id">LEFT OUTER JOIN mpcloc mp ON box.ucc128_id = mp.ucc128_id </if>
               WHERE box.ia_id &lt;&gt; :work_ia_id_box
	             AND box.ia_id = :box_area_id
	             AND sku.inactive_flag IS NULL
	             AND ps.reporting_status IS NOT NULL
                 <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
                 <if>AND ps.pickslip_id =CAST(:pickslip_id as NUMBER)</if>
                 <if>and <a pre="PS.customer_id IN (" sep="," post=")">(:customer_id)</a></if>
                 <if>AND PS.SHIPPING_ID = :SHIPPING_ID</if>
                 <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:bucket_id)</a></if>
                 <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
                 <if>AND label_id =cast(:label_id as varchar2(255))</if>
                 <if c="$ExpFlag = 'I'">AND ps.Export_Flag = 'Y'</if>
                 <if c="$ExpFlag = 'D'">AND ps.export_flag is null</if>
                 <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
                 <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
                 <if>AND mp.mpc_id =cast(:mpc_id as number)</if>
                 <if>AND ps.customer_id =CAST(:customer_id as varchar2(255))</if>
                 <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE as DATE)</if>
                 <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE as DATE) +1</if>
                 <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
                 <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
                 <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
                 <if c="$VALIDATED">AND ps.reporting_status = 'VALIDATED'</if>
                 <if c="$BoxesInBucket">AND BOX.CARTON_ID IS NOT NULL
                   and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                 </if>
                 <if c="$BoxOnPallet">and box.pallet_id is null
                     and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                     </if> 
                GROUP BY box.ucc128_id,
					     box.pallet_id,
					     box.carton_id,
					     sku.style,
					     sku.color,
					     sku.dimension,
					     sku.sku_size,
					     ps.customer_id,
					     ps.po_id,
                         box.ia_id
                </SelectSql>
                <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
                </SysContext>
                <SelectParameters>
                    <asp:ControlParameter Name="box_area_id" ControlID="ddlAreas" PropertyName="value"
                        Type="String" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:QueryStringParameter Name="BoxesInBucket" QueryStringField="BoxesInBucket" Direction="Input" />
                    <asp:QueryStringParameter Name="BoxOnPallet" QueryStringField="BoxOnPallet" Direction="Input" />
                    <asp:ControlParameter ControlID="tbPoId" Type="String" Direction="Input" Name="po_id" />
                    <asp:ControlParameter ControlID="tbPickSlipId" Type="Int32" Direction="Input" Name="pickslip_id" />
                    <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
                    <asp:ControlParameter ControlID="tbBucketId" Type="String" Direction="Input" Name="bucket_id" />
                    <asp:ControlParameter ControlID="tbMpcId" Type="Int32" Direction="Input" Name="mpc_id" />
                    <asp:ControlParameter ControlID="ls" Type="String" Direction="Input" Name="label_id" />
                    <asp:ControlParameter ControlID="tbDcId" Type="String" Direction="Input" Name="customer_dc_id" />
                    <asp:ControlParameter ControlID="rblCustomerType" Type="String" Direction="Input"
                        Name="ExpFlag" />
                        <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                          <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="cbValidated" Type="String" Direction="Input" Name="validated" />
                    <asp:Parameter Name="work_ia_id_box" Type="String" DefaultValue="<%$  AppSettings: WIPAreaForBox  %>" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvADR" runat="server" AutoGenerateColumns="false" ShowFooter="true"
                DataSourceID="dsAdr" AllowSorting="true" AllowPaging="true" PageSize="<%$ AppSettings: PageSize %>"
                DefaultSortExpression="pallet_id,ucc128_id,carton_id,customer_id,po_id;Area;$;location_id">
                <Columns>
                    <eclipse:SequenceField />
                    <asp:TemplateField SortExpression="pallet_id,ucc128_id,carton_id,customer_id,po_id">
                        <ItemTemplate>
                            <div class="master_row_entry">
                                <%# Eval("pallet_id","<span><strong>Pallet:</strong> {0}</span>")%>
                                &bull;
                                <%# Eval("ucc128_id","<span><strong>Box:</strong>{0}</span>")%>
                                &bull;
                                <%# Eval("Carton_id","<span><strong>Carton:</strong>{0}<span>")%>
                                &bull;
                                <%# Eval("customer_id","<span><strong>Customer:</strong>{0}</span>")%>
                                &bull;
                                <%# Eval("po_id","<span><strong>PO:</strong>{0}</span>")%>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <eclipse:MultiBoundField DataFields="location_id" HeaderText="Location" SortExpression="location_id" />
                    <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" SortExpression="bucket_id" />
                    <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style" />
                    <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color" />
                    <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dimension" SortExpression="dimension" />
                    <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size" />
                    <eclipse:MultiBoundField DataFields="area" HeaderText="Area" SortExpression="area" />
                    <eclipse:MultiBoundField DataFields="expected_pieces" HeaderText="Expected Pieces"
                        SortExpression="expected_pieces" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="current_pieces" HeaderText="Current Pieces"
                        SortExpression="current_pieces" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Location of Box in DC"
    EnableViewState="false" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6609 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_03.aspx $
 *  $Id: R110_03.aspx 6609 2014-04-01 04:18:37Z skumar $
 * Version Control Template Added.
 * drill down added but not compleate
--%>
<%--Display multiple data bound controls--%> 
<script runat="server">
    /// &lt;summary&gt;
    /// When grid is data bound, data bind the form view
    /// &lt;/summary&gt;
    /// &lt;param name="sender"&gt;&lt;/param&gt;
    /// &lt;param name="e"&gt;&lt;/param&gt;
    protected void ds_Selected(object sender, SqlDataSourceStatusEventArgs e)
    {
        fvTotalPickslips.DataSource = ds1.Select(DataSourceSelectArguments.Empty);
        fvTotalPickslips.DataBind();
    }
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //sets  first date of previous year           
            string str = DateTime.Now.AddDays(-30).ToShortDateString();
            if (string.IsNullOrEmpty(tbFromDeliveryDate.Text))
            {
                // Do not modify date if it is being passed via query string
                tbFromDeliveryDate.Text = str;
            }
            else
            {
                cbDeliverydate.Checked = true;
            }
            if (string.IsNullOrEmpty(tbFromDcCancelDate.Text))
            {
                tbFromDcCancelDate.Text = str;
            }
            else
            {
                cbDcCancelDate.Checked = true;
            }


            DateTime dtThisMonthEndDate = GetMonthEndDate(DateTime.Today);
            str = string.Format("{0:d}", dtThisMonthEndDate);
            if (string.IsNullOrEmpty(tbToDeliveryDate.Text))
            {
                tbToDeliveryDate.Text = str;
            }
            else
            {
                cbDeliverydate.Checked = true;
            }
            if (string.IsNullOrEmpty(tbToDcCancelDate.Text))
            {
                tbToDcCancelDate.Text = str;
            }
            else
            {
                cbDcCancelDate.Checked = true;
            }

        }


        base.OnLoad(e);
    }
    public static DateTime GetMonthEndDate(DateTime current)
    {
        // Accessing private variable using reflection to avoide the need to modify the library
        var __monthStartDates = (IEnumerable<DateTime>)typeof(BusinessDateTextBox).GetField(
            "__monthStartDates", System.Reflection.BindingFlags.NonPublic |
             System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.GetField).GetValue(null);
        var dt = __monthStartDates.OrderBy(p => p).FirstOrDefault(p => p >= current);
        // Assume calendar month end date if date not found
        if (dt == DateTime.MinValue)
        {
            dt = new DateTime(current.Year, current.Month, 1);
            dt.AddMonths(1).AddDays(-1);
            return dt;
        }
        else
        {
            return dt.AddDays(-1);
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="
    This report displays two things. 
                            a) For each area, count of cartons in unshipped pickslips. 
                            b) Number of pickslips in order bucket.  Several optional filters are available to help you focus on your orders of interest:
        PO, Pickslip, Customer, bucket, MPC, Label and DC. All pickslips are in process
        mode. You also have the option to focus on validated pickslips only." />
    <meta name="ReportId" content="110.03" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Pickslip parameter is able to take 10 digit pickslip Id." />
    <meta name="Version" content="$Id: R110_03.aspx 6609 2014-04-01 04:18:37Z skumar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Area" />
                <%--DataSource Fetching Area--%>
                <oracle:OracleDataSource ID="dsAreas" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %> ">
                    <SelectSql>
                     select distinct (ia_id) as ia_id,
							 '(' || ia_id || ') ' || short_description as short_description,
                             'Physical Areas' AS option_group,							 
					         ia.process_flow_sequence as area_sequence
	                    from ia ia
                       where short_name not in (:Restoc_Area, :fpk_area_box, :bulk_area, :doc_area) 
                        and ia.picking_area_flag is null
                     order by area_sequence
                    </SelectSql>
                    <SelectParameters>
                        <asp:Parameter Name="Restoc_Area" Type="String" DefaultValue="<%$  AppSettings: RestockingArea  %>" />
                        <asp:Parameter Name="fpk_area_box" Type="String" DefaultValue="<%$  AppSettings: PickingArea  %>" />
                        <asp:Parameter Name="bulk_area" Type="String" DefaultValue="<%$  AppSettings: BulkAreaForBox  %>" />
                        <asp:Parameter Name="doc_area" Type="String" DefaultValue="<%$  AppSettings: DocArea  %>" />
                    </SelectParameters>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlAreas" runat="server" DataSourceID="dsAreas" DataFields="ia_id,short_description"
                    DataTextFormatString="{1}" FriendlyName="Inventory Area" ToolTip="Inventory Area where you see the carton count.">
                    <Items>
                        <eclipse:DropDownItem Text="All" Value="" Persistent="Always" />
                        <eclipse:DropDownItem Text="Expediter Bucket" Value="EB" Persistent="Always" />
                        <eclipse:DropDownItem Text="(VAS) Value Added Service" Value="VAS" Persistent="Always" />
                        <eclipse:DropDownItem Text="MPC Unstarted" Value="MU" Persistent="Always" />
                        <eclipse:DropDownItem Text="Unstarted Cancelled" Value="UC" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel runat="server" Text="PO" />
                <i:TextBoxEx SkinID="PO" ID="tbPoId" FriendlyName="PO" runat="server" ToolTip="To see carton count of a specific PO(Purchase order) please provide PO Id." />
                <eclipse:LeftLabel runat="server" Text="Pickslip" />
                <i:TextBoxEx ID="tbPickSlipId" FriendlyName="Pickslip" runat="server" QueryString="pickslip_id" MaxLength="11"
                    ToolTip="To see carton count of a specific pickslip please provide pickslip Id." >
                    <Validators>
                        <i:Value ValueType="Integer" ClientMessage="Pickslip should be numeric only." />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="Customer" />
                <i:TextBoxEx SkinID="CustomerId" ID="tbCustId" FriendlyName="Customer" runat="server"
                    ToolTip="To see carton count of a specific customer please provide Customer Id." />
                <eclipse:LeftLabel runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id" FriendlyName="Bucket"
                    ToolTip="To see carton count of a specific bucket please provide bucket Id." Size="10" MaxLength="5">
                    <Validators>
                        <i:Value ValueType="Integer" ClientMessage="Bucket should be numeric only" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" Text="MPC" />
                <i:TextBoxEx ID="tbMpcId" runat="server" QueryString="mpc_id" FriendlyName="MPC"
                    ToolTip="To see carton count of a specific mpc please provide 
                mpc Id."
                    MaxLength="10">
                    <Validators>
                        <i:Value ValueType="Integer" ClientMessage="MPC should be numeric only" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" />
                <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label" QueryString="label_id" ToolTip="Select any label to see the order." />

                <eclipse:LeftPanel ID="LeftPanel5" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbvas" Text="Orders Required VAS" CheckedValue="Y"
                        QueryString="vas" FriendlyName="Orders Required VAS" Checked="false" />
                </eclipse:LeftPanel>
                <%--<asp:Label runat="server" Text="Vas"></asp:Label>--%>
                <oracle:OracleDataSource ID="DsVas" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %> ">
                    <SelectSql>                    
                      SELECT TV.VAS_CODE, TV.DESCRIPTION FROM TAB_VAS TV
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlvas" runat="server" DataSourceID="DsVas"
                    DataFields="VAS_CODE, DESCRIPTION" DataTextFormatString="{0}:{1}"
                    DataValueFormatString="{0}" ToolTip="Vas ID" FriendlyName="VAS TYPE" QueryString="vas_id">
                    <Items>
                        <eclipse:DropDownItem Text="All VAS" Value="vas" Persistent="Always" />
                    </Items>
                    <Validators>
                        <i:Filter DependsOn="cbvas" DependsOnState="Value" DependsOnValue="Y" />
                    </Validators>
                </i:DropDownListEx2>
                <br />
                If you want to see orders that require some specific VAS then please choose it form this drop down list.

                 <eclipse:LeftLabel runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbDcId" runat="server" FriendlyName="Customer DC" ToolTip="To see carton count of a specific dc please provide dc Id."
                    QueryString="customer_dc_id" />
                <eclipse:LeftLabel ID="LeftLabel" runat="server" />
                <i:CheckBoxEx ID="cbValidated" runat="server" QueryString="report_status" FriendlyName="Only Validated Pickslips"
                    CheckedValue="VALIDATED" />
                <eclipse:LeftLabel runat="server" Text="Customer Type" />
                <i:RadioButtonListEx runat="server" ID="rblCustomerType" ToolTip="Customer Type"
                    QueryString="customer_type" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="All" Value="" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbDeliverydate" Text="Start Date" CheckedValue="Y"
                        QueryString="delivery_date" FilterDisabled="true" />
                </eclipse:LeftPanel>
                From
            <d:BusinessDateTextBox ID="tbFromDeliveryDate" runat="server" FriendlyName=" From Start Date"
                QueryString="delivery_start_date">
                <Validators>
                    <i:Filter DependsOn="cbDeliverydate" DependsOnState="Checked" />
                    <i:Date />
                </Validators>
            </d:BusinessDateTextBox>
                To
            <d:BusinessDateTextBox ID="tbToDeliveryDate" runat="server" FriendlyName=" To Start  Date"
                QueryString="delivery_end_date">
                <Validators>
                    <i:Filter DependsOn="cbDeliverydate" DependsOnState="Checked" />
                    <i:Date DateType="ToDate" />
                </Validators>
            </d:BusinessDateTextBox>
                <eclipse:LeftPanel ID="LeftPanel1" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbDcCancelDate" Text="DC Cancel Date" CheckedValue="Y"
                        QueryString="cancel_date" />
                </eclipse:LeftPanel>
                From
            <d:BusinessDateTextBox ID="tbFromDcCancelDate" runat="server" FriendlyName="From Dc Cancel  Date"
                QueryString="from_dc_cancel_date">
                <Validators>
                    <i:Filter DependsOn="cbDcCancelDate" DependsOnState="Checked" />
                    <i:Date />
                </Validators>
            </d:BusinessDateTextBox>
                To
            <d:BusinessDateTextBox ID="tbToDcCancelDate" runat="server" FriendlyName="To Dc Cancel Date"
                QueryString="to_dc_cancel_date">
                <Validators>
                    <i:Filter DependsOn="cbDcCancelDate" DependsOnState="Checked" />
                    <i:Date DateType="ToDate" />
                </Validators>
            </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
            <asp:Panel runat="server">
                <eclipse:TwoColumnPanel runat="server">
                    <eclipse:LeftLabel runat="server" Text="Building" />
                    <oracle:OracleDataSource ID="dsbuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                        <SelectSql>
                               WITH Q1 AS
                                    (SELECT TWL.WAREHOUSE_LOCATION_ID, TWL.DESCRIPTION
                                     FROM TAB_WAREHOUSE_LOCATION TWL
   
                                     UNION
                                     SELECT 'Unknown' AS WAREHOUSE_LOCATION_ID, 'Unknown' AS DESCRIPTION
                                     FROM TAB_WAREHOUSE_LOCATION TWL)
                                     SELECT Q1.WAREHOUSE_LOCATION_ID,
                                     (Q1.WAREHOUSE_LOCATION_ID || ':' || Q1.DESCRIPTION) AS DESCRIPTION
                                      FROM Q1
                            ORDER BY 1
                        </SelectSql>
                    </oracle:OracleDataSource>

                    <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                        DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsbuilding" FriendlyName="Building"
                        QueryString="building">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>

            </asp:Panel>

        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
        <SelectSql>
             SELECT COUNT(dem.pickslip_id) AS order_pickslip_count
         FROM dem_pickslip dem
        WHERE dem.ps_status_id=1
        <if>AND dem.customer_order_id=cast(:po_id as varchar2(25))</if>
        <if>AND dem.pickslip_id =:pickslip_id</if>
        <if>AND dem.customer_id=cast(:customer_id as varchar2(10))</if>
        <if>AND dem.customer_dist_center_id=cast(:customer_dc_id as varchar2(13))</if>
        <if>AND dem.pickslip_type=cast(:label_id as varchar2(5))</if>
        <if c="$ExpFlag = 'I'">AND dem.Export_Flag = 'Y'</if>
        <if c="$ExpFlag = 'D'">AND dem.export_flag is null</if>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPoId" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbPickSlipId" Type="Int64" Direction="Input" Name="pickslip_id" />
            <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="ls" Type="String" Direction="Input" Name="label_id" />
            <asp:ControlParameter ControlID="tbDcId" Type="String" Direction="Input" Name="customer_dc_id" />
            <asp:ControlParameter ControlID="rblCustomerType" Type="String" Direction="Input"
                Name="ExpFlag" />
        </SelectParameters>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
    </oracle:OracleDataSource>
    <asp:FormView runat="server" ID="fvTotalPickslips" CssClass="ui-widget">
        <HeaderTemplate>
            <br />
        </HeaderTemplate>
        <ItemTemplate>
            <asp:Label runat="server" Font-Bold="true" Text='<%# Eval("order_pickslip_count", "{0:N0}") %>' />
            pickslips exist in <em>In Order Bucket</em>
        </ItemTemplate>
        <FooterTemplate>
            <br />
        </FooterTemplate>
    </asp:FormView>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader"
        CancelSelectOnNullParameter="true" OnSelected="ds_Selected">
        <SelectSql>
                 WITH box_area AS 
        ( 
        SELECT CASE
               WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
                   PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL THEN
               'VAS'
               WHEN b.ia_id IS NULL THEN
                   DECODE(b.stop_process_date, NULL, 'EB', 'UC')
               WHEN b.ia_id = :work_ia_id_box THEN
                   DECODE(mpc.pitching_start_date, NULL, 'MU', :work_ia_id_box)
               ELSE
                   b.ia_id
               END AS box_area_id,
		       COUNT(DISTINCT b.ucc128_id) AS count_cartons
          FROM box b
          LEFT OUTER JOIN ps ps ON b.pickslip_id = ps.pickslip_id
           <if c="$delivery_start_date or $delivery_end_date or $dc_cancel_start_date or $dc_cancel_end_date">INNER JOIN po po ON po.customer_id = ps.customer_id and po.po_id = ps.po_id and po.iteration = ps.iteration</if>
          LEFT OUTER JOIN mpcloc mloc ON b.ucc128_id = mloc.ucc128_id
          LEFT OUTER JOIN mpc mpc on mpc.mpc_id = mloc.mpc_id
            LEFT OUTER JOIN PS_VAS PV
                    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
        WHERE ps.transfer_date is null
           <if c="$ia_id = 'VAS'"> 
               AND B.PITCHING_END_DATE IS NOT NULL 
               AND B.VERIFY_DATE IS NULL
                AND PV.VAS_ID IS NOT NULL 
               AND B.PALLET_ID IS NOT NULL
           </if>
           <if c="$ia_id = 'EB'"> and b.ia_id is null and b.stop_process_date is null</if>
           <if c="$ia_id = 'UC'"> and b.ia_id is null and b.stop_process_date is not null</if>
           <if c="$ia_id = 'MU'">and b.ia_id =:work_ia_id_box and mpc.pitching_start_date is null</if>
           <if c="$ia_id = $work_ia_id_box"> and b.ia_id =:work_ia_id_box and mpc.pitching_start_date is not null</if>
           <if c="$ia_id != 'EB' and $ia_id != 'UC' and $ia_id != 'MU' and $ia_id !='VAS' and $ia_id != $work_ia_id_box">
            AND b.ia_id &lt;&gt; :work_ia_id_box and b.ia_id = :ia_id</if>           
           <if>AND ps.po_id= CAST(:po_id as varchar2(25))</if>
           <if>AND ps.pickslip_id= :pickslip_id</if>
           <if>AND ps.customer_id=CAST(:customer_id as varchar2(255))</if>
           <if>AND ps.bucket_id= :bucket_id</if>
           <if>AND ps.customer_dc_id=cast(:customer_dc_id as varchar2(13))</if>
           <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
           <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
           <if>AND po.start_date &lt;= CAST(:delivery_end_date AS DATE)</if>       
           <if>AND po.dc_cancel_date &gt;=CAST(:dc_cancel_start_date AS DATE)</if>
           <if>AND po.dc_cancel_date &lt;=CAST(:dc_cancel_end_date AS DATE)</if> 
           <if>AND ps.label_id=cast(:label_id as varchar2(2))</if>
           <if c="$ExpFlag = 'I'">AND ps.Export_Flag = 'Y'</if>
           <if c="$ExpFlag = 'D'">AND ps.export_flag is null</if>
           <if>AND ps.reporting_status = cast(:Validated as varchar2(40))</if>
           <if>AND mpc.mpc_id = :mpc_id</if>
           <if c="$vas"> 
           AND PV.VAS_ID IS NOT NULL        
           <if c="$vas_id !='vas'">AND PV.VAS_ID =:vas_id</if>    
           </if>
           GROUP BY CASE
               WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
                   PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL THEN
               'VAS'
               WHEN b.ia_id IS NULL THEN
                   DECODE(b.stop_process_date, NULL, 'EB', 'UC')
               WHEN b.ia_id = :work_ia_id_box THEN
                   DECODE(mpc.pitching_start_date, NULL, 'MU', :work_ia_id_box)
               ELSE
                   b.ia_id
               END
        )
        SELECT a.box_area_id AS box_area_id,
               CASE
				 WHEN a.box_area_id = 'EB' THEN
				   'Expediter Bucket'
				 WHEN a.box_area_id = 'MU' THEN
				   'MPC Unstarted'
				 WHEN a.box_area_id = 'UC' THEN
				   'Unstarted Cancelled'
				 ELSE
				   a.box_area_id
			    END AS box_area_discription,
			   a.count_cartons AS count_no_of_boxes
	      FROM box_area a
	      LEFT OUTER JOIN ia ON ia.ia_id = a.box_area_id
          WHERE 1=1
          <if>AND a.box_area_id = :ia_id</if>
	     ORDER BY CASE 
	                WHEN a.box_area_id = :can_ia_id_box THEN -100
	                WHEN a.box_area_id = 'UC' THEN -60
	                WHEN a.box_area_id = 'EB' THEN -50
	                WHEN a.box_area_id = 'MU' THEN -40
                    WHEN a.box_area_id = 'VAS' THEN 25
			        ELSE ia.process_flow_sequence
			      END
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlAreas" Type="String" Direction="Input" PropertyName="Value"
                Name="ia_id" />
            <asp:ControlParameter ControlID="tbPoId" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbPickSlipId" Type="Int64" Direction="Input" Name="pickslip_id" />
            <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="tbBucketId" Type="Int64" Direction="Input" Name="bucket_id" />
            <asp:ControlParameter ControlID="tbMpcId" Type="Int64" Direction="Input" Name="mpc_id" />
            <asp:ControlParameter ControlID="ls" Type="String" Direction="Input" Name="label_id" />
            <asp:ControlParameter ControlID="tbDcId" Type="String" Direction="Input" Name="customer_dc_id" />
            <asp:ControlParameter ControlID="rblCustomerType" Type="String" Direction="Input"
                Name="ExpFlag" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="tbFromDeliveryDate" Type="DateTime" Direction="Input" Name="delivery_start_date" />
            <asp:ControlParameter ControlID="tbToDeliveryDate" Type="DateTime" Direction="Input" Name="delivery_end_date" />
            <asp:ControlParameter ControlID="tbFromDcCancelDate" Type="DateTime" Direction="Input" Name="dc_cancel_start_date" />
            <asp:ControlParameter ControlID="tbToDcCancelDate" Type="DateTime" Direction="Input" Name="dc_cancel_end_date" />
            <asp:ControlParameter ControlID="cbValidated" Type="String" Direction="Input" Name="Validated" />
            <asp:Parameter Name="work_ia_id_box" DbType="String" DefaultValue="<%$  AppSettings: WIPAreaForBox  %>" />
            <asp:Parameter Name="can_ia_id_box" DbType="String" DefaultValue="<%$  AppSettings: CancelArea  %>" />
            <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
            <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
        </SelectParameters>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AllowSorting="false" DataSourceID="ds"
        AutoGenerateColumns="false" DefaultSortExpression="area_sequence" ShowFooter="true"
        PreSorted="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="box_area_discription" DataNavigateUrlFields="box_area_id"
                HeaderText="Inventory Area" DataNavigateUrlFormatString="R110_105.aspx?box_area_id={0}&AreaFlag=Y"
                SortExpression="box_area_id" AppliedFiltersControlID="ctlButtonBar$af">
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="count_no_of_boxes" HeaderText="No of Boxes"
                DataFormatString="{0:N0}" SortExpression="count_no_of_boxes" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

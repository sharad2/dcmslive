<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Location of Box in DC" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6607 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_105.aspx $
 *  $Id: R110_105.aspx 6607 2014-03-31 11:29:48Z skumar $
 * Version Control Template Added.
 * drill down added but not compleate
--%>
<%--MultiView Pattern--%> 
<script runat="server">
    /// <summary>
    /// This report having multiple view for the same added the code.
    /// </summary>
    /// <param name="e"></param>

    //protected override void OnLoad(EventArgs e)
    //{
        
    //        ButtonBar1.GridViewId = gv.ID;
        
    //}
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays boxes of unshipped pickslips lying in specified area along with their SKU detail. Several optional filters are available 
    to help you focus on your orders of interest: PO, Pickslip, Customer, bucket, MPC, Label, DC, DC Cancel date, BOL, Customer Store and ATS date. Only in process pickslips will be
    considered in this report. You also have the option to focus on validated pickslips only. 
    Please Note: Boxes will be repeated in PO Consolidation case." />
    <meta name="ReportId" content="110.105" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_105.aspx 6607 2014-03-31 11:29:48Z skumar $" />
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
    <style type="text/css">
        /*The style to be applied to the div of template field. Which is a master field */ .master_row_entry {
            display: inline-block;
            width: 30em;
            margin-top: 2mm;
            margin-bottom: 2mm;
        }

            .master_row_entry span {
                white-space: nowrap;
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Area" />
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
                        <eclipse:DropDownItem Text="(VAS) Value Added Service" Value="VAS" Persistent="Always" />
                        <eclipse:DropDownItem Text="Non Physical Boxes" Value="Non Physical Boxes" Persistent="Always" />
                        <eclipse:DropDownItem Text="Expediter Bucket" Value="EB" Persistent="Always" />
                        <eclipse:DropDownItem Text="MPC Unstarted" Value="MU" Persistent="Always" />
                        <eclipse:DropDownItem Text="Unstarted Cancelled" Value="UC" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="PO" />
                <i:TextBoxEx ID="tbPoId" runat="server" ToolTip="To see carton count of a specific PO(Purchase order) plesae provide PO Id."
                    QueryString="po_id">
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Pickslip" />
                <i:TextBoxEx ID="tbPickSlipId" runat="server" QueryString="pickslip_id" MaxLength="11" ToolTip="To see carton count of a specific pickslip please provide pickslip Id.">
                    <Validators>
                        <i:Value ValueType="Integer" ClientMessage="Pickslip should be numeric only." />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Customer" />
                <i:TextBoxEx SkinID="CustomerId" ID="tbCustId" runat="server" QueryString="customer_id" />
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id">
                    <Validators>
                        <i:Value ValueType="String" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="MPC" />
                <i:TextBoxEx ID="tbMpcId" runat="server" QueryString="mpc_id">
                    <Validators>
                        <i:Value ValueType="Integer" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text="Store" />
                <i:TextBoxEx ID="tbstore" runat="server" QueryString="customer_store_id" />
                <eclipse:LeftLabel ID="LeftLabel8" runat="server" Text=" Bill Of Lading" />
                <i:TextBoxEx ID="tbShipping" runat="server" Width="60%" QueryString="Shipping_Id"
                    FriendlyName="Bill Of Lading" />
                <eclipse:LeftLabel runat="server" Text="Appointment ID" />
                <i:TextBoxEx ID="tbappointment" runat="server" QueryString="appointment_id" />
                <eclipse:LeftLabel runat="server" Text="Status" />
                <i:TextBoxEx ID="tbstatus" runat="server" QueryString="reporting_status" />
                <eclipse:LeftLabel ID="LeftLabel9" runat="server" />
                <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" FriendlyName="Label"
                    QueryString="label_id" ToolTip="Select any label to see the order." ShowAll="true" />

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
                <eclipse:LeftLabel ID="LeftLabel10" runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbDcId" runat="server" QueryString="customer_dc_id" />
                <eclipse:LeftLabel ID="LeftLabel11" runat="server" />
                <i:CheckBoxEx ID="cbValidated" runat="server" QueryString="report_status" FriendlyName="Only Validated Pickslips"
                    CheckedValue="VALIDATED" ToolTip="Check the checkbox to see the box count of only validated pickslips." />
                <eclipse:LeftLabel ID="LeftLabel12" runat="server" Text="Customer Type" />
                <i:RadioButtonListEx runat="server" ID="rblCustomerType" ToolTip="Customer Type"
                    QueryString="customer_type" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="All" Value="" />
                        <i:RadioItem Text="Domestic" Value="D" />
                        <i:RadioItem Text="International" Value="I" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftLabel ID="LeftLabel13" runat="server" Text="ATS Date" />
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
            </eclipse:TwoColumnPanel>
            <asp:Panel runat="server">
                <eclipse:TwoColumnPanel runat="server">
                    <eclipse:LeftLabel ID="LeftLabel14" runat="server" Text="Building" />
                    <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
                        DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                        QueryString="building">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
            <if c="$box_area_id='GRN'">
            WITH Q1 AS (
                SELECT box.ucc128_id AS ucc128_id,
                         CASE
           WHEN BOX.PITCHING_END_DATE IS NOT NULL AND BOX.VERIFY_DATE IS NULL AND
                PV.VAS_ID IS NOT NULL AND BOX.PALLET_ID IS NOT NULL THEN
            'VAS'
           ELSE
            BOX.IA_ID
         END AS BOX_AREA_ID,
			               MAX(box.location_id) AS location_id,
                           max(box.pallet_id) as pallet_id,
                           max(box.carton_id) as carton_id,
			               SUM(boxdet.expected_pieces) AS expected_pieces,
			               SUM(boxdet.current_pieces) AS current_pieces,
			               sku.style AS style,
			               sku.color AS color,
			               sku.dimension AS dimension,
			               sku.sku_size AS sku_size,
			               ps.customer_id AS customer_id,
			               ps.po_id AS po_id,
                           SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION, (TV.DESCRIPTION || ','), ''))) AS vas_id,
			               MAX(ps.bucket_id) AS bucket_id
	                  FROM box box
	                  LEFT OUTER JOIN boxdet boxdet ON box.ucc128_id = boxdet.ucc128_id
								                   AND box.pickslip_id = boxdet.pickslip_id
	                  LEFT OUTER JOIN ps ON box.pickslip_id = ps.pickslip_id
                      left outer join edi_753_754_ps edips on
                                           ps.pickslip_id = edips.pickslip_id
                      LEFT OUTER JOIN PO ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
                      AND PS.PO_ID = PO.PO_ID
                      AND PS.ITERATION = PO.ITERATION
                    LEFT OUTER JOIN PS_VAS PV
                    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
                    LEFT OUTER JOIN tab_vas tv on
                        pv.vas_id = tv.vas_CODE
                       LEFT OUTER JOIN SHIP S
                                      ON PS.SHIPPING_ID = S.SHIPPING_ID
	                  LEFT OUTER JOIN master_sku sku ON boxdet.upc_code = sku.upc_code
                      <if c="$mpc_id or ($box_area_id and ($box_area_id='MU' or $box_area_id=$work_ia_id_box))">LEFT OUTER JOIN mpcloc mpcloc ON box.ucc128_id = mpcloc.ucc128_id</if>
                      <if c="$box_area_id and ($box_area_id='MU' or $box_area_id=$work_ia_id_box)">LEFT OUTER JOIN mpc mpc ON mpc.mpc_id = mpcloc.mpc_id</if>
                     WHERE ps.transfer_date is null 
                     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
                     <if c="$box_area_id and ($box_area_id !='EB' and $box_area_id !='UC' and $box_area_id !='MU' and $box_area_id !='VAS' and $box_area_id != 'Non Physical Boxes' and $box_area_id !=$work_ia_id_box)">AND box.ia_id = :box_area_id</if>
                     <if c="$box_area_id and ($box_area_id ='EB' or $box_area_id='UC' or $box_area_id = 'Non Physical Boxes')">AND box.ia_id is null</if>
                     <if c="$box_area_id and ($box_area_id ='MU' or $box_area_id=$work_ia_id_box)">AND box.ia_id = :work_ia_id_box
                     </if>
                     <if c="$box_area_id ='EB' ">and box.stop_process_date IS NULL</if>
                     <if c="$box_area_id ='UC'">and box.stop_process_date IS NOT NULL</if>
                     <if c="$box_area_id ='MU' ">and mpc.pitching_start_date IS NULL</if>
                     <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
                     <if>AND ps.pickslip_id =:pickslip_id</if>
                     <if>and PS.customer_id =:customer_id</if>
                     <if>and <a pre="ps.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
                     <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
                     <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">(:bucket_id)</a></if>
                     <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
                     <if>AND mpcloc.mpc_id =cast(:mpc_id as number)</if>
                     <if>AND ps.label_id =cast(:label_id as varchar2(255))</if>
                     <if c="$ExpFlag = 'I'">AND ps.Export_Flag = 'Y'</if>
                     <if c="$ExpFlag = 'D'"> AND ps.export_flag is null</if>
                     <if c="$validated">AND ps.reporting_status = 'VALIDATED'</if>
                     <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE as DATE)</if>
                     <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE as DATE) +1</if>
                     <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
                     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
                     <if>and PS.REPORTING_STATUS =:REPORTING_STATUS</if>
                     <if c="$vas"> 
                        and pv.vas_id is not null        
                     <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
                     </if>
                    <if c="$box_area_id='VAS'">
                       AND Box.PITCHING_END_DATE IS NOT NULL AND Box.VERIFY_DATE IS NULL AND
                       PV.VAS_ID IS NOT NULL AND BOX.PALLET_ID IS NOT NULL
                    </if>
                     <if c="$BoxesInBucket">AND BOX.CARTON_ID IS NOT NULL
                     and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                     and BOX.IA_ID_COPY ='NOA'
                    </if>
                     <if c="$BoxOnPallet">and box.pallet_id is null
                     and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                     <if>and s.appointment_id =:appointment_id</if>
                     </if> 
                 <else>
                     <if c="$box_area_id =$work_ia_id_box">and mpc.pitching_start_date IS NOT NULL 
                     </if>
                     </else>
                     GROUP BY box.ucc128_id,
					          sku.style,
					          sku.color,
					          sku.dimension,
					          sku.sku_size,
					          ps.customer_id,
					          ps.po_id,
                    CASE
           WHEN BOX.PITCHING_END_DATE IS NOT NULL AND BOX.VERIFY_DATE IS NULL AND
                PV.VAS_ID IS NOT NULL AND BOX.PALLET_ID IS NOT NULL THEN
            'VAS'
           ELSE
            BOX.IA_ID
         END
            )

SELECT UCC128_ID,
       BOX_AREA_ID,
       LOCATION_ID,
       PALLET_ID,
       CARTON_ID,
       EXPECTED_PIECES,
       CURRENT_PIECES,
       STYLE,
       COLOR,
       DIMENSION,
       SKU_SIZE,
       CUSTOMER_ID,
       PO_ID,
       VAS_ID,
       BUCKET_ID
      FROM Q1 Q WHERE Q.BOX_AREA_ID = :box_area_id         
            </if>
            <else>
                SELECT box.ucc128_id AS ucc128_id,

			               MAX(box.location_id) AS location_id,
                           max(box.pallet_id) as pallet_id,
                           max(box.carton_id) as carton_id,
			               SUM(boxdet.expected_pieces) AS expected_pieces,
			               SUM(boxdet.current_pieces) AS current_pieces,
			               sku.style AS style,
			               sku.color AS color,
			               sku.dimension AS dimension,
			               sku.sku_size AS sku_size,
			               ps.customer_id AS customer_id,
			               ps.po_id AS po_id,
                           SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION, (TV.DESCRIPTION || ','), ''))) AS vas_id,
			               MAX(ps.bucket_id) AS bucket_id
	                  FROM box box
	                  LEFT OUTER JOIN boxdet boxdet ON box.ucc128_id = boxdet.ucc128_id
								                   AND box.pickslip_id = boxdet.pickslip_id
	                  LEFT OUTER JOIN ps ON box.pickslip_id = ps.pickslip_id
                      left outer join edi_753_754_ps edips on
                                           ps.pickslip_id = edips.pickslip_id
                      LEFT OUTER JOIN PO ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
                      AND PS.PO_ID = PO.PO_ID
                      AND PS.ITERATION = PO.ITERATION
                    LEFT OUTER JOIN PS_VAS PV
                    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
                    LEFT OUTER JOIN tab_vas tv on
                        pv.vas_id = tv.vas_CODE
                       LEFT OUTER JOIN SHIP S
                                      ON PS.SHIPPING_ID = S.SHIPPING_ID
	                  LEFT OUTER JOIN master_sku sku ON boxdet.upc_code = sku.upc_code
                      <if c="$mpc_id or ($box_area_id and ($box_area_id='MU' or $box_area_id=$work_ia_id_box))">LEFT OUTER JOIN mpcloc mpcloc ON box.ucc128_id = mpcloc.ucc128_id</if>
                      <if c="$box_area_id and ($box_area_id='MU' or $box_area_id=$work_ia_id_box)">LEFT OUTER JOIN mpc mpc ON mpc.mpc_id = mpcloc.mpc_id</if>
                     WHERE ps.transfer_date is null 
                     <if>AND <a pre="NVL(ps.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
                     <if c="$box_area_id and ($box_area_id !='EB' and $box_area_id !='UC' and $box_area_id !='MU' and $box_area_id !='VAS' and $box_area_id != 'Non Physical Boxes' and $box_area_id !=$work_ia_id_box)">AND box.ia_id = :box_area_id</if>
                     <if c="$box_area_id and ($box_area_id ='EB' or $box_area_id='UC' or $box_area_id = 'Non Physical Boxes')">AND box.ia_id is null</if>
                     <if c="$box_area_id and ($box_area_id ='MU' or $box_area_id=$work_ia_id_box)">AND box.ia_id = :work_ia_id_box
                     </if>
                     <if c="$box_area_id ='EB' ">and box.stop_process_date IS NULL</if>
                     <if c="$box_area_id ='UC'">and box.stop_process_date IS NOT NULL</if>
                     <if c="$box_area_id ='MU' ">and mpc.pitching_start_date IS NULL</if>
                     <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
                     <if>AND ps.pickslip_id =:pickslip_id</if>
                     <if>and PS.customer_id =:customer_id</if>
                     <if>and <a pre="ps.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
                     <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
                     <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">(:bucket_id)</a></if>
                     <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
                     <if>AND mpcloc.mpc_id =cast(:mpc_id as number)</if>
                     <if>AND ps.label_id =cast(:label_id as varchar2(255))</if>
                     <if c="$ExpFlag = 'I'">AND ps.Export_Flag = 'Y'</if>
                     <if c="$ExpFlag = 'D'"> AND ps.export_flag is null</if>
                     <if c="$validated">AND ps.reporting_status = 'VALIDATED'</if>
                     <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE as DATE)</if>
                     <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE as DATE) +1</if>
                     <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
                     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
                     <if>and PS.REPORTING_STATUS =:REPORTING_STATUS</if>
                     <if c="$vas"> 
                        and pv.vas_id is not null        
                     <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
                 </if>
                    <if c="$box_area_id='VAS'">
                       AND Box.PITCHING_END_DATE IS NOT NULL AND Box.VERIFY_DATE IS NULL AND
                       PV.VAS_ID IS NOT NULL AND BOX.PALLET_ID IS NOT NULL
                    </if>
                     <if c="$BoxesInBucket">AND BOX.CARTON_ID IS NOT NULL
                     and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                     and BOX.IA_ID_COPY ='NOA'
                    </if>
                     <if c="$BoxOnPallet">and box.pallet_id is null
                     and box.STOP_PROCESS_DATE IS NULL
                     and boxdet.STOP_PROCESS_DATE IS NULL
                     <if>and s.appointment_id =:appointment_id</if>
                     </if> 
                  <else>
                     <if c="$box_area_id =$work_ia_id_box">and mpc.pitching_start_date IS NOT NULL 
                     </if>
                      </else>
                     GROUP BY box.ucc128_id,
					          sku.style,
					          sku.color,
					          sku.dimension,
					          sku.sku_size,
					          ps.customer_id,
					          ps.po_id
            </else>
        </SelectSql>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
        <SelectParameters>
            <asp:ControlParameter Name="box_area_id" ControlID="ddlAreas" PropertyName="value"
                Type="String" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbPoId" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbPickSlipId" Type="String" Direction="Input" Name="pickslip_id" />
            <asp:ControlParameter ControlID="tbCustId" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="tbBucketId" Type="String" Direction="Input" Name="bucket_id" />
            <asp:ControlParameter ControlID="tbMpcId" Type="Int32" Direction="Input" Name="mpc_id" />
            <asp:ControlParameter ControlID="ls" Type="String" Direction="Input" Name="label_id" />
            <asp:ControlParameter ControlID="tbDcId" Type="String" Direction="Input" Name="customer_dc_id" />
            <asp:ControlParameter ControlID="rblCustomerType" Type="String" Direction="Input"
                Name="ExpFlag" />
            <asp:ControlParameter ControlID="tbstatus" Type="String" Direction="Input" Name="REPORTING_STATUS" />
            <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="cbValidated" Type="String" Direction="Input" Name="validated" />
            <asp:Parameter Name="work_ia_id_box" Type="String" DefaultValue="<%$  AppSettings: WIPAreaForBox  %>" />
            <asp:Parameter Name="ia_id_box" Type="String" DefaultValue="MU" />
            <asp:QueryStringParameter Name="BoxesInBucket" QueryStringField="BoxesInBucket" Direction="Input" />
            <asp:QueryStringParameter Name="BoxOnPallet" QueryStringField="BoxOnPallet" Direction="Input" />

            <asp:QueryStringParameter Name="AreaFlag" QueryStringField="AreaFlag" Direction="Input" />

            <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="tbappointment" Name="appointment_id" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
            <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" ShowFooter="true"
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
                                <%# Eval("pallet_id","<span><strong>Pallet:</strong>{0}</span>")%>
                                &bull;
                                <%# Eval("ucc128_id","<span><strong>Box:</strong>{0}</span>")%> 
                                 &bull;
                                <%# Eval("vas_id","<span><strong>VAS:</strong>{0}</span>")%>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="location_id" HeaderText="Location" SortExpression="location_id" />
            <eclipse:MultiBoundField DataFields="carton_id" HeaderText="carton" SortExpression="carton_id" HideEmptyColumn="true" />
            <eclipse:MultiBoundField DataFields="bucket_id" HeaderText="Bucket" SortExpression="bucket_id" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension" />
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size" />
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
</asp:Content>

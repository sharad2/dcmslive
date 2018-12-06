 <%@ Page Title="Open Bucket Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7130 $
 *  $Author: apanwar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_140/R140_02.aspx $
 *  $Id: R140_02.aspx 7130 2014-08-14 08:02:15Z apanwar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        //ds.CommandParsing += new EventHandler<CommandParsingEventArgs>(ds_CommandParsing);
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
            if (string.IsNullOrEmpty(tbFromDcCancelDate.Text))
            {
                tbFromDcCancelDate.Text = str;
            }
            DateTime dtThisMonthEndDate = GetMonthEndDate(DateTime.Today);
            str = string.Format("{0:d}", dtThisMonthEndDate);
            if (string.IsNullOrEmpty(tbToDeliveryDate.Text))
            {
                tbToDeliveryDate.Text = str;
            }
            if (string.IsNullOrEmpty(tbToDcCancelDate.Text))
            {
                tbToDcCancelDate.Text = str;
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
    <meta name="Description" content="This report display details of buckets which are opened for processing. You can see details for specified Bucket, Label or Customer, through filters available for this report. You can also specify a value to exclude the Buckets older than the specified number of days. You can see details for the pitching and checking only by select the 'Pitching only' and 'Checking only' filters. This report also display the status of bucket i.e. frozen or unfrozen." />
    <meta name="ReportId" content="140.02" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Drill down report 140.102 and 105 are being changed for showing whether the assigned location for the SKU is marked as freeze or not. This information will be intimated by showing a check sign in a new column named as 'Is Any Assigned Location Freeze?' which can be found next to column 'Assigned Locations' in both reports.|Drill down reoprts 140.102 and 140.105 will show a tick sign in column 'Is Any Assigned Location Marked For CYC?' against those SKUs which are assigned to any locations whicha is marked for CYC.|In drill down report 140.102 and 140.105, following column names have been changed: 'Location' to 'Assigned Location' and 'UPC Code' to 'UPC'.|Canceled pieces were also included in  the Unprocessed Pieces, which are now excluded." />
    <meta name="Version" content="$Id: R140_02.aspx 7130 2014-08-14 08:02:15Z apanwar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
                $('#cbAll').attr('checked', 'checked');
            };
           
        });
        function cbAll_OnClientChange(event, ui) {
            if ($('#cbAll').is(':checked')) {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').removeAttr('checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id" ToolTip="Enter ID of the bucket for which you want to see this report">
                    <Validators>
                        <i:Value ValueType="Integer" MaxLength="5" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" ToolTip="Click to choose label from the list"
                    FriendlyName="Label">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Customer" />
                <i:TextBoxEx ID="tbCustomerId" runat="server" QueryString="customer_id" ToolTip="Enter ID of the customer for which you want to see this report" />
                <br />
                The customer for which you want to see the Buckets.
                <eclipse:LeftLabel ID="lblNoDays" runat="server" Text="Exclude Buckets Older Than" />
                <i:TextBoxEx ID="tbNoDays" runat="server" QueryString="no_of_days" ToolTip="Enter number of days. Number should be in between 1-2000">
                    <Validators>
                        <i:Value ValueType="Integer" Min="1" Max="2000" ClientMessage="Value must lies between 1 and 2000 both inclusive." />
                    </Validators>
                </i:TextBoxEx>
                (1 to 2000)Days
                <eclipse:LeftLabel runat="server" Text="Pick Mode" />
                <i:RadioButtonListEx runat="server" ID="rblPickMode" ToolTip="Lists bucket for the select pick mode"
                    QueryString="pick_mode" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="All" Value="" />
                        <i:RadioItem Text="Pitching" Value="PITCHING" />
                        <i:RadioItem Text="Checking" Value="CHECKING" />
                        <i:RadioItem Text="ADR Exclusive (ADRE)" Value="ADRE" />
                        <i:RadioItem Text="ADR Exclusive - Label pre printed (ADREPPWSS)" Value="ADREPPWSS" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftLabel runat="server" Text="Bucket Status" />
                <i:RadioButtonListEx runat="server" ID="rblBucketStatus" ToolTip="Restrict the report to list only freeze or un freeze buckets"
                    QueryString="bucket_status">
                    <Items>
                        <i:RadioItem Text="Both" Value="" />
                        <i:RadioItem Text="Frozen" Value="F" />
                        <i:RadioItem Text="Unfrozen" Value="U" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:CheckBoxEx runat="server" ID="cbDeliverydate" Text="Start Date" CheckedValue="Y"
                        QueryString="delivery_date" FilterDisabled="true" ToolTip="Use this filter to see this report for the desired Start Date range" />
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
                        QueryString="dc_cancel_date" FilterDisabled="true" ToolTip="Use this filter to see this report for the desired DC Cancel Date range" />
                </eclipse:LeftPanel>
                From
                <d:BusinessDateTextBox ID="tbFromDcCancelDate" runat="server" FriendlyName="From Dc Cancel  Date"
                    QueryString="dc_cancel_start_date">
                    <Validators>
                        <i:Filter DependsOn="cbDcCancelDate" DependsOnState="Checked" />
                        <i:Date />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="tbToDcCancelDate" runat="server" FriendlyName="To Dc Cancel Date"
                    QueryString="dc_cancel_end_date">
                    <Validators>
                        <i:Filter DependsOn="cbDcCancelDate" DependsOnState="Checked" />
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ToolTip="Choose the desired virtual warehouse for which you want to see this report"  />
                 <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server"  Text="Building"/>
                     <br />
                     <br />
                    <i:CheckBoxEx ID="cbAll" runat="server" FriendlyName="Select All" OnClientChange="cbAll_OnClientChange" ToolTip="Use this filter to run this report for the desired buildings">                     
                    </i:CheckBoxEx>
                     Click to Select/UnSelect all
                </eclipse:LeftPanel>
               <%-- <i:CheckBoxEx ID="cbAll" runat="server" Text="Select All" OnClientChange="cbAll_OnClientChange" ></i:CheckBoxEx>--%>
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
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
            WITH  PICKSLIP_INFO AS
 (SELECT MAX(PS.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID,
         MAX(PS.VWH_ID) AS VWH_ID,
         MAX(PS.BUCKET_ID) AS BUCKET_ID,
         MAX(PS.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
         PS.PICKSLIP_ID,
         MAX(BKT.NAME) AS BUCKET_NAME,
         MAX(DECODE(BKT.FREEZE, '', 'Y', '')) AS UNFREEZE,
         MAX(BKT.PICK_MODE) AS PICK_MODE,
         MIN(PO.DC_CANCEL_DATE) AS MIN_DC_CANCEL_DATE,
         MIN(PO.START_DATE) AS MIN_START_DATE,
         COUNT(DISTINCT B.UCC128_ID) AS COUNT_OF_BOX,
         COUNT(DISTINCT(CASE
                          WHEN B.IA_ID = CAST(:RedBoxArea AS VARCHAR2(3)) THEN
                           B.UCC128_ID
                        END)) AS COUNT_OF_RED_BOX,
         COUNT(DISTINCT(CASE
                          WHEN B.IA_ID_COPY = 'NOA' THEN
                           B.UCC128_ID
                        END)) AS COUNT_OF_UNAVAILABLE_BOX,
         COUNT(DISTINCT B.CARTON_ID) AS COUNT_OF_PULLABLE_BOX,
         COUNT(DISTINCT(CASE
                          WHEN B.IA_ID_COPY = 'NOA' THEN
                           B.CARTON_ID
                        END)) AS ABOUT_TO_PULL_CARTONS,
         SUM(BD.CURRENT_PIECES) AS PICKED_PIECES
    FROM PS
    LEFT OUTER JOIN BUCKET BKT
      ON PS.BUCKET_ID = BKT.BUCKET_ID
    LEFT OUTER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
     AND B.STOP_PROCESS_DATE IS NULL
    LEFT OUTER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
          AND BD.STOP_PROCESS_DATE IS NULL
   WHERE PS.REPORTING_STATUS = 'UNDER PROCESS'
     <if>AND bKT.date_created &gt;= SYSDATE - cast(:days as number(5))</if>
     <if>AND ps.bucket_id=cast(:bucket_id as number(5))</if>
     <if>AND <a pre="NVL(PS.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>AND BKT.pick_mode = CAST(:pick_mode as varchar2(255))</if>
     <if c="$bucket_status='F'">AND BKT.freeze IS NOT NULL</if>
     <if c="$bucket_status='U'">AND BKT.freeze IS NULL</if>
     <if>AND ps.label_id=cast(:label_id as varchar2(255))</if>  
     <if>AND ps.customer_id=CAST(:customer_id as varchar2(255))</if>
     <if>and ps.vwh_id=:vwh_id</if>
     <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
     <if>AND po.start_date &lt; CAST(:delivery_end_date AS DATE) +1</if>       
     <if>AND po.dc_cancel_date &gt;=CAST(:dc_cancel_start_date AS DATE) </if>
     <if>AND po.dc_cancel_date &lt;CAST(:dc_cancel_end_date AS DATE) +1</if> 
     AND PS.TRANSFER_DATE IS NULL    
   GROUP BY PS.PICKSLIP_ID),
CANCEL_PIECES AS
 (SELECT B.PICKSLIP_ID, SUM(BD.EXPECTED_PIECES) AS CANCELLED_PIECES
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
   WHERE B.STOP_PROCESS_REASON = '$BOXCANCEL'
     AND B.PICKSLIP_ID IN (SELECT PI.PICKSLIP_ID FROM PICKSLIP_INFO PI)
   GROUP BY B.PICKSLIP_ID)
SELECT COUNT(DISTINCT Q1.PICKSLIP_ID) AS COUNT_OF_PICKSLIP,
       Q1.BUCKET_ID AS BUCKET_ID,
       MAX(Q1.BUCKET_NAME) AS BUCKET_NAME,
       MAX(Q1.WAREHOUSE_LOCATION_ID) AS WAREHOUSE_LOCATION_ID,
       MAX(Q1.VWH_ID) AS VWH_ID,
       SUM(Q1.TOTAL_QUANTITY_ORDERED) AS TOTAL_QUANTITY_ORDERED,
       CASE WHEN SUM(Q1.COUNT_OF_BOX) &gt; 0
            THEN 'Y' ELSE '' END  AS AVAILABLE_FOR_PITCHING,
       MIN(Q1.UNFREEZE) AS UNFREEZE,
       MIN(Q1.PICK_MODE) AS PICK_MODE,
       MIN(Q1.MIN_DC_CANCEL_DATE) AS MIN_DC_CANCEL_DATE,
       MIN(Q1.MIN_START_DATE) AS MIN_START_DATE, 
       SUM(Q1.COUNT_OF_BOX) AS COUNT_OF_BOX,
       SUM(Q1.COUNT_OF_RED_BOX) AS COUNT_OF_RED_BOX,
       SUM(Q1.COUNT_OF_UNAVAILABLE_BOX) AS COUNT_OF_UNAVAILABLE_BOX,
       SUM(Q1.COUNT_OF_PULLABLE_BOX) AS COUNT_OF_PULLABLE_BOX,
       SUM(Q1.ABOUT_TO_PULL_CARTONS) AS ABOUT_TO_PULL_CARTONS,
       SUM((NVL(Q1.TOTAL_QUANTITY_ORDERED, 0) - NVL(CANCELLED_PIECES, 0)) -
           NVL(Q1.PICKED_PIECES, 0)) AS UNPROCESSEDPIECES
  FROM PICKSLIP_INFO Q1
  LEFT OUTER JOIN CANCEL_PIECES CP
    ON Q1.PICKSLIP_ID = CP.PICKSLIP_ID
 GROUP BY Q1.BUCKET_ID    
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbNoDays" Direction="Input" Name="days" Type="Int32" />
            <asp:ControlParameter ControlID="tbBucketId" Type="Int32" Direction="Input" Name="bucket_id" />
            <asp:ControlParameter ControlID="ctlLabel" Type="String" Direction="Input" Name="label_id" />
            <asp:ControlParameter ControlID="tbCustomerId" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="rblPickMode" Type="String" Direction="Input" Name="pick_mode" />
            <asp:ControlParameter ControlID="tbFromDeliveryDate" Type="DateTime" Direction="Input"
                Name="delivery_start_date" />
            <asp:ControlParameter ControlID="tbToDeliveryDate" Type="DateTime" Direction="Input"
                Name="delivery_end_date" />
            <asp:ControlParameter ControlID="tbFromDcCancelDate" Type="DateTime" Direction="Input"
                Name="dc_cancel_start_date" />
            <asp:ControlParameter ControlID="tbToDcCancelDate" Type="DateTime" Direction="Input"
                Name="dc_cancel_end_date" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="rblBucketStatus" Direction="Input" Name="bucket_status"
                Type="String" />
            <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="bucket_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="warehouse_location_id" SortExpression="warehouse_location_id"
                HeaderText="Building" HeaderToolTip="Building of the Bucket" />
            <eclipse:MultiBoundField DataFields="bucket_id" SortExpression="bucket_id" HeaderText="Bucket|Id" HeaderToolTip="ID of the Bucket" />
            <eclipse:MultiBoundField DataFields="bucket_name" SortExpression="bucket_name" HeaderText="Bucket|Name" HeaderToolTip="Name of the Bucket"
                ItemStyle-Wrap="true" />
            <eclipse:MultiBoundField DataFields="vwh_id" SortExpression="vwh_id" HeaderText="VWh"  HeaderToolTip="Virtual Warehouse of the Bucket"/>
            <eclipse:SiteHyperLinkField DataTextField="count_of_pickslip" SortExpression="count_of_pickslip"
                HeaderText="Number of|Pickslips" DataSummaryCalculation="ValueSummation" HeaderToolTip="Number of under process pickslips of the bucket"
                DataNavigateUrlFormatString="R140_101.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataTextFormatString="{0:#,###}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_box" SortExpression="count_of_box" HeaderToolTip="Total number of boxes which belongs to under process pickslips."
                HeaderText="Number of|Total Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataNavigateUrlFormatString="R110_03.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation"
                HeaderStyle-Wrap="true">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_red_box" SortExpression="count_of_red_box" HeaderToolTip="Total number of boxes in RED area which belongs to under process pickslips."
                HeaderText="Number of|Red Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R140_103.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_unavailable_box" SortExpression="count_of_unavailable_box" HeaderToolTip="Total number of boxes waiting to expedite which belongs to the under process pickslips."
                HeaderText="Number of|Non-Physical Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataNavigateUrlFormatString="R140_105.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="count_of_pullable_box" SortExpression="count_of_pullable_box" HeaderToolTip="Number of boxes which can be directly pulled from carton area."
                HeaderText="Number of|Pullable Boxes" DataFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="about_to_pull_cartons" SortExpression="about_to_pull_cartons" HeaderToolTip="Number of boxes which are waiting to pull from carton area of the building"
                HeaderText="Number of|About to Pull Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:#,###}"
                DataNavigateUrlFormatString="R110_105.aspx?bucket_id={0}&building={1}&BoxesInBucket=Y"
                DataNavigateUrlFields="bucket_id,warehouse_location_id," DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="UnprocessedPieces" HeaderText="Number of|Unprocessed Pieces" SortExpression="UnprocessedPieces"
                DataSummaryCalculation="ValueSummation" HeaderToolTip="Total no. of pieces which are not picked yet."
                DataNavigateUrlFormatString="R140_102.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}" DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id"
                DataFooterFormatString="{0:N0}" DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="min_start_date" SortExpression="min_start_date"
                HeaderText="Start Date" DataFormatString="{0:d}"  HeaderToolTip="Earliest date on which the customer is willing to accept the shipment. "/>
            <eclipse:MultiBoundField DataFields="min_dc_cancel_date" SortExpression="min_dc_cancel_date"
                HeaderText="DC Cancel Date" DataFormatString="{0:d}"  HeaderToolTip="Orders must be shipped from the DC till this date." />
            <jquery:IconField DataField="available_for_pitching" HeaderText="Status|Available" HeaderToolTip="If Check sign is visible, it means that boxes have been created for the bucket."
                DataFieldValues="Y" IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center"
                SortExpression="available_for_pitching"/>
            <jquery:IconField DataField="unfreeze" HeaderText="Status|UnFrozen" DataFieldValues="Y" HeaderToolTip="Indicates that bucket is not in freeze state"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="unfreeze" />
            <jquery:IconField DataField="pick_mode" HeaderText="Status|Checking" DataFieldValues="CHECKING" HeaderToolTip="If Check sign is visible, it means this bucket will be processed thru checking path."
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="pick_mode" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Title="Open Bucket Summary Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4286 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R140_02.aspx $
 *  $Id: R140_02.aspx 4286 2012-08-18 09:18:18Z skumar $
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
    <meta name="Version" content="$Id: R140_02.aspx 4286 2012-08-18 09:18:18Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucketId" runat="server" QueryString="bucket_id" ToolTip="Use this parameter to retreive data for specific bucket">
                    <Validators>
                        <i:Value ValueType="Integer" MaxLength="5" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Label" />
                <d:StyleLabelSelector ID="ctlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label" QueryString="label_id">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Customer" />
                <i:TextBoxEx ID="tbCustomerId" runat="server" QueryString="customer_id" ToolTip="Use this parameter to retreive data for specific customer" />
                <br />
                The customer for which you want to see the Buckets.
                <eclipse:LeftLabel ID="lblNoDays" runat="server" Text="Exclude Buckets Older Than" />
                <i:TextBoxEx ID="tbNoDays" runat="server" QueryString="no_of_days" ToolTip="Use this parameter to exclude buckets older than specified number of days">
                    <Validators>
                        <i:Value ValueType="Integer" Min="1" Max="2000" ClientMessage="Value must lies between 1 and 2000 both inclusive." />
                    </Validators>
                </i:TextBoxEx>
                (1 to 2000)Days
                <eclipse:LeftLabel runat="server" Text="Pick Mode" />
                <i:RadioButtonListEx runat="server" ID="rblPickMode" ToolTip="Use this filter to retreive data for Pitching, Checking or for both pick mode"
                    QueryString="pick_mode" Orientation="Vertical">
                    <Items>
                        <i:RadioItem Text="Both" Value="" />
                        <i:RadioItem Text="Pitching" Value="PITCHING" />
                        <i:RadioItem Text="Checking" Value="CHECKING" />
                    </Items>
                </i:RadioButtonListEx>
                <eclipse:LeftLabel runat="server" Text="Bucket Status" />
                <i:RadioButtonListEx runat="server" ID="rblBucketStatus" ToolTip="Use this filter to retreive data for Frozen, UnFrozen or for both bucket status"
                    QueryString="bucket_status">
                    <Items>
                        <i:RadioItem Text="Both" Value="" />
                        <i:RadioItem Text="Frozen" Value="F" />
                        <i:RadioItem Text="Unfrozen" Value="U" />
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
                        QueryString="dc_cancel_date" FilterDisabled="true" />
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
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Building" />
                <d:BuildingSelector FriendlyName="Building" runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
                </d:BuildingSelector>
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
  with TOTAL_ORDERED_PIECES as
 (
 select 
  MAX(P.warehouse_location_id) as warehouse_location_id,
  MAX(P.VWH_ID) AS VWH_ID, 
  sum(psd.pieces_ordered) as ordered_pieces,
  COUNT(DISTINCT p.pickslip_id) AS count_of_pickslip,
  MIN(po.dc_cancel_date) AS min_dc_cancel_date,
  MIN(po.start_date) AS min_start_date,
 p.bucket_id as bucket_id,
  min(bkt.name) as bucket_name,
  MIN(bkt.available_for_pitching) AS available_for_pitching,
  MIN(decode(bkt.freeze, '', 'Y', '')) AS unfreeze,
  MIN(bkt.pick_mode) AS pick_mode,
  MIN(bkt.pull_to_dock) AS pull_to_dock
 from ps p
 inner join bucket bkt on
 p.bucket_id=bkt.bucket_id
 inner join psdet psd on
 p.pickslip_id=psd.pickslip_id
 LEFT OUTER JOIN po po
 ON p.customer_id = po.customer_id
 AND p.po_id = po.po_id
 AND p.iteration = po.iteration
 where p.transfer_date is null
 and p.reporting_status='UNDER PROCESS'
 <if>AND p.bucket_id=cast(:bucket_id as number(5))</if>
 <if>and p.warehouse_location_id = cast(:warehouse_location_id as varchar2(255))</if>
 <if>AND p.label_id=cast(:label_id as varchar2(255))</if>  
 <if>AND p.customer_id=CAST(:customer_id as varchar2(255))</if>
 <if>AND po.start_date &gt;= CAST(:delivery_start_date AS DATE)</if>      
 <if>AND po.start_date &lt;= CAST(:delivery_end_date AS DATE)</if>       
 <if>AND po.dc_cancel_date &gt;=CAST(:dc_cancel_start_date AS DATE)</if>
 <if>AND po.dc_cancel_date &lt;=CAST(:dc_cancel_end_date AS DATE)</if> 
 <if>AND bkt.pick_mode = CAST(:pick_mode as varchar2(255))</if>
 <if c="$bucket_status='F'">AND bkt.freeze IS NOT NULL</if>
 <if c="$bucket_status='U'">AND bkt.freeze IS NULL</if>
 <if>AND bkt.date_created &gt;= SYSDATE - cast(:days as number(5))</if>
 <if>and p.vwh_id=:vwh_id</if>
 group by p.bucket_id
 ),
 TOTAL_PICKED_PIECES as
 (
  SELECT 
          b.bucket_id AS bucket_id,
          MIN(b.name) AS bucket_name,
          COUNT(DISTINCT box.ucc128_id) AS count_of_box,
          COUNT(DISTINCT(CASE
                           WHEN box.ia_id = CAST('RED' AS VARCHAR2(255)) THEN
                            box.ucc128_id
                         END)) AS count_of_red_box,
          COUNT(DISTINCT(CASE
                           WHEN box.ia_id_copy = 'NOA' THEN
                            box.ucc128_id
                         END)) AS count_of_unavailable_box,
          COUNT(DISTINCT box.carton_id) AS count_of_pullable_box,
          COUNT(DISTINCT(CASE
                           WHEN box.ia_id_copy = 'NOA' THEN
                            box.carton_id
                         END)) AS about_to_pull_cartons,
          SUM(DECODE(box.ia_id_copy, 'NOA', bd.expected_pieces)) AS number_of_unprocessed_pieces,
           sum(case
         when box.verify_date is not null then
          bd.expected_pieces
         else
          bd.current_pieces
       end) as picked_pieces
    FROM bucket b
   INNER JOIN ps ps
      ON ps.bucket_id = b.bucket_id
     left outer join box box
     ON ps.pickslip_id = box.pickslip_id
     left outer join boxdet bd
     on box.pickslip_id = bd.pickslip_id
     and box.ucc128_id = bd.ucc128_id
     where 1=1
     and ps.reporting_status='UNDER PROCESS'
     <if>AND b.date_created &gt;= SYSDATE - cast(:days as number(5))</if>
     <if>AND ps.bucket_id=cast(:bucket_id as number(5))</if>
     <if>and ps.warehouse_location_id = cast(:warehouse_location_id as varchar2(255))</if>
     <if>AND b.pick_mode = CAST(:pick_mode as varchar2(255))</if>
     <if c="$bucket_status='F'">AND b.freeze IS NOT NULL</if>
     <if c="$bucket_status='U'">AND b.freeze IS NULL</if>
     <if>AND ps.label_id=cast(:label_id as varchar2(255))</if>  
     <if>AND ps.customer_id=CAST(:customer_id as varchar2(255))</if>
     <if>and ps.vwh_id=:vwh_id</if>
     and box.stop_process_date IS NULL
     AND bd.stop_process_date IS NULL
     and ps.transfer_date is null
   GROUP BY b.bucket_id
 )
 SELECT OP.warehouse_location_id,
       OP.VWH_ID,
       OP.BUCKET_ID,
       OP.BUCKET_NAME,
       OP.COUNT_OF_PICKSLIP,
       PP.count_of_box,
       PP.COUNT_OF_RED_BOX,
       PP.COUNT_OF_UNAVAILABLE_BOX,
       PP.COUNT_OF_PULLABLE_BOX,
       PP.about_to_pull_cartons,      
       OP.min_dc_cancel_date,
       OP.min_start_date,
       OP.pull_to_dock,
       op.available_for_pitching,
       op.unfreeze,
       op.pick_mode,
       OP.ordered_pieces,
       PP.picked_pieces,
       OP.ordered_pieces-NVL(PP.picked_pieces,0) as UnprocessedPieces,
       PP.number_of_unprocessed_pieces
  FROM TOTAL_ORDERED_PIECES OP
  left outer join TOTAL_PICKED_PIECES PP on
  OP.bucket_id=PP.bucket_id
        
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
                HeaderText="Building" />
            <eclipse:MultiBoundField DataFields="bucket_id" SortExpression="bucket_id" HeaderText="Bucket|Id" />
            <eclipse:MultiBoundField DataFields="bucket_name" SortExpression="bucket_name" HeaderText="Bucket|Name"
                ItemStyle-Wrap="true" />
            <eclipse:MultiBoundField DataFields="vwh_id" SortExpression="vwh_id" HeaderText="VWh" />
            <eclipse:SiteHyperLinkField DataTextField="count_of_pickslip" SortExpression="count_of_pickslip"
                HeaderText="Number of|Pickslips" DataSummaryCalculation="ValueSummation" AppliedFiltersControlID="ctlButtonBar$af"
                DataNavigateUrlFormatString="R140_101.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataTextFormatString="{0:#,###}"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_box" SortExpression="count_of_box"
                HeaderText="Number of|Total Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:N0}"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R110_03.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation"
                HeaderStyle-Wrap="true">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_red_box" SortExpression="count_of_red_box"
                HeaderText="Number of|Red Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:N0}"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R140_103.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_unavailable_box" SortExpression="count_of_unavailable_box"
                HeaderText="Number of|Non-Physical Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:N0}"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R140_105.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:SiteHyperLinkField DataTextField="count_of_pullable_box" SortExpression="count_of_pullable_box"
                HeaderText="Number of|Pullable Boxes" DataTextFormatString="{0:#,###}" DataFooterFormatString="{0:N0}"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R110_105.aspx?bucket_id={0}&vwh_id={1}&warehouse_location_id={2}&BoxesInBucket=N"
                DataNavigateUrlFields="bucket_id,vwh_id,warehouse_location_id" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="about_to_pull_cartons" SortExpression="about_to_pull_cartons"
                HeaderText="Number of|About to Pull Boxes" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <%-- <eclipse:SiteHyperLinkField DataTextField="number_of_unprocessed_pieces" SortExpression="number_of_unprocessed_pieces"
                HeaderText="Number of|Unprocessed Pieces" DataTextFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                AppliedFiltersControlID="ctlButtonBar$af" DataNavigateUrlFormatString="R140_102.aspx?bucket_id={0}&vwh_id={1}"
                DataNavigateUrlFields="bucket_id,vwh_id" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>--%>
            <eclipse:SiteHyperLinkField DataTextField="UnprocessedPieces" HeaderText="Number of|Unprocessed Pieces"
                DataSummaryCalculation="ValueSummation" AppliedFiltersControlID="ctlButtonBar$af"
                DataNavigateUrlFormatString="R140_102.aspx?bucket_id={0}&vwh_id={1}" DataNavigateUrlFields="bucket_id,vwh_id"
                 DataFooterFormatString="{0:N0}" DataTextFormatString="{0:#,###}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="min_start_date" SortExpression="min_start_date"
                HeaderText="Start Date" DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="min_dc_cancel_date" SortExpression="min_dc_cancel_date"
                HeaderText="DC Cancel Date" DataFormatString="{0:d}" />
            <jquery:IconField DataField="available_for_pitching" HeaderText="Status|Available"
                DataFieldValues="Y" IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center"
                SortExpression="available_for_pitching" />
            <jquery:IconField DataField="unfreeze" HeaderText="Status|UnFrozen" DataFieldValues="Y"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="unfreeze" />
            <jquery:IconField DataField="pick_mode" HeaderText="Status|Checking" DataFieldValues="CHECKING"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="pick_mode" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

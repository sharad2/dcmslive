<%@ Page Title="Unscanned Boxes At UPS Station" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6812 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R110_107.aspx 6812 2014-05-16 05:25:33Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">

    private HashSet<Int64> _pickslipSet = new HashSet<Int64>();
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            var pickslipId = Convert.ToInt64(DataBinder.Eval(e.Row.DataItem, "PICKSLIP_ID"));
            _pickslipSet.Add(pickslipId);
            if (_pickslipSet.Count % 2 == 0)
            {
                e.Row.BackColor = System.Drawing.Color.LightGray;
            }
            
        }

    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is showing only those boxes which are not scanned at UPS station." />
    <meta name="ReportId" content="110.107" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R110_107.aspx 6812 2014-05-16 05:25:33Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel5" Text="Customer" runat="server" />
                <i:TextBoxEx ID="tbCustomer" runat="server" QueryString="customer_id" FriendlyName="Customer" ToolTip="Filter out the results for passed Customer Id.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel Text="PO" runat="server" />
                <i:TextBoxEx ID="tbPO" runat="server" QueryString="po_id" FriendlyName="PO" ToolTip="Filter out the results for passed Purchase Order"></i:TextBoxEx>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
WITH LOADED_BOXES AS
 (SELECT UCC128_ID, MAX(PRO_NUMBER) AS PRO_NUMBER, MAX(WORKSTATION_NAME) AS WORKSTATION_NAME, MAX(Insert_Date) AS Insert_Date
    FROM LOAD_SMSUPS
   GROUP BY UCC128_ID),
Q1 AS
 (SELECT B.UCC128_ID,
         B.VERIFY_DATE,
         P.CUSTOMER_ID,
         C.NAME,
         B.PALLET_ID,
         B.IA_ID,
         PO.START_DATE,
         PO.DC_CANCEL_DATE,
         LB.WORKSTATION_NAME,
         LB.Insert_Date,
         NVL(B.PRO_NUMBER, LB.PRO_NUMBER) AS TRACKING_NUMBER,
         COUNT(*) OVER(PARTITION BY B.PICKSLIP_ID) AS COUNT_BOXES_IN_PS,
         COUNT(B.VERIFY_DATE) OVER(PARTITION BY B.PICKSLIP_ID) AS COUNT_VERIFIED_BOXES_IN_PS,
         COUNT(NVL(B.PRO_NUMBER, LB.PRO_NUMBER)) OVER(PARTITION BY B.PICKSLIP_ID) AS COUNT_SCANNED_BOXES_IN_PS,
         P.PICKSLIP_ID
    FROM BOX B
   INNER JOIN PS P
      ON P.PICKSLIP_ID = B.PICKSLIP_ID
   INNER JOIN PO
      ON P.CUSTOMER_ID = PO.CUSTOMER_ID
     AND P.PO_ID = PO.PO_ID
     AND P.ITERATION = PO.ITERATION
    LEFT OUTER JOIN CUST C
      ON P.CUSTOMER_ID = C.CUSTOMER_ID
   INNER JOIN MASTER_CARRIER MC
      ON MC.CARRIER_ID = P.CARRIER_ID
     AND MC.SMALL_SHIPMENT_FLAG = 'Y'
    LEFT OUTER JOIN LOADED_BOXES LB
      ON LB.UCC128_ID = B.UCC128_ID
   WHERE B.STOP_PROCESS_DATE IS NULL
    <if>AND P.customer_id =:customer_id</if>    
    <if>and po.po_id =:po_id</if>    
            )
SELECT Q1.UCC128_ID,
       Q1.CUSTOMER_ID,
       Q1.NAME AS CUSTOMER_NAME,
       Q1.VERIFY_DATE,
       Q1.TRACKING_NUMBER,
       Q1.PALLET_ID,
       Q1.IA_ID,
       Q1.START_DATE,
       Q1.DC_CANCEL_DATE,
       Q1.PICKSLIP_ID,
       Q1.WORKSTATION_NAME,
       Q1.Insert_Date,
       Q1.COUNT_BOXES_IN_PS,
       Q1.COUNT_VERIFIED_BOXES_IN_PS,
       Q1.COUNT_SCANNED_BOXES_IN_PS
  FROM Q1
 WHERE COUNT_VERIFIED_BOXES_IN_PS &gt; 0
   AND (COUNT_SCANNED_BOXES_IN_PS != COUNT_BOXES_IN_PS)
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbPO" Name="po_id" Type="String" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true" OnRowDataBound="gv_RowDataBound"
        ShowFooter="false" DataSourceID="ds" DefaultSortExpression="CUSTOMER_ID;IA_ID;$;PICKSLIP_ID;verify_date">
        <AlternatingRowStyle CssClass="" />
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField HeaderText="Customer" DataFields="CUSTOMER_ID,CUSTOMER_NAME" SortExpression="CUSTOMER_ID" DataFormatString="{0} : {1}" />
            <eclipse:MultiBoundField HeaderText="Area" DataFields="IA_ID" SortExpression="IA_ID" />
            <eclipse:MultiBoundField HeaderText="Pallet" DataFields="PALLET_ID" SortExpression="PALLET_ID" HeaderToolTip="Pallet of the boxes" />
            <eclipse:MultiBoundField HeaderText="Pickslip" DataFields="PICKSLIP_ID" SortExpression="PICKSLIP_ID" AccessibleHeaderText="Pickslip" HeaderToolTip="Pickslips nos. of the customer order." />
            <eclipse:MultiBoundField HeaderText="Box" DataFields="UCC128_ID" SortExpression="UCC128_ID" HeaderToolTip="Carton number." />
            <eclipse:MultiBoundField HeaderText="Tracking #" DataFields="TRACKING_NUMBER" SortExpression="TRACKING_NUMBER" HeaderToolTip="The no. used to track the status of the order." />
            <eclipse:MultiBoundField HeaderText="Boxes In Pickslip|Total" DataFields="COUNT_BOXES_IN_PS" SortExpression="COUNT_BOXES_IN_PS" HeaderToolTip="Tota no. of boxes in the pickslip"
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField HeaderText="Boxes In Pickslip|Scanned At UPS" DataFields="COUNT_SCANNED_BOXES_IN_PS" SortExpression="COUNT_SCANNED_BOXES_IN_PS" HeaderToolTip="No. of verified boxes already scanned at UPS station."
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField HeaderText="Boxes In Pickslip|Verified" DataFields="COUNT_VERIFIED_BOXES_IN_PS" SortExpression="COUNT_VERIFIED_BOXES_IN_PS" HeaderToolTip="No. of verified boxes not scanned at the UPS station."
                DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField HeaderText="Delivery Date" DataFields="START_DATE" SortExpression="START_DATE" DataFormatString="{0:d}" HeaderToolTip="The date before which the order must not be shipped."/>
            <eclipse:MultiBoundField HeaderText="DC Cancel Date" DataFields="DC_CANCEL_DATE" SortExpression="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderToolTip="The date by which the order must be dispatched from the warehouse." />
            <eclipse:MultiBoundField HeaderText="Verify Date" DataFields="verify_date" SortExpression="verify_date"  HeaderToolTip="The date on which the box was verified."/>
            <eclipse:MultiBoundField HeaderText="Box scan date at UPS" DataFields="Insert_Date" SortExpression="Insert_Date" HeaderToolTip="The date on which the box was scanned at the UPS station." />
            <eclipse:MultiBoundField HeaderText="UPS Work Station" DataFields="WORKSTATION_NAME" SortExpression="WORKSTATION_NAME" HeaderToolTip="Name of the workstation the box was scanned at the UPS station." />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

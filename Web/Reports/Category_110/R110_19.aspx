<%@ Page Title="Routed Orders Information" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 1027 $
 *  $Author: rverma $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_19.aspx $
 *  $Id: R110_19.aspx 1027 2011-06-15 05:13:11Z rverma $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report displays the orders along with number of boxes which are marked for routing and pickup date is assigned for passed carrier and pickup date." />
    <meta name="ReportId" content="110.19" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R110_19.aspx 1027 2011-06-15 05:13:11Z rverma $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpCarrier" runat="server">
                <eclipse:LeftLabel ID="lblCarrier" runat="server" Text="Carrier" />
                <oracle:OracleDataSource ID="dsCarrier" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" >
                    <SelectSql>
                    SELECT M.Carrier_ID, M.DESCRIPTION ||' - '|| M.Carrier_ID  as DESCRIPTION FROM v_Carrier M WHERE M.INACTIVE_FLAG IS NULL ORDER BY M.DESCRIPTION
                    </SelectSql> 
                    </oracle:OracleDataSource> 
                <i:DropDownListEx2 ID="ddCarrier" runat="server" DataSourceID="dsCarrier" DataFields="Carrier_ID,DESCRIPTION"
                     ToolTip="Select Carrier for which you want to see the information." DataTextFormatString="{1}" 
                    FriendlyName="Carrier Description">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
            <eclipse:TwoColumnPanel ID="tcpPickupDate" runat="server">
                <eclipse:LeftLabel ID="lblPickupDate" runat="server" Text="Pickup Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="Pickup Date From"
                     Text="0" ToolTip="Must enter the pickup date by which you see the order information from this date.">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="Pickup Date To" Text="7"
                    ToolTip="Enter the date by which you see the order information upto this date. Please Enter only 1 year as date range.">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <%-- The other panel will provide you the sort control --%>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--Use button bar to put all the buttons, it will also provide you the validation summary and Applied Filter control--%>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <%--Provide the data source for quering the data for the report, the datasource should always be placed above the display 
            control since query execution time is displayed where the data source control actaully is on the page,
            while writing the select query the alias name must match with that of database column names so as to avoid 
            any confusion, for details of control refer OracleDataSource.htm with in doc folder of EclipseLibrary.Oracle--%>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" 
        CancelSelectOnNullParameter="true">
 <SelectSql>
 SELECT PS.CUSTOMER_ID AS CUSTOMER_ID,
       MAX(CUST.NAME) AS CUSTOMER_NAME,
       PS.PO_ID AS PO,
       PS.CUSTOMER_DC_ID AS DC,
       COUNT(BOX.UCC128_ID) AS NUMBER_OF_BOXES,
       PS.PICKUP_DATE AS PICKUP_DATE,
       PS.VWH_ID AS VWH_ID,
       PS.WAREHOUSE_LOCATION AS WAREHOUSE_LOCATION
FROM PS PS,BOX BOX, CUST CUST
WHERE PS.PICKSLIP_ID = BOX.PICKSLIP_ID(+)
	 AND CUST.CUSTOMER_ID = PS.CUSTOMER_ID
	 AND BOX.SUSPENSE_DATE IS NULL
	 AND BOX.STOP_PROCESS_DATE IS NULL
	 AND BOX.STOP_PROCESS_REASON IS NULL
	 AND PS.CARRIER_ID = :CARRIER_ID
	 AND PS.PICKUP_DATE &gt;= to_date(:FromDate,'mm/dd/yyyy')
	 AND PS.PICKUP_DATE &lt;  to_date(:ToDate,'mm/dd/yyyy') + 1 
     AND ps.cancel_reason_code IS NULL
GROUP BY PS.CUSTOMER_ID,
          PS.PO_ID,
	      PS.CUSTOMER_DC_ID,
	      PS.PICKUP_DATE,
	      PS.WAREHOUSE_LOCATION,
	      PS.VWH_ID
 </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="ddCarrier" Type="String" Direction="Input" Name="CARRIER_ID" />
            <asp:ControlParameter ControlID="dtFrom" Type="String" Direction="Input" Name="FromDate" />
            <asp:ControlParameter ControlID="dtTo" Type="String" Direction="Input" Name="ToDate" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <%--Provide the control where result to be displayed over here--%>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="PICKUP_DATE;CUSTOMER_ID;">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="CUSTOMER_ID" HeaderText="Customer ID" SortExpression="CUSTOMER_ID"
                HeaderToolTip="Customer ID" />
            <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Customer Name" SortExpression="CUSTOMER_NAME"
                HeaderToolTip="Name of the Customer" />
            <eclipse:MultiBoundField DataFields="PO" HeaderText="PO" SortExpression="PO" HeaderToolTip="Purchase Order Number" />
            <eclipse:MultiBoundField DataFields="DC" HeaderText="DC" SortExpression="DC" HeaderToolTip=" Customer Distribution Center ID" />
            <eclipse:MultiBoundField DataFields="NUMBER_OF_BOXES" HeaderText="# of Boxes" SortExpression="NUMBER_OF_BOXES"
                DataFormatString="{0:N0}" HeaderToolTip="Number of Boxes" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterToolTip="Total Number of Boxes">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PICKUP_DATE" HeaderText="Pickup Date" SortExpression="PICKUP_DATE"
                HeaderToolTip="Order Pickup Date" DataFormatString="{0:d}" />
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION" HeaderText="Warehouse Location"
                SortExpression="WAREHOUSE_LOCATION" HeaderToolTip="Warehouse Location" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="Vwh" SortExpression="VWH_ID"
                HeaderToolTip="Virtual Warehouse" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

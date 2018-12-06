<%@ Page Title="Details Of Manual BOLs Exported" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6082 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Doc/Template.aspx $
 *  $Id: R10_84.aspx 6082 2013-09-05 08:31:50Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    [WebMethod]
    public static AutoCompleteItem[] GetCustomers(string term)
    {

        AutoCompleteItem[] items;

        using (OracleDataSource ds = new OracleDataSource())
        {
            ds.ConnectionString = ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString;
            ds.ProviderName = ConfigurationManager.ConnectionStrings["dcmslive"].ProviderName;
            ds.SysContext.ModuleName = "Customer Selector";

            ds.SelectSql = @"
                select cust.customer_id as customer_id, 
                       cust.name as customer_name
                from cust cust
                where 1 = 1
                <if c='$keywords'>AND (cust.customer_id like '%' || CAST(:keywords as VARCHAR2(25)) || '%' or UPPER(cust.name) like '%' || upper(CAST(:keywords as VARCHAR2(25))) || '%')</if>
                ";

            string[] tokens = term.Split(',');
            ds.SelectParameters.Add("keywords", TypeCode.String, tokens[tokens.Length - 1].Trim());

            items = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                     select new AutoCompleteItem()
                     {
                         Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_id"), DataBinder.Eval(cst, "customer_name")),
                         Value = DataBinder.Eval(cst, "customer_id", "{0}")
                     }).Take(20).ToArray();
        }
        return items;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report displays list of BOLs which were exported to Vision on a specified date. Along with the BOL id report also displays number of boxes which were shipped and total weight of the shipment." />
    <meta name="ReportId" content="10.84" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R10_84.aspx 6082 2013-09-05 08:31:50Z skumar $" />
    <meta name="ChangeLog" content="Fixed bug due to which shipped BOLs were not getting reflected in this report." />
    <script type="text/javascript">
        function tbcustomer_OnClientSelect(event, ui) {
            //   this.value = this.value.split(/,\s*/).pop();           
            var terms = this.value.split(/,\s*/);
            // remove the current input
            terms.pop();
            // add the selected item
            terms.push(ui.item.Value);
            // add placeholder to get the comma-and-space at the end
            terms.push("");
            this.value = terms.join(", ");
            return false;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel Text="Customer" runat="server" />
                <i:AutoComplete runat="server" ID="tbcustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Customer" QueryString="customer_id" ToolTip="The customers whose BOL you are interested in."
                    Delay="1000" Width="137" OnClientSelect="tbcustomer_OnClientSelect">
                </i:AutoComplete>
                <br />
                You can pass multiple Customer IDs separated by a comma (, ).
                <eclipse:LeftLabel runat="server" Text="Upload Date" />
                From
                <d:BusinessDateTextBox ID="tbFromUploaddate" runat="server" FriendlyName="From Upload date"
                    Text="-7" ToolTip="Please specify a date or date range here."
                    QueryString="Upload_start_date">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                To
                <d:BusinessDateTextBox ID="tbToUploaddate" runat="server" FriendlyName="To Upload date"
                    Text="0" ToolTip="Please specify a date or date range here. " QueryString="Upload_end_date">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
SELECT /*+ index(shp SHIP_UPLOAD_DATE_I) index(chk CHK_SHIP_FK_I) index(ps PS_UK) */
DISTINCT NVL(DP.ASN_FLAG, 'N') AS ASN,
         SHP.SHIPPING_ID AS SHIPPING_ID,
         SHP.PARENT_SHIPPING_ID AS PARENT_SHIPPING_ID,
         SHP.MBOL_ID AS MBOL_ID,
         DP.CUSTOMER_ID AS CUSTOMER_ID,
         C.NAME AS NAME,
         DP.PICKSLIP_PREFIX AS PICKSLIP_PREFIX,
         SHP.NUMBER_OF_BOXES AS NO_OF_BOXES,
         SHP.WEIGHT AS WEIGHT
  FROM DEM_SHIPPING SHP
 INNER JOIN DEM_CHECKING CHK
    ON SHP.SHIPPING_ID = CHK.SHIPPING_ID
 INNER JOIN DEM_PICKSLIP DP
    ON CHK.CHECKING_ID = DP.CHECKING_ID
 INNER JOIN MASTER_CUSTOMER C
    ON DP.CUSTOMER_ID = C.CUSTOMER_ID
 WHERE DP.PS_STATUS_ID = 8
   <if>AND SHP.UPLOAD_DATE &gt;= CAST(:upload_start_date AS DATE)</if>
   <if>AND SHP.UPLOAD_DATE &lt; CAST(:upload_end_date AS DATE) + 1</if>
   <if>AND <a pre="DP.customer_id IN (" sep="," post=")">:customer_id</a></if>
   AND SHP.SHIPMENT_TYPE = 2
UNION ALL
SELECT NVL(MAX(C.ASN_FLAG), 'N') AS ASN,
       S.SHIPPING_ID,
       MAX(S.PARENT_SHIPPING_ID) AS PARENT_SHIPPING_ID,
       MAX(S.MBOL_ID) AS MBOL_ID,
       MAX(PS.CUSTOMER_ID) AS CUSTOMER_ID,
       MAX(C.NAME) AS NAME,
       MAX(PS.PICKSLIP_PREFIX) AS PICKSLIP_PREFIX,
       COUNT(B.UCC128_ID) AS NO_OF_BOXES,
       MAX(S.WEIGHT) AS WEIGHT
  FROM PS
 INNER JOIN CUST C
    ON PS.CUSTOMER_ID = C.CUSTOMER_ID
 INNER JOIN SHIP S
    ON PS.SHIPPING_ID = S.SHIPPING_ID
 INNER JOIN BOX B
    ON PS.PICKSLIP_ID = B.PICKSLIP_ID
 WHERE PS.ISI_WM_CHRO_SEQU_ID IS NOT NULL
   AND PS.PICKSLIP_CANCEL_DATE IS NULL
   AND PS.TRANSFER_DATE IS NOT NULL
   AND S.SHIPPING_TYPE = 'BOL'
   AND B.IA_ID &lt;&gt; 'CAN'
   <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
   AND B.STOP_PROCESS_DATE IS NOT NULL
   <if>AND PS.TRANSFER_DATE &gt;= CAST(:upload_start_date AS DATE)</if>
   <if>AND PS.TRANSFER_DATE &lt; CAST(:upload_end_date AS DATE) + 1</if>
 GROUP BY S.SHIPPING_ID


        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbFromUploadDate" Type="DateTime" Direction="Input"
                Name="upload_start_date" />
            <asp:ControlParameter ControlID="tbToUploadDate" Type="DateTime" Direction="Input"
                Name="upload_end_date" />
            <asp:ControlParameter ControlID="tbcustomer" Type="String" Direction="Input"
                Name="customer_id" PropertyName="Text"/>
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds" DefaultSortExpression="NAME;$;ASN;SHIPPING_ID">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="ASN" HeaderText="ASN" SortExpression="ASN" />
            <eclipse:MultiBoundField DataFields="SHIPPING_ID" HeaderText="Shipping ID" SortExpression="SHIPPING_ID" />
            <eclipse:MultiBoundField DataFields="PARENT_SHIPPING_ID" HeaderText="Parent Shipping ID" SortExpression="PARENT_SHIPPING_ID" />
            <eclipse:MultiBoundField DataFields="MBOL_ID" HeaderText="MBOL" SortExpression="MBOL_ID" />
            <eclipse:MultiBoundField DataFields="CUSTOMER_ID,NAME" HeaderText="Customer" SortExpression="NAME" DataFormatString="{0}:{1}" />
            <eclipse:MultiBoundField DataFields="PICKSLIP_PREFIX" HeaderText="Prefix" SortExpression="PICKSLIP_PREFIX"/>
            <eclipse:MultiBoundField DataFields="NO_OF_BOXES" HeaderText="No. Of Boxes" SortExpression="NO_OF_BOXES" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" />
            <eclipse:MultiBoundField DataFields="WEIGHT" HeaderText="Weight(In Pound)" SortExpression="WEIGHT" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" />

        </Columns>
    </jquery:GridViewEx>
</asp:Content>

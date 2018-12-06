<%@ Page Title="Transmitted DC and State info for EDI754 customers" Language="C#"
    MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5659 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_170/R170_04.aspx $
 *  $Id: R170_04.aspx 5659 2013-07-17 04:13:22Z skumar $
 * Version Control Template Added.
 *
--%><asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report shows the old and new transmitted DC, PO, Customer Store, Load Id and ATS Date by Carrier for EDI customers when carrier has changed." />
    <meta name="ReportId" content="170.04" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R170_04.aspx 5659 2013-07-17 04:13:22Z skumar $" />
    <meta name="ChangeLog" content="Showing box count which will help users to ensure if all labels are reprinted.| Data is now displayed by carrier and customer." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Customer" />
                <i:TextBoxEx runat="server" ID="tbCustomer" SkinID="CustomerId" FriendlyName="Customer"
                    ToolTip="Pass Customer Id" />
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="ATS Date" />
                From
                <d:BusinessDateTextBox ID="tbFrom" runat="server" FriendlyName="From Date" QueryString="from_date" ToolTip="Plase pass the date or date range." />
                To
                <d:BusinessDateTextBox ID="tbTo" runat="server" FriendlyName="To Date" QueryString="to_date" ToolTip="Plase pass the date or date range.">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Pickslip import date from today" />
                <%--Min value and max value introduced. Approval pending.--%>
                <i:TextBoxEx ID="tbImportDate" runat="server" Text="90" FriendlyName="Import Date from today"
                    ToolTip="Pass no of days.">
                    <Validators>
                        <i:Value ValueType="Integer" Min="0" Max="1800" />
                    </Validators>
                </i:TextBoxEx>
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
        CancelSelectOnNullParameter="true" >
                  <SelectSql>
                <%--  SELECT edips.original_customer_dc_id AS ORIGINAL_DC_ID,
               edips.customer_dc_id AS DC_ID,
               ps.po_id AS PO_ID,
               ps.customer_store_id AS STORE_ID,
               MAX(edips.carrier_id) AS CARRIER_ID,  
               MAX(decode(carr.description,
                          '',
                          edips.carrier_id,
                          carr.description)) AS DESCRIPTION,            
               MAX(edips.load_id) AS LOAD_ID,
               MAX(edips.ats_date) AS ATS_DATE
          FROM edi_753_754_ps edips,
               v_carrier      carr,
               ps             ps
         WHERE edips.pickslip_id = ps.pickslip_id
           AND edips.carrier_id = carr.carrier_id
           AND ((nvl(edips.carrier_id,
                     0) != nvl(edips.original_carrier_id,
                                 0)))
           AND ps.pickslip_cancel_date IS NULL
           AND ps.cancel_reason_code IS NULL
           <if>AND edips.ats_date &gt;= (CAST(:ATS_FROM_DATE AS DATE)) and edips.ats_date &lt; (CAST(:ATS_TO_DATE AS DATE) + 1)</if>
           <if>AND ps.customer_id = CAST(:CUSTOMER_ID AS VARCHAR2(255))</if>
           <if>AND (ps.pickslip_import_date &gt;= SYSDATE - CAST(:Import_Date_From_Today AS NUMBER) AND
                   ps.pickslip_import_date &lt; (SYSDATE + 1))</if>
         GROUP BY edips.original_customer_dc_id,
                  edips.customer_dc_id,
                  ps.po_id,
                  ps.customer_store_id--%>

SELECT EDIPS.ORIGINAL_CUSTOMER_DC_ID AS ORIGINAL_DC_ID,
       EDIPS.CUSTOMER_DC_ID AS DC_ID,
       PS.CUSTOMER_ID AS CUSTOMER_ID,
       PS.PO_ID AS PO_ID,
       COUNT(DISTINCT B.UCC128_ID) AS BOXES,
       PS.CUSTOMER_STORE_ID AS STORE_ID,
       MAX(C.NAME) AS CUSTOMER_NAME,
       MAX(EDIPS.CARRIER_ID) AS CARRIER_ID,
       MAX(CARR.DESCRIPTION) AS DESCRIPTION,
       MAX(EDIPS.LOAD_ID) AS LOAD_ID,
       MAX(EDIPS.ATS_DATE) AS ATS_DATE
  FROM EDI_753_754_PS EDIPS
 INNER JOIN V_CARRIER CARR
    ON EDIPS.CARRIER_ID = CARR.CARRIER_ID
 INNER JOIN PS
    ON EDIPS.PICKSLIP_ID = PS.PICKSLIP_ID
  LEFT OUTER JOIN CUST C
    ON PS.CUSTOMER_ID = C.CUSTOMER_ID
  LEFT OUTER JOIN BOX B
    ON PS.PICKSLIP_ID = B.PICKSLIP_ID
 WHERE (NVL(EDIPS.CARRIER_ID, 0) != NVL(EDIPS.ORIGINAL_CARRIER_ID, 0))
   AND PS.PICKSLIP_CANCEL_DATE IS NULL
   AND PS.CANCEL_REASON_CODE IS NULL
  <if>AND edips.ats_date &gt;= (CAST(:ATS_FROM_DATE AS DATE)) and edips.ats_date &lt; (CAST(:ATS_TO_DATE AS DATE) + 1)</if>
  <if>AND ps.customer_id = CAST(:CUSTOMER_ID AS VARCHAR2(255))</if>
  <if>AND (ps.pickslip_import_date &gt;= SYSDATE - CAST(:Import_Date_From_Today AS NUMBER) AND
            ps.pickslip_import_date &lt; (SYSDATE + 1))</if>
  AND NVL(B.STOP_PROCESS_REASON,0) NOT IN ('$BOXCANCEL')
 GROUP BY PS.CUSTOMER_ID,
          EDIPS.ORIGINAL_CUSTOMER_DC_ID,
          EDIPS.CUSTOMER_DC_ID,
          PS.PO_ID,
          PS.CUSTOMER_STORE_ID

                  </SelectSql> 

        <SelectParameters>
            <asp:ControlParameter ControlID="tbImportDate" Type="Int32" Name="Import_Date_From_Today"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbCustomer" Type="String" Name="CUSTOMER_ID" Direction="Input" />
            <asp:ControlParameter ControlID="tbFrom" Type="DateTime" Name="ATS_FROM_DATE" Direction="Input" />
            <asp:ControlParameter ControlID="tbTo" Type="DateTime" Name="ATS_TO_DATE" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
         DataSourceID="ds" ShowFooter="true" DefaultSortExpression="CARRIER_ID;CUSTOMER_ID;$;">
        <Columns>
            <eclipse:MultiBoundField DataFields="CARRIER_ID,DESCRIPTION" HeaderText="Carrier" HeaderToolTip="New Carrier Id"
                SortExpression="CARRIER_ID" DataFormatString="{0} : {1}" />
            <eclipse:MultiBoundField DataFields="CUSTOMER_ID,CUSTOMER_NAME" HeaderText="Customer" HeaderToolTip="Carrer Name"
                SortExpression="CUSTOMER_ID" DataFormatString="{0} : {1}" />
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="ORIGINAL_DC_ID" HeaderText="DC #|Old" HeaderToolTip="New DC Id"
                SortExpression="ORIGINAL_DC_ID" />
            <eclipse:MultiBoundField DataFields="DC_ID" HeaderText="DC #|New" HeaderToolTip="New DC Id"
                SortExpression="DC_ID" />
            <eclipse:MultiBoundField DataFields="BOXES" HeaderText="#Boxes" HeaderToolTip="New DC Id"
                SortExpression="BOXES"  DataFormatString="{0:N0}"
                DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right"/>
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PO_ID" HeaderText="PO #" HeaderToolTip="PO Id"
                SortExpression="PO_ID" />
            <eclipse:MultiBoundField DataFields="STORE_ID" HeaderText="Store #" HeaderToolTip="Store Id"
                SortExpression="STORE_ID" />
            <eclipse:MultiBoundField DataFields="LOAD_ID" HeaderText="Load #" HeaderToolTip="Load Id"
                SortExpression="LOAD_ID" />
            <eclipse:MultiBoundField DataFields="ATS_DATE" HeaderText="ATS Date" HeaderToolTip="ATS Date"
                SortExpression="ATS_DATE" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

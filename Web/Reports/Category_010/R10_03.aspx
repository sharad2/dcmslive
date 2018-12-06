<%@ Page Title="All Unshipped Order Detail" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 3859 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_010/R10_03.aspx $
 *  $Id: R10_03.aspx 3859 2012-07-06 11:35:54Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (rblOptions.Value == "Style")
        {
            mv.ActiveViewIndex = 0;
            ButtonBar1.GridViewId = gv.ID;
        }
        else if (rblOptions.Value == "ForCancel")
        {
            mv.ActiveViewIndex = 2;
            ButtonBar1.GridViewId = gvByCancelDate.ID;
        }
        else
        {
            mv.ActiveViewIndex = 1;
            ButtonBar1.GridViewId = gvByImportDate.ID;
        }

        base.OnLoad(e);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays detail of all unshipped order with the help of style, color and customer filters and also shows the count of POs by cancel date and import date." />
    <meta name="ReportId" content="10.03" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R10_03.aspx 3859 2012-07-06 11:35:54Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <i:RadioButtonListEx runat="server" ID="rblOptions" Value="Style" FriendlyName="Unshipped Orders"
                        QueryString="order_type" Visible="false" />
                </eclipse:LeftPanel>
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <i:RadioItemProxy runat="server" Text="SKU" ID="rbStyle" CheckedValue="Style" QueryString="order_type" />
                </eclipse:LeftPanel>
                <eclipse:TwoColumnPanel ID="tcl" runat="server">
                    <eclipse:LeftLabel ID="lbl" runat="server" Text="Style" />
                    <i:TextBoxEx ID="tbstyle" runat="server" FriendlyName="Style">
                        <Validators>
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="Style" />
                            <i:Required DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="Style" />
                        </Validators>
                    </i:TextBoxEx>
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Color" />
                    <i:TextBoxEx ID="tbcolor" runat="server" FriendlyName="Color">
                        <Validators>
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="Style" />
                        </Validators>
                    </i:TextBoxEx>
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Customer" />
                    <i:TextBoxEx ID="tbcustomer" runat="server" FriendlyName="Customer" QueryString="customer_id" />
                </eclipse:TwoColumnPanel>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:RadioItemProxy runat="server" ID="rbcancel" Text="Cancel Date" CheckedValue="ForCancel"
                        QueryString="order_type" />
                </eclipse:LeftPanel>
                <asp:Panel ID="Panel1" runat="server">
                    <d:BusinessDateTextBox ID="FromCancel" runat="server" Text="0" FriendlyName="From Cancel Date">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="ForCancel" />
                        </Validators>
                    </d:BusinessDateTextBox>
                    <d:BusinessDateTextBox ID="ToCancel" runat="server"  Text="7" FriendlyName="To Cancel Date">
                        <Validators>
                            <i:Date DateType="ToDate" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="ForCancel" />
                        </Validators>
                    </d:BusinessDateTextBox>
                </asp:Panel>
                <eclipse:LeftPanel ID="LeftPanel4" runat="server">
                    <i:RadioItemProxy runat="server" ID="rbImport" Text="Import Date" CheckedValue="ForImport"
                        QueryString="order_type" />
                </eclipse:LeftPanel>
                <asp:Panel ID="Panel2" runat="server">
                    <d:BusinessDateTextBox ID="Fromimport" runat="server" Text="0" FriendlyName="From Import Date">
                        <Validators>
                            <i:Date DateType="Default" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="ForImport" />
                        </Validators>
                    </d:BusinessDateTextBox>
                    <d:BusinessDateTextBox ID="Toimport" runat="server" Text="7" FriendlyName="To Import Date">
                        <Validators>
                            <i:Date DateType="ToDate" />
                            <i:Filter DependsOn="rblOptions" DependsOnState="Value" DependsOnValue="ForImport" />
                        </Validators>
                    </d:BusinessDateTextBox>
                </asp:Panel>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <asp:MultiView runat="server" ID="mv" ActiveViewIndex="-1">
        <asp:View ID="View1" runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                SELECT /*+rule*/
                PS.PICKSLIP_ID AS PICKSLIP_ID,
       PSDET.UPC_CODE AS UPC_CODE,
       MAX(PS.CUSTOMER_ORDER_ID) AS CUSTOMER_ORDER_ID,
       MAX(PSDET.STYLE) AS STYLE,
       MAX(PSDET.COLOR) AS COLOR,
       MAX(PSDET.SKU_SIZE) AS SKU_SIZE,
       MAX(PSDET.DIMENSION) AS DIMENSION,
       MAX(PS.CUSTOMER_ID) || ':  ' ||
       NVL(MAX(CD.NAME), 'Not in Customer Master') AS CUSTOMER_NAME,
       MAX(PS.DELIVERY_DATE) AS DELIVERY_DATE,
       MAX(PS.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(PS.PS_STATUS_ID) AS STATUS,
       SUM(PSDET.QUANTITY_ORDERED) AS TOTAL_PIECES,
       SUM(NVL(PSDET.QUANTITY_ALLOCATED, PSDET.QUANTITY_ORDERED)) -
       SUM(NVL(PSDET.QUANTITY_SHIPPED, 0)) AS SHORT_PIECES
  FROM DEM_PICKSLIP_DETAIL PSDET
 INNER JOIN DEM_PICKSLIP PS
    ON PSDET.PICKSLIP_ID = PS.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_CUSTOMER CD
    ON PS.CUSTOMER_ID = CD.CUSTOMER_ID
 WHERE PS.PS_STATUS_ID IN (1, 99)
   <if>AND PS.CUSTOMER_ID =:CUSTOMER_ID</if>
   <if>AND PSDET.STYLE = :STYLE</if>
  <if>and <a pre="PSDET.COLOR IN  (" sep="," post=")">(:COLOR)</a></if>
 GROUP BY PS.PICKSLIP_ID, PSDET.UPC_CODE
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbstyle" Name="STYLE" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcolor" Name="COLOR" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="CUSTOMER_ID" Type="String" Direction="Input" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds" RowStyle-Wrap="false" DefaultSortExpression="CUSTOMER_NAME;CUSTOMER_ORDER_ID;STATUS;$;">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" ItemStyle-Font-Bold="true" HeaderText="Customer"
                        SortExpression="CUSTOMER_NAME" />
                    <eclipse:MultiBoundField DataFields="CUSTOMER_ORDER_ID" HeaderText="PO" SortExpression="CUSTOMER_ORDER_ID" />
                    <eclipse:MultiBoundField DataFields="STATUS" HeaderText="Status" SortExpression="STATUS" />
                    <eclipse:MultiBoundField DataFields="PICKSLIP_ID" HeaderText="Pickslip" SortExpression="PICKSLIP_ID" />
                    <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE" />
                    <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" />
                    <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim" SortExpression="DIMENSION" />
                    <eclipse:MultiBoundField DataFields="SKU_SIZE" HeaderText="Size" SortExpression="SKU_SIZE" />
                    <eclipse:MultiBoundField DataFields="TOTAL_PIECES" HeaderText="Pieces|Total" SortExpression="TOTAL_PIECES"
                        ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                        DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="SHORT_PIECES" HeaderText="Pieces|Short" SortExpression="SHORT_PIECES"
                        ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                        DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="DELIVERY_DATE" ItemStyle-HorizontalAlign="Right"
                        DataFormatString="{0:d}" HeaderText="Date|Delivery " SortExpression="DELIVERY_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" ItemStyle-HorizontalAlign="Right"
                        DataFormatString="{0:d}" HeaderText="Date|DC Cancel" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View ID="View2" runat="server">
            <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
SELECT /*+ RULE */
 PS.PICKSLIP_IMPORT_DATE AS IMPORT_DATE,
 SUM(PS.TOTAL_QUANTITY_ORDERED) AS ORDERED_QUANTITY,
 SUM(PS.TOTAL_DOLLARS_ORDERED) AS AMOUNT,
 TRUNC(SYSDATE) - TRUNC(PS.PICKSLIP_IMPORT_DATE) AS AGE,
 COUNT(DISTINCT PS.CUSTOMER_ORDER_ID) AS NO_OF_POS
  FROM DEM_PICKSLIP PS
 WHERE PS.PS_STATUS_ID IN (1, 99)
   AND PS.UPLOAD_DATE IS NULL
   <if>AND ps.pickslip_import_date &gt;= CAST(:Import_from_date as DATE)</if>
   <if>AND ps.pickslip_import_date &lt; CAST(:Import_to_date as DATE) + 1</if>
 GROUP BY PS.PICKSLIP_IMPORT_DATE
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="Fromimport" Type="DateTime" Direction="Input" Name="Import_from_date" />
                    <asp:ControlParameter ControlID="Toimport" Type="DateTime" Direction="Input" Name="Import_to_date" />
                    <%-- <asp:ControlParameter ControlID="rblOptions" Type="String" Direction="Input" Name="rblOptions" />--%>
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvByImportDate" runat="server" AutoGenerateColumns="false"
                AllowSorting="true" ShowFooter="true" DataSourceID="ds1" RowStyle-Wrap="false">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="NO_OF_POS" HeaderText="PO" SortExpression="NO_OF_POS"
                        ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="AGE" HeaderText="Age" SortExpression="AGE" ItemStyle-HorizontalAlign="Right"
                        DataFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="ORDERED_QUANTITY" ItemStyle-HorizontalAlign="Right"
                        DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                        FooterStyle-HorizontalAlign="Right" HeaderText="Quantity|Order" SortExpression="ORDERED_QUANTITY" />
                    <eclipse:MultiBoundField DataFields="AMOUNT" HeaderText="Quantity|Amount" SortExpression="AMOUNT"
                        ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                        DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="IMPORT_DATE" ItemStyle-HorizontalAlign="Right"
                        DataFormatString="{0:d}" HeaderText="Date Import" SortExpression="IMPORT_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View ID="View3" runat="server">
            <oracle:OracleDataSource ID="ds2" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>               
SELECT /*+ RULE */
 PS.CANCEL_DATE AS CANCEL_DATE,
 SUM(PSDET.QUANTITY_ORDERED) AS ORDERED_QUANTITY,
 SUM(PSDET.QUANTITY_SHIPPED) AS CHECKED_QUANTITY,
 SUM(PSDET.QUANTITY_ORDERED * EXTENDED_PRICE) AS AMOUNT,
 COUNT(DISTINCT PS.CUSTOMER_ORDER_ID) AS NO_OF_POS
  FROM DEM_PICKSLIP PS
  INNER JOIN DEM_PICKSLIP_DETAIL PSDET
  ON PS.PICKSLIP_ID = PSDET.PICKSLIP_ID
 WHERE PS.PS_STATUS_ID IN (1, 99)
  <if>AND ps.cancel_date &gt; = CAST(:from_date AS DATE)</if>
 <if>AND ps.cancel_date &lt; CAST(:to_date AS DATE) +1 </if>
 GROUP BY PS.CANCEL_DATE
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="FromCancel" Type="DateTime" Direction="Input" Name="from_date" />
                    <asp:ControlParameter ControlID="ToCancel" Type="DateTime" Direction="Input" Name="to_date" />
                    <%--<asp:ControlParameter ControlID="rblOptions" Type="String" Direction="Input" Name="rblOptions" />--%>
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gvByCancelDate" runat="server" AutoGenerateColumns="false"
                AllowSorting="true" ShowFooter="true" DataSourceID="ds2">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="NO_OF_POS" HeaderText="PO" SortExpression="NO_OF_POS"
                        ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="CHECKED_QUANTITY" HeaderText="Quantity|Checked"
                        SortExpression="CHECKED_QUANTITY" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="ORDERED_QUANTITY" HeaderText="Quantity|Order"
                        SortExpression="ORDERED_QUANTITY" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="AMOUNT" HeaderText="Quantity|Amount" SortExpression="AMOUNT"
                        ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                        DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="CANCEL_DATE" ItemStyle-HorizontalAlign="Right"
                        DataFormatString="{0:d}" HeaderText="Cancel Date" SortExpression="CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

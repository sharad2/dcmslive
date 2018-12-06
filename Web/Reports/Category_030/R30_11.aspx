<%@ Page Title="SKUs Return in a given time period" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7191 $
 *  $Author: skumar $
 *  $HeadURL: 

http://vcs/svn/net35/Projects/XTremeReporter3/trunk/Website/Reports/Category_030/R30_11.

aspx $
 *  $Id: R30_11.aspx 7191 2014-08-29 09:10:00Z skumar $
 * Version Control Template Added.
 Max dimension in query even dimension is in group by clause. [GL- Corrected]
 When write a specific code for special purpose always write proper comment so that any one 

can understand what are you doing.
--%>
<%--Mutually Exclusive Parameters--%>
<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        gv.RowDataBound += new GridViewRowEventHandler(gv_RowDataBound);
        base.OnInit(e);
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        // Handling dynamic visibility of the status column

        if (tbReceiptNumber.Text !="" && IsPostBack)
        {
            DataControlField dcf = (from DataControlField dc in gv.Columns
                                    where dc.AccessibleHeaderText.Equals("status")
                                    select dc).Single();
            dcf.Visible = true;
        }
        if (Ckbox.Value == "Y" && IsPostBack)
        {
            DataControlField dcf = (from DataControlField dc in gv.Columns
                                    where dc.AccessibleHeaderText.Equals("status")
                                    select dc).Single();
            dcf.Visible = false;
        }
        if (Ckbox.Value == "Y" && IsPostBack)
        {
            DataControlField dcf = (from DataControlField dc in gv.Columns
                                    where dc.AccessibleHeaderText.Equals("MasterColumn")
                                    select dc).Single();
            dcf.Visible = false;
        }
        if (Ckbox.Value == "Y" && IsPostBack)
        {
            DataControlField dcf = (from DataControlField dc in gvModifiedReturns.Columns
                                    where dc.AccessibleHeaderText.Equals("MasterColumn1")
                                    select dc).Single();
            dcf.Visible = false;
        }
        if (Ckbox.Value == "Y")
        {
            gv.DefaultSortExpression = "quantity {0:I};style";
            gvModifiedReturns.DefaultSortExpression = "quantity {0:I};style";

        }
    }
    /// <summary>
    /// Event handled to give visual segrigation for modified returns.
    /// </summary>
    //private bool _isModifiedCaptionVisible;
    //private bool _isNewCaptionVisible;
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {

    }
    protected void tbReceiptNumber_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (string.IsNullOrEmpty(tbReceiptNumber.Text) && string.IsNullOrEmpty(tbauthorization.Text) && is_partial.Checked == false && cbcompletedate.Checked == false)
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide value for at least one filter in 'Returns For' Section.";
            return;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report lists all the SKUs which are returned back 

from customers on the specified date range or partially entered returns. Optionally, the report 

lists the records for any specified Receipt Number." />
    <meta name="ReportId" content="30.11" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Completed date filter can now be used with other filters as well. |Now you can see returns by style.|Now report can be exclusively run for the given Authorization Number. In previous version one additional filter was also required to see returns for an authorization number.|Provided Customer ID and Authorization number filters.| Label column is removed from master." />
    <meta name="Version" content="$Id: R30_11.aspx 7191 2014-08-29 09:10:00Z skumar $" />
    <style type="text/css">
        /*The style to be applied to the div of template field. Which is a master field */
        .master_row_entry {
            margin-bottom: .3em;
            padding-right: 2mm;
        }

        .masterColumn {
            display: inline-block;
            overflow: visible;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" Text="Customer ID" ViewStateMode="Disabled" />
                <i:TextBoxEx ID="tbcustomer" runat="server" FriendlyName="Customer" ToolTip="Customer ID which you want to see the information" />
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <fieldset>
                        <legend class="ui-widget-header">Returns For (Pass at least one filter)</legend>
                        <br />
                        <eclipse:TwoColumnPanel ID="TCP" runat="server">
                            <eclipse:LeftPanel runat="server">
                                <i:CheckBoxEx runat="server" ID="is_partial" Text="All Partially Received" ToolTip="Check to view partially entered records" FriendlyName="All Partially Received" CheckedValue="partial" />
                            </eclipse:LeftPanel>

                            <eclipse:LeftPanel ID="LeftPanel4" runat="server">
                                <i:CheckBoxEx runat="server" ID="cbcompletedate" FilterDisabled="true" Text="Completed between dates" CheckedValue="Y"
                                    QueryString="completed_date" FriendlyName="Completed Date" Checked="false" ToolTip="Check to view returned SKUs which are completely recieved to modified within specified dates" />
                            </eclipse:LeftPanel>
                            From
                            <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From Completion Date"
                                QueryString="from_completed_date" Text="-7">
                                <Validators>
                                    <i:Filter DependsOn="cbcompletedate" DependsOnState="Checked" />
                                    <i:Date />
                                </Validators>
                            </d:BusinessDateTextBox>
                            To:
                            <d:BusinessDateTextBox ID="dtTo" runat="server" FriendlyName="To Completion Date"
                                QueryString="to_completed_date" Text="0">
                                <Validators>
                                    <i:Filter DependsOn="cbcompletedate" DependsOnState="Checked" />
                                    <i:Date DateType="ToDate" />
                                </Validators>
                            </d:BusinessDateTextBox>
                            <eclipse:LeftLabel runat="server" />
                            <i:TextBoxEx ID="tbReceiptNumber" runat="server" FriendlyName="Receipt Number" ToolTip="Check to view records of a specific receipt number">
                                <Validators>
                                    <i:Custom OnServerValidate="tbReceiptNumber_OnServerValidate" />
                                </Validators>
                            </i:TextBoxEx>
                            <eclipse:LeftLabel runat="server" />
                            <i:TextBoxEx ID="tbauthorization" runat="server" FriendlyName="Authorization Number" ToolTip="Authorization Number which you want to see the information">
                            </i:TextBoxEx>
                        </eclipse:TwoColumnPanel>
                    </fieldset>
                    <br />
                </eclipse:LeftPanel>
                <eclipse:LeftLabel ID="labl" runat="server" />
                <i:CheckBoxEx runat="server" ID="Ckbox" FriendlyName="Returns by Style" CheckedValue="Y" />
                <br />
                Check this if you want to see returns by Style.
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
           SELECT 
                MAX(ms.label_id) as label_id,
               <if c="$StyleValue='Y'">
               demdet.style ||' : ' || max(ms.description) as style,
       null AS receipt_numbers,
       null as color,
       null as dimension,
       null as sizes,
       null AS received_date,
       null AS auth_number,
       null as complete_date,
       null as customer_id,
       null as dm_date,
       null as reason_code,
       null as is_complete_return, 
       null as store_Id,
       null as dm_number,
       null AS modified_complete_date,
       null AS STATUS,
       null AS expected_pieces,
               </if>
               <else>
       demdet.style as style,
       dem.receipt_number AS receipt_numbers,
       demdet.color as color,
       demdet.dimension as dimension,
       demdet.sku_size as sizes,
       MAX(dem.received_date) AS received_date,
       MAX(dem.returns_authorization_number) AS auth_number,
       MAX(dem.complete_date) as complete_date,
       MAX(dem.customer_id || ' : ' || mc.name) as customer_id,
       MAX(dem.dm_date) as dm_date,
       MAX(dem.reason_code) as reason_code,
       MAX(dem.is_complete_return) as is_complete_return,
       MAX(dem.customer_store_id) as store_Id,
       MAX(dem.dm_number) as dm_number,
      <if c="$FROM_RECEIPT_DATE">MAX(dem.modified_complete_date)</if>
      <else>NULL</else> AS modified_complete_date,
       MAX(CASE
              WHEN dem.is_complete_return IS NULL THEN
              'No'
              ELSE
              'Yes'
              END)AS STATUS,
       MAX(dem.expected_pieces) AS expected_pieces,
               </else>
       SUM(demdet.quantity) as quantity
  FROM DEM_RETURNS dem
  INNER JOIN DEM_RETURNS_DETAIL demdet ON DEM.RECEIPT_NUMBER = demdet.RECEIPT_NUMBER
  LEFT OUTER JOIN MASTER_STYLE ms ON ms.STYLE = demdet.STYLE
  LEFT OUTER JOIN cust mc ON dem.customer_id = mc.customer_id
  WHERE 1 = 1
   <if c="$is_partial='partial'">AND dem.is_complete_return IS NULL</if>
   <if c="$FROM_RECEIPT_DATE">AND dem.is_complete_return IS NOT NULL AND 
(trunc(dem.complete_date) between trunc(:FROM_RECEIPT_DATE) 
   AND  trunc(:TO_RECEIPT_DATE))And dem.modified_complete_date is null</if>
  <if>AND dem.receipt_number = trim(:receipt_number)</if> 
<if>and dem.customer_id = trim(:customer_id)</if>
  <if>and dem.returns_authorization_number = trim(:authorization_number)</if>
  GROUP BY <if c="$StyleValue='Y'">demdet.style</if>
               <else>dem.receipt_number,          
           demdet.style,
           demdet.color,
           demdet.dimension,
           demdet.sku_size</else>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FROM_RECEIPT_DATE" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="TO_RECEIPT_DATE" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FROM_MODIFIED_DATE" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="TO_MODIFIED_DATE" />
            <asp:ControlParameter ControlID="tbReceiptNumber" Type="String" Direction="Input"
                Name="receipt_number" />
            <asp:ControlParameter Name="is_partial" ControlID="is_partial" Type="String" PropertyName="Value" />
            <asp:ControlParameter ControlID="tbcustomer" Type="String" Direction="Input"
                Name="customer_id" />
            <asp:ControlParameter ControlID="tbauthorization" Type="String" Direction="Input"
                Name="authorization_number" />
            <asp:ControlParameter ControlID="Ckbox" Type="String" Direction="Input"
                Name="StyleValue" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
           <if c="$FROM_RECEIPT_DATE">
           SELECT 
               <if c="$StyleValue='Y'">
        demdet.style ||' : ' || max(ms.description) as style,
       null AS receipt_numbers,
       null as color,
       null as dimension,
       null as sizes,
       null AS received_date,
       null AS auth_number,
       null as complete_date,
       null as customer_id,
       null as dm_date,
       null as reason_code,
       null as is_complete_return,
       null as store_Id,
       null as dm_number,
       null AS modified_complete_date,
       null AS STATUS,
       null AS expected_pieces,
               </if>
               <else>
       demdet.style as style,
       dem.receipt_number AS receipt_numbers,
       demdet.color as color,
       demdet.dimension as dimension,
       demdet.sku_size as sizes,
       MAX(dem.received_date) AS received_date,
       MAX(dem.returns_authorization_number) AS auth_number,
       MAX(dem.complete_date) as complete_date,
       MAX(dem.customer_id || ' : ' ||mc.name) as customer_id,
       MAX(dem.dm_date) as dm_date,
       MAX(dem.reason_code) as reason_code,
       MAX(dem.is_complete_return) as is_complete_return,
       MAX(dem.customer_store_id) as store_Id,
       MAX(dem.dm_number) as dm_number,
      <if c="$FROM_RECEIPT_DATE">MAX(dem.modified_complete_date)</if>
      <else>NULL</else> AS modified_complete_date,
       MAX(CASE
              WHEN dem.is_complete_return IS NULL THEN
              'No'
              ELSE
              'Yes'
              END)AS STATUS,
       MAX(dem.expected_pieces) AS expected_pieces,
               </else>
       MAX(ms.label_id) as label_id,
       SUM(demdet.quantity) as quantity
  FROM DEM_RETURNS dem
  INNER JOIN DEM_RETURNS_DETAIL demdet ON DEM.RECEIPT_NUMBER = demdet.RECEIPT_NUMBER
  LEFT OUTER JOIN MASTER_STYLE ms ON ms.STYLE = demdet.STYLE
  LEFT OUTER JOIN cust mc ON dem.customer_id = mc.customer_id
  WHERE 1 = 1  
   <if c="$FROM_RECEIPT_DATE">AND dem.is_complete_return IS NOT NULL AND 
 (trunc(dem.modified_complete_date) between trunc(:FROM_RECEIPT_DATE) 
   AND  trunc(:TO_RECEIPT_DATE) )</if> 
  <if>AND dem.receipt_number = trim(:receipt_number)</if> 
  <if>and dem.customer_id = trim(:customer_id)</if>     
  <if c="$is_partial='partial'">AND dem.is_complete_return IS NULL</if>                       
  <if>and dem.returns_authorization_number = trim(:authorization_number)</if>
  GROUP BY <if c="$StyleValue='Y'">demdet.style</if>
               <else>dem.receipt_number,          
               demdet.style,
           demdet.color,
           demdet.dimension,
           demdet.sku_size</else>
           </if>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FROM_RECEIPT_DATE" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="TO_RECEIPT_DATE" />
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="FROM_MODIFIED_DATE" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="TO_MODIFIED_DATE" />
            <asp:ControlParameter ControlID="tbReceiptNumber" Type="String" Direction="Input"
                Name="receipt_number" />
             <asp:ControlParameter Name="is_partial" ControlID="is_partial" Type="String" PropertyName="Value" />
            <asp:ControlParameter ControlID="tbcustomer" Type="String" Direction="Input"
                Name="customer_id" />
            <asp:ControlParameter ControlID="tbauthorization" Type="String" Direction="Input"
                Name="authorization_number" />
            <asp:ControlParameter ControlID="Ckbox" Type="String" Direction="Input"
                Name="StyleValue" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        EnableViewState="false" ShowFooter="true" DataSourceID="ds" DefaultSortExpression="modified_complete_date {0:I},receipt_numbers,label_id,customer_id,received_date,dm_date,store_Id,auth_number,reason_code,dm_number,complete_date;$;label_id;style;color;dimension;sizes"
        EnableMasterRowNewSequence="true">
        <Columns>
            <eclipse:SequenceField />
            <asp:TemplateField AccessibleHeaderText="MasterColumn" SortExpression="modified_complete_date {0:I},receipt_numbers,label_id,customer_id,received_date,dm_date,store_Id,auth_number,reason_code,dm_number,complete_date"
                HeaderText="RMA Info">
                <ItemTemplate>
                    <span class="masterColumn">
                        <span class="master_row_entry">
                            <strong title="Return ID">Return#:</strong>
                            <%# Eval("receipt_numbers")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Date of Return">Return Date:</strong>
                            <%# Eval("received_date", "{0:d}")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Authorization Number">Authorization#:</strong>
                            <%# Eval("auth_number")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="# of expected pieces">Expected Pieces:</strong>
                            <%# Eval("expected_pieces")%>
                        </span>
                    </span>
                    <span class="masterColumn">
                        <span class="master_row_entry">
                            <strong>Customer:</strong>
                            <%# Eval("customer_id")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="DM Date">DM Date:</strong>
                            <%# Eval("dm_date", "{0:d}")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Reason Code">Reason:</strong>
                            <%# Eval("reason_code")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Completion Date">Completed Date:</strong>
                            <%# Eval("complete_date", "{0:d}")%>
                        </span>
                    </span>
                    <span class="masterColumn">
                        <span class="master_row_entry">
                            <strong title="Store ID">Store:</strong>
                            <%# Eval("store_Id")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="DM Number">DM#:</strong>
                            <%# Eval("dm_number")%>
                        </span>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" HideEmptyColumn="true" SortExpression="color"
                HeaderToolTip="Color" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" HideEmptyColumn="true" SortExpression="dimension"
                HeaderToolTip="Dimension" />
            <eclipse:MultiBoundField DataFields="sizes" HeaderText="Size" HideEmptyColumn="true" SortExpression="sizes"
                HeaderToolTip="SKU Sizes" />
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Quantity" SortExpression="quantity"
                ItemStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right"
                FooterToolTip="Total quantity of returns">
                <ItemStyle Width="2em" />
            </eclipse:MultiBoundField>
            <jquery:IconField DataField="status" HeaderText="Completed?" DataFieldValues="Yes"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="status"
                HeaderToolTip="Is return completed on the given date" AccessibleHeaderText="status"
                Visible="false" />
        </Columns>
    </jquery:GridViewEx>
    <br />
    <jquery:GridViewEx ID="gvModifiedReturns"  Caption="<h3>Modified Returns</h3>" CaptionAlign="Left" DataSourceID="ds1" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        EnableViewState="false" ShowFooter="true" DefaultSortExpression="modified_complete_date {0:I},receipt_numbers,label_id,customer_id,received_date,dm_date,store_Id,auth_number,reason_code,dm_number,complete_date;$;label_id;style;color;dimension;sizes"
        EnableMasterRowNewSequence="true" ShowExpandCollapseButtons="false">
        <Columns>
            <eclipse:SequenceField />
            <asp:TemplateField AccessibleHeaderText="MasterColumn1" SortExpression="modified_complete_date {0:I},receipt_numbers,label_id,customer_id,received_date,dm_date,store_Id,auth_number,reason_code,dm_number,complete_date">
                <ItemTemplate>
                    <span class="masterColumn">
                        <span class="master_row_entry">
                            <strong title="Return ID">Return#:</strong>
                            <%# Eval("receipt_numbers")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Date of Return">Return Date:</strong>
                            <%# Eval("received_date", "{0:d}")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Authorization Number">Authorization#:</strong>
                            <%# Eval("auth_number")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="# of expected pieces">Expected Pieces:</strong>
                            <%# Eval("expected_pieces")%>
                        </span>
                    </span>
                    <span class="masterColumn">
                        <span class="master_row_entry">
                            <strong>Customer:</strong>
                            <%# Eval("customer_id")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="DM Date">DM Date:</strong>
                            <%# Eval("dm_date", "{0:d}")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Reason Code">Reason:</strong>
                            <%# Eval("reason_code")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="Completion Date">Completed Date:</strong>
                            <%# Eval("complete_date", "{0:d}")%>
                        </span>
                    </span>
                    <span class="masterColumn">
                        <span class="master_row_entry">
                            <strong title="Store ID">Store:</strong>
                            <%# Eval("store_Id")%>
                        </span>
                        <br />
                        <span class="master_row_entry">
                            <strong title="DM Number">DM#:</strong>
                            <%# Eval("dm_number")%>
                        </span>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label" />
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style" />
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color" HideEmptyColumn="true" />
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dim" SortExpression="dimension"
                HeaderToolTip="Dimension" HideEmptyColumn="true" />
            <eclipse:MultiBoundField DataFields="sizes" HeaderText="Size" SortExpression="sizes"
                HeaderToolTip="SKU Sizes" HideEmptyColumn="true" />
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Quantity" SortExpression="quantity" DataFormatString="{0:N0}"
                ItemStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right"
                FooterToolTip="Total quantity of returns">
                <ItemStyle Width="2em" />
            </eclipse:MultiBoundField>
            <jquery:IconField DataField="status" HeaderText="Completed?" DataFieldValues="Yes"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="status"
                HeaderToolTip="Is return completed on the given date" AccessibleHeaderText="status"
                Visible="false" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

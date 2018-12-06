<%@ Page Title="Boxes of a customer in different areas" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4276 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R110_21.aspx $
 *  $Id: R110_21.aspx 4276 2012-08-18 07:20:31Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    //&lt;summary&gt;
    //When grid is load and main grid show the row then the form view visible ture
    //&lt;/summary&gt;
    //&lt;param name="sender"&gt;&lt;/param&gt;
    //&lt;param name="e"&gt;&lt;/param&gt;
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int? CountOfBuckets;
        int? CountOfPOs;
        int? CountOfDcs;
        int? CountOfbols;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CountOfBuckets = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_BUCKETS"));
            CountOfPOs = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_POS"));
            CountOfDcs = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_DCS"));
            CountOfbols = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_SHIPPING_ID"));
            var cellIndex = 0;
            if (CountOfBuckets > 1)
            {
                cellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BUCKET" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE WAVEs";
            }
            if (CountOfPOs > 1)
            {
                cellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_PO" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE POs";
            }
            if (CountOfDcs > 1)
            {
                cellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_DC" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE DCs";
            }
            if (CountOfbols > 1)
            {
                cellIndex = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BOLS" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE BOLs";
              
            }

            divInfo.Visible = true;
            div1.Visible = true;
            div2.Visible = true;

        }
    }
    protected void gv1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            div1.Visible = true;
            divInfo.Visible = true;
            div2.Visible = true;
            div4.Visible = true;
            div3.Visible = true;
        }
       
            

    }

    //protected void gv1_OnLoad(object sender,EventArgs e)
    //{
    //    if (gv1.Columns.Count > 0)
    //    {
    //        SiteHyperLinkField fld1 = (SiteHyperLinkField)gv1.Columns[1];
    //        fld1.DataNavigateUrlFormatString = string.Format("R110_105.aspx?box_area_id={{0}}&WAREHOUSE_LOCATION_ID={{1}}&BoxOnPallet=N&customer_id={0}", tbcustomer.Text);
    //    }     
        
    //}
    protected void gv2_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int? CountOfBuckets;
        int? CountOfPOs;
        int? CountOfDcs;
        int? CountOfbols;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CountOfBuckets = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_BUCKETS"));
            CountOfPOs = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_POS"));
            CountOfDcs = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_DCS"));
            CountOfbols = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_SHIPPING_ID"));
            var cellIndex = 0;
            if (CountOfBuckets > 1)
            {
                cellIndex = gv2.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BUCKET" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE WAVEs";
            }
            if (CountOfPOs > 1)
            {
                cellIndex = gv2.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_PO" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE POs";
            }
            if (CountOfDcs > 1)
            {
                cellIndex = gv2.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_DC" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE DCs";
            }
            if (CountOfbols > 1)
            {
                cellIndex = gv2.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BOLS" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE BOLs";
            }

            divInfo.Visible = true;
            div1.Visible = true;
            div2.Visible = true;

        }

    }
    //this grid show the box on P Pallat PO wise
    protected void gvByPo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int? CountOfBuckets;
        int? CountOfDcs;
        int? CountOfbols;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CountOfBuckets = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_BUCKETS"));

            CountOfDcs = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_DCS"));
            CountOfbols = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_SHIPPING_ID"));
            var cellIndex = 0;
            if (CountOfBuckets > 1)
            {
                cellIndex = gvByPo.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BUCKET" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE WAVEs";
            }
            if (CountOfDcs > 1)
            {
                cellIndex = gvByPo.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_DC" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE DCs";
            }
            if (CountOfbols > 1)
            {
                cellIndex = gvByPo.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BOLS" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE BOLs";
            }
            divInfo.Visible = true;
            div3.Visible = true;
            div4.Visible = true;

        }
    }
    // That code has writen for the Temporary Pallet PO wise
    protected void gvByPo1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int? CountOfBuckets;
        int? CountOfDcs;
        int? CountOfbols;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CountOfBuckets = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_BUCKETS"));
            CountOfDcs = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_OF_DCS"));
            CountOfbols = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "COUNT_SHIPPING_ID"));
            var cellIndex = 0;
            if (CountOfBuckets > 1)
            {
                cellIndex = gvByPo1.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BUCKET" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE WAVEs";
            }
            if (CountOfDcs > 1)
            {
                cellIndex = gvByPo1.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_DC" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE DCs";
            }
            if (CountOfbols > 1)
            {
                cellIndex = gvByPo1.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "MAX_BOLS" ? i : -1)
                        .Single(p => p >= 0);
                e.Row.ToolTip = "This Pallet contains mixed criteria boxes.";
                e.Row.Cells[cellIndex].Text = "MULTIPLE BOLs";
            }

            divInfo.Visible = true;
            div3.Visible = true;
            div4.Visible = true;

        }

    }
    protected override void OnLoad(EventArgs e)
    {
        if (Ckbox.Checked)
        {
            mv.ActiveViewIndex = 1;
            ctlButtonBar.GridViewId = gvByPo.ID;
            ctlButtonBar.GridViewId = gvByPo1.ID;
        }
        else
        {
            mv.ActiveViewIndex = 0;
            ctlButtonBar.GridViewId = gv.ID;
            ctlButtonBar.GridViewId = gv2.ID;
        }
      

        base.OnLoad(e);
    }
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
    protected void tbcustomer_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (!string.IsNullOrEmpty(tbcustomer.Text))
        {
            e.ControlToValidate.IsValid = true;
            return;
        }
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is for showing area wise palletized and non palletized boxes of a customer. This report can also be displayed with different combinations of the following 
    filters:- Purchase Order, Bill Of Lading, Customer DC, Customer Store, Building, ATS Date and DC Cancel Date. This report will not consider shipped orders." />
    <meta name="ReportId" content="110.21" />
    <meta name="Browsable" content="true" />
     <meta name="ChangeLog" content="Provided multiple selection for customer filter.|Showing user who put last box on the Pallet." />
    <meta name="Version" content="$Id: R110_21.aspx 4276 2012-08-18 07:20:31Z skumar $" />
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
                <eclipse:LeftLabel ID="LeftLabel5" Text="Customer" runat="server" />
               <i:AutoComplete runat="server" ID="tbcustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Customer" QueryString="customer_id" ToolTip="The customers whose purchase order you are interested in."
                    Delay="1000" Width="200"  OnClientSelect="tbcustomer_OnClientSelect">
                   <Validators>
                        <i:Required  OnServerValidate="tbcustomer_OnServerValidate" />
                    </Validators>
                </i:AutoComplete>
                <br />
                You can pass multiple Customers seperated by comma (i.e. 10120,11160)
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="Purchase Order" />
                <i:TextBoxEx ID="tbPO" runat="server" QueryString="po_id" FriendlyName="Purchase Order" />
                <br />
                You can pass multiple POs seperated by comma (i.e. 79149272,19096723)
                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text=" Bill Of Lading" />
                <i:TextBoxEx ID="tbShipping" runat="server" QueryString="Shipping_Id" FriendlyName="Bill Of Lading" />
                <eclipse:LeftLabel ID="Lbl" runat="server" Text="Wave" />
                <i:TextBoxEx ID="tbWave" runat="server" QueryString="bucket_id" />
                <br />
                You can pass multiple Waves seperated by comma (i.e. 28390,28409)
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Customer DC" />
                <i:TextBoxEx ID="tbdc" runat="server" QueryString="customer_dc_id" />
                <br />
                You can pass multiple DCs seperated by comma (i.e. 90324,94417)
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Customer Store" />
                <i:TextBoxEx ID="tbstore" runat="server" QueryString="customer_store_id" />
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" />
                <d:BuildingSelector FriendlyName="Building" runat="server" ID="ctlWhLoc" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ToolTip="Please Select building " ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <br />
                Boxes of customer will be shown for open order in this building.
                <eclipse:LeftLabel ID="LeftLabel9" runat="server" Text="ATS Date" />
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
                <eclipse:LeftLabel ID="labl" runat="server" />
                <i:CheckBoxEx runat="server" ID="Ckbox" FriendlyName="PO wise details" CheckedValue="Y"
                    Text="Check this if you want to see the details PO wise." />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds1" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
        <SelectSql>
         <if c="$customer_id">
 SELECT nvl(B.IA_ID,'Non Physical Boxes')   AS box_area_id,
        MAX(edips.LOAD_ID)             AS LOAD_ID,
        IA.PROCESS_FLOW_SEQUENCE    AS PROCESS_FLOW_SEQUENCE,
        PS.CUSTOMER_ID AS CUSTOMER_ID,
        MAX(C.NAME)                 AS NAME,
        ps.WAREHOUSE_LOCATION_ID    AS WAREHOUSE_LOCATION_ID,
        MIN(ms.LABEL_ID)            AS MIN_LABEL_ID,
        MAX(ms.LABEL_ID)            AS MAX_LABEL_ID,
        COUNT(DISTINCT ms.LABEL_ID) AS COUNT_LABEL_ID,
        COUNT(DISTINCT b.ucc128_id) AS TOTAL_BOXES
    FROM BOX B
    INNER JOIN BOXDET BD ON 
    B.UCC128_ID = BD.UCC128_ID
    AND B.PICKSLIP_ID = BD.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_SKU MSKU ON
    BD.UPC_CODE = MSKU.UPC_CODE
    LEFT OUTER JOIN MASTER_STYLE MS ON
    MSKU.STYLE = MS.STYLE
    LEFT OUTER JOIN IA IA
      ON B.IA_ID = IA.IA_ID
    LEFT OUTER JOIN PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
    LEFT OUTER JOIN CUST C ON 
    PS.CUSTOMER_ID = C.CUSTOMER_ID
    LEFT OUTER JOIN edi_753_754_ps edips
      ON PS.PICKSLIP_ID = edips.PICKSLIP_ID
    LEFT OUTER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
   WHERE PS.TRANSFER_DATE IS NULL
     AND B.PALLET_ID IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
     <if>AND ps.SHIPPING_ID = :SHIPPING_ID</if>
     <if>AND <a pre="PS.customer_id in(" sep="," post=")">:customer_id</a></if>
     <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
     <if>AND PS.customer_store_id =:customer_store_id</if>
       <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:BUCKET_ID)</a></if>
      <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
     <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
     <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE as DATE)</if>
     <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE as DATE) +1</if>
GROUP BY IA.PROCESS_FLOW_SEQUENCE,
nvl(B.IA_ID,'Non Physical Boxes'),
ps.warehouse_location_id, PS.CUSTOMER_ID
  </if>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" PropertyName="Text" />
            <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
            <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                Direction="Input" />
            <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
        id="div1" visible="false">
        <i>Boxes Not On Pallet.</i>
    </div>
    <jquery:GridViewEx ID="gv1" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds1" ShowExpandCollapseButtons="false" OnRowDataBound="gv1_RowDataBound"
        DefaultSortExpression="NAME;$;IA.PROCESS_FLOW_SEQUENCE {0:I} NULLS FIRST">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="box_area_id" DataNavigateUrlFields="box_area_id,WAREHOUSE_LOCATION_ID,customer_id"
                HeaderText="Area" DataNavigateUrlFormatString="R110_105.aspx?box_area_id={0}&WAREHOUSE_LOCATION_ID={1}&customer_id={2}&BoxOnPallet=N"
                SortExpression="box_area_id" AppliedFiltersControlID="ctlButtonBar$af" AccessibleHeaderText="boxArea">
            </eclipse:SiteHyperLinkField>
            <asp:TemplateField HeaderText="Label" HeaderStyle-Wrap="false" SortExpression="MIN_LABEL_ID">
                <ItemTemplate>
                    <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LABEL_ID,MIN_LABEL_ID,MAX_LABEL_ID" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="LOAD_ID" SortExpression="LOAD_ID" HeaderText="Load Id"
                ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="NAME" HeaderText="Name"
                        SortExpression="NAME" />
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" SortExpression="WAREHOUSE_LOCATION_ID"
                NullDisplayText="Unknown" HeaderText="Building" ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="TOTAL_BOXES" HeaderText="Total Boxes" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right" />
        </Columns>
    </jquery:GridViewEx>
    <asp:MultiView runat="server" ID="mv" ActiveViewIndex="-1">
        <asp:View runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                <if c="$customer_id">
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       B.IA_ID AS IA_ID,
       PS.CUSTOMER_ID AS CUSTOMER_ID,
       MAX(C.NAME) AS CUSTOMER_NAME,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(PS.SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT PS.SHIPPING_ID) AS COUNT_SHIPPING_ID,
       MAX(PS.BUCKET_ID) AS MAX_BUCKET,
       COUNT(DISTINCT PS.BUCKET_ID) AS COUNT_OF_BUCKETS,
       MAX(PS.PO_ID) AS MAX_PO,
       COUNT(DISTINCT PS.PO_ID) AS COUNT_OF_POS,
       MAX(PS.CUSTOMER_DC_ID) AS MAX_DC,
       COUNT(DISTINCT PS.CUSTOMER_DC_ID) AS COUNT_OF_DCS,
       MAX(B.MODIFIED_BY) KEEP (DENSE_RANK LAST ORDER BY b.date_modified) AS USER_NAME,
       COUNT(DISTINCT B.UCC128_ID) AS Total_Boxes
  FROM BOX B
 INNER JOIN BOXDET BD
    ON B.UCC128_ID = BD.UCC128_ID
   AND B.PICKSLIP_ID = BD.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_SKU MSKU
    ON BD.UPC_CODE = MSKU.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MS
    ON MSKU.STYLE = MS.STYLE
  LEFT OUTER JOIN PS
    ON B.PICKSLIP_ID = PS.PICKSLIP_ID
  LEFT OUTER JOIN CUST C ON 
    PS.CUSTOMER_ID = C.CUSTOMER_ID
  LEFT OUTER JOIN SHIP S
    ON PS.SHIPPING_ID = S.SHIPPING_ID
  LEFT OUTER JOIN edi_753_754_ps edips
    ON PS.PICKSLIP_ID = edips.PICKSLIP_ID
  LEFT OUTER JOIN PO
    ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
   AND PS.PO_ID = PO.PO_ID
   AND PS.ITERATION = PO.ITERATION
 WHERE PS.TRANSFER_DATE IS NULL
   AND PALLET_ID LIKE 'P%'
   AND B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
   <if>AND PS.SHIPPING_ID = :SHIPPING_ID</if>
    <if>AND <a pre="PS.customer_id in(" sep="," post=")">:customer_id</a></if>
   <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
   <if>AND PS.CUSTOMER_STORE_ID = :customer_store_id</if>
   <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:BUCKET_ID)</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
   <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
   <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
   <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
GROUP BY B.PALLET_ID,B.IA_ID,ps.warehouse_location_id, PS.CUSTOMER_ID
</if>
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" PropertyName="Text"/>
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="divInfo" visible="false">
                <i>Boxes On Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds" DefaultSortExpression="CUSTOMER_NAME;IA_ID;warehouse_location_id;$;PALLET_ID;location_id"
                OnRowDataBound="gv_RowDataBound">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                        <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name"
                        SortExpression="CUSTOMER_NAME" />
                    <eclipse:MultiBoundField DataFields="IA_ID" NullDisplayText="<b>Non Physical Boxes</b>"
                        HeaderText="Area" SortExpression="IA_ID" />
                    <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                        NullDisplayText="Unknown" SortExpression="warehouse_location_id" />
                    <eclipse:MultiBoundField DataFields="location_id" ItemStyle-Wrap="false" HeaderText="Location"
                        NullDisplayText="No Location" SortExpression="location_id" />
                    <eclipse:MultiBoundField DataFields="Total_Boxes" HeaderText="Total Boxes" HeaderStyle-Wrap="false"
                        SortExpression="Total_Boxes" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Label" HeaderStyle-Wrap="false" SortExpression="MIN_LABEL_ID">
                        <ItemTemplate>
                            <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LABEL_ID,MIN_LABEL_ID,MAX_LABEL_ID" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <eclipse:MultiBoundField DataFields="LOAD_ID" HeaderText="Load Id" SortExpression="LOAD_ID"
                        HeaderStyle-Wrap="false" />
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                        <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="User" ItemStyle-Wrap="false"
                        SortExpression="USER_NAME"  />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="Dc Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
            <oracle:OracleDataSource ID="ds2" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
         <if c="$customer_id">
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       B.IA_ID AS IA_ID,
       PS.CUSTOMER_ID AS CUSTOMER_ID,
       MAX(C.NAME) AS CUSTOMER_NAME,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(PS.SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT PS.SHIPPING_ID) AS COUNT_SHIPPING_ID,
       MAX(PS.BUCKET_ID) AS MAX_BUCKET,
       COUNT(DISTINCT PS.BUCKET_ID) AS COUNT_OF_BUCKETS,
       MAX(PS.PO_ID) AS MAX_PO,
       COUNT(DISTINCT PS.PO_ID) AS COUNT_OF_POS,
       MAX(PS.CUSTOMER_DC_ID) AS MAX_DC,
       COUNT(DISTINCT PS.CUSTOMER_DC_ID) AS COUNT_OF_DCS,
       MAX(B.MODIFIED_BY) KEEP (DENSE_RANK LAST ORDER BY b.date_modified) AS USER_NAME,
       COUNT(DISTINCT B.UCC128_ID) AS Total_Boxes
  FROM BOX B
 INNER JOIN BOXDET BD
    ON B.UCC128_ID = BD.UCC128_ID
   AND B.PICKSLIP_ID = BD.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_SKU MSKU
    ON BD.UPC_CODE = MSKU.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MS
    ON MSKU.STYLE = MS.STYLE
  LEFT OUTER JOIN PS
    ON B.PICKSLIP_ID = PS.PICKSLIP_ID
    LEFT OUTER JOIN CUST C ON 
    PS.CUSTOMER_ID = C.CUSTOMER_ID
  LEFT OUTER JOIN SHIP S
    ON PS.SHIPPING_ID = S.SHIPPING_ID
  LEFT OUTER JOIN edi_753_754_ps edips
    ON PS.PICKSLIP_ID = edips.PICKSLIP_ID
  LEFT OUTER JOIN PO
    ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
   AND PS.PO_ID = PO.PO_ID
   AND PS.ITERATION = PO.ITERATION
 WHERE PS.TRANSFER_DATE IS NULL
   AND PALLET_ID NOT LIKE 'P%'
   AND B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">:PO_ID</a></if>
   <if>AND PS.SHIPPING_ID = :SHIPPING_ID</if>
   <if>AND <a pre="PS.customer_id in(" sep="," post=")">:customer_id</a></if>
   <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
   <if>AND PS.CUSTOMER_STORE_ID = :customer_store_id</if>
   <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:BUCKET_ID)</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
       <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
<if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
 GROUP BY B.PALLET_ID,B.IA_ID,ps.warehouse_location_id, PS.CUSTOMER_ID
  </if>
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" PropertyName="Text" />
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="div2" visible="false">
                <i>Boxes On Temporary Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gv2" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds2" ShowExpandCollapseButtons="false" OnRowDataBound="gv2_RowDataBound"
                DefaultSortExpression="CUSTOMER_NAME;ia_id;WAREHOUSE_LOCATION_ID;$;">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                        <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name"
                        SortExpression="CUSTOMER_NAME" />
                    <eclipse:MultiBoundField DataFields="IA_ID" NullDisplayText="<b>Non Physical Boxes</b>"
                        HeaderText="Area" SortExpression="IA_ID" />
                    <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                        NullDisplayText="Unknown" SortExpression="warehouse_location_id" />
                    <eclipse:MultiBoundField DataFields="location_id" ItemStyle-Wrap="false" HeaderText="Location"
                        NullDisplayText="No Location" SortExpression="location_id" />
                    <eclipse:MultiBoundField DataFields="Total_Boxes" HeaderText="Total Boxes" HeaderStyle-Wrap="false"
                        SortExpression="Total_Boxes" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Label" HeaderStyle-Wrap="false" SortExpression="MIN_LABEL_ID">
                        <ItemTemplate>
                            <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LABEL_ID,MIN_LABEL_ID,MAX_LABEL_ID" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <eclipse:MultiBoundField DataFields="LOAD_ID" HeaderText="Load Id" SortExpression="LOAD_ID"
                        HeaderStyle-Wrap="false" />
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                        <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="user" ItemStyle-Wrap="false"
                        SortExpression="USER_NAME"  />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="Dc Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View runat="server">
            <oracle:OracleDataSource ID="ds3" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       B.IA_ID AS IA_ID,
       PS.CUSTOMER_ID AS CUSTOMER_ID,
       MAX(C.NAME) AS CUSTOMER_NAME,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(PS.SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT PS.SHIPPING_ID) AS COUNT_SHIPPING_ID,
       MAX(PS.BUCKET_ID) AS MAX_BUCKET,
       COUNT(DISTINCT PS.BUCKET_ID) AS COUNT_OF_BUCKETS,
       PS.PO_ID AS MAX_PO,
       MAX(PS.CUSTOMER_DC_ID) AS MAX_DC,
       COUNT(DISTINCT PS.CUSTOMER_DC_ID) AS COUNT_OF_DCS,
       MAX(B.MODIFIED_BY) KEEP (DENSE_RANK LAST ORDER BY b.date_modified) AS USER_NAME,
       COUNT(DISTINCT B.UCC128_ID) AS Total_Boxes
  FROM BOX B
 INNER JOIN BOXDET BD
    ON B.UCC128_ID = BD.UCC128_ID
   AND B.PICKSLIP_ID = BD.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_SKU MSKU
    ON BD.UPC_CODE = MSKU.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MS
    ON MSKU.STYLE = MS.STYLE
  LEFT OUTER JOIN PS
    ON B.PICKSLIP_ID = PS.PICKSLIP_ID
    LEFT OUTER JOIN CUST C ON 
    PS.CUSTOMER_ID = C.CUSTOMER_ID
  LEFT OUTER JOIN SHIP S
    ON PS.SHIPPING_ID = S.SHIPPING_ID
  LEFT OUTER JOIN edi_753_754_ps edips
    ON PS.PICKSLIP_ID = edips.PICKSLIP_ID
  LEFT OUTER JOIN PO
    ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
   AND PS.PO_ID = PO.PO_ID
   AND PS.ITERATION = PO.ITERATION
 WHERE PS.TRANSFER_DATE IS NULL
   AND PALLET_ID LIKE 'P%'
   AND B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
   <if>AND PS.SHIPPING_ID = :SHIPPING_ID</if>
   <if>AND <a pre="PS.customer_id in(" sep="," post=")">:customer_id</a></if>
   <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
   <if>AND PS.CUSTOMER_STORE_ID = :customer_store_id</if>
   <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:BUCKET_ID)</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
       <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
   <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
GROUP BY B.PALLET_ID,B.IA_ID,ps.warehouse_location_id, PS.PO_ID, PS.CUSTOMER_ID
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" PropertyName="Text" />
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="div3" visible="false">
                <i>Boxes On Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gvByPo" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds3" DefaultSortExpression="CUSTOMER_NAME;MAX_PO;$;" OnRowDataBound="gvByPo_RowDataBound">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                        <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name"
                        SortExpression="CUSTOMER_NAME" />
                    <eclipse:MultiBoundField DataFields="IA_ID" ItemStyle-Wrap="false" NullDisplayText="<b>Non Physical Boxes</b>"
                        HeaderText="Area" SortExpression="IA_ID" />
                    <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                        NullDisplayText="Unknown" SortExpression="warehouse_location_id" />
                    <eclipse:MultiBoundField DataFields="location_id" ItemStyle-Wrap="false" HeaderText="Location"
                        NullDisplayText="No Location" SortExpression="location_id" />
                    <eclipse:MultiBoundField DataFields="Total_Boxes" HeaderText="Total Boxes" HeaderStyle-Wrap="false"
                        SortExpression="Total_Boxes" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Label" HeaderStyle-Wrap="false" SortExpression="MIN_LABEL_ID">
                        <ItemTemplate>
                            <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LABEL_ID,MIN_LABEL_ID,MAX_LABEL_ID" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <eclipse:MultiBoundField DataFields="LOAD_ID" HeaderText="Load Id" SortExpression="LOAD_ID"
                        HeaderStyle-Wrap="false" />
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                        <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="user" ItemStyle-Wrap="false"
                        SortExpression="USER_NAME"  />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="Dc Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
            <oracle:OracleDataSource ID="ds4" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
         <if c="$customer_id">
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       B.IA_ID AS IA_ID,
       PS.CUSTOMER_ID AS CUSTOMER_ID,
       MAX(C.NAME) AS CUSTOMER_NAME,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(PS.SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT PS.SHIPPING_ID) AS COUNT_SHIPPING_ID,
       MAX(PS.BUCKET_ID) AS MAX_BUCKET,
       COUNT(DISTINCT PS.BUCKET_ID) AS COUNT_OF_BUCKETS,
       PS.PO_ID AS MAX_PO,
       MAX(PS.CUSTOMER_DC_ID) AS MAX_DC,
       COUNT(DISTINCT PS.CUSTOMER_DC_ID) AS COUNT_OF_DCS,
       MAX(B.MODIFIED_BY) KEEP (DENSE_RANK LAST ORDER BY b.date_modified) AS USER_NAME,
       COUNT(DISTINCT B.UCC128_ID) AS Total_Boxes
  FROM BOX B
 INNER JOIN BOXDET BD
    ON B.UCC128_ID = BD.UCC128_ID
   AND B.PICKSLIP_ID = BD.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_SKU MSKU
    ON BD.UPC_CODE = MSKU.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MS
    ON MSKU.STYLE = MS.STYLE
  LEFT OUTER JOIN PS
    ON B.PICKSLIP_ID = PS.PICKSLIP_ID
  LEFT OUTER JOIN CUST C ON 
    PS.CUSTOMER_ID = C.CUSTOMER_ID
  LEFT OUTER JOIN SHIP S
    ON PS.SHIPPING_ID = S.SHIPPING_ID
  LEFT OUTER JOIN edi_753_754_ps edips
    ON PS.PICKSLIP_ID = edips.PICKSLIP_ID
  LEFT OUTER JOIN PO
    ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
   AND PS.PO_ID = PO.PO_ID
   AND PS.ITERATION = PO.ITERATION
 WHERE PS.TRANSFER_DATE IS NULL
   AND PALLET_ID NOT LIKE 'P%'
   AND B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">:PO_ID</a></if>
   <if>AND PS.SHIPPING_ID = :SHIPPING_ID</if>
    <if>AND <a pre="PS.customer_id in(" sep="," post=")">:customer_id</a></if>
    <if>AND PS.WAREHOUSE_LOCATION_ID =:WAREHOUSE_LOCATION_ID</if>
   <if>AND PS.CUSTOMER_STORE_ID = :customer_store_id</if>
   <if>and <a pre="PS.BUCKET_ID IN (" sep="," post=")">(:BUCKET_ID)</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
       <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
<if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
 GROUP BY B.PALLET_ID,B.IA_ID,ps.warehouse_location_id,PS.PO_ID, PS.CUSTOMER_ID 
  </if>
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input" PropertyName="Text"/>
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="div4" visible="false">
                <i>Boxes On Temporary Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gvByPo1" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds4" ShowExpandCollapseButtons="false" OnRowDataBound="gvByPo1_RowDataBound"
                DefaultSortExpression="CUSTOMER_NAME;MAX_PO;$;">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                        <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name"
                        SortExpression="CUSTOMER_NAME" />
                    <eclipse:MultiBoundField DataFields="IA_ID" ItemStyle-Wrap="false" NullDisplayText="<b>Non Physical Boxes</b>"
                        HeaderText="Area" SortExpression="IA_ID" />
                    <eclipse:MultiBoundField DataFields="warehouse_location_id" HeaderText="Building"
                        NullDisplayText="Unknown" SortExpression="warehouse_location_id" />
                    <eclipse:MultiBoundField DataFields="location_id" ItemStyle-Wrap="false" HeaderText="Location"
                        NullDisplayText="No Location" SortExpression="location_id" />
                    <eclipse:MultiBoundField DataFields="Total_Boxes" HeaderText="Total Boxes" HeaderStyle-Wrap="false"
                        SortExpression="Total_Boxes" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:N0}"
                        DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Label" HeaderStyle-Wrap="false" SortExpression="MIN_LABEL_ID">
                        <ItemTemplate>
                            <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LABEL_ID,MIN_LABEL_ID,MAX_LABEL_ID" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <eclipse:MultiBoundField DataFields="LOAD_ID" HeaderText="Load Id" SortExpression="LOAD_ID"
                        HeaderStyle-Wrap="false" />
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                    <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="user" ItemStyle-Wrap="false"
                        SortExpression="USER_NAME"  />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="Dc Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

<%@ Page Title="Boxes of a customer in different areas" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7236 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_21.aspx $
 *  $Id: R110_21.aspx 7236 2014-11-07 09:27:07Z skumar $
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
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbPO.Text) &&
            string.IsNullOrEmpty(tbShipping.Text) && string.IsNullOrEmpty(tbWave.Text) &&
            string.IsNullOrEmpty(tbdc.Text) && string.IsNullOrEmpty(tbstore.Text)
            && string.IsNullOrEmpty(dtATSDate.Value) && string.IsNullOrEmpty(cbCanceldate.Value)
            && string.IsNullOrEmpty(tbappointment.Value) && string.IsNullOrEmpty(cbvas.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide value for at least one filter in 'Boxes of' Section.";
            return;
        }
    }

    protected void ds1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbPO.Text) &&
            string.IsNullOrEmpty(tbShipping.Text) && string.IsNullOrEmpty(tbWave.Text) &&
            string.IsNullOrEmpty(tbdc.Text) && string.IsNullOrEmpty(tbstore.Text)
            && string.IsNullOrEmpty(dtATSDate.Value) && string.IsNullOrEmpty(cbCanceldate.Value)
            && string.IsNullOrEmpty(tbappointment.Value) && string.IsNullOrEmpty(cbvas.Value))
        {
            e.Cancel = true;
        }
        return;
    }
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbPO.Text) &&
            string.IsNullOrEmpty(tbShipping.Text) && string.IsNullOrEmpty(tbWave.Text) &&
            string.IsNullOrEmpty(tbdc.Text) && string.IsNullOrEmpty(tbstore.Text)
            && string.IsNullOrEmpty(dtATSDate.Value) && string.IsNullOrEmpty(cbCanceldate.Value)
            && string.IsNullOrEmpty(tbappointment.Value) && string.IsNullOrEmpty(cbvas.Value))
        {
            e.Cancel = true;
        }
        return;
    }
    protected void ds3_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbPO.Text) &&
            string.IsNullOrEmpty(tbShipping.Text) && string.IsNullOrEmpty(tbWave.Text) &&
            string.IsNullOrEmpty(tbdc.Text) && string.IsNullOrEmpty(tbstore.Text)
            && string.IsNullOrEmpty(dtATSDate.Value) && string.IsNullOrEmpty(cbCanceldate.Value)
            && string.IsNullOrEmpty(tbappointment.Value) && string.IsNullOrEmpty(cbvas.Value))
        {
            e.Cancel = true;
        }
        return;
    }
    protected void ds4_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbPO.Text) &&
            string.IsNullOrEmpty(tbShipping.Text) && string.IsNullOrEmpty(tbWave.Text) &&
            string.IsNullOrEmpty(tbdc.Text) && string.IsNullOrEmpty(tbstore.Text)
            && string.IsNullOrEmpty(dtATSDate.Value) && string.IsNullOrEmpty(cbCanceldate.Value)
            && string.IsNullOrEmpty(tbappointment.Value) && string.IsNullOrEmpty(cbvas.Value))
        {
            e.Cancel = true;
        }
        return;
    }
    protected void ds2_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (string.IsNullOrEmpty(tbcustomer.Text) && string.IsNullOrEmpty(tbPO.Text) &&
            string.IsNullOrEmpty(tbShipping.Text) && string.IsNullOrEmpty(tbWave.Text) &&
            string.IsNullOrEmpty(tbdc.Text) && string.IsNullOrEmpty(tbstore.Text)
            && string.IsNullOrEmpty(dtATSDate.Value) && string.IsNullOrEmpty(cbCanceldate.Value)
            && string.IsNullOrEmpty(tbappointment.Value) && string.IsNullOrEmpty(cbvas.Value))
        {
            e.Cancel = true;
        }
        return;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report is for showing area wise palletized and non palletized boxes of a customer. This report can also be displayed with different combinations of the following 
    filters:- Purchase Order, Bill Of Lading, Customer DC, Customer Store, Building, ATS Date and DC Cancel Date. This report will not consider shipped orders." />
    <meta name="ReportId" content="110.21" />
    <meta name="Browsable" content="true" />
     <meta name="ChangeLog" content="Now report will show STO against a PO. This additional information will be displayed under a new column 'PO Attrib 1'." />
    <meta name="Version" content="$Id: R110_21.aspx 7236 2014-11-07 09:27:07Z skumar $" />
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
        #TCP {
            float: left;
            padding: 1em 0em 0.5em 0.5em;
        }

        #dv {
            float: left;
            font-size: 12px;
            padding: 1em 0em 0.5em 0.5em;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <fieldset>
                        <legend class="ui-widget-header">Boxes Of (Pass at least one filter)</legend>
                        <br />
                        <fieldset>
                            <legend></legend>
                            <eclipse:TwoColumnPanel ID="TCP" runat="server">
                                <eclipse:LeftLabel ID="LeftLabel5" Text="Customer" runat="server" />
                                <i:AutoComplete runat="server" ID="tbcustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                                    FriendlyName="Customer" QueryString="customer_id" ToolTip="The customers whose purchase order you are interested in."
                                    Delay="1000" Width="137" OnClientSelect="tbcustomer_OnClientSelect">
                                    <Validators>
                                        <i:Custom OnServerValidate="tbcustomer_OnServerValidate" />
                                    </Validators>
                                </i:AutoComplete>
                                <br />
                                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="Purchase Order" />
                                <i:TextBoxEx ID="tbPO" runat="server" QueryString="po_id" FriendlyName="Purchase Order" />
                                <br />
                                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text=" Bill Of Lading" />
                                <i:TextBoxEx ID="tbShipping" runat="server" QueryString="Shipping_Id" FriendlyName="Bill Of Lading" />
                                <br />
                                <eclipse:LeftLabel ID="Lbl" runat="server" Text="Wave" />
                                <i:TextBoxEx ID="tbWave" runat="server" QueryString="bucket_id">
                                </i:TextBoxEx>
                                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Customer DC" />
                                <i:TextBoxEx ID="tbdc" runat="server" QueryString="customer_dc_id" />
                                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Customer Store" />
                                <i:TextBoxEx ID="tbstore" runat="server" QueryString="customer_store_id" />

                            </eclipse:TwoColumnPanel>
                            <div id="dv">
                                You can pass multiple values
                                <br />
                                separated by comma for<br />
                            all filters in this section.</div>
                        </fieldset>
                        <br />
                        <eclipse:TwoColumnPanel runat="server">
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
                
                            <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Appointment ID" />
                            <i:TextBoxEx ID="tbappointment" runat="server" QueryString="appointment_id">
                                <Validators>
                                    <i:Value ValueType="Integer" ClientMessage="Appointment ID should be numeric" />
                                </Validators>
                            </i:TextBoxEx>
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
                        </eclipse:TwoColumnPanel>
                        <br />
                    </fieldset>
                    <br />
                </eclipse:LeftPanel>
               <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Building"/>
                <oracle:OracleDataSource ID="dsbuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsbuilding" FriendlyName="Building"
                    QueryString="building">
                </i:CheckBoxListEx>
                <br />
                Boxes of customer will be shown for open order in this building.
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
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        OnSelecting="ds1_Selecting">
        <SelectSql>
            WITH Q1 AS
 (SELECT NVL(CASE
               WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
                    PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL THEN
                'VAS'
               ELSE
                B.IA_ID
             END,
             'Non Physical Boxes') AS BOX_AREA_ID,
         EDIPS.LOAD_ID AS LOAD_ID,
         IA.PROCESS_FLOW_SEQUENCE AS PROCESS_FLOW_SEQUENCE,
         PS.CUSTOMER_ID || ' : ' || C.NAME AS NAME,
         PS.CUSTOMER_ID AS CUSTOMER_ID,
         PS.WAREHOUSE_LOCATION_ID AS BUILDING,
         MS.LABEL_ID AS LABEL_ID,
         B.UCC128_ID AS UCC128_ID
    FROM BOX B
   INNER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_SKU MSKU
      ON BD.UPC_CODE = MSKU.UPC_CODE
    LEFT OUTER JOIN MASTER_STYLE MS
      ON MSKU.STYLE = MS.STYLE
    LEFT OUTER JOIN IA IA
      ON B.IA_ID = IA.IA_ID
    LEFT OUTER JOIN PS
      ON B.PICKSLIP_ID = PS.PICKSLIP_ID
    LEFT OUTER JOIN CUST C
      ON PS.CUSTOMER_ID = C.CUSTOMER_ID
    LEFT OUTER JOIN EDI_753_754_PS EDIPS
      ON PS.PICKSLIP_ID = EDIPS.PICKSLIP_ID
    LEFT OUTER JOIN PS_VAS PV
      ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
    LEFT OUTER JOIN TAB_VAS TV
      ON PV.VAS_ID = TV.VAS_CODE
    LEFT OUTER JOIN PO
      ON PS.CUSTOMER_ID = PO.CUSTOMER_ID
     AND PS.PO_ID = PO.PO_ID
     AND PS.ITERATION = PO.ITERATION
    LEFT OUTER JOIN SHIP S
      ON PS.SHIPPING_ID = S.SHIPPING_ID
   WHERE PS.TRANSFER_DATE IS NULL
     AND B.PALLET_ID IS NULL
     AND B.STOP_PROCESS_DATE IS NULL
     AND BD.STOP_PROCESS_DATE IS NULL
     <if>and s.appointment_id = :appointment_id</if>
     <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
     <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
     <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
     <if>AND <a pre="PS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
     <if>AND <a pre="PS.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
     <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">:BUCKET_ID</a></if>
     <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
     <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
     <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE as DATE)</if>
     <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE as DATE) +1</if>
     <if c="$vas"> 
     and pv.vas_id is not null        
     <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
     </if>    
    )
SELECT Q.BOX_AREA_ID as BOX_AREA_ID,
       MAX(Q.LOAD_ID) as LOAD_ID,
       DECODE(Q.BOX_AREA_ID, 'VAS', 25, Q.PROCESS_FLOW_SEQUENCE) AS FLOW_SEQUENCE,
       MAX(Q.NAME) AS NAME,
       Q.CUSTOMER_ID AS CUSTOMER_ID,
       Q.BUILDING AS BUILDING,
       MIN(Q.LABEL_ID) AS MIN_LABEL_ID,
       MAX(Q.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT Q.LABEL_ID) AS COUNT_LABEL_ID,
       COUNT(DISTINCT Q.UCC128_ID) AS TOTAL_BOXES
  FROM Q1 Q
 GROUP BY DECODE(Q.BOX_AREA_ID, 'VAS', 25, Q.PROCESS_FLOW_SEQUENCE),
          Q.BOX_AREA_ID,
          Q.BUILDING,
          Q.CUSTOMER_ID
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input"
                PropertyName="Text" />
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
            <asp:ControlParameter ControlID="tbappointment" Name="appointment_id" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
            <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
        id="div1" visible="false">
        <i>Boxes Not On Pallet.</i>
    </div>
    <jquery:GridViewEx ID="gv1" runat="server" AutoGenerateColumns="false" AllowSorting="true"
        ShowFooter="true" DataSourceID="ds1" ShowExpandCollapseButtons="false" OnRowDataBound="gv1_RowDataBound"
        DefaultSortExpression="NAME;$;FLOW_SEQUENCE {0} NULLS FIRST">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="box_area_id" DataNavigateUrlFields="box_area_id,building,customer_id"
                HeaderText="Area" DataNavigateUrlFormatString="R110_105.aspx?box_area_id={0}&building={1}&customer_id={2}&BoxOnPallet=Y"
                SortExpression="box_area_id" AppliedFiltersControlID="ctlButtonBar$af" AccessibleHeaderText="boxArea">
            </eclipse:SiteHyperLinkField>
            <asp:TemplateField HeaderText="Label" HeaderStyle-Wrap="false" SortExpression="MIN_LABEL_ID">
                <ItemTemplate>
                    <eclipse:MultiValueLabel ID="MultiValueLabel1" runat="server" DataFields="COUNT_LABEL_ID,MIN_LABEL_ID,MAX_LABEL_ID" />
                </ItemTemplate>
            </asp:TemplateField>
            <eclipse:MultiBoundField DataFields="LOAD_ID" SortExpression="LOAD_ID" HeaderText="Load Id"
                ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="NAME" HeaderText="Name" SortExpression="NAME" />
            <eclipse:MultiBoundField DataFields="building" SortExpression="building"
                NullDisplayText="Unknown" HeaderText="Building" ItemStyle-HorizontalAlign="Right" />
            <eclipse:MultiBoundField DataFields="TOTAL_BOXES" HeaderText="Total Boxes" ItemStyle-HorizontalAlign="Right"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}"
                FooterStyle-HorizontalAlign="Right" />
        </Columns>
    </jquery:GridViewEx>
    <asp:MultiView runat="server" ID="mv" ActiveViewIndex="-1">
        <asp:View ID="View1" runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
                OnSelecting="ds_Selecting">
                <SelectSql>            
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL
           THEN
          'VAS'
         ELSE
          B.IA_ID
       END AS IA_ID,
       PS.CUSTOMER_ID ||' : '|| C.NAME AS CUSTOMER_NAME,
       RTRIM(SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION, (TV.DESCRIPTION || ', '), ''))),', ') AS VAS,
       CASE WHEN COUNT(UNIQUE PS.SALES_ORDER_ID) >1 THEN
       '*****'
       ELSE
       TO_CHAR(MAX(PS.SALES_ORDER_ID))
       END AS SALES_ORDER_ID,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(S.PARENT_SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT S.PARENT_SHIPPING_ID) AS COUNT_SHIPPING_ID,
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
  LEFT OUTER JOIN PS_VAS PV
    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
  LEFT OUTER JOIN tab_vas tv on
            pv.vas_id = tv.vas_CODE
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
    <if c="$vas"> 
    and pv.vas_id is not null        
    <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
    </if>
   AND B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
   <if>and s.appointment_id =:appointment_id</if>
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
   <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
   <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
   <if>AND <a pre="PS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <if>AND <a pre="PS.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
   <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">:BUCKET_ID</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
   <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
   <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
   <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
GROUP BY B.PALLET_ID,CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL
           THEN
          'VAS'
         ELSE
          B.IA_ID
       END, ps.warehouse_location_id, PS.CUSTOMER_ID ||' : '|| C.NAME
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input"
                        PropertyName="Text" />
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
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
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="divInfo" visible="false">
                <i>Boxes On Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds" DefaultSortExpression="CUSTOMER_NAME;IA_ID;warehouse_location_id;$;location_id;PALLET_ID"
                OnRowDataBound="gv_RowDataBound">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                    <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name" SortExpression="CUSTOMER_NAME" />
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
                    <eclipse:MultiBoundField DataFields="VAS" HeaderText="VAS" HeaderToolTip="Value Added Service" SortExpression="VAS"/>
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />

                     <eclipse:MultiBoundField DataFields="SALES_ORDER_ID" HeaderText="PO Attrib 1" ItemStyle-Wrap="false"
                        SortExpression="SALES_ORDER_ID" />
                    
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                    <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="Last Action Performed By"
                        ItemStyle-Wrap="false" SortExpression="USER_NAME" />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="DC Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
            <oracle:OracleDataSource ID="ds2" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
                OnSelecting="ds2_Selecting">
                <SelectSql>
       
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL
           THEN
          'VAS'
         ELSE
          B.IA_ID
       END AS IA_ID,
       PS.CUSTOMER_ID ||' : '|| C.NAME AS CUSTOMER_NAME,
       RTRIM(SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION, (TV.DESCRIPTION || ', '), ''))),', ') AS VAS,
       CASE WHEN COUNT(UNIQUE PS.SALES_ORDER_ID) >1 THEN
       '*****'
       ELSE
       TO_CHAR(MAX(PS.SALES_ORDER_ID))
       END AS SALES_ORDER_ID,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(S.PARENT_SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT S.PARENT_SHIPPING_ID) AS COUNT_SHIPPING_ID,
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
  LEFT OUTER JOIN PS_VAS PV
    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
  LEFT OUTER JOIN tab_vas tv on
            pv.vas_id = tv.vas_CODE
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
   <if c="$vas"> 
   and pv.vas_id is not null        
   <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
   </if>
   <if>and s.appointment_id =:appointment_id</if>
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">:PO_ID</a></if>
   <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
   <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
   <if>AND <a pre="PS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <if>AND <a pre="PS.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
   <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">:BUCKET_ID</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
       <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
<if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
 GROUP BY B.PALLET_ID,CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL
           THEN
          'VAS'
         ELSE
          B.IA_ID
       END,ps.warehouse_location_id,PS.CUSTOMER_ID ||' : '|| C.NAME

                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input"
                        PropertyName="Text" />
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
                    <asp:ControlParameter ControlID="tbappointment" Name="appointment_id" Type="String"
                        Direction="Input" />

                    <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
                    <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="div2" visible="false">
                <i>Boxes On Temporary Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gv2" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds2" ShowExpandCollapseButtons="false" OnRowDataBound="gv2_RowDataBound"
                DefaultSortExpression="CUSTOMER_NAME;ia_id;WAREHOUSE_LOCATION_ID;$;location_id;PALLET_ID">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                    <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name" SortExpression="CUSTOMER_NAME" />
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
                    <eclipse:MultiBoundField DataFields="VAS" HeaderText="VAS" SortExpression="VAS" HeaderToolTip="Value Added Service Required"/>
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="SALES_ORDER_ID" HeaderText="PO Attrib 1" ItemStyle-Wrap="false"
                        SortExpression="SALES_ORDER_ID" AccessibleHeaderText="SALES_ORDER_ID" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                    <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="Last Action Performed By"
                        ItemStyle-Wrap="false" SortExpression="USER_NAME" />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="DC Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View ID="View2" runat="server">
            <oracle:OracleDataSource ID="ds3" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
              OnSelecting="ds3_Selecting"  ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL
           THEN
          'VAS'
         ELSE
          B.IA_ID
       END AS IA_ID,
       PS.CUSTOMER_ID ||' : '|| C.NAME AS CUSTOMER_NAME,
       RTRIM(SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION, (TV.DESCRIPTION || ', '), ''))),', ') AS VAS,
       CASE WHEN COUNT(UNIQUE PS.SALES_ORDER_ID) >1 THEN
       '*****'
       ELSE
       TO_CHAR(MAX(PS.SALES_ORDER_ID))
       END AS SALES_ORDER_ID,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(S.PARENT_SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT S.PARENT_SHIPPING_ID) AS COUNT_SHIPPING_ID,
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
LEFT OUTER JOIN PS_VAS PV
    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
LEFT OUTER JOIN tab_vas tv on
            pv.vas_id = tv.vas_CODE
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
   <if c="$vas"> 
   and pv.vas_id is not null        
   <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
   </if>
   <if>and s.appointment_id =:appointment_id</if>
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">(:PO_ID)</a></if>
   <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
   <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
   <if>AND <a pre="PS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <if>AND <a pre="PS.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
   <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">(:BUCKET_ID)</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
       <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
   <if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
GROUP BY B.PALLET_ID,
         CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL  AND B.PALLET_ID IS NOT NULL
             THEN
          'VAS'
         ELSE
          B.IA_ID
       END, ps.warehouse_location_id, PS.PO_ID, PS.CUSTOMER_ID ||' : '|| C.NAME
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbWave" Name="BUCKET_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input"
                        PropertyName="Text" />
                    <asp:ControlParameter ControlID="tbstore" Name="customer_store_id" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="tbdc" Name="customer_dc_id" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="ctlWhLoc" Name="WAREHOUSE_LOCATION_ID" Type="String"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtATSDate" Name="ats_date" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="dtFrom" Name="FROM_DC_CANCEL_DATE" Type="DateTime"
                        Direction="Input" />
                    <asp:ControlParameter ControlID="dtTo" Name="TO_DC_CANCEL_DATE" Type="DateTime" Direction="Input" />
                    <asp:ControlParameter ControlID="tbappointment" Name="appointment_id" Type="String"
                        Direction="Input" />
                    <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
                    <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
            <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <br />
            <div style="padding: 1em 0em 1em 1em; font-style: normal; font-weight: bold" runat="server"
                id="div3" visible="false">
                <i>Boxes On Pallet.</i>
            </div>
            <jquery:GridViewEx ID="gvByPo" runat="server" AutoGenerateColumns="false" AllowSorting="true"
                ShowFooter="true" DataSourceID="ds3" DefaultSortExpression="CUSTOMER_NAME;MAX_PO;$;"
                OnRowDataBound="gvByPo_RowDataBound">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="PALLET_ID" HeaderText="Pallet" NullDisplayText="No Pallet"
                        SortExpression="PALLET_ID" />
                    <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name" SortExpression="CUSTOMER_NAME" />
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
                    <eclipse:MultiBoundField DataFields="VAS" HeaderText="VAS" SortExpression="VAS" HeaderToolTip="Value Added Service Required"/>
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="SALES_ORDER_ID" HeaderText="PO Attrib 1" ItemStyle-Wrap="false"
                        SortExpression="SALES_ORDER_ID" AccessibleHeaderText="SALES_ORDER_ID" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                    <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="Last Action Performed By"
                        ItemStyle-Wrap="false" SortExpression="USER_NAME" />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="DC Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
            <oracle:OracleDataSource ID="ds4" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
              OnSelecting="ds4_Selecting"  ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>       
SELECT B.PALLET_ID PALLET_ID,
       MAX(B.LOCATION_ID) AS LOCATION_ID,
       CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL  AND B.PALLET_ID IS NOT NULL
           THEN
          'VAS'
         ELSE
          B.IA_ID
       END AS IA_ID,
       PS.CUSTOMER_ID ||' : '|| C.NAME AS CUSTOMER_NAME,
       RTRIM(SYS.STRAGG(UNIQUE(NVL2(TV.DESCRIPTION, (TV.DESCRIPTION || ', '), ''))),', ') AS VAS,
       CASE WHEN COUNT(UNIQUE PS.SALES_ORDER_ID) >1 THEN
       '*****'
       ELSE
       TO_CHAR(MAX(PS.SALES_ORDER_ID))
       END AS SALES_ORDER_ID,
       PS.WAREHOUSE_LOCATION_ID AS WAREHOUSE_LOCATION_ID,
       MAX(S.SHIP_DATE) AS SHIP_DATE,
       MAX(PO.DC_CANCEL_DATE) AS DC_CANCEL_DATE,
       MAX(edips.LOAD_ID) AS LOAD_ID,
       MIN(MS.LABEL_ID) AS MIN_LABEL_ID,
       MAX(MS.LABEL_ID) AS MAX_LABEL_ID,
       COUNT(DISTINCT MS.LABEL_ID) AS COUNT_LABEL_ID,
       MAX(S.PARENT_SHIPPING_ID) AS MAX_SHIPPING_ID,
       COUNT(DISTINCT S.PARENT_SHIPPING_ID) AS COUNT_SHIPPING_ID,
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
   LEFT OUTER JOIN PS_VAS PV
    ON PS.PICKSLIP_ID = PV.PICKSLIP_ID
   LEFT OUTER JOIN tab_vas tv on
            pv.vas_id = tv.vas_CODE
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
   <if c="$vas"> 
   and pv.vas_id is not null        
   <if c="$vas_id !='vas'">and pv.vas_id =:vas_id</if>    
   </if>
   <if>and s.appointment_id =:appointment_id</if>
   <if>and <a pre="PS.PO_ID IN (" sep="," post=")">:PO_ID</a></if>
   <if>AND <a pre="S.PARENT_SHIPPING_ID IN (" sep="," post=")">:SHIPPING_ID</a></if>
   <if>AND <a pre="PS.customer_id IN (" sep="," post=")">:customer_id</a></if>
   <if>AND <a pre="PS.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   <if>AND <a pre="PS.customer_store_id IN (" sep="," post=")">:customer_store_id</a></if>
   <if>and <a pre="to_char(ps.bucket_id) IN (" sep="," post=")">(:BUCKET_ID)</a></if>
   <if>and <a pre="ps.customer_dc_id IN (" sep="," post=")">(:customer_dc_id) </a></if>
       <if>AND edips.ats_date &gt;=CAST(:ats_date AS DATE)</if>
     <if>AND edips.ats_date &lt;=CAST(:ats_date AS DATE) + 1</if>
   <if>AND PO.DC_CANCEL_DATE &gt;= CAST(:FROM_DC_CANCEL_DATE AS DATE) </if>
<if>AND PO.DC_CANCEL_DATE &lt; CAST(:TO_DC_CANCEL_DATE AS DATE) + 1</if>
 GROUP BY B.PALLET_ID,CASE
         WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND
              PV.VAS_ID IS NOT NULL AND B.PALLET_ID IS NOT NULL
            THEN
          'VAS'
         ELSE
          B.IA_ID
       END,ps.warehouse_location_id,PS.PO_ID, PS.CUSTOMER_ID ||' : '|| C.NAME
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbPO" Name="PO_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbShipping" Name="SHIPPING_ID" Type="String" Direction="Input" />
                    <asp:ControlParameter ControlID="tbcustomer" Name="customer_id" Type="String" Direction="Input"
                        PropertyName="Text" />
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
                    <asp:ControlParameter ControlID="tbappointment" Name="appointment_id" Type="String"
                        Direction="Input" />

                    <asp:ControlParameter ControlID="cbvas" Type="String" Direction="Input" Name="vas" />
                    <asp:ControlParameter ControlID="ddlvas" Type="String" Direction="Input" Name="vas_id" />
                    <asp:Parameter Direction="Input" Name="RedBoxArea" Type="String" DefaultValue="<%$ Appsettings:RedBoxArea %>" />
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
                    <eclipse:MultiBoundField DataFields="CUSTOMER_NAME" HeaderText="Name" SortExpression="CUSTOMER_NAME" />
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
                    <eclipse:MultiBoundField DataFields="VAS" HeaderText="VAS" SortExpression="VAS" HeaderToolTip="Value Added Service Required"/>
                    <eclipse:MultiBoundField DataFields="MAX_BUCKET" HeaderText="Wave" ItemStyle-Wrap="false"
                        SortExpression="MAX_BUCKET" AccessibleHeaderText="MAX_BUCKET" />
                    <eclipse:MultiBoundField DataFields="MAX_SHIPPING_ID" HeaderText="BOL" SortExpression="MAX_SHIPPING_ID"
                        AccessibleHeaderText="MAX_BOLS" />
                    <eclipse:MultiBoundField DataFields="MAX_PO" HeaderText="PO" ItemStyle-Wrap="false"
                        SortExpression="MAX_PO" AccessibleHeaderText="MAX_PO" ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="SALES_ORDER_ID" HeaderText="PO Attrib 1"  HeaderStyle-Wrap="false"
                        SortExpression="SALES_ORDER_ID" AccessibleHeaderText="SALES_ORDER_ID" />
                    <eclipse:MultiBoundField DataFields="MAX_DC" HeaderText="DC" ItemStyle-Wrap="false"
                        SortExpression="MAX_DC" AccessibleHeaderText="MAX_DC" />
                    <eclipse:MultiBoundField DataFields="USER_NAME" HeaderText="Last Action Performed By"
                        ItemStyle-Wrap="false" SortExpression="USER_NAME" />
                    <eclipse:MultiBoundField DataFields="SHIP_DATE" DataFormatString="{0:d}" HeaderText="Ship Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="SHIP_DATE" />
                    <eclipse:MultiBoundField DataFields="DC_CANCEL_DATE" DataFormatString="{0:d}" HeaderText="DC Cancel Date"
                        HeaderStyle-Wrap="false" ItemStyle-HorizontalAlign="Right" SortExpression="DC_CANCEL_DATE" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

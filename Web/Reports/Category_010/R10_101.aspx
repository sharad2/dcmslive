<%@ Page Title="Detail Of Customer" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Web.Services" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6160 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_010/R10_101.aspx $
 *  $Id: R10_101.aspx 6160 2013-09-21 09:28:03Z skumar $
 * Version Control Template Added.
 * Drill report is pending
 
 Feedback: DB
 1. % Dollars Shipped does not show sub total
 
--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        gv.DataBound += new EventHandler(gv_DataBound);
        base.OnInit(e);
    }

    /// <summary>
    /// For showing the footer value of pieces ordered, pieces shipped, pct pieces, dollars ordered, dollors shipped
    /// and pct dollars.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void gv_DataBound(object sender, EventArgs e)
    {
        decimal? piecesOrdered = null;
        decimal? piecesShipped = null;
        decimal? dollarsOrdered = null;
        decimal? dollarsShipped = null;
        foreach (MultiBoundField field in gv.Columns.OfType<MultiBoundField>().Where(p => p.SummaryValues != null))
        {
            switch (field.DataFields[0])
            {
                case "ORDERED_PIECES_TODAY":
                    piecesOrdered = field.SummaryValues[0];
                    lblTotalOrderedPieces.Text = string.Format("Total Ordered Pieces: <b>{0:N0}</b>", piecesOrdered);
                    break;

                case "SHIPPED_PIECES_TODAY":
                    piecesShipped = field.SummaryValues[0];
                    lblTotalShippedPieces.Text = string.Format("Total Shipped Pieces: <b>{0:N0}</b>", piecesShipped);
                    break;

                case "ORDERED_DOLLARS_TODAY":
                    dollarsOrdered = field.SummaryValues[0];
                    lblTotalDollarsOrdered.Text = string.Format("Total Dollars Ordered: <b>{0:C0}</b>", dollarsOrdered);
                    break;

                case "SHIPPED_DOLLARS_TODAY":
                    dollarsShipped = field.SummaryValues[0];
                    lblTotalDollarsShipped.Text = string.Format("Total Dollars Shipped: <b>{0:C0}</b>", dollarsShipped);
                    break;
            }

        }
        //Hide the summary infoamtion if the report is open directly.     
        GridViewEx grid = (GridViewEx)sender;

        if (grid.Rows.Count > 0)
        {
            Summary.Visible = true;
            lblTotalPctPieces.Text = string.Format("Total % Pieces Shipped: <b>{0:P2}</b>", piecesShipped / (piecesOrdered == 0 ? null : piecesOrdered));
            lblTotalPctDollars.Text = string.Format("Total % Dollars Shipped: <b>{0:P2}</b>", dollarsShipped / (dollarsOrdered == 0 ? null : dollarsOrdered));
        }
        else
        {
            Summary.Visible = false;
        }

    }
    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
            
        {
            var OrderedPieces = DataBinder.Eval(e.Row.DataItem, "ORDERED_PIECES_TODAY");
            if (OrderedPieces != DBNull.Value)
            {
                var OrderToday = Convert.ToInt32(OrderedPieces);
                if (OrderToday != 0)
                {
                    var PiecesShipped = DataBinder.Eval(e.Row.DataItem, "SHIPPED_PIECES_TODAY");
                    if (PiecesShipped != DBNull.Value)
                    {
                        var lbl = (Label)e.Row.FindControl("ShippedPercent");
                        lbl.Text = string.Format("{0:P2}", Convert.ToDouble(PiecesShipped) / OrderToday);
                    }
                }
            }
            var DollarsOrdered = DataBinder.Eval(e.Row.DataItem, "ORDERED_DOLLARS_TODAY");
            var DollarsShipped = DataBinder.Eval(e.Row.DataItem, "SHIPPED_DOLLARS_TODAY");
            if (DollarsOrdered != DBNull.Value)
            {
                var DollarsToday = Convert.ToInt32(DollarsOrdered);
                if (DollarsToday != 0)
                {
                  
                    if (DollarsShipped != DBNull.Value)
                    {
                        var DollarsValueShipped = Convert.ToInt32(DollarsShipped);
                        
                        var lbl = (Label)e.Row.FindControl("DollarsShippedPercent");
                        var test = Convert.ToDecimal(DollarsValueShipped) / Convert.ToDecimal(DollarsToday);
                        lbl.Text = string.Format("{0:P2}", test);
                    }
                    
                    
                }
            }
        } 
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
                select tct.customer_type as customer_type, tct.description as customer_description from tab_customer_type tct 
                where 1 = 1
                <if c='$keywords'>AND (tct.customer_type like '%' || CAST(:keywords as VARCHAR2(25)) || '%' or UPPER(tct.customer_type) like '%' || upper(CAST(:keywords as VARCHAR2(25))) || '%')</if>
                order by tct.description
                ";

            string[] tokens = term.Split(',');
            ds.SelectParameters.Add("keywords", TypeCode.String, tokens[tokens.Length - 1].Trim());

            items = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                     select new AutoCompleteItem()
                     {
                         Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_type"), DataBinder.Eval(cst, "customer_description")),
                         Value = DataBinder.Eval(cst, "customer_type", "{0}")
                     }).Take(20).ToArray();
        }
        return items;
    }

    [WebMethod]
    public static AutoCompleteItem ValidateCustomer(string term)
    {
        if (string.IsNullOrEmpty(term))
        {
            return null;
        }
        const string QUERY = @"

select tct.customer_type as customer_type, 
            tct.description as customer_description 
             from tab_customer_type tct 
             where 1 = 1
             <if>AND tct.customer_type =:customer_type</if>";
        OracleDataSource ds = new OracleDataSource(ConfigurationManager.ConnectionStrings["dcmslive"]);
        ds.SysContext.ModuleName = "CustomerValidator";
        ds.SelectParameters.Add("customer_type", TypeCode.String, string.Empty);
        try
        {
            ds.SelectSql = QUERY;
            if (term.Contains(":"))
            {
                term = term.Split(':')[0];
            }
            ds.SelectParameters["customer_type"].DefaultValue = term;
            AutoCompleteItem[] data = (from cst in ds.Select(DataSourceSelectArguments.Empty).Cast<object>()
                                       select new AutoCompleteItem()
                                       {
                                           Text = string.Format("{0}: {1}", DataBinder.Eval(cst, "customer_type"), DataBinder.Eval(cst, "customer_description")),
                                           Value = DataBinder.Eval(cst, "customer_type", "{0}")
                                       }).Take(5).ToArray();
            return data.Length > 0 ? data[0] : null;
        }
        finally
        {
            ds.Dispose();
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For a specified pickslip upload date,based on the customer type the report will get all the customer orders detail which have been shipped." />
    <meta name="ReportId" content="10.101" />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R10_101.aspx 6160 2013-09-21 09:28:03Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="tcpFilters" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel runat="server" />
                <d:StyleLabelSelector runat="server" ID="tblabel_id" ShowAll="true" QueryString="label_id"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" FriendlyName="Label" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel Text="Customer Type" runat="server" />
                <%-- <d:CustomerTypeSelector runat="server" ID="tbcust_type" QueryString="cust_type" ShowAll="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />--%>

                <i:AutoComplete runat="server" ID="tbCustomer" ClientIDMode="Static" WebMethod="GetCustomers"
                    FriendlyName="Specific Customers" AutoValidate="true" ValidateWebMethodName="ValidateCustomer" QueryString="cust_type" Delay="4000" ToolTip="The customers whose purchase order you are interested in." Width="200">
                </i:AutoComplete>

                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="For Date" />
                <d:BusinessDateTextBox ID="dtShipDate" runat="server" FriendlyName="For Date" QueryString="ship_date"
                    Text="0" ToolTip="Date on which the pieces shipped">
                    <Validators>
                        <i:Required />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <%--<uc:ButtonBar ID="ctlButtonBar" runat="server" />--%>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
        <SelectSql>
          <%--SELECT  ps.customer_order_id as po_id,
			    ps.ps_status_id as status_id,
			    decode(sum(ps.total_quantity_ordered),0,null,sum(ps.total_quantity_ordered)) as pieces_ordered,
			    decode(sum(ps.total_quantity_shipped),0,null,sum(ps.total_quantity_shipped)) as pieces_shipped,
			    ROUND(DECODE(sum(ps.total_dollars_ordered),0,NULL,sum(ps.total_dollars_ordered))) as dollars_ordered,
			    ROUND(decode(sum(ps.total_dollars_shipped),0,null,sum(ps.total_dollars_shipped))) as dollars_shipped,
			    cust.name as customer_name,
			    round(sum(ps.total_quantity_shipped)/ DECODE(sum(ps.total_quantity_ordered),0,1,sum(ps.total_quantity_ordered)),4)as pct_pieces_shp_ord,
			    round(sum(ps.total_dollars_shipped)/DECODE(sum(ps.total_dollars_ordered),0,1,sum(ps.total_dollars_ordered)),4)as pct_dollars_shp_ord
	       FROM dem_pickslip ps
           LEFT OUTER JOIN master_customer cust ON ps.customer_id = cust.customer_id
          WHERE PS.Ps_Status_Id = DECODE(PS.CANCEL_REASON_CODE, :cancel_reason_code, 10, 8)
          <if>AND cust.customer_type = cast(:customer_type as varchar2(255))</if>
	      <if>AND ps.vwh_id = cast(:vwh_id as varchar2(255))</if> 	       
	       AND ps.upload_date &gt;= CAST(:change_date as DATE) 
	       AND ps.upload_date &lt; CAST(:change_date as DATE) + 1
           <if>AND ps.pickslip_type = cast(:pickslip_type as varchar2(255))</if>	       
	     GROUP BY ps.customer_order_id,
		          ps.ps_status_id,
				  cust.NAME	--%>	


WITH ORDER_STATUS AS
 (SELECT ROW_NUMBER() OVER(PARTITION BY PS.PICKSLIP_ID ORDER BY 1) AS PS_SEQUENCE,
         PS.PICKSLIP_ID,
         PS.PO_ID,
         DECODE(PS.CANCEL_REASON_CODE,NULL,8,10) AS status_id,
         PS.TOTAL_QUANTITY_ORDERED,
         PS.TOTAL_DOLLARS_ORDERED,
         CUST.NAME,
         SUM(BD.CURRENT_PIECES) OVER(PARTITION BY PS.PICKSLIP_ID) AS SHIPPED_PIECES_TODAY,
         SUM(BD.CURRENT_PIECES * BD.EXTENDED_PRICE) OVER(PARTITION BY PS.PICKSLIP_ID) AS SHIPPED_DOLLARS_TODAY
    FROM PS
   LEFT OUTER JOIN BOX B
      ON PS.PICKSLIP_ID = B.PICKSLIP_ID
   LEFT OUTER JOIN BOXDET BD
      ON B.UCC128_ID = BD.UCC128_ID
     AND B.PICKSLIP_ID = BD.PICKSLIP_ID
    LEFT OUTER JOIN MASTER_CUSTOMER CUST
      ON PS.CUSTOMER_ID = CUST.CUSTOMER_ID
   WHERE 1=1
     <if>AND CUST.CUSTOMER_TYPE = cast(:customer_type as varchar2(255))</if>
     AND PS.TRANSFER_DATE &gt;= CAST(:change_date as DATE)
     AND PS.TRANSFER_DATE &lt; CAST(:change_date as DATE) + 1
     <if>AND PS.VWH_ID = cast(:vwh_id as varchar2(255))</if> 
     <if>AND PS.LABEL_ID = cast(:pickslip_type as varchar2(255))</if>   
            )
SELECT Q1.PO_ID,
       Q1.status_id,
       SUM(Q1.TOTAL_QUANTITY_ORDERED) AS ORDERED_PIECES_TODAY,
       SUM(Q1.TOTAL_DOLLARS_ORDERED) AS ORDERED_DOLLARS_TODAY,
       SUM(Q1.SHIPPED_PIECES_TODAY) AS SHIPPED_PIECES_TODAY,
       SUM(Q1.SHIPPED_DOLLARS_TODAY) AS SHIPPED_DOLLARS_TODAY,
       Q1.NAME AS CUSTOMER_NAME
  FROM ORDER_STATUS Q1
 WHERE Q1.PS_SEQUENCE = 1
 GROUP BY Q1.PO_ID, Q1.status_id, Q1.NAME



        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tblabel_id" Direction="Input" Type="String" Name="pickslip_type" />
            <asp:ControlParameter ControlID="tbCustomer" Direction="Input" Type="String" Name="customer_type" />
            <asp:ControlParameter ControlID="dtShipDate" Direction="Input" Type="DateTime" Name="change_date" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:Parameter Name="cancel_reason_code" Type="String" DefaultValue="<%$  AppSettings: CancelReasonCode  %>" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <div id="Summary" runat="server" class="ui-widget" visible="false">
        <br />
        <b>Summary</b>
        <table cellspacing="0" cellpadding="6" border="1em">
            <tr>
                <td>
                    <asp:Label runat="server" ID="lblTotalOrderedPieces" />
                </td>
                <td>
                    <asp:Label runat="server" ID="lblTotalShippedPieces" />
                </td>
                <td>
                    <asp:Label runat="server" ID="lblTotalPctPieces" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label runat="server" ID="lblTotalDollarsOrdered" />
                </td>
                <td>
                    <asp:Label runat="server" ID="lblTotalDollarsShipped" />
                </td>
                <td>
                    <asp:Label runat="server" ID="lblTotalPctDollars" />
                </td>
            </tr>
        </table>
        <br />
    </div>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" DataSourceID="ds"
        ShowFooter="true" DefaultSortExpression="customer_name;$;po_id;" OnRowDataBound="gv_RowDataBound" AllowSorting="true">
        <Columns>
            <eclipse:SequenceField FooterText="Total" />
            <asp:BoundField DataField="customer_name" HeaderText="Customer Name" SortExpression="customer_name" />
            <eclipse:MultiBoundField DataFields="po_id" HeaderText="PO" SortExpression="po_id"
                HeaderToolTip="Purchase Order ID of Customer">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="status_id" HeaderText="Status ID" SortExpression="status_id"
                HeaderToolTip="Status ID provided to the Customer">
                <ItemStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="ORDERED_PIECES_TODAY" SortExpression="ORDERED_PIECES_TODAY"
                HeaderText="Pieces|Ordered" HeaderToolTip="The number of pieces ordered by the customer"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHIPPED_PIECES_TODAY" SortExpression="SHIPPED_PIECES_TODAY"
                HeaderText="Pieces|Shipped" HeaderToolTip="The number of pieces shipped by the customer."
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <%--<eclipse:MultiBoundField DataFields="pct_pieces_shp_ord" SortExpression="pct_pieces_shp_ord"
                HeaderText="% Pieces Shipped" DataSummaryCalculation="ValueWeightedAverage" DataFormatString="{0:P2}"
                DataFooterFields="pieces_shipped,pieces_ordered" DataFooterFormatString="{0:P2}"
                HeaderToolTip="Percentage of total pieces Shipped.It is calculated by dividing PIECES_SHIPPED by PIECES_ORDERED and multiplying them with 100.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>--%>
            <asp:TemplateField HeaderText="% Pieces Shipped">
                <ItemTemplate>
                    <asp:Label ID="ShippedPercent" runat="server"></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </asp:TemplateField>

            <eclipse:MultiBoundField DataFields="ORDERED_DOLLARS_TODAY" SortExpression="ORDERED_DOLLARS_TODAY"
                HeaderText="Dollars|Ordered" HeaderToolTip="The number of dollars ordered by the customer"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:C2}" DataFooterFormatString="{0:C2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="SHIPPED_DOLLARS_TODAY" SortExpression="SHIPPED_DOLLARS_TODAY"
                HeaderText="Dollars|Shipped" HeaderToolTip="The number of dollars shipped by the customer"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:C2}" DataFooterFormatString="{0:C2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <%--<eclipse:MultiBoundField DataFields="pct_dollars_shp_ord" SortExpression="pct_dollars_shp_ord"
                HeaderText="% Dollars Shipped"   HeaderToolTip="Percentage of total dollars Shipped.It is calculated by dividing DOLLARS_SHIPPED by DOLLARS_ORDERED and multiplying them with 100."
                DataSummaryCalculation="ValueWeightedAverage" DataFooterFields="dollars_shipped,dollars_ordered"
                DataFormatString="{0:P2}" DataFooterFormatString="{0:P2}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>--%>
            <asp:TemplateField HeaderText="% Dollars Shipped">
                <ItemTemplate>
                    <asp:Label ID="DollarsShippedPercent" runat="server"></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </asp:TemplateField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Monthly Orders Report" %>

<%@ Import Namespace="System.Linq" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5661 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_010/R10_15.aspx $
 *  $Id: R10_15.aspx 5661 2013-07-17 05:40:13Z skumar $
 * Version Control Template Added.
--%>
<%--Adding custom columns to matrix field--%>
<script runat="server">
    
    // Adding one business column per business month
    void ds_PostSelected(object sender, PostSelectedEventArgs e)
    {
        if (e.Result != null)
        {
            EclipseLibrary.Web.UI.Matrix.MatrixField mf = gv.Columns.OfType<EclipseLibrary.Web.UI.Matrix.MatrixField>().Single();
            mf.DisplayColumns.CollectionChanged += new NotifyCollectionChangedEventHandler(DisplayColumns_CollectionChanged);
            foreach (var row in dsBusinessMonths.Select(DataSourceSelectArguments.Empty))
            {
                mf.DataHeaderValues.Add(new object[] { DataBinder.Eval(row, "month_start_date") });
            }
        }
    }

    /// <summary>
    /// Set the month in the header text based on the month start date
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void DisplayColumns_CollectionChanged(object sender, NotifyCollectionChangedEventArgs e)
    {
        switch (e.Action)
        {
            case NotifyCollectionChangedAction.Add:
                foreach (MatrixDisplayColumn dc in e.NewItems.Cast<MatrixDisplayColumn>()
                    .Where(p => p.MatrixColumn.ColumnType == MatrixColumnType.CellValue))
                {
                    if (dc.DataHeaderValue == DBNull.Value)
                    {
                        dc.MainHeaderText = "Null";
                    }
                    else
                    {
                        DateTime date = (DateTime)dc.DataHeaderValue;
                        int month = date.Month;
                        if (date.Day > 15)
                        {
                            ++month;
                        }
                        int year = date.Year;
                        if (month > 12)
                        {
                            month = 1;
                            ++year;
                        }
                     
                           dc.MainHeaderText =  string.Format("{0:MMM <br /> yyyy}", new DateTime(year, month, 1));
                        
                    }
                }
                break;
        }
        //EclipseLibrary.Web.UI.Matrix.MatrixField mf = gv.Columns.OfType<EclipseLibrary.Web.UI.Matrix.MatrixField>().Single();
        //mf.GroupByColumnHeaderText = true;
    }        
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report displays the monthly orders on the 
    basis of delivery date for the whole year with month begin as on FDC calendar. Now all information 
    will be shown for the selected calendar year. If there is any order for the last year in the system 
    then it will show the orders in the month of January. If there is any order for the future year in 
    the system then the orders will be shown in the month of December." />
    <meta name="ReportId" content="10.15" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R10_15.aspx 5661 2013-07-17 05:40:13Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="Tabs" Collapsible="true">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcp" runat="server">
                <eclipse:LeftLabel ID="LeftPanel1" runat="server" Text="Customer Types" />
                <i:TextBoxEx runat="server" ID="tbCustomerTypes" ClientIDMode="Static" Text="DOM"
                    CaseConversion="UpperCase">
                </i:TextBoxEx>
                <i:ButtonEx runat="server" Icon="Search" OnClientClick="function(e) {
                $('#dlgCustomerTypes').ajaxDialog('load');
                }" ToolTip="Click to choose customer type" />
                <br />
                To view label level details for some customer types, enter one or more customers
                in the textbox below or click on find button.
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Virtual Warehouse ID" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <jquery:Dialog runat="server" ID="dlgCustomerTypes" DialogStyle="Picker" Width="550"
        AutoOpen="false" ClientIDMode="Static" Title="Select Customer Types">
        <Ajax Url="~/PickersAndServices/CustomerTypePicker.aspx" OnAjaxDialogLoading="function(e) {
                    $(this).ajaxDialog('option', 'data', { customer_types: $('#tbCustomerTypes').val().toUpperCase() });
                    }" OnAjaxDialogClosing="function(event,ui){
            $('#tbCustomerTypes').textBoxEx('setval', ui.data);
            }" />
        <Buttons>
            <jquery:RemoteSubmitButton RemoteButtonSelector="#btnCtpOk" Text="Ok" />
            <jquery:CloseButton Text="Cancel" />
        </Buttons>
    </jquery:Dialog>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource runat="server" ID="dsBusinessMonths"  ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
<SelectSql>
select  t.month_number month_number, t.month_start_date
  from tab_fdc_calendar t
 where t.fiscal_year = extract(year from sysdate)
 order by t.month_start_date
</SelectSql> 
    </oracle:OracleDataSource>
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true"
        OnPostSelected="ds_PostSelected">
        <SelectSql>
WITH 
month_starts AS
(
SELECT min(t.month_start_date) AS YEAR_BEGIN_DATE,
       max(t.month_start_date) AS YEAR_END_DATE
  FROM tab_fdc_calendar t
 WHERE t.fiscal_year = extract(year from sysdate)
),

pickslip_info as
(
SELECT /*+index (ps PS_PDSTAT_FK_I) */LEAST(GREATEST(FDC.YEAR_BEGIN_DATE,
                      (SELECT S.MONTH_START_DATE
                         FROM TAB_FDC_CALENDAR S
                        WHERE ps.DELIVERY_DATE BETWEEN S.MONTH_START_DATE AND
                              S.MONTH_END_DATE)),
             FDC.YEAR_END_DATE) AS effective_MONTH_BEGIN_DATE,           
       ps.total_quantity_ordered AS TOTAL_QUANTITY_ORDERED,
       ps.total_dollars_ordered AS TOTAL_DOLLARS_ORDERED,
       ps.vwh_id AS VWH_ID,
       <if c="$extra_customer_types">
       CASE WHEN cust.customer_type IN (<a sep=','>:extra_customer_types</a>)
         THEN ps.pickslip_type
         else null
         END
       </if>
       <else>NULL</else>
       AS PICKSLIP_TYPE,       
       ps.delivery_date AS DELIVERY_DATE,
       custtype.description as custtype_description,
       cust.customer_type AS CUSTOMER_TYPE
  FROM dem_pickslip ps
  left outer join master_customer cust on cust.customer_id = ps.customer_id
  left outer join tab_customer_type custtype on custtype.customer_type =
                                                cust.customer_type
 cross join month_starts fdc
 WHERE ps.ps_status_id IN (1, 99)
 <if>AND ps.vwh_id = :vwh_id</if>
)
SELECT mon.effective_MONTH_BEGIN_DATE AS effective_MONTH_BEGIN_DATE,
       nvl(mon.CUSTOMER_TYPE,'No_Customer_Type') AS CUSTOMER_TYPE,
       mon.PICKSLIP_TYPE,
           nvl(MAX(mon.custtype_description), 'No Customer Type') || 
    nvl2(MAX(stylbl.description),' - '||MAX(stylbl.description),' ') AS pickslip_type_description,       
       MAX(mon.DELIVERY_DATE) AS max_DELIVERY_date,
       SUM(mon.TOTAL_QUANTITY_ORDERED) AS QUANTITY_ORDERED,
       SUM(mon.TOTAL_DOLLARS_ORDERED)/1000 AS DOLLARS_ORDERED,
       mon.VWH_ID AS VWH_ID
  FROM pickslip_info mon
  left outer join tab_style_label stylbl on stylbl.label_id =
                                            mon.pickslip_type                                             
 GROUP BY mon.effective_MONTH_BEGIN_DATE,
          mon.CUSTOMER_TYPE,
          mon.VWH_ID,
          mon.PICKSLIP_TYPE
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:ControlParameter Name="extra_customer_types" ControlID="tbCustomerTypes" Type="String" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" ShowFooter="true"
        AllowSorting="true" DefaultSortExpression="pickslip_type_description;VWH_ID"
        DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="pickslip_type_description" HeaderText="Item Type"
                SortExpression="pickslip_type_description" HeaderToolTip="Customer Type - Label Description" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
                HeaderToolTip="Virtual warehouse id" />
           <%-- <jquery:MatrixField DataHeaderFields="effective_MONTH_BEGIN_DATE" DataHeaderFormatString="{0:MMM yyyy}"
                DataValueFormatString="{0:N0} <br /> {1:C0}" DataValueFields="QUANTITY_ORDERED,DOLLARS_ORDERED"
                HeaderText="Pcs / $(in Thousands)" DisplayColumnTotals="true" DisplayRowTotals="true"
                DataMergeFields="pickslip_type_description,VWH_ID">
                <ItemTemplate>
                    <div style="min-height: 1em">
                        <%# MatrixBinder.Eval("QUANTITY_ORDERED", "{0:N0}")%>
                    </div>
                    <div style="min-height: 1em">
                        <%# MatrixBinder.Eval("DOLLARS_ORDERED", "{0:C0}")%>
                    </div>
                </ItemTemplate>
            </jquery:MatrixField>--%>
            <m:MatrixField DataMergeFields="pickslip_type_description,VWH_ID" DataHeaderFields="effective_MONTH_BEGIN_DATE"
                DataCellFields="QUANTITY_ORDERED,DOLLARS_ORDERED" HeaderText="{0:MMM <br /> yyyy}" SortExpression="{0:u}" GroupByColumnHeaderText="true">
                <MatrixColumns>
                    
                    <m:MatrixColumn ColumnType="CellValue"  DataHeaderFormatString="Pcs / $(in Thousands)" DataCellFormatString="{0:N0} <br /> {1:C0}" DisplayColumnTotal="true">
                    
                    </m:MatrixColumn>
                    <m:MatrixColumn ColumnType="RowTotal" DataCellFormatString="{0:N0} <br /> {1:C0}" DisplayColumnTotal="true">
                    
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

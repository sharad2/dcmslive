﻿<%@ Page Title="In Process Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7066 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_110/R110_07.aspx $
 *  $Id: R110_07.aspx 7066 2014-07-19 11:58:58Z skumar $
 * Version Control Template Added.
--%>
<script runat="server">
    /// <summary>
    /// To calculate the % packed pieces verses ordered pieces i.e. 
    /// Packed pieces * 100 / ((Unstarted Pieces + Started  Pieces) - Cancelled Pieces)
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>

    protected override void OnUnload(EventArgs e)
    {
        base.OnUnload(e);
    }
    protected void gv_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        decimal pctPieces = 0;
        int expectedPieces;
        int? packedPieces;
        int canPieces;
        int unstartedPieces;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            expectedPieces = DataBinder.Eval(e.Row.DataItem, "started_pieces") != DBNull.Value ?
                Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "started_pieces")) : 0;

            packedPieces = DataBinder.Eval(e.Row.DataItem, "current_pieces") != DBNull.Value ?
                Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "current_pieces")) : 0;

            canPieces = DataBinder.Eval(e.Row.DataItem, "can_pieces") != DBNull.Value ?
                Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "can_pieces")) : 0;

            unstartedPieces = DataBinder.Eval(e.Row.DataItem, "unstarted_pieces") != DBNull.Value ?
                Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "unstarted_pieces")) : 0;

            int? piecesProgress = (expectedPieces + unstartedPieces) - canPieces;

            if (piecesProgress > 0)
            {
                pctPieces = Convert.ToDecimal(packedPieces) / Convert.ToDecimal(piecesProgress);
            }
            else
            {
                if (packedPieces != null)
                {
                    pctPieces = Convert.ToDecimal(packedPieces);
                }
            }



            Label lblPctCompleted = (Label)e.Row.FindControl("lblPctCompleted");
            lblPctCompleted.Text = string.Format("{0:P2}", pctPieces);
            lblPctCompleted.ToolTip = string.Format("{0:N0} Current Pieces / ({1:N0} Unstarted Pieces + {2:N0} Started Pieces - {3:N0} Can Pieces = {4:N0} Total ordered Pieces) = {5:P2}",
                    packedPieces, unstartedPieces, expectedPieces, canPieces, piecesProgress, pctPieces);
        }
    }
  
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="
     This report displays the number of boxes in different areas for each customer and virtual warehouse. It shows the un-started pieces, expected pieces, packed pieces, and cancelled pieces of all un-transferred and un-cancelled customer orders for each customer and virtual warehouse. It also shows progress of order (% packed pieces verses ordered pieces) for each customer and virtual warehouse. " />
    <meta name="ReportId" content="110.07" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Now report will show VAS area boxes along with number of pieces in VAS area.|Added VAS filter." />
    <meta name="Version" content="$Id: R110_07.aspx 7066 2014-07-19 11:58:58Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="lblCustomer" runat="server" Text="Customer ID" />
                <i:TextBoxEx runat="server" ID="tbCustomer" QueryString="customer_id" ToolTip="Customer ID which you want to see the information" />
                <eclipse:LeftLabel ID="lblPo" runat="server" Text="PO" />
                <i:TextBoxEx runat="server" ID="tbPo" QueryString="po_id" ToolTip="Customer Purchase Order" />
                <eclipse:LeftLabel ID="lblPickslip" runat="server" Text="Pickslip" />
                <i:TextBoxEx ID="tbPickslip" runat="server"  QueryString="pickslip_id" ToolTip="Pickslip ID for Purchase Order">
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" />
                <d:StyleLabelSelector ID="lsLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true"
                    FriendlyName="Label" QueryString="label_id" ToolTip="Select any label to see the order">
                </d:StyleLabelSelector>
                <eclipse:LeftLabel ID="lblBucket" runat="server" Text="Bucket" />
                <i:TextBoxEx ID="tbBucket" runat="server" QueryString="bucket_id" MaxLength="5" ToolTip="Bucket ID which you want to see the information">
                    <Validators>
                        <i:Value ValueType="Integer" ClientMessage="Bucket should be numeric only" />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="lblNoDays" runat="server" Text="Pickslip import days from today" />
                <i:TextBoxEx ID="tbNoDays" runat="server" QueryString="no_of_days" Text="60" ToolTip="Pass the number of days. Report will show the information from the days passed till today. By default 60 no. of days">
                    <Validators>
                        <i:Value Min="1" Max="90" ValueType="Integer" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                (1 to 90)
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlvwh_id" runat="server" ShowAll="true" ToolTip="Select any virtual warehouse to see the information"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                <eclipse:LeftLabel ID="LeftLabel" runat="server" />
                <i:CheckBoxEx ID="cbVAS" runat="server" QueryString="vas_id" FriendlyName="Exclusive VAS"
                    CheckedValue="VASID" />
                 </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ctlButtonBar" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" DataSourceMode="DataReader">
        <SelectSql>
         WITH order_info AS
        (
        SELECT ps.customer_id AS customer_id,
               ps.vwh_id AS vwh_id,
               NULL AS ia_id,
               NULL AS VAS_PIECES,
               NULL AS no_of_box,
               null AS current_pieces,
               null AS can_pieces,
               NULL AS process_flow_sequence,
               SUM(CASE
                     WHEN bkt.available_for_pitching = 'Y' THEN
                      ps.Total_Quantity_Ordered
                   END) AS started_pieces,
               SUM(CASE
                     WHEN bkt.available_for_pitching IS NULL THEN
                      ps.Total_Quantity_Ordered
                   END) AS unstarted_pieces
          FROM rep_active_ps ps
          LEFT OUTER JOIN bucket bkt ON ps.bucket_id = bkt.bucket_id
         WHERE ps.pickslip_import_date &gt;= SYSDATE - cast(:no_of_days as number)
           AND ps.pickslip_import_date &lt; SYSDATE + 1
           <if>AND ps.customer_id= cast(:customer_id as varchar2(255))</if>
           <if>AND ps.po_id= cast(:po_id as varchar2(255))</if>
           <if>AND ps.pickslip_id= :pickslip_id</if>
           <if>AND ps.label_id= cast(:label_id as varchar2(255))</if>
           <if>AND ps.bucket_id= cast(:bucket_id as number)</if>
           <if>AND ps.vwh_id= cast(:vwh_id as varchar2(255))</if>
              <if c="$VASID" >AND PS.PICKSLIP_ID IN (
               SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
               )</if>
         GROUP BY ps.customer_id,
                  ps.vwh_id
        UNION
        SELECT ps.customer_id AS customer_id,
               ps.vwh_id AS vwh_id,
               CASE
               WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND B.STOP_PROCESS_DATE IS NULL AND
                   PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV) AND
                   B.PALLET_ID IS NOT NULL THEN
               'VAS'
               ELSE
               B.IA_ID
               END AS IA_ID,
               SUM(CASE
               WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND B.STOP_PROCESS_DATE IS NULL AND
                    PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV) AND
                    B.PALLET_ID IS NOT NULL THEN
                BD.CURRENT_PIECES
               END) AS VAS_PIECES,
               COUNT(DISTINCT b.ucc128_id) AS no_of_box,
               SUM(CASE
                     WHEN i.shipping_area_flag = 'Y' THEN
                      bd.current_pieces
                   END) AS current_pieces,
               SUM(CASE
                     WHEN i.ia_id = (SELECT icg.ia_id
                                     FROM iaconfig icg
                                    WHERE icg.iaconfig_id = '$CANCEL') THEN
                      bd.current_pieces
                   END) AS can_pieces,
               MAX(i.process_flow_sequence) AS process_flow_sequence,
               null AS started_pieces,
               null AS UNSTARTED_PIECES
          FROM ps
         INNER JOIN box b ON ps.pickslip_id = b.pickslip_id
         INNER JOIN boxdet bd ON b.pickslip_id = bd.pickslip_id
                          AND b.ucc128_id = bd.ucc128_id
          LEFT OUTER JOIN ia i ON i.ia_id = b.ia_id
         WHERE ps.transfer_date is null
           AND PS.PICKSLIP_IMPORT_DATE &gt;= SYSDATE - cast(:no_of_days as number)
           AND PS.PICKSLIP_IMPORT_DATE &lt; SYSDATE + 1
           <if>AND ps.customer_id= cast(:customer_id as varchar2(255))</if>
           <if>AND ps.po_id= cast(:po_id as varchar2(255))</if>
           <if>AND ps.pickslip_id= :pickslip_id</if>
           <if>AND ps.label_id= cast(:label_id as varchar2(255))</if>
           <if>AND ps.bucket_id= cast(:bucket_id as number)</if>
           <if>AND ps.vwh_id= cast(:vwh_id as varchar2(255))</if>
              <if c="$VASID" >AND PS.PICKSLIP_ID IN (
               SELECT PV.PICKSLIP_ID FROM PS_VAS PV 
               )</if>
         GROUP BY ps.customer_id,
                  ps.vwh_id,
                  CASE
                  WHEN B.PITCHING_END_DATE IS NOT NULL AND B.VERIFY_DATE IS NULL AND B.STOP_PROCESS_DATE IS NULL AND
                   PS.PICKSLIP_ID IN (SELECT PV.PICKSLIP_ID FROM PS_VAS PV) AND
                   B.PALLET_ID IS NOT NULL THEN
                  'VAS'
                  ELSE
                 B.IA_ID
                END                  
        )
        SELECT DISTINCT oi.customer_id AS customer_id,
                        oi.vwh_id AS vwh_id,
                        CASE
                          WHEN oi.ia_id IS NULL THEN
                           'EB'
                          ELSE
                           oi.IA_ID
                        END AS box_ia_id,
                        CASE
                          WHEN oi.IA_ID IS NULL THEN
                           'Expeditor Bucket'
                          ELSE
                           oi.IA_ID
                        END AS SHORT_DESCRIPTION,
                        SUM(oi.no_of_box) over(PARTITION BY oi.customer_id, oi.vwh_id, oi.IA_ID) AS no_of_box,
                        SUM(oi.current_pieces) over(PARTITION BY oi.customer_id, oi.vwh_id) AS current_pieces,
                        SUM(oi.can_pieces) over(PARTITION BY oi.customer_id, oi.vwh_id) AS can_pieces,
                        SUM(OI.VAS_PIECES) OVER(PARTITION BY OI.CUSTOMER_ID, OI.VWH_ID) AS VAS_PIECES,
                        CASE
                          WHEN oi.ia_id IS NULL THEN
                           -100
                          ELSE
                           oi.process_flow_sequence
                        END AS process_flow_sequence,
                        SUM(oi.started_pieces) over(PARTITION BY oi.customer_id, oi.vwh_id) AS started_pieces,
                        SUM(oi.unstarted_pieces) over(PARTITION BY oi.customer_id, oi.vwh_id) AS unstarted_pieces,
                        (oi.customer_id ||':  '||CUST.NAME) AS CUSTOMER_NAME
          FROM order_info oi
          LEFT OUTER JOIN cust cust ON cust.customer_id = oi.customer_id
        </SelectSql>
        <SysContext ClientInfo="" ModuleName="" Action="" ContextPackageName="" ProcedureFormatString="set_{0}(A{0} =&gt; :{0}, client_id =&gt; :client_id)">
        </SysContext>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbPo" Type="String" Direction="Input" Name="po_id" />
            <asp:ControlParameter ControlID="tbpickslip" Type="String" Direction="Input" Name="pickslip_id" />
            <asp:ControlParameter ControlID="tbCustomer" Type="String" Direction="Input" Name="customer_id" />
            <asp:ControlParameter ControlID="lsLabel" Type="String" Direction="Input" Name="label_id" />
            <asp:ControlParameter ControlID="tbBucket" Type="Int32" Direction="Input" Name="bucket_id" />
            <asp:ControlParameter ControlID="tbNoDays" Type="Int32" Direction="Input" Name="no_of_days" />
            <asp:ControlParameter ControlID="ctlvwh_id" Type="String" Direction="Input" Name="vwh_id" />
             <asp:ControlParameter ControlID="cbVAS" Type="String" Direction="Input" Name="VASID" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AllowSorting="false" DataSourceID="ds" AutoGenerateColumns="false"
        DefaultSortExpression="customer_name;" ShowFooter="true" OnRowDataBound="gv_OnRowDataBound">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:SiteHyperLinkField DataTextField="customer_name" HeaderText="Customer" 
                AppliedFiltersControlID="ctlButtonBar$af" SortExpression="customer_name" DataNavigateUrlFields="customer_id,vwh_id"
                DataNavigateUrlFormatString="R110_113.aspx?&customer_id={0}&vwh_id={1}"  />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id" />
            <m:MatrixField DataMergeFields="customer_id,vwh_id" DataHeaderFields="short_description"
                DataCellFields="no_of_box, box_ia_id,VWH_ID" HeaderText="No. Of Boxes">
                <MatrixColumns>
                    <m:MatrixColumn ColumnType="CellValue" DisplayColumnTotal="true" ColumnTotalFormatString="{0:N0}">
                        <ItemTemplate>
                            <eclipse:SiteHyperLink ID="SiteHyperLink" runat="server" SiteMapKey="R110_114.aspx"
                                Text='<%# Eval("no_of_box", "{0:N0}")%>' NavigateUrl='<%# string.Format("customer_id={0}&po_id={1}&pickslip_id={2}&label_id={3}&bucket_id={4}&no_of_days={5}&box_ia_id={6}&vwh_id={7}&vas_id={8}",Eval("customer_id"),tbPo.Text,tbPickslip.Text,lsLabel.Value,tbBucket.Text,tbNoDays.Text, Eval("box_ia_id"),Eval("VWH_ID"),cbVAS.Value)%>'>
                            </eclipse:SiteHyperLink>
                        </ItemTemplate>
                    </m:MatrixColumn>
                </MatrixColumns>
            </m:MatrixField>
            <eclipse:MultiBoundField DataFields="unstarted_pieces" HeaderText="Pieces |Unstarted"
                SortExpression="unstarted_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="started_pieces" HeaderText="Pieces |Expected"
                SortExpression="started_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="current_pieces" HeaderText="Pieces |Packed"
                SortExpression="current_pieces" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="VAS_PIECES" HeaderText="Pieces |In VAS"
                SortExpression="VAS_PIECES" DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="can_pieces" HeaderText="Pieces |Cancelled" SortExpression="can_pieces"
                DataFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <asp:TemplateField HeaderText="%Completed" Visible="true">
                <ItemStyle HorizontalAlign="Right" />
                <ItemTemplate>
                    <asp:Label runat="server" ID="lblPctCompleted" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

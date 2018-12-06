<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="% Fill by Carton Area" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5671 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_11.aspx $
 *  $Id: R130_11.aspx 5671 2013-07-17 09:44:41Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="This report displays the count of cartons per area per virtual warehouse,quality and building. Also displays the percentage of occupied space of these areas which includes the suspense carton as well.  " />
    <meta name="ReportId" content="130.11" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_11.aspx 5671 2013-07-17 09:44:41Z skumar $" />
    <meta name="ChangeLog" content="Showing areas along with their building.|Replaced building filter dropdown with checkbox list." />
    
 <script type="text/javascript">
     $(document).ready(function () {
         if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

             //Do nothing if any of checkbox is checked
         }
         else {
             $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
         }
     });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector runat="server" ID="ctlVwh_id" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
                 </eclipse:TwoColumnPanel>
             <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Building" />
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
                        QueryString="warehouse_location_id">
                    </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>

            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
          <SelectSql>
                  WITH percent_fill AS ( 
SELECT /*+index (MS STLOC_PK)*/
 SRC_CARTON.VWH_ID AS VWH_ID,
 SRC_CARTON.CARTON_STORAGE_AREA AS CARTON_STORAGE_AREA,
 SRC_CARTON.QUALITY_CODE AS QUALITY_CODE,
 MAX(TIA.SHORT_NAME) AS SHORT_NAME,
 COUNT(DISTINCT SRC_CARTON.CARTON_ID) AS NUMBER_OF_CARTONS,
 COALESCE(TIA.WAREHOUSE_LOCATION_ID, MS.WAREHOUSE_LOCATION_ID, 'Unknown') AS Warehouse_Location_Id,
 MAX(W.QTY_WAREHOUSE_LOC) AS LOCATION_CAPACITY
  FROM SRC_CARTON SRC_CARTON
  LEFT OUTER JOIN MASTER_STORAGE_LOCATION MS ON SRC_CARTON.CARTON_STORAGE_AREA =
                                                MS.STORAGE_AREA
                                            AND SRC_CARTON.LOCATION_ID =
                                                MS.LOCATION_ID
   LEFT OUTER JOIN TAB_INVENTORY_AREA TIA  ON 
    SRC_CARTON.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
  LEFT OUTER JOIN TAB_WAREHOUSE_LOCATION W ON MS.Warehouse_Location_Id =
                                              W.WAREHOUSE_LOCATION_ID
 WHERE TIA.STORES_WHAT ='CTN'
 <if>AND SRC_CARTON.VWH_ID = :vwh_id</if>
      <%-- <if>AND MS.Warehouse_Location_Id = :Warehouse_Location_Id</if> --%> 
               <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, MS.WAREHOUSE_LOCATION_ID, 'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
       
 GROUP BY SRC_CARTON.VWH_ID,
          SRC_CARTON.CARTON_STORAGE_AREA,
          SRC_CARTON.QUALITY_CODE,
          COALESCE(TIA.WAREHOUSE_LOCATION_ID, MS.WAREHOUSE_LOCATION_ID, 'Unknown'))
  SELECT PERCENT_FILL.*,
         ROUND((SUM(PERCENT_FILL.NUMBER_OF_CARTONS)
                OVER(PARTITION BY PERCENT_FILL.Warehouse_Location_Id,
                     PERCENT_FILL.CARTON_STORAGE_AREA) /
                PERCENT_FILL.LOCATION_CAPACITY) * 100,
               2) AS PERCENTAGE_FILL,
         ROUND(((SUM(PERCENT_FILL.NUMBER_OF_CARTONS) OVER()) /
               (SELECT SUM(W.QTY_WAREHOUSE_LOC)
                   FROM TAB_WAREHOUSE_LOCATION W
                  WHERE W.WAREHOUSE_LOCATION_ID IN
                        (SELECT PERCENT_FILL.Warehouse_Location_Id FROM PERCENT_FILL))) * 100,
               2) AS PERCENT_AGGR
    FROM PERCENT_FILL
          </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh_id" Name="vwh_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhLoc" Name="Warehouse_Location_Id" Type="String" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" DataSourceID="ds" ShowFooter="true" AutoGenerateColumns="false"
        ID="gv" Caption="Total number of cartons and area occupied by them in FDC" AllowSorting="true"
        DefaultSortExpression="Warehouse_Location_Id {0} NULLS FIRST;$;SHORT_NAME" DefaultSortDirection="Ascending">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="Warehouse_Location_Id" HeaderText="Building"
                HeaderToolTip="Location of cartons in warehouse" SortExpression="Warehouse_Location_Id {0} NULLS FIRST" />
            <eclipse:MultiBoundField DataFields="SHORT_NAME" HeaderText="Area" SortExpression="SHORT_NAME"
                HeaderToolTip="Inventory area." />
            <eclipse:MultiBoundField DataFields="QUALITY_CODE" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="QUality Code" />
            <eclipse:MultiBoundField DataFields="VWH_ID" HeaderText="VWh" SortExpression="VWH_ID"
                HeaderToolTip="Virtual Warehouse" />
            <eclipse:SiteHyperLinkField DataTextField="NUMBER_OF_CARTONS" HeaderText="# Cartons"
                SortExpression="NUMBER_OF_CARTONS" DataSummaryCalculation="ValueSummation" DataNavigateUrlFormatString="R130_101.aspx?&Warehouse_Location_Id={0}&carton_storage_area={1}&VWH_ID={2}&quality_code={3}"
                DataNavigateUrlFields="Warehouse_Location_Id,carton_storage_area,VWH_ID,quality_code" HeaderToolTip="Count of all cartons,including carton in suspense."
                DataTextFormatString="{0:N0}" FooterToolTip="Total number of cartons in all areas">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="PERCENTAGE_FILL" SortExpression="PERCENTAGE_FILL"
                HeaderText="% Full" HeaderToolTip="What percentage of the DC carton space is being used by each area/warehouse."
                ToolTipFields="NUMBER_OF_CARTONS" ToolTipFormatString="Cartons at warehouse & area / Warehouse location capacity">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
    <br />
</asp:Content>

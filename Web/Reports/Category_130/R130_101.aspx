<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="% Fill by Carton Area" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5424 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_101.aspx $
 *  $Id: R130_101.aspx 5424 2013-06-12 07:17:13Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.101" />
    <meta name="Description" content="This report displays the total number of cartons and pieces in it for each 
                                        label and warehouse in a specified area " />
    <meta name="Browsable" content="false" />
    <meta name="Version" content="$Id: R130_101.aspx 5424 2013-06-12 07:17:13Z skumar $" />
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
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" Text="Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="carton_storage_area"
                    ShowAll="true">
                </d:InventoryAreaSelector>
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwhId" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" ShowAll="true" />
                <eclipse:LeftLabel runat="server" Text="Quality Code" />
                <i:TextBoxEx runat="server" ID="tbQualityCode" QueryString="quality_code" ToolTip="Please enter the Quality Code" />
            </eclipse:TwoColumnPanel>
            <asp:Panel ID="Panel1" runat="server">
                <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Building" />
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
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
        
 SELECT COUNT(DISTINCT src_carton.CARTON_ID) AS no_of_carton,
       SUM(SRC_CARTON_DETAIL.QUANTITY) AS no_of_pieces,
       MASTER_STYLE.LABEL_ID AS label_id,
       src_carton.vwh_id as vwh_id,
       src_carton.quality_code as quality_code
  FROM src_carton src_carton
  left outer join src_carton_detail src_carton_detail on
   src_carton.carton_id = src_carton_detail.carton_id
  LEFT OUTER JOIN MASTER_SKU  MSKU ON
    SRC_CARTON_DETAIL.SKU_ID = MSKU.SKU_ID
  LEFT OUTER JOIN MASTER_STYLE MASTER_STYLE
    ON MSKU.STYLE = MASTER_STYLE.STYLE
  left outer join master_storage_location ms on
   src_carton.carton_storage_area = ms.storage_area
     AND src_carton.location_id = ms.location_id
  LEFT OUTER JOIN TAB_INVENTORY_AREA TIA  ON 
    SRC_CARTON.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
 WHERE TIA.STORES_WHAT ='CTN'
 <if>AND src_carton.CARTON_STORAGE_AREA = :carton_storage_area</if>
 <if>AND src_carton.vwh_id = :vwh_id</if>
 <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID, MS.WAREHOUSE_LOCATION_ID, 'Unknown') IN (" sep="," post=")">:warehouse_location_id</a></if>
 <if>AND src_carton.quality_code = :quality_code</if>
 GROUP BY MASTER_STYLE.LABEL_ID, ms.Warehouse_Location_Id, src_carton.vwh_id, src_carton.quality_code
      
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlCtnArea" Type="String" Direction="Input" Name="carton_storage_area" />
            <asp:ControlParameter ControlID="ctlVwhId" Type="String" Direction="Input" Name="vwh_id" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="warehouse_location_id" />
            <asp:ControlParameter ControlID="tbQualityCode" Type="String" Direction="Input" Name="quality_code" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="NO_OF_CARTON;LABEL_ID"
        AutoGenerateColumns="false" ShowFooter="true" AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label belonging to the specefied area" />
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality code of cartons" />
            <eclipse:MultiBoundField DataFields="no_of_carton" HeaderText="# Cartons" DataSummaryCalculation="ValueSummation"
                SortExpression="no_of_carton" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="no_of_pieces" HeaderText="# Pieces" DataSummaryCalculation="ValueSummation"
                SortExpression="no_of_pieces" DataFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <%--<eclipse:MultiBoundField DataFields="Warehouse_Location_Id" HeaderText="Building"
                SortExpression="Warehouse_Location_Id" />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual Warehouse" />--%>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

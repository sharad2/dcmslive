<%@ Page Title="Pitch Location Report" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7225 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_05.aspx $
 *  $Id: R130_05.aspx 7225 2014-10-10 10:09:23Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Multiview Pattern--%>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        if (rblLocation.Value == "assigned")
        {
            this.mv.ActiveViewIndex = 0;
            ctlButtonBar.GridViewId = gv1.ID;
        }
        else
        {
            this.mv.ActiveViewIndex = 1;
            ctlButtonBar.GridViewId = gv2.ID;
        }
        base.OnLoad(e);
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.05" />
    <meta name="Description" content="Shows those locations where SKU's are assigned and locations 
                                        which are open for pitching.  It also show unassigned locations which can be 
                                        assigned and made available for pitching." />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R130_05.aspx 7225 2014-10-10 10:09:23Z skumar $" />
    <meta name="ChangeLog" content="Provided two new columns 'Std. Case Qty' and 'Estimated Cartons'. 'Estimated Cartons' column will show the maximum number of cartons which can be repacked with pieces at location, considering standard case quantity." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jpnl" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
                <i:RadioButtonListEx ID="rblLocation" runat="server" QueryString="location" Value="assigned"
                    FriendlyName="Records for " />
                <eclipse:LeftPanel runat="server">
                    <i:RadioItemProxy CheckedValue="assigned" Text="Assigned Locations" QueryString="location"
                        runat="server" FilterDisabled="true" />
                    <p style="width: 10em; margin-top: 0px">
                        To focus on specific SKUs, supply one or more of the SKU filters on the right.
                    </p>
                </eclipse:LeftPanel>
                <eclipse:TwoColumnPanel runat="server" ID="tcp">
                    <eclipse:LeftLabel ID="LeftLabel5" runat="server" />
                    <d:StyleLabelSelector ID="ls" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ShowAll="true" FriendlyName="Label" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>">
                        <Validators>
                            <i:Filter DependsOn="rblLocation" DependsOnState="Value" DependsOnValue="assigned" />
                        </Validators>
                    </d:StyleLabelSelector>
                    <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Style" />
                    <i:TextBoxEx ID="tbStyle" runat="server">
                        <Validators>
                            <i:Filter DependsOn="rblLocation" DependsOnState="Value" DependsOnValue="assigned" />
                        </Validators>
                    </i:TextBoxEx>
                    <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Color" />
                    <i:TextBoxEx ID="tbColor" runat="server">
                        <Validators>
                            <i:Filter DependsOn="rblLocation" DependsOnState="Value" DependsOnValue="assigned" />
                        </Validators>
                    </i:TextBoxEx>
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Dimension" />
                    <i:TextBoxEx ID="tbDimension" runat="server">
                        <Validators>
                            <i:Filter DependsOn="rblLocation" DependsOnState="Value" DependsOnValue="assigned" />
                        </Validators>
                    </i:TextBoxEx>
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="SKU Size" />
                    <i:TextBoxEx ID="tbSize" runat="server">
                        <Validators>
                            <i:Filter DependsOn="rblLocation" DependsOnState="Value" DependsOnValue="assigned" />
                        </Validators>
                    </i:TextBoxEx>
                </eclipse:TwoColumnPanel>
                <eclipse:LeftPanel runat="server" Span="true">
                    <i:RadioItemProxy CheckedValue="unassigned" Text="All unassigned locations" QueryString="location"
                        runat="server" />
                </eclipse:LeftPanel>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" ID="ctlButtonBar" />
    <asp:MultiView runat="server" ActiveViewIndex="-1" ID="mv">
        <asp:View ID="vw1" runat="server">
            <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
 select /*+index (sku sku_uk) index (ialoc_content IALOCCONT_PK)  */
       ialoc.location_id as location_id,
       max(ialoc.vwh_id) as vwh_id,
       max(sku.style) as style,
       max(sku.color) as color,
       max(sku.dimension) as dimension,
       max(sku.sku_size) as sku_size,
       max(sku.standard_case_qty) as standard_case_qty,
       max(trunc(ialoc_content.number_of_units / decode(sku.standard_case_qty, 0, null, sku.standard_case_qty))) as Estimated_Cartons,
       max(ialoc_content.number_of_units) as number_of_units,
       max(label_id) as label_id,
       max(ialoc.assigned_upc_code) as assigned_upc_code,
       max(ialoc.assigned_upc_max_pieces) as assigned_upc_max_pieces,
       max(round((sku.weight_per_dozen / 12), 4)) as weight_each,
       max(round((sku.volume_per_dozen / 12), 4)) as cube_each
  from ialoc
  LEFT outer join ialoc_content on ialoc_content.ia_id = ialoc.ia_id
                               and ialoc_content.location_id =
                                   ialoc.location_id
     AND IALOC_CONTENT.IACONTENT_ID = IALOC.ASSIGNED_UPC_CODE
  LEFT OUTER JOIN master_sku sku on ialoc.assigned_upc_code = sku.upc_code
  left outer join master_style on master_style.style = sku.style
  LEFT OUTER JOIN IA ia1 on ia1.ia_id = ialoc.ia_id
 where assigned_upc_code is not null
   AND ialoc.location_type = 'RAIL'
   AND ia1.picking_area_flag = 'Y'
   <if>AND sku.style = :style</if>
   <if>AND sku.color = :color</if>                
   <if>AND sku.dimension = :dimension</if>
   <if>AND sku.sku_size = :sku_size</if>  
   <if>AND master_style.label_id = :label_id</if>                                                    
    <if>AND ialoc.vwh_id = :vwh_id</if>
 group by ialoc.location_id
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="tbStyle" Type="String" Direction="Input" Name="style" />
                    <asp:ControlParameter ControlID="tbColor" Type="String" Direction="Input" Name="color" />
                    <asp:ControlParameter ControlID="tbDimension" Type="String" Direction="Input" Name="dimension" />
                    <asp:ControlParameter ControlID="tbSize" Type="String" Direction="Input" Name="sku_size" />
                    <asp:ControlParameter ControlID="ls" Type="String" Direction="Input" Name="label_id" />
                    <asp:ControlParameter ControlID="ctlVwh" Type="String" Direction="Input" Name="vwh_id" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gv1" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
                AllowSorting="true" ShowFooter="true" DefaultSortExpression="style" AllowPaging="true"
                PageSize="<%$ AppSettings: PageSize %>">
                <Columns>
                    <eclipse:SequenceField />
                    <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                        ItemStyle-HorizontalAlign="Left" HeaderToolTip="Virtual Warehouse" />
                    <asp:BoundField DataField="style" HeaderText="Style" SortExpression="style" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField DataField="color" HeaderText="Color" SortExpression="color" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField DataField="dimension" HeaderText="Dimension" SortExpression="dimension"
                        ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField DataField="sku_size" HeaderText="Size" SortExpression="sku_size"
                        ItemStyle-HorizontalAlign="Left" />
                  <eclipse:MultiBoundField DataFields="number_of_units" HeaderText="Quantity" DataSummaryCalculation="ValueSummation"
                        SortExpression="number_of_units" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" NullDisplayText="0"
                        HeaderToolTip="Quantity of SKU in Location">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                      <eclipse:MultiBoundField DataFields="standard_case_qty" HeaderToolTip="Standard Case Qty of the SKU" HeaderText="Std. Case Qty" NullDisplayText="0" SortExpression="standard_case_qty" 
                        ItemStyle-HorizontalAlign="Right" />
                    <eclipse:MultiBoundField DataFields="Estimated_Cartons" NullDisplayText="0" HeaderToolTip="Estimated cartons which can be repacked.    (Quantity / Std. Case Qty)" HeaderText="Estimated Cartons" SortExpression="Estimated_Cartons"
                        ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" DataSummaryCalculation="ValueSummation" />
                    <asp:BoundField DataField="label_id" HeaderText="Label" SortExpression="label_id"
                        ItemStyle-HorizontalAlign="Left" />
                    <eclipse:MultiBoundField DataFields="location_id" HeaderText="FPK Location" SortExpression="location_id"
                        ItemStyle-HorizontalAlign="Left" />
                    <eclipse:MultiBoundField DataFields="assigned_upc_code" HeaderText="UPC" SortExpression="assigned_upc_code"
                        ItemStyle-HorizontalAlign="Left" HeaderToolTip="Assigned UPC" />
                    <eclipse:MultiBoundField DataFields="assigned_upc_max_pieces" HeaderText="Capacity"
                        SortExpression="assigned_upc_max_pieces" ItemStyle-HorizontalAlign="Right" HeaderToolTip="Location Capacity" />
                    <eclipse:MultiBoundField DataFields="weight_each" HeaderText="Weight Each" SortExpression="weight_each"
                        DataSummaryCalculation="ValueSummation" DataFormatString="{0:N2}" DataFooterFormatString="{0:N2}"
                        HeaderToolTip="Weight of the SKU">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                    <eclipse:MultiBoundField DataFields="cube_each" SortExpression="cube_each" HeaderText="Cube Each"
                        DataSummaryCalculation="ValueSummation" DataFormatString="{0:N4}" DataFooterFormatString="{0:N4}"
                        HeaderToolTip="Volume of the SKU">
                        <ItemStyle HorizontalAlign="Right" />
                        <FooterStyle HorizontalAlign="Right" />
                    </eclipse:MultiBoundField>
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
        <asp:View ID="vw2" runat="server">
            <oracle:OracleDataSource ID="ds2" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                   SELECT ialoc.Location_Id AS location_id, 
                 ialoc.vwh_id AS vwh_id
                 FROM ialoc ialoc
                 WHERE ialoc.assigned_upc_code is null
                 and ialoc.ia_id in
                  (select ia_id from ia where ia.picking_area_flag = 'Y')
                 AND ialoc.location_type = 'RAIL'
                 <if>AND ialoc.vwh_id = :WAREHOUSE_ID</if> 
                </SelectSql>
                <SelectParameters>
                    <asp:ControlParameter ControlID="ctlVwh" PropertyName="Value" Type="String"
                        Direction="Input" Name="WAREHOUSE_ID" />
                </SelectParameters>
            </oracle:OracleDataSource>
            <jquery:GridViewEx ID="gv2" runat="server" DataSourceID="ds2" AutoGenerateColumns="false"
                AllowSorting="true" DefaultSortExpression="location_id" Caption="Showing Unassigned Locations"
                AllowPaging="true" PageSize="200">
                <Columns>
                    <eclipse:SequenceField />
                    <asp:BoundField DataField="location_id" HeaderText="Location" SortExpression="location_id"
                        ItemStyle-HorizontalAlign="Left" />
                    <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                        ItemStyle-HorizontalAlign="Left" HeaderToolTip="Virtual Warehouse" />
                </Columns>
            </jquery:GridViewEx>
        </asp:View>
    </asp:MultiView>
</asp:Content>

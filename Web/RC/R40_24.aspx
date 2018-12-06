<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Location of SKU in Carton Area" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4299 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/RC/R40_24.aspx $
 *  $Id: R40_24.aspx 4299 2012-08-20 07:08:43Z skumar $
 * Version Control Template Added.
 *
--%>
<%--Standard Pattern--%>
<script runat="server">
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="Description" content="Report retrieves the cartons for the SKU in given area. 
    It can also filter on received date as well as on Sewing Plant Code. It also shows whether the carton is  
    reserved or not. " />
    <meta name="ReportId" content="40.24" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R40_24.aspx 4299 2012-08-20 07:08:43Z skumar $" />
    <meta name="ChangeLog" content="In some case report was not honouring passed area filter.This bug has been fixed." />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Style" />
                <i:TextBoxEx ID="tbStyle" runat="server" FriendlyName="Style" QueryString="style">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Color" />
                <i:TextBoxEx ID="tbColor" runat="server" FriendlyName="Color" QueryString="color" >
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Dimension" />
                <i:TextBoxEx ID="tbDimension" runat="server" FriendlyName="Dimension" QueryString="dimension" >
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel4" runat="server" Text="Size" />
                <i:TextBoxEx ID="tbSize" runat="server" FriendlyName="Size" QueryString="sku_size">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel ID="LeftLabel5" runat="server" Text="Specify Received Date" />
                <d:BusinessDateTextBox ID="dtReceivedDate" runat="server" FriendlyName="Received Date" />
                <eclipse:LeftLabel ID="LeftLabel6" runat="server" Text="Sewing Plant Code" />
                <i:TextBoxEx ID="tbSewingPlantCode" runat="server" FriendlyName="Sewing Plant Code" />
                <eclipse:LeftLabel ID="LeftLabel7" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" QueryString="vwh_id" />
                <eclipse:LeftLabel ID="LeftLabel8" runat="server" />
                <d:BuildingSelector runat="server" ID="ctlWarehouseLocation" ShowAll="false" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" FriendlyName="Building" QueryString="building_id" >
                    <Items>
                     <eclipse:DropDownItem Text="(All)" Value="" Persistent="Always" />
                    <eclipse:DropDownItem Text="Unknown" Value="Unknown" Persistent="Always" />
                    </Items>
                    </d:BuildingSelector>
                <eclipse:LeftLabel runat="server" Text="Specify Carton Area" />
                  <oracle:OracleDataSource ID="dsAreas" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"  CancelSelectOnNullParameter="true">
                    <SelectSql>
                    
                            SELECT t.short_name,
                                   t.inventory_storage_area,
                                   t.description 
                                   FROM tab_inventory_area t
                                   WHERE t.stores_what ='CTN'
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlAreas" runat="server"  DataSourceID="dsAreas" DataFields="short_name,description,inventory_storage_area"
                    DataTextFormatString="{0}:{1}" Value="<%$ AppSettings:CartonReserveArea %>"  DataValueFormatString="{2}" QueryString="area">
                    <Items>
                        <eclipse:DropDownItem Value="" Text="(Any)" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                 <eclipse:LeftLabel ID="lblQuality" runat="server" Text="Quality Code" />
                <oracle:OracleDataSource ID="dsQuality" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                            select tqc.quality_code as qualitycode ,
                            tqc.description as qualitydescription
                            from tab_quality_code tqc
                            order by tqc.quality_rank asc
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlQualityCode" runat="server" DataSourceID="dsQuality" DataFields="qualitycode,qualitydescription"
                    DataTextFormatString="{0}:{1}" DataValueFormatString="{0}" QueryString="quality_code">
                    <Items>
                        <eclipse:DropDownItem Value="" Text="(Any)" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <br />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="jp1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="Buttonbar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
                <SelectSql> 
   SELECT tia.short_name as carton_storage_area, 
       ctndet.style as style,
       ctndet.color as color,
       ctndet.dimension as dimension,
       ctndet.sku_size as sku_size,
       ctn.quality_code as quality_code,
       ctn.location_id as location_id,
       ctn.pallet_id as pallet_id,
       ctn.carton_id as carton_id,
       ctn.sewing_plant_code as sewing_plant_code,
       ctn.price_season_code as price_season_code,
       ctn.Insert_Date as received_date,
       ctndet.quantity as quantity,
       decode(ctndet.req_process_id, NULL, '', 'TRUE') as reservation,
       ctn.vwh_id as vwh_id,
       nvl(nvl(tia.warehouse_location_id,msl.warehouse_location_id),'Unknown') as WAREHOUSE_LOCATION_ID
  FROM src_carton ctn
 inner JOIN src_carton_detail ctndet ON ctn.carton_id = ctndet.carton_id
  LEFT OUTER JOIN master_style ms ON ctndet.style = ms.style
 LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON ctn.LOCATION_ID = MSL.LOCATION_ID
     and ctn.carton_storage_area = msl.storage_area
    left outer JOIN TAB_INVENTORY_AREA TIA
      ON ctn.carton_storage_area = TIA.INVENTORY_STORAGE_AREA
   WHERE ctndet.style = :style
   AND ctndet.color = :color
   AND ctndet.DIMENSION = :dimension1
   AND ctndet.sku_size = :size1
   <if>AND ctn.vwh_id=:vwh_id</if>
   <if c="$warehouse_location_id != 'Unknown'">AND (TIA.WAREHOUSE_LOCATION_ID = :warehouse_location_id or MSL.WAREHOUSE_LOCATION_ID = :warehouse_location_id) </if>
   <if c="$warehouse_location_id ='Unknown'">and (MSL.Warehouse_Location_Id is null and TIA.WAREHOUSE_LOCATION_ID is null)</if> 
   <if>AND ctn.carton_storage_area =:carton_storage_area</if>
   <if c="$received_date">
   AND ctn.insert_date &gt;= trunc(:received_date)
   AND ctn.insert_date &lt; trunc(:received_date)+1   
   </if>
   <if>AND ctn.sewing_plant_code = :sewing_plant_code</if>
   <if>and ctn.quality_code=:quality_code</if>
   <if c="$showunresvpieces">
   and ctndet.req_process_id is null
   and ctn.suspense_date is null
   </if>  
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbStyle" Direction="Input" Name="style" Type="String" />
            <asp:ControlParameter ControlID="tbColor" Direction="Input" Name="color" Type="String" />
            <asp:ControlParameter ControlID="tbDimension" Direction="Input" Name="dimension1"
                Type="String" />
            <asp:ControlParameter ControlID="tbSize" Direction="Input" Name="size1" Type="String" />
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Name="vwh_id" Type="String" />
            <asp:ControlParameter ControlID="ctlWarehouseLocation" Direction="Input" Name="warehouse_location_id"
                Type="String" />
            <asp:ControlParameter ControlID="ddlAreas" Direction="Input" Name="carton_storage_area"
                Type="String" />
            <asp:ControlParameter ControlID="dtReceivedDate" Direction="Input" Name="received_date"
                Type="DateTime" />
            <asp:ControlParameter ControlID="tbSewingPlantCode" Direction="Input" Name="sewing_plant_code"
                Type="String" />
                 <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input"
                Name="quality_code" />
            <asp:QueryStringParameter Name="showunresvpieces" Type="String" QueryStringField="showunresvpieces" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx runat="server" ID="gv" DataSourceID="ds" AutoGenerateColumns="false"
        AllowSorting="true" ShowFooter="true" DefaultSortExpression="carton_storage_area;style;color;dimension;sku_size;quality_code;$;pallet_id;location_id">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="carton_storage_area" HeaderText="Area" SortExpression="carton_storage_area"
                HeaderToolTip="Storge area of the carton.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style of the SKU.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color of the SKU.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dimension" SortExpression="dimension"
                HeaderToolTip="Dimension of the SKU.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="Size of the SKU.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality code of carton" />
            <eclipse:MultiBoundField DataFields="pallet_id" HeaderText="Pallet" SortExpression="pallet_id"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="location_id" HeaderText="Location" SortExpression="location_id"></eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_id" HeaderText="Carton" SortExpression="carton_id"
                HeaderToolTip="Carton ID.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sewing_plant_code" HeaderText="Sewing Plant Code"
                HeaderToolTip="Sewing plant code for the carton." SortExpression="sewing_plant_code">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="price_season_code" HeaderText="Season Code"
                HeaderToolTip="Season code for the carton." SortExpression="price_season_code">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="received_date" HeaderText="Received Date" SortExpression="received_date"
                HeaderToolTip="Date when carton processed." DataFormatString="{0:MM/dd/yyyy}">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Quantity" SortExpression="quantity"
                HeaderToolTip="Sum of pieces for the corresponding Carton and SKU." DataSummaryCalculation="ValueSummation"
                FooterToolTip="Total Quantity." DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <jquery:IconField DataField="reservation" HeaderText="Reservation" DataFieldValues="TRUE"
                HeaderToolTip="Status of Carton which shows whether the requirement against the given carton is present or not"
                IconNames="ui-icon-check" ItemStyle-HorizontalAlign="Center" SortExpression="reservation" />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="VWh" SortExpression="vwh_id"
                HeaderToolTip="Virtual Warehouse ID.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building"
                HeaderToolTip="Location of the warehouse." SortExpression="WAREHOUSE_LOCATION_ID">
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

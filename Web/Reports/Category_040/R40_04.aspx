<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Pallets on a given Carton Storage Area" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5567 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_04.aspx $
 *  $Id: R40_04.aspx 5567 2013-07-06 09:44:11Z skumar $
 * Version Control Template Added.
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="Report provides the information of all the pallets lying in the given storage area. The report also provides insight about the pallets and thus cartons awaiting some process." />
    <meta name="ReportId" content="40.04" />
    <meta name="Browsable" content="true" />
    <meta name="Version" content="$Id: R40_04.aspx 5567 2013-07-06 09:44:11Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Specify Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    UsableInventoryAreaOnly="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    ShowAll="true" StorageAreaType="CTN">
                </d:InventoryAreaSelector>
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true" >
        <SelectSql>
         SELECT ctn.pallet_id AS pallet_id,
        ctn.quality_code AS quality_code,
        MAX(ctn.location_id) AS location_id,
        COUNT(ctn.carton_id) AS cartons_count,
        MIN(ctn.modified_date) AS modified_date,
        CTN.CARTON_STORAGE_AREA,
        MAX(TIA.SHORT_NAME) AS AREAS,
        COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                MSL.WAREHOUSE_LOCATION_ID,
                'Unknown') AS WAREHOUSE_LOCATION_ID
        FROM src_carton ctn
        LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
        ON CTN.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
        AND CTN.LOCATION_ID = MSL.LOCATION_ID
        INNER JOIN TAB_INVENTORY_AREA TIA
        ON CTN.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
        WHERE ctn.pallet_id IS NOT NULL
        <if>AND ctn.carton_storage_area = :carton_storage_area</if>
        GROUP BY ctn.pallet_id, ctn.quality_code,
          CTN.CARTON_STORAGE_AREA,
          COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                   MSL.WAREHOUSE_LOCATION_ID,
                   'Unknown')
        </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlCtnArea" Direction="Input" Type="String" Name="carton_storage_area" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DefaultSortExpression="WAREHOUSE_LOCATION_ID;AREAS;$;pallet_id" DataSourceID="ds"
        AutoGenerateColumns="false" AllowSorting="true" ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
             <asp:BoundField HeaderText="Building" DataField="WAREHOUSE_LOCATION_ID" SortExpression="WAREHOUSE_LOCATION_ID" />
            <asp:BoundField HeaderText="Area" DataField="AREAS" SortExpression="AREAS" />
            <eclipse:SiteHyperLinkField DataTextField="pallet_id" HeaderText="Pallet" SortExpression="pallet_id"
                DataNavigateUrlFormatString="R40_09.aspx?pallet_id={0}&quality_code={1}" DataNavigateUrlFields="pallet_id,quality_code">
            </eclipse:SiteHyperLinkField>
            <asp:BoundField HeaderText="Location" DataField="location_id" SortExpression="location_id" />
            <asp:BoundField HeaderText="Quality" DataField="quality_code" SortExpression="quality_code" />
            <asp:BoundField HeaderText="Pallet Created Date(Modified Date)" DataField="modified_date"
                SortExpression="modified_date {0:I} NULLS LAST" />
            <eclipse:MultiBoundField DataFields="cartons_count" HeaderText="# Cartons" SortExpression="cartons_count"
                DataSummaryCalculation="ValueSummation">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

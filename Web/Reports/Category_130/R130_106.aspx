<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKU Inventory" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6170 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_106.aspx $
 *  $Id: R130_106.aspx 6170 2013-09-25 10:38:29Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.106" />
    <meta name="Browsable" content="false" />
    <meta name="Description" content="Shows details of quantity at each location for a specified UPC code in picking area." />
    <meta name="Version" content="$Id: R130_106.aspx 6170 2013-09-25 10:38:29Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel ID="jp" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="UPC Code" />
                <i:TextBoxEx ID="tbUPC" runat="server" QueryString="UPC" ToolTip="Upc Code to which you want to see location-wise inventory.(It is required)">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    QueryString="vwh_id" ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" ToolTip="By default, inventory of all Virtual Warehouse is shown for each location. If your focus is on the inventory in a particular Virtual Warehouse, Specify that Virtaul Warehouse." />
            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>">
        <SelectSql>
            <if c="$AREA !='BOX'">
          <if c="not($showunresvpieces)">       
        SELECT max(i.short_name || ':' || i.short_description) AS ia_id,
               SYS.STRAGG(UNIQUE ic.location_id ||',')     AS location_id,
               max(ic.iacontent_id)    AS UPC_Code,
               sum(ic.number_of_units) AS pieces_at_location,
               MAX(ms.style)           AS style,
               MAX(ms.color)           AS color,
               MAX(ms.dimension)       AS dimension,
               MAX(ms.sku_size)        AS sku_size
          FROM ialoc_content ic
          LEFT OUTER JOIN ialoc ial
            ON ic.ia_id = ial.ia_id
           AND ic.location_id = ial.location_id
         LEFT OUTER JOIN master_sku ms
            ON ms.UPC_Code = ic.iacontent_id
         LEFT OUTER JOIN ia i
            ON i.ia_id = ial.ia_id
         WHERE 1=1
              <if c="not($AREA)">AND i.picking_area_flag = 'Y'</if>
              <else>AND ic.ia_id=:area</else>
            <if>AND ic.iacontent_id = CAST(:upc_code as varchar2(255))</if>
           <if>AND ial.vwh_id = CAST(:vwh_id as varchar2(255))</if>
                GROUP BY IC.IA_ID
              </if>
           <else>
         SELECT IL.SHORT_NAME AS IA_ID,
         IL.location_id as location_id,
         NVL(IL.NUMBER_OF_UNITS, 0) - NVL(R.RESERVED_UNITS, 0) AS pieces_at_location,
         IL.style as style,
         IL.color as color,
         IL.dimension as dimension,
         IL.sku_size as sku_size
    FROM (SELECT max(IAC.IA_ID)      AS AREA_ID,
                 MAX(IA.SHORT_NAME) AS SHORT_NAME,
                 iac.location_id as location_id,
                 max(msku.style) as style,
                 max(msku.color) as color,
                 max(msku.dimension) as dimension,
                 max(msku.sku_size) as sku_size,
                 sum(IAC.NUMBER_OF_UNITS) AS NUMBER_OF_UNITS,
                 I.vwh_id as vwh_id,
                 msku.sku_id
            FROM IALOC_CONTENT IAC
           INNER JOIN IALOC I
              ON I.IA_ID = IAC.IA_ID
             AND I.LOCATION_ID = IAC.LOCATION_ID          
           INNER JOIN MASTER_SKU MSKU
              ON MSKU.UPC_CODE = IAC.IACONTENT_ID
           INNER JOIN IA ON I.IA_ID = IA.IA_ID
           WHERE 1=1
             <if>AND I.VWH_ID = :vwh_id</if>
             <if> and iac.iacontent_id=:upc_code</if>
             <if>and IAC.IA_ID=:area</if>
           GROUP BY msku.sku_id,
                    I.VWH_ID,
                    Iac.location_id
                    ) IL
    LEFT OUTER JOIN (SELECT max(RD.IA_ID) AS IA_ID,
                            rd.location_id as location_id,
                            max(msku.style) as style,
                            max(msku.color) as color,
                            max(msku.dimension) as dimension,
                            max(msku.sku_size) as sku_size,
                            sum(RD.PIECES_RESERVED) as RESERVED_UNITS,
                            msku.sku_id as sku_id,
                            RD.vwh_id as vwh_id
                            FROM RESVDET RD
                            INNER JOIN MASTER_SKU MSKU
                            ON RD.UPC_CODE = MSKU.UPC_CODE                        
                             where 1=1
                           <if>and rd.vwh_id=:vwh_id</if>
                           <if>and rd.upc_code=:upc_code</if>
 GROUP BY msku.sku_id, RD.VWH_ID,rd.location_id) R   
     on IL.Sku_id=R.sku_id
     AND IL.VWH_ID = R.VWH_ID
     AND IL.LOCATION_ID = R.LOCATION_ID
           </else></if>
             <else>
SELECT B.IA_ID,
       NULL AS LOCATION_ID,
       MAX(MS.STYLE) AS STYLE,
       MAX(MS.COLOR) AS COLOR,
       MAX(MS.DIMENSION) AS DIMENSION,
       MAX(MS.SKU_SIZE) AS SKU_SIZE,
       SUM(BD.CURRENT_PIECES) as pieces_at_location
  FROM BOX B
 INNER JOIN BOXDET BD
    ON B.UCC128_ID = BD.UCC128_ID
   AND B.PICKSLIP_ID = BD.PICKSLIP_ID
  LEFT OUTER JOIN MASTER_SKU MS
    ON BD.UPC_CODE = MS.UPC_CODE
 WHERE B.STOP_PROCESS_DATE IS NULL
   AND BD.STOP_PROCESS_DATE IS NULL
    AND bd.current_pieces >0
   <if>and b.vwh_id=:vwh_id</if>
   <if>and bd.upc_code=:upc_code</if>
   GROUP BY B.IA_ID
             </else>
        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="tbUPC" Type="String" Direction="Input" Name="upc_code" />
            <asp:ControlParameter ControlID="ctlVwh" Type="String" Direction="Input" Name="vwh_id" />
            <asp:QueryStringParameter Name="showunresvpieces" DbType="String" QueryStringField="showunresvpieces" />
            <asp:QueryStringParameter Name="area" DbType="String" QueryStringField="area" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" DataSourceID="ds"
        AllowSorting="true" DefaultSortExpression="STYLE;COLOR;DIMENSION;sku_SIZE;$;LOCATION_ID"
        ShowFooter="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="STYLE" HeaderText="Style" SortExpression="STYLE" />
            <eclipse:MultiBoundField DataFields="COLOR" HeaderText="Color" SortExpression="COLOR" />
            <eclipse:MultiBoundField DataFields="DIMENSION" HeaderText="Dim." SortExpression="DIMENSION" />
            <eclipse:MultiBoundField DataFields="sku_SIZE" HeaderText="Size" SortExpression="sku_SIZE" />
            <eclipse:MultiBoundField DataFields="IA_ID" HeaderText="Area" SortExpression="IA_ID"
                HeaderToolTip="Inventory Area" />
            <eclipse:MultiBoundField DataFields="LOCATION_ID" HeaderText="Location" SortExpression="LOCATION_ID" HideEmptyColumn="true" />
            <eclipse:MultiBoundField DataFields="PIECES_AT_LOCATION" HeaderText="Pieces" SortExpression="PIECES_AT_LOCATION"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}"
                HeaderToolTip="Total number of pieces at particular location">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

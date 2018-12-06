<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="SKUs flagged for Red carton cycle count" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4824 $
 *  $Author: skumar $
 *  *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_130/R130_29.aspx $
 *  $Id: R130_29.aspx 4824 2013-01-10 04:50:02Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    protected void cbSpecificBuilding_OnServerValidate(object sender, EclipseLibrary.Web.JQuery.Input.ServerValidateEventArgs e)
    {
        if (cbSpecificBuilding.Checked && string.IsNullOrEmpty(ctlWhLoc.Value))
        {
            e.ControlToValidate.IsValid = false;
            e.ControlToValidate.ErrorMessage = "Please provide select at least one building.";
            return;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="ReportId" content="130.29" />
    <meta name="Description" content="The report display the information about the location marked 
                                        for CYC while pitching due to mismatch of pieces." />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content="Helps you know login user who marked the location for CYC.|Changed column and filter names from Warehouse Location  to  Building." />
    <meta name="Version" content="$Id: R130_29.aspx 4824 2013-01-10 04:50:02Z skumar $" />
    <script type="text/javascript">
        function ctlWhLoc_OnClientChange(event, ui) {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {
                $('#cbSpecificBuilding').attr('checked', 'checked');
            } else {
                $('#cbSpecificBuilding').removeAttr('checked', 'checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs ID="tabs" runat="server">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel runat="server">
                <eclipse:LeftLabel runat="server" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" />
               <%-- <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Building" />
                <d:BuildingSelector ID="ctlWhLoc" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" FriendlyName="Building" ToolTip="Click to choose Warehouse Location" />
            --%>
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel3" runat="server" Text="Check For Specific Building" />
                    <i:CheckBoxEx ID="cbSpecificBuilding" runat="server" FriendlyName="Specific Building">
                        <Validators>
                            <i:Custom OnServerValidate="cbSpecificBuilding_OnServerValidate" />
                        </Validators>
                    </i:CheckBoxEx>
                </eclipse:LeftPanel>

                <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                            SELECT TWL.WAREHOUSE_LOCATION_ID,
                                   (TWL.WAREHOUSE_LOCATION_ID || ':' || TWL.DESCRIPTION) AS DESCRIPTION
                            FROM TAB_WAREHOUSE_LOCATION TWL
                            ORDER BY 1
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:CheckBoxListEx ID="ctlWhLoc" runat="server" DataTextField="DESCRIPTION"
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Check For building In"
                    QueryString="building" OnClientChange="ctlWhLoc_OnClientChange">
                </i:CheckBoxListEx>

            </eclipse:TwoColumnPanel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser runat="server" GridViewExId="gv" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
        CancelSelectOnNullParameter="true">
         <SelectSql>
         SELECT /*+ index (ia ialoc_pk )*/
 IA.CYC_MARKED_DATE  AS CYC_MARKED_DATE,
 IA.CYC_MODIFIED_BY  AS CYC_MODIFIED_BY,
 IA.LOCATION_ID      AS LOCATION_ID,
 IA.VWH_ID           AS VWH_ID,
 IA.warehouse_location_id AS warehouse_location_id,
 MS.STYLE            AS STYLE,
 MS.COLOR            AS COLOR,
 MS.DIMENSION        AS DIMENSION,
 MS.SKU_SIZE         AS SKU_SIZE,
 IAC.NUMBER_OF_UNITS AS PIECES,
 MT.LABEL_ID         AS LABEL_ID
 FROM IALOC IA
  LEFT OUTER JOIN IALOC_CONTENT IAC ON IA.IA_ID = IAC.IA_ID
                                   AND IA.LOCATION_ID = IAC.LOCATION_ID
 INNER JOIN MASTER_SKU MS ON IA.ASSIGNED_UPC_CODE = MS.UPC_CODE
  LEFT OUTER JOIN MASTER_STYLE MT ON MS.STYLE = MT.STYLE
 WHERE IA.CYC_MARKED_DATE IS NOT NULL
   AND IA.LOCATION_STATUS IN
       (SELECT SP.SPLH_VALUE AS SPLH_VALUE
          FROM SPLH SP
         WHERE SPLH_ID = '$LCLOCSTAT')
         <if>AND IA.VWH_ID = cast(:vwh_id as varchar2(255))</if>
         <%--<if>AND IA.warehouse_location_id=:Whloc</if>--%>
             <if>AND <a pre="ia.WAREHOUSE_LOCATION_ID IN (" sep="," post=")">:Whloc</a></if>
         </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Name="Whloc" Direction="Input" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" AutoGenerateColumns="false"
        DefaultSortExpression="warehouse_location_id;$;CYC_MARKED_DATE" ShowFooter="true"
        AllowSorting="true">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField HeaderText="Building" DataFields="warehouse_location_id"
                SortExpression="warehouse_location_id">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="CYC_MARKED_DATE" SortExpression="CYC_MARKED_DATE"
                HeaderText="CYC|Marked Date" DataFormatString="{0:d} {0:t}" />
            <eclipse:MultiBoundField DataFields="CYC_MODIFIED_BY" SortExpression="CYC_MODIFIED_BY" HeaderText="CYC|Marked By" />
            <eclipse:MultiBoundField DataFields="STYLE" SortExpression="STYLE" HeaderText="Style" />
            <eclipse:MultiBoundField DataFields="COLOR" SortExpression="COLOR" HeaderText="Color" />
            <eclipse:MultiBoundField DataFields="DIMENSION" SortExpression="DIMENSION" HeaderText="Dim"
                HeaderToolTip="Dimension" />
            <eclipse:MultiBoundField DataFields="SKU_SIZE" SortExpression="SKU_SIZE" HeaderText="Size"
                HeaderToolTip="SKU Size" />
            <eclipse:MultiBoundField DataFields="LABEL_ID" SortExpression="LABEL_ID" HeaderText="Label"
                HeaderToolTip="Label ID" />
            <eclipse:MultiBoundField DataFields="LOCATION_ID" SortExpression="LOCATION_ID" HeaderText="Location" />
            <eclipse:MultiBoundField DataFields="PIECES" SortExpression="PIECES" HeaderText="System<br />Pieces"
                DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="VWH_ID" SortExpression="VWH_ID" HeaderText="VWh"
                HeaderToolTip="Virtual Warehouse" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

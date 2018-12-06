<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Carton with details for Define Storage Area" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 7112 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_16.aspx $
 *  $Id: R40_16.aspx 7112 2014-08-02 11:09:26Z skumar $
 * Version Control Template Added.
--%>
<%--Shift Pattern--%>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="EclipseLibrary.Web.Extensions" %>
<script runat="server">
   
    protected void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        string strShiftNumberWhere = ShiftSelector.GetShiftNumberClause("sc.MODIFIED_DATE");
        if (string.IsNullOrEmpty(rbtnShift.Value))
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Empty);
        }
        else
        {
            e.Command.CommandText = e.Command.CommandText.Replace("$ShiftNumberWhere$", string.Format(" AND {0} = :{1}", strShiftNumberWhere, "shift_number"));
        }
    }
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {


            if (!string.IsNullOrEmpty(ddlLabel.Value))
            {
                // check radio button if bucket is passed via query string
                //rblOrderType.Value = "SB";
                //rbSpecificBucket.CheckedValue = "SB";
                rblfilter.Value = "L";
                rbLabel.CheckedValue = "L";
            }
            if (!string.IsNullOrEmpty(tbstyle.Text))
            {
                rblfilter.Value = "S";
                rbStyle.CheckedValue = "S";
            }

        }
        base.OnLoad(e);
    }
    protected void gv_OnDataBound(object send, EventArgs e)
    {
        var CountOfLocation = gv.Columns.Cast<DataControlField>().Select((p, i) => p.AccessibleHeaderText == "FPKLocation" ? i : -1)
           .Single(p => p >= 0);


        if (gv.Rows.Count > 1)
        {
            for (int tempIndex = 0; tempIndex <= gv.Rows.Count - 1; tempIndex++)
            {
                var stringval = gv.Rows[tempIndex].Cells[CountOfLocation].Text.Split(',').Where(p => !string.IsNullOrWhiteSpace(p)).ToArray();
                var txt = string.Join(",", stringval.Where(p => !string.IsNullOrEmpty(p)).Select(p => p));
                gv.Rows[tempIndex].Cells[CountOfLocation].Text = txt;
                if (gv.Rows[tempIndex].Cells[CountOfLocation].Text.Split(',').Where(p => !string.IsNullOrWhiteSpace(p)).Count() > 1)
                {

                    gv.Rows[tempIndex].Cells[CountOfLocation].BackColor = System.Drawing.Color.Yellow;
                    gv.Rows[tempIndex].Cells[CountOfLocation].ForeColor = System.Drawing.Color.Red;

                }
            }
        }
    }
              
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="The report displays the comprehensive details of each carton for a specified 
    storage area. You can further filter, on the basis of label, pulls generated for the pulls generated area in a given time period,
    Shift, first or second shift in which the pulls have been generated and warehouse id of the cartons belong to a 
    specified storage area." />
    <meta name="ReportId" content="40.16" />
    <meta name="Browsable" content="true" />
    <meta name="ChangeLog" content=" New filter for price season code is avalaible now.|A new column Price Season Code has been introduced in the report.|In Building filter provided option for selecting and unselecting all buildings." />  
    <meta name="Version" content="$Id: R40_16.aspx 7112 2014-08-02 11:09:26Z skumar $" />
    <script type="text/javascript">
        $(document).ready(function () {
            if ($('#ctlWhLoc').find('input:checkbox').is(':checked')) {

                //Do nothing if any of checkbox is checked
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
                $('#cbAll').attr('checked', 'checked');
            };

        });
        function cbAll_OnClientChange(event, ui) {
            if ($('#cbAll').is(':checked')) {
                $('#ctlWhLoc').find('input:checkbox').attr('checked', 'checked');
            }
            else {
                $('#ctlWhLoc').find('input:checkbox').removeAttr('checked');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="tcpFilters" runat="server">
                <eclipse:LeftLabel runat="server" Text="Carton Storage Area" />
                <d:InventoryAreaSelector ID="ctlCtnArea" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ShowAll="true" StorageAreaType="CTN" UsableInventoryAreaOnly="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                    QueryString="CARTON_STORAGE_AREA" ToolTip="Click to choose area from the list">
                </d:InventoryAreaSelector>
                <eclipse:LeftPanel ID="LeftPanel1" runat="server" Span="true">
                    <i:RadioButtonListEx runat="server" ID="rblfilter" Visible="false" Value="L"
                        QueryString="filter_type" />
                </eclipse:LeftPanel>
                <eclipse:LeftPanel ID="LeftPanel2" runat="server">
                    <i:RadioItemProxy ID="rbLabel" runat="server" Text="Label" 
                        CheckedValue="L" QueryString="filter_type" FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel ID="Panel1" runat="server">
                    <d:StyleLabelSelector ID="ddlLabel" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                        ShowAll="true" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>"
                        QueryString="LABEL_ID" FriendlyName="Label" ToolTip="Click to choose label from the list">
                        <Validators>
                            <i:Filter DependsOn="rblfilter" DependsOnState="Value" DependsOnValue="L" />
                        </Validators>
                    </d:StyleLabelSelector>
                </asp:Panel>
                <eclipse:LeftPanel ID="LeftPanel3" runat="server">
                    <i:RadioItemProxy runat="server" Text="Style" ID="rbStyle" CheckedValue="S"
                        QueryString="filter_type" FilterDisabled="true" />
                </eclipse:LeftPanel>
                <asp:Panel runat="server" ID="p_receipt">
                    <i:TextBoxEx ID="tbstyle" FriendlyName="Style" runat="server" QueryString="style" ToolTip="Enter Style for which you want to run this report.">
                        <Validators>
                            <i:Filter DependsOn="rblfilter" DependsOnState="Value" DependsOnValue="S" />
                            <i:Required DependsOn="rblfilter" DependsOnState="Value" DependsOnValue="S" />
                        </Validators>
                    </i:TextBoxEx>
                </asp:Panel>
                <br />
                <eclipse:LeftLabel runat="server" Text="Summarize Modified Date" />
                From
                <d:BusinessDateTextBox ID="dtFrom" runat="server" FriendlyName="From modified date"
                    ToolTip="Pulls generated for the pulls generated area in a given time period."
                    QueryString="modified_date_from" />
                To
                <d:BusinessDateTextBox ID="dtTo" runat="server" ToolTip="Pulls generated for the pulls generated area in a given time period."
                    FriendlyName="To modified date" QueryString="modified_date_to">
                    <Validators>
                        <i:Date DateType="ToDate" />
                    </Validators>
                </d:BusinessDateTextBox>
                <eclipse:LeftLabel runat="server" Text="Shift" />
                <d:ShiftSelector ID="rbtnShift" runat="server" ToolTip="Shift" />
                <eclipse:LeftLabel runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" QueryString="vwh_id" ToolTip="Click to choose Virtual Warehouse from the list"/>
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
                    DataTextFormatString="{0}:{1}" DataValueFormatString="{0}" QueryString="quality_code" ToolTip="Click to choose Quality from the list">
                    <Items>
                       <eclipse:DropDownItem Text="All" Value="" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
                <eclipse:LeftLabel runat="server" Text="Price Season Code" />
                <oracle:OracleDataSource ID="dsSeasonCode" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
                    ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true">
                    <SelectSql>
                            SELECT T.PRICE_SEASON_CODE AS PRICE_SEASON_CODE,
                                   T.DESCRIPTION       AS DESCIPTION
                              FROM TAB_PRICE_SEASON T
                              order by PRICE_SEASON_CODE
                    </SelectSql>
                </oracle:OracleDataSource>
                <i:DropDownListEx2 ID="ddlSeasonCode" runat="server" DataSourceID="dsSeasonCode" DataFields="PRICE_SEASON_CODE,DESCIPTION"
                    DataTextFormatString="{0}: {1}" DataValueFormatString="{0}" QueryString="PRICE_SEASON_CODE" ToolTip="Click to choose Price season code from the list">
                    <Items>
                       <eclipse:DropDownItem Text="All" Value="" Persistent="Always" />
                    </Items>
                </i:DropDownListEx2>
            </eclipse:TwoColumnPanel>
            <asp:Panel runat="server">
                <eclipse:TwoColumnPanel runat="server">
                     <eclipse:LeftPanel ID="LeftPanel4" runat="server">
                    <eclipse:LeftLabel ID="LeftLabel4" runat="server"  Text="Building"/>
                     <br />
                     <br />
                    <i:CheckBoxEx ID="cbAll" runat="server" FilterDisabled="true" FriendlyName="Select All" OnClientChange="cbAll_OnClientChange" ToolTip="Use this filter to run this report for the desired buildings">                     
                    </i:CheckBoxEx>
                     Click to Select/UnSelect all
                </eclipse:LeftPanel>
                <oracle:OracleDataSource ID="dsBuilding" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
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
                    DataValueField="WAREHOUSE_LOCATION_ID" DataSourceID="dsBuilding" FriendlyName="Building"
                    QueryString="building_id">
                </i:CheckBoxListEx>
                </eclipse:TwoColumnPanel>
            </asp:Panel>
        </jquery:JPanel>
        <jquery:JPanel runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" />
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" OnSelecting="ds_Selecting">
        <SelectSql>
WITH CARTON_DETAIL AS
 (SELECT SC.CARTON_ID,
         MS.UPC_CODE,
         SC.LOCATION_ID AS CARTON_LOCATION,
         SC.PALLET_ID,
         SC.MODIFIED_DATE,
         NVL2(SC.SUSPENSE_DATE, 'TRUE', '') AS SUSPENSE_DATE,
         COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown') AS WAREHOUSE_LOCATION_ID,
         SC.CARTON_STORAGE_AREA,
         tia.short_name,
         SC.VWH_ID,
         MS.STYLE,
         MS.COLOR,
         MS.DIMENSION,
         MS.SKU_SIZE,
         SCD.QUANTITY,
         SCD.req_assign_date,
         sc.quality_code,
         SC.PRICE_SEASON_CODE
    FROM SRC_CARTON SC
   INNER JOIN SRC_CARTON_DETAIL SCD
      ON SC.CARTON_ID = SCD.CARTON_ID
    LEFT OUTER JOIN MASTER_SKU MS
      ON SCD.SKU_ID = MS.SKU_ID
    LEFT OUTER JOIN MASTER_STORAGE_LOCATION MSL
      ON SC.CARTON_STORAGE_AREA = MSL.STORAGE_AREA
     AND SC.LOCATION_ID = MSL.LOCATION_ID
    LEFT OUTER JOIN TAB_INVENTORY_AREA TIA
      ON SC.CARTON_STORAGE_AREA = TIA.INVENTORY_STORAGE_AREA
    WHERE 1=1
     <if>AND sc.carton_storage_area = :CARTON_STORAGE_AREA</if>
     <if>AND ms.style = :style</if>
     <if>AND sc.VWH_ID = :vwh_id</if>
     <if>and sc.quality_code= :quality_code</if>
     <if>and sc.price_season_code =:price_season_code</if>
     <if>AND sc.modified_date &gt;= (:modified_date_from)</if>
     <if>AND sc.modified_date &lt; (:modified_date_to)+1</if>
     <if>AND <a pre="COALESCE(TIA.WAREHOUSE_LOCATION_ID,
                  MSL.WAREHOUSE_LOCATION_ID,
                  'Unknown')  IN (" sep="," post=")"> :WAREHOUSE_LOCATION_ID</a></if>
     <![CDATA[
            $ShiftNumberWhere$                     
            ]]>
),
IALOC_DETAIL AS
 (SELECT I.ASSIGNED_UPC_CODE,
         I.VWH_ID,
         SYS.STRAGG(UNIQUE(I.LOCATION_ID || ', ')) AS assigned_fpk_location
    FROM IALOC I
   WHERE I.ASSIGNED_UPC_CODE IS NOT NULL
   <if>AND i.VWH_ID = :vwh_id</if>
   <if>AND <a pre="NVL(I.WAREHOUSE_LOCATION_ID,'Unknown') IN (" sep="," post=")">:WAREHOUSE_LOCATION_ID</a></if>
   GROUP BY I.ASSIGNED_UPC_CODE, I.VWH_ID)
SELECT CD.CARTON_ID,
       CD.UPC_CODE,
       CD.CARTON_LOCATION,
       CD.PALLET_ID,
       CD.MODIFIED_DATE,
       CD.SUSPENSE_DATE,
       CD.WAREHOUSE_LOCATION_ID,
       CD.CARTON_STORAGE_AREA,
       CD.VWH_ID,
       CD.STYLE,
       CD.COLOR,
       CD.DIMENSION,
       CD.SKU_SIZE,
       CD.QUANTITY,
       MST.LABEL_ID,
       cd.short_name,
       ICD.assigned_fpk_location,
       CD.req_assign_date,
       cd.quality_code,
       CD.PRICE_SEASON_CODE
  FROM CARTON_DETAIL CD
  LEFT OUTER JOIN IALOC_DETAIL ICD
    ON ICD.ASSIGNED_UPC_CODE = CD.UPC_CODE
   AND ICD.VWH_ID = CD.VWH_ID
  LEFT OUTER JOIN MASTER_STYLE MST ON 
            CD.STYLE = MST.STYLE
where 1=1
<if>AND mst.Label_ID = :LABEL_ID</if>

        </SelectSql>
        <SelectParameters>
            <asp:ControlParameter ControlID="dtFrom" Type="DateTime" Direction="Input" Name="modified_date_from" />
            <asp:ControlParameter ControlID="dtTo" Type="DateTime" Direction="Input" Name="modified_date_to" />
            <asp:ControlParameter ControlID="ctlCtnArea" Name="CARTON_STORAGE_AREA" Type="String"
                Direction="Input" />
            <asp:ControlParameter ControlID="ddlLabel" Name="LABEL_ID" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="ctlVwh" Name="vwh_id" Type="String" Direction="Input" />
            <asp:ControlParameter ControlID="rbtnShift" Type="Int32" Direction="Input" Name="shift_number" />
            <asp:ControlParameter ControlID="tbStyle" Type="String" Direction="Input" Name="style" />
            <asp:ControlParameter ControlID="ctlWhLoc" Type="String" Direction="Input" Name="WAREHOUSE_LOCATION_ID" />
            <asp:ControlParameter ControlID="ddlQualityCode" Type="String" Direction="Input" Name="quality_code" />
            <asp:ControlParameter ControlID="ddlSeasonCode" Type="String" Direction="Input" Name="price_season_code" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds" DefaultSortExpression="vwh_id;short_name;WAREHOUSE_LOCATION_ID;$;pallet_id;carton_id"
        AutoGenerateColumns="false" OnDataBound="gv_OnDataBound" AllowSorting="true" ShowFooter="true" AllowPaging="true"
        PageSize="<%$ AppSettings: PageSize %>">
        <Columns>
            <eclipse:SequenceField />
            <eclipse:MultiBoundField DataFields="vwh_id" HeaderText="Vwh" SortExpression="vwh_id"
                HeaderToolTip="Virtual warehouse">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="short_name" HeaderText="Area" SortExpression="short_name"
                HeaderToolTip="Area where the carton is curretly situated">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="WAREHOUSE_LOCATION_ID" HeaderText="Building" SortExpression="WAREHOUSE_LOCATION_ID"
                HeaderToolTip="Building of the sku.">
            </eclipse:MultiBoundField>
            <eclipse:SiteHyperLinkField DataTextField="pallet_id" HeaderText="Pallet" HeaderToolTip="Pallet on which cartons are lying."
                SortExpression="pallet_id" DataNavigateUrlFormatString="R40_23.aspx?&pallet_id={0}&vwh_id={1}"
                DataNavigateUrlFields="pallet_id,vwh_id">
            </eclipse:SiteHyperLinkField>
            <eclipse:MultiBoundField DataFields="CARTON_LOCATION" HeaderText="Location" HeaderToolTip="Location on which cartons are lying."
                SortExpression="CARTON_LOCATION" HideEmptyColumn="true">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="carton_id" HeaderText="Carton" SortExpression="carton_id"
                HeaderToolTip="Carton lying on the pallet or location">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="label_id" HeaderText="Label" SortExpression="label_id"
                HeaderToolTip="Label assigned to the sku.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="modified_date" HideEmptyColumn="true" HeaderText="Modified Date" SortExpression="modified_date {0:I} NULLS LAST"
                HeaderToolTip="Date on which the changes has been done on the carton" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}">
                <ItemStyle Wrap="false" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="upc_code" HeaderText="UPC" SortExpression="upc_code"
                HeaderToolTip="UPC code for the sku.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="style" HeaderText="Style" SortExpression="style"
                HeaderToolTip="Style of the sku.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="color" HeaderText="Color" SortExpression="color"
                HeaderToolTip="Color of the sku.">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="dimension" HeaderText="Dimension" SortExpression="dimension"
                HeaderToolTip="Dimension of the sku.">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="sku_size" HeaderText="Size" SortExpression="sku_size"
                HeaderToolTip="Size of the sku.">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quality_code" HeaderText="Quality" SortExpression="quality_code"
                HeaderToolTip="Quality of the sku.">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="PRICE_SEASON_CODE" HeaderText="Price Season Code" SortExpression="PRICE_SEASON_CODE"
                 HeaderToolTip="Price Season Code of the SKU">
                <ItemStyle HorizontalAlign="Left" />
                <FooterStyle HorizontalAlign="Left" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="quantity" HeaderText="Pieces" SortExpression="quantity"
                HeaderToolTip="Quantity in pieces of sku" DataSummaryCalculation="ValueSummation"
                DataFooterFormatString="{0:N0}" FooterToolTip="Total pieces">
                <ItemStyle HorizontalAlign="Right" />
                <FooterStyle HorizontalAlign="Right" />
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="assigned_fpk_location" HeaderText="Assign FPK Loc" AccessibleHeaderText="FPKLocation"
                SortExpression="assigned_fpk_location" NullDisplayText="No Location" HeaderToolTip="Location assigned to cartons which are on the pallet">
            </eclipse:MultiBoundField>
            <eclipse:MultiBoundField DataFields="req_assign_date" HeaderText="Ctn Assigned On" HideEmptyColumn="true"
                SortExpression="req_assign_date" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}">
            </eclipse:MultiBoundField>
            <jquery:IconField HeaderText="Carton In Suspense" DataField="suspense_date" DataFieldValues="TRUE"
                HeaderToolTip="Status of the carton whether the carton is in suspense or not."
                IconNames="ui-icon-check" SortExpression="suspense_date" ItemStyle-HorizontalAlign="Center" />
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

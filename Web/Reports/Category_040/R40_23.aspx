<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" Title="Pallet History"  %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 6518 $
 *  $Author: hsingh $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Reports/Category_040/R40_23.aspx $
 *  $Id: R40_23.aspx 6518 2014-03-24 12:18:03Z hsingh $
 * Version Control Template Added.
--%>
<script runat="server">
#pragma warning disable
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Description" content="For the specified Pallet the report displays the Cartons,Locations and the employee name with there date and time when the pallet was stored in the DC along with the SKUs and the quantity." />
    <meta name="ReportId" content="40.23" />
	<meta name="ChangeLog" content="We have now added five new columns for showing SKU details and the quantity.
| We have added a new filter for the user where the user can filter out the data on the basis of no. of days i.e for how long the user want to see the pallet history."/>
    <meta name="Browsable" content="true" /> 
    <meta name="Version" content="$Id: R40_23.aspx 6518 2014-03-24 12:18:03Z hsingh $" />   
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <jquery:Tabs runat="server" ID="tabs">
        <jquery:JPanel ID="JPanel1" runat="server" HeaderText="Filters">
            <eclipse:TwoColumnPanel ID="TwoColumnPanel1" runat="server">
                <eclipse:LeftLabel ID="LeftLabel2" runat="server" Text="Pallet ID" />
                <i:TextBoxEx ID="tbPalletID" runat="server" QueryString="pallet_id">
                    <Validators>
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
               
                <eclipse:LeftLabel ID="LeftLabel1" runat="server" Text="Virtual Warehouse" />
                <d:VirtualWarehouseSelector ID="ctlVwh" runat="server" ShowAll="true"
                    ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>" ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" />
                  <eclipse:LeftLabel ID="lblNoDays" runat="server" Text="Show records of last" />
                <i:TextBoxEx ID="tbNoDays" runat="server" QueryString="no_of_days" Text="30" ToolTip="Pass the number of days. Report will show the information from the days passed till today. By default 30 no. of days" MaxLength="3" Width="125px">
                    <Validators>
                        <i:Value Min="1" Max="180" ValueType="Integer" />
                        <i:Required />
                    </Validators>
                </i:TextBoxEx>
                days.  
            </eclipse:TwoColumnPanel>
            
          
        </jquery:JPanel>
        <jquery:JPanel ID="JPanel2" runat="server" HeaderText="Sorting">
            <jquery:SortColumnsChooser ID="SortColumnsChooser1" runat="server" GridViewExId="gv"
                EnableGroupBy="true" />
        </jquery:JPanel>
    </jquery:Tabs>
    <uc2:ButtonBar2 ID="ButtonBar1" runat="server" /> 
    <oracle:OracleDataSource ID="ds" runat="server" ConnectionString="<%$ ConnectionStrings:DCMSLIVE %>"
        ProviderName="<%$ ConnectionStrings:DCMSLIVE.ProviderName %>" CancelSelectOnNullParameter="true" >
          <SelectSql>
       WITH PALLET_HISTORY AS

 (SELECT SRPD.CARTON_ID AS CARTON_ID,

         SRPD.TO_LOCATION_ID AS TO_LOCATION_ID,
         
         SRPD.FROM_LOCATION_ID AS FROM_LOCATION_ID,
         
         SRPD.MODULE_CODE AS MODULE_CODE,
         
         SCD.STYLE AS STYLE,
         
         SCD.COLOR AS COLOR,
         
         SCD.DIMENSION AS DIMENSION,
         
         SCD.SKU_SIZE AS SKU_SIZE,
         
         scd.quantity AS quantity,
         
         SRPD.INSERTED_BY AS INSERTED_BY,
         
         SRPD.INSERT_DATE AS INSERT_DATE,
         
         SRPD.VWH_ID AS VWH_ID
  
    FROM SRC_CARTON_PROCESS_DETAIL SRPD
  
   LEFT OUTER JOIN SRC_CARTON SC
  
      ON SC.CARTON_ID = SRPD.CARTON_ID
  
   LEFT OUTER JOIN SRC_CARTON_DETAIL SCD
  
      ON SC.CARTON_ID = SCD.CARTON_ID
  
   WHERE (SRPD.FROM_PALLET_ID =:pallet_id OR SRPD.TO_PALLET_ID =:pallet_id)
        
     AND SRPD.INSERT_DATE &gt; SYSDATE - cast(:no_of_days as number)
              <if>AND SRPD.VWH_ID = :vwh_id</if>
              
  
  UNION ALL
  
  SELECT SRPD.CARTON_ID AS CARTON_ID,
         
         SRPD.TO_LOCATION_ID AS TO_LOCATION_ID,
         
         SRPD.FROM_LOCATION_ID AS FROM_LOCATION_ID,
         
         SRPD.MODULE_CODE AS MODULE_CODE,
         
         MS.STYLE AS STYLE,
         
         MS.COLOR AS COLOR,
         
         MS.DIMENSION AS DIMENSION,
         
         MS.SKU_SIZE AS SKU_SIZE,
         
         soc.total_carton_quantity AS quantity,
         
         SRPD.INSERTED_BY AS INSERTED_BY,
         
         SRPD.INSERT_DATE AS INSERT_DATE,
         
         SRPD.VWH_ID AS VWH_ID
  
    FROM SRC_CARTON_PROCESS_DETAIL SRPD
  
   LEFT OUTER JOIN SRC_OPEN_CARTON SOC
  
      ON SRPD.CARTON_ID = SOC.CARTON_ID
  
   INNER JOIN MASTER_SKU MS
  
      ON SOC.SKU_ID = MS.SKU_ID
  
   WHERE (SRPD.FROM_PALLET_ID =:pallet_id OR SRPD.TO_PALLET_ID =:pallet_id )
        
     AND SRPD.INSERT_DATE &gt; SYSDATE - cast(:no_of_days as number)
               <if>AND SRPD.VWH_ID = :vwh_id</if>
  
  )

SELECT CARTON_ID AS CARTON_ID,
       
       FROM_LOCATION_ID AS FROM_LOCATION_ID,
       
       TO_LOCATION_ID TO_LOCATION_ID,
       MODULE_CODE AS module_code,
      
       VWH_ID AS VWH_ID,
       
       MAX(STYLE) AS STYLE,
       
       MAX(COLOR) AS COLOR,
       
       MAX(DIMENSION) AS DIMENSION,
       
       MAX(SKU_SIZE) AS SKU_SIZE,
       
       MAX(quantity) AS quantity,
       
       MAX(INSERTED_BY) AS INSERTED_BY,
       
       INSERT_DATE AS INSERT_DATE

  FROM PALLET_HISTORY PH



 GROUP BY CARTON_ID,
          
          FROM_LOCATION_ID,
          
          TO_LOCATION_ID,  
              MODULE_CODE,     
          INSERT_DATE,
          
          VWH_ID

          </SelectSql> 
        <SelectParameters>
            <asp:ControlParameter ControlID="ctlVwh" Direction="Input" Type="String" Name="vwh_id" />
            <asp:ControlParameter ControlID="tbPalletID" Direction="Input" Type="String" Name="pallet_id" />
            <asp:ControlParameter ControlID="tbNoDays" Type="Int32" Direction="Input" Name="no_of_days" />
        </SelectParameters>
    </oracle:OracleDataSource>
    <jquery:GridViewEx ID="gv" runat="server" AutoGenerateColumns="false" ShowFooter="true"
        AllowSorting="true" DefaultSortExpression="module_code;$;from_location_id;to_location_id" DataSourceID="ds">
        <Columns>
            <eclipse:SequenceField />
            <asp:BoundField DataField="module_code" HeaderText="Module Code" SortExpression="module_code" />
            <asp:BoundField DataField="carton_id" HeaderText="Carton" SortExpression="carton_id" />
            <asp:BoundField HeaderText="SKU|Style" DataField="STYLE" SortExpression="STYLE"/>
            <asp:BoundField HeaderText="SKU|Color" DataField="COLOR"  SortExpression="COLOR"/>
            <asp:BoundField HeaderText="SKU|Dimension" DataField="DIMENSION" SortExpression="DIMENSION" />
            <asp:BoundField HeaderText="SKU|Sku Size" DataField="SKU_SIZE" SortExpression="SKU_SIZE" />
            <eclipse:MultiBoundField HeaderText="Quantity" DataFields="quantity" SortExpression="quantity" ItemStyle-HorizontalAlign="Right" DataSummaryCalculation="ValueSummation" DataFormatString="{0:N0}" DataFooterFormatString="{0:N0}" FooterStyle-HorizontalAlign="Right" />           
            <asp:BoundField DataField="from_location_id" HeaderText="From Location" SortExpression="from_location_id" />
            <asp:BoundField DataField="to_location_id" HeaderText="To Location" SortExpression="to_location_id" />
            <asp:BoundField DataField="inserted_by" HeaderText="User" SortExpression="inserted_by" />
            <asp:BoundField DataField="insert_date" HeaderText="Inserted Date and Time" SortExpression="insert_date" DataFormatString="{0:MM/dd/yyyy HH:mm:ss}"/>
            <asp:BoundField DataField="vwh_id" HeaderText="VWh" SortExpression="vwh_id" /> 
        </Columns>
    </jquery:GridViewEx>
</asp:Content>

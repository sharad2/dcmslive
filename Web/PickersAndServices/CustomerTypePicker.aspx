<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CustomerTypePicker.aspx.cs" 
Inherits="PickersAndServices_CustomerTypePicker" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <jquery:JQueryScriptManager runat="server" />
</head>
<body>
    <form id="CustomerTypePicker" runat="server">
    <div>
        <oracle:OracleDataSource runat="server" ID="dsCustomerTypes" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
            ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>" CancelSelectOnNullParameter="true">
                <SelectSql>
                    select tct.customer_type, 
                        tct.customer_type ||' - ' || tct.description AS description, 
                        tct.subgroup_flag 
                        from tab_customer_type tct 
                    order by tct.description
                </SelectSql>
            </oracle:OracleDataSource>
            
        <i:CheckBoxListEx runat="server" ID="cblCustomerTypes" DataSourceID="dsCustomerTypes"
            DataTextField="description" DataValueField="customer_type" DataSelectedField="subgroup_flag"
            DataCheckedValue="Y" ClientIDMode="Static" QueryString="customer_types" FriendlyName="Customer Types"
            OnClientChange="function(e){
               var selectedVals = $(this).checkBoxListEx('values');
              
               $('#CustomerTypePicker #tb_CtpCustomerType').val(selectedVals);
            }">
            <Validators>
                <i:Required />
            </Validators>
        </i:CheckBoxListEx>
        Current Selection:
        <i:TextBoxEx runat="server" ID="tb_CtpCustomerType" ClientIDMode="Static" ReadOnly="true"
            FriendlyName="Customer Type">
        </i:TextBoxEx>
        <i:ButtonEx ID="btnCtpOk" runat="server" Action="Submit" Text="Ok" ClientIDMode="Static"
          ClientVisible="AjaxHidden" OnClick="btnCtpOk_Click" />
    </div>
    </form>
</body>
</html>

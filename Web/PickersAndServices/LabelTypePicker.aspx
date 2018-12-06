<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LabelTypePicker.aspx.cs" Inherits="PickersAndServices_LabelTypePicker" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <jquery:JQueryScriptManager runat="server" />
</head>
<body>
     <form id="LabelTypePicker" runat="server">
    <div>
        <oracle:OracleDataSource runat="server" ID="dsLableTypes" ConnectionString="<%$ ConnectionStrings:dcmslive %>"
            ProviderName="<%$ ConnectionStrings:dcmslive.ProviderName %>">
    <SelectSql>
        SELECT tsl.label_id, tsl.label_id ||' - ' || tsl.description as description
          FROM tab_style_label tsl
   WHERE tsl.inactive_flag IS NULL ORDER BY tsl.description
    </SelectSql>
   </oracle:OracleDataSource>
        <i:CheckBoxListEx ID="cblLabelTypes" runat="server" DataSourceID="dsLableTypes"
            DataTextField="description" DataValueField="label_id" ClientIDMode="Static"
            QueryString="label_id" FriendlyName="Label Types" WidthItem="20em">
        </i:CheckBoxListEx>
        <i:ButtonEx runat="server" ClientVisible="AjaxHidden" ID="ltp_btnGo" Text="Go" Action="Submit"
            CausesValidation="true" OnClick="ltp_btnGo_Click" />
        <i:ValidationSummary ID="ValidationSummary1" runat="server" />
    </div>
    </form>
</body>
</html>

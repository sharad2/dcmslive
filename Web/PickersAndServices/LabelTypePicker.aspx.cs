using System;
using System.Web.Script.Serialization;

public partial class PickersAndServices_LabelTypePicker : PageBase
{
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }
    protected void ltp_btnGo_Click(object sender, EventArgs e)
    {
        this.Response.ContentType = "application/json";
        JavaScriptSerializer ser = new JavaScriptSerializer();
        string s = ser.Serialize(cblLabelTypes.SelectedValues);
        this.Response.StatusCode = 205;
        this.Response.Write(s);
        this.Response.End();
    }
}
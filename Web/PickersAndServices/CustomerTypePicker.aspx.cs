using System;
using System.Web.Script.Serialization;

public partial class PickersAndServices_CustomerTypePicker : PageBase
{
    protected override void OnInit(EventArgs e)
    {
        cblCustomerTypes.DataBound += new EventHandler<EventArgs>(cblCustomerTypes_DataBound);
        base.OnInit(e);
    }

    protected void cblCustomerTypes_DataBound(object sender, EventArgs e)
    {
        tb_CtpCustomerType.Text = cblCustomerTypes.QueryStringValue;
    }

    /// <summary>
    /// Return selected customers as JSON
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCtpOk_Click(object sender, EventArgs e)
    {
        this.Response.ContentType = "application/json";
        JavaScriptSerializer ser = new JavaScriptSerializer();
        string s = ser.Serialize(tb_CtpCustomerType.Text); ;
        this.Response.StatusCode = 205;
        this.Response.Write(s);
        this.Response.End();
    }
}
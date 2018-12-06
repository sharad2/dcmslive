using System;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Oracle.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;

namespace DcmsDatabase.Web.Selectors
{
    [Obsolete("Use Autocomplete instead")]
    public class CustomerTypeSelector:DropDownListEx
    {
        public CustomerTypeSelector()
        {
            this.QueryString = "customer_type";
            this.FriendlyName = "Customer Type";
        }

        [DefaultValue("false")]
        [Browsable(true)]
        public bool ShowAll { get; set; }

        public string ProviderName { get; set; }

        [Browsable(true)]
        [
              DefaultValue(""),
              EditorAttribute(typeof(System.Web.UI.Design.ConnectionStringEditor),
                             typeof(System.Drawing.Design.UITypeEditor)),
              Category("Data"),
              Description("The connection string to retrieve labels")
            ]
        public string ConnectionString { get; set; }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            DataBind();
        }

        protected override void PerformDataBinding()
        {
            //base.PerformDataBinding();
            if (this.ShowAll)
            {
                //this.AppendDataBoundItems = true;
                DropDownItem ddi = new DropDownItem();
                ddi.Text = "(All)";
                ddi.Value = string.Empty;
                ddi.Persistent =  DropDownPersistenceType.Always;
                this.Items.Add(ddi);
            }

            var customerType = GetCustomerType(this.ConnectionString, this.ProviderName);
            foreach (var item in customerType)
            {
                this.Items.Add(item);
            }
        }

        public static DropDownItem[] GetCustomerType(string connectString, string providerName)
        {
            const string QUERY = @"
        select tct.customer_type, tct.description from tab_customer_type tct order by tct.description
";

            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ConnectionString = connectString;
                ds.SelectSql = QUERY;
                ds.ProviderName = providerName;
                ds.SysContext.ModuleName = "Customer Type";
                //ds.CancelSelectOnValidationFailure = false;
                return (from object row in ds.Select(DataSourceSelectArguments.Empty)
                        select new DropDownItem()
                        {
                            Text = string.Format("{0}: {1}", DataBinder.Eval(row, "customer_type"),
                                                    DataBinder.Eval(row, "description")),
                            Value = DataBinder.Eval(row, "customer_type", "{0}")
                        }).ToArray();
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            this.EnsureDataBound(true);
        }
    }
}

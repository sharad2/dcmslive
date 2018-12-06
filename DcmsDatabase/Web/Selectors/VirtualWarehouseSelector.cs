using System;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;
using EclipseLibrary.WebForms.Oracle;

namespace DcmsDatabase.Web.Selectors
{
    public class VirtualWarehouseSelector:DropDownListEx2
    {
        /// <summary>
        /// Preset to default values. 
        /// </summary>
        public VirtualWarehouseSelector()
        {
            this.QueryString = "vwh_id";
            this.FriendlyName = "Virtual Warehouse";
            this.UseCookie = CookieUsageType.None;
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
              Description("The connection string to retrieve virtual warehouse")
        ]
        public string ConnectionString { get; set; }

        protected override void PerformDataBinding()
        {
            //base.PerformDataBinding();
            var virtualwarehouses = GetVwh(this.ConnectionString, this.ProviderName);
            if (this.ShowAll)
            {
                DropDownItem ddi = new DropDownItem()
                {
                    Text = "(All)"
                };
                this.Items.Add(ddi);
            }
            foreach (var item in virtualwarehouses)
            {
                this.Items.Add(item);
            }
        }

        public static DropDownItem[] GetVwh(string connectString, string providerName)
        {
            const string strQuery = "SELECT vwh_id AS vwh_id, description AS description FROM <proxy/>tab_virtual_warehouse ORDER BY vwh_id";
            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ProviderName = providerName;
                ds.SysContext.ModuleName = "Retrieving Vwh";
                ds.ConnectionString = connectString;
                ds.SelectSql = strQuery;
                //ds.CancelSelectOnValidationFailure = false;

                return (from object row in ds.Select(DataSourceSelectArguments.Empty)
                        select new DropDownItem()
                        {
                            Text = string.Format("{0}: {1}", DataBinder.Eval(row, "vwh_id"),
                               DataBinder.Eval(row, "description")),
                            Value = DataBinder.Eval(row, "vwh_id", "{0}"),

                        }).ToArray();
            }

        }


        protected override void OnPreRender(EventArgs e)
        {
            EnsureDataBound(true);
            base.OnPreRender(e);
        }
    }
}

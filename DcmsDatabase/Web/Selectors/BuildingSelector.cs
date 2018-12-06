using System;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;
using EclipseLibrary.WebForms.Oracle;

namespace DcmsDatabase.Web.Selectors
{
    /// <summary>
    /// 2 Feb 2009: Removed the QueryString override since calling EnsureDataBoud() from there is leading to exceptions.
    /// </summary>
    public class BuildingSelector:DropDownListEx2
    {
        public BuildingSelector()
        {
            this.QueryString = "building_id";
            this.FriendlyName = "Warehouse Location";
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
              Description("The connection string to retrieve buildings")
        ]
        public string ConnectionString { get; set; }

        protected override void PerformDataBinding()
        {
            //base.PerformDataBinding();
            var buildings = GetBuildings(this.ConnectionString, this.ProviderName);
             if (this.ShowAll)
                {
                    DropDownItem ddi = new DropDownItem()
                    {
                        Text = "(All)"
                    };
                    this.Items.Add(ddi);
                }
            foreach (var item in buildings)
            {
                this.Items.Add(item);
            }
        }

        public static DropDownItem[] GetBuildings(string connectString, string providerName)
        {
            const string strQuery = "select warehouse_location_id, description AS description from <proxy/>tab_warehouse_location order by 1";
            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ProviderName = providerName;
                ds.SysContext.ModuleName = "Retrieving Buildings";
                ds.ConnectionString = connectString;
                ds.SelectSql = strQuery;
                //ds.CancelSelectOnValidationFailure = false;
               
                    return (from object row in ds.Select(DataSourceSelectArguments.Empty)
                            select new DropDownItem()
                            {
                                Text = string.Format("{0}: {1}", DataBinder.Eval(row, "warehouse_location_id"),
                                   DataBinder.Eval(row, "description")),
                                Value = DataBinder.Eval(row, "warehouse_location_id", "{0}"),

                            }).ToArray();
                }
            
        }

        protected override void OnPreRender(EventArgs e)
        {
            EnsureDataBound(true);
            base.OnPreRender(e);
        }

        //public override string QueryStringValue
        //{
        //    get
        //    {
        //        if (!this.ShowAll)
        //        {
        //            EnsureDataBound();
        //        }
        //        return base.QueryStringValue;
        //    }
        //    set
        //    {
        //        base.QueryStringValue = value;
        //    }
        //}
    }
}

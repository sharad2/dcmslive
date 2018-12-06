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
    /// All the labels will be showon in combo list.
    /// </summary>
    public class StyleLabelSelector : DropDownListEx2
    {
        public StyleLabelSelector()
        {
            this.QueryString = "label_id";
            this.FriendlyName = "Style Label";
            this.UseLabelGroup = true;
        }

        [DefaultValue("false")]
        [Browsable(true)]
        public bool ShowAll { get; set; }

        public string ProviderName { get; set; }
        public bool UseLabelGroup { get; set; }

        

        [Browsable(true)]
        [
              DefaultValue(""),
              EditorAttribute(typeof(System.Web.UI.Design.ConnectionStringEditor),
                             typeof(System.Drawing.Design.UITypeEditor)),
              Category("Data"),
              Description("The connection string to retrieve labels")
        ]
        public string ConnectionString { get; set; }



        protected override void PerformDataBinding()
        {
            //base.PerformDataBinding();
            this.Items.Clear();
            if (this.ShowAll)
            {
                DropDownItem ddi = new DropDownItem()
                {
                    Text = "(All)"
                };
                this.Items.Add(ddi);
            }

            var labels = GetLabels(this.ConnectionString, this.ProviderName, this.UseLabelGroup);

            foreach (var item in labels)
            {
                this.Items.Add(item);
            }

        }


        public static DropDownItem[] GetLabels(string connectString, string providerName, bool labelGroup)
        {

            string QUERY;

            if (labelGroup)
            {

                QUERY = @"
select tsl.label_id as label_id,
       MAX(twl.warehouse_location_id) as max_warehouse_location_id,
       MAX(twl.description) as building_description,
       COUNT(DISTINCT twl.warehouse_location_id) as count_warehouse_location_id,
       MAX(tsl.description) as label_description
  from <proxy />tab_style_label tsl
  left outer join <proxy />tab_label_group tlg on tsl.label_id = tlg.label_id
  left outer join <proxy />tab_warehouse_location twl on tlg.label_group =
                                                twl.label_group
 group by tsl.label_id
 order by tsl.label_id
";
            }

            else
            {
                QUERY = @"select tsl.label_id as label_id,      
      tsl.description as label_description
  from <proxy />tab_style_label tsl
 order by tsl.label_id";

            }


            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ConnectionString = connectString;
                ds.SelectSql = QUERY;
                ds.ProviderName = providerName;
                ds.SysContext.ModuleName = "Reteriving labels";
                //ds.CancelSelectOnValidationFailure = false;
                var query = from object row in ds.Select(DataSourceSelectArguments.Empty)
                            select new DropDownItem()
                            {
                                Text = string.Format("{0}: {1}", DataBinder.Eval(row, "label_id"),
                                    DataBinder.Eval(row, "label_description")),
                                Value = DataBinder.Eval(row, "label_id", "{0}")
                            };

                return query.ToArray();
            }
        }


        protected override void OnPreRender(EventArgs e)
        {
            EnsureDataBound(true);
            base.OnPreRender(e);
        }
    }
}

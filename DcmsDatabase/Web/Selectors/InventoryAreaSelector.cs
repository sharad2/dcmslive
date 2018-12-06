using System;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;
using EclipseLibrary.WebForms.Oracle;

namespace DcmsDatabase.Web.Selectors
{


    /// <summary>
    /// All the Carton and SKU areas will be showon in combo list. 
    /// By default all the areas are shown.
    /// You can specify StorageAreaType if you are intrested in any one Carton or SKU areas. 
    /// [Deepak Bhatt] TODO: Handle StoresWhat
    /// </summary>
    public class InventoryAreaSelector : DropDownListEx2, IPostBackDataHandler
    {

        //private readonly Collection<DropDownItem> _items;
        public enum StoresWhat
        {
            All,
            CTN,
            SKU
        }

        //// <summary>
        //// Gets selected item
        //// </summary>
        //public override DropDownItem SelectedItem
        //{
        //    get
        //    {
        //        return base.SelectedItem;
        //    }
        //}
       
        public InventoryAreaSelector()
        {
            this.QueryString = "inventory_storage_area";
            this.StorageAreaType = StoresWhat.All;
            this.UsableInventoryAreaOnly = true;
            this.DisplayStorageTypeGroups = true;
        }

        /// <summary>
        /// Specify whether CTN or SKU
        /// </summary>
        [Browsable(true)]
        public StoresWhat StorageAreaType { get; set; }

        [Browsable(true)]
        [DefaultValue(true)]
        public bool UsableInventoryAreaOnly { get; set; }

        [Browsable(true)]
        [Themeable(true)]
        [DefaultValue(true)]
        public bool DisplayStorageTypeGroups { get; set; }

        [Browsable(true)]
        [
              DefaultValue(""),
              EditorAttribute(typeof(System.Web.UI.Design.ConnectionStringEditor),
                             typeof(System.Drawing.Design.UITypeEditor)),
              Category("Data"),
              Description("The connection string to retrieve carton area")
            ]
        public string ConnectionString { get; set; }

        public string ProviderName { get; set; }

        public bool ShowAll { get; set; }

        /// <summary>
        /// Rerurns corresponding area type of selected area.
        /// </summary>
        [Browsable(false)]
        public StoresWhat SelectedStorageAreaType
        {
            get
            {
                DropDownItem li = this.Items.FirstOrDefault(p => p.Value == this.Value);
                if (li == null || string.IsNullOrEmpty(li.OptionGroup))
                {
                    return StoresWhat.All;
                }
                else
                {
                    return (StoresWhat)Enum.Parse(typeof(StoresWhat), li.OptionGroup);
                }
            }
        }


        /// <summary>
        /// Binding data to the control
        /// </summary>
        protected override void PerformDataBinding()
        {



            //this.Items.Clear();
            if (this.ShowAll)
            {
                DropDownItem li = new DropDownItem();
                li.Text = "(Show All)";
                li.Value = string.Empty;
                li.Persistent = DropDownPersistenceType.Always;
                this.Items.Add(li);
            }

            string storesWhat = string.Empty;
            if (this.StorageAreaType != StoresWhat.All)
            {
                storesWhat = this.StorageAreaType.ToString();

            }

            string usableInventory = string.Empty;

            if (UsableInventoryAreaOnly)
            {
                usableInventory = "true";

            }

            var areas = GetAreas(this.ConnectionString, this.ProviderName, storesWhat, usableInventory);

            foreach (var item in areas)
            {
                if (this.StorageAreaType != StoresWhat.All || !this.DisplayStorageTypeGroups)
                {
                    item.OptionGroup = string.Empty;
                }
                this.Items.Add(item);
            }

        }

        /// <summary>
        /// If you are calling from a webmethod then pass storesWhat = CTN for getting carton area, SKU for getting SKU areas.
        /// If you want to select all areas pass empty string.
        /// Pass usableInventory as "true" if you want to select only usable inventory areas otherwise pass empty.
        /// </summary>
        /// <param name="connectString"></param>
        /// <param name="providerName"></param>
        /// <param name="storesWhat"></param>
        /// <param name="usableInventory"></param>
        /// <returns></returns>
        public static DropDownItem[] GetAreas(string connectString, string providerName, string storesWhat, string usableInventory)
        {
            string strQuery = @"
select inventory_storage_area,
    short_name || ':' || description as description,
    stores_what
from tab_inventory_area
where 1 = 1
<if>AND stores_what = :stores_what</if>
<if c='$unusable_inventory'>AND unusable_inventory IS NULL</if>
order by short_name,warehouse_location_id
";

            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ConnectionString = connectString;
                ds.SelectSql = strQuery;
                ds.ProviderName = providerName;
                ds.SysContext.ModuleName = "Selecting Areas";
                //ds.CancelSelectOnValidationFailure = false;
                ds.SelectParameters.Add("stores_what", DbType.String, storesWhat);
                ds.SelectParameters.Add("unusable_inventory", DbType.String, usableInventory);

                var query = from object row in ds.Select(DataSourceSelectArguments.Empty)
                            select new DropDownItem()
                            {
                                Text = string.Format("{0}", DataBinder.Eval(row, "description")),
                                Value = DataBinder.Eval(row, "inventory_storage_area", "{0}"),
                                OptionGroup = DataBinder.Eval(row, "stores_what", "{0}")
                            };

                return query.ToArray();
            }


        }

        /// <summary>
        /// Ensuring control is populated before its Propertis accesses its value.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInit(EventArgs e)
        {
            EnsureDataBound(false);
            base.OnInit(e);
        }


    }
}

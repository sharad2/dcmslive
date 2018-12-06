using System;
using System.Collections;
using System.Data;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;
using EclipseLibrary.WebForms.Oracle;

namespace DcmsDatabase.Web.Selectors
{
    public enum PrinterType
    {
        All,
        Laser,
        Label
    }
    /// <summary>
    /// Provides you property PrinterType, you use use this to set the printer_type of your intrest. For example,
    /// for carton ticket printing you will set the printer type as label and we will only select label printers.
    /// The selected printer is stored in session state and is shared across all instances of the control.
    /// This means that if you select printer on one page, you will see it as the default on every other
    /// page which uses this control.
    /// This control also provides client side validation if you do not select a printer.
    /// TODO: Discuss how to show printer required message while validating in server.
    /// 
    /// </summary>
    public class PrinterSelector : DropDownListEx2
    {

        public PrinterSelector()
        {
            this.QueryString = "printer_name";
            this.FriendlyName = "Printer";
        }

        public string ConnectionString { get; set; }

        public PrinterType PrinterType { get; set; }

        public string ProviderName { get; set; }

        //protected override void OnInit(EventArgs e)
        //{
        //    base.OnInit(e);

        //    //SetValueFromSession();
        //}

        protected override void OnLoad(EventArgs e)
        {
            DataBind();
            base.OnLoad(e);
        }

        protected override void PerformDataBinding()
        {
            //base.PerformDataBinding();

            //            const string strQuery = @"
            //select
            //    tabprinter.name AS name,
            //    tabprinter.description AS description,
            //    [$:printer_type$NULL$][$not(:printer_type)$tabprinter.printer_type$] AS printer_type
            //from tab_printer tabprinter 
            //where 1 = 1
            //[$:printer_type$AND printer_type = :printer_type$]
            //order by tabprinter.description";
            //            using (OracleDataSource ds = new OracleDataSource(this.ConnectionString, strQuery))
            //            {
            //                ds.ProviderName = this.ProviderName;
            //                ds.SysContext.ModuleName = this.Page.Title;
            //                ds.CancelSelectOnValidationFailure = false;
            //                ds.SelectParameters.Add("printer_type", DbType.String, GetPrinterType());
            //                this.Items.Clear();
            //                var query = from object row in ds.Select(DataSourceSelectArguments.Empty)
            //                            select new DropDownItem()
            //                            {
            //                                Text = string.Format("{0}: {1}", DataBinder.Eval(row, "name"),
            //                                   DataBinder.Eval(row, "description")),
            //                                Value = DataBinder.Eval(row, "name", "{0}"),
            //                                OptionGroup = DataBinder.Eval(row, "printer_type", "{0}")
            //                            };
            var printers = GetPrinters(this.ConnectionString, this.ProviderName, GetPrinterType());
            foreach (var item in printers)
            {
                this.Items.Add(item);
            }
        }

        /// <summary>
        /// This is static to make it possible to call from a web service
        /// </summary>
        /// <param name="connectString"></param>
        /// <param name="providerName"></param>
        /// <param name="printerType"></param>
        /// <returns></returns>
        public static DropDownItem[] GetPrinters(string connectString, string providerName, string printerType)
        {
            const string strQuery = @"
select
    tabprinter.name AS name,
    tabprinter.description AS description,
<if c='$printer_type'>
printer_type As printer_type
</if>
<else>
NULL as printer_type
</else>
from <proxy />tab_printer tabprinter 
where 1 = 1
<if c='$printer_type'>
AND upper(printer_type) = upper(:printer_type)
</if>
order by lower(name)";
            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ProviderName = providerName;
                ds.ConnectionString = connectString;
                ds.SelectSql = strQuery;
                ds.SysContext.ModuleName = "Retrieving printers";
                //ds.CancelSelectOnValidationFailure = false;
                ds.SelectParameters.Add("printer_type", DbType.String, printerType);
                return (from object row in ds.Select(DataSourceSelectArguments.Empty)
                        select new DropDownItem()
                        {
                            Text = string.Format("{0}: {1}", DataBinder.Eval(row, "name"),
                               DataBinder.Eval(row, "description")),
                            Value = DataBinder.Eval(row, "name", "{0}"),
                            OptionGroup = DataBinder.Eval(row, "printer_type", "{0}")
                        }).ToArray();
            }
        }

        private string GetPrinterType()
        {
            switch (this.PrinterType)
            {
                case PrinterType.All:
                    return "";

                case PrinterType.Laser:
                    return "laser";

                case PrinterType.Label:
                    return "zebra";

                default:
                    throw new NotImplementedException();
            }
        }

        //        protected override IEnumerable PerformSelect()
        //        {
        //            const string strQuery = @"
        //select tabprinter.name name, tabprinter.description description,
        //tabprinter.printer_type printer_type,tabprinter.name ||' '||'___'||' '|| tabprinter.description nmdesc
        //from tab_printer tabprinter 
        //where 1 = 1
        //[$:printer_type$AND printer_type = :printer_type$]
        //order by tabprinter.description";
        //            this.DataTextField = "description";
        //            this.DataValueField = "name";
        //            this.DataTextFormatString = "{1}: {0}";

        //            using (OracleDataSource ds = new OracleDataSource(this.ConnectionString, strQuery))
        //            {
        //                ds.ProviderName = this.ProviderName;
        //                ds.SysContext.ModuleName = this.Page.Title;
        //                ds.CancelSelectOnValidationFailure = false;
        //                if (string.IsNullOrEmpty(this.PrinterType))
        //                {
        //                    this.DataOptionGroupField = "printer_type";
        //                }
        //                ds.SelectParameters.Add("printer_type", DbType.String, this.PrinterType);
        //                this.AppendDataBoundItems = true;
        //                this.Items.Insert(0, new DropDownItem() { Text = "(Select Printer)" });
        //                return ds.Select(DataSourceSelectArguments.Empty).OfType<object>().ToList();
        //            }

        //        }

        /// <summary>
        /// Save value in session state so that all controls can share the default value
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            this.EnsureDataBound(true);

            //if (this.Context.Session != null)
            //{
            //    this.Context.Session[this.GetType().ToString()] = this.SelectedValue;

            //}

            //JQueryOptions rules = new JQueryOptions();
            //JQueryOptions messages = new JQueryOptions();
            //rules.Add("required", true);
            //messages.Add("required", "{0} is required", this.FriendlyName);
            //JQueryScriptManager.Current.AddValidationRule(this.UniqueID, rules, messages);
        }

        /// <summary>
        /// This function sets the printer value from session state
        /// </summary>

        //protected void SetValueFromSession()
        //{
        //    if (!this.Page.IsPostBack && this.Context.Session != null)
        //    {
        //        string str = string.Format("{0}", this.Context.Session[this.GetType().ToString()]);

        //        if (!string.IsNullOrEmpty(str))
        //        {
        //            this.SelectedValue = str.Trim();
        //        }
        //    }
        //}
    }


}

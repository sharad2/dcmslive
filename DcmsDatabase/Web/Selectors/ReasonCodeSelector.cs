using System;
using System.Collections;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.UI;
using EclipseLibrary.WebForms.Oracle;

namespace DcmsDatabase.Web.Selectors
{
    public enum ReasonType
    {
        All,
        Pickslip
    }
    public class ReasonCodeSelector : DropDownListEx2
    {
        public ReasonCodeSelector()
        {
            this.QueryString = "reason_code";
            this.IsValid = true;
            this.FriendlyName = "Reason Code";
        }

        public string ConnectionString { get; set; }

        public string ProviderName { get; set; }

        public ReasonType ReasonType { get; set; }

        /// <summary>
        /// ModuleCode paramter takes the value of ModuleCode to populate the specific Reason code list
        /// </summary>


        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
        }


        protected override void PerformDataBinding()
        {
            //base.PerformDataBinding();
            this.DataFields = "reason_code,description";
            this.DataValueFormatString = "{0}";
            this.DataTextFormatString = "{0}: {1}";

            var reasonCodes = GetReasonCodes(this.ConnectionString, this.ProviderName, GetReasonType());

            foreach (var item in reasonCodes)
            {
                this.Items.Add(item);
            }
        }

        public static DropDownItem[] GetReasonCodes(string connectString, string providerName, string reasonType)
        {
            const string strQuery = @"
                SELECT reason.reason_code AS reason_code,
                       reason.description AS description
               FROM tab_reason reason WHERE 1 = 1 <if c=""$reasonType = 'Pickslip'""> AND reason.pickslip_cancel_flag = 'Y'</if>";
            using (OracleDataSource ds = new OracleDataSource())
            {
                ds.ConnectionString = connectString;
                ds.SelectSql = strQuery;
                ds.ProviderName = providerName;
                ds.SysContext.ModuleName = "Retrieving reason codes";
                ds.SelectParameters.Add("reasonType", reasonType);
                ds.SelectSql = strQuery;
                //ds.CancelSelectOnValidationFailure = false;
                return (from object row in ds.Select(DataSourceSelectArguments.Empty)
                        select new DropDownItem()
                        {
                            Text = string.Format("{0}: {1}", DataBinder.Eval(row, "reason_code"),
                               DataBinder.Eval(row, "description")),
                            Value = DataBinder.Eval(row, "reason_code", "{0}"),
                        }).ToArray();
            }
        }

        private string GetReasonType()
        {
            switch (this.ReasonType)
            {
                case ReasonType.All:
                    return "";

                case ReasonType.Pickslip:
                    return "Pickslip";

                default:
                    throw new NotImplementedException();
            }
        }


        /// <summary>
        /// EnsureDataBound
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            EnsureDataBound(true);
            base.OnPreRender(e);
        }
    }
}

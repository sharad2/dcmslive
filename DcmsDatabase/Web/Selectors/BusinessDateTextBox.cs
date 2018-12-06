using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Web.JQuery;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.WebForms.Oracle;

namespace DcmsDatabase.Web.Selectors
{
    /// <summary>
    /// Higlights FDC month start date in the calendar.
    /// Set ConvertDefaultDate to automatically convert the default date which is set.
    /// You can find out month start date, week start date, days between current date and month start, etc.
    /// using available properties.
    /// TODO: Decide values for Min, max days, max range, etc.
    /// </summary>
    /// <remarks>
    /// MonthStartDate property returns the month start corresponding to the currently set date.
    /// Month start dates are displayed for +/- 12 months from today
    /// If no data, calendar month is implied.
    /// 1st seven days of month are first week and so on.
    /// 
    /// Month start dates are read from the database and then stored in a static variable. This means that a server restart
    /// will be required before database changes will become visible.
    /// 
    /// Sharad 24 Jul 2009: ControlValueProperty is now CompanionDate. If we are a from/to control then we try to return
    /// the companion's date if our date is null.
    /// </remarks>
    /// 
    public class BusinessDateTextBox : TextBoxEx
    {
        /// <summary>
        /// This should be sorted by start date descending
        /// </summary>
        private static readonly List<DateTime> __monthStartDates;

        /// <summary>
        /// Returns the month start date for any passed year and month.
        /// </summary>
        /// <param name="year"></param>
        /// <param name="month"></param>
        /// <returns></returns>
        public static DateTime GetMonthStartDate(int year, int month)
        {
            DateTime dt = __monthStartDates.Where(p => p.Year == year && p.Month == month).FirstOrDefault();
            // Assume calendar month start date if date not found
            return dt == DateTime.MinValue ? new DateTime(year, month, 1) : dt;
        }

        /// <summary>
        /// Sharad 23 Aug 2011: Retrieving dates for +/- 2 years
        /// </summary>
        static BusinessDateTextBox()
        {
            __monthStartDates = new List<DateTime>(24);
            const string QUERY = @"
SELECT t.month_start_date as month_start_date
FROM tab_fdc_calendar t
where t.fiscal_year &lt;= (:curYear + 2) and t.fiscal_year &gt;= (:curYear - 2)
ORDER BY t.month_start_date DESC
";
            using (OracleDataSource ds = new OracleDataSource(ConfigurationManager.ConnectionStrings["dcmslive"]))
            {
                ds.SelectSql = QUERY;
                ds.SelectParameters.Add("curYear", TypeCode.Int32, DateTime.Today.Year.ToString());
                ds.SysContext.ModuleName = "Month Start Date";

                foreach (var row in ds.Select(DataSourceSelectArguments.Empty))
                {
                    __monthStartDates.Add(Convert.ToDateTime(DataBinder.Eval(row, "month_start_date")));
                }

            }
        }

        private BusinessDateTextBox _associatedControl;

        /// <summary>
        /// If we are neither from, nor to, returns the date.
        /// If we contain a date, always returns our date.
        /// If we do not contain a date, then tries to return the companion's date.
        /// </summary>
        public DateTime? CompanionDate
        {
            get
            {
                DateTime? dt = this.ValueAsDate;
                if (_associatedControl == null || dt != null)
                {
                    return dt;
                }
                return _associatedControl.ValueAsDate;

            }
        }

        /// <summary>
        /// gets the business month start date corresponding to the currently set date
        /// </summary>
        public DateTime? MonthStartDate
        {
            get
            {
                if (this.ValueAsDate == null)
                {
                    return null;
                }
                // _monthStartDates is sorted descending. The first date which is less than current date
                // is the month start date we are interested in. If not found, we return calendar month start date
                var startDate = __monthStartDates.FirstOrDefault(p => p < this.ValueAsDate);
                if (startDate == default(DateTime))
                {
                    // Not found. Return first of the month
                    startDate = new DateTime(this.ValueAsDate.Value.Year, this.ValueAsDate.Value.Month, 1);
                }
                return startDate;
            }
        }

        public DateTime? MonthEndDate
        {
            get
            {
                if (this.ValueAsDate.Value == null)
                {
                    return null;
                }
                // _monthStartDates is sorted descending. Reverse makes it descending.
                // The first date which is more than current date
                // is the month start date of the next month. Subtract 1 day to get month end date of
                // current month.
                var endDate = __monthStartDates.Reverse<DateTime>().FirstOrDefault(p => p >= this.ValueAsDate.Value);
                if (endDate == default(DateTime))
                {
                    // Not found. Return last day of calendar month
                    DateTime nextMonth = this.ValueAsDate.Value.AddMonths(1);
                    endDate = new DateTime(nextMonth.Year, nextMonth.Month, 1);
                }
                return endDate;
            }
        }

        /// <summary>
        /// Simply week start date + 7.
        /// </summary>
        public DateTime? WeekEndDate
        {
            get
            {
                DateTime? weekStartDate = this.WeekStartDate;
                if (weekStartDate == null)
                {
                    return null;
                }
                return weekStartDate.Value.AddDays(7); ;
            }
        }

        public int? DaysFromMonthStart
        {
            get
            {
                if (this.ValueAsDate == null)
                {
                    return null;
                }
                TimeSpan span = this.ValueAsDate.Value - this.MonthStartDate.Value;
                int indexWithinMonth = System.Convert.ToInt32(span.TotalDays);
                return indexWithinMonth;
            }
        }

        /// <summary>
        /// Index of the date set in text box within the business week.
        /// </summary>
        public int? DaysFromWeekStart
        {
            get
            {
                int? indexWithinMonth = this.DaysFromMonthStart;
                if (indexWithinMonth == null)
                {
                    return null;
                }
                return indexWithinMonth.Value % 7;
            }
        }

        public DateTime? WeekStartDate
        {
            get
            {
                int? n = this.DaysFromWeekStart;
                if (n == null)
                {
                    return null;
                }
                DateTime weekStart = this.ValueAsDate.Value.AddDays(-1 * n.Value);
                return weekStart;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            if (!this.Validators.OfType<Date>().Any())
            {
                this.Validators.Add(new Date());
            }
            base.OnInit(e);
        }

        /// <summary>
        /// Defaulting the ToDate textbox to the FromDate if the ToDate is empty.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            var val = this.Validators.OfType<Date>().First();
            //Checking if "From" date is null, then return empty string.
            if (val.DateType == DateType.Default)
            {
                if (this.ValueAsDate == null)
                {
                    this.Text = string.Empty;
                }
            }

            else if (val.DateType == DateType.ToDate)
            {
                _associatedControl = (BusinessDateTextBox)val.GetFromControl(this);
                if (this.ValueAsDate == null)
                {
                    this.Text = _associatedControl.Text;
                }
            }
            base.OnLoad(e);
        }

        protected override void PreCreateScripts()
        {
            this.DatePickerOptions.AddRaw("beforeShowDay", "BusinessDateTextBox_beforeShowDay");
            if (!JQueryScriptManager.Current.IsScriptBlockRegistered("BusinessDateTextBoxScript"))
            {
                // Create global array of month start dates
                List<string> javascriptArray = new List<string>(__monthStartDates.Count);

                string str;
                foreach (DateTime monthStartDate in __monthStartDates)
                {
                    str = string.Format("[{0},{1},{2}]", monthStartDate.Year, monthStartDate.Month - 1, monthStartDate.Day);
                    javascriptArray.Add(str);
                }

                str = string.Format("[{0}]", string.Join(",", javascriptArray.ToArray()));
                string script = Properties.Resources.BusinessDateTextBoxScript.Replace("[[]]", str);
                JQueryScriptManager.Current.RegisterScriptBlock("BusinessDateTextBoxScript", script);
            }
            JQueryScriptManager.Current.RegisterCssBlock("BusinessDateTextBoxStyles", Properties.Resources.BusinessDateTextBoxStyles);
            base.PreCreateScripts();
        }

        public override string DisplayValue
        {
            get
            {
                return string.Format("{0:d}", this.CompanionDate);
            }
        }


        protected override string GetQueryStringValue()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0:d}", this.CompanionDate);
        }
    }
}


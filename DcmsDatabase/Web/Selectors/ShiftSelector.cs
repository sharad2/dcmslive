using System;
using System.ComponentModel;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;
using EclipseLibrary.Web.JQuery.Input;

namespace DcmsDatabase.Web.Selectors
{
    /// <summary>
    /// You can pass the initial value of the shift in the query string shift_number.
    /// Pass 1 for 1st shift and so on. Pass 0 for all shifts or don't pass anything.
    /// </summary>
    /// <remarks>
    /// Sharad 22 Jul 2009: Added function GetShiftNumberClause() 
    /// </remarks>
    public class ShiftSelector : RadioButtonListEx
    {
        private static readonly TimeSpan[] _shifts;

        static ShiftSelector()
        {
            string[] shiftSettings = ConfigurationManager.AppSettings["Shifts"].Split(',');
            _shifts = (from shift in shiftSettings
                       select TimeSpan.FromHours(double.Parse(shift))).ToArray();

        }

        public ShiftSelector()
        {
            //this.RepeatDirection = RepeatDirection.Horizontal;
            //this.RepeatLayout = RepeatLayout.Flow;
            this.FriendlyName = "Shift";
            this.QueryString = "shift_number";
        }

        /// <summary>
        /// Total number of shifts supported. Increase to specify more.
        /// </summary>
        enum Shifts
        {
            First,
            Second,
            Third,
            Fourth,
            Fifth,
            Sixth,
            Seventh,
            Eighth,
            Ninth,
            Tenth,
            Eleventh,
            Twelfth 
        };

        /// <summary>
        /// Adding shifts to the list.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (this.DesignMode)
            {
                return;
            }
            this.Items.Clear();
            string[] shifts = ConfigurationManager.AppSettings["Shifts"].Split(',');

            // Raise exception if specified number of shifts exceeds supported number of shifts
            if (shifts.Length > Enum.GetValues(typeof(Shifts)).Length)
            {
                throw new HttpException("Numbers of Shifts specified exceeds the supported number of shifts.");
            }


            // Need atleast 2 shift-values to make a shift.
            if (shifts.Length < 2)
            {
                throw new HttpException("Must have 2 or more shifts");
            }

            RadioItem li = new RadioItem() { Text = "All" };
            this.Items.Add(li);

            int nCtr = 0;
            DateTime dateFrom;
            DateTime dateTo;
            string strTootltip = string.Empty;
            for (; nCtr < shifts.Length - 1; nCtr++)
            {
                dateFrom = DateTime.Today + TimeSpan.FromHours(double.Parse(shifts[nCtr]));
                dateTo = DateTime.Today + TimeSpan.FromHours(double.Parse(shifts[nCtr + 1]));
                strTootltip = string.Format("{0:t} to {1:t}", dateFrom, dateTo);
                li = new RadioItem() { Text = string.Format("{0}", Enum.GetName(typeof(Shifts), nCtr)), Value = (nCtr + 1).ToString(), ToolTip = strTootltip };
                this.Items.Add(li);
            }
            
            // Adding last shift to the list
            dateFrom = DateTime.Today + TimeSpan.FromHours(double.Parse(shifts[nCtr]));
            dateTo = DateTime.Today + TimeSpan.FromHours(double.Parse(shifts[0]));
            strTootltip = string.Format("{0:t} to {1:t}", dateFrom, dateTo);
            li = new RadioItem() { Text = string.Format("{0}", Enum.GetName(typeof(Shifts), nCtr)), Value = (nCtr + 1).ToString(), ToolTip = strTootltip };
            this.Items.Add(li);

        }


        /// <summary>
        /// Use web.config to determine shift timings. Generates two columns:
        /// 1) shift_number which is 1, 2, 3, etc depending on the shift.
        /// 2) shift_start_date: This is the date on which the shift started. Useful when the time is after midninght.
        /// </summary>
        /// <param name="dbDateColumnName"></param>
        /// <returns></returns>
        /// 
        [Obsolete("Use GetShiftNumberClause() and/or GetShiftDateClause()")]
        public static string GetSelectClause(string dbDateColumnName)
        {
            StringBuilder sb = new StringBuilder();
            BuildShiftNumberClause(dbDateColumnName, sb);
            sb.AppendLine(" AS shift_number,");
            BuildShiftStartDateClause(dbDateColumnName, sb);
            sb.AppendLine(" AS shift_start_date");
            return sb.ToString();
        }

        /// <summary>
        /// Returns
        ///        CASE
        /// WHEN (boxprod.operation_start_date -
        ///      TRUNC(boxprod.operation_start_date)) * 24 BETWEEN 5 AND 14 THEN
        ///  1
        /// WHEN (boxprod.operation_start_date -
        ///      TRUNC(boxprod.operation_start_date)) * 24 BETWEEN 14 AND 23 THEN
        ///  2
        /// ELSE
        ///  3
        /// END
        /// </summary>
        /// <param name="dbDateColumnName"></param>
        /// <returns></returns>
        public static string GetShiftNumberClause(string dbDateColumnName)
        {
            StringBuilder sb = new StringBuilder();
            BuildShiftNumberClause(dbDateColumnName, sb);
            return sb.ToString();
        }

        /// <summary>
        /// It is assumed that e.ReplacementString contains the name of the date column.
        /// </summary>
        /// <param name="e"></param>
        /// <param name="parameterName"></param>
        /// <example>
        /*
         * Query contains this parsing directive: [$ShiftNumberWhere$bp.operation_start_date$]
         * The Command parsing event handler parses it like this:
        protected void ds_CommandParsing(object sender, CommandParsingEventArgs e)
        {
            switch (e.FunctionName)
            {
                case "ShiftNumberWhere":
                    ShiftSelector.HandleShiftNumberWhere(e, "shift_number");
                    break;
            }
        }
        */
        /// </example>
        //[Obsolete]
        //public static void HandleShiftNumberWhere(CommandParsingEventArgs e,
        //    string parameterName)
        //{
        //    if (e.Command.Parameters[parameterName].Value == null)
        //    {
        //        e.Action = CommandParsingAction.IgnoreClause;
        //    }
        //    else
        //    {
        //        string str = ShiftSelector.GetShiftNumberClause(e.ReplacementString);
        //        e.ReplacementString = string.Format(" AND {0} = :{1}", str, parameterName);
        //        e.Action = CommandParsingAction.UseClause;
        //    }
        //}

        /// <summary>
        /// It is assumed that e.ReplacementString contains the name of the date column.
        /// </summary>
        /// <param name="e"></param>
        /// <param name="parameterName"></param>
        /// <example>
        /*
         * Query contains this parsing directive: [$ShiftDateWhere$bp.operation_start_date$]
         * The Command parsing event handler parses it like this:
        protected void ds_CommandParsing(object sender, CommandParsingEventArgs e)
        {
            switch (e.FunctionName)
            {
                case "ShiftDateWhere":
                    ShiftSelector.HandleShiftDateWhere(e, "shift_start_date");
                    break;
            }
        }
        */
        /// </example>
        //[Obsolete]
        //public static void HandleShiftDateWhere(CommandParsingEventArgs e,
        //    string parameterName)
        //{
        //    if (e.Command.Parameters[parameterName].Value == null)
        //    {
        //        e.Action = CommandParsingAction.IgnoreClause;
        //    }
        //    else
        //    {
        //        string str = ShiftSelector.GetShiftDateClause(e.ReplacementString);
        //        e.ReplacementString = string.Format(" AND {0} = :{1}", str, parameterName);
        //        e.Action = CommandParsingAction.UseClause;
        //    }
        //}

        /// <summary>
        /// CASE
        /// WHEN (boxprod.operation_start_date -
        ///      TRUNC(boxprod.operation_start_date)) * 24 <= 5 THEN
        ///  TRUNC(boxprod.operation_start_date - 1)
        /// ELSE
        ///  TRUNC(boxprod.operation_start_date)
        /// END
        /// </summary>
        /// <param name="dbDateColumnName"></param>
        /// <returns></returns>
        public static string GetShiftDateClause(string dbDateColumnName)
        {
            StringBuilder sb = new StringBuilder();
            BuildShiftStartDateClause(dbDateColumnName, sb);
            return sb.ToString();
        }

        private static void BuildShiftStartDateClause(string dbDateColumnName, StringBuilder sb)
        {
            sb.AppendFormat(@"(
   CASE
    WHEN ({0} - TRUNC({0})) * 24 <= {1} THEN TRUNC({0} - 1)
    ELSE TRUNC({0})
END)", dbDateColumnName, _shifts[0].TotalHours);
        }

        private static void BuildShiftNumberClause(string dbDateColumnName, StringBuilder sb)
        {
            sb.AppendLine("(CASE");
            for (int i = 0; i < _shifts.Length; ++i)
            {
                if (i < _shifts.Length - 1)
                {
                    sb.AppendFormat("WHEN ({0} - TRUNC({0})) * 24 BETWEEN {1} AND {2} THEN {3}",
                        dbDateColumnName, _shifts[i].TotalHours, _shifts[i + 1].TotalHours, i + 1);
                }
                else
                {
                    // Last shift
                    sb.AppendFormat("ELSE {0}", i + 1);
                }
                sb.AppendLine();
            }
            sb.AppendLine("END)");
        }

        /// <summary>
        /// If curStartTime is before 7 am (or whatever is given in web.config), 
        /// return previous day 7 am, else return same day 7 am.
        /// If all shifts button is selected, then all work is presumed to be in the first shift.
        /// </summary>
        /// <param name="curStartTime"></param>
        /// <returns></returns>
        public DateTime GetShiftStartTime(DateTime curTime)
        {
            DateTime curDate = new DateTime(curTime.Year, curTime.Month, curTime.Day);
            TimeSpan curSpan = curTime - curDate;
            TimeSpan shiftStart;
            if (string.IsNullOrEmpty(this.Value))
            {
                // First shift
                shiftStart = _shifts[0];
                if (curSpan < shiftStart)
                {
                    // Next day times belong to last shift
                    curDate -= TimeSpan.FromDays(1);
                }
            }
            else
            {
                shiftStart = _shifts.Reverse().FirstOrDefault(p => p < curSpan);
                if (shiftStart == TimeSpan.Zero)
                {
                    // Next day times belong to last shift
                    curDate -= TimeSpan.FromDays(1);
                    shiftStart = _shifts[_shifts.Length - 1];
                }
            }

            DateTime shiftDate = curDate + shiftStart;
            return shiftDate;
        }

        private static readonly TimeSpan _breakDuration = TimeSpan.FromMinutes(30);

        /// <summary>
        /// The time at which each break starts
        /// </summary>
        private static readonly TimeSpan[] _breakStartHours = new TimeSpan[] { TimeSpan.FromHours(12), TimeSpan.FromHours(21) };

        /// <summary>
        /// Number of breaks which have occured within the passed clock hours.
        /// Everything is relative to first shift.
        /// </summary>
        /// <param name="clockHours"></param>
        /// <returns></returns>
        /// <remarks>
        /// Work which is performed during the break should be treated as work performed before the break.
        /// </remarks>
        public int GetNumberofBreaks(TimeSpan clockHours)
        {
            int nShiftIndex = string.IsNullOrEmpty(this.Value) ? 0 : int.Parse(this.Value) - 1;
            // Shift starts at 5:00 am (_shifts[nShiftIndex]); 
            // Break starts at 12:00 noon (p)
            // You worked for 1 hours (clockHours) -> no break
            // You worked for 7 hours (clockHours) -> no break
            // You worked for 8 hours (clockHours) -> 1 break
            int nBreaks = _breakStartHours.Select((p, i) => i >= nShiftIndex && p - _shifts[nShiftIndex] < clockHours)
                .Count(p => p);
            return nBreaks;
        }

        public static TimeSpan BreakDuration
        {
            get
            {
                return _breakDuration;
            }
        }
    }
}

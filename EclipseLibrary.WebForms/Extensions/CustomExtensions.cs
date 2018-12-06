using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Diagnostics;


namespace EclipseLibrary.Web.Extensions
{
    /// <summary>
    /// To use functions in this class, you must explicitly include it in your file since all the functions are written
    /// as extensions. Extension functions are available for Control and TimeSpan classes.
    /// </summary>
    /// <remarks>
    /// <see cref="Format"/> can be used to format a TimeSpan value in a human readable form. For a Control,
    /// you can access their <see cref="Ancestors"/> and <see cref="Descendants"/>.
    /// </remarks>
    public static class CustomExtensions
    {
        /// <summary>
        /// Returns the passed time span value as a readable string
        /// </summary>
        /// <param name="span">The time span to format</param>
        /// <returns>A string representation of the time span, e.g. 2 days 5 hours.</returns>
        /// <remarks>
        /// The value returned depends upon how long the passed <paramref name="span"/> is.
        /// <list type="table">
        /// <listheader>
        /// <term>Value of span</term>
        /// <description>String returned</description>
        /// </listheader>
        /// <item>
        /// <term>
        /// &gt; 6 months
        /// </term>
        /// <description>
        /// Years and months e.g. 5 Years, 3 Months
        /// </description>
        /// </item>
        /// <item>
        /// <term>
        /// 1 day to 6 months
        /// </term>
        /// <description>Number of days, e.g. 60 days</description>
        /// </item>
        /// <item>
        /// <term>
        /// 1 hour to 1 day
        /// </term>
        /// <description>
        /// Number of hours, e.g. 5 hours
        /// </description>
        /// </item>
        /// <item>
        /// <term>
        /// 1 second to 1 hour
        /// </term>
        /// <description>
        /// Minutes and seconds, e.g. 5 minutes, 10 seconds.
        /// </description>
        /// </item>
        /// <item>
        /// <term>
        /// &lt; 1 second
        /// </term>
        /// <description>
        /// Number of milliseconds, e.g. 300 msec.
        /// </description>
        /// </item>
        /// </list>
        /// <para>
        /// Code exists to display singular and plural properly. We say 1 year, not 1 years. Also we will never say
        /// 0 years, 3 months. Instead we will say 3 months only.
        /// </para>
        /// </remarks>
        public static string Format(this TimeSpan span)
        {
            if (Math.Abs(span.TotalDays) >= 1)
            {
                if (Math.Abs(span.TotalDays) > 180)
                {
                    // For durations of one week or more we try to show year and month components
                    string str = string.Empty;
                    int nYears = (int)Math.Floor(span.TotalDays / 365.0);
                    if (nYears > 0)
                    {
                        str = String.Format("{0:N0} Year{1}", nYears, nYears == 1 ? string.Empty : "s");
                    }
                    int nMonths = (int)Math.Round((span.TotalDays - 365 * nYears) / 30.0);
                    if (nMonths > 0)
                    {
                        if (!string.IsNullOrEmpty(str))
                        {
                            str += ", ";
                        }
                        str += String.Format("{0:N0} Months", nMonths);
                    }
                    return str;
                }
                // For durations under six months, we show days and hours
                return string.Format("{0:N0} day{1}{2:' '# hours;'Negative';#}",
                    Math.Floor(span.TotalDays), Math.Floor(span.TotalDays) == 1 ? string.Empty : "s", span.Hours);
            }
            if (Math.Abs(span.TotalHours) >= 1)
            {
                return string.Format("{0:N0}:{1:00} hours", Math.Floor(span.TotalHours), span.Minutes);
            }
            if (Math.Abs(span.TotalMinutes) >= 1)
            {
                double d = Math.Floor(span.TotalMinutes);
                if (d == 1)
                {
                    return string.Format("{0:N0} minute {1:N0} seconds", d, span.Seconds);
                }
                else
                {
                    return string.Format("{0:N0} minutes {1:N0} seconds", d, span.Seconds);
                }
            }
            if (Math.Abs(span.TotalSeconds) >= 15)
            {
                return string.Format("{0:N0} seconds", span.TotalSeconds);
            }
            if (Math.Abs(span.TotalSeconds) >= 5)
            {
                return string.Format("{0:N2} seconds", span.TotalSeconds);
            }
            if (Math.Abs(span.TotalSeconds) >= 1)
            {
                return string.Format("{0:N3} seconds", span.TotalSeconds);
            }
            else
            {
                return string.Format("{0:0 msec;;'Instant'}", span.TotalMilliseconds);
            }
            // Not expected that we will get here. Just call base class
        }

        /// <summary>
        /// The descendants of controls which do not qualify the predicate
        /// are not returned. This is useful if you have no interest in the controls within a <c>TwoColumnPanel</c> or any other container.
        /// It can also enhance performance by minimizing the set of controls which need to be looked at.
        /// </summary>
        /// <param name="ctl">The control whose descendants need to be enumerated</param>
        /// <param name="recurseFilter">A lambda expression which takes a control and returns whether its descendants
        /// should be considered</param>
        /// <returns>An enumerable which can enumerate all descendants of <paramref name="ctl"/></returns>
        /// <remarks>
        /// <para>
        /// A breadth first search is performed. First, controls at the highes levels are enumerated, and then controls at lower
        /// levels are enumerated. LiterControl is not enumerated since it can serve no useful purpose.
        /// </para>
        /// <para>
        /// Inspired by http://weblogs.asp.net/dfindley/archive/2007/06/29/linq-the-uber-findcontrol.aspx
        /// </para>
        /// <para>
        /// Sharad 4 Nov 2010: Fixed bug which enumerated some controls multiple times.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// This example gets the first empty textbox
        /// </para>
        /// <code>
        /// <![CDATA[
        /// TextBox firstEmpty = accountDetails.Descendants()
        ///    .OfType<TextBox>()
        ///    .Where(tb => tb.Text.Trim().Length == 0)
        ///    .FirstOrDefault();
        /// ]]>
        /// </code>
        /// <para>
        /// In this code snippet, we do not want to look at controls within a validation container. Keep in mind
        /// that IValidationContainer controls will still be returned. Their children will not be returned.
        /// </para>
        /// <code>
        /// <![CDATA[
        /// IFilterInput controls = this.Page.Descendants(p => !(p is IValidationContainer)).OfType<IFilterInput>();
        /// foreach (IFilterInput ctl in controls) {
        ///   ...
        /// }
        /// ]]>
        /// </code>
        /// </example>
        public static IEnumerable<Control> Descendants(this Control ctl, Func<Control, bool> recurseFilter = null)
        {
            if (ctl is Page)
            {
                Trace.TraceWarning("Performance warning: Enumerating descendants of page");
            }
            Trace.Indent();

            if (ctl.HasControls())
            {
                var list = ctl.Controls.Cast<Control>().Where(p => !(p is LiteralControl)).ToArray();
                foreach (Control child in list)
                {
#if DEBUG
                    System.Diagnostics.Trace.WriteLine(string.Format("{0}: {1}", child, child.UniqueID));
#endif
                    yield return child;
                }
                foreach (Control grandChild in list
                    .Where(p => p.HasControls() && (recurseFilter == null || recurseFilter(p)))
                    .SelectMany(p => p.Descendants(recurseFilter)))
                {
                    yield return grandChild;
                }
            }
#if DEBUG
            System.Diagnostics.Trace.Unindent();
#endif
        }

        /// <summary>
        /// Returns all ancestors of the passed control
        /// </summary>
        /// <param name="ctl">The control whose ancestors are needed</param>
        /// <param name="includeSelf">Whether the control whose ancestors are sought should be included in the list</param>
        /// <returns></returns>
        public static IEnumerable<Control> Ancestors(this Control ctl, bool includeSelf)
        {
            if (includeSelf)
            {
                yield return ctl;
            }
            Control ctlParent = ctl.Parent;
            while (ctlParent != null)
            {
                yield return ctlParent;
                ctlParent = ctlParent.Parent;
            }

        }
    }
}

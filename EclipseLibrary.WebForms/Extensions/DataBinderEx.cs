using System;
using System.Web.UI;

namespace EclipseLibrary.Web.Utilities
{
    /// <summary>
    /// Provides useful enhancements to the .NET DataBinder class
    /// </summary>
    /// <remarks>
    /// <list type="number">
    /// <item>
    /// <description>Can return strongly typed values using the generic Eval</description>.
    /// </item>
    /// <item>
    /// <description>Is <c>DBNull</c>  aware. Returns default value for the type for DBNull.</description>
    /// </item>
    /// </list>
    /// </remarks>
    public static class DataBinderEx
    {
        /// <summary>
        /// Returns result type casted to T
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="dataItem"></param>
        /// <param name="field"></param>
        /// <returns></returns>
        public static T Eval<T>(object dataItem, string field)
        {
            object obj = DataBinder.Eval(dataItem, field);
            if (obj == null || Convert.IsDBNull(obj))
            {
                return default(T);
            }
            return (T)Convert.ChangeType(obj, typeof(T));
        }

        /// <summary>
        /// If <paramref name="field"/> evaluates to null, returns <paramref name="nullText"/>.
        /// </summary>
        /// <param name="dataItem">The data item to evaluate</param>
        /// <param name="field">The field whose value is sought</param>
        /// <param name="formatString">Format string to apply to the value</param>
        /// <param name="nullText">The string to return if <paramref name="field"/> evaluates to null or DBNull</param>
        /// <returns>string representation of the value</returns>
        /// <remarks>
        /// </remarks>
        /// <example>
        /// <para>
        /// The text property evaluates to 0 when <c>quantity</c> is null.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<eclipse:SiteHyperLink ID="shlSKU" runat="server" Text='<%# DataBinderEx.Eval(Container.DataItem, "quantity", "{0:N0}", "0") %>' />
        /// ]]>
        /// </code>
        /// </example>
        public static string Eval(object dataItem, string field, string formatString, string nullText = "")
        {
            object obj = DataBinder.Eval(dataItem, field);
            if (obj == null || Convert.IsDBNull(obj))
            {
                return nullText;
            }
            return string.Format(formatString, obj);
        }
    }
}

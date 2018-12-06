using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// If count is 0, displays none; if it is 1, displays min value. If 2 or more, displays min - max
    /// DataFields must be in multiples of 3. Each set of 3 should be count, min, max.
    /// DataZeroValueFormatString, DataSingleValueFormatString, DataTwoValueFormatString,
    /// DataMultiValueFormatString controls
    /// what is displayed for 0 count, 1 count and more than 1 count.
    /// In format strings, Use {0} to show count, {1} to show min and {2} to show max.
    /// </summary>
    /// <remarks>
    /// <para>
    /// <c>MultiValueLabel</c> is useful when you commonly have a single value, but you do want to accommodate the case when multiple
    /// values may be retrieved. It only works in data binding scenarios and is commonly placed inside the <c>ItemTemplate</c> of a 
    /// <see cref="JQuery.GridViewEx"/> control. You need to specify at least three fields for <see cref="DataFields"/>, each representing
    /// count, min and max values, in that order. <c>MultiValueLabel</c> is very functional with just this much information. It will display
    /// a single value if count is 1. It will display two comma seperated values if count is 2. If count is 3 or more, it will display something
    /// link <c>min - max</c>.
    /// </para>
    /// <para>
    /// You can customize what is displayed in each case by optionally specifying values for <see cref="DataZeroValueFormatString"/>,
    /// <see cref="DataSingleValueFormatString"/>, <see cref="DataTwoValueFormatString"/>, <see cref="DataMultiValueFormatString"/>.
    /// You also have full control on what tooltip is displayed in each case through the properties
    /// <see cref="DataZeroValueTipFormatString"/>, <see cref="DataSingleValueTipFormatString"/>, <see cref="DataTwoValueTipFormatString"/>,
    /// <see cref="DataMultiValueTipFormatString"/>.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// This query groups by creation date and then retrieves count, min and max of distinct progress dates within each creation date. 
    /// </para>
    /// <code lang="C#">
    /// <![CDATA[
    ///var query = from actdet in db.FormatActivityDetails
    ///                group actdet by new
    ///                {
    ///                    Date = (actdet.Modified ?? actdet.Created).Value.Date,
    ///                    ProgressFormat = actdet.FormatDetail.ProgressFormat
    ///                } into g
    ///                orderby g.Key.ProgressFormat.Package.Description, g.Key.Date descending, g.Key.ProgressFormat.ProgressFormatName
    ///                select new
    ///                {
    ///                    Date = g.Key.Date,
    ///                    MinPhysicalProgressDate = (DateTime?)g.Where(p => p.PhysicalProgressData != null).Min(p => p.FormatDetail.ProgressDate.Date),
    ///                    MaxPhysicalProgressDate = (DateTime?)g.Where(p => p.PhysicalProgressData != null).Max(p => p.FormatDetail.ProgressDate.Date),
    ///                    CountPhysicalProgressDate = g.Where(p => p.PhysicalProgressData != null)
    ///                        .Select(p => p.FormatDetail.ProgressDate.Date).Distinct().Count(),
    ///                    ...
    ///                };
    /// ]]>
    /// </code>
    /// <para>
    /// The template column in the following grid will display the values depending on what the count is.
    /// </para>
    /// <code lang="XML">
    /// <![CDATA[
    ///<jquery:GridViewEx ID="gvBuzz" runat="server">
    ///    <Columns>
    ///        <asp:TemplateField HeaderText="Physical|# Activities">
    ///            <ItemTemplate>
    ///                <eclipse:MultiValueLabel runat="server" DataFields="CountPhysicalProgressDate,MinPhysicalProgressDate,MaxPhysicalProgressDate"
    ///                    DataTwoValueFormatString="for {1:MMM\'y} and {2:MMM\'y}" DataMultiValueFormatString="for {1:MMM\'y} to {2:MMM\'y}"
    ///                    DataSingleValueFormatString="for {1:MMM\'y}" DataZeroValueFormatString="&nbsp;" />
    ///            </ItemTemplate>
    ///        </asp:TemplateField>
    ///    </Columns>
    ///</jquery:GridViewEx>
    /// ]]>
    /// </code>
    /// </example>
    public class MultiValueLabel:Label
    {
        public MultiValueLabel()
        {
            this.DataZeroValueFormatString = "None";
            this.DataSingleValueFormatString = "{1}";
            this.DataTwoValueFormatString = "{1}, {2}";
            this.DataMultiValueFormatString = "{1} - {2}";
            this.DataZeroValueTipFormatString = "No values available";
            this.DataSingleValueTipFormatString = "Exactly one value found";
            this.DataTwoValueTipFormatString = "Two values found";
            this.DataMultiValueTipFormatString = "{0} values from {1} - {2}";
            this.Seperator = "/";
        }

        /// <summary>
        /// Copy constructor. Copies just the Data* properties
        /// </summary>
        /// <param name="other"></param>
        public MultiValueLabel(MultiValueLabel other)
        {
            this.DataFields = other.DataFields;
            this.DataZeroValueFormatString = other.DataZeroValueFormatString;
            this.DataSingleValueFormatString = other.DataSingleValueFormatString;
            this.DataTwoValueFormatString = other.DataTwoValueFormatString;
            this.DataMultiValueFormatString = other.DataMultiValueFormatString;
            this.DataZeroValueTipFormatString = other.DataZeroValueTipFormatString;
            this.DataSingleValueTipFormatString = other.DataSingleValueTipFormatString;
            this.DataTwoValueTipFormatString = other.DataTwoValueTipFormatString;
            this.DataMultiValueTipFormatString = other.DataMultiValueTipFormatString;
            this.Seperator = other.Seperator;
        }

        /// <summary>
        /// Data fields to evaluate in multiples of three.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The first data field specified must evaluate count. The second data field must evaluate the minimum value. The third
        /// data field must evaluate the maximum value.
        /// </para>
        /// <para>
        /// At run time, the value displayed in <c>MultiValueLabel</c> depends on the count.
        /// </para>
        /// <list type="table">
        /// <listheader>
        /// <term>
        /// Value of Count
        /// </term>
        /// <description>Result</description>
        /// </listheader>
        /// <item>
        /// <term>0</term>
        /// <description>
        /// The values are formatted using the <see cref="DataZeroValueFormatString"/>.
        /// </description>
        /// </item>
        /// <item>
        /// <term>1</term>
        /// <description>
        /// The values are formatted using the <see cref="DataSingleValueFormatString"/>.
        /// </description>
        /// </item>
        /// <item>
        /// <term>2</term>
        /// <description>
        /// The values are formatted using the <see cref="DataTwoValueFormatString"/>.
        /// </description>
        /// </item>
        /// <item>
        /// <term>3 or more</term>
        /// <description>
        /// The values are formatted using the <see cref="DataMultiValueFormatString"/>.
        /// </description>
        /// </item>
        /// </list>
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [Description("CountField,Min value field, Max value field")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] DataFields
        {
            get;
            set;
        }

        /// <summary>
        /// Text to display if count is 0
        /// </summary>
        /// <remarks>
        /// <para>
        /// It defaults to <c>None</c> but you can set it to an empty string if you prefer.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [Description("Text to display if count is 0")]
        [Themeable(false)]
        [DefaultValue("None")]
        public string DataZeroValueFormatString { get; set; }

        /// <summary>
        /// Text to display if count is 1
        /// </summary>
        /// <remarks>
        /// <para>
        /// It defaults to <c>{1}</c> which means that it shows the min value. Since count is 1, the max value is the same as the
        /// min value so it should not matter what is shown.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [Description("Text to display if count is 1")]
        [Themeable(false)]
        [DefaultValue("{1}")]
        public string DataSingleValueFormatString { get; set; }

        /// <summary>
        /// Text to display if count is 2
        /// </summary>
        /// <remarks>
        /// <para>
        /// It defaults to <c>{1},{2}</c> which means that it shows the min value, max value.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [Description("Text to display if count is 2")]
        [Themeable(false)]
        [DefaultValue("{1},{2}")]
        public string DataTwoValueFormatString { get; set; }

        /// <summary>
        /// Text to display if count is more than 2
        /// </summary>
        /// <remarks>
        /// <para>
        /// It defaults to <c>{1}-{2}</c> which means that it shows the min value-max value. As an alternative,
        /// you might set it to <c>{1} to {2}</c>.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [Description("Text to display if count is more than 2")]
        [Themeable(false)]
        [DefaultValue("{1}-{2}")]
        public string DataMultiValueFormatString { get; set; }

        /// <summary>
        /// Tip to display if count is 0
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Tip to display if count is 0")]
        [Themeable(false)]
        [DefaultValue("No values available")]
        public string DataZeroValueTipFormatString { get; set; }

        /// <summary>
        /// Tip to display if count is 1
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Tip to display if count is 1")]
        [Themeable(false)]
        [DefaultValue("Exactly one value found")]
        public string DataSingleValueTipFormatString { get; set; }

        /// <summary>
        /// Tip to display if count is 2
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Tip to display if count is 2")]
        [Themeable(false)]
        [DefaultValue("Two values found")]
        public string DataTwoValueTipFormatString { get; set; }

        /// <summary>
        /// Tip to display if count is more than 2
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Tip to display if count is more than 2")]
        [Themeable(false)]
        [DefaultValue("{0} values from {1} - {2}")]
        public string DataMultiValueTipFormatString { get; set; }

        [Browsable(true)]
        [Category("Data")]
        [Description("Seperator used to seperate each set of 3")]
        [Themeable(false)]
        [DefaultValue("/")]
        public string Seperator { get; set; }

        /// <summary>
        /// Retrieves the data item of the page, evaluates the count, and then uses the appropriate
        /// format string to set the label text.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnDataBinding(EventArgs e)
        {
            object dataItem = this.Page.GetDataItem();

            object[] values = new object[3];
            List<string> list = new List<string>();
            for (int i = 0; i < this.DataFields.Length; ++i)
            {
                object obj = DataBinder.Eval(dataItem, this.DataFields[i]);
                values[i % 3] = obj;
                int nCount;
                if (obj == DBNull.Value)
                {
                    nCount = 0;
                }
                else
                {
                    nCount = Convert.ToInt32(values[i % 3]);
                }
                ++i;
                while (i % 3 != 0)
                {
                    values[i % 3] = DataBinder.Eval(dataItem, this.DataFields[i]);
                    ++i;
                }
                string strText;
                string strTip;
                switch (nCount)
                {
                    case 0:
                        strText = string.Format(this.DataZeroValueFormatString, values);
                        strTip = string.Format(this.DataZeroValueTipFormatString, values);
                        break;

                    case 1:
                        strText = string.Format(this.DataSingleValueFormatString, values);
                        strTip = string.Format(this.DataSingleValueTipFormatString, values);
                        break;

                    case 2:
                        strText = string.Format(this.DataTwoValueFormatString, values);
                        strTip = string.Format(this.DataTwoValueTipFormatString, values);
                        break;

                    default:
                        strText = string.Format(this.DataMultiValueFormatString, values);
                        strTip = string.Format(this.DataMultiValueTipFormatString, values);
                        break;
                }
                string str = string.Format("<span title=\"{1}\" style=\"white-space:nowrap\">{0}</span>", strText, strTip);
                list.Add(str);
                --i;
            }
            this.Text = string.Join(this.Seperator, list.ToArray());

            base.OnDataBinding(e);
        }
    }
}

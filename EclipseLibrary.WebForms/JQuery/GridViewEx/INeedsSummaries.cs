using System.Web.UI.WebControls;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// This is test
    /// </summary>
    ///  <include file='INeedsSummaries.xml' path='INeedsSummaries/doc[@name="SummaryCalculationType"]/*'/> 
    public enum SummaryCalculationType
    {
        /// <summary>
        /// No totals are required
        /// </summary>
        None,

        /// <summary>
        /// The data source is responsible for calculating totals
        /// </summary>
       
        DataSource,

        /// <summary>
        /// The values returned by the data source would be summed up to compute the total.
        /// In the case, the DataFooterFields must eval to numeric values.
        /// </summary>
        /// <include file='INeedsSummaries.xml' path='INeedsSummaries/doc[@name="ValueSummation"]/*'/>
        ValueSummation,

        /// <summary>
        /// You specify two footer fields. Computes sum(field1)/sum(field2). Useful for calculating
        /// percentages and weighted averages.
        /// </summary>
        /// <include file='INeedsSummaries.xml' path='INeedsSummaries/doc[@name="ValueWeightedAverage"]/*'/>
        ValueWeightedAverage
    }

    /// <summary>
    /// All DataControlField derived classes should implement this to enable the display of
    /// data item values in the footer. MultiBoundField is the first implementor of this.
    /// </summary>
    ///  <include file='INeedsSummaries.xml' path='INeedsSummaries/doc[@name="class"]/*'/>
    public interface INeedsSummaries
    {
        /// <summary>  
        /// If you specify DataSummaryCalculation to indicate which field needs to be summarized
        /// </summary>
        SummaryCalculationType DataSummaryCalculation { get; set; }

        /// <summary>
        /// Fields to display in the footer. The data item of the first row is used to get the values.
        /// </summary>
        string[] DataFooterFields
        {
            get;
            set;
        }

        /// <summary>
        /// Format string to use for footer text. Defaults to DataFormatString.
        /// </summary>
        string DataFooterFormatString { get; set; }

        string FooterToolTip { get; set; }

        /// <summary>
        /// You can access this programmatically to determine the value we will show in the footer.
        /// You can even change it before rendering to control what is displayed in the footer.
        /// </summary>
        /// <include file='INeedsSummaries.xml' path='INeedsSummaries/doc[@name="SummaryValues"]/*'/>
        decimal?[] SummaryValues { get; set; }

        /// <summary>
        /// The number of values over which SummaryValues were computed. null vallues are not included in the count.
        /// This is always 0 when DataSummaryCalculation=DataSource
        /// </summary>
        int[] SummaryValuesCount { get; set; }
    }

}

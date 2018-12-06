using System.ComponentModel;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.JQuery;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// Same as HyperLinkField. When used in conjunction with GridViewEx, it can display
    /// summaries in the footer. You will need to specify DataSummaryCalculation property.
    /// </summary>
    /// <remarks>
    /// If DataSummaryCalculation is not None, the default item style becomes right aligned
    /// Sharad 5 Sep 2009: Updated to accommodate changes in INeedsSummaries interface
    /// <para>
    /// Can also specify <see cref="HeaderToolTip"/>
    /// </para>
    /// </remarks>
    public class HyperLinkFieldEx:HyperLinkField, INeedsSummaries, IHasHeaderToolTip
    {

        private string[] _dataTextFields;
        public override string DataTextField
        {
            get
            {
                return base.DataTextField;
            }
            set
            {
                base.DataTextField = value;
                _dataTextFields = new string[] { this.DataTextField };
            }
        }

        #region INeedsSummaries Members

        public SummaryCalculationType _dataSummaryCalculation;

        [Browsable(true)]
        [DefaultValue(SummaryCalculationType.None)]
        public SummaryCalculationType DataSummaryCalculation
        {
            get
            {
                return _dataSummaryCalculation;
            }
            set
            {
                _dataSummaryCalculation = value;
                if (value != SummaryCalculationType.None)
                {
                    if (this.ItemStyle.HorizontalAlign == HorizontalAlign.NotSet)
                    {
                        this.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
                    }
                    if (this.FooterStyle.HorizontalAlign == HorizontalAlign.NotSet)
                    {
                        this.FooterStyle.HorizontalAlign = HorizontalAlign.Right;
                    }
                }
            }
        }

        private string[] _dataFooterFields;

        /// <summary>
        /// If not specified, DataTextField is used
        /// </summary>
        [Browsable(true)]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        public string[] DataFooterFields
        {
            get
            {
                return _dataFooterFields ?? _dataTextFields;
            }
            set
            {
                _dataFooterFields = value;
            }
        }

        private string _dataFooterFormatString;

        /// <summary>
        /// The format string to use for totals
        /// </summary>
        /// <remarks>
        /// <para>
        /// Returns <see cref="HyperLinkField.DataTextFormatString"/> if this has not been explicitly set
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string DataFooterFormatString
        {
            get
            {
                if (string.IsNullOrEmpty(_dataFooterFormatString))
                {
                    return this.DataTextFormatString;
                }
                else
                {
                    return _dataFooterFormatString;
                }
            }
            set
            {
                _dataFooterFormatString = value;
            }
        }

        [Browsable(true)]
        public string FooterToolTip
        {
            get;
            set;
        }

        [Browsable(false)]
        public decimal?[] SummaryValues
        {
            get;
            set;
        }

        [Browsable(false)]
        public int[] SummaryValuesCount { get; set; }


        #endregion

        public string HeaderToolTip
        {
            get;
            set;
        }
    }
}

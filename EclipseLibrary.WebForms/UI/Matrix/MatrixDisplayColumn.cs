using System;
using System.Collections.Generic;
using System.Linq;
using EclipseLibrary.Oracle.Helpers.XPath;


namespace EclipseLibrary.Web.UI.Matrix
{

    /// <summary>
    /// The column which is displayed by <see cref="MatrixField"/>.
    /// </summary>
    /// <remarks>
    /// <para>
    /// For each distinct value of <see cref="MatrixField.DataHeaderFields"/>, one DisplayColumn is created.
    /// It contains properties which are necessary to properly render the column such as <see cref="MainHeaderText"/>
    /// and <see cref="ColumnHeaderText"/>.
    /// </para>
    /// <para>
    /// It is constructed by <see cref="MatrixField.MaybeAddHeaderValue"/> when a new distinct column value is retrieved from the 
    /// data source. It is accessible via the <see cref="MatrixCell.DisplayColumn"/> and <see cref="MatrixField.DisplayColumns"/>
    /// properties.
    /// Two <see cref="MatrixDisplayColumn"/>
    /// are considered to be Equal if they have the same <see cref="MainHeaderText"/>
    /// and <see cref="ColumnHeaderText"/> as defined by <see cref="CompareTo"/>.
    /// </para>
    /// <para>
    /// The order in which the columns are displayed is controlled by the implementation of <see cref="CompareTo"/> method.
    /// </para>
    /// </remarks>
    public class MatrixDisplayColumn : IComparable<MatrixDisplayColumn>
    {
        // ReSharper disable InconsistentNaming
        protected readonly MatrixField _mf;
        // ReSharper restore InconsistentNaming
        private readonly MatrixColumn _mc;
        private readonly int _colIndex;

        // ReSharper disable InconsistentNaming
        protected string _mainHeaderText;
        // ReSharper restore InconsistentNaming
        private readonly decimal?[] _columnTotals;
        private readonly int[] _colTotalindexes;

        internal MatrixDisplayColumn(MatrixField mf, MatrixColumn col, int colIndex)
        {
            _mf = mf;
            _mc = col;
            _colIndex = colIndex;
            ConditionalFormatter formatter = mf.GetHeaderFormatter(colIndex);
            _columnHeaderText = string.Format(formatter, col.DataHeaderFormatString, this.DataHeaderValues);
            this.Visible = string.IsNullOrEmpty(col.VisibleExpression) || formatter.Matches(col.VisibleExpression);
            _mainSortText = string.IsNullOrWhiteSpace(mf.SortExpression) ? string.Empty : string.Format(formatter, mf.SortExpression, this.DataHeaderValues);

            switch (col.ColumnType)
            {
                case MatrixColumnType.RowTotal:
                    _mainHeaderText = _mf.RowTotalHeaderText;
                    break;

                case MatrixColumnType.CellValue:
                    _mainHeaderText = string.Format(formatter, _mf.HeaderText.Split('|')[0], this.DataHeaderValues);
                    break;

                default:
                    break;
            }
            _columnTotals = new decimal?[mf.DataCellFields.Length];
            _colTotalindexes = mf.DataCellFields
                .Select((p, i) => this.MatrixColumn.ColumnTotalFormatString.Contains("{" + i.ToString()) ? i : -1)
                .Where(p => p >= 0).ToArray();
        }

        /// <summary>
        /// An array containing the indexes of cell fields which need to be totaled
        /// </summary>
        internal int[] FieldsToTotal
        {
            get
            {
                return _colTotalindexes;
            }

        }

        public bool Visible { get; set; }

        /// <summary>
        /// The matrix column corresponding to which this display column was created
        /// </summary>
        public MatrixColumn MatrixColumn
        {
            get
            {
                return _mc;
            }
        }

        /// <summary>
        /// The text to show in the first line of the header
        /// </summary>
        /// <remarks>
        /// <para>
        /// If you need to customize this text, you can update it any time, most likely in the
        /// <c>ObservableCollection.CollectionChanged</c> event.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// Based on the header value, this code sets custom header text. First it adds all header values by selecting from
        /// a master date table. In the <c>PostSelected</c> event handler of the datasource shown below, it first hooks to the
        /// <c>ObservableCollection.CollectionChanged</c> event of <see cref="MatrixField.DisplayColumns"/>. Then it iterates
        /// the values retrieved from the datasource and adds them to <see cref="MatrixField.DataHeaderValues"/>.
        /// </para>
        /// <code lang="C#">
        /// <![CDATA[
        /// void ds_PostSelected(object sender, PostSelectedEventArgs e)
        ///{
        ///    if (e.Result != null)
        ///    {
        ///        EclipseLibrary.Web.UI.Matrix.MatrixField mf = gv.Columns.OfType<EclipseLibrary.Web.UI.Matrix.MatrixField>().First();
        ///        mf.DisplayColumns.CollectionChanged += new NotifyCollectionChangedEventHandler(DisplayColumns_CollectionChanged);
        ///        foreach (var row in dsBusinessMonths.Select(DataSourceSelectArguments.Empty))
        ///        {
        ///            mf.DataHeaderValues.Add(new object[] { DataBinder.Eval(row, "month_start_date") });
        ///        }
        ///    }
        ///}
        /// ]]>
        /// </code>
        /// <para>
        /// In the <c>ObservableCollection.CollectionChanged</c> event handler shown below, it customizes the 
        /// <see cref="MainHeaderText"/> of each display column. The column which has just been added is passed as one
        /// of the event arguments.
        /// </para>
        /// <code lang="C#">
        /// <![CDATA[
        ///void DisplayColumns_CollectionChanged(object sender, NotifyCollectionChangedEventArgs e)
        ///{
        ///    switch (e.Action)
        ///    {
        ///        case NotifyCollectionChangedAction.Add:
        ///            foreach (MatrixDisplayColumnBase dc in e.NewItems.Cast<MatrixDisplayColumnBase>()
        ///                    .Where(p => p.MatrixColumn.ColumnType == MatrixColumnType.CellValue))
        ///            {
        ///                DateTime date = (DateTime)dc.DataHeaderValue;
        ///                int month = date.Month;
        ///                if (date.Day > 15)
        ///                {
        ///                    ++month;
        ///                }
        ///                int year = date.Year;
        ///                if (month > 12)
        ///                {
        ///                    month = 1;
        ///                    ++year;
        ///                }
        ///                dc.MainHeaderText = string.Format("{0:MMM yyyy}", new DateTime(year, month, 1));
        ///            }
        ///            break;
        ///    }
        ///}
        /// ]]>
        /// </code>
        /// </example>
        public string MainHeaderText
        {
            get
            {
                return _mainHeaderText;
            }
            set
            {
                _mainHeaderText = value;
            }
        }

        // ReSharper disable InconsistentNaming
        protected string _columnHeaderText;
        // ReSharper restore InconsistentNaming

        /// <summary>
        /// The text to show in the second line of the header
        /// </summary>
        public string ColumnHeaderText
        {
            get
            {
                return _columnHeaderText;
            }
            set { _columnHeaderText = value; }
        }

        /// <summary>
        /// The index of header values in <see cref="MatrixField.DataHeaderValues"/>. Will be -1 for row totals
        /// </summary>
        internal int DataHeaderValueIndex
        {
            get
            {
                return _colIndex;
            }
        }

        /// <summary>
        /// Returns an array of nulls for total columns
        /// </summary>
        public object[] DataHeaderValues
        {
            get
            {
                if (_colIndex == -1)
                {
                    return new object[_mf.DataHeaderFields.Length];
                }
                return _mf.DataHeaderValues[this.DataHeaderValueIndex];
            }
        }

        /// <summary>
        /// Easy way to retrieve the value of the first header field
        /// </summary>
        public object DataHeaderValue
        {
            get
            {
                if (_colIndex == -1)
                {
                    return null;
                }
                return _mf.DataHeaderValues[this.DataHeaderValueIndex][0];
            }
        }

        internal void UpdateColumnTotals(object[] values)
        {
            foreach (int i in _mf.DataCellFields
                .Select((p, i) => _colTotalindexes.Contains(i) ? i : -1)
                .Where(p => p >= 0))
            {
                if (values[i] != DBNull.Value)
                {
                    _columnTotals[i] = (_columnTotals[i] ?? 0) + Convert.ToDecimal(values[i]);
                }

            }
        }

        public IEnumerable<decimal?> ColumnTotal
        {
            get
            {
                return _columnTotals;
            }

        }

        #region IComparable
        /// <summary>
        /// Columns are equal if they are of same type and have same <see cref="MainHeaderText"/> and
        /// <see cref="ColumnHeaderText"/>.
        /// </summary>
        /// <param name="other"></param>
        /// <returns></returns>
        /// <remarks>
        /// <para>
        /// </para>
        /// </remarks>
        public int CompareTo(MatrixDisplayColumn other)
        {
            int n;
            if (other.MatrixColumn.ColumnType == MatrixColumnType.RowTotal && this.MatrixColumn.ColumnType != MatrixColumnType.RowTotal)
            {
                // Other is the total so we are smaller
                n = -1;
            }
            else if (this.MatrixColumn.ColumnType == MatrixColumnType.RowTotal && other.MatrixColumn.ColumnType != MatrixColumnType.RowTotal)
            {
                // We are the total so we are bigger
                n = 1;
            }
            else
            {
                // We are both of the same type
                n = 0;
            }

            if (n != 0)
            {
                // Total type columns display last.
                return n;
            }
            if (_mf.GroupByColumnHeaderText)
            {
                n = this.ColumnHeaderText.CompareTo(other.ColumnHeaderText);
                if (n == 0)
                {
                    n = this.MainSortText.CompareTo(other.MainSortText);
                }


            }
            else
            {
                n = this.MainSortText.CompareTo(other.MainSortText);
                if (n == 0)
                {
                    n = this.ColumnHeaderText.CompareTo(other.ColumnHeaderText);
                }
            }
            return n;
        }
        #endregion

        private string _mainSortText;

        /// <summary>
        /// 
        /// </summary>
        /// <remarks>
        /// <para>
        /// Defaults to <see cref="MainHeaderText"/>.
        /// </para>
        /// </remarks>
        public string MainSortText
        {
            get
            {
                if (string.IsNullOrWhiteSpace(_mainSortText))
                {
                    return _mainHeaderText;
                }
                return _mainSortText;
            }
            set { _mainSortText = value; }
        }

        /// <summary>
        /// Debugging
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format("{0}|{1}", this.MainHeaderText, this.ColumnHeaderText);
        }
    }

}

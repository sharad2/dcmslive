using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Oracle.Helpers.XPath;
using EclipseLibrary.Web.JQuery;

namespace EclipseLibrary.Web.UI.Matrix
{
    /// <summary>
    /// Displays data of multiple rows within a single row
    /// </summary>
    /// <remarks>
    /// <para>
    /// Following is the minimum markup required for a working matrix field.
    /// </para>
    /// <code lang="xml">
    /// <![CDATA[
    ///<m:MatrixField DataCellFields="TOTAL_QUANTITY" DataMergeFields="AREA">
    ///    <HeaderFields>
    ///        <Fields>
    ///            <m:MatrixHeaderField Name="VWH_ID" />
    ///        </Fields>
    ///    </HeaderFields>
    ///</m:MatrixField>
    /// ]]>
    /// </code>
    /// <para>
    /// The following steps explain what this markup means.
    /// </para>
    /// <list type="number">
    /// <item>
    /// <description>
    /// Decide which columns to display.
    /// <see cref="DataHeaderFields"/> must contain the name of at least one data field. At this point you will
    /// will see one column for each distinct value of the header field returned by your data source. However, all
    /// cells will be empty.
    /// </description>
    /// </item>
    /// <item>
    /// <description>
    /// Decide what to display in each cell. Specify a value for <see cref="DataCellFields"/>. The value of this
    /// field will display in each cell.
    /// </description>
    /// </item>
    /// <item>
    /// <description>
    /// Merge adjacent rows. At this point, each row is displaying a value in exactly one column. We want to merge adjacent
    /// rows so that the number of rows displayed become less and each row potentially displays values in multiple columns.
    /// To achieve this you specify <see cref="DataMergeFields"/>. Adjacent rows which have the same values for each field
    /// sepecified in <see cref="DataMergeFields"/> will be collapsed into one.
    /// </description>
    /// </item>
    /// <item>
    /// <term>
    /// </term>
    /// <description>
    /// </description>
    /// </item>
    /// <item>
    /// <term>
    /// </term>
    /// <description>
    /// </description>
    /// </item>
    /// <item>
    /// <term>
    /// </term>
    /// <description>
    /// </description>
    /// </item>
    /// <item>
    /// <term>
    /// </term>
    /// <description>
    /// </description>
    /// </item>
    /// </list>
    /// <para>
    /// To add static columns, you can manually add data values to <see cref="DataHeaderValues"/>. The text wi
    /// </para>
    /// <para>
    /// Headers are sorted by <c>SortExpression</c> which defaults to <see cref="HeaderText"/>. The <see cref="MatrixHeaderRow.Render"/>
    /// method sorts the columns before displaying them.
    /// </para>
    /// <para>
    /// Grouping Columns. <see cref="MatrixColumn.DataHeaderFormatString"/> serves as the title of the main group
    /// and <see cref="HeaderText"/> serves as title of the subgroup. By specifying
    /// a conditional format string for <see cref="HeaderText"/> you can group columns. 
    /// See <see cref="HeaderText"/> for an example.
    /// </para>
    /// </remarks>
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class MatrixField : DataControlField, IHasCustomCells
    {
        #region Initialization

        /// <summary>
        /// Constructor
        /// </summary>
        public MatrixField()
        {
            this.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
            this.FooterStyle.HorizontalAlign = HorizontalAlign.Right;
            _displayColumns = new ObservableCollection<MatrixDisplayColumn>();
            _dataHeaderValues = new ObservableCollection<object[]>();
            _dataHeaderValues.CollectionChanged += dataHeaderValues_CollectionChanged;
            this._matrixColumns = new Collection<MatrixColumn>();
            this.RowTotalHeaderText = "Total";
            _curCellValues = new Dictionary<int, object[]>();
        }

        private ConditionalFormatter _headerFormatter;
        internal ConditionalFormatter GetHeaderFormatter(int columnIndex)
        {
            if (_headerFormatter == null)
            {
                _headerFormatter = new ConditionalFormatter(null);
            }
            _headerFormatter.Callback = varname => this.DataHeaderFields
                    .Select((p, i) => p == varname ? i : -1)
                    .Where(p => p >= 0).Select(p => this.DataHeaderValues[columnIndex][p])
                    .Single();
            return _headerFormatter;
        }

        /// <exclude />
        /// <summary>
        /// Not implemented
        /// </summary>
        /// <returns></returns>
        protected override DataControlField CreateField()
        {
            throw new NotImplementedException();
        }


        /// <summary>
        /// Need to store it for the sake of <see cref="DataRows"/>
        /// </summary>
        private GridViewEx _gv;

        /// <summary>
        /// Hook up the row data bound and pre render events of the grid
        /// </summary>
        /// <param name="sortingEnabled">Not used</param>
        /// <param name="control">This must be of type <see cref="GridViewEx"/>.</param>
        /// <returns></returns>
        public override bool Initialize(bool sortingEnabled, Control control)
        {
            _gv = (GridViewEx)control;

            if (this.MatrixColumns.Count == 0)
            {
                // Add a default column
                this.MatrixColumns.Add(new MatrixColumn());
            }

            foreach (var mc in this.MatrixColumns.Where(p => p.ColumnType == MatrixColumnType.RowTotal))
            {
                MatrixDisplayColumn info = new MatrixDisplayColumn(this, mc, -1);
                _displayColumns.Add(info);
            }

            return base.Initialize(sortingEnabled, control);
        }

        #endregion

        #region Browsable Properties
        /// <summary>
        /// If the previous and current rows have the same values for all merge fields, the current row will be
        /// hidden, and the data for the second row will be shown in the previous row.
        /// </summary>
        /// <remarks>
        /// <para>
        /// It is very important that the rows within the data source are pre sorted by the fields specified here.
        /// As long as the rows have the same values for all <c>DataMergeFields</c>, they are collapsed into a single
        /// row. As soon as any of the <c>DataMergeFields</c> change, we begin a new row.
        /// </para>
        /// <note type="caution">
        /// You must ensure that all fields specified in <c>DataMergeFields</c> and 
        /// should be part of the conceptual primary key of the query output. Otherwise you will encounter exceptions.
        /// </note>
        /// <para>
        /// If you do not specify <see cref="DataMergeFields"/>, then we do not merge any rows. This means that all rows
        /// will be visible. This is useful only in debugging scenarios.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// Following is a basic markup which uses <c>DataMergeFields</c>.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///<jquery:GridViewEx ID="gv" runat="server" DataSourceID="ds">
        ///    <Columns>
        ///        <asp:BoundField DataField="upc_code" HeaderText="UPC" />
        ///        <jquery:MatrixField DataHeaderField="carton_storage_area" DataValueFields="quantity"
        ///            DataMergeFields="upc_code" HeaderText="Pieces">
        ///        </jquery:MatrixField>
        ///    </Columns>
        ///</jquery:GridViewEx>        
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        public string[] DataMergeFields { get; set; }

        private readonly Collection<MatrixColumn> _matrixColumns;

        /// <summary>
        /// Specify these columns at design time. They control what columns are displayed.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Each column can display one or more values by specifying the <see cref="MatrixColumn.DataCellFormatString"/>
        /// property. You can even display custom content using <see cref="MatrixColumn.ItemTemplate"/> property.
        /// Column totals are enabled by setting the property.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public Collection<MatrixColumn> MatrixColumns
        {
            get
            {
                return _matrixColumns;
            }
        }

        /// <summary>
        /// The fields which will be used to generate matrix columns
        /// </summary>
        [Browsable(true)]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        public string[] DataHeaderFields
        {
            get;
            set;
        }

        /// <summary>
        /// Fields whose value needs to be displayed in each matrix column
        /// </summary>
        /// <remarks>
        /// <para>
        /// You can specify more than one field for this property, seperated by commas.
        /// <see cref="MatrixColumn.DataCellFormatString"/> controls how these values are presented.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        public string[] DataCellFields { get; set; }

        /// <summary>
        /// This can be a format string. The place holders will be replaced with <see cref="DataHeaderFields"/>
        /// </summary>
        /// <remarks>
        /// <para>
        /// The <see cref="HeaderText"/> is used to populate the <see cref="MatrixDisplayColumn.MainHeaderText"/> of each
        /// display column. It is not permissible for <see cref="MatrixColumn.DataHeaderFormatString"/> to contain a <c>|</c> symbol.
        /// The format string can contain conditional formatting statements. It is evaluated for each
        /// header column seperately. This enables grouping of columns as shown in the example.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// In this example the columns are grouped by are type.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///  <m:MatrixField DataMergeFields="vwh_id,quality_code,style,color" DataHeaderFields="area_type,inventory_area_id"
        ///    DataCellFields="inventory_pieces" HeaderText="{0::$area_type = 1:Front Areas:Back Areas}">
        ///    <MatrixColumns>
        ///        <m:MatrixColumn ColumnType="CellValue" DataHeaderFormatString="{1}" DisplayColumnTotal="true"
        ///            DataCellFormatString="{0:N0}" >
        ///        </m:MatrixColumn>
        ///        <m:MatrixColumn ColumnType="RowTotal" DisplayColumnTotal="true" />
        ///    </MatrixColumns>
        /// </m:MatrixField>
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [DefaultValue("{0}")]
        public override string HeaderText
        {
            get
            {

                string ret = base.HeaderText;
                if (this.MatrixColumns.Any(p => !string.IsNullOrWhiteSpace(p.DataHeaderFormatString)))
                {
                    ret += "|xx";
                }
                return ret;
            }
            set
            {
                if (value.Contains("|"))
                {
                    throw new ArgumentException("Header text cannot contain |", "value");
                }
                base.HeaderText = value;
            }
        }

        /// <summary>
        /// By default grouping of column is by <see cref="HeaderText"/>
        /// </summary>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool GroupByColumnHeaderText { get; set; }

        /// <summary>
        /// Header text to display for row totals of all groups combined.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Row totals are enabled by including a <see cref="MatrixColumn"/> whose <see cref="MatrixColumn.ColumnType"/>
        /// is <see cref="MatrixColumnType.RowTotal"/>
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("Total")]
        public string RowTotalHeaderText { get; set; }

        #endregion

        private readonly ObservableCollection<object[]> _dataHeaderValues;

        /// <summary>
        /// The first array in the list contains the values of each field specified in <see cref="DataHeaderFields"/>.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The length of each array returned is exactly equal to the
        /// number of fields specified in <see cref="DataHeaderFields"/>. You can monitor this collection by hooking
        /// to its <c>CollectionChanged</c> event.
        /// </para>
        /// <para>
        /// Public so that static values can be added.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// In this example, we want to add two static columns for Deductions total and Earnings Total. You can fully customize the header and sort order of these static columns.
        /// To set custom text for the cells within these static columns we must handle the <c>RowDataBound</c> event of the grid. An example can be found
        /// in <see cref="MatrixRow"/>.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///  protected override void OnLoad(EventArgs e)
        ///  {
        ///    var mf = gvPaybill.Columns.OfType<EclipseLibrary.Web.UI.Matrix.MatrixField>().Single();
        ///    mf.DisplayColumns.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(DisplayColumns_CollectionChanged);
        ///    mf.DataHeaderValues.Add(new object[] { true, "X" });
        ///    mf.DataHeaderValues.Add(new object[] { false, "X" });
        ///  } 
        ///   void DisplayColumns_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        ///  {
        ///    if (e.Action == NotifyCollectionChangedAction.Add)
        ///    {
        ///        foreach (var dc in e.NewItems.Cast<EclipseLibrary.Web.UI.Matrix.MatrixDisplayColumn>().Where(p => p.ColumnHeaderText == "X"))
        ///        {
        ///            dc.ColumnHeaderText = "Total";
        ///            
        ///        }
        ///    }
        ///  }
        /// ]]>
        /// </code>
        /// </example>
        public ObservableCollection<object[]> DataHeaderValues
        {
            get { return _dataHeaderValues; }
        }

        internal IEnumerable<MatrixRow> DataRows
        {
            get
            {
                return _gv.Rows.Cast<GridViewRow>()
                    .Where(p => p.Visible)
                    .Select(p => p.Cells.OfType<MatrixRow>().Single(q => q.ContainingField == this));
            }
        }

        #region IHasCustomCells

        private MatrixHeaderRow _headerRow;
        private MatrixRow _footerRow;

        /// <exclude/>
        /// <summary>
        /// </summary>
        /// <param name="cellType"></param>
        /// <exception cref="NotImplementedException"></exception>
        DataControlFieldCell IHasCustomCells.CreateCell(DataControlCellType cellType)
        {
            switch (cellType)
            {
                case DataControlCellType.Header:
                    if (_headerRow == null)
                    {
                        _headerRow = new MatrixHeaderRow(this);
                        return _headerRow;
                    }
                    return new MatrixHeaderRowProxy(_headerRow);

                case DataControlCellType.DataCell:
                    return new MatrixRow(this);

                case DataControlCellType.Footer:
                    return _footerRow ?? (_footerRow = new MatrixRow(this));

                default:
                    throw new NotImplementedException();
            }
        }

        /// <exclude/>
        /// <summary>
        /// </summary>
        /// <param name="writer"></param>
        /// <param name="firstRowIndex"></param>
        /// <param name="lastRowIndex"></param>
        /// <param name="parentRow"></param>
        void IHasCustomCells.RenderSubtotals(GridViewRow parentRow, HtmlTextWriter writer, int firstRowIndex, int lastRowIndex)
        {
            _footerRow.RenderSubtotals(writer, firstRowIndex, lastRowIndex);
            //_footerRow.RenderControl(writer);
        }

        /// <summary>
        /// The n'th entry is the array of values of <see cref="DataCellFields"/>.
        /// </summary>
        private readonly Dictionary<int, object[]> _curCellValues;

        /// <summary>
        /// All cell values pertaining to the row currently being data bound
        /// </summary>
        /// <remarks>
        /// <para>
        /// They are maintained in <see cref="IHasCustomCells.FilterRow"/>.
        /// <see cref="MatrixCell.DataBind"/> uses them to set cell values and row totals.
        /// </para>
        /// </remarks>
        internal IDictionary<int, object[]> CurCellValues
        {
            get
            {
                return _curCellValues;
            }
        }

        /// <summary>
        /// Becomes false when the next data item matches the current data item
        /// </summary>
        private bool _isFirstRowOfSet = true;

        /// <summary>
        /// Decides whether the <paramref name="dataItem"/> returned by data source should be displayed as a grid row
        /// </summary>
        /// <param name="dataItem">The dataItem returned by the data source</param>
        /// <param name="peek">The next <paramref name="dataItem"/> which will be passed to <see cref="IHasCustomCells.FilterRow"/></param>
        /// <returns>true if the <paramref name="dataItem"/> should be retained</returns>
        /// <remarks>
        /// <para>
        /// Compares the <see cref="DataMergeFields"/> of <paramref name="dataItem"/> and <paramref name="peek"/>.
        /// If they are same, then this dataItem is not accepted in anticipation of accepting it when it is sent to us next.
        /// We accept the  <paramref name="dataItem"/> only when it is the last dataItem for the <see cref="DataMergeFields"/>
        /// it represents.
        /// </para>
        /// </remarks>
        bool IHasCustomCells.FilterRow(object dataItem, object peek)
        {
            if (_isFirstRowOfSet)
            {
                _curCellValues.Clear();
                _isFirstRowOfSet = false;
            }
            int colDataIndex = this.MaybeAddHeaderValue(dataItem);
            bool bAcceptDataItem;
            if (this.DataMergeFields == null || this.DataMergeFields.Length == 0)
            {
                // If DataMergeFields not specified, rows are not merged. This helps debugging.
                bAcceptDataItem = true;
            }
            else
            {
                if (peek == null)
                {
                    // This is the last row of the grid. It must be accepted.
                    bAcceptDataItem = true;
                }
                else
                {
                    // Accept only if the next one does not match
                    bAcceptDataItem = !this.DataMergeFields.Select(p => DataBinder.Eval(peek, p))
                        .SequenceEqual(this.DataMergeFields.Select(p => DataBinder.Eval(dataItem, p)));
                }
            }

            object[] cellValues = (from dataField in this.DataCellFields
                                   select DataBinder.Eval(dataItem, dataField)).ToArray();
            _curCellValues.Add(colDataIndex, cellValues);
            if (bAcceptDataItem)
            {
                _isFirstRowOfSet = true;
            }
            return bAcceptDataItem;
        }

        #endregion

        /// <summary>
        /// Evaluates the <see cref="DataHeaderFields"/> of the passed dataItem. It then searches for them in the header value list
        /// <see cref="DataHeaderValues"/>. If these header values are not found, it adds them to the list.
        /// </summary>
        /// <param name="dataItem">The dataItem to evaluate</param>
        /// <returns>The index of header fields in header value list</returns>
        private int MaybeAddHeaderValue(object dataItem)
        {
            object[] curValues = this.DataHeaderFields.Select(p => DataBinder.Eval(dataItem, p)).ToArray();
            int indexPlusOne = this.DataHeaderValues.Select((p, i) => p.SequenceEqual(curValues) ? i + 1 : 0).FirstOrDefault(p => p > 0);
            if (indexPlusOne == 0)
            {
                this.DataHeaderValues.Add(curValues);
                indexPlusOne = this.DataHeaderValues.Count;
                //return indexPlusOne;
            }
            return indexPlusOne - 1;
        }

        /// <summary>
        /// Called when a new header value is added to the list by <see cref="MaybeAddHeaderValue"/> or by the page developer.
        /// Creates the corresponding <see cref="MatrixDisplayColumn"/> and adds them to <see cref="DisplayColumns"/>.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// <exception cref="NotImplementedException"></exception>
        private void dataHeaderValues_CollectionChanged(object sender, NotifyCollectionChangedEventArgs e)
        {
            switch (e.Action)
            {
                case NotifyCollectionChangedAction.Add:
                    foreach (MatrixColumn col in this.MatrixColumns.Where(p => p.ColumnType == MatrixColumnType.CellValue))
                    {
                        MatrixDisplayColumn dc = new MatrixDisplayColumn(this, col, e.NewStartingIndex);
                        _displayColumns.Add(dc);
                    }
                    break;

                default:
                    throw new NotImplementedException();
            }
        }


        private readonly ObservableCollection<MatrixDisplayColumn> _displayColumns;
        /// <summary>
        /// Returns columns in the order the header is rendered
        /// </summary>
        /// <remarks>
        /// <para>
        /// Hook to the <c>ObservableCollection.CollectionChanged</c> event if you want to modify columns as they are added.
        /// See <see cref="MatrixDisplayColumn.MainHeaderText"/> for an example.
        /// </para>
        /// </remarks>
        public ObservableCollection<MatrixDisplayColumn> DisplayColumns
        {
            get
            {
                return _displayColumns;
            }
        }
    }
}

using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.JQuery.Scripts;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Adds major enhancements to the ASP.NET <see cref="GridView"/>
    /// </summary>
    /// <include file='GridViewEx.xml' path='GridViewEx/doc[@name="class"]/*'/>
    [ControlValueProperty("SelectedValues[0]")]
    [Designer(typeof(System.Web.UI.Design.ControlDesigner))]
    public class GridViewEx : GridView
    {
        //public bool EnableTableScripting { get; set; }

        #region Initialization
        public GridViewEx()
        {
            // This class is used to apply styles to various grid view elements.
            this.CssClass = "gvex-table";
            this.SelectedRowStyle.CssClass = "ui-selected";
            this.EmptyDataText = "No rows found";
            this.FooterStyle.CssClass = "ui-state-active ui-widget-header";
            this.AlternatingRowStyle.CssClass = "gvex-alternating-row";
            this.PagerSettings.Position = PagerPosition.Top;
            this.PagerSettings.Mode = PagerButtons.NumericFirstLast;
            this.SelectedRowStyle.CssClass = "ui-selected";
            this.HeaderStyle.CssClass = "ui-state-default";
            this.DisplayMasterRow = true;
            this.ShowExpandCollapseButtons = true;
            // Viewstate is disabled by default, but page developer can enable it
            this.EnableViewState = false;
            this.EnableMasterRowNewSequence = false;
            this.EditRowStyle.CssClass = "gvex-edit-link";

        }

        private const string PREFIX_SORTEVENT = "Sort$";
        private const string PREFIX_PAGEEVENT = "PageSort$";

        /// <summary>
        /// If the event is PageSort, Raise paging events and set the new page index along with the default sort expression
        /// The intent is that the sort expression must not change across pages.
        /// </summary>
        /// <param name="eventArgument"></param>
        /// <remarks>
        /// eventArgument will look like PageSort$10$col1;col2 or PageSort$10$col1;col2;$;col3
        /// </remarks>
        protected override void RaisePostBackEvent(string eventArgument)
        {
            string str;
            int index;
            if (eventArgument.StartsWith(PREFIX_PAGEEVENT))
            {
                int pageIndex;
                str = HttpUtility.UrlDecode(eventArgument);
                string[] tokens = str.Substring(PREFIX_PAGEEVENT.Length).Split('$');
                index = tokens[0].LastIndexOf('/');
                if (index < 0)
                {
                    pageIndex = int.Parse(tokens[0]) - 1;
                }
                else
                {
                    // Windows 2003 server prefixes the number with the URL so we remove it
                    // e.g. http://localhost/.../3
                    pageIndex = int.Parse(tokens[0].Substring(index + 1)) - 1;
                }
                // Necessary to ensure that data binding occurs even if view state is enabled
                if (pageIndex != this.PageIndex)
                {
                    this.RequiresDataBinding = true;
                    str = tokens[1];
                    if (tokens.Length > 2)
                    {
                        str += "$" + tokens[2];
                    }
                    this.DefaultSortExpression = str;
                    this.PageIndex = pageIndex;
                    OnPageIndexChanged(EventArgs.Empty);
                }
            }
            else if (eventArgument.StartsWith(PREFIX_SORTEVENT))
            {
                str = HttpUtility.UrlDecode(eventArgument.Substring(PREFIX_SORTEVENT.Length));
                index = str.LastIndexOf('/');
                if (index < 0)
                {
                    this.DefaultSortExpression = str;
                }
                else
                {
                    this.DefaultSortExpression = str.Substring(index + 1);
                }
                this.PageIndex = 0;
                // Necessary to ensure that data binding occurs even if view state is enabled
                this.RequiresDataBinding = true;
                OnSorted(EventArgs.Empty);
            }
            else
            {
                base.RaisePostBackEvent(eventArgument);
            }
        }
        #endregion

        private MultiKeyDictionary<string, string> _clientEvents;

        /// <summary>
        /// Client events of the grid
        /// </summary>
        public IDictionary<string, string> ClientEvents
        {
            get
            {
                if (_clientEvents == null)
                {
                    _clientEvents = new MultiKeyDictionary<string, string>();
                }
                return _clientEvents;
            }
        }

        #region Paging and sorting
        protected override void InitializePager(GridViewRow row, int columnSpan, PagedDataSource pagedDataSource)
        {
            if (pagedDataSource.VirtualCount <= this.PageSize && row.TableSection == TableRowSection.TableFooter)
            {
                // Pager will not be visible. Reset the footer TableSection
                row.TableSection = TableRowSection.TableBody;
            }
            GridViewExPagerRow rowex = row as GridViewExPagerRow;
            if (rowex == null)
            {
                base.InitializePager(row, columnSpan, pagedDataSource);
            }
            else
            {
                rowex.Intialize(columnSpan, pagedDataSource);
            }
        }

        /// <summary>
        /// If true, then the grid will not initially try to sort itself, regardless of the DefaultSortExpression
        /// </summary>
        /// <remarks>
        /// <para>
        /// When <see cref="DefaultSortExpression"/> is specified, the grid passes this sort expression to the data source to ensure that
        /// the results are returned with the right sort order. If you know that your results are already properly sorted, you should set this
        /// to true.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool PreSorted { get; set; }

        /// <summary>
        /// Provides a way to set the sort expression at design time
        /// </summary>
        /// <include file='GridViewEx.xml' path='GridViewEx/doc[@name="DefaultSortExpression"]/*'/>
        [Browsable(true)]
        [DefaultValue("")]
        public string DefaultSortExpression
        {
            get
            {
                return _sortExpressions.ToString();
            }
            set
            {
                SortExpressionCollection coll = new SortExpressionCollection(value);
                if (!_sortExpressions.Equals(value))
                {
                    if (_masterColumnsCreated && !IsViewStateEnabled)
                    {
                        // _masterColumnsCreated is set to true when the first data row is created.
                        // If view state is enabled, master columns get created twice. Once when rows are created from
                        // view state and again when the control is data bound. With view state off (the default),
                        // we expect that master columns will be created only once unless you are double data binding.
                        throw new NotSupportedException("Will this happen?");
                    }
                    _sortExpressions = coll;
                    _masterColumnsCreated = false;
                }
            }
        }

        /// <summary>
        /// The current sort expression which may look like style$priority {0:I}
        /// </summary>
        private SortExpressionCollection _sortExpressions = new SortExpressionCollection();
        public override string SortExpression
        {
            get
            {
                return _sortExpressions.ToString();
            }
        }

        [Browsable(false)]
        internal SortExpressionCollection SortExpressions
        {
            get
            {
                return _sortExpressions;
            }
        }

        /// <summary>
        /// SortDirection is not used
        /// </summary>
        [Browsable(false)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
        public override SortDirection SortDirection
        {
            get
            {
                return SortDirection.Ascending;
            }
        }

        /// <summary>
        /// Capture the sort expression being passed.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnSorting(GridViewSortEventArgs e)
        {
            throw new NotSupportedException("GridViewEx never raises the Sorting event");
        }

        protected override void OnPageIndexChanging(GridViewPageEventArgs e)
        {
            throw new NotSupportedException("GridViewEx never raises the PageIndexChanging event");
        }

        #endregion

        #region Rendering
        /// <summary>
        /// Register scripts only if grid has rows
        /// </summary>
        /// <param name="e"></param>
        /// <remarks>
        /// The selectable events are registered using bind syntax. Registering them as selectable options will
        /// not work because we raise those events as well.
        /// </remarks>
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            // Render scripts even if row count 0 so that developer scripts do not raise errors when there are no rows.
            if (this.DesignMode)
            {
                return;
            }
            // Try to guess whether scripts will be needed
            if (this.ClientIDMode == ClientIDMode.Static ||   // User intends to write script against this grid view
                this.AllowSorting ||       // Sorting requires scripts
                this._masterColumnIndexes != null ||  // Master columns need script to expand/collapse
                this.AllowPaging ||     // Script needed to handle paging clicks
                this.EnableViewState ||  // User intends to edit
                (this._rowMenuItems != null && this._rowMenuItems.Count > 0)
                )
            {
                if (string.IsNullOrEmpty(this.ID))
                {
                    throw new HttpException("ID for GridViewEx is required for scripting");
                }
                JQueryScriptManager.Current.CreateScripts += new EventHandler(JQueryScriptManager_CreateScripts);
            }
            else
            {
                // Scripts not needed
                return;
            }
        }

        /// <summary>
        /// Event handler for <see cref="JQueryScriptManager.CreateScripts"/>. Create all the required scripts
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void JQueryScriptManager_CreateScripts(object sender, EventArgs e)
        {
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.UiCore | ScriptTypes.GridViewEx |
                ScriptTypes.Json);
            JQueryOptions options = new JQueryOptions();
            if (_selectable != null)
            {
                _selectable.MakeSelectable(this, options);
            }
            // Create an array of visible column names and save it in table element data
            List<string> list = this.Columns.Cast<DataControlField>().Where(p => p.Visible)
                .Select(p => p.AccessibleHeaderText).ToList();
            options.Add("columnNames", list);
            string str;
            //foreach (var col in this.Columns.Cast<DataControlField>().Where(p => p.Visible))
            //{
            //    str = string.Format("'{0}'", col.AccessibleHeaderText);
            //    list.Add(str);
            //}
            //options.AddRaw("columnNames", "[" + string.Join(",", list.ToArray()) + "]");

            options.Add("uniqueId", this.UniqueID);
            if (this.DataKeyNames.Length > 0)
            {
                options.Add("dataKeysCount", this.DataKeyNames.Length);
                if (!this.IsViewStateEnabled)
                {
                    str = GetSerializedDataKeys();
                    options.AddRaw("dataKeys", str);
                }
            }
            if (this.Page.Form != null && !string.IsNullOrEmpty(this.Page.Form.ClientID))
            {
                options.Add("form", "#{0}", this.Page.Form.ClientID);
            }

            // Data keys are stored as jquery array to provide access to client script
            AddControlState(options);
            AddRowMenuOptions(options);

            StringBuilder script = new StringBuilder();
            script.AppendFormat("$('#{0}').gridViewEx({1})",
                this.ClientID, options.ToJson());
            if (_clientEvents != null)
            {
                foreach (var item in _clientEvents)
                {
                    script.AppendFormat(".bind('{0}', {1})", item.Key, item.Value);
                }
            }
            script.Append(";");
            JQueryScriptManager.Current.RegisterReadyScript(script.ToString());

            if (this.Rows.Count > 0 && this.MasterColumnIndexes != null && this.DisplayMasterRow &&
                this.ShowExpandCollapseButtons)
            {
                _btnExpandAll = new ButtonEx();
                _btnExpandAll.CausesValidation = false;
                _btnExpandAll.Text = "Expand All";
                _btnExpandAll.Icon = ButtonIconType.PlusThick;
                _btnExpandAll.Action = ButtonAction.None;
                _btnExpandAll.ID = this.ClientID + "_expandAll";
                _btnExpandAll.OnClientClick = string.Format(@"function(e) {{
$('#{0}').gridViewEx('expandAll');
}}", this.ClientID);
                _btnExpandAll.RegisterScripts();

                _btnCollapseAll = new ButtonEx();
                _btnCollapseAll.CausesValidation = false;
                _btnCollapseAll.Text = "Collapse All";
                _btnCollapseAll.Icon = ButtonIconType.MinusThick;
                _btnCollapseAll.Action = ButtonAction.None;
                _btnCollapseAll.ID = this.ClientID + "_collapseAll";
                _btnCollapseAll.OnClientClick = string.Format(@"function(e) {{
$('#{0}').gridViewEx('collapseAll');
}}", this.ClientID);
                _btnCollapseAll.RegisterScripts();
            }
        }

        protected override void Render(HtmlTextWriter writer)
        {
            if (this.FooterRow != null)
            {
                UpdateFooterCellText();
            }
            RenderMenuItems(writer);
            base.Render(writer);

            var q = this.Ancestors(true).Where(p => !p.EnableViewState).FirstOrDefault();

            if (this.IsViewStateEnabled)
            {
                if (this.Rows.Count > 0 && this.DataKeyNames.Length > 0)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
                    writer.AddAttribute(HtmlTextWriterAttribute.Id,
                        this.ClientID + this.ClientIDSeparator + SUFFIX_DATAKEYSINPUT);
                    writer.AddAttribute(HtmlTextWriterAttribute.Name,
                        this.UniqueID + this.IdSeparator + SUFFIX_DATAKEYSINPUT);
                    string str = GetSerializedDataKeys();
                    writer.AddAttribute(HtmlTextWriterAttribute.Value, str);
                    writer.RenderBeginTag(HtmlTextWriterTag.Input);
                    writer.RenderEndTag();
                }
                //if ((_selectable != null && _selectable.IsSelectable) || this.SelectedIndex >= 0)
                //{
                // Sharad 16 Sep 2010: Selected indexes will be posted back whenever view state is enabled
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
                writer.AddAttribute(HtmlTextWriterAttribute.Id,
                    this.ClientID + this.ClientIDSeparator + SUFFIX_SELECTIONS);
                writer.AddAttribute(HtmlTextWriterAttribute.Name,
                    this.UniqueID + this.IdSeparator + SUFFIX_SELECTIONS);
                if (_selectedIndexes != null && _selectedIndexes.Count > 0)
                {
                    JavaScriptSerializer serializer = new JavaScriptSerializer();
                    string str = serializer.Serialize(_selectedIndexes);
                    writer.AddAttribute(HtmlTextWriterAttribute.Value, str);
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Input);
                writer.RenderEndTag();
                //}
            }
        }

        private string GetSerializedDataKeys()
        {
            var query = from DataKey key in this.DataKeys
                        select key.Values.Values;
            JavaScriptSerializer ser = new JavaScriptSerializer();
            string str = ser.Serialize(query);
            return str;
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            if (_btnExpandAll != null)
            {
                //writer.AddStyleAttribute(HtmlTextWriterStyle.Margin, "1em 1em 1em 1em");
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "gvex-expandcollapse");
                writer.RenderBeginTag(HtmlTextWriterTag.Div);
                _btnExpandAll.RenderControl(writer);
                writer.Write("&nbsp;&nbsp;&nbsp;&nbsp;");
                _btnCollapseAll.RenderControl(writer);
                writer.RenderEndTag();      // div
            }
            base.RenderContents(writer);
        }

        #endregion

        #region Selection Modes
        private ButtonEx _btnExpandAll;
        private ButtonEx _btnCollapseAll;

        private List<int> _selectedIndexes;

        private GridViewExSelectable _selectable;

        /// <summary>
        /// Enables multiple row level selection for the grid. 
        /// </summary>
        /// <include file='GridViewEx.xml' path='GridViewEx/doc[@name="Selectable"]/*'/>
        [Browsable(true)]
        [NotifyParentProperty(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public GridViewExSelectable Selectable
        {
            get
            {
                // DebuggerBrowsable attribute ensures taht the grid does not become selectable just because you looked at the property
                if (_selectable == null)
                {
                    _selectable = new GridViewExSelectable();
                }
                return _selectable;
            }
        }

        /// <summary>
        /// SelectedIndexes become meaningless after you data bind the grid.
        /// This property is useful after postback only if you set EnableViewState to true and you have specified
        /// at least one data key.
        /// </summary>
        /// <remarks>
        /// <para>
        /// When <c>EnableViewState</c> is <c>true</c>, you can
        /// determine the indexes of the rows selected by the user on the client side. Under these conditions
        /// a hidden field is created during <see cref="Render"/>. The <c>gridViewEx</c> widget updates this
        /// hidden field each time the user changes the selections.
        /// </para>
        /// <para>
        /// During <see cref="LoadControlState"/> values are read from this hidden field and the
        /// populated in <c>SelectedIndexes</c>. During <see cref="CreateRow"/>, the row is marked as selected
        /// if its index exists in <c>SelectedIndexes</c>. All <c>SelectedIndexes</c>
        /// are discarded when <see cref="PerformDataBinding"/> is called.
        /// is called.
        /// </para>
        /// <para>
        /// Sharad 16 Sep 2010: Selected indexes no longer require the grid to be selectable. They are available as long as
        /// <c>EnableViewState</c> is true.
        /// </para>
        /// </remarks>
        [Browsable(false)]
        public IList<int> SelectedIndexes
        {
            get
            {
                if (_selectedIndexes == null)
                {
                    _selectedIndexes = new List<int>();
                }
                return _selectedIndexes;
            }
        }

        /// <summary>
        /// Simply gets and sets the first selected index
        /// </summary>
        public override int SelectedIndex
        {
            get
            {
                if (_selectedIndexes == null || _selectedIndexes.Count == 0)
                {
                    return -1;
                }
                else
                {
                    return _selectedIndexes[0];
                }
            }
            set
            {
                if (value >= 0)
                {
                    if (_selectedIndexes == null || _selectedIndexes.Count == 0)
                    {
                        _selectedIndexes = new List<int>();
                        _selectedIndexes.Add(value);
                    }
                    else
                    {
                        _selectedIndexes[0] = value;
                    }
                }
                else
                {
                    _selectedIndexes = null;
                }
            }
        }

        #endregion

        #region Empty Data Text
        /// <summary>
        /// Becomes true if null data is passed to PerformDataBinding. It usually means that the query was
        /// cancelled.
        /// </summary>
        private bool _bQueryCancelled;

        protected override void PerformDataBinding(IEnumerable data)
        {
            _dataKeys = null;
            _bDataRowCreated = false;
            if (data == null)
            {
                _bQueryCancelled = true;
            }
            _countInvisibleRows = 0;
            _selectedIndexes = null;

            IHasCustomCells[] customCells = this.Columns.OfType<IHasCustomCells>().ToArray();
            if (data == null || customCells.Length == 0)
            {
                base.PerformDataBinding(data);
            }
            else
            {
                base.PerformDataBinding(FilteredData(customCells, data));
            }
        }

        private IEnumerable FilteredData(IHasCustomCells[] customCells, IEnumerable data)
        {
            object previous = null;
            foreach (var item in data)
            {
                if (previous == null)
                {
                    previous = item;
                    continue;
                }
                // Exception if custom cells do not agree about keeping the row
                bool b = customCells.Select(p => p.FilterRow(previous, item)).Distinct().Single();
                if (b)
                {
                    yield return previous;
                }
                previous = item;
            }
            if (previous != null)
            {
                bool b = customCells.Select(p => p.FilterRow(previous, null)).Distinct().Single();
                if (b)
                {
                    yield return previous;
                }
            }
        }

        /// <summary>
        /// Do not show empty text if query was cancelled
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is the text which is displayed if the query returns no rows. If the query is cancelled
        /// due to any reason, then this text is not displayed. The thinking is that this text will typically
        /// be <c>No Pickslip Found</c> and it is unreasonable to say this if the query was never executed.
        /// </para>
        /// <para>
        /// If you need to update this property programmatically, you must do so before data binding begins.
        /// If you must change it after data binding, then you can use flloing code in the
        /// <c>RowDataBound</c> event.
        /// </para>
        /// <code>
        /// <![CDATA[
        /// protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
        /// {
        ///    switch (e.Row.RowType)
        ///    {
        ///        case DataControlRowType.EmptyDataRow:
        ///            e.Row.Cells[0].Text = "Sorry, Nothing found";
        ///            break;
        ///    }
        /// }
        /// ]]>
        /// </code>
        /// </remarks>
        [DefaultValue("No rows found")]
        public override string EmptyDataText
        {
            get
            {
                if (_bQueryCancelled)
                {
                    return string.Empty;
                }
                else
                {
                    return base.EmptyDataText;
                }
            }
            set
            {
                base.EmptyDataText = value;
            }
        }
        #endregion

        #region Row Creation
        /// <summary>
        /// Generate th instead of td
        /// </summary>
        /// 
        [ReadOnly(true)]
        public override bool UseAccessibleHeader
        {
            get
            {
                return true;
            }
            set
            {

            }
        }

        private bool _bDataRowCreated;
        protected override GridViewRow CreateRow(int rowIndex, int dataSourceIndex, DataControlRowType rowType, DataControlRowState rowState)
        {
            GridViewRow row;
            switch (rowType)
            {
                case DataControlRowType.DataRow:
                    _bDataRowCreated = true;

                    if (this.MasterColumnIndexes != null && this.DisplayMasterRow)
                    {
                        row = new GridViewExMasterRow(this, rowIndex, dataSourceIndex, rowState);
                    }
                    else
                    {
                        //row = base.CreateRow(rowIndex, dataSourceIndex, rowType, rowState);
                        row = new GridViewExDataRow(this, rowIndex, dataSourceIndex, rowType, rowState);
                    }
                    if (_selectedIndexes != null && _selectedIndexes.Contains(rowIndex))
                    {
                        row.RowState |= DataControlRowState.Selected;
                    }
                    break;

                case DataControlRowType.EmptyDataRow:
                    row = base.CreateRow(rowIndex, dataSourceIndex, rowType, rowState);
                    break;

                case DataControlRowType.Footer:
                    row = base.CreateRow(rowIndex, dataSourceIndex, rowType, rowState);
                    if (this.ShowFooter)
                    {
                        row.TableSection = TableRowSection.TableFooter;
                    }
                    break;

                case DataControlRowType.Header:
                    row = new GridViewExHeaderRow(rowIndex, dataSourceIndex, rowType, rowState);
                    break;

                case DataControlRowType.Pager:
                    // NumericFirstLast pager is custom implemented
                    if (this.PagerSettings.Mode == PagerButtons.NumericFirstLast)
                    {
                        // _selectArguments will be null if the query was cancelled
                        row = new GridViewExPagerRow(
                            _bDataRowCreated ? TableRowSection.TableFooter : TableRowSection.TableHeader);
                    }
                    else
                    {
                        row = base.CreateRow(rowIndex, dataSourceIndex, rowType, rowState);
                        row.TableSection = _bDataRowCreated ? TableRowSection.TableFooter : TableRowSection.TableHeader;
                    }
                    break;

                case DataControlRowType.Separator:
                default:
                    throw new NotImplementedException();
            }
            return row;
        }


        protected override void InitializeRow(GridViewRow row, DataControlField[] fields)
        {
            DataControlFieldCell cell;
            switch (row.RowType)
            {
                case DataControlRowType.Header:
                    foreach (DataControlField field in fields)
                    {
                        IHasCustomCells cancreate = field as IHasCustomCells;
                        if (cancreate == null)
                        {
                            cell = new GridViewExHeaderCell(this, field);
                        }
                        else
                        {
                            cell = cancreate.CreateCell(DataControlCellType.Header);
                        }
                        field.InitializeCell(cell, DataControlCellType.Header, row.RowState, row.RowIndex);
                        row.Cells.Add(cell);
                    }
                    break;

                case DataControlRowType.DataRow:
                    foreach (DataControlField field in fields)
                    {
                        IHasCustomCells cancreate = field as IHasCustomCells;
                        if (cancreate == null)
                        {
                            cell = new DataControlFieldCell(field);
                        }
                        else
                        {
                            cell = cancreate.CreateCell(DataControlCellType.DataCell);
                        }
                        field.InitializeCell(cell, DataControlCellType.DataCell, row.RowState, row.RowIndex);
                        row.Cells.Add(cell);
                    }

                    break;

                case DataControlRowType.Footer:
                    foreach (DataControlField field in fields)
                    {
                        IHasCustomCells cancreate = field as IHasCustomCells;
                        if (cancreate == null)
                        {
                            cell = new DataControlFieldCell(field);
                        }
                        else
                        {
                            cell = cancreate.CreateCell(DataControlCellType.Footer);
                        }
                        field.InitializeCell(cell, DataControlCellType.Footer, row.RowState, row.RowIndex);
                        row.Cells.Add(cell);
                    }
                    break;

                default:
                    base.InitializeRow(row, fields);
                    break;
            }
        }

        #endregion

        #region Master Row

        /// <summary>
        /// Whether master columns should be ignored, even if they are specified
        /// </summary>
        /// <remarks>
        /// This is useful when exporting to Excel. You can force the grid to not render the master subheaders
        /// even though master columns have been specified in <see cref="DefaultSortExpression"/>.
        /// </remarks>
        [Browsable(false)]
        [Themeable(false)]
        [DefaultValue(true)]
        public bool DisplayMasterRow { get; set; }

        /// <summary>
        /// Whether Expand All and Collapse All buttons should be displayed. Default true.
        /// This is relevant only when master columns have been specified.
        /// </summary>
        /// <include file='GridViewEx.xml' path='GridViewEx/doc[@name="ShowExpandCollapseButtons"]/*'/>        
        [Browsable(true)]
        [DefaultValue(true)]
        [Themeable(true)]
        public bool ShowExpandCollapseButtons { get; set; }

        /// <summary>
        /// A flag used to track whether master column indexes have been computed
        /// </summary>
        private bool _masterColumnsCreated;
        private List<int> _masterColumnIndexes;

        /// <summary>
        /// Column indexes of master columns. The indexes must be in the order of master expressions.
        /// MasterColumnIndexes will be returned whether or not DisplayMasterRow is true. GridViewMatrixField
        /// relies on this behavior.
        /// </summary>
        internal IList<int> MasterColumnIndexes
        {
            get
            {
                if (_masterColumnsCreated)
                {
                    return _masterColumnIndexes;
                }
                //char[] seperator = new char[] { ';' };
                //string[] tokens = _sortExpressions.Split(seperator, StringSplitOptions.RemoveEmptyEntries);
                /*
                 * This join query is similar to:
                _masterColumnIndexes = (
                    from string masterExpr in tokens.TakeWhile(p => p != "$")
                    select this.Columns.Cast<DataControlField>().IndexOfFirst(
                    p => SortFormatProvider.SortExpressionsEqual(p.SortExpression, masterExpr))).ToList();
                 * e.g. priority;$;style;color reverses to become color;style;$;priority. 
                 * Then we skip everything before $ leaving us with $;priority.
                 * We filter out the $ in the where clause and are left with just the master expression priority.
                 * If there is no $, we are guaranteed to get an empty list.
                */

                _masterColumnIndexes =
                    (from defexpr in _sortExpressions.MasterSortExpressions
                     from DataControlField col in this.Columns
                     where defexpr.Equals(col.SortExpression)
                     select this.Columns.IndexOf(col)).ToList();
                if (_masterColumnIndexes.Count == 0)
                {
                    // No master columns
                    _masterColumnIndexes = null;
                }

                _masterColumnsCreated = true;
                return _masterColumnIndexes;
            }
        }

        protected override void OnDataBound(EventArgs e)
        {
            if (this.MasterColumnIndexes != null && this.DisplayMasterRow)
            {
                // Make master columns invisible. Changing visibility of column makes the grid rebind.
                // So we are having to explicitly manage the RequiresDataBinding flag.
                for (int i = 0; i < _masterColumnIndexes.Count; ++i)
                {
                    this.Columns[_masterColumnIndexes[i]].Visible = false;
                }
                this.RequiresDataBinding = false;
            }
            base.OnDataBound(e);
        }


        #endregion

        #region DataSource

        /// <summary>
        /// We convert sort expression of "max_priority {0};style {0};color {0};dimension {0};sku_size {0}"
        /// into "max_priority DESC, style DESC, color DESC, dimension DESC, sku_size DESC"
        /// depending on the sort direction. Specifying {0} in the sort expression is optional.
        /// DefaultSortExpression is ignored if datasource cannot sort
        /// </summary>
        /// <returns></returns>
        protected override DataSourceSelectArguments CreateDataSourceSelectArguments()
        {
            DataSourceSelectArguments selectArguments = base.CreateDataSourceSelectArguments();
            //uncomment the if clause because it is being used by reports 110.03 and 130.07. It is obsolete property
            // and earlier we have to define defaultsortexpresssion in every case than it was useful. Now we may or may not
            //define the sort expression.
            if (!this.PreSorted)
            {
                selectArguments.SortExpression = _sortExpressions.GetDataSourceSortExpression();
            }

            return selectArguments;
        }

        #endregion

        #region Summary Management

        /// <summary>
        /// Number of rows which are not visible. We supply this info to each row so that the RowIndex
        /// they return can correspond to visible row index.
        /// </summary>
        private int _countInvisibleRows;

        /// <summary>
        /// After all RowDataBound events have executed, footer row needs to calculate summary of visible rows
        /// </summary>
        /// <param name="e"></param>
        protected override void OnRowDataBound(GridViewRowEventArgs e)
        {
            base.OnRowDataBound(e);
            switch (e.Row.RowType)
            {
                case DataControlRowType.Header:
                    var query = from INeedsSummaries col in this.Columns.OfType<INeedsSummaries>()
                                where col.DataSummaryCalculation != SummaryCalculationType.None
                                select col;

                    //Clear the previous summary values to support the SummaryValues in viewState . 
                    foreach (INeedsSummaries col in query)
                    {
                        col.SummaryValues = null;
                        col.SummaryValuesCount = null;
                    }
                    break;

                case DataControlRowType.DataRow:
                    if (e.Row.Visible && (e.Row.RowState & DataControlRowState.Insert) != DataControlRowState.Insert)
                    {
                        query = from INeedsSummaries col in this.Columns.OfType<INeedsSummaries>()
                                where col.DataSummaryCalculation != SummaryCalculationType.None
                                select col;
                        foreach (INeedsSummaries col in query)
                        {
                            UpdateSummaries(col, e);
                        }
                        if (_countInvisibleRows > 0)
                        {
                            // Common case
                            GridViewExDataRow row = (GridViewExDataRow)e.Row;
                            if (row != null)
                            {
                                row.InvisibleRowCount = _countInvisibleRows;
                            }
                        }
                    }
                    else
                    {
                        ++_countInvisibleRows;
                    }
                    break;
            }
        }

        /// <summary>
        /// Should be called for visible rows only. Displaying nothing when sum evaluates to null.
        /// </summary>
        private void UpdateSummaries(INeedsSummaries col, GridViewRowEventArgs e)
        {
            //decimal?[] values;
            object obj;
            switch (col.DataSummaryCalculation)
            {
                case SummaryCalculationType.DataSource:
                    if (col.DataFooterFields == null || col.DataFooterFields.Length == 0)
                    {
                        throw new InvalidOperationException("To compute totals, DataFooterFields must be specified");
                    }

                    if (col.SummaryValues == null)
                    {
                        col.SummaryValues = new decimal?[col.DataFooterFields.Length];
                        for (int i = 0; i < col.SummaryValues.Length; ++i)
                        {
                            obj = DataBinder.Eval(e.Row.DataItem, col.DataFooterFields[i]);
                            if (obj != DBNull.Value)
                            {
                                col.SummaryValues[i] = Convert.ToDecimal(obj);
                            }
                        }
                        //col.SummaryValues = values;
                    }
                    break;

                case SummaryCalculationType.ValueSummation:
                case SummaryCalculationType.ValueWeightedAverage:
                    if (col.SummaryValues == null)
                    {
                        col.SummaryValues = new decimal?[col.DataFooterFields.Length];
                        col.SummaryValuesCount = new int[col.DataFooterFields.Length];
                    }
                    for (int i = 0; i < col.SummaryValues.Length; ++i)
                    {
                        obj = DataBinder.Eval(e.Row.DataItem, col.DataFooterFields[i]);
                        if (obj != DBNull.Value)
                        {
                            decimal d = Convert.ToDecimal(obj);
                            if (col.SummaryValues[i] == null)
                            {
                                col.SummaryValues[i] = d;
                            }
                            else
                            {
                                col.SummaryValues[i] += d;
                            }
                            ++col.SummaryValuesCount[i];
                        }
                    }
                    break;

                default:
                    throw new NotImplementedException();
            }
        }

        private void UpdateFooterCellText()
        {
            foreach (DataControlFieldCell cell in this.FooterRow.Cells.Cast<DataControlFieldCell>()
                .Where(p => p.ContainingField is INeedsSummaries))
            {
                INeedsSummaries footerField = (INeedsSummaries)cell.ContainingField;
                cell.ToolTip = footerField.FooterToolTip;
                switch (footerField.DataSummaryCalculation)
                {
                    case SummaryCalculationType.None:
                        break;

                    case SummaryCalculationType.ValueSummation:
                    case SummaryCalculationType.DataSource:
                        if (footerField.SummaryValues != null)
                        {
                            // SummaryValues will be null when grid is being recreated from ViewState.
                            // All fields are expected to store SummaryValues in ViewState. If they do not
                            // then at least we avoid the null reference error.
                            string formatString = footerField.DataFooterFormatString;
                            if (string.IsNullOrEmpty(formatString))
                            {
                                formatString = "{0}";
                            }
                            object[] values = footerField.SummaryValues.Cast<object>().ToArray();
                            cell.Text = string.Format(formatString, values);
                        }
                        break;

                    case SummaryCalculationType.ValueWeightedAverage:
                        if (footerField.SummaryValues != null)
                        {
                            // SummaryValues will be null when grid is being recreated from ViewState.
                            // All fields are expected to store SummaryValues in ViewState. If they do not
                            // then at least we avoid the null reference error.
                            string formatString = footerField.DataFooterFormatString;
                            if (string.IsNullOrEmpty(formatString))
                            {
                                formatString = "{0}";
                            }
                            object value = footerField.SummaryValues[0] / footerField.SummaryValues[1];
                            //object[] values = footerField.SummaryValues
                            //    .Select((p, i) => footerField.SummaryValuesCount[i] == 0 ? null : p / footerField.SummaryValuesCount[i])
                            //    .Cast<object>().ToArray();
                            cell.Text = string.Format(formatString, value);
                        }
                        break;

                    default:
                        throw new NotImplementedException();
                }
            }
        }

        #endregion

        #region Control State

        /// <summary>
        /// The suffix to use in the name and id of the input control which will be used to post back the data keys.
        /// </summary>
        private const string SUFFIX_DATAKEYSINPUT = "dk";

        /// <summary>
        /// The suffix to use in the name and id of the input control which will be used to post back selected indexes.
        /// </summary>
        private const string SUFFIX_SELECTIONS = "sel";

        /// <summary>
        /// DataKeys loaded from control state are available in _dataKeys.
        /// After databinding, the base class data keys are used
        /// </summary>
        private DataKeyArray _dataKeys;

        /// <summary>
        /// DataKeys are saved in view state and not in control state
        /// </summary>
        public override DataKeyArray DataKeys
        {
            get
            {
                if (_dataKeys == null)
                {
                    return base.DataKeys;
                }
                else
                {
                    return _dataKeys;
                }
            }
        }

        /// <summary>
        /// Called from <see cref="OnPreRender"/>. Tell the gridViewEx widget about our data keys
        /// </summary>
        /// <param name="options"></param>
        private void AddControlState(JQueryOptions options)
        {
            if (this.Rows.Count > 0)
            {
                string str;
                if (this.EnableViewState)
                {
                    HtmlForm form = this.Ancestors(false).OfType<HtmlForm>().FirstOrDefault();
                    if (form == null)
                    {
                        str = string.Format("Since EnableViewState=true for grid {0}, it must be placed within a server form",
                            this.ID);
                        throw new HttpException(str);
                    }
                    if (this.IsViewStateEnabled && this.DataKeyNames.Length > 0)
                    {
                        str = string.Format("#{0}{1}{2}", this.ClientID, this.ClientIDSeparator, SUFFIX_DATAKEYSINPUT);
                        options.Add("_dataKeysInputSelector", str);
                    }
                    //if ((_selectable != null && _selectable.IsSelectable) || this.SelectedIndex >= 0)
                    //{
                    str = string.Format("#{0}{1}{2}", this.ClientID, this.ClientIDSeparator, SUFFIX_SELECTIONS);
                    options.Add("_selections", str);
                    //}
                }
            }
        }

        /// <summary>
        /// Load the data keys from hidden field and store in _dataKeys.
        /// Should we save something else in the control state as well?
        /// We must save the edit index for editing to work properly
        /// </summary>
        /// <param name="savedState"></param>
        protected override void LoadControlState(object savedState)
        {
            Triplet pair = (Triplet)savedState;
            this.EditIndex = (int)pair.First;
            this.DataKeyNames = (string[])pair.Second;
            this.PageIndex = (int)pair.Third;
            string str = this.Page.Request.Form[this.UniqueID + this.IdSeparator + SUFFIX_DATAKEYSINPUT];
            if (!string.IsNullOrEmpty(str))
            {
                JavaScriptSerializer ser = new JavaScriptSerializer();
                IEnumerable<object[]> allValues = ser.Deserialize<IEnumerable<object[]>>(str);
                ArrayList list = new ArrayList();
                foreach (object[] values in allValues)
                {
                    OrderedDictionary dict = new OrderedDictionary();
                    for (int i = 0; i < values.Length; ++i)
                    {
                        dict.Add(this.DataKeyNames[i], values[i]);
                    }
                    DataKey key = new DataKey(dict, this.DataKeyNames);
                    list.Add(key);
                }
                _dataKeys = new DataKeyArray(list);
            }

            str = this.Page.Request.Form[this.UniqueID + this.IdSeparator + SUFFIX_SELECTIONS];
            if (!string.IsNullOrEmpty(str))
            {
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                _selectedIndexes = new List<int>(serializer.Deserialize<int[]>(str));
            }
        }

        /// <summary>
        /// Save data key names and edit index. Data key names need to be saved because
        /// Dynamic Data forgets them.
        /// </summary>
        /// <returns></returns>
        /// <remarks>
        /// We save the page index only if view state is enabled
        /// </remarks>
        protected override object SaveControlState()
        {
            Triplet pair = new Triplet(this.EditIndex, this.DataKeyNames, this.PageIndex);
            return pair;
        }

        #endregion

        private Collection<RowMenuItemBase> _rowMenuItems;

        /// <summary>
        /// The items to display in the row menu of the grid
        /// </summary>
        /// <remarks>
        /// <para>
        /// If you are setting any <see cref="RowMenuItem"/> property dynamically, you must do it
        /// during or before the <c>PreRender</c> event.
        /// </para>
        /// <para>
        /// When a row is in edit or insert mode, row menu is not diplayed for that row.
        /// Row menu is not displayed for disabled rows either.
        /// </para>
        /// <para>
        /// If the grid is within an accordion, the left edge of the row menu could get truncated
        /// because accordion does not allow anything to go outside its boundaries. You can workaround
        /// this by adding this style to your page. Make sure that there are no side effects.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///<style type="text/css">
        ///.ui-accordion .ui-accordion-content 
        ///{
        ///    overflow:visible!important;
        ///}
        ///</style>
        /// ]]>
        /// </code>
        /// <para>
        /// Sharad 19 Oct 2010: On printer friendly pages, the row menu will show up. To avoid this, you need to define
        /// the following css in in your printing.css file. The default styles will prevent the row menu from printing, but they
        /// will not prevent it from showing on the printer friendly screen.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///.gvex-rowmenu
        ///{
        ///    display: none!important;
        ///}
        /// ]]>
        /// </code>
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public Collection<RowMenuItemBase> RowMenuItems
        {
            get
            {
                if (_rowMenuItems == null)
                {
                    _rowMenuItems = new Collection<RowMenuItemBase>();
                }
                return _rowMenuItems;
            }
        }

        /// <summary>
        /// Adds a javascript array of functions to menuItemActions options.
        /// </summary>
        /// <param name="options"></param>
        private void AddRowMenuOptions(JQueryOptions options)
        {
            if (this.Rows.Count > 0 && _rowMenuItems != null && _rowMenuItems.Count > 0)
            {
                var list = _rowMenuItems.Where(p => p.Visible && ButtonEx.IsUserInAnyRole(this.Page.User, p.RolesRequired))
                    .Select(p => p.GetClientFunction(this))
                    .ToArray();
                string str = "[" + string.Join(",", list) + "]";
                options.AddRaw("menuItemActions", str);
            }
        }

        /// <summary>
        /// <div class="ui-widget gvex-rowmenu">
        /// <div id="myid_menu" class="gvex-rowmenu ...">
        ///     <div>Item 1</div>
        ///     <div>Item 2</div>
        /// </div>
        /// </div>
        /// </summary>
        /// <param name="writer"></param>
        private void RenderMenuItems(HtmlTextWriter writer)
        {
            if (this.Rows.Count > 0 && _rowMenuItems != null && _rowMenuItems.Count > 0)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-widget gvex-rowmenu");
                writer.RenderBeginTag(HtmlTextWriterTag.Div);       // outer div
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-widget-content ui-selecting ui-helper-hidden");
                writer.AddAttribute(HtmlTextWriterAttribute.Id,
                    this.ClientID + "_menu");
                writer.RenderBeginTag(HtmlTextWriterTag.Div);       // content div
                foreach (var item in _rowMenuItems.Where(p => p.Visible && ButtonEx.IsUserInAnyRole(this.Page.User, p.RolesRequired)))
                {
                    if (!string.IsNullOrEmpty(item.ToolTip))
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Title, item.ToolTip);
                    }
                    writer.RenderBeginTag(HtmlTextWriterTag.Div);
                    writer.Write(item.Text);
                    writer.RenderEndTag();      // item div
                }
                writer.RenderEndTag();      // content div
                writer.RenderEndTag();      // outermost div
            }
        }

        /// <summary>
        /// Shortcut to retrieving the first data key of the first selected row
        /// </summary>
        public new object SelectedValue
        {
            get
            {
                throw new NotSupportedException("Use SelectedValues instead");
            }
        }

        /// <summary>
        /// The first string in the array is a comma separated list of the values of the first data key, and so on.
        /// The length of the array equals the number of data key names.
        /// </summary>
        /// <remarks>
        /// <para>
        /// <c>SelectedValues</c> will not reflect user selctions after postback 
        /// unless view state is enabled.
        /// </para>
        /// </remarks>
        public string[] SelectedValues
        {
            get
            {
                string[][] values = new string[this.DataKeyNames.Length][];
                for (int i = 0; i < values.Length; ++i)
                {
                    values[i] = this.SelectedIndexes.Select(p => this.DataKeys[p])
                        .Select(p => string.Format("{0}", p.Values[i]))
                        .ToArray();
                }
                var query = from value in values
                            select string.Join(",", value);
                return query.ToArray();
            }
        }


        /// <summary>
        /// Property to set resequencing specified
        /// </summary>
        private bool _enableNewSequence;

        /// <summary>
        /// Whether the row sequence should restart within each master group.
        /// </summary>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool EnableMasterRowNewSequence
        {
            get
            {
                return _enableNewSequence;
            }
            set
            {
                _enableNewSequence = value;
            }
        }

        /// <summary>
        /// If the rows have already been created from view state, update the status of the row which
        /// has now been selected
        /// </summary>
        /// <param name="e"></param>
        protected override void OnSelectedIndexChanged(EventArgs e)
        {
            foreach (GridViewRow row in this.Rows)
            {
                if (_selectedIndexes != null && _selectedIndexes.Contains(row.RowIndex))
                {
                    row.RowState |= DataControlRowState.Selected;
                }
                else
                {
                    row.RowState &= ~DataControlRowState.Selected;
                }
            }

            base.OnSelectedIndexChanged(e);
        }

        [Browsable(true)]
        [DefaultValue("gvex-table")]
        public override string CssClass
        {
            get
            {
                return base.CssClass;
            }
            set
            {
                base.CssClass = value;
            }
        }

    }
}

using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Oracle.Helpers.XPath;
using EclipseLibrary.Web.JQuery;

namespace EclipseLibrary.Web.UI
{

    /// <summary>
    /// Enhanced version of ASP.NET <c>BoundField</c>
    /// </summary>
    /// <remarks>
    /// <para>Multiple <see cref="DataFields"/> can be specified. <see cref="ToolTipFields"/> and <see cref="ToolTipFormatString"/>
    /// properties support cell level tooltips. You can automatically hide a column if it remains empty
    /// by setting <see cref="HideEmptyColumn"/>.
    /// </para>
    /// <para>
    /// The definition of an empty column is that
    /// all data fields individually evaluate to null or an empty string. In this situation,
    /// the format string is not used and the cell displays the <see cref="NullDisplayText"/>.
    /// </para>
    /// <para>
    /// <see cref="CommonCellText" /> property returns null (not an empty string) if each cell has a different text.
    /// If all cells have the same text, it returns that text. You can use this feature if you intend to
    /// hide columns which have the same text in all rows.
    /// </para>
    /// <para>
    /// <see cref="DataSummaryCalculation"/> property can automatically calculate totals.
    /// <see cref="DataFooterFields" /> and <see cref="DataFooterFormatString" /> can be used to customize the display of totals.
    /// <see cref="SummaryValues"/> can be used to access totals programmatically.
    /// </para>
    /// <para>
    /// When <see cref="EnableRowSpan"/> is true, cells in adjacent rows are spanned if they contain the same text.
    /// </para>
    /// </remarks>
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class MultiBoundField : DataControlField, IHasHeaderToolTip, INeedsSummaries
    {
        /// <summary>
        /// Default template used when in edit or insert mode. Displays a label
        /// </summary>
        private class DefaultTemplate : ITemplate
        {
            private readonly MultiBoundField _mbf;
            public DefaultTemplate(MultiBoundField mbf)
            {
                _mbf = mbf;
            }

            #region ITemplate Members

            public void InstantiateIn(Control container)
            {
                Label lbl = new Label();
                lbl.BorderStyle = BorderStyle.None;
                lbl.BackColor = Color.Transparent;
                lbl.DataBinding += new EventHandler(lbl_DataBinding);
                container.Controls.Add(lbl);
            }

            void lbl_DataBinding(object sender, EventArgs e)
            {
                Label lbl = (Label)sender;
                GridViewRow row = (GridViewRow)lbl.NamingContainer;

                lbl.Text = GetCellText(row.DataItem, _mbf.DataFormatString, _mbf.DataFields);
                _mbf.CheckTextProperties(lbl.Text);
                if (string.IsNullOrEmpty(lbl.Text))
                {
                    lbl.Text = _mbf.NullDisplayText;
                }
                if (_mbf.ToolTipFields != null)
                {
                    lbl.ToolTip = GetCellText(row.DataItem, _mbf.ToolTipFormatString, _mbf.ToolTipFields);
                }
            }

            #endregion
        }

        #region Properties
        /// <summary>
        /// If true, the column will be made invisible if all cells in the
        /// column evaluate to an emty string.
        /// </summary>
        [Browsable(true)]
        [Description("Whether empty columns should be made invisible")]
        [Category("Behavior")]
        [DefaultValue(false)]
        public bool HideEmptyColumn { get; set; }

        /// <summary>
        /// The text to display if all data fields evaluate to empty
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is useful if you want to show a value such as <c>Not Applicable</c>
        /// when the value in the database is null.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string NullDisplayText { get; set; }

        /// <summary>
        /// The value of these fields is displayed using the <see cref="DataFormatString"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Comma seperated list of data fields")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] DataFields
        {
            get;
            set;
        }

        /// <summary>
        /// Used to display the value of <see cref="DataFields"/>
        /// </summary>
        /// <remarks>
        /// <para>
        /// <see cref="ConditionalFormatter"/> is used to format the values which means you can
        /// write format strings like <c>{0::$assigned_flag:Cartons Assigned:Cartons not yet assigned}</c>.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [Description("Format string to use for cell text")]
        [Themeable(false)]
        public string DataFormatString { get; set; }

        /// <summary>
        /// The value of these fields is displayed in the tool tip using
        /// <see cref="ToolTipFormatString"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Comma seperated list of tooltip fields")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] ToolTipFields
        {
            get;
            set;
        }

        /// <summary>
        /// The format string to use to display the tool tip. Each placeholder
        /// in the format string is replaced with the corresponding <see cref="ToolTipFields"/>.
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Format string to use for the tooltip")]
        [Themeable(false)]
        public string ToolTipFormatString { get; set; }

        /// <summary>
        /// The tool tip to display for the header
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Tool tip to display for the header text")]
        [Themeable(false)]
        public string HeaderToolTip { get; set; }

        /// <summary>
        /// If values in adjacent rows are same, then the column would be row spanned
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("If values in adjacent rows are same, then the column would be row spanned")]
        [Themeable(false)]
        [DefaultValue(false)]
        public bool EnableRowSpan { get; set; }

        /// <summary>
        /// The text in the cell which was data bound last
        /// </summary>
        private string m_previousCellText;
        private bool m_bAllCellTextSame;

        /// <summary>
        /// This will return null if different cells have different text.
        /// If all cells have the same text, it returns that text.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property is useful as a space saving mechanism. If all cell texts are
        /// same, you can write code to hide the column and display the text in some header
        /// label.
        /// </para>
        /// </remarks>
        /// <example>
        /// <code>
        /// <![CDATA[
        /// protected void gvEmployeesForperiod_DataBound(object sender, EventArgs e)
        /// {
        ///     MultiBoundField col = gvEmployeesForperiod.Columns.OfType<MultiBoundField>()
        ///         .Where(p => p.AccessibleHeaderText == "Bank").Single();
        ///     if (!string.IsNullOrEmpty(col.CommonCellText)) {
        ///         col.Visible = false;    // Hide the column
        ///         // Show text in some header label
        ///         lblHeader.Text = col.CommonCellText;
        ///     }
        /// }
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(false)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
        public string CommonCellText
        {
            get
            {
                if (m_bAllCellTextSame)
                {
                    return m_previousCellText;
                }
                else
                {
                    return null;
                }
            }
        }

        /// <summary>
        /// The template to use when the row is in edit mode
        /// </summary>
        [Browsable(false)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [DefaultValue(typeof(ITemplate), "")]
        [TemplateContainerAttribute(typeof(IDataItemContainer), BindingDirection.TwoWay)]
        public ITemplate EditItemTemplate
        {
            get;
            set;
        }

        /// <summary>
        /// The template to use when row is in insert mode. If not specified,
        /// then <see cref="EditItemTemplate"/> is used instead.
        /// </summary>
        [Browsable(false)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [DefaultValue(typeof(ITemplate), "")]
        [TemplateContainerAttribute(typeof(IDataItemContainer), BindingDirection.TwoWay)]
        public ITemplate InsertItemTemplate
        {
            get;
            set;
        }
        #endregion

        #region Initialization

        private bool m_bColumnIsEmpty;

        /// <summary>
        /// 
        /// </summary>
        public MultiBoundField()
        {
            this.ToolTipFormatString = "{0}";
            this.DataFormatString = "{0}";
            this.HeaderToolTip = string.Empty;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override DataControlField CreateField()
        {
            return new MultiBoundField();
        }

        /// <summary>
        /// Hook up to the data bound event of the grid
        /// </summary>
        /// <param name="enableSorting"></param>
        /// <param name="control"></param>
        /// <returns></returns>
        public override bool Initialize(bool enableSorting, Control control)
        {
            bool bReturn = base.Initialize(enableSorting, control);
            m_bColumnIsEmpty = true;
            m_bAllCellTextSame = true;

            GridView gv = (GridView)control;

            // Hide empty column
            gv.DataBound += new EventHandler(gv_DataBound);
            return bReturn;
        }

        private void gv_DataBound(object sender, EventArgs e)
        {
            if (this.HideEmptyColumn)
            {
                this.Visible = !m_bColumnIsEmpty;
            }
        }

        /// <summary>
        /// Set up the data binding event handlers for each cell
        /// </summary>
        /// <param name="cell"></param>
        /// <param name="cellType"></param>
        /// <param name="rowState"></param>
        /// <param name="rowIndex"></param>
        public override void InitializeCell(DataControlFieldCell cell, DataControlCellType cellType, DataControlRowState rowState, int rowIndex)
        {
            object obj = cell.Parent;
            switch (cellType)
            {
                case DataControlCellType.Header:
                    // Assign sort icon and tooltip
                    cell.DataBinding += new EventHandler(header_DataBinding);
                    break;

                case DataControlCellType.DataCell:
                    // Display data
                    // Sharad 5 Oct 2010: Fixed bug. Earlier we were not executing this code if this.DataFields were null
                    if ((rowState & DataControlRowState.Edit) == DataControlRowState.Edit)
                    {
                        ITemplate templ = this.EditItemTemplate ?? new DefaultTemplate(this);
                        templ.InstantiateIn(cell);
                    }
                    else if ((rowState & DataControlRowState.Insert) == DataControlRowState.Insert)
                    {
                        CreateInsertControls(cell);
                        //cell.DataBinding += new EventHandler(cellInsert_DataBinding);
                    }
                    else
                    {
                        cell.DataBinding += new EventHandler(cell_DataBinding);
                        cell.PreRender += new EventHandler(cell_PreRender);
                    }
                    break;
            }
            base.InitializeCell(cell, cellType, rowState, rowIndex);
        }

        private void CreateInsertControls(DataControlFieldCell cell)
        {
            //cell.Controls.Clear();
            ITemplate templ;
            if (this.InsertItemTemplate != null)
            {
                templ = this.InsertItemTemplate;
            }
            else if (this.EditItemTemplate != null)
            {
                templ = this.EditItemTemplate;
            }
            else
            {
                templ = new DefaultTemplate(this);
            }
            templ.InstantiateIn(cell);
        }

        #endregion

        #region Helpers
        /// <summary>
        /// Evaluates the data fields and uses the format string to create the string to return
        /// </summary>
        /// <param name="dataItem"></param>
        /// <param name="formatString"></param>
        /// <param name="fields"></param>
        /// <returns></returns>
        public static string GetCellText(object dataItem, string formatString, string[] fields)
        {
            if (fields == null || fields.Length == 0)
            {
                return formatString;
            }

            Dictionary<string, object> values = new Dictionary<string, object>();

            //bool bIsEmpty = true;
            foreach (string field in fields)
            {
                object obj = DataBinder.Eval(dataItem, field);
                values.Add(field, obj);
            }
            try
            {
                ConditionalFormatter formatter = new ConditionalFormatter(p => values[p]);
                return string.Format(formatter, formatString, values.Values.ToArray());
            }
            catch (FormatException ex)
            {
                //Exception diag = new Exception(formatString, ex);
                //throw diag;
                return ex.Message;
            }
            //}
        }
        #endregion

        #region Cell Databinding

        private void header_DataBinding(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridView gv = (GridView)cell.NamingContainer.NamingContainer;

            cell.ToolTip = this.HeaderToolTip;
        }


        private void cell_DataBinding(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;

            if (_extractedValue == null || ((int)_extractedValue.First) != row.RowIndex)
            {
                cell.Text = GetCellText(row.DataItem, this.DataFormatString, this.DataFields);
            }
            else
            {
                // After a row is updated we get here. At this time we may not have the data item available.
                // So we use the value which we remembered during the extraction process.
                cell.Text = (string)_extractedValue.Second;
            }


            if (this.EnableRowSpan && row.RowIndex > 0 && m_previousCellText != null && cell.Text == m_previousCellText)
            {
                // This cell is same as previous one. Update row span of previous visible cell
                GridView gv = (GridView)row.NamingContainer;
                int cellIndex = row.Cells.GetCellIndex(cell);
                GridViewRow previousRow = gv.Rows.Cast<GridViewRow>().Reverse().First(p => p.Cells[cellIndex].Visible);
                TableCell previousCell = previousRow.Cells[cellIndex];
                if (previousCell.RowSpan == 0)
                {
                    previousCell.RowSpan = 2;
                }
                else
                {
                    previousCell.RowSpan += 1;
                }
                cell.Visible = false;
            }

            CheckTextProperties(cell.Text);

            if (string.IsNullOrEmpty(cell.Text))
            {
                cell.Text = this.NullDisplayText;
            }
            if (this.ToolTipFields != null && !string.IsNullOrEmpty(cell.Text))
            {
                cell.ToolTip = GetCellText(row.DataItem, this.ToolTipFormatString, this.ToolTipFields);
            }

        }

        /// <summary>
        /// Empty cells cause rendering problems. We display non breaking space
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cell_PreRender(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            if (string.IsNullOrEmpty(cell.Text))
            {
                cell.Text = "&nbsp;";
            }
        }

        /// <summary>
        /// See whether all column text are same and whether column has now become non empty
        /// </summary>
        /// <param name="text"></param>
        private void CheckTextProperties(string text)
        {
            if (!string.IsNullOrEmpty(text))
            {
                m_bColumnIsEmpty = false;
            }
            if (m_previousCellText == null)
            {
                m_previousCellText = text;
            }
            else if (text != m_previousCellText)
            {
                m_bAllCellTextSame = false;
                // SS 1 Sep 2010: Keep maintaining previous cell text in order to support EnableRowSpan
                m_previousCellText = text;
            }
        }

        #endregion

        #region Overrides
        /// <summary>
        /// Do not call the base class so that the field changed event gets suppressed.
        /// We do not want a requery just because visibility changed.
        /// </summary>
        protected override void OnFieldChanged()
        {
            //base.OnFieldChanged();
        }

        /// <summary>
        /// First is row index, Second is the text value
        /// </summary>
        private Pair _extractedValue;
        /// <summary>
        /// Read the value in the templates and add to dictionary
        /// </summary>
        /// <param name="dictionary"></param>
        /// <param name="cell"></param>
        /// <param name="rowState"></param>
        /// <param name="includeReadOnly"></param>
        public override void ExtractValuesFromCell(IOrderedDictionary dictionary, DataControlFieldCell cell, DataControlRowState rowState, bool includeReadOnly)
        {
            if ((rowState & DataControlRowState.Edit) == DataControlRowState.Edit)
            {
                if (this.EditItemTemplate != null)
                {
                    IBindableTemplate templ = (IBindableTemplate)this.EditItemTemplate;
                    IOrderedDictionary dict = templ.ExtractValues(cell);
                    foreach (var key in dict.Keys)
                    {
                        dictionary.Add(key, dict[key]);
                    }
                }
            }
            else if ((rowState & DataControlRowState.Insert) == DataControlRowState.Insert)
            {
                IBindableTemplate templ = (IBindableTemplate)(this.InsertItemTemplate ?? this.EditItemTemplate);
                if (templ != null)
                {
                    IOrderedDictionary dict = templ.ExtractValues(cell);
                    foreach (var key in dict.Keys)
                    {
                        dictionary.Add(key, dict[key]);
                    }
                }
            }
            else if (cell.HasControls())
            {
                // We will not have controls during deleting
                GridViewRow row = (GridViewRow)cell.NamingContainer;
                Label lbl = (Label)cell.Controls[0];
                _extractedValue = new Pair();
                _extractedValue.First = row.RowIndex;
                _extractedValue.Second = lbl.Text;
            }
            base.ExtractValuesFromCell(dictionary, cell, rowState, includeReadOnly);
        }

        public override void ValidateSupportsCallback()
        {
            //base.ValidateSupportsCallback();
        }
        #endregion


        #region INeedsSummaries Members

        /// <summary>
        /// What type of summary calculation, if any, is needed.
        /// </summary>
        [Browsable(true)]
        public SummaryCalculationType DataSummaryCalculation
        {
            get;
            set;
        }

        private string[] _dataFooterFields;

        /// <summary>
        /// See <see cref="INeedsSummaries.DataFooterFields"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Comma seperated list of data fields to display in footer")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] DataFooterFields
        {
            get
            {
                if (_dataFooterFields == null)
                {
                    return this.DataFields;
                }
                else
                {
                    return _dataFooterFields;
                }
            }
            set
            {
                _dataFooterFields = value;
            }
        }

        private string _footerFormatString;

        /// <summary>
        /// Format string to use for footer text. Defaults to <see cref="DataFormatString"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Format string to use for footer text")]
        [Themeable(false)]
        public string DataFooterFormatString
        {
            get
            {
                if (string.IsNullOrEmpty(_footerFormatString))
                {
                    return this.DataFormatString;
                }
                else
                {
                    return _footerFormatString;
                }
            }
            set
            {
                _footerFormatString = value;
            }
        }

        /// <summary>
        /// Tooltip to display in the footer
        /// </summary>
        public string FooterToolTip
        {
            get;
            set;
        }

        /// <summary>
        /// The summary values which have been computed for display in the footer column
        /// </summary>
        /// <remarks>
        /// These values are saved in view state so they are available to you even if the grid does not
        /// data bind and recreates itself from view state.
        /// </remarks>
        [Browsable(false)]
        public decimal?[] SummaryValues
        {
            get
            {
                if (ViewState["SummaryValues"] == null)
                {
                    return null;
                }
                else
                {
                    return (decimal?[])ViewState["SummaryValues"];
                }
            }
            set
            {
                ViewState["SummaryValues"] = value;
            }

        }

        /// <summary>
        /// How many values were used in computing the summaries. Null values
        /// are not counted. Useful if you are trying to compute the average.
        /// </summary>
        [Browsable(false)]
        public int[] SummaryValuesCount { get; set; }

        #endregion
    }
}

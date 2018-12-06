using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;
using System;

namespace EclipseLibrary.Web.UI.Matrix
{
    public enum MatrixColumnType
    {
        RowTotal,
        CellValue
    }

    [ParseChildren(true)]
    [PersistChildren(false)]
    [Browsable(true)]
    public class MatrixColumn
    {
        public MatrixColumn()
        {
            this.VisibleExpression = string.Empty;
            this.DataCellFormatString = "{0}";
            this.DataHeaderFormatString = "{0}";
            this.ColumnType = MatrixColumnType.CellValue;
        }
        /// <summary>
        /// Unique identifier for this column
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property is not used by <see cref="MatrixField"/> framework. It is provided to help you write code which can
        /// search for specific <see cref="MatrixColumn"/>.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// In this example, we change the Color of  the display column when <c>OUTCOME</c> is <c>RESTOCKED</c>.
        /// <code lang="C#">
        /// <![CDATA[ 
        ///protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
        ///{
        /// switch (e.Row.RowType)
        /// {
        ///   case DataControlRowType.DataRow:
        ///       EclipseLibrary.Web.UI.Matrix.MatrixField mf = gv.Columns.OfType<EclipseLibrary.Web.UI.Matrix.MatrixField>().Single();
        ///       MatrixRow mr = e.Row.Controls.OfType<MatrixRow>().Single();
        ///       MatrixCell mc = mr.MatrixCells.Where(p => DataBinder.Eval(p.DataItem, "OUTCOME", "{0}") == "RESTOCKED" && p.DisplayColumn.MatrixColumn.ID == "units")
        ///           .SingleOrDefault();
        ///       if (mc != null)
        ///       {
        ///           mc.CssClass = "ui-state-highlight";
        ///       }
        ///       break;
        ///   }
        ///  }
        ///  ]]>
        /// </code> 
        /// </para>
        ///     <code lang="XML">
        ///         <![CDATA[
        ///  <m:MatrixField DataMergeFields="operator,shift_start_date,vwh_id" HeaderText="{0::$OUTCOME='CARTON IN SUSPENSE':Number of Suspense:Number of Restock}"
        ///    DataHeaderFields="OUTCOME" DataCellFields="restocked_cartons,restocked_pieces,restocked_units,restocked_non_mp_units, restocked_mp_units"
        ///    GroupByColumnHeaderText="false">
        ///    <MatrixColumns>
        ///        <m:MatrixColumn DataCellFormatString="{2}" DataHeaderFormatString="Units" DisplayColumnTotal="true"
        ///            ColumnType="CellValue" ID="units">
        ///        </m:MatrixColumn>
        ///        <m:MatrixColumn DataCellFormatString="{3}" DataHeaderFormatString="Non MP Units"
        ///            DisplayColumnTotal="true" ColumnType="CellValue">
        ///        </m:MatrixColumn>
        ///    </MatrixColumns>
        ///</m:MatrixField>
        ///         ]]>
        ///     </code>
        /// </example>
        public string ID { get; set; }

        /// <summary>
        /// Whether this is a total column or regular column
        /// </summary>
        [Browsable(true)]
        [DefaultValue(MatrixColumnType.CellValue)]
        public MatrixColumnType ColumnType
        {
            get;
            set;
        }

        /// <summary>
        /// Format of value fields to display in each matrix cell.
        /// </summary>
        /// <remarks>
        /// <para>
        /// If a simple format string is not sufficient for your markup requirements, you can use
        /// <see cref="ItemTemplate"/>. It also serves as the default value for <see cref="ColumnTotalFormatString"/>.
        ///  method uses this format string to format the value to display in
        /// each matrix cell. If an <see cref="ItemTemplate"/> has been specified, this property is not used.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("{0}")]
        public string DataCellFormatString { get; set; }

        /// <summary>
        /// Text to display in the column header
        /// </summary>
        [Browsable(true)]
        [DefaultValue("{0}")]
        public string DataHeaderFormatString { get; set; }

        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public TableItemStyle ItemStyle { get; set; }

        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public TableItemStyle FooterStyle { get; set; }

        /// <summary>
        /// Custom controls to display within the cell.
        /// </summary>
        /// <remarks>
        /// <para>
        /// If a template is specified, <see cref="DataCellFormatString"/> is not used.
        /// </para>
        /// </remarks>
        [
            Browsable(false),
            PersistenceMode(PersistenceMode.InnerProperty),
            DefaultValue(typeof(ITemplate), ""),
            Description("Item template"),
            TemplateContainer(typeof(MatrixCell))
        ]
        public ITemplate ItemTemplate { get; set; }

        ///// <summary>
        ///// Template to be used for cells which have no data. 
        ///// </summary>
        ///// <remarks>
        ///// <para>
        ///// Normally cells which have no data are displayed as empty.
        ///// But you can display the contents in your template here.
        ///// Databinding occurs for the default template during the rendering phase. This means that jquery controls
        ///// will not be able to generate the scripts needed by them. It is best to use only those constrols within the template
        ///// which do not rely on client script.
        ///// </para>
        ///// <para>
        ///// Refer <see cref="ItemTemplate"/> to see the example.
        ///// </para>
        ///// </remarks>
        //[
        //    Browsable(false),
        //    PersistenceMode(PersistenceMode.InnerProperty),
        //    DefaultValue(typeof(ITemplate), "")
        //]
        //public ITemplate DefaultTemplate { get; set; }

        private string _totalFormatString;

        /// <summary>
        /// The format string to use for displaying column totals. Place holders refer to header values.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Defaults to <see cref="DataCellFormatString"/>. Column totals are displayed only if <see cref="DisplayColumnTotal"/> is true.
        /// Placeholders {0}, {1} etc. refer to the fields specified in
        /// <see cref="MatrixField.DataCellFields"/>. Totals are computed only for those fields for which a place holder is
        /// specified. Each value to be summed up must be numeric.
        /// </para>
        /// <para>
        /// If multiple fields have been specified in
        /// <see cref="MatrixField.DataCellFields"/>, and sum of the fields do not evaluate to numeric values, then
        /// you must specify a value for this property. Otherwise an attempt will be made to sum up non numeric fields
        /// as well which will result in run time errors.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string ColumnTotalFormatString
        {
            get
            {
                if (string.IsNullOrWhiteSpace(_totalFormatString))
                {
                    return this.DataCellFormatString;
                }
                return _totalFormatString;
            }
            set
            {
                _totalFormatString = value;
            }
        }

        /// <summary>
        /// To hide on display of particular values, write an XPATH expression to specify the <see cref="VisibleExpression"/>.
        /// </summary>
        /// <remarks>
        /// Invisible columns do not participate in row and column totals.
        /// </remarks>
        /// <example>
        /// <para>
        ///     Follow this example to conditionally hide or display a <see cref="MatrixColumn"/>.
        ///     In the example below, <see cref="MatrixColumn"/> will be invisible if the specified <see cref="MatrixField.DataHeaderFields"/> has a
        ///     value <c>CARTON IN SUSPENSE</c>.
        /// </para>
        ///     <code>
        ///         <![CDATA[
        ///<m:MatrixField DataMergeFields="operator,shift_start_date,vwh_id" HeaderText="{0::$OUTCOME='CARTON IN SUSPENSE':Number of Suspense:Number of Restock}"
        ///         DataHeaderFields="OUTCOME" DataCellFields="restocked_cartons,restocked_pieces,restocked_units,restocked_non_mp_units, restocked_mp_units"
        ///         GroupByColumnHeaderText="false">
        ///         <MatrixColumns>
        ///             <m:MatrixColumn DataCellFormatString="{0}" DataHeaderFormatString="Cartons" DisplayColumnTotal="true"
        ///                 ColumnType="CellValue">
        ///         </m:MatrixColumn>
        ///         <m:MatrixColumn DataCellFormatString="{2}" DataHeaderFormatString="Units" DisplayColumnTotal="true"
        ///             ColumnType="CellValue" ID="units" VisibleExpression="$OUTCOME = 'CARTON IN SUSPENSE'">
        ///         </m:MatrixColumn>
        ///         ]]>
        ///     </code>
        /// </example>
        public string VisibleExpression { get; set; }
        /// <summary>
        /// Whether column totals should be displayed
        /// </summary>
        [Browsable(true)]
        public bool DisplayColumnTotal { get; set; }
    }

}

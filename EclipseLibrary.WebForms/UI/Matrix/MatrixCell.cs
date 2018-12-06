using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;

namespace EclipseLibrary.Web.UI.Matrix
{
    /// <summary>
    /// Multiple matrix cells are rendered within each grid view row. This class represents one of those cells.
    /// </summary>
    public sealed class MatrixCell : TableCell, IDataItemContainer, ICustomTypeDescriptor
    {
        private readonly MatrixDisplayColumn _dc;
        internal MatrixCell(MatrixDisplayColumn dc)
        {
            if (dc == null)
            {
                throw new ArgumentNullException("dc");
            }
            _dc = dc;
            this.Visible = dc.Visible;
        }

        protected override void OnInit(EventArgs e)
        {
            GridViewRow gridRow = (GridViewRow)this.NamingContainer;
            if (gridRow.RowType == DataControlRowType.DataRow && this.DisplayColumn.MatrixColumn.ItemTemplate != null)
            {
                this.DisplayColumn.MatrixColumn.ItemTemplate.InstantiateIn(this);
            }
            base.OnInit(e);
        }

        protected override void OnPreRender(EventArgs e)
        {
            GridViewRow row = (GridViewRow)this.NamingContainer;
            switch (row.RowType)
            {
                case DataControlRowType.DataRow:
                    if (_dc.MatrixColumn.ColumnType == MatrixColumnType.RowTotal)
                    {
                        // First apply grid footer style and then let it get overridden by other styles
                        GridView gv = (GridView)row.NamingContainer;
                        this.ControlStyle.MergeWith(gv.FooterStyle);
                    }
                    if (_dc.MatrixColumn.ItemStyle != null)
                    {
                        this.ControlStyle.MergeWith(_dc.MatrixColumn.ItemStyle);
                    }
                    break;
                case DataControlRowType.Footer:
                    if (_dc.MatrixColumn.FooterStyle != null)
                    {
                        this.ControlStyle.MergeWith(_dc.MatrixColumn.FooterStyle);
                    }
                    break;
                default:
                    throw new NotImplementedException();
            }
            base.OnPreRender(e);
        }

        public MatrixDisplayColumn DisplayColumn
        {
            get
            {
                return _dc;
            }
        }

        private PropertyDescriptorCollection _coll;

        /// <summary>
        /// This array contains the cell values. It is a member variable because we use these values to compute subtotals.
        /// </summary>
        private object[] _values;

        internal object[] CellValues
        {
            get
            {
                return _values;
            }
        }

        public override void DataBind()
        {
            MatrixRow mr = (MatrixRow)this.Parent;
            MatrixField mf = (MatrixField)mr.ContainingField;
            Dictionary<string, object> dict = new Dictionary<string, object>(StringComparer.CurrentCultureIgnoreCase);

            // Grid Row data item fields. Their values will get overwritten with more specific values below
            // By returning these properties, we enable ItemTemplate to Eval row fields as well.
            GridViewRow gridRow = (GridViewRow)this.NamingContainer;
            ICustomTypeDescriptor custom = gridRow.DataItem as ICustomTypeDescriptor;
            if (custom != null)
            {
                // Only add those properties which have not already been added
                foreach (KeyValuePair<string, object> kvp in custom.GetProperties().Cast<PropertyDescriptor>()
                    .Select(p => new KeyValuePair<string, object>(p.Name, p.GetValue(custom))))
                {
                    dict[kvp.Key] = kvp.Value;
                }
            }

            // Header fields
            for (int i = 0; i < mf.DataHeaderFields.Length; ++i)
            {
                dict[mf.DataHeaderFields[i]] = _dc.DataHeaderValues[i];
            }

            // Value fields
            string formatString;
            switch (gridRow.RowType)
            {
                case DataControlRowType.DataRow:
                    switch (_dc.MatrixColumn.ColumnType)
                    {
                        case MatrixColumnType.CellValue:
                            bool b = mf.CurCellValues.TryGetValue(_dc.DataHeaderValueIndex, out _values);
                            if (b)
                            {
                                if (_dc.MatrixColumn.DisplayColumnTotal)
                                {
                                    _dc.UpdateColumnTotals(_values);
                                }
                            }
                            else
                            {
                                _values = new object[mf.DataCellFields.Length];
                            }
                            break;

                        case MatrixColumnType.RowTotal:
                            int[] rowTotalindexes = mf.DataCellFields
                                .Select((p, i) => _dc.MatrixColumn.DataCellFormatString.Contains("{" + i.ToString()) ? i : -1)
                                .Where(p => p >= 0).ToArray();
                            var query = from i in Enumerable.Range(0, mf.DataHeaderValues.Count)
                                        where mf.CurCellValues.ContainsKey(i)
                                        select mf.CurCellValues[i];
                            decimal?[] rowTotals = new decimal?[mf.DataCellFields.Length];
                            foreach (object[] val in query)
                            {
                                foreach (int index in rowTotalindexes)
                                {
                                    if (!Convert.IsDBNull(val[index]))
                                    {
                                        decimal d = Convert.ToDecimal(val[index]);
                                        rowTotals[index] = (rowTotals[index] ?? 0) + d;
                                    }
                                }
                            }
                            _values = rowTotals.Cast<object>().ToArray();
                            if (_dc.MatrixColumn.DisplayColumnTotal)
                            {
                                _dc.UpdateColumnTotals(_values);
                            }
                            break;

                        default:
                            throw new NotImplementedException();
                    }
                    if (_dc.MatrixColumn.ItemTemplate == null)
                    {
                        formatString = this.DisplayColumn.MatrixColumn.DataCellFormatString;
                    }
                    else
                    {
                        formatString = null;
                    }
                    break;

                case DataControlRowType.Footer:
                    _values = _dc.ColumnTotal.Cast<object>().ToArray();
                    formatString = this.DisplayColumn.MatrixColumn.ColumnTotalFormatString;
                    break;

                default:
                    throw new NotImplementedException();
            }

            for (int i = 0; i < mf.DataCellFields.Length; ++i)
            {
                dict[mf.DataCellFields[i]] = _values[i];
            }

            _coll = new PropertyDescriptorCollection(
                dict.Select(p => new KeyValuePropertyDescriptor(p.Key, p.Value)).ToArray()
                );

            if (!string.IsNullOrEmpty(formatString))
            {
                // This means that no template has been specified
                try
                {
                    this.Text = string.Format(formatString, _values);
                }
                catch (FormatException)
                {
                    // Show diagnostic
                    string msg = string.Format("Format string: {0}; Cell Fields: {1}",
                        formatString, string.Join(", ", mf.DataCellFields));
                    throw new FormatException(msg);
                }
            }
            base.DataBind();

            // Save memory. Coll is no longer needed
            // Sharad 15 Jun 2011: _coll cannot be made null because app code might be needing it
            // during the RowDataBound event of the grid.
            //_coll = null;
        }


        #region IDataItemContainer
        public object DataItem
        {
            get { return this; }
        }

        public int DataItemIndex
        {
            get { throw new NotImplementedException(); }
        }

        public int DisplayIndex
        {
            get
            {
                return 0;
            }
        }
        #endregion

        #region ICustomTypeDescriptor

        System.ComponentModel.AttributeCollection ICustomTypeDescriptor.GetAttributes()
        {
            throw new NotImplementedException();
        }

        string ICustomTypeDescriptor.GetClassName()
        {
            throw new NotImplementedException();
        }

        string ICustomTypeDescriptor.GetComponentName()
        {
            throw new NotImplementedException();
        }

        TypeConverter ICustomTypeDescriptor.GetConverter()
        {
            throw new NotImplementedException();
        }

        EventDescriptor ICustomTypeDescriptor.GetDefaultEvent()
        {
            throw new NotImplementedException();
        }

        PropertyDescriptor ICustomTypeDescriptor.GetDefaultProperty()
        {
            throw new NotImplementedException();
        }

        object ICustomTypeDescriptor.GetEditor(Type editorBaseType)
        {
            throw new NotImplementedException();
        }

        EventDescriptorCollection ICustomTypeDescriptor.GetEvents(Attribute[] attributes)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        EventDescriptorCollection ICustomTypeDescriptor.GetEvents()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="attributes"></param>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        PropertyDescriptorCollection ICustomTypeDescriptor.GetProperties(Attribute[] attributes)
        {
            throw new NotImplementedException();
        }

        PropertyDescriptorCollection ICustomTypeDescriptor.GetProperties()
        {
            return _coll;
        }

        object ICustomTypeDescriptor.GetPropertyOwner(PropertyDescriptor pd)
        {
            throw new NotImplementedException();
        }

        #endregion

        /// <summary>
        /// Debugging
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return "Cell for " + _dc;
        }

    }
}

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// A sort expression is a string. It may or may not have {0} embedded in it.
    /// If it does not have a {0} or {0:I}, we append {0} to the end.
    /// Two sort expressions are considered to be equal if their string representation is same after
    /// all {0} and {0:I} have been removed.
    /// </summary>
    /// <remarks>
    /// This is an immutable class just like String. After construction, it cannot be changed.
    /// It encapsulates the SortExpression acceptable for columns of GridViewEx.
    /// </remarks>
    public class SortExpression : IEquatable<SortExpression>, IEquatable<string>
    {
        /// <summary>
        /// Sort expression which is guaranteed to include {0} or {0:I}
        /// </summary>
        private readonly string _expr;

        /// <summary>
        /// Sort expression which is guaranteed to *not* include {0} or {0:I}.
        /// Used for comparisons.
        /// </summary>
        private readonly string _simpleExpr;

        protected SortExpression()
        {
            _expr = string.Empty;
            _simpleExpr = string.Empty;
        }

        /// <summary>
        /// expr would be of the form col1,col2,col3
        /// </summary>
        /// <param name="expr"></param>
        public SortExpression(string expr)
        {
            if (string.IsNullOrEmpty(expr))
            {
                throw new ArgumentNullException("expr", "This is an internal error");
            }
            if (expr.IndexOfAny(new char[] {'$', ';'}) >= 0)
            {
                throw new ArgumentException("Cannot be $", "expr", null);
            }
            if (expr.Contains("{0"))
            {
                _expr = expr;
            }
            else
            {
                _expr = expr + " {0}";
            }
            _simpleExpr = _expr.Replace("{0}", string.Empty).Replace("{0:I}", string.Empty).Trim();
        }

        /// <summary>
        /// Toggles the direction of the sort expression. Replaces {0} with {0:I} and vice versa.
        /// </summary>
        public SortExpression Toggle()
        {
            return new SortExpression(_expr.Replace("{0}", "{0:X}").Replace("{0:I}", "{0}").Replace("{0:X}", "{0:I}"));
        }

        /// <summary>
        /// Descending if any {0:I} is encountered, otherwise ascending.
        /// </summary>
        /// <returns></returns>
        public SortDirection GetSortDirection()
        {
            if (_expr.Contains("{0:I}"))
            {
                // Toggle Direction
                return SortDirection.Descending;
            }
            else
            {
                return SortDirection.Ascending;
            }
        }

        /// <summary>
        /// Provides value comparison semantics rather than the default reference comparison.
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public override bool Equals(object obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Overridden to avoid compiler warning
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            return _expr.GetHashCode();
        }

        /// <summary>
        /// Returns the expression which is guaranteed to contain {0} or {0:I}
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return _expr;
        }

        #region IEquatable<string> Members

        /// <summary>
        /// Converts the passed string to a sort expression and then compares it
        /// </summary>
        /// <param name="other"></param>
        /// <returns></returns>
        public bool Equals(string other)
        {
            // Whether the passed string represents a sort expression equivalent to ours
            if (string.IsNullOrEmpty(other))
            {
                return false;
            }
            return this.Equals(new SortExpression(other));
        }

        #endregion

        #region IEquatable<SortExpression> Members

        public bool Equals(SortExpression other)
        {
            return _simpleExpr.Equals(other._simpleExpr, StringComparison.InvariantCultureIgnoreCase);
        }

        #endregion
    }

    /// <summary>
    /// This is an immutable class. Collection of sort expressions.
    /// </summary>
    public class SortExpressionCollection : IEnumerable<SortExpression>, IEquatable<SortExpressionCollection>
    {
        private readonly List<SortExpression> _list;

        /// <summary>
        /// String representation of the expression, e.g. col1,col2;col3;$;col4
        /// </summary>
        private readonly string _expression;

        /// <summary>
        /// All columns before this index are master sort columns
        /// </summary>
        private readonly int _indexOfFirstSortColumn;

        public SortExpressionCollection()
        {
            _list = new List<SortExpression>();
            _expression = string.Empty;
        }

        /// <summary>
        /// Expects the string to be in the format col1,col2;col3;$;col4
        /// </summary>
        /// <param name="sortExpressions"></param>
        public SortExpressionCollection(string sortExpressions)
        {
            _list = new List<SortExpression>();
            char[] seperator = new char[] { ';' };
            string[] tokens = sortExpressions.Split(seperator, StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < tokens.Length; ++i)
            {
                if (tokens[i] == "$")
                {
                    _indexOfFirstSortColumn = i;
                }
                else
                {
                    _list.Add(new SortExpression(tokens[i]));
                }
            }

            _expression = EvaluateSortExpression();

        }

        /// <summary>
        /// Returns a semicolon seperated string. Each component is guaranteed to contain {0} or {0:I}
        /// </summary>
        /// <returns></returns>
        private string EvaluateSortExpression()
        {
            string _expression;
            if (_indexOfFirstSortColumn == 0)
            {
                _expression = string.Join(";", _list.Select(p => p.ToString()).ToArray());
            }
            else
            {
                StringBuilder sb = new StringBuilder(64);
                for (int i = 0; i < _list.Count; ++i)
                {
                    if (i == _indexOfFirstSortColumn)
                    {
                        sb.Append(";$");
                    }
                    if (i > 0)
                    {
                        sb.Append(";");
                    }
                    sb.Append(_list[i]);
                }
                if (_indexOfFirstSortColumn == _list.Count)
                {
                    // All expressions are master expressions
                    sb.Append(";$");
                }
                _expression = sb.ToString();
            }
            return _expression;
        }

        /// <summary>
        /// Creates a new SortExpressionCollection in which expr is the primary sort column
        /// </summary>
        /// <param name="other"></param>
        /// <param name="expr"></param>
        /// <returns></returns>
        /// <remarks>
        /// Case 1: expr is the first master expression -> It remains the first master expression and its
        /// direction is toggled
        /// Case 2: expr is a master expression but not the first -> It now becomes the first master expression
        /// Case 3: expr is the first sort expression -> It remainst the first sort expression and its direction is toggled
        /// Case 4: expr is a sort expr but not the first -> It now becomes the first sort expression
        /// Case 5: expr is not currently a sort or master expression -> It now becomes the only sort expression
        /// </remarks>
        public SortExpressionCollection(SortExpressionCollection other, SortExpression expr)
        {
            //int nIndex = other.IndexOfFirst(p => p.Equals(expr));
            int nIndex;
            if (other.Any())
            {
                nIndex = other.Select((p, i) => p.Equals(expr) ? i : -1).Max();
            }
            else
            {
                nIndex = -1;
            }
            _list = new List<SortExpression>(other._list);
            _indexOfFirstSortColumn = other._indexOfFirstSortColumn;
            if (nIndex == -1)
            {
                // Case 5: Not a sort or master expression
                _list.RemoveRange(_indexOfFirstSortColumn, _list.Count - _indexOfFirstSortColumn);
                _list.Insert(_indexOfFirstSortColumn, expr);
            }
            else if (nIndex < _indexOfFirstSortColumn)
            {
                // expr is master column
                if (nIndex == 0)
                {
                    // Case 1: First Master column. Toggle direction
                    _list[0] = _list[0].Toggle();
                }
                else
                {
                    // Case 2: Not the first master column. Make it first.
                    SortExpression temp = _list[0];
                    _list[0] = expr;
                    _list[nIndex] = temp;
                }
            }
            else
            {
                // expr is a sort column
                if (nIndex == _indexOfFirstSortColumn)
                {
                    // Case 3: First sort column. Toggle direction
                    _list[nIndex] = _list[nIndex].Toggle();
                }
                else
                {
                    // Case 4: Not the first sort column. Make it first
                    SortExpression temp = _list[_indexOfFirstSortColumn];
                    _list[_indexOfFirstSortColumn] = expr;
                    _list[nIndex] = temp;
                }
            }
            _expression = EvaluateSortExpression();
        }

        /// <summary>
        /// Indexer
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public SortExpression this[int index]
        {
            get
            {
                return _list[index];
            }
        }

        /// <summary>
        /// Utility function to evaluate the sort expression; {0} replaced by ASC. {0:I} replaced by DESC.
        /// Ignores the $ seperator
        /// </summary>
        /// <returns></returns>
        public string GetDataSourceSortExpression()
        {
            List<string> results = new List<string>();
            for (int i = 0; i < _list.Count; ++i)
            {
                //results.Add(string.Format(sfp, _list[i].ToString(), SortDirection.Ascending));
                string str = _list[i].ToString().Replace("{0}", "ASC").Replace("{0:I}", "DESC");
                results.Add(str);
            }
            return string.Join(", ", results.Where(p => !string.IsNullOrEmpty(p)).ToArray());
        }

        /// <summary>
        /// Returns all the master sort expressions
        /// </summary>
        public IEnumerable<SortExpression> MasterSortExpressions
        {
            get
            {
                return _list.Take(_indexOfFirstSortColumn);
            }
        }

        /// <summary>
        /// Returns the count of master expressions
        /// </summary>
        public int CountMasterExpressions
        {
            get
            {
                return _indexOfFirstSortColumn;
            }
        }

        public int Count
        {
            get
            {
                return _list.Count;
            }
        }

        #region IEnumerable<SortExpression> Members

        public IEnumerator<SortExpression> GetEnumerator()
        {
            return _list.GetEnumerator();
        }

        #endregion

        #region IEnumerable Members

        IEnumerator IEnumerable.GetEnumerator()
        {
            return _list.GetEnumerator();
        }

        #endregion

        /// <summary>
        /// Returns all sort expressions semicolon seperated
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return _expression;
        }


        #region IEquatable<SortExpressionCollection> Members

        public bool Equals(SortExpressionCollection other)
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}

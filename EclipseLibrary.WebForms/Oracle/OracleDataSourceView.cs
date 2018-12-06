using System;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Caching;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Oracle.Helpers;
using Oracle.ManagedDataAccess.Client;
//using Oracle.DataAccess.Client;
//using Oracle.DataAccess.Client;

namespace EclipseLibrary.WebForms.Oracle
{

    /// <summary>
    /// Arguments for the <see cref="OracleDataSource.PostSelected"/> event
    /// </summary>
    public class PostSelectedEventArgs : EventArgs
    {
        /// <summary>
        /// The result of the query. You can wrap these results in your own iterator.
        /// </summary>
        public IEnumerable Result { get; set; }
    }

    /// <summary>
    /// This data source provides support for client side paging and sorting.
    /// Can automatically retrieve total row count using a query similar to 
    /// SELECT COUNT(*) FROM (your query).
    /// You main query must begin with SELECT$ instead of SELECT.
    /// </summary>
    /// <remarks>
    /// 16 Oct 2009: Sharad. We can now optionally specify a condition after array parameters.
    /// Client side paging and sorting is provided by transforming your query as follows:
    /// <code>
    /// select *
    /// from (
    /// select /*+ first_rows(25) */
    /// your_columns,
    /// row_number() over (order by sort column) rn
    /// from your_tables )
    /// where rn between :n and :m 
    /// order by rn
    /// </code>
    /// <para>
    /// 4 Jan 2010: Supported DataSourceMode=DataSet
    /// </para>
    /// </remarks>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1063:ImplementIDisposableCorrectly")]
    public partial class OracleDataSourceView : SqlDataSourceView, IDisposable
    {
        #region Initialization
        private readonly OracleDataSource _owner;
        private readonly HttpContext _context;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="owner"></param>
        /// <param name="name"></param>
        /// <param name="context"></param>
        internal OracleDataSourceView(OracleDataSource owner, string name, HttpContext context)
            : base(owner, name, context)
        {
            //m_listQueryLog = new List<string>();
            _owner = owner;
            _context = context;
        }

        /// <summary>
        /// Allows you to access the associated data source control so that you can use it for FindControl() purposes
        /// </summary>
        /// 
        public OracleDataSource Owner
        {
            get
            {
                return _owner;
            }
        }
        #endregion

        #region Connection and Transaction
        private DbConnection Connection
        {
            get
            {
                if (_owner.Datastore.Connection == null)
                {
                    string userName;
                    if (HttpContext.Current == null)
                    {
                        // This happens when background tasks execute query
                        userName = string.Empty;
                    }
                    else
                    {
                        userName = HttpContext.Current.User.Identity.Name;
                    }
                    //_owner._db.CreateConnectionForUser(userName);
                    _owner.Datastore.CreateConnection(_owner.ConnectionString, userName);
                }
                return _owner.Datastore.Connection;
            }
        }

        private enum OpenReason
        {
            Selecting,
            Updating,
            Inserting,
            Deleting
        }

        /// <summary>
        /// Not null if a transaction is in progress
        /// </summary>
        private DbTransaction _transaction;

        /// <summary>
        /// true when user requests transaction before the connection has been opened
        /// </summary>
        private bool _needTransaction;

        private void SetConnection(DbCommand cmd, OpenReason reason)
        {
            DbConnection conn = this.Connection;
            if (conn.State == ConnectionState.Closed)
            {
                try
                {
                    conn.Open();
                }
                catch (OracleDataStoreException ex)
                {
                    //OracleExceptionEx oex = new OracleExceptionEx(string.Empty, ex);
                    if (ex.OracleErrorNumber == 28150)
                    {
                        DbConnectionStringBuilder builder = new DbConnectionStringBuilder();
                        builder.ConnectionString = conn.ConnectionString;
                        string msg = string.Format("User {0} is not authorized to connect on behalf of {1}",
                            builder["Proxy User ID"], builder["User ID"]);
                        throw new Exception(msg, ex);
                    }
                    else
                    {
                        throw;
                    }
                }
            }
            if (string.IsNullOrEmpty(_owner.SysContext.ModuleName))
            {
                if (_owner.Page == null)
                {
                    throw new HttpException("When OracleDataSource is used outside a page, ModuleName must be specified");
                }
                _owner.SysContext.ModuleName = string.IsNullOrEmpty(_owner.Page.Title) ? _context.Request.AppRelativeCurrentExecutionFilePath : _owner.Page.Title;
            }
            if (string.IsNullOrEmpty(_owner.SysContext.Action))
            {
                _owner.SysContext.Action = string.Format("OracleDataSource ID: {0}; {1}", _owner.ID, reason);
            }

            if (this._context != null)
            {
                // _context is null when background thread are firing query such as FireAndForget in ProfileHelperBase
                // We set the user's IP address in client info. The info set by the page developer is being deliberately
                // ignored. The philosophy of this control is that we always want the IP address.
                if (this._context.Request.UserHostName == _context.Request.UserHostAddress)
                {
                    _owner.SysContext.ClientInfo = string.Format("{0}@{1}",
                                   this._context.User.Identity.Name, this._context.Request.UserHostName);
                }
                else
                {
                    _owner.SysContext.ClientInfo = string.Format("{0}:{1}",
                        this._context.Request.UserHostName, _context.Request.UserHostAddress);
                }
            }

            if (_needTransaction)
            {
                _transaction = conn.BeginTransaction();
                _needTransaction = false;
            }
            using (DbCommand cmdContext = conn.CreateCommand())
            {
                cmdContext.Transaction = _transaction;
                _owner.SysContext.SetDatabaseContext(cmdContext, _context, _owner);
            }
            cmd.Connection = conn;
            cmd.Transaction = _transaction;

            // Special handling for ODP.NET. Force bind by name. Default is stupidly bind by position
            if (cmd.GetType().FullName == "Oracle.DataAccess.Client.OracleCommand")
            {
                dynamic odp = cmd;
                odp.BindByName = true;
                odp.InitialLONGFetchSize = 1024;   // Retrieve first 1K chars from a long column
            }
        }

        internal void BeginTransaction()
        {
            if (_transaction != null)
            {
                throw new InvalidOperationException("Will this happen?");
            }
            if (_owner.Datastore.Connection == null || _owner.Datastore.Connection.State == ConnectionState.Closed)
            {
                // Transaction will be created when the connection is created
                _needTransaction = true;
            }
            else
            {
                _transaction = _owner.Datastore.Connection.BeginTransaction();
            }
            if (_owner.Page != null)
            {
                _owner.Page.Error += Page_Error;
            }

        }

        /// <summary>
        /// In case of an error, automatically rollback any transaction which may be in progress
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
// ReSharper disable InconsistentNaming
        private void Page_Error(object sender, EventArgs e)
// ReSharper restore InconsistentNaming
        {
            if (_transaction != null)
            {
                _transaction.Rollback();
                _transaction = null;
            }

        }

        internal void CommitTransaction()
        {
            if (_transaction == null)
            {
                if (!_needTransaction)
                {
                    throw new InvalidOperationException("There is no transaction in progress");
                }
            }
            else
            {
                _transaction.Commit();
                _transaction = null;
                //MaybeClearCustomContext();
            }
        }

        internal void RollBackTransaction()
        {
            if (_transaction == null)
            {
                throw new InvalidOperationException("There is no transaction in progress");
            }
            _transaction.Rollback();
            _transaction = null;
        }

        #endregion

        #region Deleting
        /// <summary>
        /// We do not use oldValues so there is no concurrency check. We merge all the DeleteParameters
        /// specified in the markup. The base class apparently does not do that.
        /// </summary>
        /// <param name="keys"></param>
        /// <param name="oldValues"></param>
        /// <returns></returns>
        protected override int ExecuteDelete(IDictionary keys, IDictionary oldValues)
        {
            int nReturn = -1;

            DbCommand cmd = this.Connection.CreateCommand();
            cmd.Transaction = _transaction;

            CreateParametersFromDictionary(keys, cmd);
            if (!MergeMarkupParameters(cmd, this.DeleteParameters))
            {
                return nReturn;
            }
            //cmd.CommandText = this.DeleteCommand;

            //SetCommandType(cmd, this.DeleteCommandType);
            SqlDataSourceCommandEventArgs cmdEventArgs = new SqlDataSourceCommandEventArgs(cmd);
            OnDeleting(cmdEventArgs);
            try
            {

                if (!cmdEventArgs.Cancel)
                {
                    SetConnection(cmd, OpenReason.Deleting);
                    QueryLogging.TraceOracleCommand(_context.Trace, cmd);
                    // Sharad 20 Sep 2012: This does not seem to be necessary any longer
                    //cmd.CommandText = cmd.CommandText.Replace("\r\n", " ");
                    nReturn = cmd.ExecuteNonQuery();
                    QueryLogging.TraceQueryEnd(this._context.Trace);
                    SqlDataSourceStatusEventArgs statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, nReturn, null);
                    OnDeleted(statusEventArgs);
                    ClearEnumerable();
                }
            }
            catch (DbException ex)
            {
                SqlDataSourceStatusEventArgs statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, 0, ex);
                OnDeleted(statusEventArgs);
                if (!statusEventArgs.ExceptionHandled)
                {
                    throw;
                }
            }
            finally
            {
                cmd.Dispose();
            }
            return nReturn;
        }

        /// <summary>
        /// Raise command parsing event
        /// </summary>
        /// <param name="e"></param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        protected override void OnDeleting(SqlDataSourceCommandEventArgs e)
        {
            e.Command.CommandText = string.IsNullOrWhiteSpace(_owner.DeleteSql) ? this.DeleteCommand : _owner.DeleteSql;
            // Event handlers get the first chance to manipulate command
            base.OnDeleting(e);

            if (e.Cancel || string.IsNullOrWhiteSpace(e.Command.CommandText))
            {
                return;
            }

            if (string.IsNullOrWhiteSpace(_owner.DeleteSql))
            {
                // RaiseCommandParsingEvents is obsolete
//#pragma warning disable 612,618
//                RaiseCommandParsingEvents(e);
//#pragma warning restore 612,618
                throw new HttpException("DeleteSql must be specified");
            }
            else
            {
                XmlToSql.BuildCommand((OracleCommand)e.Command, null, p => false);
            }
            return;           
        }
        #endregion

        #region Selecting

        private const string COL_TOTAL_ROWCOUNT = "TotalRowCount_";

        /// <summary>
        /// PostSelected event is not raised event if the query is cancelled.
        /// </summary>
        internal event EventHandler<PostSelectedEventArgs> PostSelected;

        private IEnumerable _enumerable;
        /// <summary>
        /// This is the record we gobble up while peeking at the row count
        /// </summary>
        private DbDataRecord _record;

        /// <summary>
        /// Perform the query and return results
        /// </summary>
        /// <param name="arguments"></param>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments)
        {
            if (_enumerable != null)
            {
                switch (_owner.DataSourceMode)
                {
                    case SqlDataSourceMode.DataReader:
                        throw new NotSupportedException("Running the same query mutiple times? If your are assigning the same data source " +
                            "to multiple data bound controls, set DataSourceMode=DataSet");

                    case SqlDataSourceMode.DataSet:
                        return _enumerable;

                    default:
                        throw new NotImplementedException();
                }
            }

            // Here _enumerable is definitely null

            IEnumerable data = DoExecuteSelect(arguments);

            if (PostSelected != null)
            {
                PostSelectedEventArgs args = new PostSelectedEventArgs {Result = data};
                PostSelected(this, args);
                return args.Result;
            }
            return data;
        }

        /// <summary />
        /// <param name="arguments"></param>
        /// <returns></returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        private IEnumerable DoExecuteSelect(DataSourceSelectArguments arguments)
        {
            DbCommand cmd = this.Connection.CreateCommand();        // new OracleCommand();
            //int nReturn = -1;

            if (!MergeMarkupParameters(cmd, SelectParameters))
            {
                Trace.TraceWarning("Datasource {0} is cancelling the query because MergeMarkupParameters returned false",
                    _owner.ID);
                return null;
            }
            SqlDataSourceSelectingEventArgs cmdEventArgs = new SqlDataSourceSelectingEventArgs(cmd, arguments);
            OnSelecting(cmdEventArgs);
            if (cmdEventArgs.Cancel)
            {
                //Trace.TraceWarning("Datasource {0} is cancelling the query as requested by Selecting event handler",
                //    m_owner.ID);
                return null;
            }
            if (arguments.MaximumRows > 0)
            {
                if (_owner.DataSourceMode == SqlDataSourceMode.DataSet)
                {
                    throw new NotSupportedException("Paging not supported when DataSourceMode=DataSet");
                }
                cmd.CommandText = ConstructPagingClause(arguments, cmd.CommandText);
            }
            else if (arguments.RetrieveTotalRowCount)
            {
                throw new NotSupportedException("Row count needed but no paging ? Let Sharad know if this happens.");
            }
            else if (!string.IsNullOrEmpty(arguments.SortExpression))
            {
                cmd.CommandText = ConstructSortingClause(arguments, cmd.CommandText);
            }
            if (this.CancelSelectOnNullParameter)
            {
                foreach (DbParameter param in
                    cmd.Parameters.Cast<DbParameter>().Where(param => param.Value == DBNull.Value || param.Value == null))
                {
                    // Do not execute the query
                    Trace.TraceWarning("Datasource {0} is cancelling the query because value of {1} is null",
                                       _owner.ID, param.ParameterName);
                    return null;
                }
            }
            QueryLogging.TraceOracleCommand(_context.Trace, cmd);
            SetConnection(cmd, OpenReason.Selecting);
#if DEBUG
            if (cmd.CommandText.IndexOf("--") >= 0)
            {
                throw new InvalidOperationException("Comments are not allowed within queries");
            }
#endif
            cmd.CommandText = cmd.CommandText.Replace("\r\n", " ");
            SqlDataSourceStatusEventArgs statusEventArgs;
            try
            {
                switch (_owner.DataSourceMode)
                {
                    case SqlDataSourceMode.DataReader:
                        if (_owner.EnableCaching)
                        {
                            throw new NotSupportedException("When EnableCaching is true, DataSourceMode must be DataSet");
                        }
                        _enumerable = cmd.ExecuteReader();
                        break;

                    case SqlDataSourceMode.DataSet:
                        DataTable dt = GetDataTable(cmd);
                        _enumerable = dt.DefaultView;
                        break;

                    default:
                        throw new NotImplementedException();
                }
                statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, -1, null);
            }
            catch (DbException ex)
            {
                statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, 0, ex);
            }
            QueryLogging.TraceQueryEnd(this._context.Trace);
            OnSelected(statusEventArgs);
            if (statusEventArgs.Exception == null)
            {
                if (arguments.RetrieveTotalRowCount)
                {
                    // We should never get here for DataSourceMode=DataSet so _reader is guaranteed to be non null
                    // Get the total count from the first row of the reader
                    DbDataReader reader = (DbDataReader)_enumerable;
                    if (reader.HasRows)
                    {
                        foreach (DbDataRecord record in reader)
                        {
                            _record = record;
                            //m_owner.TotalRowCount =
                                arguments.TotalRowCount = Convert.ToInt32(record[COL_TOTAL_ROWCOUNT]);
                            break;
                        }
                        // Since we have gobbled up one row, use ReaderIterator which is intelligent about this
                        return ReaderIterator;
                    }
                    arguments.TotalRowCount = 0;
                    return _enumerable;
                }
                return _enumerable;
            }
            if (!statusEventArgs.ExceptionHandled)
            {
                //OracleExceptionEx excep = new OracleExceptionEx(cmd.CommandText, statusEventArgs.Exception);
                throw statusEventArgs.Exception;
            }
            return null;
        }

        private DataTable GetDataTable(DbCommand cmd)
        {
            DataTable dt;
            var key = string.Format("{0}_{1}", _owner.UniqueID, cmd.CommandText.GetHashCode());
            if (_owner.EnableCaching && _owner.CacheDuration > 0)
            {
                if (cmd.Parameters.Count > 0)
                {
                    throw new NotImplementedException("Parameters are not currently supported");
                }

                dt = (DataTable)HttpContext.Current.Cache[key];
                if (dt != null)
                {
                    Trace.TraceInformation("OracleDataSource {0} - Avoiding query and returning results from cache", _owner.ID);
                    return dt;
                }
            }
            DbDataAdapter adapter = new OracleDataAdapter();        // _owner._db.Factory.CreateDataAdapter();
// ReSharper disable PossibleNullReferenceException
            adapter.SelectCommand = cmd;
// ReSharper restore PossibleNullReferenceException
            dt = new DataTable();
            adapter.Fill(dt);
            if (_owner.EnableCaching && _owner.CacheDuration > 0)
            {
                DateTime absoluteExpiration = Cache.NoAbsoluteExpiration;
                TimeSpan slidingExpiration = Cache.NoSlidingExpiration;
                switch (_owner.CacheExpirationPolicy)
                {
                    case DataSourceCacheExpiry.Absolute:
                        absoluteExpiration = DateTime.Now + TimeSpan.FromSeconds(_owner.CacheDuration);
                        break;

                    case DataSourceCacheExpiry.Sliding:
                        slidingExpiration = TimeSpan.FromSeconds(_owner.CacheDuration);
                        break;

                    default:
                        throw new NotImplementedException();
                }
                // Cache the result
                HttpContext.Current.Cache.Insert(key, dt, null, absoluteExpiration, slidingExpiration);
            }
            return dt;
        }


        private IEnumerable ReaderIterator
        {
            get
            {
                // First return the gobbled record and then iterate
                yield return _record;
                foreach (object obj in _enumerable)
                {
                    yield return obj;
                }
            }
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        protected override void OnSelecting(SqlDataSourceSelectingEventArgs e)
        {
            e.Command.CommandText = string.IsNullOrWhiteSpace(_owner.SelectSql) ? this.SelectCommand : _owner.SelectSql;

            //SetCommandType(e.Command, this.SelectCommandType);

            // Event handlers get the first chance to manipulate command
            base.OnSelecting(e);

            if (e.Cancel)
            {
                Trace.TraceWarning("Datasource {0} is cancelling query in OnSelecting because event handler set e.Cancel = true",
                    _owner.ID);
                return;
            }

            if (string.IsNullOrWhiteSpace(_owner.SelectSql))
            {
                // RaiseCommandParsingEvents is obsolete
//#pragma warning disable 612,618
//                RaiseCommandParsingEvents(e);
//#pragma warning restore 612,618
                throw new HttpException("SelectSql must be specified");
            }
            else
            {
                //BuildCommandFromXml(e);
                XmlToSql.BuildCommand((OracleCommand)e.Command, null, p => false);
            }

            if (string.IsNullOrWhiteSpace(e.Command.CommandText))
            {
                Trace.TraceWarning("Datasource {0} is cancelling query in OnSelecting because CommandText evaluated to empty",
                    _owner.ID);
                e.Cancel = true;
            }

            return;
        }

        private static string ConstructSortingClause(DataSourceSelectArguments args, string originalCommandText)
        {
            // No paging requested
            if (string.IsNullOrEmpty(args.SortExpression))
            {
                throw new InvalidOperationException("Call not expected");
            }
            string orderByClause = args.SortExpression;
            string commandText = string.Format("{0} ORDER BY {1}", originalCommandText, orderByClause);
            return commandText;
        }

        /// <summary>
        /// matches[0] contains <code>WITH a1 AS (query1), a2 AS (query2) SELECT ...</code>
        /// matches[0].Groups["with"] contains <code>a1 AS (query1), a2 AS (query2)</code>
        /// </summary>
        readonly Regex _regexWith = new Regex(@"\s*WITH\s+(?<with>.+?\))\s*SELECT", RegexOptions.IgnoreCase | RegexOptions.Singleline);

        private string ConstructPagingClause(DataSourceSelectArguments args, string originalCommandText)
        {
            string orderBy = args.SortExpression;


            MatchCollection matches = _regexWith.Matches(originalCommandText);

            // The with clause includes a trailing comma added by us
            string withClause;
            switch (matches.Count)
            {
                case 0:
                    withClause = string.Empty;
                    break;

                case 1:
                    Group g = matches[0].Groups["with"];
                    withClause = g.Value + ", ";
                    originalCommandText = originalCommandText.Remove(matches[0].Index, g.Length + (g.Index - matches[0].Index));
                    break;

                default:
                    throw new ArgumentException("Multiple WITH clauses?", "originalCommandText");
            }


            const string QUERY6 = @"
  WITH {5}
       OriginalQuery AS ({0}),
       PagedQuery AS (SELECT ROW_NUMBER() over(order by {1}) AS row_sequence,
                             COUNT(*) OVER() AS {2},
                             t.*
                        FROM OriginalQuery t
                      )
SELECT *
  FROM PagedQuery
 WHERE row_sequence >= {3}
   AND row_sequence < {4}
 ORDER BY row_sequence
";
            // If order by clause not specified, use 1 as the order by clause which amounts to 
            // undefined sorting
            string commandText = string.Format(QUERY6, originalCommandText,
                string.IsNullOrEmpty(orderBy) ? "1" : orderBy,
                COL_TOTAL_ROWCOUNT,
                args.StartRowIndex + 1, args.StartRowIndex + args.MaximumRows + 1, withClause);
            return commandText;
        }

        #endregion

        #region Command Parsing








        private static readonly Regex _regexParameters = new Regex(@":(?<paramName>\w+)",
            RegexOptions.Singleline | RegexOptions.IgnoreCase | RegexOptions.Compiled);

        /// <summary>
        /// This regular expression is also used by OracleDataSource
        /// </summary>
        internal static Regex ParametersRegEx
        {
            get
            {
                return _regexParameters;
            }
        }


        #endregion

        #region Capabilities

        /// <summary>
        /// Always true
        /// </summary>
        public override bool CanPage
        {
            get
            {
                return !_owner.PagingDisabled;
            }
        }

        /// <summary>
        /// Always true
        /// </summary>
        public override bool CanRetrieveTotalRowCount
        {
            get
            {
                return !_owner.PagingDisabled;
            }
        }

        /// <summary>
        /// Always true
        /// </summary>
        public override bool CanSort
        {
            get
            {
                return true;
            }
        }

        /// <summary>
        /// Raises custom exception
        /// </summary>
        /// <param name="capability"></param>
        protected override void RaiseUnsupportedCapabilityError(DataSourceCapabilities capability)
        {
            string error = string.Empty;
            if ((capability & DataSourceCapabilities.Page) == DataSourceCapabilities.Page ||
                (capability & DataSourceCapabilities.RetrieveTotalRowCount) == DataSourceCapabilities.RetrieveTotalRowCount)
            {
                error += "For database server side paging, use SELECT$. " +
                    "Alternatively, for small number of rows only, set DataSourceMode=DataSet";
            }
            if ((capability & DataSourceCapabilities.Sort) == DataSourceCapabilities.Sort)
            {
                error += " For database server side paging, use SELECT$. " +
                    "Alternatively, for small number of rows only, set DataSourceMode=DataSet";
            }
            if (string.IsNullOrEmpty(error))
            {
                base.RaiseUnsupportedCapabilityError(capability);
            }
            else
            {
                throw new NotSupportedException(error);
            }
            return;

        }
        #endregion

        #region Inserting
        /// <summary>
        /// Execute the insert command
        /// </summary>
        /// <param name="values"></param>
        /// <returns></returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        protected override int ExecuteInsert(IDictionary values)
        {
            //return base.ExecuteInsert(values);
            int nReturn = -1;

            DbCommand cmd = this.Connection.CreateCommand();
            cmd.Transaction = _transaction;
            CreateParametersFromDictionary(values, cmd);
            if (!MergeMarkupParameters(cmd, InsertParameters))
            {
                return nReturn;
            }
            //cmd.CommandText = this.InsertCommand;
            //SetCommandType(cmd, InsertCommandType);

            SqlDataSourceCommandEventArgs cmdEventArgs = new SqlDataSourceCommandEventArgs(cmd);
            OnInserting(cmdEventArgs);
            try
            {
                if (!cmdEventArgs.Cancel)
                {
                    SetConnection(cmd, OpenReason.Inserting);
                    QueryLogging.TraceOracleCommand(_context.Trace, cmd);
                    cmd.CommandText = cmd.CommandText.Replace("\r\n", " ").Trim();
                    nReturn = cmd.ExecuteNonQuery();
                    QueryLogging.TraceQueryEnd(this._context.Trace);
                    SqlDataSourceStatusEventArgs statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, nReturn, null);
                    OnInserted(statusEventArgs);
                    ClearEnumerable();
                }
            }
            catch (DbException ex)
            {
                SqlDataSourceStatusEventArgs statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, 0, ex);
                OnInserted(statusEventArgs);
                if (!statusEventArgs.ExceptionHandled)
                {
                    throw;
                }
            }
            finally
            {
                cmd.Dispose();
            }
            return nReturn;
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        protected override void OnInserting(SqlDataSourceCommandEventArgs e)
        {
            e.Command.CommandText = string.IsNullOrWhiteSpace(_owner.InsertSql) ? this.InsertCommand : _owner.InsertSql;
            // Event handlers get the first chance to manipulate command
            base.OnInserting(e);

            if (e.Cancel || string.IsNullOrWhiteSpace(e.Command.CommandText))
            {
                return;
            }

            if (string.IsNullOrWhiteSpace(_owner.InsertSql))
            {
                // RaiseCommandParsingEvents is obsolete
//#pragma warning disable 612,618
//                RaiseCommandParsingEvents(e);
//#pragma warning restore 612,618
                throw new HttpException("InsertSql must be specified");
            }
            else
            {
                XmlToSql.BuildCommand((OracleCommand)e.Command, null, p => false);
            }
            return;
        }
        #endregion

        #region Updating
        /// <summary>
        /// Do everything manually without calling the base class. Additionally, support 
        /// transactions.
        /// </summary>
        /// <param name="keys"></param>
        /// <param name="values"></param>
        /// <param name="oldValues"></param>
        /// <returns></returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        protected override int ExecuteUpdate(IDictionary keys, IDictionary values, IDictionary oldValues)
        {
            if (this.ConflictDetection == ConflictOptions.CompareAllValues)
            {
                // Do not update if old values are same as new values
// ReSharper disable PossibleNullReferenceException
                bool valuesChanged = values.Keys.Cast<object>().Any(key => !values[key].Equals(oldValues[key]));
// ReSharper restore PossibleNullReferenceException
                if (!valuesChanged)
                {
                    Trace.TraceWarning("OracleDataSource {0}: Updating cancelled because all old and new values are same", _owner.ID);
                    return -1;
                }
            }
            //return base.ExecuteUpdate(keys, values, oldValues);
            int nReturn = -1;

            DbCommand cmd = this.Connection.CreateCommand();
            CreateParametersFromDictionary(keys, cmd);
            CreateParametersFromDictionary(values, cmd);
            if (!MergeMarkupParameters(cmd, UpdateParameters))
            {
                return nReturn;
            }

            // Command text will be set by OnUpdating
            //cmd.CommandText = this.UpdateCommand;
            //SetCommandType(cmd, UpdateCommandType);

            SqlDataSourceCommandEventArgs cmdEventArgs = new SqlDataSourceCommandEventArgs(cmd);
            OnUpdating(cmdEventArgs);
            try
            {
                if (!cmdEventArgs.Cancel)
                {
                    SetConnection(cmd, OpenReason.Updating);
                    QueryLogging.TraceOracleCommand(_context.Trace, cmd);
                    cmd.CommandText = cmd.CommandText.Replace("\r\n", " ");
                    cmd.Transaction = _transaction;
                    nReturn = cmd.ExecuteNonQuery();
                    QueryLogging.TraceQueryEnd(this._context.Trace);
                    ExtractStatusMessages(cmd);
                    SqlDataSourceStatusEventArgs statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, nReturn, null);
                    OnUpdated(statusEventArgs);
                    // After updating, the saved results should not be used
                    ClearEnumerable();
                }
            }
            catch (DbException ex)
            {
                SqlDataSourceStatusEventArgs statusEventArgs = new SqlDataSourceStatusEventArgs(cmd, 0, ex);
                OnUpdated(statusEventArgs);
                if (!statusEventArgs.ExceptionHandled)
                {
                    throw;      // new OracleExceptionEx(cmd.CommandText, ex);
                }
            }
            finally
            {
                cmd.Dispose();
            }
            return nReturn;
        }

        /// <summary>
        /// Status messages begin with /** and end with */
        /// </summary>
        /// <param name="cmd"></param>
        private static void ExtractStatusMessages(DbCommand cmd)
        {
            Regex regex = new Regex(
    @"\/\*\*(?<msg>[^\*\/]*?)\*\/",
    RegexOptions.IgnoreCase | RegexOptions.Singleline | RegexOptions.Compiled);
            MatchCollection matches = regex.Matches(cmd.CommandText);
            for (int i = matches.Count - 1; i >= 0; i--)
            {
                Match m = matches[i];
                string statusMessage = m.Value;
                var paramMatches = _regexParameters.Matches(statusMessage);
                for (int j = paramMatches.Count - 1; j >= 0; --j)
                {
                    var x = paramMatches[j];
                    statusMessage = statusMessage.Remove(x.Index, x.Length);
                    statusMessage = statusMessage.Insert(x.Index, cmd.Parameters[x.Value.Substring(1)].Value.ToString());
                }
            }
        }

        /// <summary>
        /// Raise command parsing event
        /// </summary>
        /// <param name="e"></param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        protected override void OnUpdating(SqlDataSourceCommandEventArgs e)
        {

            e.Command.CommandText = string.IsNullOrWhiteSpace(_owner.UpdateSql) ? this.UpdateCommand : _owner.UpdateSql;
            // Event handlers get the first chance to manipulate command
            base.OnUpdating(e);

            if (e.Cancel || string.IsNullOrWhiteSpace(e.Command.CommandText))
            {
                return;
            }

            if (string.IsNullOrWhiteSpace(_owner.UpdateSql))
            {
                // RaiseCommandParsingEvents is obsolete
//#pragma warning disable 612,618
//                RaiseCommandParsingEvents(e);
//#pragma warning restore 612,618
                throw new HttpException("UpdateSql must be specified");
            }
            else
            {
                XmlToSql.BuildCommand((OracleCommand)e.Command, null, p => false);
            }
            return;
        }

        /// <summary>
        /// Store the values of all out parameters on update
        /// </summary>
        /// <param name="e"></param>
        protected override void OnUpdated(SqlDataSourceStatusEventArgs e)
        {
            SetOutValues(e);
            base.OnUpdated(e);
        }

        /// <summary>
        /// Store the values of all out parameters on insert
        /// </summary>
        /// <param name="e"></param>
        protected override void OnInserted(SqlDataSourceStatusEventArgs e)
        {
            SetOutValues(e);
            base.OnInserted(e);
        }

        /// <summary>
        /// Store the values of all out parameters on delete
        /// </summary>
        /// <param name="e"></param>
        protected override void OnDeleted(SqlDataSourceStatusEventArgs e)
        {
            SetOutValues(e);
            base.OnDeleted(e);
        }

        private void SetOutValues(SqlDataSourceStatusEventArgs e)
        {
            if (e.Exception == null)
            {
                _owner.ClearOutValues();
                foreach (DbParameter param in e.Command.Parameters)
                {
                    if (param.Direction == ParameterDirection.InputOutput ||
                        param.Direction == ParameterDirection.Output || param.Direction == ParameterDirection.ReturnValue)
                    {
                        _owner.OutValues.Add(param.ParameterName, param.Value);
                    }
                }
            }
        }

        #endregion

        #region Helpers
        private static void CreateParametersFromDictionary(IDictionary keys, DbCommand cmd)
        {
            if (keys != null)
            {
                DbParameter oparam;
                foreach (DictionaryEntry item in keys)
                {
                    oparam = cmd.CreateParameter();
                    oparam.Value = item.Value ?? DBNull.Value;
                    oparam.ParameterName = item.Key.ToString();
                    cmd.Parameters.Add(oparam);
                }
            }
            return;
        }

        /// <summary>
        /// Returns false if markup control parameter has an invalid value.
        /// It is expected that some validator will let the user know what the problem is.
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="markupParameters"></param>
        /// <returns></returns>
        private bool MergeMarkupParameters(DbCommand cmd, ParameterCollection markupParameters)
        {
            DbParameter cmdParameter;
            IOrderedDictionary markupParameterValues;
            // For Array parameter, Type is always string. DbType is the real type
            var specialMarkupParams = (from Parameter p in markupParameters
                                       where p.Type != TypeCode.Empty && p.DbType != DbType.Object
                                       select new { MarkupParameter = p, RealDbType = p.DbType }).ToList();
            specialMarkupParams.ForEach(p => p.MarkupParameter.DbType = DbType.Object);
            try
            {
                markupParameterValues = markupParameters.GetValues(_context, _owner);
            }
            catch (FormatException ex)
            {
                throw new InvalidOperationException("Let Sharad know if this happens", ex);
            }
            foreach (DictionaryEntry markupParameterValue in markupParameterValues)
            {
                Parameter markupParameter = markupParameters[markupParameterValue.Key.ToString()];
                int nIndex = cmd.Parameters.IndexOf(markupParameterValue.Key.ToString());
                if (nIndex >= 0)
                {
                    cmdParameter = cmd.Parameters[nIndex];
                    // We must convert empty strings to null here so that our future command parsing will work properly
                    if (markupParameter.ConvertEmptyStringToNull && cmdParameter.Value != null && (cmdParameter.Value is string))
                    {
                        string str = (string)cmdParameter.Value;
                        if (string.IsNullOrEmpty(str))
                        {
                            cmdParameter.Value = null;
                        }
                    }
                }
                else
                {
                    // Add it now
                    cmdParameter = cmd.CreateParameter();
                    cmdParameter.Value = markupParameterValue.Value;
                    cmdParameter.ParameterName = markupParameterValue.Key.ToString();
                    cmd.Parameters.Add(cmdParameter);
                }
                var special = specialMarkupParams.FirstOrDefault(p => p.MarkupParameter.Name == markupParameter.Name);
                if (special != null)
                {
                    // This must be an array parameter. Use the real DbType
                    cmdParameter.DbType = special.RealDbType;
                }
                else if (markupParameter.Type == TypeCode.Empty)
                {
                    cmdParameter.DbType = markupParameter.DbType;
                }
                else
                {
                    cmdParameter.DbType = Parameter.ConvertTypeCodeToDbType(markupParameter.Type);
                }
                cmdParameter.Direction = markupParameter.Direction;
                cmdParameter.Size = markupParameter.Size;
            }
            return true;
        }
        #endregion

        #region IDisposable Members

        /// <summary>
        /// Dispose off connection and reader
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1065:DoNotRaiseExceptionsInUnexpectedLocations"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1063:ImplementIDisposableCorrectly")]
        public void Dispose()
        {
            if (_transaction != null)
            {
                throw new InvalidOperationException("You must commit or roll back the transaction you started");
            }
            ClearEnumerable();

            //if (_conn != null)
            //{
            //    _conn.Dispose();
            //}
        }

        /// <summary>
        /// Gets rid of the saved enumerable
        /// </summary>
        private void ClearEnumerable()
        {
            // Dispose off only if caching is not enabled.
            if (_enumerable != null && (!_owner.EnableCaching || _owner.CacheDuration == 0))
            {
                IDisposable dis = _enumerable as IDisposable;
                if (dis != null)
                {
                    dis.Dispose();
                }
                _enumerable = null;
            }
        }

        #endregion

        /// <summary>
        /// Whenever the query or something else changes, discard existing results. This prevents the
        /// error which stops people from executing query twice.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnDataSourceViewChanged(EventArgs e)
        {
            ClearEnumerable();
            base.OnDataSourceViewChanged(e);
        }
    }
}

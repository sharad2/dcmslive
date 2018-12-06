using System;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Oracle.Helpers;

namespace EclipseLibrary.WebForms.Oracle
{
    /// <summary>
    /// Sets module code and other information accepted by <c>DBMS_APPLICATION_INFO</c> package.
    /// </summary>
    /// <remarks>
    /// <para>
    /// If ODP.NEt is being used, the client info and action are set in an optimized way using the properties of the
    /// OracleConnection object. Reflection is used to avoid a dependency on ODP.NET classes.
    /// </para>
    /// </remarks>
    [ParseChildren(true)]
    [PersistChildren(false)]
    [TypeConverter(typeof(ExpandableObjectConverter))]
    public class OracleSysContext
    {
        /// <summary>
        /// By default in SysContext, Enable is true
        /// </summary>
        public OracleSysContext()
        {
            this.ProcedureFormatString = "set_{0}(A{0} => :{0}, client_id => :client_id)";
            this.EnableSysContext = true;
        }

        private string _clientInfo;
        /// <summary>
        /// Set via DBMS_APPLICATION_INFO. The value set in the markup is ignored by <see cref="OracleDataSource"/>
        /// </summary>
        /// <remarks>
        /// Max 64 characters
        /// </remarks>
        [Browsable(false)]
        [DefaultValue("")]
        public string ClientInfo
        {
            get
            {
                return _clientInfo;
            }
            set
            {
                if (_clientInfo != value)
                {
                    _clientInfo = value.Substring(0, Math.Min(value.Length, 64));
                    _parametersChanged = true;
                }
            }
        }


        /// <summary>
        /// The property to enable/disable SysContext
        /// </summary>
        /// <remarks>
        /// SysContext is not set in case of Oracle 9i
        /// </remarks>
        /// <example>
        /// <![CDATA[
        ///   if (!string.IsNullOrEmpty(ConfigurationManager.AppSettings["tweaks"]))
        ///       {
        ///          dsPickSlip.SysContext.Enable = false;
        ///       }
        /// ]]>
        /// </example>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool EnableSysContext { get; set; }


        private string _moduleName;

        /// <summary>
        /// Set via DBMS_APPLICATION_INFO. Max 48 characters
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string ModuleName
        {
            get
            {
                return _moduleName;
            }
            set
            {
                if (_moduleName != value)
                {
                    _moduleName = value.Substring(0, Math.Min(value.Length, 48));
                    _parametersChanged = true;
                }
            }
        }

        private string _action;
        /// <summary>
        /// Set via DBMS_APPLICATION_INFO. Max limit 32 characters. Rest truncated
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string Action
        {
            get
            {
                return _action;
            }
            set
            {
                if (_action != value)
                {
                    _action = value.Substring(0, Math.Min(value.Length, 32));
                    _parametersChanged = true;
                }
            }
        }

        /// <summary>
        /// The package which provides the functions to manipulate a custom context
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        public string ContextPackageName { get; set; }

        /// <summary>
        /// The name of the procedure which can set a custom context value
        /// e.g. set_{0}(A{0} => :{0});
        /// {0} represents the name of the parameter which is being set.
        /// </summary>
        /// <remarks>
        /// If you have a ContextParameter named pickslip_id, its value will be set using the call
        /// CustomContextPackage.set_pickslip_id(Apickslip_id => :pickslip_id);
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("set_{0}(A{0} => :{0}, client_id => :client_id);")]
        public string ProcedureFormatString { get; set; }

        private ParameterCollection _contextParameters;

        /// <summary>
        /// Custom values to be set in the custom Oracle10g context.
        /// </summary>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public ParameterCollection ContextParameters
        {
            get
            {
                if (_contextParameters == null)
                {
                    _contextParameters = new ParameterCollection();
                    _contextParameters.ParametersChanged += new EventHandler(contextParameters_ParametersChanged);
                }
                return _contextParameters;
            }
        }

        /// <summary>
        /// When true, it means that values have not been set in database yet
        /// </summary>
        private bool _parametersChanged;

        void contextParameters_ParametersChanged(object sender, EventArgs e)
        {
            _parametersChanged = true;
        }

        private Guid _uniqueId;

        /// <summary>
        /// OK to call this multiple times if you wish to change some of the values. The unique id will be set
        /// only once. If no parameters have changed since the last call, it does nothing
        /// </summary>
        /// <remarks>
        /// In the unlikely case of you using the same context for multiple connections, the _parametersChanged check will be
        /// a bug for you. This is because after you set the context on one connection, we will not set it on the next
        /// connection because we will think that we have already set it.
        /// </remarks>
        /// <param name="cmd"></param>
        /// <param name="context"></param>
        /// <param name="ctl"></param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public void SetDatabaseContext(DbCommand cmd, HttpContext context, Control ctl)
        {
            if (!_parametersChanged)
            {
                // 1) Do nothing if the parameters have not changed because we have already set the context.
                // 2) If Enable property is false then too do nothing
                return;
            }
            StringBuilder sb = new StringBuilder();
            sb.Append("BEGIN ");
            bool bCode = PrepareApplicationContext(cmd, sb);

            if (this.ContextParameters != null && this._contextParameters.Count > 0 && this.EnableSysContext)
            {
                if (string.IsNullOrEmpty(this.ContextPackageName))
                {
                    throw new HttpException("If ContextParameters are supplied, CustomContextPackage must be specified as well");
                }
                //OracleParameter param;
                if (_uniqueId == Guid.Empty)
                {
                    _uniqueId = Guid.NewGuid();
                    sb.Append("DBMS_SESSION.SET_IDENTIFIER(client_id => :client_id); ");
                    bCode = true;
                }
                DbParameter param = cmd.CreateParameter();
                param.ParameterName = "client_id";
                param.Value = _uniqueId.ToString();
                param.DbType = DbType.String;
                cmd.Parameters.Add(param);
                IOrderedDictionary values = this.ContextParameters.GetValues(context, ctl);
                foreach (Parameter parameter in this.ContextParameters)
                {
                    // ConvertEmptyStringToNull true implies that null value will be set. false implies that null value will
                    // not be set.
                    string strValue = string.Format("{0}", values[parameter.Name]);
                    if (!string.IsNullOrEmpty(strValue) || parameter.ConvertEmptyStringToNull)
                    {
                        sb.Append(this.ContextPackageName);
                        sb.Append(".");
                        sb.AppendFormat(this.ProcedureFormatString, parameter.Name);
                        sb.Append("; ");
                        param = cmd.CreateParameter();
                        param.ParameterName = parameter.Name;
                        param.Value = string.IsNullOrEmpty(strValue) ? DBNull.Value : (object)strValue;
                        param.DbType = parameter.GetDatabaseType();
                        cmd.Parameters.Add(param);
                        bCode = true;
                    }
                }
                _parametersChanged = false;
            }

            if (bCode)
            {
                sb.Append("END;");
                cmd.CommandText = sb.ToString();
                cmd.CommandType = CommandType.Text;
                QueryLogging.TraceOracleCommand(context.Trace, cmd);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Provides optimized handling for ODP.NET connection.
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="sb"></param>
        /// <returns>true if something was added to passed sb</returns>
        private bool PrepareApplicationContext(DbCommand cmd, StringBuilder sb)
        {
            //Type connType = cmd.Connection.GetType();
            if (cmd.Connection.GetType().FullName == "Oracle.DataAccess.Client.OracleConnection")
            {
                // ODP.NET specific code
                dynamic odp = cmd.Connection;
                odp.ClientInfo = this.ClientInfo;
                odp.ActionName = this.Action;
                odp.ModuleName = this.ModuleName;
                //var prop = connType.GetProperty("ClientInfo");
                //prop.SetValue(cmd.Connection, this.ClientInfo, null);
                //prop = connType.GetProperty("ActionName");
                //// Max allowable length for action is 32
                //prop.SetValue(cmd.Connection, this.Action, null);
                //prop = connType.GetProperty("ModuleName");
                //prop.SetValue(cmd.Connection, this.ModuleName, null);
                return false;
            }
            else
            {
                // Do it the long generic way
                sb.Append("DBMS_APPLICATION_INFO.SET_MODULE(module_name => :module_name, action_name => :action_name); ");

                DbParameter param = cmd.CreateParameter();
                param.ParameterName = "module_name";
                param.Value = this.ModuleName;
                param.DbType = DbType.String;
                cmd.Parameters.Add(param);

                param = cmd.CreateParameter();
                param.ParameterName = "action_name";
                param.Value = this.Action;
                param.DbType = DbType.String;
                cmd.Parameters.Add(param);

                if (!string.IsNullOrEmpty(this.ClientInfo))
                {
                    sb.Append("DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => :client_info); ");
                    param = cmd.CreateParameter();
                    param.ParameterName = "client_info";
                    param.Value = this.ClientInfo;
                    param.DbType = DbType.String;
                    cmd.Parameters.Add(param);
                }

                return true;
            }

        }

    }
}

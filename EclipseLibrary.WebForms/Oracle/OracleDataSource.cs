using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Configuration;
using System.Data.Common;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Oracle;

namespace EclipseLibrary.WebForms.Oracle
{
    ///// <summary>
    ///// Represents a query which can be set as the command text for <see cref="OracleDataSource"/>.
    ///// </summary>
    //[TypeConverter(typeof(ExpandableObjectConverter))]
    //[ParseChildren(true, "Query")]
    //[PersistChildren(false)]
    //[Obsolete("Use SelectSql Property")]
    //public class CommandText
    //{
    //    /// <summary>
    //    /// 
    //    /// </summary>
    //    public CommandText()
    //    {
    //        this.Query = string.Empty;
    //    }

    //    /// <summary>
    //    /// A unique ID which can be used to select the command text.
    //    /// </summary>
    //    [Browsable(true)]
    //    [PersistenceMode(PersistenceMode.Attribute)]
    //    public string ID { get; set; }

    //    /// <summary>
    //    /// The text of the query.
    //    /// </summary>
    //    [Browsable(true)]
    //    [PersistenceMode(PersistenceMode.InnerDefaultProperty)]
    //    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    //    [DefaultValue(typeof(string), "")]
    //    public string Query { get; set; }
    //}

    ///// <summary>
    ///// Collection of <see cref="CommandText"/> returned by <see cref="OracleDataSource.CommandTexts"/>.
    ///// </summary>
    //[Obsolete]
    //public class CommandTextCollection : Collection<CommandText>
    //{
    //    /// <summary>
    //    /// Returns the query text corresponding to the passed id.
    //    /// </summary>
    //    /// <param name="id"></param>
    //    /// <returns></returns>
    //    public string this[string id]
    //    {
    //        get
    //        {
    //            foreach (CommandText ct in this)
    //            {
    //                if (ct.ID == id)
    //                {
    //                    return ct.Query;
    //                }
    //            }
    //            throw new ArgumentOutOfRangeException("id");
    //        }
    //    }
    //}

    /// <summary>
    /// The only purpose of this class is to log each query executed.
    /// SS 30 Oct 2008: It now provides client side sorting and paging support. See SqlDataSourceViewEx class
    /// for more info.
    /// </summary>
    /// <remarks>
    /// <para>
    /// By default, <see cref="Control.EnableViewState"/> is set to false. It needs to be set to true only if the associated control
    /// has its EnableViewState property set to true. When view state of the databound control is not enabled, 
    /// it will data bind on each postback. When its view state is enabled, it will data bind only if the data source
    /// parameters change. To enable datasource view state tracking, it is necessary to turn on EnableViewState of the
    /// data source.
    /// </para>
    /// <para>
    /// Sharad 13 Oct 2010: If you set <see cref="SqlDataSource.ConflictDetection"/> to <c>CompareAllValues</c>, then Update will be bypassed if all
    /// old and new values are same.
    /// </para>
    /// <para>
    /// Sharad 14 Oct 2010: Properties <see cref="SqlDataSource.EnableCaching"/>, <see cref="SqlDataSource.CacheDuration"/> and
    /// <see cref="SqlDataSource.CacheExpirationPolicy"/> are now supported. They work as documented in MSDN. A significant
    /// limitation is that the query cannot have any parameters since we have not implemented the capability to cache different
    /// results for different parameters. Thus caching is useful only for queries which summarize a large amount of data such as the queries
    /// you might execute on a typical home page.
    /// </para>
    /// <para>
    /// Sharad 30 Nov 2010: New property <see cref="SelectSql"/> available which provides XML based SQL filtering
    /// </para>
    /// </remarks>
    [ToolboxData(@"
    <{0}:OracleDataSource runat=""server"" ConnectionString=""<%$ ConnectionStrings:dcms4 %>""
        ProviderName=""<%$ ConnectionStrings:dcms4.ProviderName %>"">
    </{0}:OracleDataSource>
")]
    [Themeable(true)]
    public class OracleDataSource : SqlDataSource
    {
        /// <summary>
        /// 
        /// </summary>
        public OracleDataSource()
        {
            this.DataSourceMode = SqlDataSourceMode.DataReader;
            this.CancelSelectOnNullParameter = false;
            this.EnableViewState = false;
        }

        ///// <summary>
        ///// 
        ///// </summary>
        ///// <param name="connectionString"></param>
        ///// <param name="selectCommand"></param>
        //[Obsolete("Use the parameterless constructor and specify SelectSql after construction")]
        //public OracleDataSource(string connectionString, string selectCommand)
        //{
        //    this.ConnectionString = connectionString;
        //    this.SelectCommand = selectCommand;
        //    this.DataSourceMode = SqlDataSourceMode.DataReader;
        //    this.CancelSelectOnNullParameter = false;
        //    this.EnableViewState = false;
        //}

        /// <summary>
        /// Useful if you are reading the connection string from web.config. Both <c>ProviderName</c> and <c>ConnectionString</c> are used
        /// </summary>
        /// <param name="connection"></param>
        public OracleDataSource(ConnectionStringSettings connection)
        {
            this.DataSourceMode = SqlDataSourceMode.DataReader;
            this.CancelSelectOnNullParameter = false;
            this.EnableViewState = false;
            this.ProviderName = connection.ProviderName;
            this.ConnectionString = connection.ConnectionString;
        }

        private OracleSysContext _sysContext = new OracleSysContext();

        /// <summary>
        /// The context information for the query to be executed.
        /// </summary>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public OracleSysContext SysContext
        {
            get
            {
                return _sysContext;
            }
        }

        private Dictionary<string, object> _outValues;

        /// <summary>
        /// Values of all out parameters from the last database operation.
        /// </summary>
        [Browsable(false)]
        public IDictionary<string, object> OutValues
        {
            get
            {
                if (_outValues == null)
                {
                    _outValues = new Dictionary<string, object>();
                }
                return _outValues;
            }
        }

        /// <summary>
        /// This is more efficient than using OutValues.Clear() since you avoid creating an unnecessary
        /// _outValues dictionary
        /// </summary>
        internal void ClearOutValues()
        {
            _outValues = null;
        }

        /// <summary>
        /// Total count of all the rows. This is available only in paging scenarios where you are not displaying
        /// all the rows. This row count tells you how many rows you would have displayed if there was no paging.
        /// It is saved in view state and is available after the select operation.
        /// The value is set by the view when total count is retrieved
        /// </summary>
        [Browsable(false)]
        [Obsolete("Not supported. Is anyone using this?")]
        public int TotalRowCount
        {
            get
            {
                object obj = ViewState["TotalRowCount"];
                if (obj == null)
                {
                    return 0;
                }
                else
                {
                    return (int)obj;
                }
            }
            internal set
            {
                ViewState["TotalRowCount"] = value;
            }
        }



        /// <summary>
        /// We must claim to be visible, otherwise we will not get a chance to render the query
        /// </summary>
        [Browsable(false)]
        [ReadOnly(true)]
        public override bool Visible
        {
            get
            {
                return true;    // base.Visible;
            }
            set
            {
                // Ignore
                //base.Visible = value;
            }
        }

        /// <summary>
        /// Whether paging should be enabled
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property was invented because asp ListView always asks for TotalRowCount, whether or not paging is
        /// requested. Set this to true to inform ListView that we do not support paging. When this is true,
        /// <see cref="OracleDataSourceView.CanPage"/> and <see cref="OracleDataSourceView.CanRetrieveTotalRowCount"/> return false;
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool PagingDisabled { get; set; }

        private string _selectSql = string.Empty;

        /// <summary>
        /// Select Sql possibly decorated with filtering XML
        /// </summary>
        /// <remarks>
        /// <para>
        /// The Sql can be interspersed with conditions which can be automatically evaluated to slice and dice the SQL text as
        /// shown in the example below. You wrap the conditional text within <![CDATA[<if></if>]]> XML tags. This communicates to the
        /// parser that the conditional text should be used only if all parameters referenced within the text have non null values.
        /// As an example, <![CDATA[<if>AND msku.sku_id = :sku_id</if>]]> states that the text <c>AND msku.sku_id = :sku_id</c> should
        /// be used only if the parameter <c>:sku_id</c> has a non null value.
        /// </para>
        /// <para>
        /// <c>else</c> tag is also supported. It must immediately follow the <c>if</c> tag. If the <c>if</c> condition
        /// is not satisfied, the <c>else</c> tag is used.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        /// ...
        ///<if c=":tweaks">
        ///  src.source_order_prefix      AS source_order_prefix,
        ///  src.source_order_id          AS source_order_id,
        ///  src.source_order_line_number AS source_order_line_number,
        ///</if>
        ///<else>
        ///  NULL      AS source_order_prefix,
        ///  NULL          AS source_order_id,
        ///  NULL AS source_order_line_number,
        ///</else>
        /// ]]>
        /// ...
        /// </code>
        /// <para>
        /// You can also specify the condition to evaluate explicitly by providing it as the value of the
        /// <c>c</c> attribute of the <c>if</c> element. <![CDATA[<if c="choice = '1'">ia_id IS NULL<if>]]> states that
        /// the clause <c>ia_id IS NULL</c> will be used only if the condition <c>choice = '1'</c> evaluates to true.
        /// </para>
        /// <para>
        /// Array parameters are also supported using the syntax
        /// <![CDATA[<a [pre=''] [sep=','] [post='']>sql clause containing :param placeholder</a>]]>.
        /// If the value of <c>:param</c> is null, no sql is generated. 
        /// Otherwise the value is treated as a comma seperated list of multiple values. The Sql generated
        /// can be visualized as :
        /// </para>
        /// <list type="number">
        /// <item>
        /// <description>Append the value of the <c>pre</c> attribute to the resulting SQL.</description>
        /// </item>
        /// <item>
        /// <description>
        /// For each value of the parameter, append clause to the resulting SQL seperated by the value of <c>sep</c>.
        /// The parameter :param within the clause is replaced by :parami for the i'th value. A parameter called <c>parami</c>
        /// is also added to the <c>DbCommand</c> and its value is 
        /// </description>
        /// </item>
        /// <item>
        /// <description>Append the value of the <c>post</c> attribute.</description>
        /// </item>
        /// </list>
        /// <para>
        /// The above sounds complicated but it is not. Assuming that the parameter <c>ia_id</c> has the value
        /// <c>FPK,BIR,RST</c>, then the statement <![CDATA[<a var='ia_id' pre='(' post=')' sep=' OR '>ia_id = {0}</a>]]>
        /// results in the text <c>(ia_id = :ia_id1 OR ia_id = :ia_id2 OR ia_id = :ia_id3)</c>.
        /// </para>
        /// 
        /// </remarks>
        /// <example>
        /// <para>
        /// This example demonstrates several of the XML filtering features available. <![CDATA[<if c="choice = '1'">]]>
        /// specifies an explicit condition which is used to decide whether the first query should be used at all. Within the first query,
        /// <![CDATA[<if>AND msku.sku_id = :sku_id</if>]]> says that the the clause <c>AND msku.sku_id = :sku_id</c> should be used
        /// only if the parameter <c>sku_id</c> has a non null value. This is a shorthand way of writing the equivalent condition'
        /// <![CDATA[<if c=':sku_id'>AND msku.sku_id = :sku_id</if>]]>.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<o:OracleDataSource runat="server" ID="dsSkuArea" ConnectionString="<%$ ConnectionStrings:dcms8 %>"
        ///    ProviderName="<%$ ConnectionStrings:dcms8.ProviderName %>">
        ///    <SelectSql>
        ///<if c="choice = '1'">
        ///select ...
        ///FROM boxdet bd
        ///INNER JOIN master_sku msku ON msku.upc_code = bd.upc_code
        ///INNER JOIN box b
        ///ON b.ucc128_id = bd.ucc128_id
        ///AND b.pickslip_id = bd.pickslip_id
        ///left outer join ia ia
        ///on ia.ia_id = b.ia_id
        ///WHERE bd.stop_process_date is null
        ///and b.stop_process_date is null
        ///AND bd.current_pieces &gt; 0
        ///and b.ia_id is not null
        ///<if>AND msku.sku_id = :sku_id</if>
        ///<if>AND msku.style = :style</if>
        ///<if>AND msku.color = :color</if>
        ///<if>AND msku.dimension = :dimension</if>
        ///<if>AND msku.sku_size = :sku_size</if>
        ///<if>AND b.vwh_id = :vwh_id</if>
        ///<a pre='AND b.ia_id IN (' sep=,' post=')'>:ia_id</a>
        ///GROUP BY b.ia_id, b.vwh_id, msku.sku_id
        ///</if>
        ///<if c="choice = '2'">
        ///SELECT ...
        ///</if>
        ///    </SelectSql>
        ///    <SelectParameters>
        ///        <asp:ControlParameter ControlID="tbSku" Name="sku_id" Type="String" PropertyName="Value" />
        ///        <asp:ControlParameter ControlID="tbStyle" Name="style" Type="String" />
        ///        <asp:ControlParameter ControlID="tbColor" Name="color" Type="String" />
        ///        <asp:ControlParameter ControlID="tbDimension" Name="dimension" Type="String" />
        ///        <asp:ControlParameter ControlID="tbSize" Name="sku_size" Type="String" />
        ///        <asp:ControlParameter ControlID="ddlVwh" Name="vwh_id" Type="String" />
        ///        <asp:ControlParameter ControlID="ddlQualityCode" Name="quality_code" Type="String" />
        ///        <asp:ControlParameter ControlID="cblSkuArea" Name="ia_id" Type="String" />
        ///        <asp:ControlParameter ControlID="rblChoice" Name="choice" Type="String" />
        ///    </SelectParameters>
        ///</o:OracleDataSource>
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [TypeConverter(typeof(MultilineStringConverter))]
        public string SelectSql
        {
            get
            {
                return _selectSql;
            }
            set
            {
                _selectSql = value;
                RaiseDataSourceChangedEvent(EventArgs.Empty);
            }
        }

        /// <summary>
        /// Clears any cached data
        /// </summary>
        /// <remarks>
        /// <para>
        /// Call this after you manually querying this data source and then wish to discard the results you got.
        /// This was invented based on a specialized need of PiecesConstraint.aspx in DcmsWeb. We should think this through
        /// further.
        /// </para>
        /// </remarks>
        public void ClearCache()
        {
            RaiseDataSourceChangedEvent(EventArgs.Empty);
        }


        /// <summary>
        /// Sql to use while Inserting
        /// </summary>
        /// <remarks>
        /// <para>
        /// The Sql can contain XML tags to filter out portions as documented in <see cref="SelectSql"/>.
        /// This property should be used in preference to the deprecated <c>InsertCommand</c> propery.
        /// </para>
        /// <example>
        /// <para>
        /// This example Insert details only if <c>upc_code</c> parameter is not specified. Else pkg_ctnresv.add_sku will be called 
        /// only if <c>upc_code</c> parameter is specified.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<o:OracleDataSource runat="server" ID="dsCtnResv" ConnectionString="<%$ ConnectionStrings:dcms8 %>"
        ///    ProviderName="<%$ ConnectionStrings:dcms8.ProviderName %>" DataSourceMode="DataSet"
        ///    ConflictDetection="CompareAllValues" OnInserted="dsCtnResv_Inserted">
        ///<InsertSql>
        ///        <if c="not(:upc_code)">
        ///            declare
        ///                Lresv_rec pkg_ctnresv.resv_rec_type;
        ///                LGroup_Id VARCHAR2(255);
        ///            begin
        ///             ...
        ///            end;
        ///            </if>
        ///            <if c=":upc_code">
        ///            begin
        ///                  pkg_ctnresv.add_sku(actn_resv_id =&gt; :ctn_resv_id,
        ///                                  asku_id =&gt; :upc_code,
        ///                                  apieces_per_package =&gt; 1,
        ///                                  arequired_pieces =&gt; :quantity_requested,
        ///                                  adestination_location =&gt; :destination_area,
        ///                                  atarget_sku_id =&gt; :conversion_upc);
        ///            end;
        ///            </if>
        ///    </InsertSql>
        ///    <InsertParameters>
        ///        <asp:Parameter Name="upc_code" Type="String" />
        ///        ...
        ///    </InsertParameters>
        ///</o:OracleDataSource>
        /// ]]>
        /// </code>
        /// </example>
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [TypeConverter(typeof(MultilineStringConverter))]
        public string InsertSql { get; set; }


        /// <summary>
        /// Sql to use while updating
        /// </summary>
        /// <remarks>
        /// <para>
        /// The Sql can contain XML tags to filter out portions as documented in <see cref="SelectSql"/>.
        /// This property should be used in preference to the deprecated <c>UpdateCommand</c> propery.
        /// </para>
        /// <example>
        /// <para>
        /// This example updates weight only if <c>update_weight</c> parameter is specified. The volume is updated
        /// only if <c>update_volume</c> parameter is specified.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<o:OracleDataSource ID="dsSelectedUpdate" runat="server" ConnectionString="<%$ ConnectionStrings:dcms4 %>"
        ///    ProviderName="<%$ ConnectionStrings:dcms4.ProviderName %>" UpdateCommand="
        ///            UPDATE master_sku msku
        ///            SET [$:update_weight$msku.weight_per_dozen = :weight_per_dozen$]
        ///            [$:update_weight and :update_volume$,$]
        ///                [$:update_volume$msku.volume_per_dozen = :volume_per_dozen$]
        ///                WHERE msku.sku_id = :sku_id
        ///    ">
        ///    <UpdateSql>
        ///    UPDATE master_sku msku
        ///            SET <if c=":update_weight">msku.weight_per_dozen = :weight_per_dozen</if>
        ///            <if c=":update_weight and :update_volume">,</if>
        ///            <if c=":update_volume">msku.volume_per_dozen = :volume_per_dozen</if>
        ///                WHERE msku.sku_id = :sku_id
        ///    </UpdateSql>
        ///    <UpdateParameters>
        ///        <asp:Parameter Name="sku_id" Type="Int32" />
        ///        <asp:ControlParameter ControlID="tbWeight" Name="weight_per_dozen" Type="Decimal"
        ///            Direction="Input" />
        ///        <asp:ControlParameter ControlID="tbVolume" Name="volume_per_dozen" Type="Decimal"
        ///            Direction="Input" />
        ///        <asp:ControlParameter ControlID="rblWeight" Name="update_weight" Type="String"
        ///            Direction="Input" />
        ///        <asp:ControlParameter ControlID="rblVolume" Name="update_volume" Type="String"
        ///            Direction="Input" />
        ///    </UpdateParameters>
        ///</o:OracleDataSource>
        /// ]]>
        /// </code>
        /// </example>
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [TypeConverter(typeof(MultilineStringConverter))]
        public string UpdateSql { get; set; }


        /// <summary>
        /// Sql to use while Deleting
        /// </summary>
        /// <remarks>
        /// <para>
        /// The Sql can contain XML tags to filter out portions as documented in <see cref="SelectSql"/>.
        /// This property should be used in preference to the deprecated <c>DeleteCommand</c> propery.
        /// </para>
        /// <example>
        /// <para>
        /// This example delete <c>master_storage_location</c> only if <c>storage_area</c> parameter is specified.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<o:OracleDataSource ID="dsLoc" runat="server" ConnectionString="<%$ ConnectionStrings:dcms4 %>"
        ///         ProviderName="<%$ ConnectionStrings:dcms4.ProviderName %>" 
        ///         DeleteCommand="delete master_storage_location msl
        ///         where msl.location_id like '%'|| :location_id||'%'
        ///             [$:storage_area$and msl.storage_area = :storage_area$]
        ///             and not exists (select ctn.location_id
        ///      from src_carton ctn
        ///      where ctn.location_id = msl.location_id
        ///      group by location_id)">
        ///         <DeleteParameters>
        ///             <asp:ControlParameter ControlID="ddlArea" Name="storage_area" Type="String" />
        ///             <asp:ControlParameter Name="location_id" ControlID="tbLocationLike" Type="String" />
        ///         </DeleteParameters>    
        ///     </o:OracleDataSource>
        /// ]]>
        /// </code>
        /// </example>
        /// </remarks>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [TypeConverter(typeof(MultilineStringConverter))]
        public string DeleteSql { get; set; }

        /// <summary>
        /// Get rid of the view
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1063:ImplementIDisposableCorrectly")]
        public override void Dispose()
        {
            if (m_view != null)
            {
                m_view.Dispose();
            }
            if (_db != null)
            {
                _db.Dispose();
                _db = null;
            }
            base.Dispose();
        }

        /// <summary>
        /// All subsequent commands will execute in the context of this transaction
        /// </summary>
        public void BeginTransaction()
        {
            m_view.BeginTransaction();
        }

        /// <summary>
        /// Commit the transaction
        /// </summary>
        public void CommitTransaction()
        {
            m_view.CommitTransaction();
        }

        /// <summary>
        /// Rollback the transaction
        /// </summary>
        public void RollBackTransaction()
        {
            m_view.RollBackTransaction();
        }

        private OracleDataSourceView m_view;

        /// <summary>
        /// Creates an instance of <see cref="OracleDataSourceView"/>.
        /// </summary>
        /// <param name="viewName"></param>
        /// <returns></returns>
        protected override SqlDataSourceView CreateDataSourceView(string viewName)
        {
            if (m_view != null)
            {
                throw new InvalidOperationException("Call expected only once");
            }
            m_view = new OracleDataSourceView(this, viewName, this.Context);
            m_view.Selected += new SqlDataSourceStatusEventHandler(m_view_Selected);
            return m_view;
        }

        /// <summary>
        /// We trace the query in comments as well
        /// </summary>
        private DbCommand _cmdToTrace;
        private void m_view_Selected(object sender, SqlDataSourceStatusEventArgs e)
        {
            _cmdToTrace = e.Command;
        }

        ///// <summary>
        ///// TODO: Detailed doc
        ///// </summary>
        //[Category("Data")]
        //[Description("Raised when SQL command is parsed for tokens")]
        //[Obsolete]
        //public event EventHandler<CommandParsingEventArgs> CommandParsing
        //{
        //    add
        //    {
        //        m_view.CommandParsing += value;
        //    }
        //    remove
        //    {
        //        m_view.CommandParsing -= value;
        //    }
        //}

        /// <summary>
        /// TODO:
        /// </summary>
        [Category("Data")]
        [Description("Raised just before data is returned to the data bound control")]
        public event EventHandler<PostSelectedEventArgs> PostSelected
        {
            add
            {
                m_view.PostSelected += value;
            }
            remove
            {
                m_view.PostSelected -= value;
            }
        }

        //[Obsolete]
        //private CommandTextCollection _queries;

        ///// <summary>
        ///// You can specify any queries here. Then ask us to return a particular query
        ///// </summary>
        //[Browsable(true)]
        //[PersistenceMode(PersistenceMode.InnerProperty)]
        //[Themeable(false)]
        //[Bindable(true)]
        //[Category("Data")]
        //[Description("Container for specifying multiple queries")]
        //[NotifyParentProperty(true)]
        //[Obsolete("Use SelectSql property")]
        //public CommandTextCollection CommandTexts
        //{
        //    get
        //    {
        //        if (_queries == null)
        //        {
        //            _queries = new CommandTextCollection();
        //        }
        //        return _queries;
        //    }
        //}

        #region Query Execution Time

        ///// <summary>
        ///// When true, sets the query execution time in the profile.
        ///// </summary>
        //[Browsable(true)]
        //[DefaultValue(false)]
        //[Obsolete("Not supported")]
        //public bool DisplayExecutionTime { get; set; }


        /// <summary>
        /// Trace the query within comments for debugging purposes
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            if (_cmdToTrace != null)
            {
                bool IsRequestFromWindowsCE = this.Page.Request.ServerVariables["HTTP_USER_AGENT"].Contains("Windows CE");
                if (!IsRequestFromWindowsCE)
                {
                    writer.WriteLine();
                    writer.WriteLine("<!--");
                    writer.WriteLine("****OracleDataSource ID: {0}", this.ID);
                    writer.WriteLine(_cmdToTrace.CommandText);
                    string str;
                    foreach (DbParameter param in _cmdToTrace.Parameters)
                    {
                        if (param.Value == null)
                        {
                            str = string.Format("Parameter {0} -> null (null {1}) {2}",
                                param.ParameterName, param.DbType, param.Direction);
                        }
                        else
                        {
                            str = string.Format("Parameter {0} -> {1} ({2} {3}) {4}",
                                param.ParameterName, param.Value, param.Value.GetType(), param.DbType, param.Direction);
                        }
                        writer.WriteLine(str);
                    }
                    writer.WriteLine("-->");
                }
            }
        }
        #endregion

        private static Regex __regexStatusMsg;

        /// <summary>
        /// Status messages begin with /** and end with */
        /// </summary>
        /// <param name="cmd"></param>
        public static IList<string> ExtractStatusMessages(DbCommand cmd)
        {
            List<string> list = new List<string>();
            if (__regexStatusMsg == null)
            {
                // Extract all strings within /** and */
                __regexStatusMsg = new Regex(@"\/\*\*(?<msg>[^\*\/]*?)\*\/",
                    RegexOptions.IgnoreCase | RegexOptions.Singleline | RegexOptions.Compiled);
            }

            MatchCollection statusMsgMatches = __regexStatusMsg.Matches(cmd.CommandText);
            foreach (Match statusMsgMatch in statusMsgMatches)
            {
                string statusMessage = statusMsgMatch.Value;
                // For each parameter specified in this status message
                // Iterate in reverse order so that string replacement does not change index of matches
                foreach (Match paramMatch in OracleDataSourceView.ParametersRegEx.Matches(statusMessage).Cast<Match>().Reverse())
                {
                    statusMessage = statusMessage.Remove(paramMatch.Index, paramMatch.Length);
                    // Substring removes leading :
                    statusMessage = statusMessage.Insert(paramMatch.Index, cmd.Parameters[paramMatch.Value.Substring(1)].Value.ToString());
                }
                // Remove leading /** and trailing */
                list.Add(statusMessage.Substring(3, statusMessage.Length - 5));
            }

            return list;
        }

        private OracleDatastore _db;

        internal OracleDatastore Datastore
        {
            get {
                if (_db == null)
                {
                    _db = new OracleDatastore(this.Context.Trace);
                }
                return _db;
            }
        } 



        #region Not supported
        ///// <summary>
        ///// Setting not supported. Always returns <c>SqlDataSourceCommandType.Text</c>.
        ///// </summary>
        //[EditorBrowsable(EditorBrowsableState.Never)]
        //[Browsable(false)]
        //[Obsolete("The only acceptable value is Text")]
        //public new SqlDataSourceCommandType SelectCommandType
        //{
        //    get
        //    {
        //        return SqlDataSourceCommandType.Text;
        //    }
        //    set
        //    {
        //        throw new NotSupportedException();
        //    }
        //}

        ///// <summary>
        ///// Setting not supported. Always returns <c>SqlDataSourceCommandType.Text</c>.
        ///// </summary>
        //[Browsable(false)]
        //[Obsolete("The only acceptable value is Text")]
        //[EditorBrowsable(EditorBrowsableState.Never)]
        //public new SqlDataSourceCommandType UpdateCommandType
        //{
        //    get
        //    {
        //        return SqlDataSourceCommandType.Text;
        //    }
        //    set
        //    {
        //        throw new NotSupportedException();
        //    }
        //}

        ///// <summary>
        ///// Setting not supported. Always returns <c>SqlDataSourceCommandType.Text</c>.
        ///// </summary>
        //[Browsable(false)]
        //[Obsolete("The only acceptable value is Text")]
        //[EditorBrowsable(EditorBrowsableState.Never)]
        //public new SqlDataSourceCommandType InsertCommandType
        //{
        //    get
        //    {
        //        return SqlDataSourceCommandType.Text;
        //    }
        //    set
        //    {
        //        throw new NotSupportedException();
        //    }
        //}

        ///// <summary>
        ///// Setting not supported. Always returns <c>SqlDataSourceCommandType.Text</c>.
        ///// </summary>
        //[Browsable(false)]
        //[Obsolete("The only acceptable value is Text")]
        //[EditorBrowsable(EditorBrowsableState.Never)]
        //public new SqlDataSourceCommandType DeleteCommandType
        //{
        //    get
        //    {
        //        return SqlDataSourceCommandType.Text;
        //    }
        //    set
        //    {
        //        throw new NotSupportedException();
        //    }
        //}
        #endregion

        #region Deprecated
        ///// <summary>
        ///// 
        ///// </summary>
        //[Obsolete("Use SelectSql")]
        //[Browsable(false)]
        //public new string SelectCommand
        //{
        //    get
        //    {
        //        return base.SelectCommand;
        //    }
        //    set
        //    {
        //        base.SelectCommand = value;
        //    }
        //}

        ///// <summary>
        ///// 
        ///// </summary>
        //[Obsolete("Use InsertSql")]
        //[Browsable(false)]
        //public new string InsertCommand
        //{
        //    get
        //    {
        //        return base.InsertCommand;
        //    }
        //    set
        //    {
        //        base.InsertCommand = value;
        //    }
        //}

        ///// <summary>
        ///// 
        ///// </summary>
        //[Obsolete("UpdateSql")]
        //[Browsable(false)]
        //public new string UpdateCommand
        //{
        //    get
        //    {
        //        return base.UpdateCommand;
        //    }
        //    set
        //    {
        //        base.UpdateCommand = value;
        //    }
        //}

        ///// <summary>
        ///// 
        ///// </summary>
        //[Obsolete("DeleteSql")]
        //[Browsable(false)]
        //public new string DeleteCommand
        //{
        //    get
        //    {
        //        return base.DeleteCommand;
        //    }
        //    set
        //    {
        //        base.DeleteCommand = value;
        //    }
        //}

        ///// <summary>
        ///// Dummy property for compatibility with pickers using older version of library.
        ///// </summary>
        //[Obsolete]
        //[Browsable(false)]
        //public bool CancelSelectOnValidationFailure { get; set; }

        ///// <summary>
        ///// Dummy property for compatibility with pickers using older version of library.
        ///// </summary>
        //[Obsolete]
        //[Browsable(false)]
        //public bool IgnoreOrderByCheck { get; set; }
        #endregion
    }
}

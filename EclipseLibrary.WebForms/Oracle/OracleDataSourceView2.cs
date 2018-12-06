// Contains CommandParsing related functions of the OracleDataSourceView class.
namespace EclipseLibrary.WebForms.Oracle
{
    ///// <summary>
    ///// Used during the <see cref="OracleDataSource.CommandParsing"/> event.
    ///// This is the type of the <see cref="CommandParsingEventArgs.Action"/> property.
    ///// </summary>
    //[Obsolete]
    //public enum CommandParsingAction
    //{
    //    /// <summary>
    //    /// It is an error if the value remains this after <see cref="OracleDataSource.CommandParsing"/>
    //    /// event handlers have finished executing.
    //    /// </summary>
    //    Undecided,

    //    /// <summary>
    //    /// The clause which is being parsed should be ignored.
    //    /// </summary>
    //    IgnoreClause,

    //    /// <summary>
    //    /// The clause which is being parsed should be used.
    //    /// </summary>
    //    UseClause,

    //    /// <summary>
    //    /// The replacement for the clause has been specified in <see cref="CommandParsingEventArgs.ReplacementString"/>
    //    /// property.
    //    /// </summary>
    //    UseReplacement,

    //    /// <summary>
    //    /// This is an opportunity to cancel the query
    //    /// </summary>
    //    CancelQuery
    //}

    ///// <summary>
    ///// Passed as argument to the <see cref="OracleDataSource.CommandParsing"/> event.
    ///// </summary>
    //[Obsolete]
    //public class CommandParsingEventArgs : EventArgs
    //{
    //    private readonly DbCommand _cmd;
    //    /// <summary>
    //    /// 
    //    /// </summary>
    //    /// <param name="cmd"></param>
    //    public CommandParsingEventArgs(DbCommand cmd)
    //    {
    //        _cmd = cmd;
    //        //_parameters = cmd.Parameters;
    //    }

    //    /// <summary>
    //    /// The name of the function which is being parsed
    //    /// </summary>
    //    public string FunctionName { get; set; }

    //    /// <summary>
    //    /// Initially it contains the text which was parsed for the function.
    //    /// It will become part of the SQL command if <see cref="Action"/> is set to 
    //    /// <c>UseReplacement</c>
    //    /// </summary>
    //    public string ReplacementString { get; set; }

    //    /// <summary>
    //    /// How should the SQL text for this function be handled.
    //    /// </summary>
    //    public CommandParsingAction Action { get; set; }

    //    /// <summary>
    //    /// The command whose text is being constructed. You may want to access parameter values
    //    /// or even add/modify parameters.
    //    /// </summary>
    //    public DbCommand Command
    //    {
    //        get
    //        {
    //            return _cmd;
    //        }
    //    }

    //    /// <exclude />
    //    /// <summary>
    //    /// 
    //    /// </summary>
    //    [Obsolete("Use Command.Parameters instead")]
    //    public DbParameterCollection Parameters
    //    {
    //        get
    //        {
    //            return _cmd.Parameters;
    //        }
    //    }
    //}

    public partial class OracleDataSourceView
    {
        ///// <summary>
        ///// Raised when the query is being parsed for tokens
        ///// </summary>
        //[Obsolete]
        //internal event EventHandler<CommandParsingEventArgs> CommandParsing;


        #region Legacy Parsing
        ///// <summary>
        ///// 
        ///// </summary>
        ///// <param name="cmd"></param>
        ///// <param name="varName">The name of the array variable</param>
        ///// <param name="repeat"></param>
        ///// <returns>pre + :varName0 + sep + ... sep + :varNamen + post</returns>
        ///// <remarks>
        ///// </remarks>
        //[Obsolete]
        //private static string HandleArrayParameterLegacy(DbCommand cmd, string varName, string repeat)
        //{
        //    if (cmd.Parameters[varName].Value == null)
        //    {
        //        return string.Empty;
        //    }
        //    // Scanner returns \r so included \r also. \n is for new line
        //    string[] arrayValues = cmd.Parameters[varName].Value.ToString().Split(',', '\r', '\n');
        //    List<string> args = new List<string>();
        //    string str;
        //    for (int index = 0; index < arrayValues.Length; ++index)
        //    {
        //        if (!string.IsNullOrEmpty(arrayValues[index]))
        //        {
        //            DbParameter param = cmd.CreateParameter();      // new OracleParameter();
        //            param.ParameterName = string.Format("{0}{1}", varName, index);
        //            str = string.Format(":{0}{1}", varName, index);
        //            args.Add(str);
        //            param.Value = arrayValues[index].Trim();
        //            param.DbType = cmd.Parameters[varName].DbType;
        //            cmd.Parameters.Add(param);
        //        }
        //    }
        //    if (args.Count == 0)
        //    {
        //        return string.Empty;
        //    }

        //    ConditionalFormatter formatter = new ConditionalFormatter(null);
        //    //if (sep == null || string.IsNullOrWhiteSpace(sep.Value))
        //    //{
        //        // Legacy mode. Suitable only for the IN clause
        //        // e.g. [$[style]$style IN ({0})$] becomes style IN (:style0, :style1)
        //        str = string.Join(", ", args.ToArray());
        //        string replacement = string.Format(formatter, repeat, str);

        //    return replacement;
        //}

        ///// <summary>
        ///// Example pattern: abcd [$StyleWhere$AND style LIKE :style || '%'$] efgh
        ///// This has one function with
        ///// functionName = StyleWhere
        ///// params = StyleWhere$AND style LIKE :style || '%'
        ///// </summary>
        //[Obsolete]
        //private static readonly Regex _clauseRegex = new Regex(
        //    @"\[\$(?<clauseName>[^\$]*?)\$" + @"(?:(?<clause>.*?)(?:(?=\$\])))*?\$\]",
        //    RegexOptions.IgnoreCase | RegexOptions.Singleline | RegexOptions.Compiled);

        //[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities"), Obsolete]
        //private void RaiseCommandParsingEvents(SqlDataSourceCommandEventArgs e)
        //{
        //    switch (e.Command.CommandType)
        //    {
        //        case CommandType.StoredProcedure:
        //            throw new NotSupportedException("By Sharad as of 29 Nov 2010");

        //        case CommandType.Text:
        //            StringBuilder sb = new StringBuilder(e.Command.CommandText);
        //            // Parse clauses next
        //            if (sb.ToString().Contains("[["))
        //            {
        //                // Catch common error. SOmeone is trying to have a block within a block
        //                throw new InvalidOperationException("Current limitation. Cannot nest blocks. " + sb);
        //            }
        //            e.Cancel = ParseQueryTokens(e.Command, sb, _clauseRegex, "clauseName", "clause");
        //            if (!e.Cancel)
        //            {
        //                e.Command.CommandText = sb.ToString();
        //                e.Cancel = RemoveUnusedParams(e.Command);
        //            }
        //            break;

        //        default:
        //            throw new NotSupportedException();
        //    }
        //}

        //[Obsolete]
        //internal static bool RemoveUnusedParams(DbCommand cmd)
        //{
        //    var matches = _regexParameters.Matches(cmd.CommandText);
        //    List<string> toKeep = (from Match m in matches select m.Groups["paramName"].Value).ToList();

        //    List<DbParameter> toRemove = new List<DbParameter>();
        //    foreach (DbParameter param in cmd.Parameters)
        //    {
        //        if (!toKeep.Any(p => string.Compare(p, param.ParameterName, true) == 0))
        //        {
        //            // Parameter not used in query. Get rid of it.
        //            toRemove.Add(param);
        //        }
        //        else if (param.Value == null)
        //        {
        //            // we must change null to DBNull
        //            param.Value = DBNull.Value;
        //        }
        //    }

        //    foreach (DbParameter param in toRemove)
        //    {
        //        cmd.Parameters.Remove(param);
        //    }
        //    return false;       // Do not cancel the query
        //}

        ///// <summary>
        ///// cmd is used only to send as an event argument
        ///// </summary>
        ///// <param name="cmd"></param>
        ///// <param name="sb"></param>
        ///// <param name="regex"></param>
        ///// <param name="groupLeft"></param>
        ///// <param name="groupRight"></param>
        ///// <returns></returns>
        //[Obsolete]
        //private bool ParseQueryTokens(DbCommand cmd, StringBuilder sb, Regex regex, string groupLeft, string groupRight)
        //{
        //    MatchCollection matches = regex.Matches(sb.ToString());
        //    CommandParsingEventArgs cpeArgs = new CommandParsingEventArgs(cmd);
        //    // Notice that we are iterating in reverse order of matches
        //    bool bCancel = false;
        //    //XPathEvaluator nav = new XPathEvaluator(cmd.Parameters.Cast<DbParameter>().ToDictionary(p => p.ParameterName,
        //    //    q => q.Value, StringComparer.OrdinalIgnoreCase));
        //    XPathEvaluator nav = new XPathEvaluator(p => cmd.Parameters[p].Value) {VariablePrefix = ":"};
        //    for (int i = matches.Count - 1; i >= 0 && !bCancel; i--)
        //    {
        //        cpeArgs.Action = CommandParsingAction.Undecided;
        //        cpeArgs.FunctionName = matches[i].Groups[groupLeft].Value;
        //        cpeArgs.ReplacementString = matches[i].Groups[groupRight].Value;
        //        if (cpeArgs.FunctionName.StartsWith("["))
        //        {
        //            // Array parameter. Might look like [ucc_id_list]contains(:print_what, 'P')
        //            int index = cpeArgs.FunctionName.IndexOf("]");
        //            string condition = cpeArgs.FunctionName.Substring(index + 1).Trim();
        //            bool b = true;
        //            if (condition.Length > 0)
        //            {
        //                // Make sure the condition is satisfied before we bother to do array parsing
        //                b = nav.Matches(condition);
        //            }
        //            if (b)
        //            {
        //                // Condition satisfied. Let array do its work
        //                cpeArgs.FunctionName = cpeArgs.FunctionName.Substring(0, index + 1).TrimStart('[').TrimEnd(']');
        //                string[] tokens = cpeArgs.FunctionName.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        //                if (tokens.Length > 1)
        //                {
        //                    throw new NotSupportedException("This functionality has been removed. Use SelectSql.");
        //                }
        //                if (cpeArgs.Command.Parameters[tokens[0]].Value == null)
        //                {
        //                    cpeArgs.Action = CommandParsingAction.IgnoreClause;
        //                }
        //                else
        //                {
        //                    cpeArgs.ReplacementString = HandleArrayParameterLegacy(cmd, tokens[0], cpeArgs.ReplacementString);
        //                    cpeArgs.Action = string.IsNullOrWhiteSpace(cpeArgs.ReplacementString) ? CommandParsingAction.IgnoreClause : CommandParsingAction.UseClause;
        //                }
        //            }
        //            else
        //            {
        //                // Condition failed. Ignore the clause
        //                cpeArgs.Action = CommandParsingAction.IgnoreClause;
        //            }
        //        }
        //        else if (cpeArgs.FunctionName.Contains(":"))
        //        {
        //            bool b = nav.Matches(cpeArgs.FunctionName);
        //            cpeArgs.Action = b ? CommandParsingAction.UseClause : CommandParsingAction.IgnoreClause;
        //        }
        //        else
        //        {
        //            if (CommandParsing != null)
        //            {
        //                CommandParsing(this, cpeArgs);
        //            }
        //        }

        //        sb.Remove(matches[i].Index, matches[i].Length);
        //        switch (cpeArgs.Action)
        //        {
        //            case CommandParsingAction.Undecided:
        //                string str = string.Format("Must decide what to do with Function: {0}",
        //                    cpeArgs.FunctionName);
        //                throw new InvalidOperationException(str);

        //            case CommandParsingAction.IgnoreClause:
        //                // OK
        //                break;

        //            case CommandParsingAction.UseClause:
        //                sb.Insert(matches[i].Index, cpeArgs.ReplacementString);
        //                break;

        //            case CommandParsingAction.UseReplacement:
        //                sb.Insert(matches[i].Index, cpeArgs.ReplacementString);
        //                break;

        //            case CommandParsingAction.CancelQuery:
        //                bCancel = true;
        //                break;

        //            default:
        //                break;
        //        }

        //    }
        //    return bCancel;
        //}
        #endregion

    }

}

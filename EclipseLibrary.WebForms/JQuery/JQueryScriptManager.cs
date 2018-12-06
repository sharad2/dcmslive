using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using EclipseLibrary.Web.Extensions;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.JQuery.Scripts;

[assembly: WebResource("EclipseLibrary.Web.JQuery.Scripts.CommonScripts.min.js", "text/javascript")]
[assembly: WebResource("EclipseLibrary.Web.JQuery.Scripts.CommonStyles.css", "text/css")]
namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Types of jQuery scripts which need to be rendered
    /// </summary>
    [Flags]
    public enum ScriptTypes
    {
        /// <summary>
        /// No scripts are needed
        /// </summary>
        None = 0x0,

        /// <summary>
        /// Generate script to call web methods
        /// </summary>
        WebMethods = 0x4,

        /// <summary>
        /// Generate script for latestText function
        /// </summary>
        LatestText = 0x8,

        /// <summary>
        /// All common scripts are in a single file
        /// </summary>
        [Browsable(false)]
        Common = 0x20,

        /// <summary>
        /// jQuery core scripts
        /// </summary>
        Core = 0x20,

        /// <summary>
        /// jQuery UI scripts
        /// </summary>
        UiCore = 0x20,

        /// <summary>
        /// buttonEx widget
        /// </summary>
        ButtonEx = 0x20,

        /// <summary>
        /// Validation plugin
        /// </summary>
        Validation = 0x20,

        /// <summary>
        /// JSON plugin
        /// </summary>
        Json = 0x20,

        /// <summary>
        /// ajaxDropDown widget
        /// </summary>
        AjaxDropDown = 0x20,

        /// <summary>
        /// ajaxDialog widget
        /// </summary>
        AjaxDialog = 0x20,

        /// <summary>
        /// checkBoxListEx widget
        /// </summary>
        CheckBoxListEx = 0x20,

        /// <summary>
        /// gridViewEx widget
        /// </summary>
        GridViewEx = 0x20,

        /// <summary>
        /// cascade widget
        /// </summary>
        Cascade = 0x20,

        /// <summary>
        /// textBoxEx widget
        /// </summary>
        TextBoxEx = 0x20,

        /// <summary>
        /// radioButtonListEx widget
        /// </summary>
        RadioButtonListEx = 0x20
    }

    /// <summary>
    /// This is a utilitarian class to centralize loading of JQuery scripts. It follows the singleton pattern.
    /// The constructor is private. You access it through the static Current property.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Sharad 18 Jul 2009: Provided the ability to nest scripts as children. These scripts are rendered after the jquery framework
    /// scripts. However, for ajax calls, these scripts are rendered *before* the framework scripts. This avoides undefined object
    /// errors in IE8 when functions are called before they have been declared.
    /// Sharad 9/9/09: Added capability to include validation scripts
    /// </para>
    /// <para>
    /// 25 Nov 2009: A single CommonScripts.min.js includes most of the scripts needed by the application.
    /// The post build event is responsible for creating this file. The current Post Build event looks like this:
    /// </para>
    /// <example>
    /// <![CDATA[
    ///$(ProjectDir)Tools\jsmin.exe < $(ProjectDir)Web\JQuery\Scripts\jquery.validate.js > $(ProjectDir)Web\JQuery\Scripts\CommonScripts.min.js
    ///$(ProjectDir)Tools\jsmin.exe < $(ProjectDir)Web\JQuery\Scripts\json2.js >> $(ProjectDir)Web\JQuery\Scripts\CommonScripts.min.js
    ///$(ProjectDir)Tools\jsmin.exe < $(ProjectDir)Web\JQuery\Scripts\CommonScripts.js >> $(ProjectDir)Web\JQuery\Scripts\CommonScripts.min.js
    ///$(ProjectDir)Tools\jsmin.exe < $(ProjectDir)Web\JQuery\Scripts\AjaxDialog.js >> $(ProjectDir)Web\JQuery\Scripts\CommonScripts.min.js
    ///]]>
    ///</example>
    ///<para>
    ///2 Dec 2009: Do not raise exception if the page has no form. Just ignore the client validation rules.
    ///</para>
    ///<para>
    ///<c>JQueryScriptManager</c> assists in setting initial focus on the page. Each control which is interested in
    ///receiving focus should implement <see cref="IFocusable"/> call <see cref="AddTopLevelFocusable"/> during the
    ///<see cref="Control.PreRender"/> event. It should also implement the <see cref="IFocusable.Focus"/> function which
    ///should generate the script to give focus to the control.
    ///</para>
    /// </remarks>
    [ParseChildren(false)]
    [PersistChildren(true)]
    public class JQueryScriptManager : Control
    {
        #region Initialization
        private ScriptTypes _scripts;
        /// <summary>
        /// Singleton class. Private constructor.
        /// </summary>
        public JQueryScriptManager()
        {
            object obj = HttpContext.Current.Items["JQuerySriptManager"];
            if (obj != null)
            {
                throw new HttpException("Multiple JQueryScriptManager ?");
            }
            HttpContext.Current.Items["JQuerySriptManager"] = this;
        }

        /// <summary>
        /// Returns the <c>JQueryScriptmanager</c> which is managing the current request
        /// </summary>
        public static JQueryScriptManager Current
        {
            get
            {
                JQueryScriptManager mgr = (JQueryScriptManager)HttpContext.Current.Items["JQuerySriptManager"];
                if (mgr == null)
                {
                    throw new HttpException("JQuerySriptManager is required on the page");
                }
                return mgr;
            }
        }
        #endregion

        #region Ajax
        /// <summary>
        /// returns true if the page is called via AJAX. JQuery ajax functions set the server variable
        /// HTTP_X_REQUESTED_WITH which we take advantage of.
        /// When true, the behavior changes as follows:
        /// 1. Jquery script includes are not rendered. It is presumed that the calling page has the includes.
        /// 2. document.ready scripts are not bracketed within the ready handler. Instead they are emitted as
        /// gloabal scripts which run on startup.
        /// 3. CSS script includes are not rendered.
        /// </summary>
        public static bool IsAjaxCall
        {
            get
            {
                return !string.IsNullOrEmpty(HttpContext.Current.Request.ServerVariables["HTTP_X_REQUESTED_WITH"]);
            }
        }
        #endregion

        /// <summary>
        /// The form with which validation rules will be associated
        /// </summary>
        /// <remarks>
        /// <para>
        /// By default, all valiadtion rules are associated with the server form. If you do not have a server form, then
        /// you must specify the selector to your form here.
        /// </para>
        /// <para>
        /// TODO: Support multiple form validations
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string FormSelector { get; set; }

        #region Standard Scripts

        /// <summary>
        /// Request rendering of one or more scripts
        /// </summary>
        /// <param name="types"></param>
        /// <returns></returns>
        public JQueryScriptManager RegisterScripts(ScriptTypes types)
        {
            _scripts |= types;
            return this;
        }

        /// <summary>
        /// If we get here, core scripts are always needed
        /// </summary>
        /// <param name="writer"></param>
        private void RenderStandardScriptIncludes(HtmlTextWriter writer)
        {
            string url;

            if ((_scripts & ScriptTypes.Common) == ScriptTypes.Common)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Id, "common_js");
                url = this.Page.ClientScript.GetWebResourceUrl(typeof(JQueryScriptManager),
                    "EclipseLibrary.Web.JQuery.Scripts.CommonScripts.min.js");
                writer.AddAttribute(HtmlTextWriterAttribute.Src, url);
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
                writer.RenderBeginTag(HtmlTextWriterTag.Script);
                writer.RenderEndTag();
            }

            return;
        }

        #endregion

        #region Css
        private Dictionary<string, string> _cssBlocks;

        /// <summary>
        /// Registers the CSS block for rendering only if a block with the same id has not already been registered.
        /// This prevents duplicate rendering of the same styles.
        /// </summary>
        /// <param name="id"></param>
        /// <param name="block"></param>
        /// <returns></returns>
        /// <remarks>
        /// Designed for use by custom controls in other libraries. For example, BusinessDateTextBox uses it.
        /// </remarks>
        public JQueryScriptManager RegisterCssBlock(string id, string block)
        {
            if (_cssBlocks == null)
            {
                _cssBlocks = new Dictionary<string, string>();
            }
            if (!_cssBlocks.ContainsKey(id))
            {
                _cssBlocks.Add(id, block);
            }
            return this;
        }

        private void RenderCss(HtmlTextWriter writer)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Id, "commonStyles");
            string url = this.Page.ClientScript.GetWebResourceUrl(typeof(JQueryScriptManager),
                "EclipseLibrary.Web.JQuery.Scripts.CommonStyles.css");
            writer.AddAttribute(HtmlTextWriterAttribute.Href, url);
            writer.AddAttribute(HtmlTextWriterAttribute.Rel, "stylesheet");
            writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/css");
            writer.RenderBeginTag(HtmlTextWriterTag.Link);
            writer.RenderEndTag();

            if (_cssBlocks != null)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/css");
                writer.RenderBeginTag(HtmlTextWriterTag.Style);
                foreach (var item in _cssBlocks)
                {
                    writer.Write(item.Value);
                }
                writer.RenderEndTag();      // style
            }
        }
        #endregion

        #region Custom Scripts

        private List<string> _scriptBlocks;
        private HashSet<string> _scriptBlockKeys;

        /// <summary>
        /// If creating a block requires significant resources, you can first check whether it has already been registered
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public bool IsScriptBlockRegistered(string key)
        {
            return _scriptBlockKeys != null && _scriptBlockKeys.Contains(key);
        }

        /// <summary>
        /// Registers a script block for rendering
        /// </summary>
        /// <param name="script"></param>
        /// <returns></returns>
        public JQueryScriptManager RegisterScriptBlock(string script)
        {
            if (_scriptBlocks == null)
            {
                _scriptBlocks = new List<string>();
            }
            _scriptBlocks.Add(script);
            return this;
        }

        /// <summary>
        /// Registers a script block for rendering only if a block with the same id has not already been
        /// registered.
        /// </summary>
        /// <param name="id"></param>
        /// <param name="script"></param>
        /// <returns></returns>
        public JQueryScriptManager RegisterScriptBlock(string id, string script)
        {
            if (_scriptBlockKeys == null)
            {
                _scriptBlockKeys = new HashSet<string>();
            }
            if (!_scriptBlockKeys.Contains(id))
            {
                _scriptBlockKeys.Add(id);
                RegisterScriptBlock(script);
            }
            return this;
        }

        #endregion

        #region Ready Scripts
        private List<string> _readyScripts;

        /// <summary>
        /// Registers a script which should be executed during the document.ready() event.
        /// </summary>
        /// <param name="script"></param>
        /// <returns></returns>
        public JQueryScriptManager RegisterReadyScript(string script)
        {
            if (_readyScripts == null)
            {
                RegisterScripts(ScriptTypes.Core);
                _readyScripts = new List<string>();
            }
            _readyScripts.Add(script);
            return this;
        }

        /// <summary>
        /// Keyed ready scripts are rendered before _readyScripts. This is important for the validation plugin. 
        /// </summary>
        private Dictionary<string, string> _keyedReadyScripts;

        /// <summary>
        /// Registers a script which should be executed during the document.ready() event.
        /// Do not register again if a script with the same id has already been registered.
        /// </summary>
        /// <param name="id"></param>
        /// <param name="script"></param>
        /// <returns></returns>
        public JQueryScriptManager RegisterReadyScript(string id, string script)
        {
            if (_keyedReadyScripts == null)
            {
                RegisterScripts(ScriptTypes.Core);
                _keyedReadyScripts = new Dictionary<string, string>();
            }
            if (!_keyedReadyScripts.ContainsKey(id))
            {
                _keyedReadyScripts.Add(id, script);
                //RegisterReadyScript(script);
            }
            return this;
        }

        /// <summary>
        /// If creating a ready script requires significant resources, you can first check whether it
        /// has already been registered.
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public bool IsReadyScriptRegistered(string id)
        {
            return _keyedReadyScripts != null && _keyedReadyScripts.ContainsKey(id);
        }

        private void RenderReadyScripts(HtmlTextWriter writer)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Id, "ready_blocks");
            writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
            writer.RenderBeginTag(HtmlTextWriterTag.Script);

            if (_scriptBlocks != null)
            {
                foreach (string block in _scriptBlocks)
                {
                    writer.Write(block);
                }
            }

            bool bReadyRendered = false;
            if (_keyedReadyScripts != null || _readyScripts != null ||
                ((_scripts & ScriptTypes.Validation) == ScriptTypes.Validation))
            {
                if (!IsAjaxCall)
                {
                    writer.WriteLine("$(document).ready(function(){");
                    bReadyRendered = true;
                }
            }

            PrepareFormForValidation(writer);

            if (_keyedReadyScripts != null)
            {
                foreach (string script in _keyedReadyScripts.Values)
                {
                    writer.WriteLine(script);
                }
            }

            if (_readyScripts != null)
            {
                foreach (string script in _readyScripts)
                {
                    writer.WriteLine(script);
                }
            }

            if (bReadyRendered)
            {
                writer.Write("});");
            }
            writer.RenderEndTag();      //script
            return;
        }
        #endregion

        #region Rendering

        private List<Control> _focusables;

        /// <summary>
        /// Each focusable is responsible for adding itself to this list. This should be done
        /// during the <c>Load</c> event.
        /// </summary>
        /// <param name="focusable"></param>
        /// <remarks>
        /// <para>
        /// We maintain a list of all top level focusables only.
        /// Later we give focus to the first top level focusable with the highest
        /// priority.
        /// </para>
        /// </remarks>
        internal void AddTopLevelFocusable(IFocusable focusable)
        {
            if (_focusables == null)
            {
                _focusables = new List<Control>();
            }
            Control ctl = (Control)focusable;
            IFocusable ancestor = ctl.Ancestors(false).OfType<IFocusable>().FirstOrDefault();
            // We only add top level ancestors to the list of focusables
            if (ancestor == null)
            {
                _focusables.Add(ctl);
            }
        }

        /// <summary>
        /// This is the last opportunity for every control to create their jQuery scripts
        /// </summary>
        public event EventHandler CreateScripts;

        /// <summary>
        /// For ajax calls, child scripts are rendered before the framework scripts.
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            // Thankfully OrderBy does a stable sort.
            if (_focusables != null)
            {
                IFocusable focus = _focusables.Cast<IFocusable>()
                    .Where(p => p.FocusPriority != FocusPriority.NotAllowed)
                    .OrderBy(p => p.FocusPriority).FirstOrDefault();
                if (focus != null)
                {
                    focus.Focus();
                }
            }
            if (CreateScripts != null)
            {
                CreateScripts(this, EventArgs.Empty);
            }

            if (_scripts == ScriptTypes.None)
            {
                // If Jquery is not needed, do nothing
                return;
            }
            // Render proxies first. This is critical for Ajax calls.
            //RenderProxies(writer);

            if (IsAjaxCall)
            {
                RenderChildren(writer);
            }
            else
            {
                RenderCss(writer);
            }

            if (!IsAjaxCall)
            {
                RenderStandardScriptIncludes(writer);
            }
            // Custom script includes are included for AJAX calls as well
            //RenderCustomScriptIncludes(writer);

            RenderReadyScripts(writer);

            if (!IsAjaxCall)
            {
                RenderChildren(writer);
            }
        }
        #endregion

        #region Validation

        /// <summary>
        /// Set this to true when you do not have a form and yet would like to show the * symbol for required.
        /// UPCPicker is the motivation for this property.
        /// </summary>
        public bool DisableClientValidation { get; set; }

        private Dictionary<InputControlBase, JQueryOptions> _rules;
        private Dictionary<string, JQueryOptions> _messages;


        internal void AddValidationRule(InputControlBase ctl, string ruleName, object ruleParams, object message)
        {
            RegisterScripts(ScriptTypes.Core | ScriptTypes.Validation);
            if (_rules == null)
            {
                _rules = new Dictionary<InputControlBase, JQueryOptions>();
            }
            JQueryOptions options;
            if (!_rules.TryGetValue(ctl, out options))
            {
                options = new JQueryOptions();
                _rules.Add(ctl, options);
            }
            options.Add(ruleName, ruleParams);

            if (message != null)
            {
                if (_messages == null)
                {
                    _messages = new Dictionary<string, JQueryOptions>();
                }
                if (!_messages.TryGetValue(ctl.UniqueID, out options))
                {
                    options = new JQueryOptions();
                    _messages.Add(ctl.UniqueID, options);
                }
                options.Add(ruleName, message);
            }
        }

        /// <summary>
        /// CSS class applied to elements for which validation should not be performed
        /// </summary>
        public static string CssClassIgnoreValidation
        {
            get
            {
                return "val-ignore";
            }
        }

        /// <summary>
        /// CSS class applied to a validation container
        /// </summary>
        public static string CssClassValidationContainer
        {
            get
            {
                return "val-container";
            }
        }

        /// <summary>
        /// Class to be applied to validation summary container
        /// </summary>
        public static string CssClassValidationSummary
        {
            get
            {
                return "val-summary";
            }
        }

        /// <summary>
        /// No validation rules are generated if the page has no form
        /// </summary>
        /// <param name="writer"></param>
        private void PrepareFormForValidation(HtmlTextWriter writer)
        {
            if (_rules == null)
            {
                return;
            }
            if (this.DisableClientValidation || ((_scripts & ScriptTypes.Validation) != ScriptTypes.Validation))
            {
                // If validation scripts not requested, validation framework is not generated
                return;
            }
            JQueryOptions validateOptions = new JQueryOptions();

            // Hide all summaries. Error placement will make the correct one visible
            string script = @"
function(map, list) {
    $.each(list, function(i) {
        $.buttonEx.validationSummary.append('<li>' + this.message + '</li>').removeClass('ui-helper-hidden');
    });
}";
            validateOptions.AddRaw("showErrors", script);

            validateOptions.Add("ignoreTitle", true);
            validateOptions.Add("ignore", ".{0}", CssClassIgnoreValidation);
            // false because our button is responsible for validating
            validateOptions.Add("onsubmit", false);
            validateOptions.Add("onfocusin", false);
            validateOptions.Add("onfocusout", false);
            validateOptions.Add("onclick", false);
            validateOptions.Add("onkeyup", false);
            validateOptions.Add("focusInvalid", false);
            validateOptions.Add("focusCleanup", false);
            if (_rules != null)
            {
                JQueryOptions rules = new JQueryOptions();
                foreach (var rule in _rules)
                {
                    rules.Add(rule.Key.UniqueID, rule.Value);
                }
                validateOptions.Add("rules", rules);
                //validateOptions.Add("rules", _rules.Aggregate(new JQueryOptions(), (rules, rule) => rules.Add(rule.Key.UniqueID, rule.Value)));
            }
            if (_messages != null)
            {
                JQueryOptions messages = new JQueryOptions();
                foreach (var msg in _messages)
                {
                    messages.Add(msg.Key, msg.Value);
                }
                validateOptions.Add("messages", messages);
                //validateOptions.Add("messages", _messages.Aggregate(new JQueryOptions(), (messages, msg) => messages.Add(msg.Key, msg.Value)));
            }
            // Validation requires that all input controls are within a form
            string formSelector;
            if (!string.IsNullOrEmpty(this.FormSelector))
            {
                formSelector = this.FormSelector;
            }
            else if (this.Page.Form != null)
            {
                if (string.IsNullOrEmpty(this.Page.Form.ClientID))
                {
                    // Make sure the form has an ID.
                    this.Page.Form.ClientIDMode = System.Web.UI.ClientIDMode.AutoID;
                }
                formSelector = string.Format("#{0}", this.Page.Form.ClientID);
            }
            else
            {
                throw new NotSupportedException("You must either have a server form or specify FormSelector");
            }
            writer.WriteLine("$('{0}').validate({1});", formSelector, validateOptions.ToJson());
        }
        #endregion

    }
}

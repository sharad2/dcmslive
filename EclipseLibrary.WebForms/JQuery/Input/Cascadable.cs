using System;
using System.ComponentModel;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Scripts;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Sets up cascading relationship between two <see cref="InputControlBase"/> derived controls
    /// </summary>
    /// <remarks>
    /// <para>
    /// If <see cref="WebMethod"/> is not specified, all Cascade properties are ignored.
    /// </para>
    /// See <a href="32370cb5-7504-45ad-9c91-7c79c958c718.htm#Cascading">Cascading Input Controls</a> for an overview and a full working example.
    /// </remarks>
    public class CascadableHelper
    {
        /// <summary>
        /// Gets the Id of the parent on whose value we depend on.
        /// </summary>
        /// <value>The ID must be of a control which is derived from <see cref="InputControlBase"/></value>
        [Browsable(true)]
        [IDReferenceProperty(typeof(InputControlBase))]
        public string CascadeParentId { get; set; }

        /// <summary>
        /// The web method to call to update the value of the input control.
        /// </summary>
        /// <include file='Cascadable.xml' path='Cascadable/doc[@name="WebMethod"]/*'/>
        [Browsable(true)]
        [Themeable(true)]
        public string WebMethod { get; set; }

        /// <summary>
        /// The path to the web service which hosts the web method. If not specified, controls should default to the page path.
        /// </summary>
        [Browsable(true)]
        [UrlProperty("*.asmx")]
        [Themeable(true)]
        public string WebServicePath { get; set; }

        /// <summary>
        /// Whether the web method should be invoked when the document first loads. By default, it is only invoked
        /// when the value of the parent changes.
        /// </summary>
        /// <remarks>
        /// After the page has been posted back, this value is ignored.
        /// </remarks>
        public bool InitializeAtStartup { get; set; }

        internal void CreateCascadeScripts(InputControlBase ctlPassed)
        {
            if (string.IsNullOrEmpty(this.WebMethod))
            {
                // We are not cascadable. Nothing to do.
                return;
            }
            string loadData = ctlPassed.GetClientCode(ClientCodeType.LoadData);

            // If there is no way to load data, then we are not cascadable even if web method has been specified.
            // AutoComplete provides its own implementation for cascadable properties
            if (string.IsNullOrEmpty(loadData))
            {
                return;
            }
            string str;
            // JSON stringifies data passed to the web method
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.Json | ScriptTypes.Core | ScriptTypes.Cascade);
            JQueryOptions options = new JQueryOptions();
            if (!string.IsNullOrEmpty(this.CascadeParentId))
            {
                InputControlBase ctlParent = (InputControlBase)ctlPassed.NamingContainer.FindControl(this.CascadeParentId);
                if (ctlParent == null)
                {
                    str = string.Format("Could not find cascade parent {0}", this.CascadeParentId);
                    throw new InvalidOperationException(str);
                }
                options.Add("parentChangeEventName", ctlParent.ClientChangeEventName);
                options.AddRaw("parentValue", ctlParent.GetClientCode(ClientCodeType.GetValue));
                options.Add("cascadeParentSelector", ctlParent.ClientSelector);
                //ctlParent.ClientIdRequired = true;
            }
            if (string.IsNullOrEmpty(this.WebServicePath))
            {
                options.Add("webServicePath", ctlPassed.Page.Request.Path);
            }
            else
            {
                options.Add("webServicePath", ctlPassed.Page.ResolveUrl(this.WebServicePath));
            }
            options.Add("webMethodName", this.WebMethod);
            options.AddRaw("loadData", loadData);
            str = ctlPassed.GetClientCode(ClientCodeType.PreLoadData);
            if (!string.IsNullOrEmpty(str))
            {
                options.AddRaw("preLoadData", str);
            }
            options.Add("interestEvent", ctlPassed.GetClientCode(ClientCodeType.InterestEvent));
            //if (!ctlPassed.Page.IsPostBack && this.InitializeAtStartup)
            if (this.InitializeAtStartup)
            {
                options.Add("initializeAtStartup", this.InitializeAtStartup);
            }
            //if (this.HideParentsFromChildren)
            //{
            //    options.Add("hideParentsFromChildren", true);
            //}
            str = string.Format(".cascade({0})", options.ToJson());
            ctlPassed.ReadyScripts.Add(str);
        }
    }

}

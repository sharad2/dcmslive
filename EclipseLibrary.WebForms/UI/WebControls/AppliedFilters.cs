using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.Extensions;
using EclipseLibrary.Web.JQuery;
using EclipseLibrary.Web.JQuery.Input;
using EclipseLibrary.Web.JQuery.Scripts;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// You specify a container ID. This control queries all input controls within the container and displays 
    /// all non empty inputs.
    /// 
    /// Unchecked checked boxes are not considered as used.
    /// For drop down lists, Tooltip is used as friendly name.
    /// 
    /// For Theming, most important properties are Width and WidthLabel.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Sharad 23 Jul 2009: Recursively checking controls as late as possible to allow developers to change properties
    /// dynamically.
    /// </para>
    /// <para>
    /// Sharad 26 Nov 2010: Added property <see cref="DisplayEmptyValues"/> which controls whether drop down lists
    /// display <c>All</c> or something similar when the selected value is empty.
    /// </para>
    /// </remarks>
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class AppliedFilters : WidgetBase
    {
        /// <summary>
        /// 
        /// </summary>
        public AppliedFilters(): base("appliedFilters")
        {

        }

        /// <summary>
        /// The ID of the container within which all filters are contained
        /// </summary>
        /// <value>Required unless you specify the <see cref="Container"/> property</value>
        [Browsable(true)]
        [IDReferencePropertyAttribute(typeof(Control))]
        public string ContainerId { get; set; }

        /// <summary>
        /// If you cannot specify the ContainerId due to naming container issues, you can set the
        /// container control here through your code
        /// </summary>
        [Browsable(false)]
        public Control Container { get; set; }


        /// <summary>
        /// Width of the label displayed before the value
        /// </summary>
        /// 
        [Browsable(true)]
        [Themeable(true)]
        [DefaultValue("")]
        public Unit WidthLabel { get; set; }

        /// <summary>
        /// Normally the filters are displayed only when both <see cref="IFilterInput.QueryStringValue"/>
        /// and <see cref="IFilterInput.DisplayValue"/> are non empty. Setting this to true displays the filter
        /// if any of the two values are non empty.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Inputs whose <see cref="IFilterInput.FilterDisabled"/> is false are never displayed.
        /// This property is themable because most likely you will apply this globally to your project via a theme.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Themeable(true)]
        [DefaultValue(false)]
        public bool DisplayEmptyValues { get; set; }

        /// <summary>
        /// Returns an empty collection
        /// </summary>
        /// <returns></returns>
        protected override ControlCollection CreateControlCollection()
        {
            return new EmptyControlCollection(this);
        }

        private class FilterItem
        {
            public FilterItem()
            {

            }
            public FilterItem(IFilterInput info)
            {
                FriendlyName = info.FriendlyName;
                QueryString = info.QueryString;
                DisplayValue = info.DisplayValue;
                QueryStringValue = info.QueryStringValue;
            }

            public string QueryStringValue { get; set; }
            public string FriendlyName
            {
                get;
                set;
            }

            public string QueryString
            {
                get;
                set;
            }

            public string DisplayValue
            {
                get;
                set;
            }

            public bool Visible { get; set; }

        }



        List<FilterItem> _usedParams;

        private void EnsureFilterList()
        {
            if (_usedParams != null)
            {
                return;
            }
            _usedParams = new List<FilterItem>();

            if (this.Container == null)
            {
                this.Container = this.NamingContainer.FindControl(this.ContainerId);
            }
            if (this.Container == null)
            {
                string str = string.Format("Container with ID {0} not found", this.ContainerId);
                throw new HttpException(str);
            }

            foreach (Control ctl in this.Container.Descendants())
            {
                FilterItem infoItem;
                IFilterInput info = ctl as IFilterInput;
                if (info != null)
                {
                    // Common case. All our custom controls should implement this interface
                    if (!info.FilterDisabled)
                    {
                        infoItem = new FilterItem(info);
                        infoItem.Visible = ctl.Visible;
                        _usedParams.Add(infoItem);
                    }
                }
                else if (ctl is CheckBoxList)
                {
                    CheckBoxList cbList = (CheckBoxList)ctl;
                    List<string> values = new List<string>();
                    foreach (ListItem item in cbList.Items)
                    {
                        if (item.Selected)
                        {
                            values.Add(item.Text);
                        }
                    }
                    if (values.Count > 0)
                    {
                        infoItem = new FilterItem();
                        infoItem.FriendlyName = cbList.ToolTip;
                        infoItem.DisplayValue = string.Join(", ", values.ToArray());
                        infoItem.QueryStringValue = infoItem.DisplayValue;
                    }
                }
                else if (ctl is ListControl)
                {
                    // DropDownList, RadioButtonList
                    ListControl ddl = (ListControl)ctl;
                    infoItem = new FilterItem();
                    infoItem.FriendlyName = ddl.ToolTip;
                    infoItem.DisplayValue = ddl.SelectedItem.Text;
                    infoItem.QueryStringValue = ddl.SelectedItem.Value;
                    _usedParams.Add(infoItem);
                }
                else if (ctl is CheckBox)
                {
                    CheckBox cb = (CheckBox)ctl;
                    if (cb.Checked)
                    {
                        infoItem = new FilterItem();
                        infoItem.FriendlyName = cb.Text;
                        infoItem.DisplayValue = "Checked";
                        infoItem.QueryStringValue = "true";
                        _usedParams.Add(infoItem);
                    }
                }
            }
        }

        /// <summary>
        /// Adds JQuery UI theming classes
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            base.AddAttributesToRender(attributes, cssClasses);
            cssClasses.Add("ui-widget");
            cssClasses.Add("ecl-appliedfilters");
        }

        /// <summary>
        /// <div class="ui-widget ecl-appliedfilters">
        ///    <div class="ui-widget-header">
        ///    Applied Filters
        ///    </div>
        ///    <div class="ui-widget-content">
        ///      <table>
        ///        <tr>
        ///          <td>Friendly Name</td>
        ///          <td>Value</td>
        ///        </tr>
        ///        ...
        ///      </table>
        ///    </div>
        /// </div>
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            EnsureFilterList();
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-widget-header");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.Write("Applied Filters");
            writer.RenderEndTag();      // div
            writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-widget-content");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.RenderBeginTag(HtmlTextWriterTag.Em);
            // Need to show seconds along with time
            writer.Write("Query executed on {0:F}", DateTime.Now);
            writer.RenderEndTag();

            //Only controls that have either the display value or having some querystring value 
            //will be considered to be displayed.
            FilterItem[] filterItems;
            if (this.DisplayEmptyValues)
            {
                filterItems = (from p in _usedParams
                               where !string.IsNullOrEmpty(p.DisplayValue) || !string.IsNullOrEmpty(p.QueryStringValue)
                               select p).ToArray();
            }
            else
            {
                filterItems = (from p in _usedParams
                               where !string.IsNullOrEmpty(p.DisplayValue) && !string.IsNullOrEmpty(p.QueryStringValue)
                               select p).ToArray();
            }

            if (filterItems.Length > 0)
            {
                writer.RenderBeginTag(HtmlTextWriterTag.Table);
                writer.RenderBeginTag(HtmlTextWriterTag.Tbody);
                // Render a filter in Applied Filters if either query string or Display value is available
                foreach (FilterItem li in filterItems)
                {
                    writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                    if (this.WidthLabel != Unit.Empty)
                    {
                        writer.AddStyleAttribute(HtmlTextWriterStyle.Width, WidthLabel.ToString());
                    }
                    writer.RenderBeginTag(HtmlTextWriterTag.Td);
                    if (string.IsNullOrEmpty(li.FriendlyName))
                    {
                        writer.AddAttribute(HtmlTextWriterAttribute.Colspan, "2");
                        writer.Write(li.DisplayValue);
                    }
                    else
                    {
                        writer.Write(li.FriendlyName);
                        writer.RenderEndTag();      //td
                        writer.RenderBeginTag(HtmlTextWriterTag.Td);
                        writer.Write(li.DisplayValue);
                    }
                    writer.RenderEndTag();      //td
                    writer.RenderEndTag();      // tr
                }
                writer.RenderEndTag();      // tbody
                writer.RenderEndTag();      // table
            }
            else
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ecl-appliedfilters_nofilters");
                writer.RenderBeginTag(HtmlTextWriterTag.Div);
                writer.Write("No filters applied");
                writer.RenderEndTag();
            }
            writer.RenderEndTag();      //div
        }

        /// <summary>
        /// Returns DIV
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Div;
            }
        }

        /// <summary>
        /// Returns all the used filters in query string format, e.g. po_id=3&amp;pickslip_id=2345.
        /// The values are available only after LoadComplete. Most commonly you will use this in PreRender.
        /// </summary>
        /// <returns></returns>
        public string AsQueryString()
        {
            EnsureFilterList();
            string[] values = (from FilterItem info in _usedParams
                               where !string.IsNullOrEmpty(info.QueryString) && !string.IsNullOrEmpty(info.QueryStringValue)
                               select
                                   string.Format("{0}={1}", info.QueryString, info.QueryStringValue)).ToArray();
            string str = string.Join("&", values);
            return str;
        }

        /// <summary>
        /// Adds the filters as query string to the passed URL. If the url already contains some query string parameters,
        /// then duplicated values are not added.
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        /// <remarks>
        /// Example url: myreport?param1=val1&amp;param2=val2
        /// </remarks>
        public string AddQueryString(string url)
        {
            EnsureFilterList();
            // tokens[0] = myreport
            // tokens[1] = param1=val1&param2=val2
            string[] tokens = url.Split('?');

            // Will eventally contain two elements: param1=val1 and param2=val2
            string[] curValues;
            // Will eventally contain two elements: param1 and param1
            string[] queryStringTokens;
            if (tokens.Length > 1)
            {
                curValues = tokens[1].Split(new char[] { '&' }, StringSplitOptions.RemoveEmptyEntries);
                queryStringTokens = (from curvalue in curValues
                                     let i = curvalue.IndexOf('=')
                                     select curvalue.Substring(0, i)).ToArray();
            }
            else
            {
                curValues = queryStringTokens = new string[0];
            }

            string[] values = (from FilterItem info in _usedParams
                               where !string.IsNullOrEmpty(info.QueryString) &&
                                    !string.IsNullOrEmpty(info.QueryStringValue) &&
                                    (tokens.Length < 2 || !queryStringTokens.Contains(info.QueryString))
                               select
                                    string.Format("{0}={1}", info.QueryString, info.QueryStringValue)).ToArray();
            if (values.Length > 0)
            {
                curValues = curValues.Concat(values).ToArray();
            }
            string str = tokens[0] + "?" + string.Join("&", curValues);
            return str;
        }

        /// <summary>
        /// Pass options to the client widget
        /// </summary>
        protected override void PreCreateScripts()
        {
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.UiCore);
            EnsureFilterList();
            JQueryOptions options = new JQueryOptions();
            foreach (var ctl in _usedParams.Where(p => !string.IsNullOrEmpty(p.QueryString) &&
                !string.IsNullOrEmpty(p.QueryStringValue)))
            {
                options.Add(ctl.QueryString, ctl.QueryStringValue);
            }
            this.ClientOptions.Add("filters", options);
            //string script = string.Format("$('{0} #{1}').appliedFilters({{ filters: {2} }});",
            //    JQueryScriptManager.Current.OutermostContainer, this.ClientID, options);
            //JQueryScriptManager.Current.RegisterScriptBlock("AppliedFiltersScripts", Properties.Resources.AppliedFiltersScripts);
        }
    }
}

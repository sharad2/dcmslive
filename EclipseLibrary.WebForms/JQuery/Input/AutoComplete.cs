using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Provides auto complete suggestions for values the user types in a textbox
    /// </summary>
    /// <remarks>
    /// <para>
    /// When number of possible values
    /// exceed 50 or so, it becomes impractical to display all of them at the same time. <see cref="AutoComplete"/> fetches
    /// the choices dynamically by calling <see cref="CascadableHelper.WebMethod"/>.
    /// </para>
    /// <para>
    /// At the minimum you must specify <see cref="WebMethod"/> property of <see cref="AutoComplete"/>.
    /// The web method takes two parameters <c>term</c> and <c>id</c> where <c>term</c> represents the input entered by the user and the 
    /// <c>id</c> will be used when the control attempts to populate its value from <see cref="InputControlBase.QueryString"/>. For more
    /// information on this scenario see <see cref="SetValueFromQueryString"/>.
    /// It must return an array of <see cref="AutoCompleteItem"/> or a single <see cref="AutoCompleteData"/> object.
    /// The <see cref="AutoCompleteItem.Text"/> is displayed in the input control and is accessible
    /// via the <see cref="Text"/> property after postback.
    /// The <see cref="AutoCompleteItem.Value"/> is stored in a hidden field and is accessible via the <see cref="Value"/>
    /// property after postback.
    /// </para>
    /// <code lang="C#">
    /// <![CDATA[
    ///[WebMethod]
    ///public static AutoCompleteItem[] GetEmployees(string term, string id)
    ///{
    ///    AutoCompleteItem[] ret;
    ///    ...
    ///    return ret;
    ///}
    /// ]]>
    /// </code>
    /// <para>
    /// <see cref="MinLength"/> and <see cref="Delay"/> properties control how aggressively the list will pop up.
    /// </para>
    /// <para>
    /// If the web method returns exactly one value, then that value is automatically selected and the list is not displayed.
    /// This speeds up data entry when the user knows the id or code of the value he is looking for. Therefore it is a best practice
    /// to return only a single value if the unique identifier of your item has been entered. As an example, you have an item with
    /// unique code 40 and you have several items whose description contains 40. The ideal web method will return only a single
    /// item whose code is 40 and not return any of the other matches.
    /// </para>
    /// <para>
    /// A down arrow is displayed immediately after the text box to indicate that auto completion list is available.
    /// You can set <see cref="ShowUiHint"/> to false to suppress this down arrow as well as the required hint
    /// and display your own image.
    /// </para>
    /// <para>
    /// The tool tip of the text box always displays the value of the text chosen by the user.
    /// This helps when the chosen text is too long
    /// to fit in the visible area of the text box. For this reason, what you specify in <see cref="InputControlBase.ToolTip"/> property
    /// becomes the tool tip of the down arrow which displays after the text box. Note that if you set <see cref="ShowUiHint"/> to false,
    /// then the tooltip will not be visible.
    /// </para>
    /// <list type="table">
    /// <listheader>
    /// <term>Topic</term>
    /// <description>Location</description>
    /// </listheader>
    /// <item>
    /// <term>How to pass custom parameters to <see cref="CascadableHelper.WebMethod"/></term>
    /// <description> <see cref="OnClientSearch"/></description>
    /// </item>
    /// <item>
    /// <term>
    /// How to receive value passed via query string
    /// </term>
    /// <description><see cref="SetValueFromQueryString"/></description>
    /// </item>
    /// <item>
    /// <term>
    /// Enhancing UI by supporting <see cref="AutoCompleteItem.Relevance"/>
    /// </term>
    /// <description><see cref="AutoCompleteData"/></description>
    /// </item>
    /// <item>
    /// <term>Preventing validation failure when the user types the text instead of selecting it from the menu</term>
    /// <description><see cref="AutoValidate"/></description>
    /// </item>
    /// <item>
    /// <term>
    /// Displaying custom text in the textbox after a value is chosen from the menu
    /// </term>
    /// <description>
    /// <see cref="OnClientSelect"/>
    /// </description>
    /// </item>
    /// <item>
    /// <term>
    /// Accessing selected value from client script.
    /// </term>
    /// <description>
    /// <see cref="Value"/>
    /// </description>
    /// </item>
    /// <item>
    /// <term>
    /// Ensuring that the user enters valid values
    /// </term>
    /// <description>
    /// <see cref="AutoValidate"/>
    /// </description>
    /// </item>
    /// </list>
    /// <para>
    /// To open the autocompletion list at any time, simply double click the text box. This mimics the browser's autocomplete behavior.
    /// </para>
    /// <para>
    /// 26 Nov 2010: When value is received via query string, the applied filters display is updated from client script.
    /// See <see cref="SetValueFromQueryString"/>.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// This example provides a text box in which the user can enter an employee name.
    /// Auto complete suggestions are provided based on the partial name entered by the user.
    /// The markup needed is very simple and is shown below.
    /// </para>
    /// <code lang="XML">
    /// <![CDATA[
    ///    <i:AutoComplete runat="server" ID="tbEmployee" ClientIdSameAsId="true" FriendlyName="Employee">
    ///        <Cascadable WebMethod="GetEmployees"  />
    ///    </i:AutoComplete>
    /// ]]>
    /// </code>
    /// <para>
    /// This is the web method which is responsible for returning the names of matching employees. It will never return
    /// more than 20 matches.
    /// </para>
    /// <code lang="C#">
    /// <![CDATA[
    ///      [WebMethod]
    ///      public object[] GetEmployees(string term, string id)
    ///      {
    ///          int employeeId = string.IsNullOrEmpty(id) ? 0 : Convert.ToInt32(id);
    ///          using (ReportingDataContext db = new ReportingDataContext(ReportingUtilities.DefaultConnectString))
    ///          {
    ///              return (from emp in db.RoEmployees
    ///                      let text = emp.EmployeeCode + ": " + emp.FirstName + " " + emp.LastName
    ///                      where ((emp.EmployeeCode == term || text.Contains(term)) ||emp.EmployeeId == employeeId )
    ///                      orderby emp.FirstName, emp.LastName
    ///                      let relevance = emp.EmployeeId == employeeId ? -10 : emp.EmployeeCode == term ? -10 : 0
    ///                      select new AutoCompleteItem()
    ///                      {
    ///                          Relevance = relevance,
    ///                          Text = text,
    ///                          Value = emp.EmployeeId.ToString()
    ///                      }).Take(20).ToArray();
    ///          }
    ///      }
    /// ]]>
    /// </code>
    /// </example>
    public class AutoComplete : InputControlBase
    {
        public AutoComplete()
            : base("autocompleteEx")
        {
            //this.ClientIdRequired = true;
            this.ShowUiHint = true;
            this.Value = string.Empty;
        }

        /// <summary>
        /// The text which is displaying in the the text box
        /// </summary>
        /// <remarks>
        /// <para>
        /// After postback, this contains the text entered by the user in the text box. At initial load this is empty unless you set
        /// it through markup or programmatically.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Themeable(false)]
        public string Text { get; set; }

        /// <summary>
        /// Triggered when an item is selected from the menu; ui.item refers to the selected item.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The default action of select is to replace the text field's value with the value of the selected item.
        /// Canceling this event prevents the value from being updated, but does not prevent the menu from closing.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// You will normally handle this event to show custom text in the text box and to set a custom value.
        /// The following code snippet shows the proper way to do this. You must use the <c>select</c> method to set the
        /// text and value. This ensures that the default select handler will not overwrite your value.
        /// </para>
        /// <code lang="js">
        /// <![CDATA[
        ///function tbUpc_Select(event, ui) {
        ///    $(this).autocompleteEx('select', ui.item.Value, ui.item.Detail);
        ///    return false;
        ///}
        /// ]]>
        /// </code>
        /// </example>
        public string OnClientSelect
        {
            get
            {
                return this.ClientEvents["autocompleteselect"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["autocompleteselect"] = value;
            }
        }

        /// <summary>
        /// Triggered when the suggestion menu is opened.
        /// </summary>
        public string OnClientOpen
        {
            get
            {
                return this.ClientEvents["autocompleteopen"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["autocompleteopen"] = value;
            }
        }

        /// <summary>
        /// Whether the web service should be invoked to validate the value if the user does not select the value from the list
        /// </summary>
        /// <remarks>
        /// <para>
        /// If the user types a value in the textbox and then tabs away, normally the value is not modified. However if you want
        /// to ensure that the entered value is valid, then you can set this property to true. When this property is true,
        /// <see cref="ValidateWebMethodName"/> must also be specified.
        /// </para>
        /// <para>
        /// When AutoValidate is true, then javascript code is associated with the <c>change</c> event to check
        /// whether the value was chosen from the menu. If not,
        /// then it invokes the <see cref="ValidateWebMethodName"/> web method and passes it the value entered in the text box. This web method
        /// should either return null, or a single item. If null is returned then the control flashes for some time and is thencleared.
        /// Otherwise it displays the text in the text box and stores the value in the hidden field.
        /// </para>
        /// <para>
        /// You can also manually cause validation as shown in the example. Do not confuse this kind of validation with the
        /// validation framework.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// The following code is executed when the user leaves the textbox. It first ensures that the value entered
        /// by the user is valid by calling <c>validate</c>. If it is valid, then it displays text and value
        /// in <c>$tbUpcCode</c> and <c>$('#spanSku')</c>. Otherwise it displays an error in <c>$('#spanErrorMessage')</c>.
        /// The error message includes the bad UPC entered by the user.
        /// </para>
        /// <para>
        /// Setting <see cref="AutoValidate"/> to true would have provided similar behavior, except that you would not have
        /// had the opportunity to show values in the other controls.
        /// </para>
        /// <code lang="js">
        /// <![CDATA[
        /// var badUpc = $(this).autocompleteEx('validate');
        /// var upc = $(this).autocompleteEx('selectedValue');                
        /// if (upc) {
        ///    // Valid value
        ///    $tbUpcCode.val(upc);
        ///    $('#spanSku').html($(this).val());
        /// } else {
        ///    // Invalid value
        ///    $('#spanErrorMessage').text($.validator.format('Invalid UPC: {0}', badUpc));
        ///    PlaySound('CriticalStop.wav', this);
        ///    return;          }
        /// }
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [DefaultValue(false)]
        public bool AutoValidate
        {
            get
            {
                return this.ClientOptions.Get("autoValidate", false);
            }
            set
            {
                this.ClientOptions.Set("autoValidate", value, false);
            }
        }

        /// <summary>
        /// The web method to call when user input needs to be validated.
        /// </summary>
        /// <remarks>
        /// <para>
        /// It must be specified if you are expecting to receive a value from a cookie or query string,
        /// i.e. <see cref="InputControlBase.QueryString"/> has been specified.
        /// The web method is passed a single parameter <c>term</c>. It must return a single <see cref="AutoCompleteItem"/> if item
        /// is found, otherwise it should return null. 
        /// </para>
        /// <para>
        /// You can set or get this through client script like so: <c>$(this).autocompleteEx('option', 'validateWebMethodName' [,value])</c>.
        /// </para>
        /// </remarks>
        /// <example>
        /// <code>
        /// <![CDATA[
        /// [WebMethod]
        /// public AutoCompleteItem ValidateUpc(string term)
        /// {
        ///     if (string.IsNullOrEmpty(id))
        ///     {
        ///         return null;
        ///     }
        ///     ...
        /// ]]>
        /// </code>
        /// </example>
        public string ValidateWebMethodName
        {
            get
            {
                return this.ClientOptions.Get<string>("validateWebMethodName", "");
            }
            set
            {
                this.ClientOptions.Set("validateWebMethodName", value, "");
            }
        }

        /// <summary>
        /// Before a request (source-option) is started, after minLength and delay are met.
        /// Can be canceled (return false), then no request will be started and no items suggested.
        /// </summary>
        /// <remarks>
        /// <para>
        /// If you want to pass custom parameters to your auto complete web method, this is your chance to do it.
        /// You can also cancel the web method call if proper conditions are not met.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// We want to display the job list only if a division has been selected. The listed jobs should belong to the selected division.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<i:DropDownListEx runat="server" ID="ddlDivisionCode" DataSourceID="dsDivisions"
        ///    DataTextField="DivisionName" DataValueField="DivisionId" DataOptionGroupField="DivisionGroup"
        ///    ClientIdSameAsId="true">
        ///    <Items>
        ///        <eclipse:DropDownItem Text="(Not Set)" Persistent="Always" />
        ///    </Items>
        ///</i:DropDownListEx>
        ///...
        ///<i:AutoComplete ID="tbJob" runat="server" FriendlyName="Job" 
        ///     OnClientSearch="tbJob_Search">
        ///    <Cascadable WebMethod="GetJobs" WebServicePath="~/Services/Contractors.asmx" />
        ///</i:AutoComplete>
        /// ]]>
        /// </code>
        /// <para>
        /// We hook to the search event and cancel the list display if division is not set. If division is set, then we pass it as
        /// a paramter to the web method.
        /// </para>
        /// <code lang="javascript">
        /// <![CDATA[
        ///function tbJob_Search(event, ui) {
        ///    var divisionId = $('#ddlDivisionCode').val();
        ///    if (!divisionId) {
        ///        alert('Please select division first');
        ///        return false;
        ///    }
        ///    $(this).autocompleteEx('option', 'parameters', { divisionId: divisionId, term: $(this).val() });
        ///    return true;
        ///}
        /// ]]>
        /// </code>
        /// <para>
        /// And here is the web method which returns jobs of the selected division.
        /// </para>
        /// <code lang="C#">
        /// <![CDATA[
        ///[WebMethod]
        ///public DropDownItem[] GetJobs(string term, int divisionId)
        ///{
        ///    var query = (from j in _db.RoJobs
        ///                    let text = j.JobCode + ": " + j.Description + " (" + j.RoContractor.ContractorName + ")"
        ///                    where j.DivisionId == divisionId && (text.Contains(term) ||
        ///                        j.JobCode == term ||
        ///                        j.RoContractor.ContractorName.Contains(term))
        ///                    orderby j.JobCode
        ///                    select new DropDownItem()
        ///                    {
        ///                        Text = text,
        ///                        Value = j.JobId.ToString()
        ///                    }
        ///                    ).Take(20).ToArray();
        ///    return query;
        ///}
        /// ]]>
        /// </code>
        /// </example>
        public string OnClientSearch
        {
            get
            {
                return this.ClientEvents["autocompletesearch"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["autocompletesearch"] = value;
            }
        }

        [Browsable(true)]
        public string OnClientKeyPress
        {
            get
            {
                return this.ClientEvents["keypress"] ?? string.Empty;
            }
            set
            {
                this.ClientEvents["keypress"] = value;
            }
        }

        public override string ClientChangeEventName
        {
            get
            {
                return "autocompletechange";
            }
        }

        /// <summary>
        /// Auto complete list will be shown after the user pauses for these many milliseconds.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Default is 4000, which means taht the list will be displayed after a 4 sec pause.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(4000)]
        public int Delay
        {
            get
            {
                return this.ClientOptions.Get<int>("delay", 4000);
            }
            set
            {
                this.ClientOptions.Set("delay", value, 4000);
            }
        }

        /// <summary>
        /// The minimum number of characters a user has to type before the Autocomplete activates
        /// </summary>
        /// <remarks>
        /// <para>
        /// Zero is useful for local data with just a few items.
        /// Should be increased when there are a lot of items,
        /// where a single character would match a few thousand items.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Themeable(false)]
        [DefaultValue(1)]
        public int MinLength
        {
            get
            {
                return this.ClientOptions.Get<int>("minLength", 1);
            }
            set
            {
                this.ClientOptions.Set("minLength", value, 1);
            }

        }

        /// <summary>
        /// The value corresponding to the text being displayed
        /// </summary>
        /// <remarks>
        /// <para>
        /// To access this value from client script, write code like <c>var x = $('#ac').autocompleteEx('selectedValue')</c>.
        /// Note that this can be null if the user did not choose an entry from the menu. To explicitly call the web method and get the value,
        /// the following code is recommended.
        /// </para>
        /// <code lang="js">
        /// <![CDATA[
        /// var upc = $(this).autocompleteEx('selectedValue');
        /// if (!upc) {
        ///     // Call validate only if value was not chosen from menu
        ///     var item = $(this).autocompleteEx('validate');
        ///     if (item == null) {
        ///         // The text entered in the 
        ///     } else if (typeof item === 'string') {
        ///         // Ajax Error. 
        ///         alert(item);
        ///     } else {
        ///         // item represents the AutoCompleteItem object returned by the web method
        ///     }
        /// }
        /// ]]>
        /// </code>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("")]
        public override string Value
        {
            get;
            set;
        }

        /// <summary>
        /// Whether a down arrow should be displayed to indicate that this is an auto complete text box
        /// </summary>
        /// <remarks>
        /// <para>
        /// You may want to set this to false if you are displaying your own UI hint. This also suppresses the * which is
        /// displayed if a required validator is attached.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool ShowUiHint { get; set; }

        /// <summary>
        /// The web method to call to update the value of the input control.
        /// </summary>
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
        /// Simply performs sanity checking
        /// </summary>
        /// <exception cref="HttpException">Cascadable.WebMethod must be specified</exception>
        protected override void PreCreateScripts()
        {
            if (!string.IsNullOrEmpty(this.WebMethod))
            {
                // It is possible to set this option through script
                this.ClientOptions.Add("webMethodName", this.WebMethod);
            }

            if (string.IsNullOrEmpty(this.WebServicePath))
            {
                // Use page path
                this.ClientOptions.Add("webServicePath", this.Page.Request.Path);
            }
            else
            {
                this.ClientOptions.Add("webServicePath", this.ResolveUrl(this.WebServicePath));
            }
            if (!string.IsNullOrEmpty(this.Text))
            {
                this.ClientOptions.Add("_validText", this.Text);
            }
            base.PreCreateScripts();
        }

        /// <summary>
        /// Renders a hidden field just before the input text box. This hidden field is used to postback the
        /// <see cref="Value"/>.
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            if (this.ShowUiHint)
            {
                writer.AddStyleAttribute(HtmlTextWriterStyle.WhiteSpace, "nowrap");
                writer.RenderBeginTag(HtmlTextWriterTag.Span);  // Span 1
            }
            writer.AddAttribute(HtmlTextWriterAttribute.Id, this.ClientID + "_hf");
            writer.AddAttribute(HtmlTextWriterAttribute.Value, this.Value);
            writer.AddAttribute(HtmlTextWriterAttribute.Type, "hidden");
            writer.AddAttribute(HtmlTextWriterAttribute.Name, this.UniqueID + "$hf");
            writer.RenderBeginTag(HtmlTextWriterTag.Input);
            writer.RenderEndTag();          // Input
            base.Render(writer);

            if (this.ShowUiHint)
            {
                if (!string.IsNullOrEmpty(this.ToolTip))
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Title, this.ToolTip);
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Span);   // Span 2
                writer.Write("&darr;");
                writer.RenderEndTag();          // Span 2
                writer.RenderEndTag();          // Span 1
                if (this.Validators.OfType<Required>().Any(p=>p.DependsOnState == DependsOnState.NotSet))
                {
                    writer.RenderBeginTag(HtmlTextWriterTag.Sup);
                    writer.Write("*");
                    writer.RenderEndTag();
                }
            }


        }

        /// <summary>
        /// If the <see cref="Value"/> is valid, then associates the <c>ac-valid</c> class with the text box
        /// which displays the text underlined.
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        /// <remarks>
        /// <para>
        /// Since the <see cref="Text"/> can be often long, it also set at the tooltip of the text box
        /// </para>
        /// </remarks>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            base.AddAttributesToRender(attributes, cssClasses);
            attributes.Add(HtmlTextWriterAttribute.Value, this.Text);
            // The tool tip may already be set but we don't need it.
            attributes[HtmlTextWriterAttribute.Title] = this.Text;
            attributes.Add(HtmlTextWriterAttribute.AutoComplete, "off");    // Disable browser autocomplete
            if (!string.IsNullOrEmpty(this.Value) && !string.IsNullOrEmpty(this.Text))
            {
                cssClasses.Add("ac-valid");
            }
        }

        /// <summary>
        /// Minimum implementation to support <c>Cascadable</c>
        /// </summary>
        /// <param name="codeType"></param>
        /// <returns></returns>
        internal override string GetClientCode(ClientCodeType codeType)
        {
            switch (codeType)
            {
                case ClientCodeType.InterestEvent:
                    return "keypress";

                case ClientCodeType.PreLoadData:
                    break;

                case ClientCodeType.LoadData:
                    return string.Empty;

                case ClientCodeType.GetValue:
                    return "function() { return $(this).autocompleteEx('selectedValue'); }";

                case ClientCodeType.SetValue:
                    break;
                case ClientCodeType.MinLengthErrorMessage:
                    break;
                case ClientCodeType.MaxLengthErrorMessage:
                    break;
                case ClientCodeType.InputSelector:
                    break;
                default:
                    break;
            }
            return base.GetClientCode(codeType);
        }

        /// <summary>
        /// Reads the post values
        /// </summary>
        /// <param name="postDataKey"></param>
        /// <param name="postCollection"></param>
        /// <returns></returns>
        /// <remarks>
        /// <para>
        /// If the user types too fast, then <see cref="Value"/> will be empty but the text box will still contain text.
        /// In this situation, we try to retrieve the value from the web service. If this is not possible, then no further action is
        /// taken.
        /// </para>
        /// </remarks>
        public override bool LoadPostData(string postDataKey, NameValueCollection postCollection)
        {
            this.Text = postCollection[postDataKey];
            this.Value = postCollection[postDataKey + "$hf"];
            return false;
        }

        public override void Validate()
        {
            base.Validate();
            if (this.AutoValidate && string.IsNullOrEmpty(this.Value) && !string.IsNullOrEmpty(this.Text))
            {
                this.IsValid = false;
                this.ErrorMessage = string.Format("{0} is not a valid value for {1}", this.Text, this.FriendlyName);
            }
        }


        /// <summary>
        /// Populates the textbox from the value passed in query string
        /// </summary>
        /// <param name="queryStringValue">The value passed via query string</param>
        /// <remarks>
        /// <para>
        /// If a value is passed in the query string specified by <see cref="InputControlBase.QueryString"/>,
        /// then it becomes the <see cref="Value"/> of the text box.
        /// </para>
        /// <para>
        /// A ready script gets associated with with the text box which calls the client side validate method to validate the
        /// value passed in query string. If the validate method fails, the query string value is discarded.
        /// Additionally, the script updates the <see cref="DisplayValue"/> in an associated label.
        /// </para>
        /// </remarks>
        protected override void SetValueFromQueryString(string queryStringValue)
        {
            base.SetValueFromQueryString(queryStringValue);

            // Validate the value on startup and also update the display value if it is showing any where
            this.ReadyScripts.Add(@".autocompleteEx('validate', function(item) {
$('label.ac-dv[for=' + this.id + ']').html($(this).val());
})");
        }

        /// <summary>
        /// Value displayed by <see cref="UI.AppliedFilters"/>
        /// </summary>
        /// <remarks>
        /// <para>
        /// The value is wrapped in a label so that it can be updated through client script. The <c>for</c>
        /// attribute of the label identifies the autocomplete whose value this label is displaying.
        /// <see cref="SetValueFromQueryString"/> takes advantage of this infrastructure.
        /// </para>
        /// </remarks>
        public override string DisplayValue
        {
            get
            {
                if (this.FilterDisabled)
                {
                    return string.Empty;
                }
                else
                {
                    if (string.IsNullOrEmpty(this.Text) && !string.IsNullOrEmpty(this.Value))
                    {
                        // Value was received from query string or cookie. Wrap in span to enable dynamic updation
                        return string.Format("<label for='{0}' class='ac-dv'>{1}</label>", this.ClientID, this.Text);
                    }
                    else
                    {
                        // Return the text as is. If we wrap the text here, APpliedFilters will wrongly conclude
                        // that the text is non empty and therefore potentially display an empty value.
                        return this.Text;
                    }
                }
            }
        }
    }
}

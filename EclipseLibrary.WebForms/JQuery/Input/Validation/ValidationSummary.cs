using System.Collections.Generic;
using System.ComponentModel;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// You can show custom error messages by adding them to CustomMessages
    /// Custom error messages are displayed just before the validation error messages.
    /// You can also show custom status messages. The status messages disappear whenever validation errors are displayed.
    /// </summary>
    /// 
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class ValidationSummary : WidgetBase
    {
        public ValidationSummary()
            : base(string.Empty)
        {

        }

        private List<string> _errorMessages;

        /// <summary>
        /// Added custom errors here to display them when the page loads
        /// </summary>
        [Browsable(false)]
        public IList<string> ErrorMessages
        {
            get
            {
                if (_errorMessages == null)
                {
                    _errorMessages = new List<string>();
                }
                return _errorMessages;
            }
        }

        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Ol;
            }
        }

        /// <summary>
        /// If there are no error messages to display, we hide the validation summary.
        /// It will become visible when client side validation takes place
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            base.AddAttributesToRender(attributes, cssClasses);
            // We always need our client ID in order for validation to work
            if (!attributes.ContainsKey(HtmlTextWriterAttribute.Id))
            {
                attributes.Add(HtmlTextWriterAttribute.Id, this.ClientID);
            }
            cssClasses.Add("ui-widget");
            cssClasses.Add("ui-state-error");
            if (_errorMessages == null || _errorMessages.Count == 0)
            {
                cssClasses.Add("ui-helper-hidden");
            }
            cssClasses.Add(JQueryScriptManager.CssClassValidationSummary);
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            if (_errorMessages != null)
            {
                foreach (string msg in _errorMessages)
                {
                    writer.RenderBeginTag(HtmlTextWriterTag.Li);
                    writer.Write(msg);
                    writer.RenderEndTag();
                }
            }

            base.RenderContents(writer);
        }

        protected override void PreCreateScripts()
        {

        }




    }
}

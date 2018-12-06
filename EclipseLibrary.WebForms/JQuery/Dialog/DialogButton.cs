using EclipseLibrary.Web.JQuery.Scripts;
using System.ComponentModel;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Abstract base class for all buttons in a dialog
    /// </summary>
    public abstract class DialogButton
    {
        /// <summary>
        /// 
        /// </summary>
        public DialogButton()
        {
            //this.Text = "Button";
        }

        //public string ID { get; set; }

        /// <summary>
        /// The text to display on the button
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// Adds the jquery options for this button to the passed <paramref name="buttonOptions"/>.
        /// </summary>
        /// <param name="containingDialog"></param>
        /// <param name="buttonOptions"></param>
        public void AddButtonOption(Dialog containingDialog, JQueryOptions buttonOptions)
        {
            string func = GetFunction(containingDialog);
            if (string.IsNullOrEmpty(this.Text))
            {
                this.Text = "Button";
            }
            buttonOptions.AddRaw(this.Text, func);
        }

        /// <summary>
        /// If true, the button will be clicked on enter key press
        /// </summary>
        public bool IsDefault { get; set; }

        /// <summary>
        /// Derived classes must return a jquery function which will be executed when the button is clicked.
        /// </summary>
        /// <param name="containingDialog"></param>
        /// <returns></returns>
        protected abstract string GetFunction(Dialog containingDialog);
    }

    /// <summary>
    /// Calls a user specified function
    /// </summary>
    public class ActionButton:DialogButton
    {
        /// <summary>
        /// The function to call when the button is clicked
        /// </summary>
        [Browsable(true)]
        public string OnClientClick { get; set; }

        /// <summary>
        /// Returns the function specified in <see cref="OnClientClick"/>
        /// </summary>
        /// <param name="containingDialog"></param>
        /// <returns></returns>
        protected override string GetFunction(Dialog containingDialog)
        {
            if (string.IsNullOrEmpty(this.OnClientClick))
            {
                //return new JQueryAnonymousFunction().ToString();
                return "function() {}";
            }
            else
            {
                return this.OnClientClick;
            }
            //return this.Function ?? new JQueryFunctionName(this.OnClientClick);
        }
    }

    /// <summary>
    /// Closes the dialog
    /// </summary>
    public class CloseButton : DialogButton
    {
        /// <summary>
        /// 
        /// </summary>
        public CloseButton()
        {
            this.Text = "Cancel";
        }

        /// <summary>
        /// Simply closes the dialog
        /// </summary>
        /// <param name="containingDialog">The dialog which will be closed</param>
        /// <returns>javascript</returns>
        protected override string GetFunction(Dialog containingDialog)
        {
            //return new JQueryAnonymousFunction("$(this).dialog('close');").ToString();
            return "function() { $(this).dialog('close'); return false;}";
        }
    }

    ///// <summary>
    ///// Reloads the Ajax contents
    ///// </summary>
    //public class AjaxRefreshButton : DialogButton
    //{
    //    /// <summary>
    //    /// 
    //    /// </summary>
    //    public AjaxRefreshButton()
    //    {
    //        this.Text = "Refresh";
    //    }

    //    protected override string GetFunction(Dialog containingDialog)
    //    {
    //        string script = "$(this).ajaxDialog('load');";
    //        return new JQueryAnonymousFunction(script).ToString();
    //    }
    //}
}


using System.ComponentModel;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Scripts;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Supply a Url which is supposed to return just a form designed to perform a single task.
    /// The form cannot have any buttons. After the form is filled, all values entered by the user are
    /// posted back to the form. The form must return status code 205 (reset content)
    /// to indicate that the action was successfully completed. Otherwise you should return the whole form again.
    /// </summary>
    public class AjaxDialogSettings
    {
        /// <summary>
        /// 
        /// </summary>
        public AjaxDialogSettings()
        {
            this.UseDialog = true;
            //this.AutoOpen = true;
            //this.CancelLoadOnEmptyValue = true;
        }

        /// <summary>
        /// The Url which will be loaded
        /// </summary>
        [Browsable(true)]
        [UrlProperty("*.aspx")]
        public string Url { get; set; }

        /// <summary>
        /// Set it to false to display the dialog inline. In this situation it will not have any title bar or buttons.
        /// </summary>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool UseDialog { get; set; }

        /// <summary>
        /// Whether it is permissible to cache the Ajax response
        /// </summary>
        [Browsable(true)]
        public bool Cache { get; set; }


        /// <summary>
        /// Function to call after the dialog has been automatically closed because status code was 205.
        /// </summary>
        /// <include file='Dialog.xml' path='Dialog/doc[@name="OnAjaxDialogClosing"]/*'/>
        public string OnAjaxDialogClosing { get; set; }

        /// <summary>
        /// Raised after the remote contents have been loaded.
        /// This is a good time to access the DOM of the loaded contents.
        /// </summary>
        /// <remarks>
        /// <para>
        /// When <see cref="Cache"/> is true, this event is raised even though the contents were loaded
        /// from the cache and not from the remote server. Using the ui argument in event handler you can
        /// distinguish whether the contents were actually loaded.
        /// </para>
        /// <code>
        /// <![CDATA[
        /// 
        /// <jquery:Dialog runat="server" ID="dlgAddPickslips" ClientIdSameAsId="true">
        ///    <Ajax UseDialog="false" Url="AddPickslipsToBucket.aspx"
        ///        Cache="true" OnAjaxDialogLoaded="ajaxDialog_Loaded" />
        /// </jquery:Dialog>
        /// 
        /// function ajaxDialog_Loaded(event, ui) {
        ///     if (!ui.cached) {         // ui.cached will be true if the contents were loaded from cache, false otherwise.
        ///         $('#dlgStatus').ajaxDialog('load');  
        ///     }
        /// }
        /// ]]>
        /// </code>
        /// <para>
        /// The above code will load a dialog <c>#dlgStatus</c> only when <c>#dlgAddPickslips</c> 
        /// gets loaded from the server and not from the cache. 
        /// </para>
        /// </remarks>
        public string OnAjaxDialogLoaded { get; set; }

        /// <summary>
        /// Raised just before the remote contents are initially loaded.
        /// Return false to cancel the load.
        /// </summary>
        /// <remarks>
        /// This is useful if you want to prevent the load because your user has not entered some data required
        /// by the remote page. It is also useful for supplying the query string to the called page
        /// as shown in the example. This example passes the value in textbox <c>tbEnCustomerPicker</c>
        /// as the value of query string <c>customer_list</c>.
        /// <code>
        /// <![CDATA[
        ///<jq:Dialog runat="server" ID="dlgEnCustomerPicker" Title="Select Customer" AutoOpen="false">
        ///    <Ajax Url="../Pages/EnhancedCustomerPicker.aspx" OnAjaxDialogLoading="function(e){
        ///        $(this).ajaxDialog('option', 'data', {customer_list: $('#tbEnCustomerPicker').textBoxEx('val')});
        ///    }" />
        ///</jq:Dialog>
        /// ]]>
        /// </code>
        /// </remarks>
        public string OnAjaxDialogLoading { get; set; }

        /// <summary>
        /// Raised just before the remote page is posted back. Return false to prevent the postback.
        /// </summary>
        /// <remarks>
        /// 
        /// </remarks>
        public string OnAjaxDialogSubmitting { get; set; }

        internal void UpdateStartupOptions(Dialog dlg, JQueryOptions options)
        {
            if (!string.IsNullOrEmpty(this.Url))
            {
                options.Add("url", dlg.ResolveUrl(this.Url));
            }
            if (this.Cache)
            {
                options.Add("cache", this.Cache);
            }

            if (!string.IsNullOrEmpty(this.OnAjaxDialogClosing))
            {
                options.AddRaw("closing", this.OnAjaxDialogClosing);
            }
            if (!string.IsNullOrEmpty(this.OnAjaxDialogLoaded))
            {
                options.AddRaw("loaded", this.OnAjaxDialogLoaded);
            }

            if (!string.IsNullOrEmpty(this.OnAjaxDialogSubmitting))
            {
                options.AddRaw("submitting", this.OnAjaxDialogSubmitting);
            }
            if (!string.IsNullOrEmpty(this.OnAjaxDialogLoading))
            {
                options.AddRaw("loading", this.OnAjaxDialogLoading);
            }
            if (!this.UseDialog)
            {
                options.Add("_useDialog", false);
            }

            if (dlg.DialogStyle == DialogStyle.Picker)
            {
                options.Add("autoClose", false);
            }

            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.Json);
        }

    }
}

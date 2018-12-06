using System.Web.UI;
using EclipseLibrary.Web.JQuery.Input;
using System;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Submits the remote page within the dialog by clicking a button within the remote page.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This button is very useful for picker style dialogs as shown in the example.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// This is a picker <see cref="Dialog"/> which is opened when a button is clicked.
    /// The Ok button of this dialog is a <c>RemoteButton</c> which submits the remote page
    /// after clicking the <c>#btn...</c> button. The picker is supposed to return a value when
    /// this button is clicked which is captured in the <see cref="AjaxDialogSettings.OnAjaxDialogClosing"/>
    /// event.
    /// </para>
    /// <code>
    /// <![CDATA[
    /// <jq:Dialog runat="server" ID="dlgEnCustomerPicker"  AutoOpen="false"
    ///     ClientIdSameAsId="true" Width="400">
    ///     <Ajax Url="../Pages/EnhancedCustomerPicker.aspx"  OnAjaxDialogClosing="function(event,ui){
    ///         $('#tbEnCustomerPicker').textBoxEx('setval', ui.data);
    ///  }"/>
    ///     <Buttons>
    ///     <jq:RemoteSubmitButton  RemoteButtonSelector="#btnEcpOk" Text="Ok" />
    ///     <jq:CloseButton Text="Cancel" />
    ///     </Buttons>
    /// </jq:Dialog>
    /// ]]>
    /// </code>
    /// </example>
    public class RemoteSubmitButton : DialogButton
    {
        /// <summary>
        /// The selector of the button within the remote page which will be clicked
        /// before the remote form is submitted. If the click handler of this button returns false,
        /// the remote form will not be submitted.
        /// </summary>
        /// <remarks>
        /// Providing a value for this property is optional. If no value is provided, 
        /// the form is submitted unconditionally.
        /// </remarks>
        public string RemoteButtonSelector { get; set; }

        /// <summary>
        /// Generate a functun which will trigger the click handler of the button.
        /// If the handler does not exist, or it returns true, the form will be submitted.
        /// </summary>
        /// <param name="containingDialog"></param>
        /// <returns></returns>
        protected override string GetFunction(Dialog containingDialog)
        {
            if (string.IsNullOrEmpty(this.RemoteButtonSelector))
            {
                throw new NotImplementedException();
            }
            else
            {
                return string.Format(@"
function(e) {{
    var $btn = $('{0}');
    var b = $btn.triggerHandler('click');
    if (b == undefined || b)
    {{
        $btn.closest('form').submit();
    }} 
}}", this.RemoteButtonSelector);
            }
        }
    }
}


namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Should be implemented by a container control which wishes to serve as a validation container
    /// </summary>
    /// <remarks>
    /// The control must generate client script to click the default button within the container whenever
    /// enter key is pressed.
    /// </remarks>
    public interface IValidationContainer
    {
        /// <summary>
        /// The control must add val-container as one of the Css classes when IsValidationContainer=true 
        /// </summary>
        bool IsValidationContainer { get; set; }
    }
}


using System;
using System.ComponentModel;
namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// The icon to display on the button
    /// </summary>
    public enum ButtonIconType
    {
        /// <summary>
        /// No icon will be displayed
        /// </summary>
        None,

        /// <summary>
        /// You specify the name in the property <see cref="ButtonEx.CustomIconName"/>
        /// </summary>
        Custom,

        /// <summary>
        /// Use for buttons which will refresh the page, such as Apply Filters
        /// </summary>
        Refresh,            // ui-icon-refresh

        /// <summary>
        /// Recommended for buttons which will reset the page to its intial state, such as Reset.
        /// </summary>
// ReSharper disable InconsistentNaming
        ArrowReturnThick_1_W,
// ReSharper restore InconsistentNaming

        /// <summary>
        /// Displays a printer icon. Use for buttons which will help in printing something
        /// </summary>
        Print,              // ui-icon-print

        /// <summary>
        /// Use for cancelling or reverting pickslips
        /// </summary>
        Cancel,

        /// <summary>
        /// Suitable for buttons which open up some kind of a picker dialog
        /// </summary>
        Search,             // ui-icon-search

        /// <summary>
        /// A button which will show more information such as Expand
        /// </summary>
        PlusThick,          // ui-icon-plusthick

        /// <summary>
        /// A button which will show less information such as collapse.
        /// </summary>
        MinusThick,         // ui-icon-minusthick

        /// <summary>
        /// Commonly used as a date picker trigger
        /// </summary>
        Calendar,           // ui-icon-calendar

        /// <summary>
        /// Buttons which will export the information to a different format such as PDF or Excel
        /// </summary>
// ReSharper disable InconsistentNaming
        TransferThick_E_W,
// ReSharper restore InconsistentNaming

        /// <summary>
        /// Displays an icon similar to a baloon style tooltip
        /// </summary>
        Comment,            // ui-icon-comment

        /// <summary>
        /// For buttons which will provide assistance in performing some task
        /// </summary>
        LightBulb,          // ui-icon-lightbulb

// ReSharper disable InconsistentNaming
        Folder_Open,
// ReSharper restore InconsistentNaming

// ReSharper disable InconsistentNaming
        Folder_Closed,
// ReSharper restore InconsistentNaming

        /// <summary>
        /// Ideal for a favorite link
        /// </summary>
        Heart,              //  ui-icon-heart

        /// <summary>
        /// Indicates that a link will open a new browser window
        /// </summary>
        NewWin,             // ui-icon-newwin

        /// <summary>
        /// Indicates that the button is associated with a hyperlink
        /// </summary>
        Link,               // ui-icon-link

        ExtLink,

        /// <summary>
        /// Use for recycle bin kind of a message
        /// </summary>
        Trash,               // ui-icon-trash

        /// <summary>
        /// A check mark
        /// </summary>
        Check,               // ui-icon-check

        ///<summary>
        ///Thick Close Mark to say No or Close
        ///</summary>
        CloseThick,          //ui-icon-closethick

        /// <summary>
        /// Displays an exclamation mark within a triangle
        /// </summary>
        Alert,               // ui-icon-alert

        Disk,

// ReSharper disable InconsistentNaming
        Triangle_1_S,
// ReSharper restore InconsistentNaming

// ReSharper disable InconsistentNaming
        Circle_Zoomin,
// ReSharper restore InconsistentNaming

        Pencil,

// ReSharper disable InconsistentNaming
        Circle_Arrow_E,
// ReSharper restore InconsistentNaming

// ReSharper disable InconsistentNaming
        Circle_Arrow_W,
// ReSharper restore InconsistentNaming

// ReSharper disable InconsistentNaming
        Circle_Arrow_N,
// ReSharper restore InconsistentNaming

// ReSharper disable InconsistentNaming
        Circle_Arrow_S
// ReSharper restore InconsistentNaming
    }

    public partial class ButtonEx
    {
        /// <summary>
        /// Returns the jquery css class associated with the passed icon
        /// </summary>
        /// <param name="icon"></param>
        /// <returns>Class name or null (not an empty string) string for icon=Custom</returns>
        /// <exception cref="ArgumentOutOfRangeException">icon parameter cannot be None or Custom</exception>
        private static string GetIcon(ButtonIconType icon)
        {
            string str;
            switch (icon)
            {
                case ButtonIconType.None:
                case ButtonIconType.Custom:
                    throw new ArgumentOutOfRangeException("icon", icon, "Cannot be None or Custom");

                default:
                    str = string.Format("ui-icon-{0}", icon.ToString().ToLower().Replace('_', '-'));
                    break;

            }
            return str;
        }
    }
}

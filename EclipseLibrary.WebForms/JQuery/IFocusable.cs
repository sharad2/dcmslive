using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// How eager is the input control to receive focus. The first most eager control on the page gets the focus.
    /// </summary>
    public enum FocusPriority
    {
        /// <summary>
        /// We will try our best to give you focus
        /// </summary>
        High = 0,

        /// <summary>
        /// You are willing to accept focus. This should be the most common value returned from 
        /// <see cref="IFocusable.FocusPriority"/>
        /// </summary>
        Normal = 1,

        /// <summary>
        /// You would rather not receive focus but won't mind if you get it.
        /// </summary>
        Low = 2,

        /// <summary>
        /// You are not in a state to receive focus. Perhaps because you have been disabled.
        /// </summary>
        NotAllowed = 3
    }

    /// <summary>
    /// Controls which are willing to accept focus should implement this interface.
    /// </summary>
    /// <remarks>
    /// <see cref="JQueryScriptManager"/> drives this interface during rendering.
    /// call
    /// </remarks>
    interface IFocusable
    {
        /// <summary>
        /// Return how interested you are in receiving focus. In most cases you should return
        /// <c>Normal</c> unless you have a special reason.
        /// </summary>
        /// <returns></returns>
        /// <remarks>
        /// Since this property can be called multiple times, it is recommended that you cache your work
        /// if it is processing intensive.
        /// </remarks>
        FocusPriority FocusPriority { get; }

        /// <summary>
        /// This function will be called when you are the chosen recipient of focus. You must generate
        /// the necessary client script which will give you focus.
        /// </summary>
        void Focus();
    }
}

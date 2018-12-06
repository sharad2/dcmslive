using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// The value is the name of the currently logged in user
    /// </summary>
    public class UserParameter:Parameter
    {
        public UserParameter()
        {
            this.Type = TypeCode.String;
        }

        protected override object Evaluate(HttpContext context, Control control)
        {
            if (context.User.Identity.IsAuthenticated)
            {
                return context.User.Identity.Name;
            }
            else
            {
                return "anonymous";
            }
        }
    }
}

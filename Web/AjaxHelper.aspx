<%@ Page Language="C#" Title="Ajax Helper Page" %>
<%@ Import Namespace="System.Linq" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    /// <summary>
    /// This simple page is called by the Master page to save user's theme selection. It is passed the chosen theme
    /// as the value of the form variable "theme".
    /// </summary>
    /// <param name="e"></param>
    /// <remarks>
    /// This page performs work only if called using the POST method. This prevents accidental calls from doing bad things.
    /// The Form variable action specifies what to do. Other form variables are interpreted based on the action.
    /// action=save_theme -> The theme passed in the theme form variable is saved as the user's default theme.
    /// action=add_fav -> The report key passed in report_key is added as the user's favorite link
    /// action=remove_fav -> The report key passed in report_key is removed from the user's list of favorite links.
    /// </remarks>
    protected override void OnLoad(EventArgs e)
    {
        string reportKey;
        switch (this.Request.Form["action"])
        {
            case "save_theme":
                this.Profile.Theme = this.Request.Form["theme"];
                this.Profile.Save();
                break;

            case "add_fav":
                reportKey = this.Request.Form["report_key"];
                this.Profile.FavoriteReports.Add(reportKey, int.MaxValue);
                this.Profile.Save();
                break;

            case "remove_fav":
                reportKey = this.Request.Form["report_key"];
                this.Profile.FavoriteReports.Remove(reportKey);
                this.Profile.Save();
                break;
                
            default:
                break;
        }

        base.OnLoad(e);
    }

    protected override void Render(HtmlTextWriter writer)
    {
        // Do nothing
        //base.Render(writer);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <p>
        This page is not meant to be called directly. It exists to implement behind the
        scenes AJAX functionality.
    </p>
</body>
</html>

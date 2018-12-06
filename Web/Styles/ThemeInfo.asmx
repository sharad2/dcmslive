<%@ WebService Language="C#" Class="ThemeInfo" %>

using System;
using System.IO;
using EclipseLibrary.Web.UI;
using System.Linq;
using System.Web.Services;

/// <summary>
/// This web service expects that each theme is within a folder in the same directory as this file.
/// It enumerates all the folders and returns them as an array of keys and values.
/// </summary>
/// <remarks>
/// <para>
/// Hidden directories are excluded. This ensures that .svn does not show up as a theme.
/// </para>
/// </remarks>
[WebService(Namespace = "http://www.eclsys.com/",
    Description = "Makes available a list of theme directories",
    Name = "ThemeEnumerator")]
[WebServiceBinding(ConformsTo = System.Web.Services.WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class ThemeInfo : System.Web.Services.WebService
{
    /// <summary>
    /// All URLs returned are encoded, so they should be decoded before use
    /// </summary>
    /// <returns></returns>
    /// <remarks>
    /// <para>
    /// Sharad 31 Jan 2011: Removed the Cache from WebMethod attribute because it was unpredictably leading to ajax errors
    /// </para>
    /// </remarks>
    [WebMethod(
        Description = "Enumerates the list of theme directories",
        EnableSession = false,
        BufferResponse = true
        )]
    public object[] GetThemes()
    {
        string strThemeDirectory = Path.GetDirectoryName(this.Context.Request.PhysicalPath);
        object[] query = (from path in Directory.GetDirectories(strThemeDirectory, "*", SearchOption.TopDirectoryOnly)
                          where (File.GetAttributes(path) & FileAttributes.Hidden) != FileAttributes.Hidden
                          let theme = Path.GetFileName(path)
                          select new
                          {
                              Text = theme,
                              Value = theme
                          }).Cast<object>().ToArray();
        return query;
    }

}


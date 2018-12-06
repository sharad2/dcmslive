using System;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;

namespace EclipseLibrary.Web.SiteStructure
{
    /// <summary>
    /// Converts an ASPX file into valid XML by making minor replacements
    /// </summary>
    /// <remarks>
    /// All content within <![CDATA[<script>]]> tags is ignored because the script tag is converted to a comment tag.
    /// <![CDATA[<%@ Page ... %@> becomes <Page ... />]]>
    /// Convert server side comments to HTML comments
    /// </remarks>
    internal class AspxStreamReader : StreamReader
    {
        public AspxStreamReader(string path)
            : base(path)
        {

        }

        private bool _bInScriptElement;

        /// <summary>
        /// <![CDATA[
        /// ]]>
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="index"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        public override int Read(char[] buffer, int index, int count)
        {
            string str;

            // Ignore empty lines
            str = ReadLine();
            if (str == null)
            {
                // End of file
                return 0;
            }

            // Everything inside <script> tag is replaced by X
            if (_bInScriptElement)
            {
                if (str.Contains("</script"))
                {
                    str = "-->";
                    _bInScriptElement = false;
                }
                else
                {
                    str = string.Empty;
                }
            }
            else if (str.Contains("<script"))
            {
                str = "<!--";
                _bInScriptElement = true;
            }
            else
            {
                // Convert server side comments to HTML comments
                str = str.Replace("<%--", "<!--").Replace("--%>", "-->");

                // <%@ Page ... %@> becomes <Page ... />
                str = Regex.Replace(str, @"<%@\s*", "<").Replace("%>", "/>");

                // Get Rid of namespaces
                str = Regex.Replace(str, @"<\w+:", "<");
                str = Regex.Replace(str, @"</\w+:", "</");
            }
            str += Environment.NewLine;
            Trace.Write(str);
            if (count < str.Length)
            {
                throw new NotImplementedException("Will this happen?");
            }
            str.ToCharArray().CopyTo(buffer, index);
            return str.Length;

        }

    }


}

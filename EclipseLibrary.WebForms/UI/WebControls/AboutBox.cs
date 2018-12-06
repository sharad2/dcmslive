using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Common;
using System.Linq;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Concurrent;

namespace EclipseLibrary.Web.UI
{
    /// <summary>
    /// Displays the assemblies referenced by the application as well as the connection strings used.
    /// Assemblies which are signed are not considered to avoid displaying version numbers of .NET assemblies.
    /// </summary>
    /// <remarks>
    /// Sharad 6 Aug 2009: Applied PartialCaching to cache the HTML output. This should lead to minor efficiency.
    /// Gyaneshwar 25th Oct. 2010: The provider are also shown in the dialog. 
    /// </remarks>
    [PartialCaching(3600)]
    public class AboutBox: WebControl
    {
        private static IEnumerable<AssemblyName> _libraries;

        private struct ConnectionInfo
        {
            public string UserId;
            public string DataSource;
            public string ProviderName;
        }
        /// <summary>
        /// First is user id, second is data source
        /// </summary>
        private static BlockingCollection<ConnectionInfo> _connections;
        //string _providername;
        /// <summary>
        /// If this is the first call, determine what libraries are being used
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e) 
        {
            if (_libraries == null)
            {
                _libraries = (from Assembly a in AppDomain.CurrentDomain.GetAssemblies()
                            let titleAttributes = a.GetCustomAttributes(typeof(AssemblyTitleAttribute), false)
                            where !a.GlobalAssemblyCache && titleAttributes.Length > 0
                            select a.GetName()).ToArray();
            }

            if (_connections == null)
            {
                _connections = new BlockingCollection<ConnectionInfo>(2);

                foreach (ConnectionStringSettings setting in ConfigurationManager.ConnectionStrings)
                {
                    DbConnectionStringBuilder builder = new DbConnectionStringBuilder();
                    builder.ConnectionString = setting.ConnectionString;
                    ConnectionInfo info;
                    info.DataSource = builder["data source"].ToString();
                    info.ProviderName = setting.ProviderName;
                    if (builder.ContainsKey("user id")) {
                        info.UserId = builder["user id"].ToString();
                    }
                    else if (builder.ContainsKey("Proxy User ID"))
                    {
                        info.UserId = builder["Proxy User ID"].ToString();
                    }
                    else
                    {
                        info.UserId = string.Empty;
                    }
                    _connections.Add(info);
                    //_connections.Add(new Pair(builder["user id"].ToString(), builder["data source"].ToString()),setting.ProviderName);
                    //_providername = setting.ProviderName;
                }
            }
            base.OnPreRender(e);
        }

        /// <summary>
        /// Returns DIV
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Div;
            }
        }

        /// <summary>
        /// Renders all required information
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            RenderLibraries(writer);
            writer.RenderBeginTag(HtmlTextWriterTag.Hr);
            writer.RenderEndTag();
            RenderConnections(writer);
           
        }

        private void RenderConnections(HtmlTextWriter writer)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Rules, "all");
            writer.RenderBeginTag(HtmlTextWriterTag.Table);
            //writer.RenderBeginTag(HtmlTextWriterTag.Caption);
            //writer.Write("Connections");
            //writer.RenderEndTag();          // Caption
            writer.RenderBeginTag(HtmlTextWriterTag.Tr);
            writer.AddStyleAttribute(HtmlTextWriterStyle.TextAlign, "Left");
            writer.RenderBeginTag(HtmlTextWriterTag.Th);
            writer.Write("User");
            writer.RenderEndTag(); //th
            writer.RenderBeginTag(HtmlTextWriterTag.Th);
            writer.Write("Connections");
            writer.RenderEndTag(); //th
            writer.RenderBeginTag(HtmlTextWriterTag.Th);
            writer.Write("Providers");
            writer.RenderEndTag(); //th
            writer.RenderEndTag(); //tr
            foreach (var item in _connections)
            {
                
                writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                writer.RenderBeginTag(HtmlTextWriterTag.Td);
                writer.Write(item.UserId);
                writer.RenderEndTag();          // td
                writer.RenderBeginTag(HtmlTextWriterTag.Td);
                writer.Write(item.DataSource);
                writer.RenderEndTag();          // td
                writer.RenderBeginTag(HtmlTextWriterTag.Td);
                writer.Write(item.ProviderName);
                writer.RenderEndTag();  //td
                writer.RenderEndTag();          // tr
                
            }
            writer.RenderEndTag();          // table

        }

        private static void RenderLibraries(HtmlTextWriter writer)
        {
            writer.AddAttribute(HtmlTextWriterAttribute.Rules, "all");
            writer.RenderBeginTag(HtmlTextWriterTag.Table);
            //writer.RenderBeginTag(HtmlTextWriterTag.Caption);
            //writer.Write("Libraries");
            //writer.RenderEndTag();          // Caption
            writer.RenderBeginTag(HtmlTextWriterTag.Tr);
            writer.AddStyleAttribute(HtmlTextWriterStyle.TextAlign, "Left");
            writer.RenderBeginTag(HtmlTextWriterTag.Th);
            writer.Write("Libraries");
            writer.RenderEndTag();
            writer.RenderBeginTag(HtmlTextWriterTag.Th);
            writer.Write("Version No.");
            writer.RenderEndTag();
            writer.RenderEndTag();
            foreach (var item in _libraries)
            {
                
                writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                writer.RenderBeginTag(HtmlTextWriterTag.Td);
                writer.Write(item.Name);
                writer.RenderEndTag();          // td
                //writer.RenderBeginTag(HtmlTextWriterTag.Td);
                //writer.Write(item.Description);
                //writer.RenderEndTag();          // td
                writer.RenderBeginTag(HtmlTextWriterTag.Td);
                writer.Write(item.Version);
                writer.RenderEndTag();          // td
                writer.RenderEndTag();          // tr
            }
            writer.RenderEndTag();          // table
        }
        
    }
}

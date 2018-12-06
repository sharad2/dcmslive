using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Web.Caching;
using System.Xml;

namespace EclipseLibrary.Web.SiteStructure
{
    /// <summary>
    /// Automatically creates a sitemap by parsing all the *.aspx files within a root folder.
    /// You specify the name of the default page, and all other pages are presumed to be children of the
    /// default page. The SiteMapNode is populated using the information gleaned by parsing the page.
    /// Sharad 17 Jul 2012: Property <c>CreationTime</c> is always available for each node which contains the creation time of the file.
    /// The date is in string format which can be parsed back to date like this:
    ///   <c>var date = DateTime.ParseExact(node["CreationTime"], "u", null)</c>
    /// </summary>
    /// <include file='AutoSiteMapProvider.xml' path='AutoSiteMapProvider/doc[@name="class"]/*'/>
    public class AutoSiteMapProvider : StaticSiteMapProvider
    {
        #region Initialization
        private string _homePageUrl;
        private string _siteMapRoot;

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="name"></param>
        /// <param name="attributes"></param>
        public override void Initialize(string name, NameValueCollection attributes)
        {
            _homePageUrl = attributes["homePageUrl"];
            _siteMapRoot = attributes["siteMapRoot"];

            string str = attributes["customAttributes"];
            if (!string.IsNullOrEmpty(str))
            {
                char[] seperators = new char[] { ',' };
                string[] customAttributes = attributes["customAttributes"].Split(seperators, StringSplitOptions.RemoveEmptyEntries);

                _customAttributes = new HashSet<string>();
                foreach (string customAttribute in customAttributes)
                {
                    _customAttributes.Add(customAttribute);
                }
            }
            base.Initialize(name, attributes);
        }
        #endregion

        #region Sitemap building
        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <returns>The root node</returns>
        /// <remarks>
        /// If the sitemap has not already been constructed, parse all the files to construct it now
        /// </remarks>
        public override SiteMapNode BuildSiteMap()
        {
            lock (this)
            {
                SiteMapNode rootNode = GetRootNodeFromCache();
                if (rootNode == null)
                {
                    this.Clear();
                    rootNode = DoBuildSiteMap();
                }
                return rootNode;
            }
        }

        /// <summary>
        /// This must be protected with a call to lock
        /// </summary>
        private SiteMapNode DoBuildSiteMap()
        {
            SiteMapNode rootNode = new SiteMapNode(this, _homePageUrl);
            rootNode.Url = _homePageUrl;
            string rootdir = HttpContext.Current.Request.PhysicalApplicationPath;
            if (!string.IsNullOrEmpty(_siteMapRoot))
            {
                rootdir += _siteMapRoot;
            }

            var dirinfo = new DirectoryInfo(rootdir);
            if (!dirinfo.Exists)
            {
                // No problem
                return rootNode;
            }
            var files = dirinfo.GetFiles("*.aspx", SearchOption.AllDirectories);
            List<string> directories = new List<string>(files.Length);
            directories.Add(rootdir);
            foreach (DirectoryInfo d in dirinfo.GetDirectories())
            {
                directories.Add(d.FullName);
            }
            foreach (FileInfo file in files)
            {
                SiteMapNode node;
                try
                {
                    node = ParseFile(file);
                    node["CreationTime"] = file.CreationTime.ToString("u");
                }
                catch (Exception ex)
                {
                    Trace.TraceError(ex.Message);
#if !DEBUG
                    throw new Exception("File " + file.FullName + " could not be parsed", ex);
#else

                    node = null;
#endif
                }
                if (node != null)
                {
                    string siteMapRoot = string.Format("~/{0}", _siteMapRoot);
                    node.Url = file.FullName.Replace(rootdir, siteMapRoot).Replace('\\', '/');
                    if (file.Name == _homePageUrl)
                    {
                        this.RemoveNode(rootNode);
                    }
                    else
                    {
                        this.AddNode(node, rootNode);
                    }
                }
            }

            this.AddNode(rootNode);
            SetRootNodeInCache(rootNode, directories.ToArray());
            return rootNode;
        }

        private HashSet<string> _customAttributes;

        private SiteMapNode ParseFile(FileInfo file)
        {
            SiteMapNode node = new SiteMapNode(this, file.Name);

            var settings = new XmlReaderSettings
            {
                ConformanceLevel = ConformanceLevel.Fragment,
                IgnoreWhitespace = true,
                IgnoreComments = true,
                CloseInput = true
            };

            using (var reader = XmlReader.Create(new AspxStreamReader(file.FullName), settings))
            {
                var b = reader.ReadToFollowing("Page");
                node.Title = reader.GetAttribute("Title");
                b = reader.ReadToFollowing("Content") && reader.ReadToDescendant("meta");
                while (b)
                {
                    var name = reader.GetAttribute("name");
                    var content = reader.GetAttribute("content");
                    switch (name)
                    {
                        case "Description":
                            node.Description = content;
                            break;

                        default:
                            if (_customAttributes != null && _customAttributes.Contains(name))
                            {
                                node[name] = content;
                            }
                            break;
                    }
                    b = reader.ReadToNextSibling("meta");
                }
            }

            return node;
        }

        #endregion

        #region Boilerplate overrides
        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <returns></returns>
        protected override SiteMapNode GetRootNodeCore()
        {
            return this.RootNode;
        }

        /// <summary>
        /// Constructs the sitemap if necessary and returns the root node
        /// </summary>
        /// <remarks>
        /// The DebuggerBrowsableAttribute ensures that the sitemap does not get built simply because
        /// you tried to look at <c>RootNode</c> in the debugger
        /// </remarks>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public override SiteMapNode RootNode
        {
            get
            {
                SiteMapNode temp = null;
                temp = BuildSiteMap();
                return temp;
            }
        }
        #endregion

        #region Application Cache

        private const string CACHE_KEY = "AutoSiteMap_";

        private SiteMapNode GetRootNodeFromCache()
        {
            return (SiteMapNode)HttpContext.Current.Cache[CACHE_KEY + _siteMapRoot];
        }

        /// <summary>
        /// Sets dependency on the directories passed.
        /// Whenever any file in the list of directories changes, the sitemap is reconstructed.
        /// </summary>
        private void SetRootNodeInCache(SiteMapNode node, string[] directories)
        {
            string[] cacheKeys = new string[1];
            CacheDependency dep = new CacheDependency(directories);
            HttpContext.Current.Cache.Insert(CACHE_KEY + _siteMapRoot, node, dep, Cache.NoAbsoluteExpiration,
                Cache.NoSlidingExpiration, CacheItemPriority.Normal, null);
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <remarks>
        /// Remove the sitemap provider entries from the application cache
        /// </remarks>
        protected override void Clear()
        {
            lock (this)
            {
                HttpContext.Current.Cache.Remove(CACHE_KEY + _siteMapRoot);
                base.Clear();
            }
        }
        #endregion
    }
}

/* $Id: AssemblyInfo.cs 13859 2009-03-26 07:16:32Z vvishwakarma $ */

using System.Reflection;
using System.Runtime.InteropServices;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyTitle("EclipseLibrary")]
[assembly: AssemblyDescription("")]
[assembly: AssemblyConfiguration("file:///C:/work/Repositories/Phpa/EclipseLibrary")]
[assembly: AssemblyCompany("Eclipse Systems Private Limited, NOIDA, INDIA")]
#if DEBUG
[assembly: AssemblyProduct("EclipseLibrary - Debug Version")]
#else
[assembly: AssemblyProduct("EclipseLibrary")]
#endif
[assembly: AssemblyCopyright("Copyright ©  2010")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("1bf1a5f7-ceb5-4536-b73e-c12984fc6cf2")]

// Version information for an assembly consists of the following four values:
//
//      Major Version
//      Minor Version 
//      Build Number
//      Revision
//
// You can specify all the values or you can default the Build and Revision Numbers 
// by using the '*' as shown below:
// [assembly: AssemblyVersion("1.0.*")]

// 6.6.1.0 -> 6.6.2.0 (Branch created by Ritesh on 6th Aug 2012)
// Sharad 16 Jul 2012 -> AutoSitemapProvider. Parsing of ASPX pages is done via XML reader instead of home grown string matching. This results in more robuest parsing.

// 6.6.2.0 -> 7.0.0.0 (Branched by Sanjeev Kumar on 15 June 2013)
// Sharad 26 Sep 2012: Removed obsolete controls MatrixField, DropDownList.
// Sharad 28 Sep 2012: Included OracleDataSourceView in this library and removed it from EclipseLibrary.Oracle. Removed dependency on EclipseLibrary.Core.

// 7.0.0.0 -> 7.0.1.0 (Brached By Sanjeev Kumar on 1st Apr 2014)
// Sharad 30 Aug 2013: Not calling the ProxyTagResolver method of OracleDataStore. This means we cannot use <proxy/> tags in queries.
// Skumar Mbisht(1st Apr 2014):- Validation ValueType Integer is now ready to support Int64. It was Int32 and not able to suport new 
// pickslips which starts with 80. For example:-8014919926. This pickslip is exceeding the max Int32 range of 2147483647. Due to this library 
// was crashing. This issue has been resolved now.

[assembly: AssemblyVersion("7.0.1.0")]
[assembly: AssemblyFileVersion("7.0.1.0")]


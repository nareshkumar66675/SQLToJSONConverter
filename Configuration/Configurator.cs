using Migration.Common;
using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Configuration
{
    public static class Configurator
    {
        /// <summary>
        /// List of Componets from XML
        /// </summary>
        public static Components SourceComponents { get;  }
        /// <summary>
        /// List of Components needs to be executed
        /// </summary>
        public static Components SelectedComponents { get; set; }
        static Configurator()
        {
            SourceComponents = XMLHelper.Components;
            SelectedComponents = new Components();
            SetGroupName();
        }
        /// <summary>
        /// Retrieves Source/Query from Transformation XML
        /// </summary>
        /// <param name="componentName">Component Name</param>
        /// <returns>Source/Query</returns>
        public static string GetSourceByComponentName(string componentName)
        {
            return GetTransformationEnumerable(componentName).Select(u => u.Source).FirstOrDefault();
        }
        /// <summary>
        /// Retrieves Destination Table from Transformation XML
        /// </summary>
        /// <param name="componentName">Component Name</param>
        /// <returns>Destination Table Name</returns>
        public static string GetDestinationByComponentName(string componentName)
        {
            return GetTransformationEnumerable(componentName).Select(u => u.Destination).FirstOrDefault();
        }
        /// <summary>
        /// Sets the Selected Components which will be executed
        /// </summary>
        /// <param name="disString">Group and List of Display Strings</param>
        public static void SetSelectedComponentsByDisplayName(Dictionary<GroupType, List<string>> disString)
        {
            SelectedComponents.Group = new List<Group>();
            SourceComponents.Group.ForEach(grp =>
            {
                List<Component> x=new List<Component>();
                disString.Where(u => u.Key == grp.Name).FirstOrDefault().Value.ForEach(t => 
                {
                    x.AddRange(grp.Component.Where(v => v.DisplayName == t).ToList());
                });
                SelectedComponents.Group.Add(new Group(x, grp.Name));
            });
        }
        /// <summary>
        /// Gets the KeyFormat From Transformation
        /// </summary>
        /// <param name="componentName">Component Name</param>
        /// <returns>Key Format</returns>
        public static KeyFormat GetKeyFormat(string componentName)
        {
            return GetTransformationEnumerable(componentName).Select(u => u.KeyFormat).FirstOrDefault();
        }
        /// <summary>
        /// Checks if there are any elemets in Components
        /// </summary>
        /// <param name="components">Components</param>
        /// <returns>True if it has elements or else False</returns>
        public static bool HasElements(this Components components)
        {
            if (components == null || components.Group==null) return false;
            foreach (var grp in components.Group)
            {
                if (grp == null) return false;
                if (grp.Component.Count > 0)
                    return true;
            }
            return false;
        }
        /// <summary>
        /// To Get List Of components By Group Name
        /// </summary>
        /// <param name="group">Group Type</param>
        /// <returns>List Of Component</returns>
        public static List<Component> GetComponentsByGroup(GroupType group)
        {
            return SourceComponents.Group.Where(t => t.Name == group).Select(u => u.Component).FirstOrDefault();
        }
        /// <summary>
        /// Set Query Params to be used for Source Query
        /// </summary>
        /// <param name="componentName">Component Name</param>
        /// <param name="queryParams">Paramaters Values</param>
        public static void SetQueryParams(string componentName,List<string> queryParams)
        {
            GetTransformationEnumerable(componentName).FirstOrDefault().QueryParams = queryParams;
        }

        #region PrivateMethods
        private static IEnumerable<Transformation> GetTransformationEnumerable(string componentName)
        {
            return XMLHelper.Transforms.Transformation.Where(t => t.Name == componentName);
        }
        private static void SetGroupName()
        {
            XMLHelper.Components.Group.ForEach(grp =>
            {
                grp.Component.ForEach(component =>
                {
                    component.GroupName = grp.Name;
                });
            });
        }
        //private static void MapTransforms()
        //{
        //    XMLHelper.Components.Group.ForEach(grp =>
        //    {
        //        grp.Component.ForEach(component =>
        //        {
        //            component.Transformation = XMLHelper.Transforms.Transformation.Where(transfor => transfor.Name == component.Name).FirstOrDefault();
        //        });
        //    });
        //} 
        #endregion
    }
}

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
            //MapTransforms();
            SetGroupName();
        }

        /// <summary>
        /// Retrieves Source/Query from Transformation XML
        /// </summary>
        /// <param name="name">Component Name</param>
        /// <returns>Source/Query</returns>
        public static string GetSourceByComponentName(string name)
        {
            return XMLHelper.Transforms.Transformation.Where(t => t.Name == name).Select(u => u.Source).FirstOrDefault();
        }
        /// <summary>
        /// Retrieves Destination Table from Transformation XML
        /// </summary>
        /// <param name="name">Component Name</param>
        /// <returns>Destination Table Name</returns>
        public static string GetDestinationByComponentName(string name)
        {
            return XMLHelper.Transforms.Transformation.Where(t => t.Name == name).Select(u => u.Destination).FirstOrDefault();
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
        public static KeyFormat GetKeyFormat(string componentName)
        {
            return XMLHelper.Transforms.Transformation.Where(t => t.Name == componentName).Select(u => u.KeyFormat).FirstOrDefault();
        }
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
    }
}

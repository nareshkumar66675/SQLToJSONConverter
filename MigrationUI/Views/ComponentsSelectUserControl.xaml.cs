using Migration.Common;
using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using static MigrationTool.Wizard;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for ComponentsSelectView.xaml
    /// </summary>
    public partial class ComponentsSelectUserControl : UserControl
    {
        public List<int> SelectedSiteIDList { get; set; }
        public List<Component> SrcComponents { get; set; }
        private static List<Component> SelectedComponents = new List<Component>();
        public ComponentsSelectUserControl()
        {
            InitializeComponent();
            //Configurator.SourceComponents.Group.ForEach(grp =>
            //{
            //    if(grp.Name== GroupType.AUTH)
            //        grp.Component.ForEach(u => { AuthCheckList.Items.Add(u.DisplayName);  });
            //    //if (grp.Name == GroupType.ASSET)
            //    //    grp.Component.ForEach(u => { AssetCheckList.Items.Add(u.DisplayName); });
            //    //if (grp.Name == GroupType.SEARCH)
            //    //    grp.Component.ForEach(u => { SearchCheckList.Items.Add(u.DisplayName); });
            //});
            SelectAllComponents();
            UpdateComponents += Wizard_UpdateComponents;       
        }
        public void InitializeData()
        {
            expander.Header = SrcComponents.Select(t => t.GroupName).FirstOrDefault().ToString();
            Logger.Instance.LogInfo("Initializing Data For Components Selection for Group -" + expander.Header);
            ComponentsCheckList.ItemsSource = SrcComponents;
            ComponentsCheckList.DisplayMemberPath = "DisplayName";
            ComponentsCheckList.ValueMemberPath = "Name";
        }
        private void Wizard_UpdateComponents(object sender, UpdateCompleteEventArgs e)
        {
            //List<string> authSelectedItems = new List<string>();
            //List<string> assetSelectedItems = new List<string>();
            //List<string> searchSelectedItems = new List<string>();
            //Dictionary<GroupType, List<string>> selectedItems = new Dictionary<GroupType, List<string>>();
            
            //foreach (var item in AuthCheckList.SelectedItems)
            //{
            //    authSelectedItems.Add(item as string);
            //}
            ////foreach (var item in AssetCheckList.SelectedItems)
            ////{
            ////    assetSelectedItems.Add(item as string);
            ////}
            ////foreach (var item in SearchCheckList.SelectedItems)
            ////{
            ////    searchSelectedItems.Add(item as string);
            ////}
            //selectedItems.Add(GroupType.AUTH, authSelectedItems);
            //selectedItems.Add(GroupType.ASSET, assetSelectedItems);
            //selectedItems.Add(GroupType.SEARCH, searchSelectedItems);
            //Configurator.SetSelectedComponentsByDisplayName(selectedItems);
            //if (Configurator.SelectedComponents.HasElements())
            //{
            //    e.status = true;
            //    Logger.Instance.LogInfo("Selected Auth Components:" + string.Join(",", authSelectedItems));
            //    Logger.Instance.LogInfo("Selected Asset Components:" + string.Join(",", assetSelectedItems));
            //    Logger.Instance.LogInfo("Selected Search Components:" + string.Join(",", searchSelectedItems));
            //}
            //else
            //    e.status = false;
        }

        private void SelectAllComponents()
        {
            //(AuthComponents.Items[0] as CheckBox).IsChecked = true;
            //AuthComponents.SelectedItemsOverride = new List<object>();
            //AuthComponents.SelectedItemsOverride.Insert(0, "sample");
            ////foreach (var item in AuthComponents.Items)
            ////{
            ////    AuthComponents.SelectedItemsOverride.Add()
            ////}
        }

        private void ComponentsCheckList_ItemSelectionChanged(object sender, Xceed.Wpf.Toolkit.Primitives.ItemSelectionChangedEventArgs e)
        {
            SelectedComponents = ComponentsCheckList.SelectedItems.Cast<Component>().ToList();
        }

        public Components GetSelectedComponents()
        {
            Components components = new Components();
            Group grp = new Group(SelectedComponents, SelectedComponents.Select(t => t.GroupName).FirstOrDefault());
            List<Group> grpList = new List<Group>();
            grpList.Add(grp);
            components.Group = grpList;
            return components;
        }
    }
}

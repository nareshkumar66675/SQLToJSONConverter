using Migration.Common;
using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using MigrationTool.Helpers;
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
        #region VariablesInitialization
        private static List<Component> SelectedComponents = new List<Component>();
        public List<int> SelectedSiteIDList { get; set; }
        public List<Component> SourceComponents { get; set; }
        public event EventHandler<ComponentsSelectionChangedEventArgs> OnComponentsSelectionChanged;
        #endregion
        public class ComponentsSelectionChangedEventArgs : EventArgs
        {
            public ComponentsSelectionChangedEventArgs(bool isEmpty)
            {
                this.IsEmpty = isEmpty;
            }
            public bool IsEmpty { get; set; }
        }
        public ComponentsSelectUserControl()
        {
            InitializeComponent();     
        }
        public void InitializeData()
        {
            try
            {
                var group = SourceComponents.Select(t => t.GroupName).FirstOrDefault();
                var completedList = DatabaseHelper.GetCompletedComponents(group, null);
                completedList.ForEach(item => SourceComponents.RemoveAll(t => t.Name == item));
                expander.Header = group.ToString();
                Logger.Instance.LogInfo("Initializing Data For Components Selection for Group -" + expander.Header);
                ComponentsCheckList.ItemsSource = SourceComponents;
                ComponentsCheckList.DisplayMemberPath = "DisplayName";
                ComponentsCheckList.ValueMemberPath = "Name";
                ComponentsCheckList.SelectedItemsOverride = SourceComponents.ToList();
                SelectedComponents = SourceComponents.ToList();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred While Initializing DataGrid For Components Selection", ex);
                Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Error Occured. Please Check Logs", "Components Selection", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private void ComponentsCheckList_ItemSelectionChanged(object sender, Xceed.Wpf.Toolkit.Primitives.ItemSelectionChangedEventArgs e)
        {
            SelectedComponents = ComponentsCheckList.SelectedItems.Cast<Component>().ToList();
            var isEmpty = SelectedComponents.Count > 0 ? false : true;
            ComponentsSelectionChangedEventArgs args = new ComponentsSelectionChangedEventArgs(isEmpty);
            OnComponentsSelectionChanged?.Invoke(this, args);
        }
        public Components GetSelectedComponents()
        {
            Components components = new Components();
            try
            {
                Group grp = new Group(SelectedComponents, SelectedComponents.Select(t => t.GroupName).FirstOrDefault());
                List<Group> grpList = new List<Group>();
                grpList.Add(grp);
                components.Group = grpList;
                Logger.Instance.LogInfo("Selected Components For " + grp.Name + " Group :" + string.Join(",", SelectedComponents.Select(t => t.Name)));
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred While returning selected components", ex);
            }
            return components;
        }
    }
}

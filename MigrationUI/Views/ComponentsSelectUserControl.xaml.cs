using Migration.Common;
using Migration.Configuration.ConfigObject;
using MigrationTool.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for ComponentsSelectView.xaml
    /// </summary>
    public partial class ComponentsSelectUserControl : UserControl
    {
        #region VariablesInitialization
        private static List<Component> SelectedComponents = new List<Component>();
        public List<string> SelectedSiteIDList { get; set; }
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
        public void InitializeData(GroupType group)
        {
            try
            {
                SetDBDetails(group);
                List<string> completedList = new List<string>();
                try
                {
                    completedList = DatabaseHelper.GetCompletedComponents(group, SelectedSiteIDList);
                }
                catch (InvalidOperationException ex)
                {
                    Logger.Instance.LogError("Error Occurred", ex);
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Migration Report Tables Not Found.\nTerminating Application", "Components Selection", MessageBoxButton.OK, MessageBoxImage.Error);
                    Application.Current.Shutdown();
                }
                completedListBox.ItemsSource = SourceComponents.Where(t => completedList.Contains(t.Name)).Select(u => u.DisplayName);
                completedList.ForEach(item => SourceComponents.RemoveAll(t => t.Name == item));
                expander.Header = group.GetDescription();
                Logger.Instance.LogInfo("Initializing Data For Components Selection for Group -" + expander.Header);
                ComponentsCheckList.ItemsSource = SourceComponents;
                ComponentsCheckList.DisplayMemberPath = "DisplayName";
                ComponentsCheckList.ValueMemberPath = "Name";
                ComponentsCheckList.SelectedItemsOverride = SourceComponents.ToList();
                SelectedComponents = SourceComponents.ToList();
                NotifySelectionChanged();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred While Initializing DataGrid For Components Selection", ex);
                ErrorHandler.ShowFatalErrorMesage(Window.GetWindow(this), "Components Selection");
            }
        }
        public ComponentsSelectUserControl()
        {
            InitializeComponent();     
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
        private void ComponentsCheckList_ItemSelectionChanged(object sender, Xceed.Wpf.Toolkit.Primitives.ItemSelectionChangedEventArgs e)
        {
            NotifySelectionChanged();
        }
        private void NotifySelectionChanged()
        {
            SelectedComponents = ComponentsCheckList.SelectedItems.Cast<Component>().ToList();
            var isEmpty = SelectedComponents.Count > 0 ? false : true;
            ComponentsSelectionChangedEventArgs args = new ComponentsSelectionChangedEventArgs(isEmpty);
            OnComponentsSelectionChanged?.Invoke(this, args);
        }
        private void SetDBDetails(GroupType group)
        {
            this.databaseTextBlock.Text = DatabaseHelper.GetDatabaseName(Common.ConnectionStrings.GetConnectionString(group));
            this.serverTextBlock.Text= DatabaseHelper.GetServerName(Common.ConnectionStrings.GetConnectionString(group));
        }

        private void selectAllButton_Click(object sender, RoutedEventArgs e)
        {
            ComponentsCheckList.SelectedItemsOverride = SourceComponents.ToList();
            SelectedComponents = SourceComponents.ToList();
            ComponentsCheckList.Items.Refresh();
            NotifySelectionChanged();
        }

        private void deselectAllButton_Click(object sender, RoutedEventArgs e)
        {
            ComponentsCheckList.SelectedItemsOverride.Clear();
            SelectedComponents.Clear();
            ComponentsCheckList.Items.Refresh();
            NotifySelectionChanged();
        }
    }
}

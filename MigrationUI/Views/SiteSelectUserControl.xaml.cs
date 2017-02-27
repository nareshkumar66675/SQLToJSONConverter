using Migration.Common;
using MigrationTool.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using static Migration.Common.Common;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for SiteSelectUserControl.xaml
    /// </summary>
    public partial class SiteSelectUserControl : UserControl
    {
        public Dictionary<string,string> SourceSites = new Dictionary<string, string>();
        public static Dictionary<string, string> SelectedSites = new Dictionary<string, string>();
        public SiteSelectUserControl()
        {
            InitializeComponent();
        }
        private void SelectSitesButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItems = srcListBox.SelectedItems.Cast<KeyValuePair<string, string>>().ToList();
                selectedItems.ForEach(item => SelectedSites.Add(item.Key, item.Value));
                selectedItems.ForEach(t => SourceSites.Remove(t.Key));
                ResetListBoxes();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While Selecting Sites", ex);
            }
        }
        private void DeSelectSitesButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItems = selectedListBox.SelectedItems.Cast<KeyValuePair<string, string>>().ToList();
                selectedItems.ForEach(item => SourceSites.Add(item.Key, item.Value));
                SourceSites.OrderBy(t => t.Value);
                selectedItems.ForEach(t => SelectedSites.Remove(t.Key));
                ResetListBoxes();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While DeSelecting Sites", ex);
            }
        }
        private void ResetListBoxes()
        {
            srcListBox.ItemsSource = SourceSites.ToList();
            selectedListBox.ItemsSource = SelectedSites.ToList();
            srcListBox.Items.Refresh();
            selectedListBox.Items.Refresh();
        }
        public void LoadSites(GroupType group)
        {
            SourceSites = GetNotMigratedSites(group);
            srcListBox.DisplayMemberPath = "Value";
            selectedListBox.DisplayMemberPath = "Value";
            Logger.Instance.LogInfo("Site Selection for Group - "+ group);
            ResetListBoxes();
        }
        public Dictionary<string, string> GetSelectedSites()
        {
            Logger.Instance.LogInfo("Selected Sites : "+ string.Join(",",SelectedSites.Select(t=>t.Key)));
            return SelectedSites;
        }
        private Dictionary<string, string> GetNotMigratedSites(GroupType group)
        {
            var allSites = new Dictionary<string, string>();
            try
            {
                allSites = DatabaseHelper.GetAllSites(ConnectionStrings.LegacyConnectionString);
                var migratedSites = DatabaseHelper.GetMigratedSites(ConnectionStrings.GetConnectionString(group));
                migratedSites.ForEach(t => allSites.Remove(t));
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While retrieving not migrated Sites", ex);
            }
            return allSites;
        }
    }
}

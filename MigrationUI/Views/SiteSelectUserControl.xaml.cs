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
            var temp = srcListBox.SelectedItems.Cast<KeyValuePair<string, string>>().ToList();
            foreach (var item in temp)
            {
                SelectedSites.Add(item.Key, item.Value);
            }
            temp.ForEach(t => SourceSites.Remove(t.Key));
            ResetListBoxes();
        }

        private void DeSelectSitesButton_Click(object sender, RoutedEventArgs e)
        {
            var temp = selectedListBox.SelectedItems.Cast<KeyValuePair<string, string>>().ToList();
            foreach (var item in temp)
            {
                SourceSites.Add(item.Key,item.Value);
            }
            SourceSites.OrderBy(t => t.Value);
            temp.ForEach(t => SelectedSites.Remove(t.Key));
            ResetListBoxes();
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
            ResetListBoxes();
        }
        public Dictionary<string, string> GetSelectedSites()
        {
            return SelectedSites;
        }
        private Dictionary<string, string> GetNotMigratedSites(GroupType group)
        {
            var all =DatabaseHelper.GetAllSites(ConnectionStrings.SourceConnectionString);
            var migrated = DatabaseHelper.GetMigratedSites(ConnectionStrings.GetConnectionString(group));

            migrated.ForEach(t => all.Remove(t));

            return all;
        }
    }
}

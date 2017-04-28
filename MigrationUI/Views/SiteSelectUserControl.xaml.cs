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
        #region Variable Initialization
        public Dictionary<string, string> SourceSites = new Dictionary<string, string>();
        public Dictionary<string, string> SelectedSites = new Dictionary<string, string>();
        public event EventHandler<SitesSelectionChangedEventArgs> OnSitesSelectionChanged;
        private int allSiteCount;
        #endregion
        public class SitesSelectionChangedEventArgs : EventArgs
        {
            public SitesSelectionChangedEventArgs(bool isEmpty)
            {
                this.IsEmpty = isEmpty;
            }
            public bool IsEmpty { get; set; }
        }
        public SiteSelectUserControl()
        {
            InitializeComponent();
        }
        public void LoadSites(GroupType group)
        {
            SourceSites.Clear();
            SelectedSites.Clear();
            SourceSites = GetNotMigratedSites(group);
            allSiteCount = SourceSites.Count;
            srcListBox.DisplayMemberPath = "Value";
            selectedListBox.DisplayMemberPath = "Value";

            Logger.Instance.LogInfo("Site Selection for Group - " + group);
            
            srcListBox.ItemsSource = SourceSites;
            selectedListBox.ItemsSource = SelectedSites;

            CollectionView srcView = (CollectionView)CollectionViewSource.GetDefaultView(srcListBox.ItemsSource);
            srcView.Filter = SrcSiteFilter;

            CollectionView selectView = (CollectionView)CollectionViewSource.GetDefaultView(selectedListBox.ItemsSource);
            selectView.Filter = SelectedSiteFilter;

            ResetListBoxes();
        }

        private bool SelectedSiteFilter(object obj)
        {
            if (String.IsNullOrEmpty(selectedSitesFltrTxtBox.Text))
                return true;
            else
                return ((obj as KeyValuePair<string, string>?).Value.Value.IndexOf(selectedSitesFltrTxtBox.Text, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        private bool SrcSiteFilter(object obj)
        {
            if (String.IsNullOrEmpty(srcSitesFltrTxtBox.Text))
                return true;
            else
                return ((obj as KeyValuePair<string, string>?).Value.Value.IndexOf(srcSitesFltrTxtBox.Text, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        public Dictionary<string, string> GetSelectedSites()
        {
            Logger.Instance.LogInfo("Selected Sites : " + string.Join(",", SelectedSites.Select(t => t.Key)));
            return SelectedSites;
        }
        private void SelectSitesButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItems = srcListBox.SelectedItems.Cast<KeyValuePair<string, string>>().ToList();
                selectedItems.ForEach(item => SelectedSites.Add(item.Key, item.Value));
                selectedItems.ForEach(t => SourceSites.Remove(t.Key));
                SourceSites.OrderBy(t => t.Value);
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
                selectedItems.ForEach(t => SelectedSites.Remove(t.Key));
                ResetListBoxes();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While DeSelecting Sites", ex);
            }
        }
        private void SelectAllSitesButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItems = srcListBox.Items.Cast<KeyValuePair<string, string>>().ToList();
                selectedItems.ForEach(item => SelectedSites.Add(item.Key, item.Value));
                selectedItems.ForEach(t => SourceSites.Remove(t.Key));
                ResetListBoxes();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While Selecting All Sites", ex);
            }
        }
        private void DeSelectAllSitesButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var selectedItems = selectedListBox.Items.Cast<KeyValuePair<string, string>>().ToList();
                selectedItems.ForEach(item => SourceSites.Add(item.Key, item.Value));
                selectedItems.ForEach(t => SelectedSites.Remove(t.Key));
                ResetListBoxes();
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While DeSelecting All Sites", ex);
            }
        }
        private void ResetListBoxes()
        {
            SelectedSites.OrderBy(t => t.Value);
            CollectionViewSource.GetDefaultView(srcListBox.ItemsSource).Refresh();
            CollectionViewSource.GetDefaultView(selectedListBox.ItemsSource).Refresh();
            UpdateStatusBar();
            NotifySelectionChanged();
        }
        private Dictionary<string, string> GetNotMigratedSites(GroupType group)
        {
            var allSites = new Dictionary<string, string>();
            try
            {
                allSites = DatabaseHelper.GetAllSitesFromLegacy();
                var migratedSites = DatabaseHelper.GetMigratedSites(ConnectionStrings.GetConnectionString(group));
                migratedSites.ForEach(t => allSites.Remove(t));
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While retrieving not migrated Sites", ex);
            }
            allSites.OrderBy(t => t.Value);
            return allSites;
        }
        private void NotifySelectionChanged()
        {
            var selected = selectedListBox.ItemsSource.Cast<KeyValuePair<string, string>>().ToList();
            var isEmpty = selected.Count > 0 ? false : true;
            SitesSelectionChangedEventArgs args = new SitesSelectionChangedEventArgs(isEmpty);
            OnSitesSelectionChanged?.Invoke(this, args);
        }

        private void srcSitesFltrTxtBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            CollectionViewSource.GetDefaultView(srcListBox.ItemsSource).Refresh();
        }

        private void selectedSitesFltrTxtBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            CollectionViewSource.GetDefaultView(selectedListBox.ItemsSource).Refresh();
        }
        private void UpdateStatusBar()
        {
            statusTextBlock.Text = string.Format(Properties.Resources.SiteSelectUserControl_Status_Message, selectedListBox.Items.Count, allSiteCount);
        }
    }
}

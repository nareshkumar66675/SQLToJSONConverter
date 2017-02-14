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

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for SiteSelectUserControl.xaml
    /// </summary>
    public partial class SiteSelectUserControl : UserControl
    {
        public List<int> srcList = new List<int>();
        public List<int> selectedList = new List<int>();
        public SiteSelectUserControl()
        {
            InitializeComponent();
            srcList=Enumerable.Range(1, 100).ToList();
            srcListBox.ItemsSource = srcList;
            selectedListBox.ItemsSource = selectedList;
        }

        private void SelectSitesButton_Click(object sender, RoutedEventArgs e)
        {
            var temp = srcListBox.SelectedItems.Cast<int>().ToList();
            selectedList.AddRange(srcListBox.SelectedItems.Cast<int>().ToList());
            temp.ForEach(t => srcList.Remove(t));
            srcListBox.Items.Refresh();
            selectedListBox.Items.Refresh();
        }

        private void DeSelectSitesButton_Click(object sender, RoutedEventArgs e)
        {
            var temp = selectedListBox.SelectedItems.Cast<int>().ToList();
            srcList.AddRange(selectedListBox.SelectedItems.Cast<int>().ToList());
            srcList.Sort();
            temp.ForEach(t => selectedList.Remove(t));
            selectedListBox.Items.Refresh();
            srcListBox.Items.Refresh();
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            bool t;
        }
    }
}

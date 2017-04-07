using Migration.Common;
using MigrationTool.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
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
using Xceed.Wpf.DataGrid;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for ViewReportUserControl.xaml
    /// </summary>
    public partial class ViewReportUserControl : UserControl
    {
        public DataTable table { get; set; }
        public ViewReportUserControl()
        {
            InitializeComponent();
        }
        public void ShowReport()
        {
            BusyIndicator.IsBusy = true;
            ReportGrid.ItemsSource = DatabaseHelper.GetAllReports().AsDataView();
            ReportGrid.ReadOnly = true;
            ReportGrid.Columns[0].Visible = false;
            ICollectionView cvTasks = CollectionViewSource.GetDefaultView(ReportGrid.ItemsSource);
            if (cvTasks != null && cvTasks.CanGroup == true)
            {
                cvTasks.GroupDescriptions.Clear();
                cvTasks.GroupDescriptions.Add(new PropertyGroupDescription("Group"));
            }
            BusyIndicator.IsBusy = false;
            ReportGrid.Items.Refresh();
        }
    }
}

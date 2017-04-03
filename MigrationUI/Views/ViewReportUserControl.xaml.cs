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
            InitializeDataGrid();
        }

        private void InitializeDataGrid()
        {
            try
            {
                //DataTable table = new DataTable();
                //table.Columns.Add(new DataColumn("Group"));
                //table.Columns.Add(new DataColumn("DisplayName"));
                //table.Columns.Add(new DataColumn("Site Count"));
                //table.Columns.Add(new DataColumn("Legacy Record"));
                //table.Columns.Add(new DataColumn("Unique Records"));
                //table.Columns.Add(new DataColumn("Inserted Records"));
                //this.table = table;

                //ProcessGrid.Columns[4].Visible = false;
                //ProcessGrid.Columns[1].Width = new ColumnWidth(1, ColumnWidthUnitType.Star);
                //ProcessGrid.Columns[2].Width = new ColumnWidth(2, ColumnWidthUnitType.Star);
                //ReportGrid.Columns[0].AllowSort = false;
                //ProcessGrid.Columns[1].AllowSort = false;
                //ProcessGrid.Columns[2].AllowSort = false;
                //ProcessGrid.Columns[3].AllowSort = false;
                //ReportGrid.ItemScrollingBehavior = ItemScrollingBehavior.Deferred;

            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error While Initializing DataGrid For Components Process", ex);
                ErrorHandler.ShowFatalErrorMsgWtLog(Window.GetWindow(this), "Process Status");
            }
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

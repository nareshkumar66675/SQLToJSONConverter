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
            ReportGrid.Columns[1].Width = new ColumnWidth(170, ColumnWidthUnitType.Pixel);
            ReportGrid.Columns[2].Width = new ColumnWidth(74, ColumnWidthUnitType.Pixel);
            ReportGrid.Columns[3].Width = new ColumnWidth(91, ColumnWidthUnitType.Pixel);
            ReportGrid.Columns[4].Width = new ColumnWidth(92, ColumnWidthUnitType.Pixel);
            ReportGrid.Columns[5].Width = new ColumnWidth(99, ColumnWidthUnitType.Pixel);
            ReportGrid.Columns[2].CellHorizontalContentAlignment = HorizontalAlignment.Center;
            ReportGrid.Columns[3].CellHorizontalContentAlignment = HorizontalAlignment.Center;
            ReportGrid.Columns[4].CellHorizontalContentAlignment = HorizontalAlignment.Center;
            ReportGrid.Columns[5].CellHorizontalContentAlignment = HorizontalAlignment.Center;
            ReportGrid.ItemScrollingBehavior = ItemScrollingBehavior.Immediate;
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

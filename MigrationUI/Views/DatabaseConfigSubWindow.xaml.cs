using Migration.Common;
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
using System.Windows.Shapes;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for DatabaseConfigSubWindow.xaml
    /// </summary>
    public partial class DatabaseConfigSubWindow : Window
    {
        public string ConnectionString { get; set; }
        public string Type
        {
            get
            {
                return DBConnectCntrl.Type;
            }
            set
            {
                DBConnectCntrl.Type = value;
            }
        }
        public DatabaseConfigSubWindow()
        {
            InitializeComponent();
        }
        public void InitializeData()
        {
            DBConnectCntrl.InitializeData(ConnectionString);
        }
        private void DBConnectCntrl_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(e.ConnectionString))
            {
                this.ConnectionString = e.ConnectionString;
            }
            else
                this.ConnectionString = string.Empty;
        }
        public string GetConnectionString()
        {
            return ConnectionString;
        }

        private void completeBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}

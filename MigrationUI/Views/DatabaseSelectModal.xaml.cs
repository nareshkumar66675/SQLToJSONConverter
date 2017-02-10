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
using System.Windows.Shapes;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for DatabaseSelectModal.xaml
    /// </summary>
    public partial class DatabaseSelectModal : Window
    {
        public string ConnectionString { get; set; }
        public string DatabaseName { get; private set; }

        private string comboDefaultText = "Select Database";
        public DatabaseSelectModal()
        {
            InitializeComponent();
            errorTextBlock.Text = comboDefaultText;
            errorTextBlock.Visibility = Visibility.Hidden;
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            if(!string.IsNullOrEmpty(ConnectionString))
            {
                Logger.Instance.LogInfo("Retrieving Database List");
                var databaseList = DatabaseHelper.GetDatabaseList(ConnectionString);
                databaseList.Insert(0, comboDefaultText);
                DatabaseComboBox.ItemsSource = databaseList;
                if (DatabaseComboBox.Items.Count>0) DatabaseComboBox.SelectedIndex = 0;
                errorTextBlock.Visibility = Visibility.Hidden;
            }
        }

        private void ok_Click(object sender, RoutedEventArgs e)
        {
            this.DatabaseName= DatabaseComboBox.SelectedValue as string;
            if (this.DatabaseName == comboDefaultText)
                errorTextBlock.Visibility = Visibility.Visible;
            else
                this.Close();
        }

        private void DatabaseComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if ((DatabaseComboBox.SelectedValue as string) == comboDefaultText)
                errorTextBlock.Visibility = Visibility.Visible;
            else
                errorTextBlock.Visibility = Visibility.Hidden;
        }

        private void cancelButton_Click(object sender, RoutedEventArgs e)
        {
            this.DatabaseName = string.Empty;
            this.Close();
        }
    }
}

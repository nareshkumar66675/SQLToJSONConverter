using Migration.Common;
using MigrationTool.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for DatabaseConfigUserControl.xaml
    /// </summary>
    public partial class DatabaseConfigUserControl : UserControl
    {
        public DatabaseConfigUserControl()
        {
            InitializeComponent();
            AuthTypeComboBox.ItemsSource = Enum.GetValues(typeof(AuthenticationType)).Cast<AuthenticationType>();
            AuthTypeComboBox.SelectedIndex = 0;
        }
        public class ConnectionCompleteEventArgs : EventArgs
        {
            public string ConnectionString { get; set; }
        }

        public event EventHandler<ConnectionCompleteEventArgs> OnConnectComplete;
        private void connectButton_Click(object sender, RoutedEventArgs e)
        {
            #region VariableDeclaration
            string rsltString = "";
            var serverName = serverNameTextBox.Text;
            var username = loginTextBox.Text;
            var pwd = passwordBox.Password;
            var authType = AuthTypeComboBox.SelectedValue.ToString(); 
            #endregion

            ConnectingIndicator.IsBusy = true;
            Logger.Instance.LogInfo("Checking Connection to the Database Server -" + serverName);
            BackgroundWorker worker = new BackgroundWorker();
            worker.DoWork += (o, ea) =>
            {
                rsltString = DatabaseHelper.CheckAndGenerateConnectionString(serverName, username, pwd, (AuthenticationType)Enum.Parse(typeof(AuthenticationType), authType));
            };
            worker.RunWorkerCompleted += (o, ea) =>
            {
                try
                {
                    ConnectingIndicator.IsBusy = false;
                    if (rsltString == "")
                    {
                        Logger.Instance.LogInfo("Cannot Establish a Connection");
                        Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Cannot Establish a Connection", "Database Connection", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    else
                    {
                        Logger.Instance.LogInfo("Connection to the Database Server Completed.");
                        DatabaseSelectModal modalWindow = new DatabaseSelectModal();
                        modalWindow.Owner = Window.GetWindow(this);
                        modalWindow.ConnectionString = rsltString;
                        modalWindow.ShowDialog();
                        if (string.IsNullOrEmpty(modalWindow.DatabaseName))
                        {
                            rsltString = string.Empty;
                        }
                        else
                        {
                            rsltString = DatabaseHelper.AddDatabaseToConnString(rsltString, modalWindow.DatabaseName);
                            Logger.Instance.LogInfo("Selected Database - " + modalWindow.DatabaseName);
                        }
                    }
                    OnConnectComplete?.Invoke(this, new ConnectionCompleteEventArgs { ConnectionString = rsltString });
                }
                catch (Exception ex)
                {
                    Logger.Instance.LogError("Error occurred while selecting database", ex);
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Error Occurred.Please Check Logs.", "Database Connection", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            };
            worker.RunWorkerAsync();
        }

        private void AuthTypeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if ((AuthenticationType)AuthTypeComboBox.SelectedItem == AuthenticationType.Windows)
                CredentialGrid.IsEnabled = false;
            else
                CredentialGrid.IsEnabled = true;
        }

        private void cancelButton_Click(object sender, RoutedEventArgs e)
        {
            AuthTypeComboBox.ItemsSource = Enum.GetValues(typeof(AuthenticationType)).Cast<AuthenticationType>();
            AuthTypeComboBox.SelectedIndex = 0;
            serverNameTextBox.Clear();
            loginTextBox.Clear();
            passwordBox.Clear();
        }
    }
}

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
        public string Type { get; set; }
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
            var serverName = serverNameTextBox.Text.Trim();
            var username = loginTextBox.Text.Trim();
            var pwd = passwordBox.Password;
            var authType = AuthTypeComboBox.SelectedValue.ToString();
            #endregion

            if(ValidateInputs())
            {
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
                            var dbName=ShowSelectDBWindow(rsltString);
                            if (string.IsNullOrEmpty(dbName))
                            {
                                rsltString = string.Empty;
                            }
                            else
                            {
                                rsltString = DatabaseHelper.AddDatabaseToConnString(rsltString, dbName);
                                databaseTextBox.Text = dbName;
                                selectedDBGrid.Visibility = Visibility.Visible;
                                Logger.Instance.LogInfo("Selected Database - " + dbName);
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
        }
        private string ShowSelectDBWindow(string connString)
        {
            DatabaseSelectModal modalWindow = new DatabaseSelectModal();
            modalWindow.Type = this.Type;
            modalWindow.Owner = Window.GetWindow(this);
            modalWindow.ConnectionString = connString;
            modalWindow.ShowDialog();
            return modalWindow.DatabaseName;
        }

        private bool ValidateInputs()
        {
            if(string.IsNullOrWhiteSpace(serverNameTextBox.Text))
            {
                Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Please enter a valid server name.", "Database Connection", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                return false;
            }
            else if((AuthenticationType)AuthTypeComboBox.SelectedItem == AuthenticationType.SQLServer)
            {
                if(string.IsNullOrWhiteSpace(loginTextBox.Text))
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Please enter a valid User Name.", "Database Connection", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                    return false;
                }
                else if(string.IsNullOrWhiteSpace(passwordBox.Text))
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Please enter a valid Password", "Database Connection", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                    return false;
                }
            }
            return true;
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
            databaseTextBox.Clear();
            selectedDBGrid.Visibility = Visibility.Collapsed;
        }
        //private object GetEnumObjects()
        //{

        //}
    }
}

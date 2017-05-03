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
using System.Windows.Media;


namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for DatabaseConfigUserControl.xaml
    /// </summary>
    public partial class DatabaseConfigUserControl : UserControl
    {
        public Brush BGColor { get; set; }
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
        public void InitializeData(string connectionString)
        {
            if(!string.IsNullOrWhiteSpace(connectionString))
            {
                serverNameTextBox.Text = DatabaseHelper.GetServerName(connectionString);
                loginTextBox.Text = DatabaseHelper.GetUserName(connectionString);
                passwordBox.Password = DatabaseHelper.GetPassword(connectionString);
                databaseTextBox.Text = DatabaseHelper.GetDatabaseName(connectionString);
                AuthTypeComboBox.SelectedItem = DatabaseHelper.GetAuthenticationType(connectionString);
                selectedDBGrid.Visibility = Visibility.Visible;
            }
        }
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
                        //Check Connection String
                        if (rsltString == "")
                        {
                            Logger.Instance.LogInfo("Cannot Establish a Connection");
                            Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), Properties.Resources.DatabaseConfigUserControl_ConnectionFailed_Error, Properties.Resources.DatabaseConfigUserControl_MessageBox_Title, MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        else
                        {
                            Logger.Instance.LogInfo("Connection to the Database Server Completed.");
                            //Show Model Window to Select DB
                            var dbName=ShowSelectDBWindow(rsltString);

                            //Check If Database is selected
                            if (string.IsNullOrEmpty(dbName))
                            {
                                rsltString = string.Empty;
                            }
                            //If Connection and DB is Valid
                            else
                            {
                                rsltString = DatabaseHelper.AddDatabaseToConnString(rsltString, dbName);
                                databaseTextBox.Text = dbName;
                                selectedDBGrid.Visibility = Visibility.Visible;
                                connectButton.IsEnabled = false;
                                Logger.Instance.LogInfo("Selected Database - " + dbName);
                            }
                        }
                        OnConnectComplete?.Invoke(this, new ConnectionCompleteEventArgs { ConnectionString = rsltString });
                    }
                    catch (Exception ex)
                    {
                        Logger.Instance.LogError("Error occurred while selecting database", ex);
                        ErrorHandler.ShowFatalErrorMsgWtLog(Window.GetWindow(this), Properties.Resources.DatabaseConfigUserControl_MessageBox_Title);
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
                Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), Properties.Resources.DatabaseConfigUserControl_InvalidServerName_Error, Properties.Resources.DatabaseConfigUserControl_MessageBox_Title, MessageBoxButton.OK, MessageBoxImage.Exclamation);
                return false;
            }
            else if((AuthenticationType)AuthTypeComboBox.SelectedItem == AuthenticationType.SQLServer)
            {
                if(string.IsNullOrWhiteSpace(loginTextBox.Text))
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), Properties.Resources.DatabaseConfigUserControl_InvalidUserName_Error, Properties.Resources.DatabaseConfigUserControl_MessageBox_Title, MessageBoxButton.OK, MessageBoxImage.Exclamation);
                    return false;
                }
                else if(string.IsNullOrWhiteSpace(passwordBox.Text))
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), Properties.Resources.DatabaseConfigUserControl_InvalidPassword_Error, Properties.Resources.DatabaseConfigUserControl_MessageBox_Title, MessageBoxButton.OK, MessageBoxImage.Exclamation);
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

        private void resetButton_Click(object sender, RoutedEventArgs e)
        {
            AuthTypeComboBox.ItemsSource = Enum.GetValues(typeof(AuthenticationType)).Cast<AuthenticationType>();
            AuthTypeComboBox.SelectedIndex = 0;
            serverNameTextBox.Clear();
            loginTextBox.Clear();
            passwordBox.Clear();
            databaseTextBox.Clear();
            selectedDBGrid.Visibility = Visibility.Collapsed;
            connectButton.IsEnabled = true;
            OnConnectComplete?.Invoke(this, new ConnectionCompleteEventArgs { ConnectionString = string.Empty });
        }

        private void DatabaseConfigUserCntrl_Loaded(object sender, RoutedEventArgs e)
        {
            Resources["BGColor"] = BGColor;//Brushes.DarkGray;
        }
    }
}

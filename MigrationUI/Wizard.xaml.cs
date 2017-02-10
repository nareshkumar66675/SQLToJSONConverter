using Migration.Common;
using Migration.Configuration;
using MigrationTool.Views;
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
using Xceed.Wpf.Toolkit;

namespace MigrationTool
{
    /// <summary>
    /// Interaction logic for Wizard.xaml
    /// </summary>
    public partial class Wizard : Window
    {
        public static event EventHandler<UpdateCompleteEventArgs> UpdateComponents;
        public static event EventHandler StartComponentProcess;
        public class UpdateCompleteEventArgs : EventArgs
        {
            public bool status { get; set; }
        }
        public Wizard()
        {
            InitializeComponent();
            Logger.Instance.LogInfo("Data Migration Tool Initialized.");
            SrcConnectCntrl.OnConnectComplete += SrcExisiting_OnConnectComplete;
            AuthConnectCntrl.OnConnectComplete += AuthDB_OnConnectComplete;
            AssetConnectCntrl.OnConnectComplete += AssetDB_OnConnectComplete;
            Wiz.Next += Wiz_Next;
            Views.ComponentsProcessPage.ProcessCompleted += ComponentsProcessPage_ProcessCompleted;
        }

        private void ComponentsProcessPage_ProcessCompleted(object sender, EventArgs e)
        {
            Wiz.CurrentPage.CanSelectNextPage = true;
        }

        private void Wiz_Next(object sender, Xceed.Wpf.Toolkit.Core.CancelRoutedEventArgs e)
        {
            Logger.Instance.LogInfo("Navigating From Page - " + Wiz.CurrentPage.Name+" to Next Page. ");
            if (Wiz.CurrentPage == ComponentsSelectionPage)
            {
                var update = new UpdateCompleteEventArgs();
                    UpdateComponents?.Invoke(this, update);
                if(update.status)
                {
                    StartComponentProcess?.Invoke(this, e);
                    Wiz.CanCancel = false;
                    Wiz.CanSelectPreviousPage = false;
                }
                else
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show("Select atleast one components to proceed.", "Compoenents Selection", MessageBoxButton.OK, MessageBoxImage.Error);
                    Wiz.CurrentPage = AssetConnectionPage;
                }   
            }            
        }

        private void AuthDB_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                Common.ConnectionStrings.AuthConnectionString = e.ConnectionString;
                Logger.Instance.LogInfo("Auth Database Connection Completed");
            }      
        }
        private void AssetDB_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                Common.ConnectionStrings.AssetConnectionString = e.ConnectionString;
                Logger.Instance.LogInfo("Asset Database Connection Completed");
            }
        }
        private void SrcExisiting_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                Common.ConnectionStrings.SourceConnectionString = e.ConnectionString;
                Logger.Instance.LogInfo("Source Database Connection Completed");
            }
        }
        private bool ValidateConnectionString(string connectionString)
        {
            if (!string.IsNullOrEmpty(connectionString))
            {
                Wiz.CurrentPage.CanSelectNextPage = true;
                return true;
            }
            return false;
        }
    }
}

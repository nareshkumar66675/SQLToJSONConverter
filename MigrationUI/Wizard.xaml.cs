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
using Xceed.Wpf.Toolkit.Core;
using static MigrationTool.Views.ComponentsSelectUserControl;

namespace MigrationTool
{
    /// <summary>
    /// Interaction logic for Wizard.xaml
    /// </summary>
    public partial class Wizard : Window
    {
        #region VariableInitialization
        private ComponentsSelectUserControl AuthCompSelectCntrl = new ComponentsSelectUserControl();
        private ComponentsSelectUserControl AssetsCompSelectCntrl = new ComponentsSelectUserControl();
        private SiteSelectUserControl AssetSiteCntrl = new SiteSelectUserControl();
        private ComponentsProcessUserControl AuthCompProcessCntrl = new ComponentsProcessUserControl();
        private ComponentsProcessUserControl AssetCompProcessCntrl = new ComponentsProcessUserControl();
        #endregion
        public Wizard()
        {
            InitializeComponent();
            Logger.Instance.LogInfo("Data Migration Tool Initialized.");
            AuthCompProcessCntrl.ProcessCompleted += AuthComponents_ProcessCompleted;
            AssetCompProcessCntrl.ProcessCompleted += AssetCompProcessCntrl_ProcessCompleted;
            AuthCompSelectCntrl.OnComponentsSelectionChanged += AuthCompSelectCntrl_OnComponentsSelectionChanged;
            AssetsCompSelectCntrl.OnComponentsSelectionChanged += AssetsCompSelectCntrl_OnComponentsSelectionChanged;
        }

        private void AssetsCompSelectCntrl_OnComponentsSelectionChanged(object sender, ComponentsSelectionChangedEventArgs e)
        {
            AssetsComponentsSelectionPage.CanSelectNextPage = !e.IsEmpty;
        }
        private void AuthCompSelectCntrl_OnComponentsSelectionChanged(object sender, ComponentsSelectionChangedEventArgs e)
        {
            AuthComponentsSelectionPage.CanSelectNextPage = !e.IsEmpty;
        }
        private void AssetCompProcessCntrl_ProcessCompleted(object sender, EventArgs e)
        {
            Wiz.CurrentPage.CanSelectNextPage = true;
        }
        private void AuthComponents_ProcessCompleted(object sender, EventArgs e)
        {
            Wiz.CurrentPage.CanSelectNextPage = true;
        }
        private void Wiz_Next(object sender, CancelRoutedEventArgs e)
        {
            Logger.Instance.LogInfo("Navigating From Page - " + Wiz.CurrentPage.Name +" to Next Page. ");

            if(Wiz.CurrentPage==AuthConnectionPage)
            {
                AuthCompSelectCntrl.SourceComponents = Configurator.GetComponentsByGroup(GroupType.AUTH);
                AuthCompSelectCntrl.InitializeData();
                AddUserControlToPage(AuthComponentsSelectionPage, AuthCompSelectCntrl);
            }
            if(Wiz.CurrentPage==AuthComponentsSelectionPage)
            {
                var comp =AuthCompSelectCntrl.GetSelectedComponents();
                AddUserControlToPage(AuthComponentsProcessPage, AuthCompProcessCntrl);
                AuthCompProcessCntrl.StartComponentProcess(comp);
            }
            if (Wiz.CurrentPage == AssetConnectionPage)
            {
                Grid AssetSiteSelectGrid = new Grid();
                AssetSiteCntrl.LoadSites(GroupType.ASSET);     
                AddUserControlToPage(AssetSiteSelectionPage, AssetSiteCntrl);
            }
            if(Wiz.CurrentPage == AssetSiteSelectionPage)
            {
                var temp = string.Join(",", AssetSiteCntrl.GetSelectedSites().Select(t => t.Key));
                AssetsCompSelectCntrl.SourceComponents = Configurator.GetComponentsByGroup(GroupType.ASSET);
                AssetsCompSelectCntrl.InitializeData();
                AddUserControlToPage(AssetsComponentsSelectionPage, AssetsCompSelectCntrl);
                //Configurator.SetQueryParams()
            }
            if(Wiz.CurrentPage==AssetsComponentsSelectionPage)
            {
                var comp = AssetsCompSelectCntrl.GetSelectedComponents();
                AddUserControlToPage(AssetsComponentsProcessPage, AssetCompProcessCntrl);
                AssetCompProcessCntrl.StartComponentProcess(comp);
            }
            //if (Wiz.CurrentPage == ComponentsSelectionPage)
            //{
            //    var update = new UpdateCompleteEventArgs();
            //        UpdateComponents?.Invoke(this, update);
            //    if(update.status)
            //    {
            //        StartComponentProcess?.Invoke(this, e);
            //        Wiz.CanCancel = false;
            //        Wiz.CanSelectPreviousPage = false;
            //    }
            //    else
            //    {
            //        Xceed.Wpf.Toolkit.MessageBox.Show("Select atleast one components to proceed.", "Compoenents Selection", MessageBoxButton.OK, MessageBoxImage.Error);
            //        Wiz.CurrentPage = AssetConnectionPage;
            //    }   
            //}   
            if(Wiz.CurrentPage==AssetsComponentsSelectionPage)
            {
                var t=AssetsCompSelectCntrl.GetSelectedComponents();
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
        private void SkipAuthButton_Click(object sender, RoutedEventArgs e)
        {
            Wiz.CurrentPage = AssetConnectionPage;
        }
        private void SkipAssetButton_Click(object sender, RoutedEventArgs e)
        {
            Wiz.CurrentPage = LastPage;
        }
        private void AddUserControlToPage(WizardPage page,UserControl cntrl)
        {
            Grid tempGrid = new Grid();
            if(page.Content == null)
            {
                tempGrid.Children.Add(cntrl);
                page.Content = tempGrid;
            }
        }
    }
}

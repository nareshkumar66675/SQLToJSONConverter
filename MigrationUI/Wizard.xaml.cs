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
            SrcConnectCntrl.Type = "LEGACY";
            AuthConnectCntrl.Type = GroupType.AUTH.ToString();
            AssetConnectCntrl.Type = GroupType.ASSET.ToString();
            AuthCompProcessCntrl.ProcessCompleted += AuthComponents_ProcessCompleted;
            AssetCompProcessCntrl.ProcessCompleted += AssetCompProcessCntrl_ProcessCompleted;
            AuthCompSelectCntrl.OnComponentsSelectionChanged += AuthCompSelectCntrl_OnComponentsSelectionChanged;
            AssetsCompSelectCntrl.OnComponentsSelectionChanged += AssetsCompSelectCntrl_OnComponentsSelectionChanged;
        }
        private void Wiz_Next(object sender, CancelRoutedEventArgs e)
        {
            try
            {
                Logger.Instance.LogInfo("Navigating From Page - " + Wiz.CurrentPage.Name + " to Next Page. ");

                if (Wiz.CurrentPage == AuthConnectionPage)
                {
                    AuthCompSelectCntrl.SourceComponents = Configurator.GetComponentsByGroup(GroupType.AUTH);
                    AuthCompSelectCntrl.InitializeData(GroupType.AUTH);
                    AddUserControlToPage(AuthComponentsSelectionPage, AuthCompSelectCntrl);
                }
                if (Wiz.CurrentPage == AuthComponentsSelectionPage)
                {
                    var comp = AuthCompSelectCntrl.GetSelectedComponents();
                    AddUserControlToPage(AuthComponentsProcessPage, AuthCompProcessCntrl);
                    AuthCompProcessCntrl.StartComponentProcess(comp);
                }
                if (Wiz.CurrentPage == AssetConnectionPage)
                {
                    Grid AssetSiteSelectGrid = new Grid();
                    AssetSiteCntrl.LoadSites(GroupType.ASSET);
                    AddUserControlToPage(AssetSiteSelectionPage, AssetSiteCntrl);
                }
                if (Wiz.CurrentPage == AssetSiteSelectionPage)
                {
                    var temp = string.Join(",", AssetSiteCntrl.GetSelectedSites().Select(t => t.Key));
                    AssetsCompSelectCntrl.SourceComponents = Configurator.GetComponentsByGroup(GroupType.ASSET);
                    AssetsCompSelectCntrl.InitializeData(GroupType.ASSET);
                    AddUserControlToPage(AssetsComponentsSelectionPage, AssetsCompSelectCntrl);
                    //Configurator.SetQueryParams()
                }
                if (Wiz.CurrentPage == AssetsComponentsSelectionPage)
                {
                    var comp = AssetsCompSelectCntrl.GetSelectedComponents();
                    AddUserControlToPage(AssetsComponentsProcessPage, AssetCompProcessCntrl);
                    AssetCompProcessCntrl.StartComponentProcess(comp);
                }
                if (Wiz.CurrentPage == AssetsComponentsSelectionPage)
                {
                    var t = AssetsCompSelectCntrl.GetSelectedComponents();
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error While Navigating to Next Page", ex);
                Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Error Occured. Please Check Logs", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
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
                Common.ConnectionStrings.LegacyConnectionString = e.ConnectionString;
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
        private void Wiz_Help(object sender, RoutedEventArgs e)
        {
            Xceed.Wpf.Toolkit.MessageBox.Show(GetWindow(this), "Contact Support for Help", "Help", MessageBoxButton.OK, MessageBoxImage.Information);
        }
    }
}

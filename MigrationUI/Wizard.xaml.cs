using Migration.Common;
using Migration.Configuration;
using MigrationTool.Helpers;
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
using static Migration.Common.Common;

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
        private ComponentsProcessUserControl ReportsCompProcessCntrl = new ComponentsProcessUserControl();
        private bool CanClose = true;

        private const string crossImagePath= "/Resources/Cross.png";
        private const string tickImagePath = "/Resources/Tick.png";

        #endregion
        public Wizard()
        {
            InitializeComponent();
            Logger.Instance.LogInfo("Data Migration Tool Initialized.");
            AuthCompSelectCntrl.OnComponentsSelectionChanged += AuthCompSelectCntrl_OnComponentsSelectionChanged;
            AssetsCompSelectCntrl.OnComponentsSelectionChanged += AssetsCompSelectCntrl_OnComponentsSelectionChanged;
            AssetSiteCntrl.OnSitesSelectionChanged += AssetSiteCntrl_OnSitesSelectionChanged;
            AuthCompProcessCntrl.ProcessCompleted += AuthCompProcessCntrl_ProcessCompleted;
            AssetCompProcessCntrl.ProcessCompleted += AssetCompProcessCntrl_ProcessCompleted;
            ReportsCompProcessCntrl.ProcessCompleted += ReportsCompProcessCntrl_ProcessCompleted;
            UpdateDbConnectButtonIcon();
        }

        private void Wiz_Next(object sender, CancelRoutedEventArgs e)
        {
            try
            {
                Logger.Instance.LogInfo("Navigating From Page - " + Wiz.CurrentPage.Name + " to Next Page. ");

                //Auth Connection Page -> Auth Components Selection Page
                if (Wiz.CurrentPage == AuthConnectionPage)
                {
                    AuthCompSelectCntrl.SourceComponents = Configurator.GetComponentListByGroup(GroupType.AUTH);
                    AuthCompSelectCntrl.InitializeData(GroupType.AUTH);
                    AddUserControlToPage(AuthComponentsSelectionPage, AuthCompSelectCntrl);
                }
                // Auth Components Selection Page -> Auth Process Page
                else if (Wiz.CurrentPage == AuthComponentsSelectionPage)
                {
                    var comp = AuthCompSelectCntrl.GetSelectedComponents();
                    AddUserControlToPage(AuthComponentsProcessPage, AuthCompProcessCntrl);
                    CanClose = false;
                    AuthCompProcessCntrl.StartComponentProcess(comp);
                }
                // Asset Connection Page -> Asset Sites Selection Page
                else if (Wiz.CurrentPage == AssetConnectionPage)
                {
                    Grid AssetSiteSelectGrid = new Grid();
                    AssetSiteCntrl.LoadSites(GroupType.ASSET);
                    AddUserControlToPage(AssetSiteSelectionPage, AssetSiteCntrl);
                }
                // Asset Sites Selection Page -> Asset Components Selection Page
                else if (Wiz.CurrentPage == AssetSiteSelectionPage)
                {
                    var siteList = AssetSiteCntrl.GetSelectedSites().Select(t => t.Key);
                    Configurator.SetQueryParamsFrTrnsfrmWtParams(new List<string> { string.Join(",", siteList) });
                    AssetsCompSelectCntrl.SourceComponents = Configurator.GetComponentListByGroup(GroupType.ASSET);
                    AssetsCompSelectCntrl.SelectedSiteIDList = siteList.ToList();
                    AssetsCompSelectCntrl.InitializeData(GroupType.ASSET);
                    AddUserControlToPage(AssetsComponentsSelectionPage, AssetsCompSelectCntrl);
                }
                // Asset Components Selection Page -> Asset Process Page
                else if (Wiz.CurrentPage == AssetsComponentsSelectionPage)
                {
                    var comp = AssetsCompSelectCntrl.GetSelectedComponents();
                    AddUserControlToPage(AssetsComponentsProcessPage, AssetCompProcessCntrl);
                    CanClose = false;
                    AssetCompProcessCntrl.StartComponentProcess(comp);
                }
                //Report Connection Page -> Reports Process Page
                else if(Wiz.CurrentPage==ReportConnectionPage)
                {
                    AddUserControlToPage(ReportComponentsProcessPage, ReportsCompProcessCntrl);
                    if(CanProcessReport())
                    {
                        CanClose = false;
                        ReportsCompProcessCntrl.StartComponentProcess(Configurator.GetComponentsByGroup(GroupType.REPORT));
                    }
                    else
                    {
                        Xceed.Wpf.Toolkit.MessageBox.Show(GetWindow(this), "Please Migrate all Data before proceeding to Report", "Report Migration", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                        e.Cancel = true;
                    }
                }
                //Reports Process Page -> Migration Report Page
                else if(Wiz.CurrentPage==ReportComponentsProcessPage)
                {
                    ViewMigrationRptCntrl.ShowReport();
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error While Navigating to Next Page", ex);
                ErrorHandler.ShowFatalErrorMsgWtLog(Window.GetWindow(this), "Error");
            }
        }

        private bool CanProcessReport()
        {
            ////Auth Check 
            //var authCompledtedComp =DatabaseHelper.GetCompletedComponents(GroupType.AUTH, null).Count;
            //var authAllComp = Configurator.GetComponentListByGroup(GroupType.AUTH).Count;

            //if (authCompledtedComp != authAllComp)
            //{
            //    Logger.Instance.LogInfo($"Cannot Proceed with Report Tables - Missing Auth Components; All Componnets Count - { authAllComp} Completed Components - {authCompledtedComp}");
            //    return false;
            //}

            ////Asset Check
            //var allSites = DatabaseHelper.GetAllSitesFromLegacy();

            //var assetCompletedComp = DatabaseHelper.GetCompletedComponents(GroupType.ASSET, allSites.Select(t => t.Key).ToList()).Count;

            //var assetAllComp = Configurator.GetComponentListByGroup(GroupType.ASSET).Count;

            //if (assetCompletedComp != assetAllComp)
            //{
            //    Logger.Instance.LogInfo($"Cannot Proceed with Report Tables - Missing Asset Components ; All Componnets Count - { assetAllComp} Completed Components - {assetCompletedComp}");
            //    return false;
            //}
            return true;
        }

        private void AuthDB_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                ConnectionStrings.AuthConnectionString = e.ConnectionString;

                Logger.Instance.LogInfo("Auth Database Connection Completed");
            }      
        }
        private void AssetDB_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                ConnectionStrings.AssetConnectionString = e.ConnectionString;
                Logger.Instance.LogInfo("Asset Database Connection Completed");
            }
        }
        private void SrcExisiting_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                ConnectionStrings.LegacyConnectionString = e.ConnectionString;
                Logger.Instance.LogInfo("Source Database Connection Completed");
            }
        }
        private void ReportDBCntrl_OnConnectComplete(object sender, DatabaseConfigUserControl.ConnectionCompleteEventArgs e)
        {
            if (ValidateConnectionString(e.ConnectionString))
            {
                ConnectionStrings.ReportConnectionString = e.ConnectionString;
                Logger.Instance.LogInfo("Report Database Connection Completed");
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
            Wiz.CurrentPage = ReportConnectionPage;
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
        private void AssetsCompSelectCntrl_OnComponentsSelectionChanged(object sender, ComponentsSelectUserControl.ComponentsSelectionChangedEventArgs e)
        {
            AssetsComponentsSelectionPage.CanSelectNextPage = !e.IsEmpty;
        }
        private void AuthCompSelectCntrl_OnComponentsSelectionChanged(object sender, ComponentsSelectUserControl.ComponentsSelectionChangedEventArgs e)
        {
            AuthComponentsSelectionPage.CanSelectNextPage = !e.IsEmpty;
        }
        private void AssetCompProcessCntrl_ProcessCompleted(object sender, EventArgs e)
        {
            CanClose = true;
            Wiz.CurrentPage.CanSelectNextPage = true;
        }
        private void AuthCompProcessCntrl_ProcessCompleted(object sender, EventArgs e)
        {
            CanClose = true;
            Wiz.CurrentPage.CanSelectNextPage = true;
        }
        private void ReportsCompProcessCntrl_ProcessCompleted(object sender, EventArgs e)
        {
            CanClose = true;
            Wiz.CurrentPage.CanSelectNextPage = true;
        }
        private void AssetSiteCntrl_OnSitesSelectionChanged(object sender, SiteSelectUserControl.SitesSelectionChangedEventArgs e)
        {
            AssetSiteSelectionPage.CanSelectNextPage = !e.IsEmpty;
        }
        private void Wiz_Help(object sender, RoutedEventArgs e)
        {
            Xceed.Wpf.Toolkit.MessageBox.Show(GetWindow(this), "Contact Support for Help", "Help", MessageBoxButton.OK, MessageBoxImage.Information);
        }
        private void LogAppClose(object sender, RoutedEventArgs e)
        {
            Logger.Instance.LogInfo("Application has been terminated by user");
        }

        private void WizardWindow_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if(!CanClose)
            {
                Xceed.Wpf.Toolkit.MessageBox.Show(GetWindow(this), "Please wait for the process to complete.", "Close", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                e.Cancel = true;
            }
                
        }
        private BitmapImage GetDBStatusImage(string connString)
        {
            BitmapImage statusIcon = new BitmapImage();
            statusIcon.BeginInit();
            if (string.IsNullOrWhiteSpace(connString))
                statusIcon.UriSource = new Uri(crossImagePath, UriKind.Relative);
            else
                statusIcon.UriSource = new Uri(tickImagePath, UriKind.Relative);
            statusIcon.EndInit();

            return statusIcon;
        }

        private void authConnectBtn_Click(object sender, RoutedEventArgs e)
        {
            DatabaseConfigSubWindow win = new DatabaseConfigSubWindow();
            win.Owner = Application.Current.MainWindow;
            win.Closed += authDBSelect_Closed; ;
            win.Type = GroupType.AUTH.ToString();
            win.ShowDialog();
        }

        private void authDBSelect_Closed(object sender, EventArgs e)
        {
            ConnectionStrings.AuthConnectionString = (sender as DatabaseConfigSubWindow).GetConnectionString();
            UpdateDbConnectButtonIcon();
        }

        private void assetDBConnectBtn_Click(object sender, RoutedEventArgs e)
        {
            DatabaseConfigSubWindow win = new DatabaseConfigSubWindow();
            win.Owner = Application.Current.MainWindow;
            win.Closed += assetDBSelect_Closed;
            win.Type = GroupType.ASSET.ToString();
            win.ShowDialog();
        }

        private void assetDBSelect_Closed(object sender, EventArgs e)
        {
            ConnectionStrings.AssetConnectionString = (sender as DatabaseConfigSubWindow).GetConnectionString();
            UpdateDbConnectButtonIcon();
        }
        private void UpdateDbConnectButtonIcon()
        {
            try
            {
                assetDBStatusIcon.Source = GetDBStatusImage(ConnectionStrings.AssetConnectionString);
                authDBStatusIcon.Source = GetDBStatusImage(ConnectionStrings.AuthConnectionString);
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}

﻿using Migration.Common;
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
            AuthCompSelectCntrl.OnComponentsSelectionChanged += AuthCompSelectCntrl_OnComponentsSelectionChanged;
            AssetsCompSelectCntrl.OnComponentsSelectionChanged += AssetsCompSelectCntrl_OnComponentsSelectionChanged;
            AssetSiteCntrl.OnSitesSelectionChanged += AssetSiteCntrl_OnSitesSelectionChanged;
            AuthCompProcessCntrl.ProcessCompleted += AuthComponents_ProcessCompleted;
            AssetCompProcessCntrl.ProcessCompleted += AssetCompProcessCntrl_ProcessCompleted;
        }

        private void Wiz_Next(object sender, CancelRoutedEventArgs e)
        {
            try
            {
                Logger.Instance.LogInfo("Navigating From Page - " + Wiz.CurrentPage.Name + " to Next Page. ");

                //Auth Connection Page -> Auth Components Selection Page
                if (Wiz.CurrentPage == AuthConnectionPage)
                {
                    AuthCompSelectCntrl.SourceComponents = Configurator.GetComponentsByGroup(GroupType.AUTH);
                    AuthCompSelectCntrl.InitializeData(GroupType.AUTH);
                    AddUserControlToPage(AuthComponentsSelectionPage, AuthCompSelectCntrl);
                }
                // Auth Components Selection Page -> Auth Process Page
                else if (Wiz.CurrentPage == AuthComponentsSelectionPage)
                {
                    var comp = AuthCompSelectCntrl.GetSelectedComponents();
                    AddUserControlToPage(AuthComponentsProcessPage, AuthCompProcessCntrl);
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
                    AssetsCompSelectCntrl.SourceComponents = Configurator.GetComponentsByGroup(GroupType.ASSET);
                    AssetsCompSelectCntrl.SelectedSiteIDList = siteList.ToList();
                    AssetsCompSelectCntrl.InitializeData(GroupType.ASSET);
                    AddUserControlToPage(AssetsComponentsSelectionPage, AssetsCompSelectCntrl);
                }
                // Asset Components Selection Page -> Asset Process Page
                else if (Wiz.CurrentPage == AssetsComponentsSelectionPage)
                {
                    var comp = AssetsCompSelectCntrl.GetSelectedComponents();
                    AddUserControlToPage(AssetsComponentsProcessPage, AssetCompProcessCntrl);
                    AssetCompProcessCntrl.StartComponentProcess(comp);
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error While Navigating to Next Page", ex);
                Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Error Occured. Please Check Logs", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                Application.Current.Shutdown();
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
            Wiz.CurrentPage.CanSelectNextPage = true;
        }
        private void AuthComponents_ProcessCompleted(object sender, EventArgs e)
        {
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
    }
}

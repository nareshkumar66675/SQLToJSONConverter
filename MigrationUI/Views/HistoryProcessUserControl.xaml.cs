using Migration.Common;
using Migration.Configuration;
using Migration.Generate;
using Migration.Persistence;
using Migration.ProcessQueue;
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
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using static Migration.Common.Common;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for HistoryProcess.xaml
    /// </summary>
    public partial class HistoryProcessUserControl : UserControl
    {
        #region VariableInitialization
        DispatcherTimer siteTimer;
        DispatcherTimer overallTimer;

        DateTime siteStartTime;
        DateTime overallStartTime;

        private bool terminate = false;
        private int selectedSiteCount;
        private string siteCompletedText = "{0} of {1} Completed";
        public event EventHandler ProcessStarted;
        public event EventHandler ProcessCompleted;
        //public Dictionary<string, string> NotMigratedSites { get; set; }
        public Dictionary<string, string> SelectedSites { get; set; }
        public KeyValuePair<string, string> CurrentSite { get; set; }
        public Dictionary<string, string> FailedSites { get; set; }
        public Dictionary<string, string> MigratedSites { get; set; } 
        #endregion
        public HistoryProcessUserControl()
        {
            InitializeComponent();
            InitialiazeTimers();
            stopButton.IsEnabled = false;
        }

        private void InitialiazeTimers()
        {
            //Site Timer
            siteTimer = new DispatcherTimer();
            siteTimer.Interval = TimeSpan.FromSeconds(1);
            siteTimer.Tick += SiteTimer_Tick;
            //Overall Timer
            overallTimer = new DispatcherTimer();
            overallTimer.Interval = TimeSpan.FromSeconds(1);
            overallTimer.Tick += OverallTimer_Tick; 
        }

        public void InitializeData()
        {
            FailedSites = new Dictionary<string, string>();
            MigratedSites = new Dictionary<string, string>();
            CurrentSite = new KeyValuePair<string, string>();
            selectedSiteCount= SelectedSites.Count();
            OverallProgress.Maximum = selectedSiteCount;

            CompletedListBox.ItemsSource = MigratedSites;
            NotCompletedListBox.ItemsSource = SelectedSites;//.ToDictionary(t=>t.Key,t=>t.Value);
            FailedSitesListBox.ItemsSource = FailedSites;
            NotCompletedListBox.DisplayMemberPath = "Value"; 
            CompletedListBox.DisplayMemberPath = "Value";
            FailedSitesListBox.DisplayMemberPath = "Value";
            OverallProgress.Value = 0;//SelectedSites.Count() - NotMigratedSites.Count();

            OverallStatusText.Text = string.Format(siteCompletedText, 0, selectedSiteCount);

        }

        private void OverallTimer_Tick(object sender, EventArgs e)
        {
            overallProgressDuration.Text= (DateTime.Now - overallStartTime).ToString(@"hh\:mm\:ss");
        }

        private void SiteTimer_Tick(object sender, EventArgs e)
        {
            siteProgressDuration.Text = (DateTime.Now - siteStartTime).ToString(@"hh\:mm\:ss");
        }

        private void startButton_Click(object sender, RoutedEventArgs e)
        {
            ProcessStarted?.Invoke(sender, e);
            BackgroundWorker worker = new BackgroundWorker();
            worker.DoWork += Worker_StartProcess;
            worker.RunWorkerAsync();
            startButton.IsEnabled = false;
            stopButton.IsEnabled = true;
            statusBar.Text = "Press Stop Button to Terminate the Process";
        }

        private async void Worker_StartProcess(object sender, DoWorkEventArgs e)
        {
            overallStartTime = DateTime.Now;
            overallTimer.Start();
            foreach (var site in SelectedSites.ToDictionary(t => t.Key, t => t.Value))
            {
                Logger.Instance.LogInfo($"History Migration Started for Site - {site.Value}({site.Key})");
                if(!terminate)
                {
                    siteStartTime = DateTime.Now;
                    Dispatcher.Invoke(() => SiteProgress.Foreground = Brushes.LightGreen);
                    
                    siteTimer.Start();
                    CurrentSite = site;
                    Dispatcher.Invoke(() => SiteNameText.Text = CurrentSite.Value);
                    Configurator.SetQueryParamsFrTrnsfrmWtParams(GroupType.HISTORY, new List<string> { string.Join(",", site.Key) });

                    Generate generate = new Generate();
                    Persist persist = new Persist();

                    var progressGenerate = new Progress<ProcessStatus>(GenerateProgress);
                    var progressPersist = new Progress<ProcessStatus>(PersistProgress);

                    //Starting Generate and Persist Parallely
                    Task genTask = generate.Start(Configurator.GetComponentsByGroup(GroupType.HISTORY), progressGenerate);
                    Task persisTask = persist.Start(progressPersist);

                    await genTask;
                    await persisTask;
                    //Thread.Sleep(100);
                    //GenerateProgress(new ProcessStatus("AST_HISTORY", 0, Status.Running));
                    //Thread.Sleep(1500);
                    //if (int.Parse(site.Key) % 2 == 0) GenerateProgress(new ProcessStatus("AST_HISTORY", 100, Status.Failed)); else GenerateProgress(new ProcessStatus("AST_HISTORY", 100, Status.Success));
                    ////Thread.Sleep(1000);
                    //PersistProgress(new ProcessStatus("AST_HISTORY", 0, Status.Running));
                    //Thread.Sleep(1500);
                    //if (int.Parse(site.Key) % 2 == 0) PersistProgress(new ProcessStatus("AST_HISTORY", 100, Status.Failed)); else PersistProgress(new ProcessStatus("AST_HISTORY", 100, Status.Success));
                    //Thread.Sleep(100);
                    siteTimer.Stop();
                }
                else
                {
                    Dispatcher.Invoke(() => statusBar.Text = "History Migration Stopped Successfully");
                    break;
                }
            }
            overallTimer.Stop();
            Dispatcher.Invoke(() => 
            {
                startButton.IsEnabled = false;
                stopButton.IsEnabled = false;
                ProcessCompleted?.Invoke(sender, e);
                if (!terminate && FailedSites.Count == 0)
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "History Migration Completed Successfully", "History Process", MessageBoxButton.OK, MessageBoxImage.Information);
                    statusBar.Text = "History Migration Completed Successfully";
                }
                else if(FailedSites.Count > 0)
                {
                    string message = $"{ FailedSites.Count} Sites Failed.";
                    statusBar.Text = "History Migration Completed With Errors";
                    ErrorHandler.ShowErrorMsgWtLog(Window.GetWindow(this), "History Process", message);
                }
            });
        }

        private void PersistProgress(ProcessStatus processStatus)
        {
            Dispatcher.Invoke(() =>
            {
                var t = CurrentSite;
                SiteProgress.Value += processStatus.PercentCompleted / 2;
                if (processStatus.Status == Status.Failed)
                {
                    SiteProgress.Value = 100;
                    SiteProgress.Foreground = Brushes.Red;
                    OverallProgress.Value++;
                    OverallStatusText.Text = string.Format(siteCompletedText, OverallProgress.Value, selectedSiteCount);
                    UpdateFailedSiteList();
                }
                else if (processStatus.Status == Status.Success)
                {
                    OverallProgress.Value++;
                    OverallStatusText.Text = string.Format(siteCompletedText, OverallProgress.Value, selectedSiteCount);
                    UpdateCompletedSiteList();
                }
            });
        }

        private void GenerateProgress(ProcessStatus processStatus)
        {
            Dispatcher.Invoke(() =>
            {
                SiteProgress.Value = processStatus.PercentCompleted / 2;
                if (processStatus.Status == Status.Failed)
                {
                    //rcrd.SetField("Status", processStatus.Status.GetDescription());
                    SiteProgress.Value = 100;
                    SiteProgress.Foreground = Brushes.Red;
                    UpdateFailedSiteList();
                }
                if (!(processStatus.Status == Status.Success))
                {
                    //rcrd.SetField("Status", processStatus.Status.GetDescription());
                }
            });
        }

        private Dictionary<string, string> GetNotMigratedSites(GroupType group, Dictionary<string, string> allSites)
        {
            Dictionary<string, string> allSiteTemp =new Dictionary<string, string>();
            try
            {
                SetMigratedSites(group, allSites);
                allSiteTemp = allSites.ToDictionary(t=>t.Key,t=>t.Value);
                foreach (var item in MigratedSites)
                {
                    allSiteTemp.Remove(item.Key);
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While retrieving not migrated Sites", ex);
            }
            allSiteTemp.OrderBy(t => t.Value);
            return allSiteTemp;
        }

        private void SetMigratedSites(GroupType group, Dictionary<string, string> allSites)
        {
            var migratedIds = DatabaseHelper.GetMigratedSites(ConnectionStrings.GetConnectionString(group));
            migratedIds.ForEach(id =>
            {
                var temp = allSites.Where(site => site.Key == id).FirstOrDefault();
                MigratedSites.Add(temp.Key,temp.Value);
            });

        }
        private void UpdateCompletedSiteList()
        {
            try
            {
                SelectedSites.Remove(CurrentSite.Key);
                NotCompletedListBox.Items.Refresh();
                if (!MigratedSites.ContainsKey(CurrentSite.Key))
                {
                    MigratedSites.Add(CurrentSite.Key, CurrentSite.Value);
                    CompletedListBox.Items.Refresh();
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Update completed SiteList Failed", ex);
            }
        }
        private void UpdateFailedSiteList()
        {
            try
            {
                SelectedSites.Remove(CurrentSite.Key);
                NotCompletedListBox.Items.Refresh();
                if (!FailedSites.ContainsKey(CurrentSite.Key))
                {
                    FailedSites.Add(CurrentSite.Key, CurrentSite.Value);
                    FailedSitesListBox.Items.Refresh();
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Update failed SiteList Failed", ex);
            }
        }
        private void stopButton_Click(object sender, RoutedEventArgs e)
        {
            var rslt =Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Do you wish to terminate the process ?", "History Process", MessageBoxButton.YesNo, MessageBoxImage.Exclamation);
            if(rslt== MessageBoxResult.Yes)
            {
                terminate = true;
                stopButton.IsEnabled = false;
                statusBar.Text = "Stopping Process!!! Please Wait....";
            }
        }
        private void HistoryProcessUserControl_Loaded(object sender, RoutedEventArgs e)
        {
            if (SelectedSites != null && MigratedSites != null)
                if (SelectedSites.Count == MigratedSites.Count)
                {
                    Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "All Items has been Migrated.\nPlease Proceed to Next page.", "History Process", MessageBoxButton.OK, MessageBoxImage.Information);
                    startButton.IsEnabled = false;
                    stopButton.IsEnabled = false;
                    ProcessCompleted?.Invoke(sender, e);
                }
        }
    }
}

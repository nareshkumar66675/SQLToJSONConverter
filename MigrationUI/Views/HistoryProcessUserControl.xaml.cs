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
        DispatcherTimer siteTimer;
        DispatcherTimer overallTimer;

        DateTime siteStartTime;
        DateTime overallStartTime;

        private bool terminate = false;

        private string siteCompletedText= "{0} of {1} Completed";

        public Dictionary<string, string> NotMigratedSites { get; set; }
        public Dictionary<string, string> AllSites { get; set; }
        public KeyValuePair<string,string> CurrentSite { get; set; }
        public HistoryProcessUserControl()
        {
            InitializeComponent();
            InitialiazeTimers();
            //ProgressGrid.IsEnabled = false;
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
            AllSites = DatabaseHelper.GetAllSitesFromLegacy();
            OverallProgress.Maximum = AllSites.Count();

            NotMigratedSites = GetNotMigratedSites(GroupType.HISTORY, AllSites);
            OverallProgress.Value = AllSites.Count() - NotMigratedSites.Count();

            OverallStatusText.Text = string.Format(siteCompletedText, AllSites.Count() - NotMigratedSites.Count(), AllSites.Count());
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
            BackgroundWorker worker = new BackgroundWorker();
            //worker.WorkerReportsProgress = true;
            worker.DoWork += Worker_StartProcess;
            //worker.ProgressChanged += worker_ProgressChanged;
            worker.RunWorkerAsync();
        }

        private async void Worker_StartProcess(object sender, DoWorkEventArgs e)
        {
            Dispatcher.Invoke(() => 
            {
                startButton.IsEnabled = false;
                stopButton.IsEnabled = true;
                statusBar.Text = "Press Stop Button to Terminate the Process";
            });
            overallStartTime = DateTime.Now;
            overallTimer.Start();
            foreach (var site in NotMigratedSites)
            {
                if(!terminate)
                {
                    siteStartTime = DateTime.Now;
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
                    Thread.Sleep(100);
                    //GenerateProgress(new ProcessStatus("AST_HISTORY", 0, Status.Running));
                    //Thread.Sleep(1000);
                    //GenerateProgress(new ProcessStatus("AST_HISTORY", 100, Status.Success));
                    ////Thread.Sleep(1000);
                    //PersistProgress(new ProcessStatus("AST_HISTORY", 0, Status.Running));
                    //Thread.Sleep(1000);
                    //PersistProgress(new ProcessStatus("AST_HISTORY", 100, Status.Success));
                    //Thread.Sleep(100);
                    siteTimer.Stop();
                }
                else
                {
                    Dispatcher.Invoke(() => statusBar.Text = "Process Stopped Successfully");
                    break;
                }
            }
            overallTimer.Stop();
            Dispatcher.Invoke(() => { startButton.IsEnabled = false; stopButton.IsEnabled = false; });
        }

        private void PersistProgress(ProcessStatus processStatus)
        {
            Dispatcher.Invoke(() =>
            {
                var t = CurrentSite;
                SiteProgress.Value += processStatus.PercentCompleted / 2;
                if (processStatus.Status == Status.Failed)
                {
                    //rcrd.SetField("Status", processStatus.Status.GetDescription());
                    SiteProgress.Value = 100;
                    SiteProgress.Foreground = Brushes.Red;
                }
                else if (processStatus.Status == Status.Success)
                {
                    OverallProgress.Value++;
                    OverallStatusText.Text = string.Format(siteCompletedText, OverallProgress.Value, AllSites.Count());
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
                allSiteTemp = allSites.ToDictionary(t=>t.Key,t=>t.Value);
                var migratedSites = DatabaseHelper.GetMigratedSites(ConnectionStrings.GetConnectionString(group));
                migratedSites.ForEach(t => allSiteTemp.Remove(t));
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error occurred While retrieving not migrated Sites", ex);
            }
            allSiteTemp.OrderBy(t => t.Value);
            return allSiteTemp;
        }

        private void stopButton_Click(object sender, RoutedEventArgs e)
        {
            var rslt =Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), "Do you wish to terminate the process ?", "History Process", MessageBoxButton.YesNo, MessageBoxImage.Exclamation);
            if(rslt== MessageBoxResult.Yes)
            {
                terminate = true;
                statusBar.Text = "Stopping Process!!! Please Wait....";
            }
        }
    }
}

using Migration.Common;
using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.Generate;
using Migration.Persistence;
using Migration.PreRequisite;
using Migration.ProcessQueue;
using MigrationTool.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media;
using Xceed.Wpf.DataGrid;
using Xceed.Wpf.Toolkit;
using static Migration.Common.Common;

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for ComponentsProcessUserControl.xaml
    /// </summary>
    public partial class ComponentsProcessUserControl : UserControl
    {
        public DataTable GridDataTable { get; set; }
        public event EventHandler ProcessCompleted;
        public ComponentsProcessUserControl()
        {
            InitializeComponent();
            InitializeDataGrid();

        }
        private void InitializeDataGrid()
        {
            try
            {
                DataTable dataTable = new DataTable();
                dataTable.Columns.Add(new DataColumn(Properties.Resources.ComponentsProcessUserControl_Group_ColName));
                dataTable.Columns.Add(new DataColumn(Properties.Resources.ComponentsProcessUserControl_DisplayName_ColName));
                dataTable.Columns.Add(new DataColumn(Properties.Resources.ComponentsProcessUserControl_Progress_ColName, typeof(ProgressBar)));
                dataTable.Columns.Add(new DataColumn(Properties.Resources.ComponentsProcessUserControl_Status_ColName));
                dataTable.Columns.Add(new DataColumn(Properties.Resources.ComponentsProcessUserControl_Name_ColName));
                GridDataTable = dataTable;
                ProcessGrid.ItemsSource = dataTable.AsDataView();
                ProcessGrid.ReadOnly = true;
                ProcessGrid.Columns[0].Visible = false;
                ProcessGrid.Columns[4].Visible = false;
                ProcessGrid.Columns[1].Width = new ColumnWidth(180, ColumnWidthUnitType.Pixel);
                ProcessGrid.Columns[2].Width = new ColumnWidth(230, ColumnWidthUnitType.Pixel);
                //ProcessGrid.Columns[2].Width = new ColumnWidth(130, ColumnWidthUnitType.Pixel);
                ProcessGrid.Columns[0].AllowSort = false;
                ProcessGrid.Columns[1].AllowSort = false;
                ProcessGrid.Columns[2].AllowSort = false;
                ProcessGrid.Columns[3].AllowSort = false;
                ProcessGrid.ItemScrollingBehavior = ItemScrollingBehavior.Immediate;
                ICollectionView cvTasks = CollectionViewSource.GetDefaultView(ProcessGrid.ItemsSource);
                if (cvTasks != null && cvTasks.CanGroup == true)
                {
                    cvTasks.GroupDescriptions.Clear();
                    cvTasks.GroupDescriptions.Add(new PropertyGroupDescription("Group"));
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error While Initializing DataGrid For Components Process",ex);
                ErrorHandler.ShowFatalErrorMsgWtLog(Window.GetWindow(this), Properties.Resources.ComponentsProcessUserControl_MessageBox_Title);
            }
        }

        public void StartComponentProcess(Components components)
        {
            try
            {
                if (GridDataTable.Rows.Count == 0)
                {
                    components.Group.ForEach(grp =>
                    {
                        grp.Component.ForEach(COMP =>
                        {
                            ProgressBar temp = new ProgressBar();
                            temp.Name = COMP.Name + "Progress";
                            temp.Minimum = 0; temp.Maximum = 100;
                            GridDataTable.Rows.Add(grp.Name.GetDescription(), COMP.DisplayName, new ProgressBar(), Status.NotStarted.GetDescription(), COMP.Name);
                        });
                    });
                    ProcessGrid.Items.Refresh();
                    BackgroundWorker worker = new BackgroundWorker();
                    //worker.WorkerReportsProgress = true;
                    worker.DoWork += Worker_StartProcess;
                    //worker.ProgressChanged += worker_ProgressChanged;
                    worker.RunWorkerAsync(components);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        private async void Worker_StartProcess(object sender, DoWorkEventArgs e)
        {
            var components = e.Argument as Components;
            try
            {
                //Execute PreRequistes
                await RunPrequisites();

                Generate generate = new Generate();
                Persist persist = new Persist();

                var progressGenerate = new Progress<ProcessStatus>(GenerateProgress);
                var progressPersist = new Progress<ProcessStatus>(PersistProgress);

                //Starting Generate and Persist Parallely
                Task genTask = generate.Start(components, progressGenerate);
                Task persisTask = persist.Start(progressPersist);

                await genTask;
                await persisTask;

                Thread.Sleep(100);
                Dispatcher.Invoke(() =>
                {
                    ProcessCompleted?.Invoke(sender, e);
                    ShowCompletedMessage();
                });
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Processing Components Failed for Group -" + components.Group.FirstOrDefault().Name??"", ex);

                Dispatcher.Invoke(() =>
                {
                    ProcessingIndicator.IsBusy = false;
                    ProcessCompleted?.Invoke(sender, e);
                    if (ex.Message == "PreRequisites Execution Failed")
                        ErrorHandler.ShowErrorMsgWtLog(Window.GetWindow(this), Properties.Resources.ComponentsProcessUserControl_PreReqFailed_Title, Properties.Resources.ComponentsProcessUserControl_PreReqFailed_Message);
                    else
                        Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), Properties.Resources.ComponentsProcessUserControl_ProcessFailed_Error, Properties.Resources.ComponentsProcessUserControl_MessageBox_Title, MessageBoxButton.OK, MessageBoxImage.Error);
                });
            }
        }

        private async Task RunPrequisites()
        {
            //Execute PreRequisites if Settings allow
            if(AppSettings.RunPreRequisites)
            {
                var progressPreRequisite = new Progress<PreReqProgress>(PreRequisiteProgress);
                Dispatcher.Invoke(() =>
                {
                    ProcessingIndicator.IsBusy = true;
                    processText.Text = string.Empty;
                    preReqProcessBar.Visibility = Visibility.Hidden;
                });
                bool result = false; ;

                if (GridDataTable.AsEnumerable().Count(t => (t.Field<string>("Group") == GroupType.ASSET.GetDescription())) > 0)
                   result = await Task.Run(() => PreRequisiteFactory.GetPreRequistes(GroupType.ASSET).Start(progressPreRequisite));
                else if (GridDataTable.AsEnumerable().Count(t => (t.Field<string>("Group") == GroupType.AUTH.GetDescription())) > 0)
                   result = await Task.Run(() => PreRequisiteFactory.GetPreRequistes(GroupType.AUTH).Start(progressPreRequisite));
                else if (GridDataTable.AsEnumerable().Count(t => (t.Field<string>("Group") == GroupType.REPORT.GetDescription())) > 0)
                    result = await Task.Run(() => PreRequisiteFactory.GetPreRequistes(GroupType.REPORT).Start(progressPreRequisite));

                if (!result)
                {
                    throw new Exception("PreRequisites Execution Failed");
                }
            }
        }

        private void PersistProgress(ProcessStatus processStatus)
        {
            try
            {
                var rcrd = GridDataTable.AsEnumerable().Where(t => (t.Field<string>("Name") == processStatus.ComponentName)).Single();
                Dispatcher.Invoke(() =>
                {
                    var progressBar = rcrd.Field<ProgressBar>("Progress");
                    progressBar.Value += processStatus.PercentCompleted / 2;
                    if (processStatus.Status == Status.Failed)
                    {
                        rcrd.SetField("Status", processStatus.Status.GetDescription());
                        progressBar.Value = 100;
                        progressBar.Foreground = Brushes.Red;
                    }
                    else
                    {
                        rcrd.SetField("Status", processStatus.Status.GetDescription());
                    }
                    ProcessGrid.Items.Refresh();
                }
                );
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred While Updating Persist Progress Bars", ex);
            }
        }

        private void GenerateProgress(ProcessStatus processStatus)
        {
            try
            {
                var rcrd = GridDataTable.AsEnumerable().Where(t => (t.Field<string>("Name") == processStatus.ComponentName)).Single();
                Dispatcher.Invoke(() =>
                {
                    var progressBar = rcrd.Field<ProgressBar>("Progress");
                    progressBar.Value += processStatus.PercentCompleted / 2;
                    if (processStatus.Status == Status.Failed)
                    {
                        rcrd.SetField("Status", processStatus.Status.GetDescription());
                        progressBar.Value = 100;
                        progressBar.Foreground = Brushes.Red;
                    }
                    if (!(processStatus.Status == Status.Success))
                    {
                        rcrd.SetField("Status", processStatus.Status.GetDescription());
                    }
                    ProcessGrid.Items.Refresh();
                }
                );
            }
            catch (Exception ex) 
            {
                Logger.Instance.LogError("Error Occured While Updating Generate Progress Bars", ex);
            }
        }
        private void PreRequisiteProgress(PreReqProgress preReqStatus)
        {
            Dispatcher.Invoke(() =>
            {
                if (preReqStatus.TotalCount == preReqStatus.CompletedCount)
                {
                    ProcessingIndicator.IsBusy = false; ;
                }
                else
                {
                    var failedPreReq = preReqStatus.Completed.Where(t => t.Status == PreReqStatus.Failed);
                    if(failedPreReq.Count()>0)
                    {
                        Logger.Instance.LogError($"PreRequisites Failed - {string.Join(",", failedPreReq.Select(t => t.Name).ToList())}", null);
                        ProcessingIndicator.IsBusy = false;
                    }
                    else
                    {
                        preReqProcessBar.Visibility = Visibility.Visible;
                        processText.Text = string.Format(Properties.Resources.ComponentsProcessUserControl_PreReqStatus_Message, preReqStatus.CompletedCount, preReqStatus.TotalCount);
                        preReqProcessBar.Maximum = preReqStatus.TotalCount;
                        preReqProcessBar.Value = preReqStatus.CompletedCount;
                    }
                }
            });
        }

        private void ShowCompletedMessage()
        {
            string message = string.Empty;
            var failedCount = GridDataTable.AsEnumerable().Count(t => (t.Field<string>("Status") == Status.Failed.GetDescription()));
            if (failedCount > 0)
            {
                message = string.Format(Properties.Resources.ComponentsProcessUserControl_ProcessFailed_Message, failedCount, GridDataTable.AsEnumerable().Count());
                ErrorHandler.ShowErrorMsgWtLog(Window.GetWindow(this), Properties.Resources.ComponentsProcessUserControl_MessageBox_Title, message);
            }
            else
            {
                message = Properties.Resources.ComponentsProcessUserControl_ProcessSuccess_Message;
                Xceed.Wpf.Toolkit.MessageBox.Show(Window.GetWindow(this), message, Properties.Resources.ComponentsProcessUserControl_MessageBox_Title, MessageBoxButton.OK, MessageBoxImage.Information);
            }        
            Logger.Instance.LogInfo(message);
        }
    }
}

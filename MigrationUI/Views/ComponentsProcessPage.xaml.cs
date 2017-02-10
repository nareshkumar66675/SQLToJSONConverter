﻿using Migration.Common;
using Migration.Configuration;
using Migration.Generate;
using Migration.Persistence;
using Migration.ProcessQueue;
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

namespace MigrationTool.Views
{
    /// <summary>
    /// Interaction logic for ComponentsProcessPage.xaml
    /// </summary>
    public partial class ComponentsProcessPage : Page
    {
        public DataTable table { get; set; }
        public static event EventHandler ProcessCompleted;
        public ComponentsProcessPage()
        {
            InitializeComponent();
            Wizard.StartComponentProcess += Wizard_StartComponentProcess;
            InitializeDataGrid();

        }
        private void InitializeDataGrid()
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add(new DataColumn("Group"));
            dataTable.Columns.Add(new DataColumn("DisplayName"));
            dataTable.Columns.Add(new DataColumn("Progress", typeof(ProgressBar)));
            dataTable.Columns.Add(new DataColumn("Status"));
            dataTable.Columns.Add(new DataColumn("Name"));
            table = dataTable;
            ProcessGrid.ItemsSource = dataTable.AsDataView();
            ProcessGrid.ReadOnly = true;
            ProcessGrid.Columns[0].Visible = false;
            ProcessGrid.Columns[4].Visible = false;
            ProcessGrid.Columns[1].Width = new ColumnWidth(1, ColumnWidthUnitType.Star);
            ProcessGrid.Columns[2].Width = new ColumnWidth(2, ColumnWidthUnitType.Star);
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

        private void Wizard_StartComponentProcess(object sender, EventArgs e)
        {
            if(table.Rows.Count==0)
            {
                Configurator.SelectedComponents.Group.ForEach(grp =>
                {
                    grp.Component.ForEach(COMP =>
                    {
                        ProgressBar temp = new ProgressBar();
                        temp.Name = COMP.Name + "Progress";
                        temp.Minimum = 0; temp.Maximum = 100;
                        table.Rows.Add(grp.Name.ToString(), COMP.DisplayName, new ProgressBar(), Status.NotStarted.ToString(),COMP.Name);
                    });
                });
                ProcessGrid.Items.Refresh();                
                BackgroundWorker worker = new BackgroundWorker();
                //worker.WorkerReportsProgress = true;
                worker.DoWork += Worker_StartProcess;
                //worker.ProgressChanged += worker_ProgressChanged;

                worker.RunWorkerAsync();
            }

        }

        private async void Worker_StartProcess(object sender, DoWorkEventArgs e)
        {
            try
            {   
                Generate generate = new Generate();
                Persist persist = new Persist();
                var progressGenerate = new Progress<ProcessStatus>(GenerateProgress);
                var progressPersist = new Progress<ProcessStatus>(PersistProgress);

                //Task t1 = Task.Factory.StartNew(() => gen.Start(Configurator.SelectedComponents, progressGenerate));
                //Task t2 = Task.Factory.StartNew(() => ps.Start(progressPersist));
                Task genTask = generate.Start(Configurator.SelectedComponents, progressGenerate);
                Task persisTask = persist.Start(progressPersist);

                await genTask;
                await persisTask;

                Dispatcher.Invoke(() =>
                {
                    ProcessCompleted?.Invoke(sender, e);
                    Xceed.Wpf.Toolkit.MessageBox.Show("Completed", "Process Status", MessageBoxButton.OK, MessageBoxImage.Information);
                    Logger.Instance.LogInfo("Components Processs Completed");
                });
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed");
            }
        }

        private void PersistProgress(ProcessStatus processStatus)
        {
            var rcrd = table.AsEnumerable().Where(t => (t.Field<string>("Name") == processStatus.ComponentName)).Single();
            Dispatcher.Invoke(() =>
            {
                rcrd.Field<ProgressBar>("Progress").Value += processStatus.PercentCompleted / 2;
                rcrd.SetField("Status", processStatus.Status.ToString());
                ProcessGrid.Items.Refresh();
            }
            );
        }

        private void GenerateProgress(ProcessStatus processStatus)
        {
            var rcrd = table.AsEnumerable().Where(t=> (t.Field<string>("Name")==processStatus.ComponentName)).Single();
            Dispatcher.Invoke(() =>
            {
                var progressBar = rcrd.Field<ProgressBar>("Progress");
                progressBar.Value += processStatus.PercentCompleted /2;
                if(processStatus.Status==Status.Failed)
                {
                    rcrd.SetField("Status", processStatus.Status.ToString());  
                    progressBar.Value = 100;
                    progressBar.Foreground = Brushes.Red;
                }
                if(!(processStatus.Status == Status.Success))
                {
                    rcrd.SetField("Status", processStatus.Status.ToString());
                }
                //else
                //    ProcessGrid.Columns[3]
                ProcessGrid.Items.Refresh();
            }
            );
        }
    }
}

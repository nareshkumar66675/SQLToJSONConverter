using Migration.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace MigrationTool.Helpers
{
    public static class ErrorHandler
    {
        /// <summary>
        /// Shows an Error Message and Terminates the Application.
        /// Option is given to view Log File.
        /// </summary>
        /// <param name="window">Window</param>
        /// <param name="messageBoxTitle">Message Box Title</param>
        public static void ShowFatalErrorMesage(Window window,string messageBoxTitle)
        {
            var result= Xceed.Wpf.Toolkit.MessageBox.Show(window, "Error Occurred. Terminating Application.\nClick Yes to View Log", messageBoxTitle, MessageBoxButton.YesNo, MessageBoxImage.Error);

            Logger.Instance.LogInfo("Application Terminated Abnormally");

            if(result==MessageBoxResult.Yes)
            {
                System.Diagnostics.Process.Start(Logger.LogFileName);
            }
            Application.Current.Shutdown();
        }
    }
}

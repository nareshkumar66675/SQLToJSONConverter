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
        /// <param name="window">Window - for Message Box Positioning</param>
        /// <param name="messageBoxTitle">Message Box Title</param>
        public static void ShowFatalErrorMsgWtLog(Window window,string messageBoxTitle)
        {
            var result= Xceed.Wpf.Toolkit.MessageBox.Show(window,string.Format(Properties.Resources.FatalErrorWithLog_Message,Environment.NewLine), messageBoxTitle, MessageBoxButton.YesNo, MessageBoxImage.Error);

            Logger.Instance.LogInfo("Application Terminated Abnormally");

            if(result==MessageBoxResult.Yes)
                ShowLog();

            Application.Current.Shutdown();
        }

        /// <summary>
        /// Shows Error Message with an option to check Log
        /// </summary>
        /// <param name="window">Window - for Message Box Positioning</param>
        /// <param name="messageBoxTitle">Message Box Title</param>
        /// <param name="message">Custom Message</param>
        public static void ShowErrorMsgWtLog(Window window, string messageBoxTitle,string message)
        {
            var result = Xceed.Wpf.Toolkit.MessageBox.Show(window, string.Format(Properties.Resources.ErrorWithLog_Message, message,Environment.NewLine), messageBoxTitle, MessageBoxButton.YesNo, MessageBoxImage.Error);

            if (result == MessageBoxResult.Yes)
                ShowLog();
        }

        private static void ShowLog()
        {
            System.Diagnostics.Process.Start(Logger.LogFileName);
        }
    }
}

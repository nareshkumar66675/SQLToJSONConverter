using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.Common
{
    /// <summary>
    /// Logger Interface
    /// </summary>
    public interface ILogger
    {
        /// <summary>
        /// Logs Info
        /// </summary>
        /// <param name="logMessage"></param>
        void LogInfo(string logMessage);
        /// <summary>
        /// Logs Error with Exception
        /// </summary>
        /// <param name="logMessage"></param>
        /// <param name="ex"></param>
        void LogError(string logMessage,Exception ex);

    }
    /// <summary>
    /// Logger Implementation
    /// </summary>
    public class Logger : ILogger
    {
        #region PrivateMembers
        private static readonly object lockObject = new object();
        private static readonly Lazy<ILogger> instance = new Lazy<ILogger>(() => new Logger(), LazyThreadSafetyMode.ExecutionAndPublication);
        private readonly TextWriter logWriter; 
        #endregion
        /// <summary>
        /// Logger Instance
        /// </summary>
        public static ILogger Instance => instance.Value;
        /// <summary>
        /// Log File Name
        /// </summary>
        public static string LogFileName { get; private set; }

        private Logger()
        {
            LogFileName = Path.Combine(AppSettings.LogFilePath, string.Concat(AppSettings.LogFileName, "_", DateTime.Now.ToString(AppSettings.LogFileTimeStampPattern), ".txt"));
            logWriter = TextWriter.Synchronized(File.AppendText(LogFileName));
            WriteToFile("********Start Of Log**********");
        }
        /// <summary>
        /// Logs Information
        /// </summary>
        /// <param name="logMessage">Log Message</param>
        public void LogInfo(string logMessage)
        {
            try
            {
                WriteToFile(logMessage);
            }
            catch (IOException)
            {
                logWriter.Close();
            }
        }
        /// <summary>
        /// Logs Error with Exception
        /// </summary>
        /// <param name="logMessage">Log Message</param>
        /// <param name="ex">Exception Object</param>
        public void LogError(string logMessage, Exception ex)
        {
            try
            {
                var exptText = new StringBuilder();
                exptText.AppendLine("Error Occurred: " + logMessage);
                if (ex != null) exptText.AppendLine("*****Exceptions Stack Trace******");
                int count = 1;
                while (ex != null)
                {
                    exptText.AppendLine("Exception : " + count);
                    exptText.AppendLine(ex.Message);
                    exptText.AppendLine(ex.StackTrace);
                    ex = ex.InnerException;
                    count++;
                }
                WriteToFile(exptText.ToString());
            }
            catch (IOException)
            {
                logWriter.Close();
            }
        }
        /// <summary>
        /// Writes Logs to files
        /// </summary>
        /// <param name="logMessage"></param>
        private void WriteToFile(string logMessage)
        {
            lock (lockObject)
            {
                DateTime now = DateTime.Now;
                logWriter.WriteLine("{0} {1}", now.ToString("yyyy-mm-dd hh-mm-ss.fff"), logMessage);
                logWriter.Flush();
            }
        }
    }
}

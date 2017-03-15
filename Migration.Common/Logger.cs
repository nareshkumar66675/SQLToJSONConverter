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
    public interface ILogger
    {
        void LogInfo(string logMessage);
        void LogError(string logMessage,Exception ex);

    }

    public class Logger : ILogger
    {
        private static readonly object lockObject = new object();
        private static readonly Lazy<ILogger> instance = new Lazy<ILogger>(() => new Logger(), LazyThreadSafetyMode.ExecutionAndPublication);
        private readonly TextWriter logWriter;
        public static ILogger Instance => instance.Value;

        private Logger()
        {
            string fileName = Path.Combine(AppSettings.LogFilePath, string.Concat(AppSettings.LogFileName, "_", DateTime.Now.ToString(AppSettings.LogFileTimeStampPattern), ".txt"));
            logWriter = TextWriter.Synchronized(File.AppendText(fileName));
            WriteToFile("********Start Of Log**********");
        }
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

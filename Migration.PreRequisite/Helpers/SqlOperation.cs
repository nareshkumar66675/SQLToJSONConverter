using Migration.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.Helpers
{
    internal class SqlOperation
    {
        public static List<string> GetAllCompletedPreRequisites(string connectionString)
        {
            List<string> completedList = new List<string>();
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                var query = Queries.GetCompletedPreRequisites;
                using (SqlCommand legacyCommand = new SqlCommand(query, conn))
                {
                    using (IDataReader dr = legacyCommand.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            completedList.Add(dr.GetString(0));
                        }
                    }
                }
            }
            return completedList;
        }
        public static bool ExecuteQuery(string connectionString,string query)
        {
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    SqlCommand command = conn.CreateCommand();
                    SqlTransaction transaction;
                    transaction = conn.BeginTransaction();
                    command.Connection = conn;
                    command.Transaction = transaction;

                    command.CommandText = query;
                    command.CommandType = CommandType.Text;

                    try
                    {
                        command.ExecuteNonQuery();
                        transaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            transaction.Rollback();
                            throw new Exception("Error Ocurred while Executing PreRequisites - Rollbacked", ex);
                        }
                        catch (Exception)
                        {
                            throw;
                        }
                    }

                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred while executing queries for PreRequisites", ex);
                return false;
            }
            return true;
        }

    }
}

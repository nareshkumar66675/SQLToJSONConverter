﻿using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
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
    internal static class SqlOperation
    {
        public static bool CheckIfTableExists(string connectionString, string tableName)
        {
            bool exists;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = @"SELECT CASE WHEN EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=@Schema AND TABLE_NAME = @TableName)) THEN 1 ELSE 0 END";
                var temp = tableName.Split('.');
                string schema = temp.Length == 2 ? temp[0] : "dbo";
                string tabName = temp.Length == 2 ? temp[1] : temp[0];
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add(new SqlParameter("@Schema", schema));
                    cmd.Parameters.Add(new SqlParameter("@TableName", tabName));

                    exists = (int)cmd.ExecuteScalar() == 1;
                }
            }
            return exists;
        }
        public static List<string> GetAllCompletedPreRequisites(string connectionString)
        {
            List<string> completedList = new List<string>();

            if (!CheckIfTableExists(connectionString, "Migration.PreRequisite"))
                return completedList;

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

        internal static void InsertPreRequisiteStatus(string connectionString, string name, string status)
        {
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlCommand command = conn.CreateCommand();
                command.Connection = conn;
                try
                {
                    //Insert Records to Report Table
                    command.CommandText = Queries.InsertPreRequisites;
                    command.Parameters.Add(new SqlParameter("@Name", name));
                    command.Parameters.Add(new SqlParameter("@Status", status));
                    command.ExecuteNonQuery();
                }
                catch
                {

                }
            }
        }

        public static bool ExecuteQuery(string connectionString, string query)
        {
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    //SqlCommand command = conn.CreateCommand();
                    //SqlTransaction transaction;
                    //transaction = conn.BeginTransaction();
                    //command.Connection = conn;
                    //command.Transaction = transaction;

                    //command.CommandText = query;
                    //command.CommandType = CommandType.Text;
                    Server server = new Server();
                    try
                    {
                        server = new Server(new ServerConnection(conn));
                        server.ConnectionContext.BeginTransaction();
                        server.ConnectionContext.ExecuteNonQuery(query);
                        server.ConnectionContext.CommitTransaction();
                        //command.ExecuteNonQuery();
                        //transaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            server.ConnectionContext.RollBackTransaction();
                            //transaction.Rollback();
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
        public static bool InsertComponentDefinition(string connectionString)
        {
            try
            {
                //Insert Asset Definitions to Legacy Database
                using (var legConn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
                {
                    legConn.Open();
                    SqlCommand command = legConn.CreateCommand();
                    SqlTransaction transaction;
                    transaction = legConn.BeginTransaction("InsertDefiniton");
                    command.Connection = legConn;
                    command.Transaction = transaction;
                    try
                    {

                        /* Check If table Exits and Empty 
                            1 - Table Exists and Empty - Records will be Inserted
                            0 - Table Exists and Not Empty - Records will not be Inserted
                           -1 - Table Not Exists - Error will ne thrown
                        */
                        command.CommandText = @"IF EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='Migration' AND TABLE_NAME = 'ASSET_TYPE_DEFN')) BEGIN
                                                SELECT CASE WHEN COUNT(ID) > 0 THEN 0 ELSE 1 END from MIGRATION.ASSET_TYPE_DEFN END
                                                ELSE BEGIN SELECT - 1 END";
                        command.CommandType = CommandType.Text;

                        var rslt = (int)command.ExecuteScalar();

                        if (rslt == 1)
                        {
                            List<string> astDefinitions = new List<string>();

                            //Get Asset Definitions - to Map New Options to Legacy
                            using (var astConn = new SqlConnection(connectionString))
                            {
                                astConn.Open();
                                var query = "SELECT Value FROM [ASSET_DEF].[ASSETS]";
                                using (SqlCommand cmd = new SqlCommand(query, astConn))
                                {
                                    using (IDataReader dr = cmd.ExecuteReader())
                                    {
                                        while (dr.Read())
                                        {
                                            astDefinitions.Add(dr.GetString(0));
                                        }
                                    }
                                }
                            }

                            //Insert Records to MIGRATION.ASSET_TYPE_DEFN
                            command.CommandText = "MIGRATION.P_ASSET_DEFINITION";
                            command.CommandType = CommandType.StoredProcedure;
                            var sqp = new SqlParameter("@pValue", SqlDbType.VarChar);
                            command.Parameters.Add(sqp);

                            foreach (var item in astDefinitions)
                            {
                                sqp.Value = item;
                                command.ExecuteNonQuery();
                            }
                        }
                        else if (rslt == -1)
                        {
                            throw new Exception("Table MIGRATION.ASSET_TYPE_DEFN not Found in Legacy Database");
                        }

                        transaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            transaction.Rollback();
                            throw new Exception("Error Ocurred - Rollbacked", ex);
                        }
                        catch (Exception)
                        {
                            throw;
                        }
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Error Occurred While Inserting Asset Defintion IDs ", ex);
                return false;
            }
        }
        public static string GetConnectionString(this FacadeType type)
        {
            switch (type)
            {
                case FacadeType.Legacy:
                    return ConnectionStrings.LegacyConnectionString;
                case FacadeType.Auth:
                    return ConnectionStrings.AuthConnectionString;
                case FacadeType.Asset:
                    return ConnectionStrings.AssetConnectionString;
                default:
                    return "";
            }
        }

    }
}
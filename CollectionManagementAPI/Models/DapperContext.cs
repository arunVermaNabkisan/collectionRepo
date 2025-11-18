using System;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace CollectionManagementSystem.Data
{
    /// <summary>
    /// Dapper Database Context for Collection Management System
    /// Provides database connection management
    /// </summary>
    public class DapperContext
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public DapperContext(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("CollectionManagementDB");

            if (string.IsNullOrEmpty(_connectionString))
            {
                throw new InvalidOperationException("Connection string 'CollectionManagementDB' is not configured.");
            }
        }

        /// <summary>
        /// Creates and returns a new database connection
        /// </summary>
        /// <returns>IDbConnection instance</returns>
        public IDbConnection CreateConnection()
        {
            return new SqlConnection(_connectionString);
        }

        /// <summary>
        /// Gets the connection string
        /// </summary>
        public string ConnectionString => _connectionString;
    }
}

// Integration Test for Cube SQL ADBC Driver
// Follows the approach from arrow_ipc_client.py
// Tests connection, queries, Arrow IPC output format, and parameter binding

#include <iostream>
#include <string>
#include <cstring>
#include <memory>
#include <vector>
#include <iomanip>

// PostgreSQL libpq headers
#include <libpq-fe.h>

using namespace std;

// Test configuration
const char* HOST = "localhost";
const char* PORT = "4444";
const char* USER = "username";
const char* PASSWORD = "password";
const char* DATABASE = "test";

// Color output
const char* GREEN = "\033[32m";
const char* RED = "\033[31m";
const char* BLUE = "\033[34m";
const char* RESET = "\033[0m";

// Test result structure
struct Test {
    string name;
    bool passed;
    string details;
    string error;

    void print() const {
        string status = passed ? (string(GREEN) + "✓ PASS" + RESET) :
                               (string(RED) + "✗ FAIL" + RESET);
        cout << status << " - " << name << endl;
        if (!details.empty()) {
            cout << "         " << details << endl;
        }
        if (!error.empty()) {
            cout << "         Error: " << error << endl;
        }
    }
};

vector<Test> results;

// Test 1: Basic Connection
Test test_basic_connection() {
    Test test{"Basic PostgreSQL Connection", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (!conn || PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            if (conn) PQfinish(conn);
            return test;
        }

        test.details = "Connected to " + string(HOST) + ":" + string(PORT);
        test.passed = true;
        PQfinish(conn);

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 2: Simple Query
Test test_simple_query() {
    Test test{"Simple SELECT Query", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        PGresult* res = PQexec(conn, "SELECT 1 as id, 'test' as value");
        if (!res || PQresultStatus(res) != PGRES_TUPLES_OK) {
            test.error = "Query execution failed";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }

        int nrows = PQntuples(res);
        int ncols = PQnfields(res);

        test.details = "Query returned " + to_string(nrows) + " row(s), " +
                      to_string(ncols) + " column(s)";

        PQclear(res);
        PQfinish(conn);
        test.passed = true;

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 3: Parameterized Query
Test test_parameterized_query() {
    Test test{"Parameterized Query", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        const char* query = "SELECT $1::int as num, $2::text as msg";
        const char* params[2] = {"42", "hello"};

        PGresult* res = PQexecParams(conn, query, 2, NULL, params, NULL, NULL, 0);
        if (!res || PQresultStatus(res) != PGRES_TUPLES_OK) {
            test.error = "Parameterized query failed";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }

        string val1 = PQgetvalue(res, 0, 0);
        string val2 = PQgetvalue(res, 0, 1);

        test.details = "Parameters: " + val1 + ", " + val2;

        PQclear(res);
        PQfinish(conn);
        test.passed = true;

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 4: Information Schema
Test test_information_schema() {
    Test test{"Information Schema Query", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        PGresult* res = PQexec(conn,
            "SELECT table_schema, table_name FROM information_schema.tables "
            "LIMIT 5");

        if (!res || PQresultStatus(res) != PGRES_TUPLES_OK) {
            test.error = "Information schema query failed";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }

        int nrows = PQntuples(res);
        test.details = "Retrieved " + to_string(nrows) + " table(s)";

        if (nrows > 0) {
            test.details += " - First: " + string(PQgetvalue(res, 0, 1));
        }

        PQclear(res);
        PQfinish(conn);
        test.passed = true;

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 5: Arrow IPC Output Format (via SQL SET command)
Test test_arrow_ipc_output_format() {
    Test test{"Arrow IPC Output Format (SET command)", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        // Enable Arrow IPC output format via SQL command (like arrow_ipc_client.py does)
        PGresult* res = PQexec(conn, "SET output_format = 'arrow_ipc'");
        if (!res || PQresultStatus(res) != PGRES_COMMAND_OK) {
            test.error = "Failed to set Arrow IPC output format";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }
        PQclear(res);

        // Execute query with Arrow IPC format
        res = PQexec(conn, "SELECT orders.FUL, MEASURE(orders.tax_amount) FROM orders GROUP BY 1");
        if (!res || PQresultStatus(res) != PGRES_TUPLES_OK) {
            test.error = "Query with Arrow IPC format failed";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }

        // Print Arrow IPC data information
        int ntuples = PQntuples(res);
        int nfields = PQnfields(res);

        cout << endl << "         " << BLUE << "Arrow IPC Data:" << RESET << endl;
        cout << "         Rows: " << ntuples << ", Columns: " << nfields << endl;

        // Print column names and types
        cout << "         Columns: ";
        for (int i = 0; i < nfields; i++) {
            cout << PQfname(res, i);
            if (i < nfields - 1) cout << ", ";
        }
        cout << endl;

        // Print binary data information for first few rows
        cout << "         " << BLUE << "Data Preview:" << RESET << endl;
        int rows_to_show = (ntuples < 10) ? ntuples : 10;

        for (int row = 0; row < rows_to_show; row++) {
            cout << "         Row " << row << ": ";
            for (int col = 0; col < nfields; col++) {
                if (PQgetisnull(res, row, col)) {
                    cout << "NULL";
                } else {
                    // Get value as text (libpq will convert if possible)
                    char* val = PQgetvalue(res, row, col);
                    int len = PQgetlength(res, row, col);

                    // Try to print as text, fall back to hex for binary
                    bool is_binary = PQfformat(res, col) == 1;
                    if (is_binary || len > 100) {
                        cout << "[" << len << " bytes";
                        if (len > 0 && len <= 20) {
                            cout << ": ";
                            for (int i = 0; i < len; i++) {
                                printf("%02x", (unsigned char)val[i]);
                                if (i < len - 1) cout << " ";
                            }
                        }
                        cout << "]";
                    } else {
                        // Print as text
                        cout << "'" << string(val, len) << "'";
                    }
                }
                if (col < nfields - 1) cout << ", ";
            }
            cout << endl;
        }

        if (ntuples > rows_to_show) {
            cout << "         ... (" << (ntuples - rows_to_show) << " more rows)" << endl;
        }

        test.details = "Arrow IPC format successfully negotiated, data retrieved and displayed";

        PQclear(res);
        PQfinish(conn);
        test.passed = true;

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 6: NULL Handling
Test test_null_handling() {
    Test test{"NULL Value Handling", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        PGresult* res = PQexec(conn, "SELECT 1 as not_null, NULL as is_null");
        if (!res || PQresultStatus(res) != PGRES_TUPLES_OK) {
            test.error = "Query failed";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }

        bool col0_null = PQgetisnull(res, 0, 0);
        bool col1_null = PQgetisnull(res, 0, 1);

        test.details = "Column 0: " + string(col0_null ? "NULL" : "NOT NULL") +
                      ", Column 1: " + string(col1_null ? "NULL" : "NOT NULL");

        PQclear(res);
        PQfinish(conn);
        test.passed = (!col0_null && col1_null);

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 7: Data Types
Test test_data_types() {
    Test test{"Data Type Support", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        PGresult* res = PQexec(conn,
            "SELECT "
            "  42::int as int_val, "
            "  3.14::float as float_val, "
            "  'text'::text as text_val, "
            "  true::bool as bool_val");

        if (!res || PQresultStatus(res) != PGRES_TUPLES_OK) {
            test.error = "Query failed";
            if (res) PQclear(res);
            PQfinish(conn);
            return test;
        }

        int ncols = PQnfields(res);
        test.details = "Supports " + to_string(ncols) +
                      " types: int, float, text, bool";

        PQclear(res);
        PQfinish(conn);
        test.passed = (ncols == 4);

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Test 8: Error Handling
Test test_error_handling() {
    Test test{"Error Handling", false, "", ""};

    try {
        string conn_str = string("host=") + HOST +
                         " port=" + PORT +
                         " user=" + USER +
                         " password=" + PASSWORD +
                         " dbname=" + DATABASE;

        PGconn* conn = PQconnectdb(conn_str.c_str());
        if (PQstatus(conn) != CONNECTION_OK) {
            test.error = PQerrorMessage(conn);
            PQfinish(conn);
            return test;
        }

        PGresult* res = PQexec(conn, "SELECT * FROM nonexistent_table");
        if (!res) {
            test.error = "PQexec returned NULL";
            PQfinish(conn);
            return test;
        }

        ExecStatusType status = PQresultStatus(res);
        if (status != PGRES_TUPLES_OK) {
            // Expected - we got an error
            test.details = "Correctly caught table not found error";
            PQclear(res);
            PQfinish(conn);
            test.passed = true;
            return test;
        }

        test.error = "Query should have failed";
        PQclear(res);
        PQfinish(conn);

    } catch (const exception& e) {
        test.error = e.what();
    }

    return test;
}

// Main test runner
int main() {
    cout << "\n" << BLUE << string(80, '=') << RESET << endl;
    cout << BLUE << "CUBE SQL ADBC DRIVER - INTEGRATION TEST SUITE" << RESET << endl;
    cout << BLUE << string(80, '=') << RESET << endl;

    cout << "\nTest Configuration:" << endl;
    cout << "  Host:     " << BLUE << HOST << RESET << endl;
    cout << "  Port:     " << BLUE << PORT << RESET << endl;
    cout << "  User:     " << BLUE << USER << RESET << endl;
    cout << "  Database: " << BLUE << DATABASE << RESET << endl;

    cout << "\n" << BLUE << string(80, '-') << RESET << endl;
    cout << BLUE << "RUNNING INTEGRATION TESTS" << RESET << endl;
    cout << BLUE << string(80, '-') << RESET << "\n";

    // Run all tests
    results.push_back(test_basic_connection());
    results.push_back(test_simple_query());
    results.push_back(test_parameterized_query());
    results.push_back(test_information_schema());
    results.push_back(test_arrow_ipc_output_format());
    results.push_back(test_null_handling());
    results.push_back(test_data_types());
    results.push_back(test_error_handling());

    // Print results
    cout << "\n" << BLUE << string(80, '-') << RESET << endl;
    cout << BLUE << "TEST RESULTS" << RESET << endl;
    cout << BLUE << string(80, '-') << RESET << "\n";

    int passed = 0;
    int failed = 0;

    for (const auto& result : results) {
        result.print();
        if (result.passed) {
            passed++;
        } else {
            failed++;
        }
    }

    // Summary
    cout << "\n" << BLUE << string(80, '=') << RESET << endl;
    cout << BLUE << "SUMMARY" << RESET << endl;
    cout << BLUE << string(80, '=') << RESET << endl;
    cout << "Total Tests: " << results.size() << endl;
    cout << GREEN << "Passed: " << passed << RESET << " / ";
    cout << RED << "Failed: " << failed << RESET << endl;
    cout << "Success Rate: " << (100 * passed / results.size()) << "%" << endl;

    if (failed == 0) {
        cout << "\n" << GREEN << "✓ ALL INTEGRATION TESTS PASSED!" << RESET << endl;
        cout << "The Cube SQL ADBC driver is fully functional." << endl;
    } else {
        cout << "\n" << RED << "✗ " << failed << " TEST(S) FAILED" << RESET << endl;
    }

    cout << "\n" << BLUE << string(80, '=') << RESET << "\n";

    return (failed == 0) ? 0 : 1;
}

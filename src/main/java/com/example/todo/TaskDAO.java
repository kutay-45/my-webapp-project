package com.example.todo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {
    private static final String URL = "jdbc:sqlite:todo.db";

    static {
        try {
            Class.forName("org.sqlite.JDBC");
            // ensure the tasks table exists
            try (Connection conn = DriverManager.getConnection(URL);
                 Statement stmt = conn.createStatement()) {
                stmt.execute("CREATE TABLE IF NOT EXISTS tasks ("
                        + "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                        + "title TEXT NOT NULL,"
                        + "completed BOOLEAN NOT NULL CHECK (completed IN (0,1))"
                        + ")");
            }
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Failed to load SQLite JDBC driver", e);
        } catch (SQLException e) {
            throw new RuntimeException("Failed to initialize database", e);
        }
    }

    public List<Task> getAll() throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT id, title, completed FROM tasks";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Task t = new Task();
                t.setId(rs.getInt("id"));
                t.setTitle(rs.getString("title"));
                t.setCompleted(rs.getBoolean("completed"));
                tasks.add(t);
            }
        }
        return tasks;
    }

    public Task get(int id) throws SQLException {
        String sql = "SELECT id, title, completed FROM tasks WHERE id = ?";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Task t = new Task();
                    t.setId(rs.getInt("id"));
                    t.setTitle(rs.getString("title"));
                    t.setCompleted(rs.getBoolean("completed"));
                    return t;
                }
            }
        }
        return null;
    }

    public Task create(Task task) throws SQLException {
        String sql = "INSERT INTO tasks(title, completed) VALUES(?,?)";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, task.getTitle());
            ps.setBoolean(2, task.isCompleted());
            int affected = ps.executeUpdate();
            if (affected == 0) {
                return null;
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    task.setId(keys.getInt(1));
                }
            }
            return task;
        }
    }

    public boolean update(Task task) throws SQLException {
        String sql = "UPDATE tasks SET title = ?, completed = ? WHERE id = ?";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, task.getTitle());
            ps.setBoolean(2, task.isCompleted());
            ps.setInt(3, task.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM tasks WHERE id = ?";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}

package com.example.todo;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/tasks/*")
public class TasksServlet extends HttpServlet {
    private final TaskDAO dao = new TaskDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        String pathInfo = req.getPathInfo(); // may be null or "/{id}"
        try (PrintWriter out = resp.getWriter()) {
            if (pathInfo == null || "/".equals(pathInfo)) {
                List<Task> list = dao.getAll();
                out.print(gson.toJson(list));
            } else {
                String[] parts = pathInfo.split("/");
                if (parts.length >= 2) {
                    int id = Integer.parseInt(parts[1]);
                    Task t = dao.get(id);
                    if (t == null) {
                        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.print("{}");
                    } else {
                        out.print(gson.toJson(t));
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        try {
            Task t = parseRequest(req);
            Task created = dao.create(t);
            resp.setStatus(HttpServletResponse.SC_CREATED);
            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(created));
            }
        } catch (SQLException | JsonSyntaxException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || "/".equals(pathInfo)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        String[] parts = pathInfo.split("/");
        if (parts.length < 2) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int id = Integer.parseInt(parts[1]);
            Task t = parseRequest(req);
            t.setId(id);
            boolean ok = dao.update(t);
            if (ok) {
                try (PrintWriter out = resp.getWriter()) {
                    out.print(gson.toJson(t));
                }
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException | JsonSyntaxException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || "/".equals(pathInfo)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        String[] parts = pathInfo.split("/");
        if (parts.length < 2) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int id = Integer.parseInt(parts[1]);
            boolean ok = dao.delete(id);
            if (ok) {
                resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private Task parseRequest(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            int ch;
            while ((ch = reader.read()) != -1) {
                sb.append((char) ch);
            }
        }
        return gson.fromJson(sb.toString(), Task.class);
    }
}

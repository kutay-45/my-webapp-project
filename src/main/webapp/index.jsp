<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Todo List</title>

    <!-- bootstrap & icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>

    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding-top: 40px;
        }
        .card {
            border-radius: 1rem;
            box-shadow: 0 20px 60px rgba(0,0,0,.3);
        }
        .gradient-text {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .task-completed {
            text-decoration: line-through;
            color: #6c757d;
        }
        .task-item:hover .btn {
            visibility: visible;
        }
        .task-item .btn {
            visibility: hidden;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="card p-4">
        <h1 class="text-center gradient-text mb-4">My Todo List</h1>

        <form id="new-task-form" class="d-flex mb-3">
            <input id="new-task-input" class="form-control me-2" placeholder="Add a new task..." required />
            <button class="btn btn-primary">Add</button>
        </form>

        <ul id="tasks" class="list-group"></ul>
    </div>
</div>

<script>
    // include context path so requests target the correct application
    const apiBase = '<%= request.getContextPath() %>/api/tasks';

    async function fetchTasks() {
        const res = await fetch(apiBase);
        return res.ok ? res.json() : [];
    }

    function renderTasks(tasks) {
        const ul = document.getElementById('tasks');
        ul.innerHTML = '';
        tasks.forEach(t => {
            const li = document.createElement('li');
            li.className = 'list-group-item d-flex align-items-center task-item';
            li.innerHTML = `
                <input type="checkbox" class="form-check-input me-2" ${t.completed ? 'checked' : ''} />
                <span class="flex-grow-1 ${t.completed ? 'task-completed' : ''}"></span>
                <button class="btn btn-sm btn-outline-secondary me-1" title="Edit">
                    <i class="bi bi-pen"></i>
                </button>
                <button class="btn btn-sm btn-outline-danger" title="Delete">
                    <i class="bi bi-trash"></i>
                </button>
            `;
            const checkbox = li.querySelector('input[type=checkbox]');
            const titleSpan = li.querySelector('span');
            titleSpan.textContent = t.title;

            checkbox.addEventListener('change', () => {
                updateTask(t.id, { completed: checkbox.checked, title: t.title });
            });

            li.querySelector('.btn-outline-secondary').addEventListener('click', () => {
                const newTitle = prompt('Edit task title', t.title);
                if (newTitle !== null && newTitle.trim() !== '' && newTitle !== t.title) {
                    updateTask(t.id, { title: newTitle, completed: t.completed });
                }
            });

            li.querySelector('.btn-outline-danger').addEventListener('click', () => {
                if (confirm('Delete this task?')) {
                    deleteTask(t.id);
                }
            });

            ul.appendChild(li);
        });
    }

    async function loadTasks() {
        const tasks = await fetchTasks();
        renderTasks(tasks);
    }

    async function addTask(title) {
        const url = apiBase;
        const res = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title })
        });
        if (res.ok) loadTasks();
    }

    async function updateTask(id, data) {
        const url = `${apiBase}/${id}`;
        const res = await fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        if (res.ok) loadTasks();
    }

    async function deleteTask(id) {
        const url = `${apiBase}/${id}`;
        const res = await fetch(url, { method: 'DELETE' });
        if (res.ok) loadTasks();
    }

    document.addEventListener('DOMContentLoaded', () => {
        loadTasks();
        document.getElementById('new-task-form').addEventListener('submit', e => {
            e.preventDefault();
            const input = document.getElementById('new-task-input');
            const val = input.value.trim();
            if (val) {
                addTask(val);
                input.value = '';
            }
        });
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
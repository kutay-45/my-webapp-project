<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World Refined</title>
    <style>
        /* Theme variables and layout (supports light and dark) */
        :root {
            --bg-start: #667eea;
            --bg-end: #764ba2;
            --text-color: #ffffff;
            --shadow-color: rgba(0,0,0,0.3);
            --button-bg: rgba(255,255,255,0.12);
            --button-color: #fff;
        }

        /* Dark theme overrides */
        .dark-theme {
            --bg-start: #0f1724; /* dark blue/near-black */
            --bg-end: #0b1220;
            --text-color: #e6eef8;
            --shadow-color: rgba(0,0,0,0.6);
            --button-bg: rgba(255,255,255,0.06);
            --button-color: #e6eef8;
        }

        /* Light theme overrides (keeps original purple gradient feel but lighter text/shadows) */
        .light-theme {
            --bg-start: #667eea;
            --bg-end: #764ba2;
            --text-color: #ffffff;
            --shadow-color: rgba(0,0,0,0.3);
            --button-bg: rgba(0,0,0,0.12);
            --button-color: #fff;
        }

        /* This centers everything on the screen */
        body {
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--bg-start) 0%, var(--bg-end) 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: var(--text-color);
            transition: background 300ms ease, color 200ms ease;
        }

        h2 {
            font-size: 4rem;
            text-shadow: 2px 4px 10px var(--shadow-color);
            animation: fadeIn 2s ease-in-out;
        }

        /* A simple entry animation */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Theme toggle button in the top-right (improved visuals and accessible focus state) */
        #theme-toggle {
            position: fixed;
            top: 16px;
            right: 16px;
            width: 48px;
            height: 48px;
            padding: 6px;
            border-radius: 12px;
            border: 1px solid transparent;
            background: var(--button-bg);
            color: var(--button-color);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 6px 18px rgba(0,0,0,0.18);
            transition: transform 120ms ease, background 200ms ease, color 200ms ease, box-shadow 200ms ease, border-color 160ms ease;
            font-size: 18px;
            backdrop-filter: blur(6px);
        }

        #theme-toggle:hover { transform: translateY(-2px); }
        #theme-toggle:active { transform: translateY(0); }

        /* Focus-visible for keyboard users */
        #theme-toggle:focus {
            outline: none;
            border-color: rgba(255,255,255,0.16);
            box-shadow: 0 6px 24px rgba(0,0,0,0.28), 0 0 0 4px rgba(100,140,255,0.12);
        }

        /* Icon sizing */
        #theme-toggle svg { width:20px; height:20px; display:block; }

        /* Show appropriate icon depending on theme. When in dark theme, show the sun (action: switch to light) */
        .icon-sun { display: none; }
        .icon-moon { display: inline-block; }
        .dark-theme .icon-sun { display: inline-block; }
        .dark-theme .icon-moon { display: none; }

        /* Small label for screen readers but visually hidden */
        .sr-only { position: absolute; width:1px; height:1px; padding:0; margin:-1px; overflow:hidden; clip:rect(0,0,0,0); border:0; }
    </style>
</head>
<body>
    <button id="theme-toggle" aria-pressed="false" title="Toggle color theme">
        <span class="sr-only">Toggle theme</span>
        <!-- Moon icon (visible in light theme) -->
        <span class="icon-moon" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                <path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" fill="currentColor"/>
            </svg>
        </span>
        <!-- Sun icon (visible in dark theme) -->
        <span class="icon-sun" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                <path d="M6.76 4.84l-1.8-1.79L3.17 4.84l1.79 1.79 1.8-1.79zM1 13h3v-2H1v2zm10 7h2v-3h-2v3zm7.03-2.03l1.79 1.79 1.79-1.79-1.79-1.79-1.79 1.79zM17.24 4.84l1.79-1.79-1.79-1.79-1.79 1.79 1.79 1.79zM22 11v2h-3v-2h3zM4.22 19.78l1.79-1.79-1.79-1.79-1.79 1.79 1.79 1.79zM12 6a6 6 0 100 12A6 6 0 0012 6z" fill="currentColor"/>
            </svg>
        </span>
    </button>

    <h2>Hello World!</h2>

    <script>
        // Theme toggle: persists to localStorage and respects system preference
        (function () {
            const storageKey = 'theme-preference';
            const toggle = document.getElementById('theme-toggle');
            const icon = document.getElementById('theme-icon');

            function applyTheme(theme) {
                // remove any existing theme class, then set the selected one on <html>
                document.documentElement.classList.remove('dark-theme', 'light-theme');
                document.documentElement.classList.add(theme === 'dark' ? 'dark-theme' : 'light-theme');
                toggle.setAttribute('aria-pressed', theme === 'dark');
                // Update tooltip/title for the button. Icons are handled by CSS (SVGs in the markup).
                toggle.title = theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme';
            }

            function init() {
                const saved = localStorage.getItem(storageKey);
                let theme = saved;
                if (!theme) {
                    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
                    theme = prefersDark ? 'dark' : 'light';
                }
                applyTheme(theme);
            }

            toggle.addEventListener('click', function () {
                const isDark = document.documentElement.classList.contains('dark-theme');
                const next = isDark ? 'light' : 'dark';
                applyTheme(next);
                try {
                    localStorage.setItem(storageKey, next);
                } catch (e) {
                    // localStorage may be unavailable in some privacy modes; ignore failures
                }
            });

            init();
        })();
    </script>
</body>
</html>
# Security guidance (all my projects)

- Every route, controller action, or WordPress AJAX/REST handler that reads or changes user data must check authentication and ownership/capability before touching the database.
- No raw SQL with user input: Laravel uses bindings, WordPress uses `$wpdb->prepare()`, Python uses parameterized queries.
- WordPress: every form and AJAX action verifies a nonce; every output is escaped (`esc_html`, `esc_attr`, `esc_url`, `wp_kses`).
- Never log passwords, tokens, API keys, NID numbers, or full phone numbers at info level or above.
- Money is stored as integer (paisa) or DECIMAL, never float; stock and balance changes run inside DB transactions.
- File uploads are validated (MIME, extension, size), renamed, and stored outside the public web root.
- Login, OTP, password reset, and public APIs are rate-limited.
- LLM/AI features: treat model output as untrusted; the model never gets direct DB write or admin access.

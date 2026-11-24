### Stack: Python

<!-- FILL: real commands. -->
```bash
<command>                                  # dev server / entry point
pytest -xvs path/to/test_file.py           # one test file (preferred)
.agents/hooks/check-files.sh path/to/file.py   # format + lint one file
pip install -r requirements-dev.txt        # black, flake8, pytest, pip-audit, pre-commit
```

- **Test isolation:** `tests/conftest.py` sets every live-service env var to an
  unroutable address before app code loads. *Set*, not unset — `load_dotenv()` refills
  unset variables from `.env`, which is how a test reaches production. Add every new
  service URL/key there in the same PR that introduces it.
- `async def` all the way down; a missing `await` returns a coroutine and fails
  silently. Never call blocking I/O (`requests`, sync DB drivers) inside `async def`.
- Pydantic models with `extra="allow"` or field aliases mean the same input can arrive
  under two names — guards must read through the same accessor as the code they guard.
- Pure helpers in `utils/`, provider HTTP in its own client module, constants in
  `constants/<feature>.py`. Grep those before writing a new helper.
- Use timezone-aware datetimes from one shared helper; never ad-hoc `datetime.now()`.

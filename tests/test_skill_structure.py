"""
OpenClaw Skill Structure Tests

验证 skill 根目录中的所有文件存在、可执行、格式正确。
在 redclaw-skill repo 根目录下运行：pytest tests/ -v
"""
import os
import stat

# Skill repo 根目录下直接就是 SKILL.md / scripts/
SKILL_DIR = "."
SCRIPTS_DIR = "scripts"


# ══════════════════════════════════════════════════════════════════════════════
# 目录结构 + SKILL.md
# ══════════════════════════════════════════════════════════════════════════════


def test_skill_md_exists():
    """SKILL.md 文件存在"""
    assert os.path.isfile("SKILL.md"), "SKILL.md not found"


def test_skill_md_has_yaml_frontmatter():
    """SKILL.md 包含 YAML frontmatter（--- 分隔符）"""
    content = open("SKILL.md").read()
    assert content.startswith("---"), "SKILL.md must start with YAML frontmatter (---)"
    parts = content.split("---", 2)
    assert len(parts) >= 3, "SKILL.md frontmatter must have closing ---"


def test_skill_md_frontmatter_required_fields():
    """SKILL.md frontmatter 包含 name、description、metadata.openclaw.requires"""
    content = open("SKILL.md").read()
    frontmatter = content.split("---", 2)[1]
    assert "name:" in frontmatter, "SKILL.md frontmatter missing 'name:'"
    assert "description:" in frontmatter, "SKILL.md frontmatter missing 'description:'"
    assert "env:" in frontmatter, "SKILL.md frontmatter missing env requirements"
    assert "REDCLAW_URL" in frontmatter, "SKILL.md frontmatter missing REDCLAW_URL env"
    assert "REDCLAW_API_KEY" in frontmatter, "SKILL.md frontmatter missing REDCLAW_API_KEY env"


def test_skill_md_body_has_trigger_words():
    """SKILL.md 正文包含触发词说明"""
    content = open("SKILL.md").read()
    body = content.split("---", 2)[2] if len(content.split("---", 2)) >= 3 else ""
    for word in ("monitor", "keyword", "alert"):
        assert word.lower() in body.lower(), f"SKILL.md body missing trigger word '{word}'"


def test_readme_exists():
    """README.md 文件存在"""
    assert os.path.isfile("README.md"), "README.md not found"


def test_license_exists():
    """LICENSE 文件存在"""
    assert os.path.isfile("LICENSE"), "LICENSE not found"


# ══════════════════════════════════════════════════════════════════════════════
# scripts/ 디렉토리와 스크립트 파일
# ══════════════════════════════════════════════════════════════════════════════


def test_scripts_dir_exists():
    """scripts/ 目录存在"""
    assert os.path.isdir(SCRIPTS_DIR), "scripts/ directory not found"


EXPECTED_SCRIPTS = ["keywords.sh", "alerts.sh", "sources.sh", "status.sh"]


def test_all_scripts_exist():
    """所有必需的 shell 脚本存在"""
    for script in EXPECTED_SCRIPTS:
        path = f"{SCRIPTS_DIR}/{script}"
        assert os.path.isfile(path), f"Script {path} not found"


def test_all_scripts_are_executable():
    """所有 shell 脚本具有可执行权限"""
    for script in EXPECTED_SCRIPTS:
        path = f"{SCRIPTS_DIR}/{script}"
        if os.path.isfile(path):
            is_executable = bool(os.stat(path).st_mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH))
            assert is_executable, f"{path} is not executable (chmod +x required)"


def test_all_scripts_have_shebang():
    """所有 shell 脚本以 #!/usr/bin/env bash 开头"""
    for script in EXPECTED_SCRIPTS:
        path = f"{SCRIPTS_DIR}/{script}"
        if os.path.isfile(path):
            first_line = open(path).readline().strip()
            assert first_line in ("#!/usr/bin/env bash", "#!/bin/bash"), \
                f"{script} missing bash shebang, got: {first_line!r}"


def test_all_scripts_use_env_vars():
    """所有脚本引用 REDCLAW_URL 和 REDCLAW_API_KEY 环境变量"""
    for script in EXPECTED_SCRIPTS:
        path = f"{SCRIPTS_DIR}/{script}"
        if os.path.isfile(path):
            content = open(path).read()
            assert "REDCLAW_URL" in content, f"{script} missing REDCLAW_URL reference"
            assert "REDCLAW_API_KEY" in content, f"{script} missing REDCLAW_API_KEY reference"


def test_keywords_sh_supports_add_list_delete_toggle_export():
    """keywords.sh 支持 add/list/delete/toggle/export 子命令"""
    path = f"{SCRIPTS_DIR}/keywords.sh"
    if os.path.isfile(path):
        content = open(path).read()
        for cmd in ("add", "list", "delete", "toggle", "export"):
            assert cmd in content, f"keywords.sh missing '{cmd}' subcommand"


def test_alerts_sh_supports_list_with_source_and_limit():
    """alerts.sh 支持 --source 和 --limit 参数"""
    path = f"{SCRIPTS_DIR}/alerts.sh"
    if os.path.isfile(path):
        content = open(path).read()
        assert "--source" in content, "alerts.sh missing --source parameter"
        assert "--limit" in content, "alerts.sh missing --limit parameter"


def test_sources_sh_supports_add_rss_and_list():
    """sources.sh 支持 add-rss 和 list 子命令"""
    path = f"{SCRIPTS_DIR}/sources.sh"
    if os.path.isfile(path):
        content = open(path).read()
        assert "add-rss" in content, "sources.sh missing 'add-rss' subcommand"
        assert "list" in content, "sources.sh missing 'list' subcommand"


def test_status_sh_calls_status_endpoint():
    """status.sh 调用 /api/v1/status 端点"""
    path = f"{SCRIPTS_DIR}/status.sh"
    if os.path.isfile(path):
        content = open(path).read()
        assert "/api/v1/status" in content, "status.sh must call /api/v1/status"

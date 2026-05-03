# Contributing to gitlab-review.nvim

First off, thank you for considering contributing! This is a community-driven project and every contribution — no matter how small — is appreciated.

## Table of Contents

- [Opening an Issue](#opening-an-issue)
- [Submitting a Pull Request](#submitting-a-pull-request)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Testing](#testing)
- [Commit Messages](#commit-messages)

## Opening an Issue

**Please open an issue before submitting a pull request.**

Starting with an issue helps us:

- Discuss the approach before any code is written
- Avoid duplicate work
- Make sure the change aligns with the project's direction
- Save everyone time

Whether it's a bug report, a feature suggestion, or a question — opening an issue first is the best way to start. When opening an issue, be clear and provide as much relevant context as possible (Neovim version, `glab` version, steps to reproduce, etc.).

### ⚠️ A note on AI-generated content

We ask contributors to **write issues and pull request descriptions by themselves**, rather than copy-pasting output from AI tools. Issues and PRs written by AI tend to be vague, over-engineered, or disconnected from the actual problem. We want clear, honest communication from real developers working on real problems.

## Submitting a Pull Request

Once you have an issue and a maintainer has agreed on the direction, feel free to open a PR:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test locally — make sure it works in your Neovim setup
5. Push to your fork and open a pull request
6. Link the related issue in the PR description

### On Vibe Coding

We are **strictly against full "vibe coding"** — pasting a prompt into an AI and merging whatever it spits out without understanding it. This project values intentional, readable, and maintainable code.

That said, **using AI as a tool is perfectly fine**, as long as there is meaningful human intervention: review, refactor, test, and take ownership of every line you submit. If you can explain why the code works, it's yours. If you can't — it's not ready.

## Development Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/<your_username>/gitlab-review.nvim.git
   cd gitlab-review.nvim
   ```

2. Open it with Neovim or symlink it to your Neovim config:

   ```bash
   ln -s "$(pwd)" ~/.local/share/nvim/site/pack/gitlab-review/start/gitlab-review.nvim
   ```

3. Make sure you have the project requirements:
   - **Neovim 0.12+**
   - Treesitter with `diff` parser
   - [`glab` CLI](https://gitlab.com/gitlab-org/cli)

## Code Style

- Follow the existing Lua style in the codebase (indentation, naming conventions, etc.)
- Keep it simple — this plugin has **zero external dependencies** for a reason
- Add comments when the intent isn't obvious, but prefer readable code over heavy commenting
- Keep functions focused and small

## Testing

Currently, there is no automated test suite set up. For now, please:

- Manually test your changes in a real Neovim environment
- Test against an actual GitLab MR to verify the API interactions work

## Commit Messages

Use clear and descriptive commit messages. Follow the [Conventional Commits](https://www.conventionalcommits.org/) format when possible:

```
type(scope): short description

feat(api): add reply to discussion action
fix(ui): resolve popup alignment issue
docs: update setup instructions
```

---

Thanks for reading! If you're unsure about anything, just open an issue or reach out. We'd love to have you here. 🍒

# Contributing to Base App Helm Chart

First, thank you for considering contributing! This project is designed to be a reusable, high-quality base chart for Kubernetes microservices.

## Ways to Contribute

- 🐞 Report bugs
- 💡 Suggest new features or improvements
- 🛠 Fix issues and open pull requests
- 📚 Improve documentation and examples

---

## Getting Started

1. **Fork** the repository.
2. **Clone** your fork:

   ```bash
   git clone https://github.com/<your-username>/hp-app-helm-chart.git
   cd hp-app-helm-chart
   ```

3. Make sure you have:

   - `helm` (v3+)
   - A Kubernetes cluster (e.g. `microk8s`, `kind`, `minikube`)
   - `kubectl` configured to talk to your cluster

---

## Development Workflow

### 1. Lint the chart

```bash
helm lint hp-app
```

### 2. Render templates locally

```bash
helm template my-app ./hp-app -f examples/values.example.yaml
```

Review the rendered manifests before applying them.

### 3. Test install on a dev cluster

```bash
helm install my-app ./hp-app -f examples/values.example.yaml
kubectl get all -l app.kubernetes.io/instance=my-app
```

When finished:

```bash
helm uninstall my-app
```

---

## Coding / Templating Guidelines

- Prefer **generic, reusable** values over app-specific logic.
- Avoid hard-coded app names, URLs, or credentials.
- Use helpers in `_helpers.tpl` for:
  - names
  - labels
  - service account names
  - image configuration
- Keep default `values.yaml` **safe** and minimal:
  - No destructive jobs by default
  - No external URLs that could break users
- Document any new feature flags or values in `README.md`.

---

## Opening a Pull Request

1. Create a new branch:

   ```bash
   git checkout -b feature/my-change
   ```

2. Make your changes and commit them with clear messages:

   ```bash
   git commit -am "feat: add X to deployment template"
   ```

3. Push your branch:

   ```bash
   git push origin feature/my-change
   ```

4. Open a Pull Request:
   - Describe **what** you changed.
   - Explain **why** you changed it.
   - If possible, include:
     - `helm template` output snippets
     - example `values.yaml` usage

---

## Reporting Bugs

When filing an issue, please include:

- Helm version: `helm version`
- Kubernetes version: `kubectl version`
- The exact command you ran
- The relevant `values.yaml` snippet (redact secrets!)
- Error logs or output

---

## Feature Requests

If you’d like to propose a new feature:

- Explain the use case (what problem it solves).
- Show a rough example of `values.yaml`.
- Indicate whether it should be enabled by default or optional.

---

## License

By contributing, you agree that your contributions will be licensed under the **MIT License**, the same license as this project.

# devops-workshop

Lær hvordan du [deployer](https://teknisk-ordbok.fly.dev/ordbok/Deploy) koden din til [prod](https://teknisk-ordbok.fly.dev/ordbok/Produksjon)!

# 🐳 Docker

## 📖 Før du begynner

Installer Docker [herfra](https://docs.docker.com/engine/install).

## 🔨 Oppgave 1.1

Prøv å bygg et Docker image slik:

```bash
cd frontend
docker build . -t devops-workshop:latest
```

Du ser at den feiler, og det virker som den mangler en fil (eller filer?) for å bygge frontend'en.
Legg til det som mangler i `COPY`-steget i filen [Dockerfile](frontend/Dockerfile).

*HINT:* Vi bruker **yarn** for å bygge frontend'en.

<details>
  <summary>✨ Se fasit</summary>

```dockerfile
FROM alpine:latest

WORKDIR /app

RUN apk update && \
    apk add yarn

# Legg til `yarn.lock`:
COPY package.json index.html yarn.lock ./

RUN yarn install

ENTRYPOINT ["yarn", "serve"]
```

</details>

## 🔨 Oppgave 1.2

Prøv å kjør applikasjonen med denne kommandoen:

```bash
docker run -it -p 3000:3000 devops-workshop:latest
```

Da skal du kunne gå i nettleseren og se noe på `http://localhost:3000`!


# ▶️ GitHub Actions

Disse oppgavene gjøres i filen [deploy.yml](.github/workflows/deploy.yml).

## 📖 Før du begynner

Sjekk ut en git branch med navnet ditt:

```bash
git checkout -b andreas-bakseter
```

**DET ER VIKTIG AT INGEN ANDRE HAR EN BRANCH MED SAMME NAVN!**

## 🔨 Oppgave 2.1

Vi vil gjerne kjøre testene våre for frontend'en i GitHub Actions, men vi mangler noen steg.
Fyll ut stegene som mangler for å kjøre testenen til frontend'en.

*HINT:* Se hvordan de andre jobbene definerer steg (i listen under `steps`).

<details>
  <summary>✨ Se fasit</summary>

```yaml
run_tests:
  name: 'Run frontend tests'
  runs-on: ubuntu-latest
  defaults:
    run:
      working-directory: './frontend'
  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Install dependencies
      run: yarn install

    - name: Run tests
      run: yarn test
```

</details>

## 🔨 Oppgave 2.2

Vi vil også at bygg-steget ikke skal starte før testene har kjørt og har passert.
Endre det slik at bygg-steget avhenger av test-steget for å kunne kjøre.

<details>
  <summary>✨ Se fasit</summary>

```yaml
build:
  name: 'Build Docker image and push to registry'
  depends-on: [set_name, run_tests]
  runs-on: ubuntu-latest
  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Build and push image to registry
      uses: docker/build-push-action@v5
      with:
        push: 'true'
        tags: '${{ env.MY_NAME }}-latest'
        file: './frontend/Dockerfile'
```

</details>

# 🏗️ Terraform

## 📖 Før du begynner

Installer Terraform [her](https://developer.hashicorp.com/terraform/install).

For å kunne kjøre Terraform lokalt kjøre denne kommandoen i mappen [terraform](terraform):

```bash
terraform init
```

## 🔨 Oppgave 3.1



## 🔨 Oppgave 3.2

Legg til en `template.container` i `azurerm_container_app`-ressursen i filen [main.tf](terraform/main.tf).

<details>
  <summary>✨ Se fasit</summary>

```hcl
resource "azurerm_container_app" "devops" {
  name                         = "${var.my_name}-app"
  container_app_environment_id = azurerm_container_app_environment.backend_env.id
  resource_group_name          = azurerm_resource_group.devops
  revision_mode                = "Single"

  template {
    container {
      name   = "devops-workshop"
      image  = "ghcr.io/computas/devops-workshop/${var.my_name}:latest"
      cpu    = "0.25"
      memory = "0.5Gi"
    }

    min_replicas    = 1
    max_replicas    = 1
    revision_suffix = substr(var.revision_suffix, 0, 10)
  }

  ingress {
    target_port      = "3000"
    external_enabled = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
```
## 🔨 Oppgave 3.3

Vi har lyst til å deploye med Terraform.
Legg til et siste steg som kjører en Terraform kommando for å endre infrastrukturen vår.

<details>
  <summary>✨ Se fasit</summary>

```yaml
deploy:
  name: 'Deploy using Terraform'
  runs-on: ubuntu-latest
  depends-on: [build]
  env:
    TF_VAR_revision_suffix: ${{ github.sha }}
    TF_VAR_my_name: ${{ env.MY_NAME }}
    ARM_CLIENT_ID: ${{ vars.ARM_CLIENT_ID }}
    ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
    ARM_SUBSCRIPTION_ID: ${{ vars.ARM_SUBSCRIPTION_ID }}
    ARM_SUBSCRIPTION_ID: ${{ vars.ARM_SUBSCRIPTION_ID }}
  defaults:
    run:
      working-directory: './terraform'
  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3

    - name: Init Terraform
      run: terraform init

    - name: Set Terraform workspace
      run: teraform workspace new $MY_NAME || terraform workspace select $MY_NAME

    - name: Run Terraform apply
      run: terraform apply -auto-approve
```

</details>

## 🔨 Oppgave 2.4

Push branchen din til GitHub og sjekk ut om den kjører.


# 🏗️ Terraform

## 📖 Før du begynner

Installer Terraform [her](https://developer.hashicorp.com/terraform/install).

I denne workshoppen har dere ikke mulighet til å kjøre Terraform lokalt,
men du kan pushe til branch'en din og se på output fra GitHub Actions.

## 🔨 Oppgave 3.1

Se på output fra GitHub Actions i steget `deploy`. Her kan du se hva Terraform har tenkt til å lage.

## 🔨 Oppgave 3.2

Legg til en `template.container` i `azurerm_container_app`-ressursen i filen [main.tf](terraform/main.tf).

<details>
  <summary>✨ Se fasit</summary>

```hcl
resource "azurerm_container_app" "devops" {
  name                         = "${var.my_name}-app"
  container_app_environment_id = azurerm_container_app_environment.backend_env.id
  resource_group_name          = azurerm_resource_group.devops
  revision_mode                = "Single"

  template {
    container {
      name   = "devops-workshop"
      image  = "ghcr.io/computas/devops-workshop/${var.my_name}:latest"
      cpu    = "0.25"
      memory = "0.5Gi"
    }

    min_replicas    = 1
    max_replicas    = 1
    revision_suffix = substr(var.revision_suffix, 0, 10)
  }

  ingress {
    target_port      = "3000"
    external_enabled = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
```

</details>

# Setup (ikke en del av workshop'en)

1. Få tak i en Azure subscription. Pass på at provider `Microsoft.App` er registrert i subscription'en din.
Se [her](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider?tabs=azure-cli) for mer informasjon,
evt. kjør kommandoen `az provider register --namespace Microsoft.App` for å registrere den.

2. Lag en ny Storage Account i Azure for å lagre Terraform state.
Bruk skriptet `bootstrap.sh` for å sette opp en ny Storage Account, som vil lages i resource group `tfstate`.

3. Lag en App Registration i Entra, og pek den mot riktig GitHub repository/environment. Se [link]().
Du kan bruke `prod` som environment, det er det som brukes i `.github/workflows/deploy.yml`.
Gi den `Contributor`-tilgang til subscription'en din.

4. Hent ut client ID fra App Registration og legg den i GitHub repository variables under `ARM_CLIENT_ID`.
Hent også ut subscription ID og tentant ID og legg de i GitHub repository variables under `ARM_SUBSCRIPTION_ID` og `ARM_TENANT_ID`.

# devops-workshop

Lær hvordan du [deployer](https://teknisk-ordbok.fly.dev/ordbok/Deploy) koden din til [prod](https://teknisk-ordbok.fly.dev/ordbok/Produksjon)!

# 🐳 1. Docker

## 📖 Før du begynner

Installer Docker [herfra](https://docs.docker.com/engine/install).

## 🔨 Oppgave 1.1

Prøv og bygg et Docker image slik:

```bash
cd frontend
docker build . -t devops-workshop:latest
```

Du ser at den feiler, og det virker som den mangler en fil (eller filer?) for å bygge frontend'en.
Legg til det som mangler i `COPY`-steget i filen [Dockerfile](frontend/Dockerfile).

_HINT:_ Vi bruker **yarn** for å bygge frontend'en.

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

Prøv og kjør applikasjonen med denne kommandoen:

```bash
docker run -it -p 3000:3000 devops-workshop:latest
```

Da skal du kunne gå i nettleseren og se noe på [http://localhost:3000](http://localhost:3000)!

# ▶️ 2. GitHub Actions

Disse oppgavene gjøres i filen [deploy.yml](.github/workflows/deploy.yml).

## 📖 Før du begynner

Sjekk ut en git branch med navnet ditt, f.eks.:

```bash
git checkout -b andreas-bakseter
```

**PASS PÅ AT INGEN ANDRE HAR EN BRANCH MED SAMME NAVN SOM DEG!**

Hver gang du vil teste endringer, push branchen din til GitHub:

```bash
git push -u origin andreas-bakseter
```

...og lag en pull request mot `master`-branchen.

Da vil du se at GitHub Actions vil kjøre jobbene dine, og du kan se output.
Hver gang du vil teste endringer, push branchen din til GitHub.

_TIPS:_ istedenfor å lage flere commits, kan du bruke `git add .` og `git commit --amend` for å legge til nye endringer i forrige commit,
for å så pushe med `git push --force`. Dette er en god praksis for å holde git-historikken ren når du til slutt merger til `master`.

## 🔨 Oppgave 2.1

Vi vil gjerne kjøre testene våre for frontend'en i GitHub Actions, men vi mangler noen steg i jobben `run-tests`.
Fyll ut stegene som mangler for å kjøre testenen til frontend'en.
Det er bare å pushe til branchen din og se om det fungerer underveis!

_HINT:_ Se hvordan de andre jobbene definerer steg (i listen under `steps`).

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

    # legger til disse stegene:
    - name: Install dependencies
      run: yarn install

    - name: Run tests
      run: yarn test
```

</details>

## 🔨 Oppgave 2.2

Se på **Summary** på din action i GitHub UI'en.
Den finner du ved å enten trykke på **Show all checks** og så **Details** på en pull request,
eller gå [hit](https://github.com/baksetercx/devops-workshop/actions) og finn din workflow run.

Du vil da se at det ikke er noen kobling mellom stegene som kjører testene og stegene som bygger Docker image.
Vi vil at bygg-steget ikke skal starte før testene har kjørt og har passert.
Endre det slik at bygg-steget avhenger av test-steget for å kunne kjøre.

Dobbeltsjekk til slutt at bygg-steget kjører etter test-steget ved å se på **Summary** i GitHub Actions UI'en.

<details>
  <summary>✨ Se fasit</summary>

```yaml
build:
  name: 'Build Docker image and push to registry'
  needs: [run-tests] # legger til denne linjen
  runs-on: ubuntu-latest
  permissions:
    contents: read
    packages: write
  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Login to GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: 'ghcr.io'
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Build and push image to registry
      uses: docker/build-push-action@v5
      with:
        push: 'true'
        tags: 'ghcr.io/${{ github.repository }}/${{ github.head_ref }}:latest'
        context: 'frontend'
```

</details>

# 🏗️ 3. Terraform

## 📖 Før du begynner

I denne workshoppen har dere ikke mulighet til å kjøre Terraform lokalt,
men du kan pushe til branch'en din og se på output fra GitHub Actions.

## 🔨 Oppgave 3.1

Se på output fra GitHub Actions i steget `deploy`. Her kan du se hva Terraform har tenkt til å lage.

## 🔨 Oppgave 3.2

Det mangler noen felter i `azurerm_container_app`-ressursen i filen [main.tf](terraform/main.tf).
Legg til de feltene som mangler for å kunne deploye applikasjonen.
Push til branchen din og se om det fungerer!

_HINT:_ Les [dokumentasjonen](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) til `azurerm_container_app`.

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
      image  = "ghcr.io/computas/devops-workshop/${var.my_name}:latest"
      # legger til disse feltene:
      name   = "devops-workshop"
      cpu    = "0.25"
      memory = "0.5Gi"
      #
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

Push så til branchen din og se om det fungerer!

<details>
  <summary>✨ Se fasit</summary>

```yaml
deploy:
  name: 'Deploy using Terraform'
  runs-on: ubuntu-latest
  needs: [build]
  env:
    TF_VAR_revision_suffix: ${{ github.sha }}
    TF_VAR_my_name: ${{ github.head_ref }}
    TF_VAR_repository: ${{ github.repository }}
    ARM_CLIENT_ID: ${{ vars.ARM_CLIENT_ID }}
    ARM_SUBSCRIPTION_ID: ${{ vars.ARM_SUBSCRIPTION_ID }}
    ARM_TENANT_ID: ${{ vars.ARM_TENANT_ID }}
    ARM_USE_OIDC: 'true'
  permissions:
    contents: read
    id-token: write
  environment: prod
  defaults:
    run:
      working-directory: 'terraform'
  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3

    - name: Init Terraform
      run: terraform init

    - name: Set Terraform workspace
      run: terraform workspace new $TF_VAR_my_name || terraform workspace select $TF_VAR_my_name

    - name: Run Terraform plan
      run: terraform plan

    - name: Run Terraform apply
      run: terraform apply -auto-approve # legger til denne linjen
```

## 🔨 Oppgave 3.4

Se på `Outputs` under **Run Terraform apply** i loggen til GitHub Actions.
Her skal du finne en link til applikasjonen din.

</details>

# 🤓 Setup for spesielt interesserte (ikke en del av workshop'en)

1. Få tak i en Azure subscription. Pass på at provider `Microsoft.App` er registrert i subscription'en din.
   Se [her](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider?tabs=azure-cli) for mer informasjon,
   og evt. kjør kommandoen `az provider register --namespace Microsoft.App` for å registrere den.

2. Lag en ny Storage Account i Azure for å lagre Terraform state.
   Bruk skriptet `bootstrap.sh` for å sette opp en ny Storage Account, som vil lages i resource group `tfstate`.

3. Lag en App Registration i Entra ID manuelt, og pek den mot riktig GitHub repository/environment,
   se [her](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure) for mer informasjon.
   Du kan bruke `prod` som environment, det er det som brukes i `.github/workflows/deploy.yml`.
   Gi den `Contributor`-tilgang til subscription'en din.

4. Hent ut client ID fra App Registration og legg den i GitHub repository variables under `ARM_CLIENT_ID`.
   Hent også ut subscription ID og tentant ID og legg de i GitHub repository variables under `ARM_SUBSCRIPTION_ID` og `ARM_TENANT_ID`.

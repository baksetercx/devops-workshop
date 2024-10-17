# devops-workshop

Lær hvordan du [deployer](https://teknisk-ordbok.fly.dev/ordbok/Deploy) koden din til [prod](https://teknisk-ordbok.fly.dev/ordbok/Produksjon)!

# Del 1: GitHub Actions og Terraform

# ▶️ 1. GitHub Actions

Disse oppgavene gjøres i filen [deploy.yml](.github/workflows/deploy.yml).

## 📖 Før du begynner

Sjekk ut en git branch med navnet ditt, f.eks.:

```bash
git checkout -b andreas-bakseter
```

**PASS PÅ AT INGEN ANDRE HAR EN BRANCH MED SAMME NAVN SOM DEG!**

Hver gang du vil teste endringer, push de til branchen din:

```bash
git push -u origin andreas-bakseter # første gang
git push # senere
```

...og lag en pull request mot `master`-branchen.

Da vil du se at GitHub Actions vil kjøre jobbene dine, og du kan se output.
Hver gang du vil teste endringer, push branchen din til GitHub.

💡 _TIPS:_ istedenfor å lage flere commits, kan du bruke `git add .` og `git commit --amend --no-edit` for å legge til nye endringer i forrige commit,
for å så pushe med `git push --force`. Dette er en god praksis for å holde git-historikken ren når du til slutt merger til `master`.

## 🔨 Oppgave 1.1

Vi vil gjerne kjøre testene våre for frontend'en i GitHub Actions, men vi mangler noen steg i jobben `frontend-tests`.
Fyll ut stegene som mangler for å kjøre testenen til frontend'en.
Det er bare å pushe til branchen din og se om det fungerer underveis!

💡 _HINT:_ Se hvordan de andre jobbene definerer steg (i listen under `steps`).

<details>
  <summary>✨ Se fasit</summary>

```yaml
frontend-tests:
  name: 'Run frontend tests'
  runs-on: ubuntu-latest
  defaults:
    run:
      working-directory: 'frontend'
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

## 🔨 Oppgave 1.2

Se på **Summary** på din action i GitHub UI'en.
Den finner du ved å enten trykke på **Show all checks** og så **Details** på en pull request,
eller gå [hit](https://github.com/baksetercx/devops-workshop/actions) og finn din *workflow run*.

Du vil da se at det ikke er noen kobling mellom stegene som kjører testene og steget som deployer frontend'en.
Vi vil at deploy-steget ikke skal starte før testene har kjørt og passerer.
Endre det slik at deploy-steget avhenger av test-steget for å kunne kjøre.

Dobbeltsjekk til slutt at deploy-steget kjører etter test-steget ved å se på **Summary** i GitHub Actions UI'en.

<details>
  <summary>✨ Se fasit</summary>

```yaml
deploy-frontend:
  name: Deploy frontend
  runs-on: ubuntu-latest
  needs:
  - frontend-tests # legger til denne linja
  - apply-terraform
  permissions:
    contents: read
    id-token: write
  environment: prod
```

</details>

# 🏗️ 2. Terraform

## 📖 Før du begynner

I denne workshoppen har dere ikke mulighet til å kjøre Terraform lokalt,
men du kan pushe til branch'en din og se på output fra GitHub Actions.

## 🔨 Oppgave 2.1

Se på output fra GitHub Actions i steget `deploy`.
Her kan du se at Terraform feiler fordi det mangler noen attributter i en ressurs.
Vanligvis ville du sett hva Terraform har tenkt til å gjøre (en `plan`).

## 🔨 Oppgave 2.2

Det mangler noen attributtene i `azurerm_static_web_app`-ressursen i filen [main.tf](terraform/main.tf).
Legg til de feltene som mangler for å kunne deploye applikasjonen.

Push så til branchen din og se om det fungerer!

💡 _HINT:_ Les [dokumentasjonen](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app) til `azurerm_static_web_app`.

<details>
  <summary>✨ Se fasit</summary>

```hcl
resource "azurerm_static_web_app" "devops" {
  name                = "${var.my_name}-webapp"
  # legger til disse attributtene:
  resource_group_name = azurerm_resource_group.devops.name
  location            = local.location
}
```

</details>

## 🔨 Oppgave 2.3

Vi har nå lyst til å lage infrastrukturen vår med Terraform.
Legg til et siste steg i `apply-terraform`-jobben som kjører en Terraform kommando for å lage infrastrukturen vår.

Push så til branchen din og se om det fungerer!

💡 _HINT:_ Se på dokumentasjonen til [Terraform](https://developer.hashicorp.com/terraform/cli/run),
eller kjør `terraform -help` i terminalen dersom du har Terraform installert lokalt.

<details>
  <summary>✨ Se fasit</summary>

```yaml
apply-terraform:
  name: Apply Terraform changes
  runs-on: ubuntu-latest
  env:
    TF_VAR_my_name: ${{ github.head_ref }}
    ARM_CLIENT_ID: ${{ vars.ARM_CLIENT_ID }}
    ARM_SUBSCRIPTION_ID: ${{ vars.ARM_SUBSCRIPTION_ID }}
    ARM_TENANT_ID: ${{ vars.ARM_TENANT_ID }}
    ARM_USE_OIDC: 'true'
  outputs:
    resource-group-name: ${{ steps.terraform-output.outputs.resource_group_name }}
    swa-name: ${{ steps.terraform-output.outputs.swa_name }}
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
      run: terraform workspace new "$TF_VAR_my_name" || terraform workspace select "$TF_VAR_my_name"

    - name: Run Terraform plan
      run: terraform plan

    - name: Run Terraform apply
      run: terraform apply -auto-approve # legg til denne linjen
```

</details>

## 🔨 Oppgave 2.4

Se på `Outputs` under **Run Terraform apply** i loggen til GitHub Actions.
Her skal du finne en link til applikasjonen din.

## 🏁 Ferdig!

Når du er ferdig med oppgavene, lukk pull request'en din.
Det vil da kjøre en siste jobb som sletter ressursene som ble laget i Azure.

Du kan sjekke logger i GitHub Actions for å se at det fungerer!

# Del 2: Coming soon ...

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

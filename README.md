# Prototipo Funcional — Supermercados LIMA

Prototipo de la Arquitectura TO-BE Fase 5: una imagen se sube a Object Storage
en OCI, se analiza con Azure AI Vision (detección de personas/objetos, sin
identificación de identidad), y el resultado se guarda de vuelta en OCI.


## Estructura

```
terraform/oci/    Object Storage en OCI (nube principal)
terraform/azure/  Azure AI Vision (segunda nube)
scripts/          Script Python que ejecuta el flujo completo
docs/             Trazabilidad y decisiones de alcance
samples/          Imágenes de prueba (no se versionan)
```

## Requisitos

- Terraform >= 1.6
- Cuenta OCI con API key (`~/.oci/config`)
- Cuenta Azure con `az login` activo
- Python 3.10+

**Región OCI fijada a `us-ashburn-1`**, región home del tenancy trial usado
para el prototipo. Si tu tenancy tiene otra región home, ajústala en
`terraform.tfvars`. El crédito del trial es finito: despliega cerca de la
fecha de la demo y destruye la infraestructura apenas termines.

## Cómo desplegar y probar

```bash
# 1. OCI
cd terraform/oci
cp terraform.tfvars.example terraform.tfvars   # completar con valores reales
terraform init
terraform apply

# 2. Azure
cd ../azure
cp terraform.tfvars.example terraform.tfvars   # completar con valores reales
terraform init
terraform apply

# 3. Variables de entorno para el script
export AZURE_VISION_ENDPOINT=$(terraform output -raw vision_endpoint)
export AZURE_VISION_KEY=$(terraform output -raw vision_primary_key)

# 4. Ejecutar
cd ../../scripts
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

python3 analyze_image.py \
  --image ../samples/persona-generica.jpg \
  --namespace <output namespace de OCI> \
  --bucket-input <output bucket_input_name de OCI> \
  --bucket-output <output bucket_output_name de OCI>
```

Usar solo imágenes genéricas o ficticias, nunca fotos de personas reales
identificables.

## Al terminar

```bash
cd terraform/azure && terraform destroy
cd ../oci && terraform destroy
```

## Seguridad

Ningún `terraform.tfvars`, `.tfstate`, clave `.pem` o `.env` debe subirse a
GitHub (ver `.gitignore`). Las credenciales se manejan por variables de
entorno o archivos locales excluidos del repositorio.

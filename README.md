# Prototipo Funcional — Supermercados LIMA

Este prototipo implementa el workload **Reconocimiento VIP / Cámaras** de la
Arquitectura TO-BE Fase 5, usando OCI como nube principal y Azure como
segunda nube para el servicio de inteligencia artificial.

## Qué hace

Cuando se sube una imagen a Object Storage en OCI, el sistema la analiza
automáticamente con Azure AI Vision (detección de personas, objetos y
descripción de escena, sin identificación de identidad) y guarda el
resultado de vuelta en OCI. El flujo completo ocurre sin intervención
manual: un evento de creación de objeto dispara una función serverless que
orquesta todo el proceso.

El repositorio incluye dos formas de ejecutar este mismo flujo:

- **Automatizada** (`function/`): OCI Events dispara una OCI Function al
  crearse un objeto en el bucket de entrada.
- **Manual** (`scripts/analyze_image.py`): ejecuta el mismo análisis desde
  la terminal, ya metodología de versión anterior.

## Por qué Azure AI Vision y no Azure AI Face

Por cuestiones legales, Azure AI Face requiere aprobación de acceso limitado de
Microsoft y su uso con datos reales depende también del marco legal de datos en
Perú. Azure AI Vision detecta la presencia de personas sin
identificar a nadie, por lo que demuestra el mismo patrón de integración
multi-cloud sin depender de esas dos aprobaciones pendientes.

## Arquitectura

```
Cámara / origen de imagen
        │
        ▼
Object Storage (OCI) ── bucket de evidencia
        │
        │  evento de creación de objeto
        ▼
OCI Events ──► OCI Functions (analiza-imagen-vip)
        │
        │  llamada HTTP con la imagen
        ▼
Azure AI Vision (Computer Vision)
        │
        │  resultado JSON
        ▼
Object Storage (OCI) ── bucket de resultados
```

La función corre en una subred privada de una VCN, con salida a internet a
través de un NAT Gateway y acceso a Object Storage a través de un Service
Gateway. Se autentica mediante Resource Principal (identidad propia del
recurso), autorizada por un Dynamic Group y políticas de IAM con permisos
acotados a los dos buckets del prototipo, sin depender de credenciales de
usuario.

## Estructura del repositorio

```
terraform/oci/    Object Storage, red (VCN/NAT/Service Gateway), IAM,
                  OCI Functions y OCI Events — nube principal
terraform/azure/  Azure AI Vision — segunda nube
function/         Código de la OCI Function y su empaquetado como imagen
                  de contenedor (build/push a OCIR)
scripts/          Script manual de análisis (analyze_image.py)
samples/          Imágenes de prueba (genéricas, no se versionan)
```

## Alcance del prototipo

Este prototipo intenta demostrar o representar una
funcionalidad de la Fase 5, no la arquitectura completa.

## Requisitos

- Terraform >= 1.6
- Cuenta OCI con API key configurada
- Cuenta Azure con sesión de Azure CLI activa
- Python 3.10+
- Docker (solo necesario para construir la imagen de la función)

La región OCI usada es `us-ashburn-1` (región home del tenancy del
prototipo); la región Azure es `eastus`, elegida por cercanía geográfica
para minimizar latencia y costo de egress entre nubes.

## Despliegue

El orden de despliegue sigue la dependencia real entre los stacks: primero
Azure (para obtener el endpoint y la clave del servicio de visión), luego
el repositorio de contenedores en OCI, luego la imagen de la función
(construida y subida manualmente a OCIR), y finalmente el resto de la
infraestructura en OCI.

```bash
# Azure
cd terraform/azure
terraform init && terraform apply

# OCI, repositorio de contenedores primero
cd ../oci
terraform apply -target=oci_artifacts_container_repository.vip_repo

# Imagen de la función
cd ../../function
docker build -t <ocir_repo_path>/analiza-imagen:0.0.1 .
docker push <ocir_repo_path>/analiza-imagen:0.0.1

# Resto de la infraestructura en OCI
cd ../terraform/oci
terraform apply
```

Una vez desplegado, basta con subir una imagen al bucket de evidencia para
que el flujo completo se ejecute solo.

## Seguridad

Los buckets de Object Storage son privados (`NoPublicAccess`). Azure nunca
accede al Object Storage de OCI: la imagen se envía directamente en el
cuerpo de la petición HTTP hacia Azure AI Vision, sin exponer ninguna URL
pública. Las credenciales de usuario (llave de OCI, sesión de Azure CLI) no
se versionan en el repositorio. La función serverless no depende de ellas
en absoluto, al autenticarse por Resource Principal.

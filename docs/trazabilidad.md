# Trazabilidad del Prototipo Funcional — Supermercados LIMA

## 1. Alcance

Este prototipo implementa un subconjunto representativo de la Arquitectura
TO-BE Fase 5, no la arquitectura completa. Demuestra el patrón de integración
multi-cloud particionado entre OCI (nube principal) y Azure (segunda nube),
aplicado al workload de Reconocimiento VIP / Cámaras.

## 2. Mapeo de componentes

| Componente implementado | Origen en Fase 5 | Workload / FRIS |
|---|---|---|
| Bucket Object Storage (entrada) | Caja "Object Storage" — OCI Región Primaria | Reconocimiento VIP / Cámaras — Workload Inventory |
| Bucket Object Storage (salida) | Caja "Object Storage" — OCI Región Primaria | Persistencia de resultado de IA |
| Azure Cognitive Services (Computer Vision) | Caja "Azure AI Vision" — Azure Región | Reconocimiento VIP / Cámaras — Workload Inventory (segunda nube candidata → resuelta en Fase 5 como Azure) |
| Tags de proyecto/workload/ambiente | Regla FinOps: "usar tags obligatorios y cost-tracking tags" | Apuntes consolidados, sección FinOps |
| Política de ciclo de vida (30 días) | Evidencia técnica del laboratorio IaaS_VM_LB_Storage (lifecycle/versionado) | Reutilización de laboratorio, sección 16.1 |

## 3. Decisión de alcance: Azure AI Vision, no Azure AI Face

Azure AI Face es un servicio de Acceso Limitado de Microsoft (requiere
aprobación de caso de uso) y su funcionalidad de identificación biométrica
depende de una validación legal pendiente (marco legal de datos biométricos
en Perú, aún no resuelto en el proyecto). Por tanto, el prototipo usa
Azure AI Vision (detección de personas/objetos, sin identificación de
identidad), que:

- No requiere aprobación de Acceso Limitado.
- No genera un dato biométrico identificatorio.
- Sigue estando respaldado por el mismo bloque de la Fase 5 (dominio de IA
  de la segunda nube).

Esta decisión debe presentarse explícitamente en la sustentación como una
limitación de alcance consciente, no como un vacío de diseño.

## 4. Supuestos y validaciones pendientes

- Región OCI usada (`sa-saopaulo-1`) es un supuesto razonable por proximidad
  geográfica a Perú; debe confirmarse contra la región real contratada por
  el proyecto.
- Región Azure (`brazilsouth`) es equivalente, elegida por cercanía y para
  mantener la restricción de latencia entre nubes descrita en el Marco
  Metodológico.
- El uso de Azure AI Face con datos reales queda pendiente de: (a) aprobación
  de Acceso Limitado de Microsoft, (b) validación del marco legal de
  biometría en Perú. Ninguna de las dos se resuelve en este prototipo.

## 5. Qué NO incluye este prototipo (y por qué)

- Streaming/Queue, Functions y NoSQL: no aparecen como cajas explícitas en
  el diagrama de Fase 5; pertenecen al detalle de implementación del
  Workload Inventory, no a la arquitectura final dibujada. Se excluyen para
  mantener trazabilidad estricta.
- Edge gateway por tienda: es parte del roadmap de cámaras a más largo
  plazo, no de la Fase 5 tal como está dibujada.
- Identificación individual de personas (Azure AI Face): ver sección 3.

# Flujo funcional

```mermaid
flowchart TD
 A[Datos de riesgos y controles] --> B[Validación de identificadores y escalas]
 B --> C{¿Datos consistentes?}
 C -- No --> D[Registrar incidencia y corregir]
 D --> A
 C -- Sí --> E[Asociación riesgo-control]
 E --> F[Criticidad: probabilidad por impacto]
 F --> G[Generación de alertas]
 G --> H[Scoring y clasificación]
 H --> I[Reporte y revisión del analista]
 I --> J[Seguimiento de planes]
 J --> K[Monitoreo de métricas y cambios]
```

La rama de rechazo y el seguimiento representan el flujo objetivo propuesto; el MVP actual ejecuta validaciones y priorización, pero no implementa una plataforma de gestión de incidencias.

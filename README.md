# Yunusco Accessories

Flutter application for Yunusco garment accessories workflows.

## Source structure

- `lib/core/`: shared networking, session state, preferences, constants, and helpers.
- `lib/data/datasources/`: ERP API and Firestore access.
- `lib/data/repositories/`: feature-level data access used by the app.
- `lib/domain/repositories/`: repository contracts consumed by presentation.
- `lib/models/`: request and response models.
- `lib/presentation/providers/`: Riverpod state and repository wiring.
- `lib/screens/`, `lib/widgets/`, and `lib/theme/`: user interface.
- `lib/services/`: push notification lifecycle and presentation.

## Authentication

The app opens on the login flow at startup. A successful login reads `token` from
the response and keeps it in memory for API authorization; it is not restored
from cookies or persisted between app launches.

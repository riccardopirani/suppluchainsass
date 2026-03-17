# Multi-Warehouse Support

Implementazione completa del supporto per magazzini multipli nella applicazione.

## Architettura

### Database Schema

#### Tabelle Principali
- **warehouses**: Definisce i magazzini disponibili per ogni workspace
  - `id`: UUID primaria
  - `workspace_id`: Riferimento al workspace
  - `name`: Nome del magazzino
  - `location`: Ubicazione geografica
  - `capacity`: Capacità massima in unità
  - `is_default`: Flag per indicare il magazzino predefinito

- **product_inventory**: Traccia lo stock di ogni prodotto in ogni magazzino
  - `id`: UUID primaria
  - `product_id`: Riferimento al prodotto
  - `warehouse_id`: Riferimento al magazzino
  - `quantity`: Quantità disponibile
  - `reorder_point`: Punto di riordino specifico del warehouse
  - `safety_stock`: Stock di sicurezza specifico del warehouse

- **purchase_orders**: Collegamento al warehouse di destinazione
  - `warehouse_id`: Magazzino dove ricevere l'ordine

### Providers Riverpod

#### `warehousesProvider`
Recupera tutti i magazzini del workspace attuale.

```dart
final warehousesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Fetches warehouses for current workspace
});
```

#### `selectedWarehouseProvider`
State provider per tracciare il magazzino selezionato.

```dart
final selectedWarehouseProvider = StateProvider<String?>((ref) => null);
```

#### `currentWarehouseProvider`
Ritorna il magazzino attualmente selezionato o quello di default.

```dart
final currentWarehouseProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Returns selected or default warehouse
});
```

#### `productInventoryProvider`
Recupera l'inventario per il magazzino selezionato.

```dart
final productInventoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Returns product inventory for selected warehouse
});
```

## UI Components

### WarehouseSelector Widget
Dropdown nel sidebar per selezionare il magazzino attivo.

```dart
const WarehouseSelector(),
```

- Mostra la lista di tutti i magazzini
- Consente di selezionare il warehouse attivo
- Aggiorna automaticamente i dati in tutte le pagine

### WarehousesPage
Pagina di gestione dei magazzini disponibile in `/app/warehouses`.

**Funzionalità:**
- Visualizza lista dei magazzini
- Crea nuovo magazzino con form dialog
- Marca un magazzino come default
- Elimina magazzino (con conferma)
- Mostra capacità e ubicazione di ogni warehouse

## Edge Functions

### sync-warehouse-inventory
Funzione automatica che crea record di `product_inventory` quando:
1. Un nuovo warehouse viene creato
2. Un nuovo prodotto viene aggiunto al workspace

**Trigger**: `on_warehouse_created` - Si attiva dopo l'inserimento di un warehouse

**Comportamento**:
- Recupera tutti i prodotti del workspace
- Crea un record di `product_inventory` per ogni prodotto nel nuovo warehouse
- Inizializza con quantità = 0

## Flusso Utente

### 1. Creazione Warehouse
```
Sidebar "Warehouses" → Cliccmare "Add Warehouse" 
→ Form (Name, Location, Capacity, Default?)
→ Salva → product_inventory creati automaticamente
```

### 2. Selezione Warehouse
```
Sidebar WarehouseSelector → Scegli warehouse
→ Tutti i dati si aggiornano per quel warehouse
```

### 3. Gestione Inventario
- **Products Page**: Mostra stock per il warehouse selezionato
- **Purchase Orders**: Associabili al warehouse di ricezione
- **Dashboard**: Metriche relative al warehouse selezionato
- **Analytics**: Dati filtrati per il warehouse attivo

## Implementazione negli Provider Esistenti

Tutti i dati filtrati per warehouse selezionato:

```dart
productsProvider        → Prodotti del workspace
productInventoryProvider → Stock del warehouse selezionato
purchaseOrdersProvider  → Ordini del workspace
forecastsProvider       → Previsioni del workspace
reorderRecommendationsProvider → Raccomandazioni per il warehouse
```

## Row Level Security (RLS)

### Policies su `warehouses`
- SELECT/INSERT/UPDATE/DELETE: Limitato ai workspace members

### Policies su `product_inventory`
- SELECT/INSERT/UPDATE/DELETE: Limitato ai warehouse del workspace

## Prossimi Passi (Opzionali)

1. **Transfer tra Warehouse**: Edge function per trasferire stock
2. **Warehouse Analytics**: Metriche per singolo warehouse
3. **Inventory Allocation**: Logica automatica di allocazione stock
4. **Warehouse Performance**: KPI per warehouse (velocity, capacity utilization)
5. **Reorder Rules per Warehouse**: Regole diverse per ogni magazzino

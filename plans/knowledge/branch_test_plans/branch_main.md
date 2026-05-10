---
LastRunOnCommit: 4bc66d5426d1a2b568e2a0fd6b27f1fa886d69dc
---

# Branch test plan — `main`

## Analyze (summary)

- **Plans:** `plans/stories/order-food.md` (**US-100**), `plans/stories/track-order.md` (**US-101**); scenarios **`plans/scenarios/add-menu-item.md` (#TS-100)** and **`plans/scenarios/submit-order-with-valid-delivery-details.md` (#TS-101)** (both under US-100). No scenario file yet for US-101.
- **SmartTests root:** `tc-tests/` (iOS Mobilewright). **Environment:** `ai-test-instructions.md` — Simulator + `IOS_APP_PATH`, no backend.
- **App reality:** Cart list does not expose per-line quantity steppers; quantity changes happen on **MenuItemDetailView** (`+` / `−` / `Add to Order`). Delivery is a **full-screen** success view (no separate “delivery form” fields).

## Plan — tests to author

| # | Spec | Scenario link | Intent |
|---|------|----------------|--------|
| 1 | `order-flow.spec.js` | #TS-100 | Menu → item detail → adjust `+` / `−` → Add to Order → cart shows correct line total. |
| 2 | `order-flow.spec.js` | #TS-101 | Cart non-empty → Place Order → delivery confirmation copy (`on its way`, delivery minutes). |

### Test 1 — #TS-100 Add menu item and change quantity

#### Arrange

- Simulator app installed (`IOS_APP_PATH`), fresh process: terminate + launch `bundleId`.
- User on welcome; no cart state.

#### Act

1. `New Order` → menu visible (`MAIN DISHES`).
2. Open **Quantum Shrimp Cascade**; assert quantity **1**.
3. Tap **`+`** twice (quantity **3**), **`−`** once (quantity **2**).
4. **`Add to Order`** → **`View Order`**.

#### Assert

- Cart shows **`2 × ₭38.00`** (or equivalent line) and total **₭76.00** for that line.
- `markScreenState` at menu loaded, detail adjusted, cart open.

### Test 2 — #TS-101 Submit order with valid delivery details

#### Arrange

- Same app boot as test 1; cart empty at start of test.

#### Act

1. Menu → add **Coffee** (single qty) → **`View Order`**.
2. **`Place Order`** (green button).

#### Assert

- Copy like **`on its way`** and **`minutes for delivery`** visible (delivery success screen per `DeliveryView.swift`).
- `markScreenState` after submit.

## Phase completion (this run)

- **Phase 1 Analyze:** done — plans read, SmartTests root confirmed.
- **Phase 2 Plan:** done — table + AAA above; user requested authoring in same flow.
- **Phase 3 Execute:** done — specs added under `tc-tests/`.
- **Phase 4 Validate:** done — `npx mobilewright test order-flow.spec.js` from `tc-tests/` with `IOS_APP_PATH` + `TESTCHIMP_API_KEY` (3 passed, ~28s).
- **Phase 5 ExploreChimp:** N/A — not opted in on branch plan.
- **Phase 6 Cleanup:** N/A — no ephemeral env; app terminate covered in `afterEach` where applicable.

## Checklist

- [x] Branch plan file created / updated
- [x] SmartTests for #TS-100 and #TS-101 authored in `tc-tests/`
- [x] Local device-backed run for `order-flow.spec.js` (green)
- [ ] CI / full `npm test` on PR when workflow expanded beyond smoke
- [ ] (Optional) Add scenarios for **US-101** when defined in `plans/`

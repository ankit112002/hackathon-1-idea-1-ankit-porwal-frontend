# Stitch design brief — Iturrieta Book

Paste-ready prompts for [Google Stitch](https://stitch.withgoogle.com). Generate **two web apps**, in this order. The guest site is the judge’s first impression. The staff console is the second.

Do not redesign the product logic. Match the screens, copy, and rules below. Make the UI feel like a Basque cider house: warm paper, bottle green, cider amber, large serif headlines, real Spanish copy. It must not look like a generic SaaS dashboard or a default Material list.

---

## How to use this file

1. Open Stitch. Start a **new project**.
2. Paste **Prompt 1** in full. Ask for a **mobile-first responsive web app** (phone 390px and desktop 1280px).
3. When those screens exist, start a **second project** and paste **Prompt 2**.
4. If a screen comes back flat, reply in the same chat with the matching **Fix** line at the bottom of that prompt. Do not start over.
5. Export the frames. The Flutter app already has the flow; these frames are the visual target.

On-screen language is **Spanish** (the live app defaults to `es`). Keep the language chips `ES · EN · EU` in the header. Do not translate the Basque motto.

---

## Product in one line

**Iturrieta Book** is the table-booking site for Sidrería Iturrieta in Aramaio. Guests reserve a cider-house menu. Staff run the room in real time. Owners change the floor, the calendar, and the prices.

Motto, always visible on the guest home: **Sagarretik txotxera**.

House facts the UI must show, never invent around:

- Open **Thursday to Sunday** only. Monday–Wednesday are visibly closed.
- Fixed menu: adult **45 €**, child **16 €**. Cider is included.
- Groups of **8 or more** pay a **10 € deposit per person**. Smaller groups confirm at once. Unpaid deposits cancel after 15 minutes.
- A group bigger than the online maximum is told to call. Public phone: **+34 685 72 15 93**.
- Times are every **15 minutes** inside the chosen service.
- If the service has no seats left, the guest joins a **waitlist** instead of booking.
- Guest keeps a private link to cancel or move the booking.
- Sample service day for mock data: **jueves 29 octubre 2026**, lunch, tables **T1–T6**, benches **B1–B2**.

---

## Shared visual system

Use this on both apps so they feel like one product.

**Mood.** A printed cider-house menu that became a website. Editorial, tactile, quiet luxury. Apple wood, poured cider, linen, evening light in a stone dining room. Local and specific to the Basque Country. Confident, not rustic-cliché (no clip-art barrels, no cartoon apples, no stock “happy diners”).

**Color.**

| Token | Hex | Use |
| --- | --- | --- |
| Paper | `#F6F1E7` | Page background |
| Surface | `#FFFDF8` | Cards, sheets, inputs |
| Ink | `#1E2420` | Text |
| Bottle green | `#1F4D36` | Primary buttons, selected day, key rules |
| Cider | `#C45C26` | Accent, today, allergy notes, deposit |
| Danger | `#8C2F2F` | Errors, no-show, destructive confirm |
| Line | `#E4DCCB` | Hairline borders, dividers |

No purple gradients, no pure black, no neon, no glassmorphism, no heavy drop shadows. Depth comes from paper vs surface and a 1px line.

**Type.**

- Headlines: **Fraunces** (soft serif, optical size large). Hero can be 56–72px on desktop, 36–44px on phone.
- Body and UI: **Source Sans 3**. 16–18px body. Never below 14px for labels.
- Numbers (prices, covers, seat counts) in Fraunces so they feel like a menu.

**Shape.** Radius 12px on cards and buttons. Buttons at least 44px tall. Primary button is solid bottle green, white label. Secondary is a green outline on paper. One primary action per screen, placed at the bottom of the phone layout and as a clear right-side action on desktop.

**Chrome.** Sticky top bar: wordmark **Iturrieta** in Fraunces, small place line **Aramaio**, language chips, and on inner guest pages a back control to home. No hamburger that hides the booking CTA.

**States every screen needs.** Loading (quiet, no spinner circus), empty, error with **Reintentar**, and a success confirmation. Allergy and deposit states must be impossible to miss.

**Do not.** Lorem ipsum. Inter/Roboto-only UI. Icon-only navigation without labels. Cards that are just a single line of text stacked with equal gaps. Centered everything. Fake charts that the product does not have.

---

# Prompt 1 — Guest web app (paste this whole block)

Design a mobile-first responsive website for **Iturrieta Book**, the public booking site of Sidrería Iturrieta, a Basque cider house in Aramaio. This is the screen a judge sees first. It must feel warm, editorial, and expensive in the first three seconds, then make reserving a table obvious.

Visual system: page `#F6F1E7`, cards `#FFFDF8`, text `#1E2420`, primary `#1F4D36`, accent `#C45C26`, danger `#8C2F2F`, borders `#E4DCCB`. Headlines in Fraunces, body in Source Sans 3. Radius 12. No generic SaaS look, no purple, no stock illustrations of people at laptops. Photography direction: close crops of cider pouring from height into a glass (txotx), apple orchard light, a long wooden table. Use photography as atmosphere, never as a banner that pushes the booking button below the fold on a phone.

Language on screen: Spanish. Header language chips: **ES** (selected), **EN**, **EU**. Wordmark: **Iturrieta**. Place: **Aramaio**. Motto, do not translate: **Sagarretik txotxera**.

Generate these 6 screens as one connected flow, phone and a desktop version of the home and the booking steps.

## Screen G1 — Home

Purpose: desire + one action. The primary button is **Reservar mesa**. A quiet text link **Equipo** goes to staff sign-in. Do not give Equipo the same visual weight as Reservar.

Layout, phone:

- Full-bleed photo, top 55% of the first viewport, darkened just enough that cream type stays readable.
- Over the photo: small eyebrow **Sidrería · Aramaio**, huge motto **Sagarretik txotxera**, one sentence: **Reservas de la sidrería. Consulta los turnos abiertos y reserva mesa.**
- Primary button **Reservar mesa** sits on the photo, not under it.
- Below the fold, a section **Turnos** as a horizontal strip of four elegant rows, not a dump of equal cards:
  - Jueves · Comida · 13:00–16:00 · última reserva 15:30 · 80 cubiertos
  - Jueves · Cena · 20:00–23:00 · última reserva 22:00 · 60 cubiertos
  - Viernes · Comida · 13:00–16:00
  - Sábado · Comida · 13:00–16:00
  Each row shows the weekday in cider color, the service name in Fraunces, and the hours in small caps. Closed weekdays are absent.
- Section **Noticias**. One published event card: **Concierto en la sidrería**, date, two lines of description, a thin cider rule on the left. Empty state copy if needed: **No hay noticias.**
- Footer: phone **+34 685 72 15 93**, **Jueves a domingo**, **Aramaio**.

Desktop: split hero. Left column is type and the button. Right column is the photograph, full height of the hero. Turnos and Noticias sit in a two-column band underneath. Max content width about 1120px, generous side margins.

## Screen G2 — Reservar, step 1 of 3, Fecha

A stepped booking, not a long form. Stepper at the top: **1 Fecha** (current), **2 Comensales**, **3 Datos**. Current step is bottle green; future steps are the hairline color.

- Month calendar, only Thursday–Sunday selectable. Monday–Wednesday look disabled, not hidden. Selected day is a solid bottle-green circle. Today is a soft cider ring.
- Selected day label in Fraunces: **Jueves 29 de octubre**.
- Under the calendar, two service cards side by side on desktop, stacked on phone:
  - **Comida · 13:00–16:00** — **24 plazas libres** — button **Elegir turno**
  - **Cena · 20:00–23:00** — **Completo** in cider, no time picker, the card explains they can still continue to the waitlist
- After Comida is chosen, a wrap of time chips every 15 minutes from 13:00 to 15:30. Selected chip is bottle green with white type. Label: **Elige una hora**.
- Sticky bottom bar: **Continuar** enabled only after a time is chosen (or the shift is full).
- Closed-day message, if they land on a shut date: **La sidrería está cerrada ese día.**

## Screen G3 — Reservar, step 2 of 3, Comensales

Title: **¿Cuántas personas?**

- Two large steppers, not tiny icon buttons. **Adultos** default 2, minimum 1. **Niños** default 0. The number is Fraunces, about 40px. Minus and plus are 44px circles.
- Notes field, label **Notas**, hint **Alergias, celiaquía, vegetariano**. This field should feel important, not like an afterthought.
- A menu receipt card on surface, with a cider left border:
  - **Total del menú**
  - **90 €** in large Fraunces (example: 2 adults)
  - **La sidra está incluida.**
  - If the party is 8 or more, a second line in cider: **Seña 120 €** (example: 12 × 10 €) and a short line **Grupos de 8 o más. Seña de 10 € por persona.**
- If seats remain: primary **Continuar**.
- If the party is larger than seats left: the receipt stays, and a calm banner says the service is full. Primary button becomes **Apuntarme a la lista de espera**.
- If the party is too big to book online: replace the continue button with **Llamar** using **+34 685 72 15 93** and the sentence **Para un grupo así, llámanos.**
- Secondary **Atrás**.

Show the 12-adult variant as the hero state of this screen, because that is the demo: total **540 €**, deposit **120 €**, cider included. Also show the small-party variant (2 adults, 90 €, no deposit) as a second frame.

## Screen G4 — Reservar, step 3 of 3, Datos

Title: **¿Cómo te localizamos?**

- If waitlist: a banner **Este turno está completo. Te avisamos si se libera una mesa.**
- Fields, stacked, large tap targets, labels above the field not floating inside it: **Nombre**, **Teléfono**, **Email**.
- Summary strip above the fields, so the guest sees what they are confirming: **Jueves 29 oct · 13:00 · Comida · 12 adultos · 540 € · seña 120 €**.
- Primary **Confirmar reserva**. On the waitlist variant the primary is **Apuntarme a la lista de espera**.
- While sending, the button reads **Enviando** and is disabled.
- Inline error in danger color, example **Introduce un teléfono con al menos 9 dígitos.**
- Secondary **Atrás** and a text button **Llamar**.

## Screen G5 — Confirmación

This screen should feel like a host just said yes. Not a receipt dumped in a card.

- Small cider check, then Fraunces headline **La mesa está reservada.**
- If they returned from payment: **Gracias. La seña está pagada.**
- A reservation card:
  - Guest name **Ane Etxebarria**
  - **29 oct 2026 · 13:00**
  - **Comida**
  - **12 adultos · 0 niños**
  - Status pill **Confirmada** in bottle green, or **Pendiente de seña** in cider when a deposit is still due
  - Notes, if any, on a cider-tinted strip: **Alergia al gluten**
  - **Seña 120 €** and either **Seña pagada.** or **La seña sigue pendiente.**
- If deposit is unpaid: one dominant button **Pagar seña**. Under it, quiet helper text that an unpaid hold cancels in 15 minutes.
- Secondary actions: **Gestionar esta reserva** and **Copiar enlace**.
- A second frame for the paid state, and a third for the waitlist success line **Estás en la lista de espera.** (no pay button).

## Screen G6 — Tu reserva

Private manage page opened from the copied link. Same reservation card as confirmation.

- If the visit is inside 48 hours of the meal, a policy note: the deposit is not refunded inside that window. Outside it, cancellation is free. Do not use legal-wall typography; one sentence.
- If the booking can still change: **Cancelar reserva** as a danger outline (not the first thing the eye hits) and **Cambiar fecha** as the secondary green outline.
- Changing the date expands the same calendar + shift + time chips as step 1, then **Guardar**.
- Success lines: **La reserva está cancelada.** and **La reserva tiene una nueva fecha.**
- Missing token state: **No encontramos esta reserva.** with **Reintentar**.

Desktop for G2–G6: the form sits in a 640px column. To its right, a sticky summary panel repeats date, service, party, menu total, and deposit, like a menu standing on the table. Phone: that summary is the strip at the top of steps 2 and 3, not a second scroll.

End of guest prompt. Generate all frames before stopping.

### Fix lines (guest)

- Home feels generic: make the motto the largest type on the page and put **Reservar mesa** on the photograph.
- Booking feels like a settings form: enlarge the stepper numbers, make the receipt card the visual hero of step 2, and keep only one green button.
- Confirmation feels like an error page: it is a welcome, with the guest name in Fraunces and the status as a pill.

---

# Prompt 2 — Staff web app (paste this whole block)

Design a separate responsive web app for the staff of Sidrería Iturrieta. Same visual system as the guest site: paper `#F6F1E7`, surface `#FFFDF8`, ink `#1E2420`, bottle green `#1F4D36`, cider `#C45C26`, danger `#8C2F2F`, line `#E4DCCB`, Fraunces for titles and big numbers, Source Sans 3 for UI. It is a working floor tool used on a phone during service and on a laptop by the owner. It should feel like the same house, quieter and denser than the guest site. No marketing hero. No purple admin template.

Two roles:

- **Camarero** sees only **Sala**, plus sign out.
- **Dueño / encargado** sees **Sala, Panel, Plano, Calendario, Noticias, Ajustes**, plus sign out.

Navigation is a labeled horizontal bar under the title, not a mystery icon rail. Current item is bottle green text with a 2px cider underline. **Salir** sits at the end, in ink, not red.

Generate these screens. Phone width for Sala and sign-in. Desktop width for Panel, Plano, Calendario, and Ajustes. Noticias can be a simple desktop list.

## Screen S1 — Acceso del equipo

Centered narrow card on paper, max 420px. Wordmark **Iturrieta**, eyebrow **Equipo**. Fields **Email** and **Contraseña**. Primary **Entrar**. Error: **Esos datos no coinciden. Inténtalo otra vez.** Link back to the public site, text only: **Volver a la sidrería**. No illustration.

## Screen S2 — Sala (the service screen)

This is the live floor. Date in Fraunces: **Jueves 29 oct 2026**. A phone-shaped add action in the header: **Reserva por teléfono**.

List of booking cards, the most important screen in the staff app. Each card:

- Time and name in Fraunces: **13:00 · Ane Etxebarria**
- **12 adultos · 0 niños**
- Status pill: **Confirmada** (green), **Sentados** (ink on surface), **Completada** (muted), **No presentado** (danger), **Lista de espera** (cider)
- Table line: **B1** or **Sin mesa**
- If there are notes, a full-width cider wash (`#C45C26` at low opacity) with the note in ink, not a tiny caption: **Notas: Alergia al gluten**. This must be the thing a waiter cannot miss.
- Actions as a wrap of 44px buttons: **Sentados** (primary, only if not yet seated or completed), **Completada** (outline), **No presentado** (outline), **Asignar mesa** (outline)

Show four cards so the hierarchy is obvious:

1. 13:00 Ane, 12 adults, notes highlighted, unassigned, status confirmada
2. 13:15 Iker, 4 adults, table **T2**, status sentados, notes absent
3. 13:30 Maite, 2 adults + 1 child, **Sin mesa**
4. 14:00 waitlist offer, status **Ofrecida**, no seat actions

Empty state, separate frame: **Todavía no hay reservas hoy.** and one button **Ver el siguiente turno abierto**. Use this for a Monday.

Assign-table dialog: title **Asignar mesa**, list **T1 · 4**, **T2 · 4**, **T3 · 6**, **T4 · 4**, **T5 · 6**, **T6 · 4**, **B1 · 10**, **B2 · 10**. A check on the assigned one. Tapping toggles.

Phone-booking dialog: same fields as the guest form in a sheet — name, phone, email, adults, children, time, notes — primary **Guardar**. Title **Reserva por teléfono**.

## Screen S3 — Panel

Owner dashboard for one service day. Five stat tiles, not a chart library. Each tile is a surface card, label in small Source Sans, value in Fraunces around 36px:

- **Cubiertos hoy** — 86
- **Reservas hoy** — 14
- **Cubiertos mañana** — 40
- **No presentados, 30 días** — 3
- **Señas de hoy** — 240 €

Below, only for the owner, two sections:

- **Equipo**. Rows: name and role. Role is a compact menu: **Dueño**, **Encargado**, **Camarero**. Example rows: **Amaia · Dueño**, **Unai · Camarero**.
- **Actividad reciente**. Quiet list: **bookings · update**, timestamp. Empty copy: **Sin actividad reciente.**

No graphs. The numbers are the design.

## Screen S4 — Plano

A floor the owner can drag. Toolbar: hint **Arrastra las mesas. Luego guarda.**, outline button **Añadir mesa**, primary **Guardar plano**.

Canvas about 880×560 on the paper color, 1px line border, pinch-zoom implied by being inside a viewer. Tables are physical objects:

- **T1–T6** as rounded rectangles, bottle-green 2px stroke, surface fill, label and seat count centered: **T3** / **6**
- **B1** and **B2** as longer benches, slightly wider, cider stroke so a bench reads differently from a table
- Shadows none. A dragged table lifts with a 2px green stroke only.

Add-table dialog: **Nombre de la mesa**, **Plazas**, **Cancelar**, **Guardar**. Empty canvas copy: **Todavía no hay mesas.**

## Screen S5 — Calendario

Closing a day, not a pretty month grid for its own sake.

- A large date row **29 oct 2026** with a calendar icon that opens a date picker.
- Field **Motivo**, example **Boda privada**.
- Primary **Cerrar este día**.
- List of closed days underneath, each with the date, the reason, and a remove icon. Empty: **No hay días cerrados.**

Warning dialog, separate frame, because this is the moment an owner might wipe real bookings: title **Hay 6 reservas este día**, body lists guest names **Ane Etxebarria, Iker Aguirre…**, actions **Cancelar** and **Cerrar igualmente** (danger). The warning must look more serious than the rest of the admin UI.

## Screen S6 — Noticias

Staff editor for what the home page shows.

- Primary **Nueva noticia**
- Cards: Spanish title **Concierto en la sidrería**, a pill **Publicada** or **Borrador**, outline **Editar**
- Editor dialog, wide: title and description fields labeled **ES**, **EN**, **EU**, and a switch **Publicar**. Actions **Cancelar** and **Guardar**.

## Screen S7 — Ajustes

Two clear groups, not one endless form.

Group **Carta y reglas**, a surface card:

- **Menú adulto** 45
- **Menú infantil** 16
- **Seña por persona** 10
- **Seña a partir de** 8
- **Grupo máximo online** 20
- **Cancelación gratuita, horas antes** 48
- **Teléfono público** +34 685 72 15 93
- Primary **Guardar**. Success **Guardado.**

Group **Turnos**. One card per service, example **Comida · Jueves**, hours **13:00–16:00**, editable **Última reserva**, **Cubiertos**, **Grupo mínimo**, **Grupo máximo**, and **Guardar** on that card. If changing a shift affects people already booked, the same serious warning dialog as the calendar: names listed, **Cancelar** / **Confirmar igualmente**.

Waiter never sees S3–S7. Show one frame of Sala with only **Sala** and **Salir** in the nav, so the restricted role is visible.

End of staff prompt.

### Fix lines (staff)

- Sala cards all look the same: make the allergy strip a full-width cider band and the time+name the largest text.
- Panel looks like analytics software: delete charts, keep five big numbers.
- Plano looks like a spreadsheet: tables must sit on a room canvas and benches must be a different shape from tables.

---

## Flow map (for you, not for Stitch)

Guest:

1. `/` Home → **Reservar mesa**
2. `/book` step Fecha → Comensales → Datos
3. Confirm creates the booking → `/book/confirm?token=…`
4. Groups of 8+ → **Pagar seña** (Stripe). Return with `paid=1` shows thanks.
5. **Gestionar esta reserva** → `/manage/:token` → cancel or change date.
6. Shift full → waitlist instead of a table. Too large for online → call **+34 685 72 15 93**.

Staff:

1. Home **Equipo** → `/admin/login`
2. Camarero lands on `/admin/waiter` only.
3. Dueño lands on `/admin` and can open Sala, Plano, Calendario, Noticias, Ajustes.
4. Sala is live: seat, complete, no-show, assign T1–T6 or B1–B2, or add a phone booking.
5. Closing a day or editing a shift warns with the names already booked.

Judge path to design for, in order: **G1 → G3 (12 adults) → G5 (deposit) → S2 (allergy visible) → S4 → S3.**

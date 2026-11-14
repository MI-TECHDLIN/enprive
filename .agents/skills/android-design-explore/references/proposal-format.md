# Proposal format

A proposal is two files the previewer app watches: `DESIGN.md` at the app's root (the shared design system) and `design/<slug>.proposal.json` (one design direction). The app validates both on every save and returns errors from `open_proposal` and `status` as `{path, message}`, where `path` points into the file (`/screens/plates/components/3/variant`, `/theme/colors/primary`, or `/designMd/...` for DESIGN.md).

`get_catalog` is the component vocabulary: every component, its props, their allowed values, and which children each slot accepts. This file covers the file structure around it.

## Token names

A prop that names a color, type style, shape, or spacing step takes a token name, never a hex value or a dimension. The two files spell the same token differently:

| Token | In the proposal (props, styles) | In DESIGN.md keys |
| --- | --- | --- |
| Color role | `ColorScheme` property name: `primaryContainer`, `onSurfaceVariant` | kebab case under `colors`: `surface-container-high` |
| Type role | `Typography` property name: `titleMedium`, `displayLargeEmphasized` | kebab case under `typography`: `display-large-emphasized` |
| Corner | `none`, `extraSmall`, `small`, `medium`, `large`, `largeIncreased`, `extraLarge`, `extraLargeIncreased`, `extraExtraLarge`, `full` | kebab case under `rounded`: `extra-large` |
| Shape polygon | `MaterialShapes` name in camel case: `sunny`, `cookie9Sided` | not in DESIGN.md |
| Spacing | a name from `spacing`: `md` | the same name under `spacing` |
| Icon | a Material Symbols name: `restaurant`, `arrow_back` | not in DESIGN.md |

## DESIGN.md

Only the YAML front matter is read; the prose below it is for people and is kept as written.

```yaml
---
version: alpha
name: Tonight's plate
colors:
  primary: "#B5523B"
typography:
  display-large: { fontFamily: Fraunces, fontVariation: "'opsz' 72, 'SOFT' 50" }
  display-large-emphasized: { fontFamily: Fraunces, fontVariation: "'opsz' 72, 'SOFT' 50" }
  # ...and Fraunces on display-medium through headline-small, plus title-large
rounded:
  extra-large: 28px
material:
  scheme: { seed: "{colors.primary}", variant: tonal-spot, contrast: 0 }
  styles:
    hero_title: { type: displayLargeEmphasized, color: onPrimaryContainer }
---
```

- **`colors.primary`** is the seed. Without a DESIGN.md the seed is `#6750A4`, so always write one. Any other key under `colors` is a color role in kebab case whose `#RRGGBB` replaces the generated role; use it rarely, since the generated scheme keeps contrast pairs intact.
- **`material.scheme`**: `seed` refers to the seed as `"{colors.primary}"` (or is a hex), `variant` is one of `tonal-spot` (the default), `neutral`, `vibrant`, `expressive`, `monochrome`, `fidelity`, `content`, `rainbow`, `fruit-salad`, and `contrast` runs from -1.0 to 1.0 (0 by default). The variants mostly move tertiary, so read `colors` from `check_proposal` after choosing one. Observed in the previewer on green `#00A646` and blue `#3B6FB5` seeds: `neutral` and `fruit-salad` keep tertiary near the seed's hue; `tonal-spot`, `rainbow`, and `vibrant` turn it to a neighboring hue (green to olive, teal, or cyan; blue to violet, pink, or purple); `expressive`, `fidelity`, and `content` throw it far (green to orange, rose, or blue; blue to mint, ochre, or mauve); `monochrome` is gray. `fidelity` and `content` also draw `tertiaryContainer` as a saturated mid tone, not a pale one: a green seed gave rose `#CB4268`.
- **`typography`**: keys are type roles in kebab case. Only `fontFamily`, `fontVariation` (axis list such as `"'wght' 650, 'wdth' 80, 'ROND' 100"`), `fontWeight`, and `letterSpacing` apply; sizes and line heights stay Material's. Families: `Google Sans Flex` on any role (the default for all), `Google Sans Code` on any role (numbers and data), one brand face on display, headline, and `title-large` roles only (`Fraunces`, `Bricolage Grotesque`, `Big Shoulders Display`), and `Doto` on display roles only. Any other family is a validation error. Set a chosen brand face on all six baseline display and headline roles (`display-large` through `headline-small`; Doto on the three display roles) and on `title-large`, because components read them internally: `LargeFlexibleTopAppBar`'s expanded title is `displaySmall`, and a small `TopAppBar` title and a `SideSheet` title draw in `titleLarge`. Roles do not inherit from each other, so an emphasized display, headline, or `title-large` style a screen uses needs its own key too.
- **`rounded`**: corner names in kebab case with px values, read as dp. Unlisted corners keep Material's scale.
- **`spacing`**: names to px values. Without it the scale is `none 0, xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48`. Declaring `spacing` replaces that whole scale, so list every step the proposals use.
- **`material.styles`**: named styles shared by every proposal, each a set of token names (see Styles below).

DESIGN.md may carry keys for other tools; the app ignores names it does not know there. A proposal's `theme` is strict and rejects them.

## The proposal file

```json
{
  "$schema": "https://raw.githubusercontent.com/charliesbot/android-design/main/app/schemas/proposal.schema.json",
  "format": 1,
  "name": "Tonight's plate",
  "theme": { },
  "navigation": { "start": "plates", "panes": { "plates": "list", "plate_detail": "detail" } },
  "screens": { "plates": { }, "plate_detail": { } }
}
```

- **`format`** is `1`. **`name`** is the title the viewer shows.
- **`theme`** (optional) takes the same keys as the DESIGN.md front matter and deep-merges over it, key by key. Put a direction's own seed, variant, faces, or styles here so DESIGN.md stays the shared base.
- **`navigation.start`** names the first screen. **`navigation.panes`** gives a screen a pane role, `list`, `detail`, `supporting`, or `extra`; an unlisted screen is a single pane. At expanded widths a `detail` screen shows beside its `list`. **`navigation.placeholders`** maps a `list` screen to the screen drawn in the detail pane while nothing is selected (`"placeholders": { "plates": "pick_plate" }`): Material shows "placeholder content in the detail pane" of a two-pane layout, and `check_proposal` notes (`empty-detail-pane`) a list pane shown beside an empty one. The placeholder is an ordinary screen in `screens` that is in no pane and that no `navigate` action opens. The graph's edges are the `navigate` actions in the screens; there is no separate edge list.
- **`navigation.destinations`** declares the app's top-level navigation once: 3 to 5 entries of `screen`, `label`, `icon`, optional `selectedIcon`, and a literal `badge`. It is not a component or a `Scaffold` slot (the validator rejects `NavigationBar`, `NavigationRail`, and `navigationRail`). The previewer draws a bar at compact and a rail from medium up, outside the panes; the selected destination is the first one from the top of the back stack, a tap resets the back stack to its screen, and the navigation hides on a full-window screen that is not a destination. A destination screen has pane role `list` or none. **`railExpanded`** adds labels beside the rail's icons from 840 dp. `get_catalog` has the full rules. With fewer than three top-level destinations use `Tabs`.
- **`screens`** maps a screen id to its content. Screen ids and component ids are identifiers: letters, digits, and underscores, not starting with a digit (`plate_detail`, never `plate-detail`).

## Screens and components

Each screen is an A2UI v1.0 `createSurface` body:

- **`catalogId`**: `https://github.com/charliesbot/android-design/catalogs/m3-expressive/v1`, on every screen (a Wear proposal uses the Wear id, see [Wear OS](#wear-os)).
- **`components`**: a flat list. Each entry has a unique `id`, a `component` name from the catalog, and that component's props. Exactly one entry has `"id": "root"`, usually a `Scaffold`.
- **`dataModel`** (optional): the screen's sample data as JSON.

Parents refer to children by id, never by nesting objects:

- A **`Child`** prop (a named slot such as `topBar`, `content`, `leading`, `anchor`) takes one id: `"topBar": "bar"`.
- A **`ChildList`** prop (`children`, `actions`, `items`, a card's `content`) takes an array of ids, `["title", "body"]`, or a **template** that repeats one component per array item: `{"componentId": "plate_row", "path": "/plates"}`.

A slot may restrict what it holds (a `Scaffold`'s `bottomBar` takes a `FloatingToolbar` or `DockedToolbar`); `get_catalog` lists those limits and the validator enforces them.

## Writing it compactly

Writing the file is most of the time a proposal takes, so keep it short:

- **One component per line**, as a compact object, the way the example below is written. Indent only the envelope.
- **Leave out every prop that equals its default.** `get_catalog` shows each default after the kind, as in `variant: filled|tonal|elevated|outlined|text = filled`.
- **Repeat with a template**, not with copies: one row component bound to a `dataModel` array.
- **Name a style once** in `material.styles` when several components share the same type, color, and shape.
- **Revise with small edits** to the lines that change. Rewrite the whole file only for a new direction, and never generate it with a script.

## Data and bindings

Any text, number, boolean, `badge`, `icon`, or image `src` prop may be a binding instead of a literal: `{"@path": "/user/name"}` reads from the screen's `dataModel`. Inside a template, a relative path reads from the current item: `{"@path": "name"}`, and `{"@call": "@index"}` is the item's index. Keep sample data representative and non-sensitive. Everything else is a literal: color and type roles, shapes, spacing, enums such as `variant`, child references, and actions. A template repeats one component, so to vary one of those per item write the items out as separate components. A component id may be listed once per size class: the validator rejects an id that two parents both list, or one parent lists twice, overlays and components nothing references included, and a template's `componentId` counts as a listing, so give each use its own id.

## Actions

An `action` prop calls a renderer function; the renderer never calls the agent, and `event` actions are rejected.

```json
"action": { "functionCall": { "@call": "navigate", "args": { "screen": "plate_detail" } } }
```

- `navigate` with `screen`: pushes that screen.
- `back`: pops one screen.
- `open` with `overlay`: opens a `BottomSheet`, `Dialog`, `Menu`, `SideSheet`, `SearchView`, `Tooltip`, `Snackbar`, `DatePicker`, or `TimePicker` of the same screen by id. Overlays are closed until opened, and one is open at a time: opening another replaces it.
- `dismiss`: closes the open overlay.

`Tabs` holds `Tab` children and has no content of its own: each `Tab`'s `action` is a `navigate` to the screen that shows that tab, which repeats the `Tabs` with its own tab `selected`. A `Carousel` takes `children` like a list, usually a template, and clips each item to the carousel shape. A multi-browse or hero carousel draws large, medium, and small items, and item text adapts to the size. `itemSize` on a node inside a carousel item (the item itself or anything under it; an error anywhere else, and not valid in a `sizeClass` override) sets the smallest item size the node shows at: `"large"` shows it only while its item is at full size, `"medium"` hides it only on the small item, and leaving it out shows it on every item. For example, `"large"` on a title and `"medium"` on a label. The mask rounds the corners of the medium and small items and crops start-aligned text there (`text-clipped` names how many dp), which `itemSize` avoids. Contrast is checked against the nearest container color role up the tree (the screen's background at the root), never against image pixels, so text over an image needs its own container, such as a style with `container`, to be checked honestly.

A `SideSheet` takes a `title`, `content`, and an optional `back` action that adds a back icon button (a close icon button is always there). A `Snackbar` takes a `message`, an optional `actionLabel` with its `action`, and `dismiss` for a close icon; it draws in the screen's `Scaffold`, so the screen needs one. `badge` on a `Tab`, an `IconButton`, or a destination is `true`, a number, or a text of at most four characters.

A `DatePicker` takes `variant` (`modal`, `modal-input`, `docked`, or `full-screen`), `range`, and its dates as ISO text: `selected`, or `start` and `end` for a range (`start` required, `end` not before it). Dates are written out, never bound to data, and the picker opens on the month of the date, because a preview must not read the clock. A docked picker names the `TextField` it opens below in `anchor`; like the `anchor` of a `Menu` or `Tooltip`, it goes in the base props, never in a `sizeClass` override, and a modal picker may keep it so the picker can turn docked from medium widths up (override `variant`). A `TimePicker` takes `variant` (`dial` or `input`), `time` as `HH:mm`, and `is24Hour` (a preview setting: the exported picker follows the device's clock setting). A `Dialog` takes `variant`: `basic` (`title`, `text`, `confirm`, `dismiss`) or `full-screen` (`title`, `confirm`, `content`: the body below a header with a close icon). A full-screen dialog is for compact windows only: `showIn` compact, or override `variant` to `basic` in `sizeClass` for medium and up, or the proposal is rejected. A full-screen date picker is recommended on compact windows, so the checker only notes one at medium widths and up.

A `SearchBar`, or a `TopAppBar` of size `search` (its `title` is the field's hint), names the `SearchView` it opens in `expanded`; tapping the field opens it, and a view nothing names is rejected. On a `TopAppBar`, `avatar` and `expanded` are for size `search` only and rejected on any other size. The view's `layout` is `full-screen` (the default, for compact windows) or `docked`. A search bar has at most two trailing elements, an `avatar` counting as one; a search app bar has at most two `actions` at compact widths, with an `avatar` in addition, and up to four from medium widths up (override `actions` in `sizeClass`). A `Tooltip` names the component it hangs off in `anchor`; `plain` is one line of `text` for an icon-only control, and `rich` adds a `title` and up to two text `Button`s in `actions`. It opens on hover or long press on a device, and by `open` in the previewer.

A `Menu` opened by `open` names the component it hangs from in `anchor`. A `Menu` held by a `SplitButton`'s `menu` slot leaves `anchor` out: the split's trailing button opens it, and an `anchor` back to the split is rejected as a cycle.

## Responsive props

Size classes are measured on the preview frame: `compact` below 600 dp, `medium` 600 to 839 dp, `expanded` 840 dp and up.

- **`showIn`**: the size classes a component appears in, all by default. `"showIn": ["compact", "medium"]` on a back button hides it where the detail pane sits beside the list.
- **`sizeClass`**: prop overrides for `medium` or `expanded`: `"sizeClass": {"expanded": {"columns": 3}}`. An override holds ordinary props of that component.

## Full-height panes

Panes fill the window's height (`android-design`, layout reference). In a proposal, side-by-side panes are a `Row` with `"verticalAlignment": "stretch"`: its `Column`, `Row`, and `Box` children fill the row's height. The row needs height to fill, so make it the `Scaffold`'s `content`, or give it `"weight": 1` inside a `Column`. Give each pane `weight` for its share of the width, and `"scroll": true` on the pane `Column` that holds a list, so the list scrolls inside its pane. Use `showIn` or `sizeClass` so the stretched row appears only where the panes sit side by side. A `Column` that does not fill its width (an unweighted child of a `Row`, a child of a `Box`, a list item's `trailing` slot) wraps its content and stretches none of its children: its `horizontalAlignment` places them, and `weight` on a pane `Column` in a `Row` is what makes it fill. A wrapping `Row` or `Column` is only as wide (or tall) as its children, so its `arrangement` (`spaceBetween`, `spaceAround`, `spaceEvenly`, `center`, `end`) does nothing there and its children sit flush: `check_proposal` notes it as `arrangement-no-space`. Give it room on that axis. A `Row` needs a weight on the pane or `Column` that wraps it in its parent `Row` (a weight shares the axis of the parent it sits in, so weighting the header `Row` inside the pane does not help). A `Column` needs a weight in its parent `Column`, or, when a `Row` holds it, a `Row` with a height (a weight in a `Column`, or the `Scaffold`'s `content`) and `"verticalAlignment": "stretch"`.

## Styles

`"style": "hero_title"` applies a named style from `material.styles` (DESIGN.md merged with the proposal's `theme`). A style's keys are `type` (type role), `color` (content color role), `container` (container color role), `shape` (corner or polygon), and `padding` (spacing name). A prop written on the component wins over its style.

## Common props

- Every component accepts `weight` (its share of a `Row` or `Column`, or of any other parent whose Compose lambda is a row or column: a toolbar, a `Card`, the actions of a top app bar; a `Box` and a `Grid` ignore it), `padding` (a spacing name: it surrounds the component, except on a `Card` or a component whose style gives it a `container`, where it sits inside the container around the content, and without it the rounded corners cut content flush against the edge, which `check_proposal` reports as `corner-clipped`), and `maxWidth` (the widest it draws, in dp: it still stretches up to that width, and its parent's alignment places it), besides `showIn`, `sizeClass`, and `style`. A component inside a `Carousel` item also accepts `itemSize`. A weighted child of a `Column` with `"scroll": true` gets no height to share once the column's content is taller than the screen (the common case), or when the column does not fill its parent's height, and collapses to nothing: `check_proposal` reports it as `weight-collapsed`, so drop the weight or give the column a bounded height. A weighted `Spacer` is exempt: it only takes what is left, which may be nothing.
- Interactive components accept `primary`, `contentDescription`, and `enabled`. Set `"primary": true` on the screen's one primary action. Give every icon-only control a `contentDescription` that states its purpose.
- `Image` has no size prop: `aspectRatio` sets its height from the width its parent gives it, and `maxWidth` (24 to 1600 dp) caps that width, so `"aspectRatio": 1, "maxWidth": 88, "shape": "full"` is an 88 dp avatar. Without `aspectRatio` it draws at its bitmap's natural size (observed: 100 by 50 dp for a 200 by 100 px file), which `maxWidth` only caps.
- `Text` truncates with `maxLines` and `"overflow": "ellipsis"`; without `overflow` it clips.

## Component rules

These are design rules, not syntax: the validator checks some of them, and the rest are yours to follow.

- Related content at the same level of hierarchy is `Tabs`, each `Tab` navigating to its screen, scrollable when the tabs do not fit; fewer than three top-level destinations are tabs. A visual collection is a `Carousel`: at most three items with text show at compact widths, item text stays brief (at most two lines at compact widths unless the background is simple). Item text adapts to the item size: `"itemSize": "large"` on a title shows it only on the large item, and `"medium"` hides a node only on the small item.
- Overlays (`BottomSheet`, `SideSheet`, `Dialog`, `DatePicker`, `TimePicker`, `Menu`, `SearchView`, `Tooltip`, `Snackbar`) open from a control. A modal bottom sheet opens at about half the window height and scrolls inside, so its key action sits near the top. A `SideSheet` is the modal side sheet, preferred in compact windows, and always carries its close icon button; the standard side sheet, which stays beside the main content at medium and expanded widths, is a screen with pane role `supporting` whose first element is a header with a title and a close icon button. A full-screen `Dialog` is for tasks with several steps or keyboard input and changes that are not saved at once, labels its confirm button by its outcome (Save, Send, Create) and never disables it; it is for compact windows only, so from medium up use a basic one. A date picker is a modal one in a dialog on compact windows (full-screen is recommended there) and a docked one below its text field from medium up; use modal input for dates that need no calendar. A time picker is always modal. A `Snackbar` is brief and low priority, with at most one action and no icon, and draws above the FAB and never in front of navigation.
- A single choice from a short list is a `RadioGroup` of `RadioButton`s with exactly one `selected` (the validator checks it, since radio buttons always have one option selected), not switches. Several choices are `Checkbox`es, and a `Checkbox` with `indeterminate` is a parent whose children are only partly checked. A `Switch` takes `icons` (a check, or a check and a close) when on and off need to read at a glance. A `Slider` is `variant: "centered"` when the range crosses zero, and `orientation: "vertical"` is for a vertical slider; a `RangeSlider` stays horizontal.
- A `DockedToolbar` goes in the `Scaffold`'s `bottomBar` for global actions that stay the same across pages, never at the same time as the navigation bar (the check flags both drawn at once): the bar belongs to primary pages, so put the toolbar on pages with actions, such as a full-window detail. Use a `FloatingToolbar` for actions of the current page. A `Menu` of several kinds of items is `MenuGroup`s, each a gap apart; `MenuItem` `role: "single"` selects one item per group and closes the menu, `"multi"` toggles and stays open, and `colors: "vibrant"` is for use sparingly.
- A `TopAppBar` of `size: "medium"` or `"large"` is a flexible app bar that collapses to the small bar as the content scrolls (it draws expanded at rest), so it suits long scrolling screens with a prominent title.
- A repeated set of cells that wraps onto more rows is a `Grid` with `columns` (1 to 24) or `minColumnWidth` (dp; the column count follows the width) and `spacing`. Its columns are equal tracks that ignore their content's width: a longer label wraps in its track, it does not widen it. One line of items shared by `weight` is a `Row`.
- A `badge` keeps its default colors and leaves room at the edge so it is not cut off.
- Text keeps 40 to 60 characters per line at every size. `check_proposal` reports `line-length` for a card, a list item, or a paragraph wider than 60 characters at its measured character width. Measured in the previewer in Google Sans Flex, 60 characters are about 400 dp of container width in `bodyMedium` and `labelLarge` and about 470 dp in `bodyLarge` and `titleMedium`, padding included, so `maxWidth` 400 passes in all four. Fix it the way Material does: give the content a `maxWidth` (in a single pane, often on the pane's `Column` with `horizontalAlignment` set), make a list pane a fixed pane beside a flexible one, or move to more columns.

## Limits

A proposal is a still, tap-driven drawing of catalog components, so some things cannot be expressed. Stand in with the nearest piece and say in the Show step what the real thing is, so the port builds it:

- **Charts and graphs:** the catalog has no chart or canvas. Use a placeholder `Image` with an `aspectRatio` (a `ProgressIndicator` for one value).
- **Custom motion:** only `LoadingIndicator` and an indeterminate `ProgressIndicator` move. Describe the intended motion in words.
- **Gestures:** the only input is a tap running an action (`navigate`, `back`, `open`, `dismiss`). Describe a swipe or a drag in words.

## Wear OS

A Wear proposal is its own file, `design/<slug>-wear.proposal.json`, and every screen names the Wear catalog id (mixing catalogs is a validation error). `get_catalog` with `catalog: "wear"` lists the components and their props. The syntax, actions (`navigate`, `back`, `open`, `dismiss`), and `DESIGN.md` are the ones above, with these differences:

- **`catalogId`**: `https://github.com/charliesbot/android-design/catalogs/wear-m3-expressive/v1`. There is no `navigation.panes`.
- **Views:** `watch` (204 dp) and `watch-large` (227 dp), round and dark.
- **Root:** a `Screen`. `scroll` (default `true`) makes its `children` the rows of a scrolling list that scales and fades at the round edge; `scroll: false` stacks them in a fixed box. `timeText` (default `true`) shows the clock, off on dialogs and pickers. `edgeButton` takes the id of one `EdgeButton`, drawn at the bottom edge. An `EdgeButton` takes exactly one of `label` or `icon`, never both (the API's content is "Either an Icon or Text"); validation rejects both or neither. On a fixed screen the body ends above the edge button, so everything else must fit the space left; `text-clipped` and `round-edge-clipped` report what does not.
- **Components:** the Wear catalog lists them (`get_catalog`). A dialog (`AlertDialog`, `ConfirmationDialog`) is an overlay in the same screen: `open` it from a control.
- **Roles:** colors and types are Wear role names, never hex. Wear has `primaryDim`, `surfaceContainerHigh`, and `errorDim` but no `surface`; its types include `numeral*` and `display*`.
- **`large`:** the only `sizeClass` key, applied from 225 dp (`watch-large`): `"sizeClass": {"large": {"type": "numeralExtraLarge"}}`. A `large` override only adds value.
- **`primary`:** set `"primary": true` on the screen's one primary action: a `Button`, `CompactButton`, `IconButton`, `TextButton`, or `EdgeButton`. On a scrolling screen it is usually the `EdgeButton`.
- **Touch targets** are 48 dp; give every icon-only control a `contentDescription`.

```json
{
  "format": 1,
  "name": "Wear timer",
  "navigation": { "start": "home" },
  "screens": {
    "home": {
      "catalogId": "https://github.com/charliesbot/android-design/catalogs/wear-m3-expressive/v1",
      "components": [
        { "id": "root", "component": "Screen", "edgeButton": "start", "children": ["header", "time"] },
        { "id": "header", "component": "ListHeader", "text": "Timer" },
        { "id": "time", "component": "Text", "text": "05:00", "type": "numeralLarge", "color": "primaryDim", "align": "center", "sizeClass": { "large": { "type": "numeralExtraLarge" } } },
        { "id": "start", "component": "EdgeButton", "label": "Start", "primary": true }
      ]
    }
  }
}
```

## Example

An adaptive app: three destinations, and a list that opens a detail screen, side by side at expanded widths. It assumes the DESIGN.md above. The list has a `maxWidth` because at medium widths it fills the window alone.

```json
{
  "$schema": "https://raw.githubusercontent.com/charliesbot/android-design/main/app/schemas/proposal.schema.json",
  "format": 1,
  "name": "Tonight's plate",
  "navigation": {
    "start": "plates",
    "panes": { "plates": "list", "plate_detail": "detail" },
    "placeholders": { "plates": "pick_plate" },
    "destinations": [
      { "screen": "plates", "label": "Plates", "icon": "restaurant" },
      { "screen": "shop", "label": "Shopping", "icon": "shopping_cart", "badge": 3 },
      { "screen": "saved", "label": "Saved", "icon": "bookmark" }
    ]
  },
  "screens": {
    "plates": {
      "catalogId": "https://github.com/charliesbot/android-design/catalogs/m3-expressive/v1",
      "dataModel": {
        "plates": [
          { "name": "Burrata and tomatoes", "time": "15 min" },
          { "name": "Charred leeks", "time": "35 min" }
        ]
      },
      "components": [
        { "id": "root", "component": "Scaffold", "topBar": "bar", "content": "list", "floatingActionButton": "add" },
        { "id": "bar", "component": "TopAppBar", "size": "large", "title": "Tonight's plate" },
        { "id": "list", "component": "List", "variant": "segmented", "padding": "lg", "maxWidth": 420, "children": { "componentId": "plate_row", "path": "/plates" } },
        { "id": "plate_row", "component": "ListItem", "headline": { "@path": "name" }, "supporting": { "@path": "time" }, "action": { "functionCall": { "@call": "navigate", "args": { "screen": "plate_detail" } } } },
        { "id": "add", "component": "FloatingActionButton", "icon": "add", "label": "New plate", "extended": true, "primary": true }
      ]
    },
    "plate_detail": {
      "catalogId": "https://github.com/charliesbot/android-design/catalogs/m3-expressive/v1",
      "components": [
        { "id": "root", "component": "Scaffold", "topBar": "bar", "content": "body" },
        { "id": "bar", "component": "TopAppBar", "title": "Burrata and tomatoes", "navigationIcon": "back" },
        { "id": "back", "component": "IconButton", "icon": "arrow_back", "contentDescription": "Back", "showIn": ["compact", "medium"], "action": { "functionCall": { "@call": "back" } } },
        { "id": "body", "component": "Column", "padding": "lg", "spacing": "lg", "children": ["hero", "cook"] },
        { "id": "hero", "component": "Text", "text": "15 minutes, no stove", "style": "hero_title" },
        { "id": "cook", "component": "Button", "size": "large", "label": "Start cooking", "icon": "skillet", "primary": true }
      ]
    },
    "pick_plate": {
      "catalogId": "https://github.com/charliesbot/android-design/catalogs/m3-expressive/v1",
      "components": [
        { "id": "root", "component": "Box", "contentAlignment": "center", "children": ["hint"] },
        { "id": "hint", "component": "Text", "text": "Pick a plate", "type": "bodyLarge" }
      ]
    },
    "shop": {
      "catalogId": "https://github.com/charliesbot/android-design/catalogs/m3-expressive/v1",
      "components": [
        { "id": "root", "component": "Scaffold", "topBar": "bar", "content": "body" },
        { "id": "bar", "component": "TopAppBar", "title": "Shopping" },
        { "id": "body", "component": "Text", "text": "Leeks, burrata, basil", "padding": "lg" }
      ]
    },
    "saved": {
      "catalogId": "https://github.com/charliesbot/android-design/catalogs/m3-expressive/v1",
      "components": [
        { "id": "root", "component": "Scaffold", "topBar": "bar", "content": "body" },
        { "id": "bar", "component": "TopAppBar", "title": "Saved" },
        { "id": "body", "component": "Text", "text": "Nothing saved yet", "padding": "lg" }
      ]
    }
  }
}
```

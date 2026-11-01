# CFB-X-Advanced-
CFB Boiler parameters



A SwiftUI app for browsing **Circulating Fluidized Bed (CFB) boiler** and **natural gas burner** reference data by load. Pick a load, and the app shows the matching steam, coal, air-flow, and burner values. It also plots parameter curves, compares two loads side by side, and exports the comparison as PDF or CSV.

> **Note:** All values shown in the app are static reference data, not live plant measurements. Do not use them as the sole basis for operating decisions. Always use your facility's approved data.

## Features

- **Boiler dashboard (CFB-X tab)**
  Select a boiler load (40–100%) and view steam flow, coal consumption, O₂ level, total/primary/secondary air flows, coal chute air, loop seal air, re-circulation air, and secondary air header pressure.

- **Burner dashboard (Burner tab)**
  Select a burner load (0–100%) and view air and natural gas flows for the front wall burners and the left and right wall burners.

- **Trends (Trends tab)**
  Interactive line charts of any boiler parameter versus load, built with Swift Charts.
  - Horizontally scrolling parameter chips
  - A marker for the currently selected load
  - Drag on the chart to change the load

- **Compare (Compare tab)**
  Choose **Load A** and **Load B** and see each parameter's value at both loads, the absolute difference, and the percentage change. A swap button flips A and B.

- **Export**
  Share the comparison as a **PDF** report or a **CSV** file through the system share sheet (`ShareLink`).
  - The PDF is rendered with `ImageRenderer` as a print-friendly, light-themed report.
  - The CSV opens correctly in Excel: it uses a UTF-8 BOM, and a `;` separator when the device locale uses a decimal comma.

## Screenshots

<!-- Add screenshots here, for example:
| Boiler | Burner | Trends | Compare |
|--------|--------|--------|---------|
| ![Boiler](docs/boiler.png) | ![Burner](docs/burner.png) | ![Trends](docs/trends.png) | ![Compare](docs/compare.png) |
-->
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen1.PNG
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen2.PNG
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen3.PNG
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen4.PNG
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen5.PNG
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen6.PNG

<a href="url"><img src="https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen1.PNG" align="left" height="334" width="187" ></a> 
<a href="url"><img src="https://github.com/agurani/CFBx/blob/master/CFB/CFB/IMG_3882.PNG" align="left" height="334" width="187" ></a> <br/> 
https://github.com/agurani/CFB-X-Advanced-/edit/main/README.md#:~:text=screen1.PNG

## Requirements

- Xcode 16 or later
- iOS 18 or later (the app uses the new `Tab` syntax)
- Swift 5.9 or later

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/CFB-X.git
   cd CFB-X
   ```
2. Open the project in Xcode:
   ```bash
   open CFB-X.xcodeproj
   ```
3. Select an iPhone simulator or a connected device.
4. Press **Run** (⌘R).

### Running on a physical iPhone

1. In **Settings > Privacy & Security**, enable **Developer Mode**.
2. In Xcode, select your project, then **Signing & Capabilities**, and choose your team.
3. Connect the iPhone and run the app.

With a free Apple ID, builds expire after 7 days and must be reinstalled from Xcode. A paid Apple Developer Program account extends this.

## Project Structure

| File / Folder | Description |
|---|---|
| `ContentView.swift` | Tab bar and all main views: boiler, burner, trends, compare, export |
| `ReferenceData` | Reference tables for the boiler and burner, indexed by load |
| `Assets.xcassets` | App icon and the dashboard color set |

### Color assets

The UI theme reads these named colors from the asset catalog. Add them (with light and dark variants) if they are missing:

- `DashboardBackground`
- `DashboardPanel`
- `DashboardAccent`
- `DashboardMuted`
- `DashboardBorder`

## How It Works

- `ReferenceData.boiler[load]` and `ReferenceData.burner[load]` return an array of values for the given integer load percentage. Views read parameters by column index.
- A shared `Dashboard` container provides the header, scrolling layout, and footer for every screen.
- `LoadCompareView` is generic. It takes a load range, a data source, and a list of parameter groups, so the boiler and burner comparisons share the same code.
- Export data is captured in a `CompareSnapshot`. PDF and CSV files are generated only when the user taps a share button.

## Tech Stack

- SwiftUI
- Swift Charts
- `ShareLink` and `Transferable` for file sharing
- `ImageRenderer` for PDF generation

## Customization

**Adding a parameter to Trends:** add a case to `TrendsView.Param`, then provide its column `index` and `unit` in the two `switch` statements.

**Adding a parameter to Compare:** add a `CompareSpec` entry to the relevant `CompareGroup`.

**Changing the load range:** update the `range` passed to `LoadCompareView` and the bounds in the load selectors.

## Roadmap

- Burner trends tab (gas/air ratio curves)
- Burner comparison tab
- Multi-parameter and stacked air distribution charts
- Localization (English and Turkish)
- Multi-page PDF export

## License

Add your license here (for example, MIT) and include a `LICENSE` file in the repository.

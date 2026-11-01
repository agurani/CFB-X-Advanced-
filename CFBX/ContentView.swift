import SwiftUI
import Charts
import UniformTypeIdentifiers

private enum Theme {
    static let background = Color("DashboardBackground")
    static let panel = Color("DashboardPanel")
    static let accent = Color("DashboardAccent")
    static let muted = Color("DashboardMuted")
    static let border = Color("DashboardBorder")
}



struct ContentView: View {
    var body: some View {
        TabView {
            Tab("CFB-X", systemImage: "flame") { BoilerView() }
            Tab("Burner", systemImage: "carbon.dioxide.cloud") { BurnerView() }
            Tab("Trends", systemImage: "chart.xyaxis.line") { TrendsView() }
            //Tab("B.Trends", systemImage: "chart.line.uptrend.xyaxis") { TrendsView() }
            Tab("Compare", systemImage: "arrow.left.arrow.right") { BoilerCompareView() }
        }
        .tint(Theme.accent)
    }
}

private struct Measurement: Identifiable {
    let id: String
    let label: String
    let value: Double
    let unit: String
    var detail: String? = nil
}

private struct BoilerView: View {
    @State private var load = 92
    private var row: [Double] { ReferenceData.boiler[load] }

    var body: some View {
        Dashboard( title: "CFB-X", subtitle: "CFB Performance Data", description: "Parameters According to Load"){
            LoadSelector(title: "Boiler Load", value: $load)
            //ReferenceNotice()
            MeasurementSection(title: "Parameters", symbol: "gauge.with.dots.needle.50percent", items: [
                .init(id: "steam", label: "Steam Flow", value: row[13], unit: "t/h"),
                .init(id: "coal", label: "Coal Consumption", value: row[4], unit: "t/h"),
                .init(id: "oxygen", label: "Oxygen Level · II. Pass", value: row[3], unit: "%"),
        
                .init(id: "total", label: "Total Air", value: row[5], unit: "kg/sn"),
                .init(id: "primary", label: "Primary Air Flow", value: row[8], unit: "kg/sn"),
                .init(id: "upper", label: "Secondary Air Upper Air Flow", value: row[1], unit: "kg/sn"),
                .init(id: "lower", label: "Secondary Air Lower Air Flow", value: row[2], unit: "kg/sn"),
                .init(id: "burner", label: "Secondary Air Burner Air Flow", value: row[9], unit: "kg/sn"),
                .init(id: "chute", label: "Coal Chutes Air Flow", value: row[6] / 4, unit: "kg/sn", detail: "For Each Chute"),
                .init(id: "rising", label: "LoopSeal Rising Zone Air Flow", value: row[10], unit: "kg/sn"),
                .init(id: "downcomer", label: "LoopSeal Downcommer Zone Air Flow", value: row[11], unit: "kg/sn"),
                .init(id: "recirculation", label: "Re-Circulation Air Flow", value: row[12], unit: "kg/sn"),
                .init(id: "pressure", label: "Secondary Air Header Pressure", value: row[7], unit: "mbar")
            ])
            
        }
    }
}

private struct BurnerView: View {
    @State private var demand = 50
    private var row: [Double] { ReferenceData.burner[demand] }

    var body: some View {
        Dashboard(title: "Burner", subtitle: "Burner Performance Data", description: "Reference Values According to Demand") {
            BurnerLoadSelector(title: "Burner Load", value: $demand)
            //ReferenceNotice()
            MeasurementSection(title: "Front Wall Burners", symbol: "flame", items: [
                .init(id: "front-air", label: "Air Flow", value: row[1], unit: "kg/sn"),
                .init(id: "front-gas", label: "Natural Gas Flow", value: row[2], unit: "kg/sn", detail: "")
            ])
            MeasurementSection(title: "Left & Right Walls Burners", symbol: "flame", items: [
                .init(id: "side-air", label: "Air Flow", value: row[3], unit: "kg/sn"),
                .init(id: "side-gas", label: "Natural Gas Flow", value: row[4], unit: "kg/sn", detail: "")
            ])
        }
    }
}


private struct TrendsView: View {
    enum Param: String, CaseIterable, Identifiable {
        case steam = "Steam Flow"
        case coal = "Coal Consumption"
        case totalAir = "Total Air"
        case primary = "Primary Air Flow"
        case secAirUpperFlow = "Secondary Air Upper Flow"
        case secAirLowerFlow = "Secondary Air Lower Flow"
        case secAirPressure = "Secondary Air Pressure"
        case recirculation = "Recirculation Flow"
        case o2 = "Oxygen"

        var id: String { rawValue }

        var index: Int {
            switch self {
            case .steam: 13
            case .coal: 4
            case .totalAir: 5
            case .primary: 8
            case .secAirUpperFlow: 1
            case .secAirLowerFlow: 2
            case .secAirPressure: 7
            case .recirculation: 12
            case .o2: 3
            }
        }

        var unit: String {
            switch self {
            case .steam, .coal: "t/h"
            case .totalAir, .primary, .secAirUpperFlow, .secAirLowerFlow, .recirculation: "kg/sn"
            case .secAirPressure: "mbar"
            case .o2: "%"
            }
        }
    }

    @State private var param: Param = .steam
    @State private var load = 92
    @State private var selection: Double?

    private var points: [(load: Int, value: Double)] {
        (40...100).map { ($0, ReferenceData.boiler[$0][param.index]) }
    }

    private var current: Double { ReferenceData.boiler[load][param.index] }

    var body: some View {
        Dashboard(title: "Trends", subtitle: "Load Curves", description: "Parameter vs Boiler Load") {

            // Yatay kayan parametre butonları
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Param.allCases) { p in
                            Button {
                                withAnimation(.snappy(duration: 0.25)) { param = p }
                            } label: {
                                Text(p.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                    .fixedSize()
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .foregroundStyle(param == p ? Color.white : Color.primary)
                                    .background(
                                        Capsule().fill(param == p ? Theme.accent : Theme.panel)
                                    )
                                    .overlay(
                                        Capsule().stroke(param == p ? Color.clear : Theme.border)
                                    )
                            }
                            .buttonStyle(.plain)
                            .id(p)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, -20)
                .onChange(of: param) { _, new in
                    withAnimation(.snappy) { proxy.scrollTo(new, anchor: .center) }
                }
            }

            LoadSelector(title: "Boiler Load", value: $load)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(current, format: .number.precision(.fractionLength(0...3)))
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: current))
                        .animation(.snappy(duration: 0.25), value: current)
                    Text(param.unit).font(.caption).foregroundStyle(Theme.muted)
                    Spacer()
                    Text("at \(load)% load").font(.caption).foregroundStyle(Theme.muted)
                }

                Chart {
                    ForEach(points, id: \.load) { p in
                        LineMark(x: .value("Load %", p.load), y: .value(param.unit, p.value))
                            .foregroundStyle(Theme.accent)
                            .interpolationMethod(.monotone)
                    }
                    RuleMark(x: .value("Current", load))
                        .foregroundStyle(Theme.muted)
                    PointMark(x: .value("Load %", load), y: .value(param.unit, current))
                        .foregroundStyle(Theme.accent)
                        .symbolSize(90)
                }
                .chartXScale(domain: 40...100)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxisLabel("Boiler Load (%)")
                .chartYAxisLabel(param.unit)
                .chartXSelection(value: $selection)
                .onChange(of: selection) { _, new in
                    if let new { load = min(100, max(40, Int(new.rounded()))) }
                }
                .frame(height: 260)
            }
            .padding(16)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border))
        }
    }
}


    
    
    
    
    
    
    
    private struct Dashboard<Content: View>: View {
    let title: String
    let subtitle: String
    let description: String
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle().fill(Theme.accent).frame(width: 7, height: 7)
                            Text(subtitle).font(.caption.weight(.bold)).tracking(1.3)
                        }.foregroundStyle(Theme.accent)
                        Text(title).font(.largeTitle.bold())
                        Text(description).font(.subheadline).foregroundStyle(Theme.muted)
                    }.padding(.top, 12)
                    content
                    Text("CFB-X  •  ŞİŞECAM")
                        .font(.caption2.weight(.semibold)).tracking(1.2)
                        .foregroundStyle(Theme.muted).padding(.vertical, 8)
                }
                .frame(maxWidth: 700, alignment: .leading)
                .padding(.horizontal, 20).padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("CFB-X")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

private struct LoadSelector: View {
    let title: String
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.headline)
                    //Text("Bir değer seçin").font(.caption).foregroundStyle(Theme.muted)
                }
                Spacer()
                Text("\(value)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(value)))
                    .animation(.snappy(duration: 0.25), value: value)
                Text("%").font(.title3.weight(.semibold)).foregroundStyle(Theme.accent)
            }
            Slider(value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }), in: 40...100) {
                Text(title)
            }.tint(Theme.accent)
            HStack {
                Text("40%")
                Spacer()
                Text("100%")
            }.font(.caption.monospacedDigit()).foregroundStyle(Theme.muted)
            Stepper("Adjust step by step: %\(value)", value: $value, in: 40...100).font(.subheadline)
        }
        .padding(20)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border))
    }
}

private struct BurnerLoadSelector: View {
    let title: String
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.headline)
                    //Text("Bir değer seçin").font(.caption).foregroundStyle(Theme.muted)
                }
                Spacer()
                Text("\(value)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(value)))
                    .animation(.snappy(duration: 0.25), value: value)
                Text("%").font(.title3.weight(.semibold)).foregroundStyle(Theme.accent)
            }
            Slider(value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }), in: 0...100) {
                Text(title)
            }.tint(Theme.accent)
            HStack {
                Text("0%")
                Spacer()
                Text("100%")
            }.font(.caption.monospacedDigit()).foregroundStyle(Theme.muted)
            Stepper("Adjust step by step: %\(value)", value: $value, in: 0...100).font(.subheadline)
        }
        .padding(20)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border))
    }
}




private struct ReferenceNotice: View {
    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "info.circle").foregroundStyle(Theme.accent)
            Text("Bunlar canlı ölçüm değil, eski uygulamadaki belirli bir kazana ait referans değerleridir. İşletme kararları için tesisin onaylı verilerini kullanın.")
                .font(.caption).foregroundStyle(Theme.muted).fixedSize(horizontal: false, vertical: true)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct MeasurementSection: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let symbol: String
    let items: [Measurement]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol).font(.headline).foregroundStyle(.primary)
            VStack(spacing: 0) {
                ForEach(items) { item in
                    MeasurementRow(item: item)
                    if item.id != items.last?.id {
                        Divider().overlay(Theme.border).padding(.horizontal, 16)
                    }
                }
            }
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border))
            .phaseAnimator([1.0, 1.015, 1.0], trigger: items.map(\.value)) { content, scale in
                content.scaleEffect(reduceMotion ? 1 : scale)
            } animation: { _ in
                .easeInOut(duration: 0.16)
            }
        }
    }
}

private struct MeasurementRow: View {
    let item: Measurement
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                label
                Spacer(minLength: 12)
                reading
            }
            VStack(alignment: .leading, spacing: 8) { label; reading }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
    private var label: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.label).font(.subheadline)
            if let detail = item.detail { Text(detail).font(.caption2).foregroundStyle(Theme.muted) }
        }
    }
    private var reading: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(item.value, format: .number.precision(.fractionLength(0...3)))
                .font(.system(.body, design: .rounded).weight(.semibold)).monospacedDigit()
                .contentTransition(.numericText(value: item.value))
                .animation(.snappy(duration: 0.25), value: item.value)
            Text(item.unit).font(.caption).foregroundStyle(Theme.muted)
        }.fixedSize()
    }
}

// MARK: - Veri modelleri

private struct CompareSpec: Identifiable {
    let id: String
    let label: String
    let unit: String
    let index: Int
    var divisor: Double = 1
}

private struct CompareGroup: Identifiable {
    var id: String { title }
    let title: String
    let symbol: String
    let specs: [CompareSpec]
}

private struct CompareItem: Identifiable {
    let id: String
    let label: String
    let unit: String
    let a: Double
    let b: Double

    var delta: Double { b - a }
    var percent: Double? { abs(a) > 1e-9 ? (b - a) / a * 100 : nil }
}

// MARK: - Genel karşılaştırma ekranı




private struct LoadCompareView: View {
    let title: String
    let subtitle: String
    let description: String
    let range: ClosedRange<Int>
    let rows: (Int) -> [Double]
    let groups: [CompareGroup]

    @State private var loadA: Int
    @State private var loadB: Int

    init(title: String, subtitle: String, description: String,
         range: ClosedRange<Int>, initialA: Int, initialB: Int,
         rows: @escaping (Int) -> [Double], groups: [CompareGroup]) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.range = range
        self.rows = rows
        self.groups = groups
        _loadA = State(initialValue: initialA)
        _loadB = State(initialValue: initialB)
    }

    private func items(for group: CompareGroup) -> [CompareItem] {
        let rowA = rows(loadA)
        let rowB = rows(loadB)
        return group.specs.map { s in
            CompareItem(id: s.id, label: s.label, unit: s.unit,
                        a: rowA[s.index] / s.divisor,
                        b: rowB[s.index] / s.divisor)
        }
    }

    private var snapshot: CompareSnapshot {
        CompareSnapshot(
            title: title, loadA: loadA, loadB: loadB, date: .now,
            blocks: groups.map { .init(title: $0.title, items: items(for: $0)) }
        )
    }

    var body: some View {
        Dashboard(title: title, subtitle: subtitle, description: description) {
            CompareLoadPicker(title: "Load A", range: range, value: $loadA)

            Button {
                let t = loadA
                loadA = loadB
                loadB = t
            } label: {
                Label("Swap A and B", systemImage: "arrow.up.arrow.down")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .tint(Theme.accent)

            CompareLoadPicker(title: "Load B", range: range, value: $loadB)

            ForEach(groups) { group in
                CompareSection(title: group.title, symbol: group.symbol,
                               loadA: loadA, loadB: loadB,
                               items: items(for: group))
            }

            CompareExportBar(snapshot: snapshot)
        }
    }
}










// MARK: - Yük seçici (kompakt)

private struct CompareLoadPicker: View {
    let title: String
    let range: ClosedRange<Int>
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.headline)
                Spacer()
                Text("%\(value)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(value)))
                    .animation(.snappy(duration: 0.25), value: value)
                Stepper("", value: $value, in: range)
                    .labelsHidden()
            }
            Slider(
                value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }),
                in: Double(range.lowerBound)...Double(range.upperBound)
            ) { Text(title) }
            .tint(Theme.accent)
        }
        .padding(16)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border))
    }
}

// MARK: - Karşılaştırma bölümü ve satırı

private struct CompareSection: View {
    let title: String
    let symbol: String
    let loadA: Int
    let loadB: Int
    let items: [CompareItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol).font(.headline)

            HStack {
                Text("A: %\(loadA)")
                Image(systemName: "arrow.right").font(.caption2)
                Text("B: %\(loadB)")
                Spacer()
                Text("Change").font(.caption)
            }
            .font(.caption.weight(.semibold).monospacedDigit())
            .foregroundStyle(Theme.muted)
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    CompareRow(item: item)
                    if item.id != items.last?.id {
                        Divider().overlay(Theme.border).padding(.horizontal, 16)
                    }
                }
            }
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border))
        }
    }
}

private struct CompareRow: View {
    let item: CompareItem

    private var changed: Bool { abs(item.delta) > 1e-9 }

    private var symbol: String {
        if !changed { return "equal" }
        return item.delta > 0 ? "arrow.up.right" : "arrow.down.right"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.label).font(.subheadline)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(item.a, format: .number.precision(.fractionLength(0...3)))
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                Image(systemName: "arrow.right")
                    .font(.caption2).foregroundStyle(Theme.muted)
                Text(item.b, format: .number.precision(.fractionLength(0...3)))
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                Text(item.unit).font(.caption).foregroundStyle(Theme.muted)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: symbol).font(.caption2.weight(.bold))
                        if let p = item.percent {
                            Text("\(p, format: .number.precision(.fractionLength(1)).sign(strategy: .always(includingZero: false)))%")
                        } else {
                            Text("—")
                        }
                    }
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(changed ? Theme.accent : Theme.muted)

                    Text("\(item.delta, format: .number.precision(.fractionLength(0...3)).sign(strategy: .always(includingZero: false))) \(item.unit)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(Theme.muted)
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Kazan karşılaştırma

private struct BoilerCompareView: View {
    var body: some View {
        LoadCompareView(
            title: "Compare",
            subtitle: "Load Comparison",
            description: "Boiler Load A vs Load B",
            range: 40...100,
            initialA: 70,
            initialB: 92,
            rows: { ReferenceData.boiler[$0] },
            groups: [
                CompareGroup(title: "Parameters", symbol: "gauge.with.dots.needle.50percent", specs: [
                    .init(id: "steam", label: "Steam Flow", unit: "t/h", index: 13),
                    .init(id: "coal", label: "Coal Consumption", unit: "t/h", index: 4),
                    .init(id: "oxygen", label: "Oxygen Level · II. Pass", unit: "%", index: 3),
                    .init(id: "total", label: "Total Air", unit: "kg/sn", index: 5),
                    .init(id: "primary", label: "Primary Air Flow", unit: "kg/sn", index: 8),
                    .init(id: "upper", label: "Secondary Air Upper Air Flow", unit: "kg/sn", index: 1),
                    .init(id: "lower", label: "Secondary Air Lower Air Flow", unit: "kg/sn", index: 2),
                    .init(id: "burner", label: "Secondary Air Burner Air Flow", unit: "kg/sn", index: 9),
                    .init(id: "chute", label: "Coal Chutes Air Flow (each)", unit: "kg/sn", index: 6, divisor: 4),
                    .init(id: "rising", label: "LoopSeal Rising Zone Air Flow", unit: "kg/sn", index: 10),
                    .init(id: "downcomer", label: "LoopSeal Downcommer Zone Air Flow", unit: "kg/sn", index: 11),
                    .init(id: "recirculation", label: "Re-Circulation Air Flow", unit: "kg/sn", index: 12),
                    .init(id: "pressure", label: "Secondary Air Header Pressure", unit: "mbar", index: 7)
                ])
            ]
        )
    }
}

// MARK: - Burner karşılaştırma

private struct BurnerCompareView: View {
    var body: some View {
        LoadCompareView(
            title: "Burner Compare",
            subtitle: "Load Comparison",
            description: "Burner Load A vs Load B",
            range: 0...100,
            initialA: 50,
            initialB: 100,
            rows: { ReferenceData.burner[$0] },
            groups: [
                CompareGroup(title: "Front Wall Burners", symbol: "flame", specs: [
                    .init(id: "front-air", label: "Air Flow", unit: "kg/sn", index: 1),
                    .init(id: "front-gas", label: "Natural Gas Flow", unit: "kg/sn", index: 2)
                ]),
                CompareGroup(title: "Left & Right Walls Burners", symbol: "flame", specs: [
                    .init(id: "side-air", label: "Air Flow", unit: "kg/sn", index: 3),
                    .init(id: "side-gas", label: "Natural Gas Flow", unit: "kg/sn", index: 4)
                ])
            ]
        )
    }
}



// MARK: - Dışa aktarma verisi

private struct CompareSnapshot: Sendable {
    struct Block: Identifiable, Sendable {
        var id: String { title }
        let title: String
        let items: [CompareItem]
    }

    let title: String
    let loadA: Int
    let loadB: Int
    let date: Date
    let blocks: [Block]

    func fileName(ext: String) -> String {
        let base = "CFB-X_\(title)_A\(loadA)-B\(loadB)"
            .replacingOccurrences(of: " ", with: "_")
        return "\(base).\(ext)"
    }

    func fileURL(ext: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName(ext: ext))
    }

    // CSV
    func csv() -> String {
        let nf = NumberFormatter()
        nf.locale = .current
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = false
        nf.maximumFractionDigits = 4

        // Virgüllü ondalık kullanan dillerde (TR gibi) Excel ayraç olarak ";" bekler
        let sep = (nf.decimalSeparator == ",") ? ";" : ","

        func num(_ v: Double) -> String {
            nf.string(from: NSNumber(value: v)) ?? ""
        }
        func field(_ s: String) -> String {
            guard s.contains(sep) || s.contains("\"") || s.contains("\n") else { return s }
            return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }

        var lines: [String] = [
            ["Group", "Parameter", "Unit",
             "Load A (\(loadA)%)", "Load B (\(loadB)%)",
             "Difference", "Change (%)"]
                .map(field).joined(separator: sep)
        ]

        for block in blocks {
            for item in block.items {
                let cols = [
                    block.title, item.label, item.unit,
                    num(item.a), num(item.b), num(item.delta),
                    item.percent.map(num) ?? ""
                ]
                lines.append(cols.map(field).joined(separator: sep))
            }
        }
        return "\u{FEFF}" + lines.joined(separator: "\n")   // BOM: Excel'de Türkçe karakterler için
    }

    // PDF (ImageRenderer ana thread'de çalışmalı)
    @MainActor
    func writePDF(to url: URL) throws {
        let renderer = ImageRenderer(content: CompareReportView(snapshot: self))
        renderer.proposedSize = .init(width: 595, height: nil)   // A4 genişliği (pt)

        var written = false
        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            ctx.beginPDFPage(nil)
            draw(ctx)
            ctx.endPDFPage()
            ctx.closePDF()
            written = true
        }
        if !written { throw CocoaError(.fileWriteUnknown) }
    }
}

// MARK: - ShareLink için Transferable tipleri

private struct CompareCSVExport: Transferable {
    let snapshot: CompareSnapshot

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
            let url = export.snapshot.fileURL(ext: "csv")
            try export.snapshot.csv().write(to: url, atomically: true, encoding: .utf8)
            return SentTransferredFile(url)
        }
    }
}

private struct ComparePDFExport: Transferable {
    let snapshot: CompareSnapshot

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .pdf) { export in
            let url = export.snapshot.fileURL(ext: "pdf")
            try await MainActor.run {
                try export.snapshot.writePDF(to: url)
            }
            return SentTransferredFile(url)
        }
    }
}

// MARK: - PDF rapor görünümü (yazdırma için sade, açık renkli)

private struct CompareReportView: View {
    let snapshot: CompareSnapshot
    private let colWidth: CGFloat = 62

    private func plain(_ v: Double) -> String {
        v.formatted(.number.precision(.fractionLength(0...3)))
    }
    private func signed(_ v: Double) -> String {
        v.formatted(.number.precision(.fractionLength(0...3))
            .sign(strategy: .always(includingZero: false)))
    }
    private func percent(_ p: Double?) -> String {
        guard let p else { return "—" }
        return p.formatted(.number.precision(.fractionLength(1))
            .sign(strategy: .always(includingZero: false))) + "%"
    }

    private func cell(_ text: String, bold: Bool = false) -> some View {
        Text(text)
            .font(.system(size: 10, weight: bold ? .bold : .regular).monospacedDigit())
            .frame(width: colWidth, alignment: .trailing)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CFB-X · \(snapshot.title)")
                    .font(.system(size: 20, weight: .bold))
                Text("Load A: \(snapshot.loadA)%   →   Load B: \(snapshot.loadB)%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                Text(snapshot.date, format: .dateTime.day().month().year().hour().minute())
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
            }

            ForEach(snapshot.blocks) { block in
                VStack(alignment: .leading, spacing: 0) {
                    Text(block.title)
                        .font(.system(size: 13, weight: .bold))
                        .padding(.bottom, 6)

                    HStack(spacing: 6) {
                        Text("Parameter").frame(maxWidth: .infinity, alignment: .leading)
                        cell("A (\(snapshot.loadA)%)", bold: true)
                        cell("B (\(snapshot.loadB)%)", bold: true)
                        cell("Diff", bold: true)
                        cell("Change", bold: true)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(Color.gray.opacity(0.18))

                    ForEach(Array(block.items.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 6) {
                            Text("\(item.label) (\(item.unit))")
                                .font(.system(size: 10))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            cell(plain(item.a))
                            cell(plain(item.b))
                            cell(signed(item.delta))
                            cell(percent(item.percent), bold: true)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 6)
                        .background(index.isMultiple(of: 2) ? Color.clear : Color.gray.opacity(0.07))
                    }
                }
            }

            Text("Reference values, not live measurements.")
                .font(.system(size: 9))
                .foregroundStyle(.gray)
        }
        .padding(32)
        .frame(width: 595, alignment: .leading)
        .background(Color.white)
        .foregroundStyle(Color.black)
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Paylaşım butonları

private struct CompareExportBar: View {
    let snapshot: CompareSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Export", systemImage: "square.and.arrow.up").font(.headline)

            HStack(spacing: 12) {
                ShareLink(
                    item: ComparePDFExport(snapshot: snapshot),
                    preview: SharePreview(snapshot.fileName(ext: "pdf"),
                                          image: Image(systemName: "doc.richtext"))
                ) {
                    Label("PDF", systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity)
                }

                ShareLink(
                    item: CompareCSVExport(snapshot: snapshot),
                    preview: SharePreview(snapshot.fileName(ext: "csv"),
                                          image: Image(systemName: "tablecells"))
                ) {
                    Label("CSV", systemImage: "tablecells")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(Theme.accent)
        }
    }
}









#Preview { ContentView() }

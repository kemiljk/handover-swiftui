//
//  PxToTw.swift
//  Handover (iOS)
//
//  Created by Karl Koch on 15/06/2021.
//

import SwiftUI
import WidgetKit

struct PxToTw: View {
    @ObservedObject var pxResults: PXResults
    @ObservedObject var emResults: EMResults
    @ObservedObject var lhResults: LHResults
    @ObservedObject var twResults: TWResults
    var device = UIDevice.current.userInterfaceIdiom
    
    var body: some View {
        if device == .phone {
            NavigationView {
                PxToTwView(pxResults: self.pxResults, emResults: self.emResults, lhResults: self.lhResults, twResults: self.twResults)
            }
        } else {
            PxToTwView(pxResults: self.pxResults, emResults: self.emResults, lhResults: self.lhResults, twResults: self.twResults)
        }
    }
}

struct PxToTwView: View {
    @AppStorage("result", store: UserDefaults(suiteName: "group.com.kejk.handover")) var resultData: Data = Data()
    @AppStorage("scaleResult", store: UserDefaults(suiteName: "group.com.kejk.handover")) var scaleResultData: String = ""
    @AppStorage("baselineResult", store: UserDefaults(suiteName: "group.com.kejk.handover")) var baselineResultData: String = "16px"
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    @State var show_toast: Bool = false
    
    @State private var baseTextEmpty = ""
    @State private var pixelTextEmpty = ""
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var pxResults: PXResults
    @ObservedObject var emResults: EMResults
    @ObservedObject var lhResults: LHResults
    @ObservedObject var twResults: TWResults
    
    @State private var show_settings_modal: Bool = false
    @State private var show_saves_modal: Bool = false
    
    func pxToTws(baseInt: Double, pixelInt: Double) -> Double {
        let twValue = (pixelInt / baseInt) * 4
        return twValue
    }
    
    func save(scaleResult: String, baselineResult: String, calcResult: String) {
        guard let calculation = try? JSONEncoder().encode(calcResult) else { return }
        self.resultData = calculation
        self.scaleResultData = scaleResult
        self.baselineResultData = baselineResult
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    let modal = UIImpactFeedbackGenerator(style: .medium)
    let menu = UIImpactFeedbackGenerator(style: .soft)
    let menuParent = UIImpactFeedbackGenerator(style: .light)
    let save = UINotificationFeedbackGenerator()
    var device = UIDevice.current.userInterfaceIdiom
    @State private var hovering = false
    
    var body: some View {
        if device == .phone {
        content
        .popup(isPresented: $show_toast, type: .floater(verticalPadding: 40), position: .top, autohideIn: 2) {
            HStack {
                Image(systemName: "checkmark").padding(.trailing, 4)
                    .font(.system(size: 20, weight: .semibold))
                Text("Saved").bold()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(Color("lightGrey"))
            .clipShape(Capsule())
        .navigationBarTitle("Px››Tw")
        .navigationBarItems(
            leading:
                    Button(action: {
                        self.show_saves_modal = true
                        self.modal.impactOccurred()
                    }) {
                        Image(systemName: "bookmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("teal"))
                    }
                    .sheet(isPresented: self.$show_saves_modal) {
                        SavesModalView(pxResults: self.pxResults, emResults: self.emResults, lhResults: self.lhResults, twResults: self.twResults)
                    },
            trailing:
                    Button(action: {
                        self.show_settings_modal = true
                        self.modal.impactOccurred()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("teal"))
                    }
                    .sheet(isPresented: self.$show_settings_modal) {
                        SettingsModalView()
                    }
            )
        }
    } else  {
    content
    .popup(isPresented: $show_toast, type: .floater(verticalPadding: 40), position: .top, autohideIn: 2) {
        HStack {
            Image(systemName: "checkmark").padding(.trailing, 4)
                .font(.system(size: 20, weight: .semibold))
            Text("Saved").bold()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 32)
        .background(Color("lightGrey"))
        .clipShape(Capsule())
    }
    .navigationBarTitle("Px››Tw")
    .navigationBarItems(
        trailing:
            HStack (spacing: 16) {
                Button(action: {
                    self.show_saves_modal = true
                }) {
                    Image(systemName: "bookmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("teal"))
                }
                .padding(8)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .hoverEffect(.highlight)
                .sheet(isPresented: self.$show_saves_modal) {
                    SavesModalView(pxResults: self.pxResults, emResults: self.emResults, lhResults: self.lhResults, twResults: self.twResults)
                }
                Button(action: {
                    self.show_settings_modal = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("teal"))
                }
                .padding(8)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .hoverEffect(.highlight)
                .sheet(isPresented: self.$show_settings_modal) {
                    SettingsModalView()
                }
            }
        )
    }
}
    
    var content: some View {
        VStack {
            VStack (alignment: .center, content: {
                Spacer()
                Text("\(Int(pixelTextEmpty) ?? 16)px is {class}-\(String(format: "%.0f", pxToTws(baseInt: Double(baseTextEmpty) ?? 16, pixelInt: Double(pixelTextEmpty) ?? 16)))")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                Spacer()
            })
            VStack (alignment: .leading) {
                Text("Baseline pixel value").font(.headline)
                TextField("16", text: $baseTextEmpty).modifier(ClearButton(text: $baseTextEmpty))
                    .font(.system(device == .mac ? .body : .title, design: .monospaced))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(RoundedRectangle(cornerRadius: device == .mac ? 6 : 8).stroke(Color("orange"), lineWidth: device == .mac ? 2.5 : 3))
                    .keyboardType(.decimalPad)
            }.padding(20)
            VStack (alignment: .leading) {
                HStack {
                    VStack (alignment: .leading) {
                        Text("Pixels").font(.headline)
                        TextField("16", text: $pixelTextEmpty).modifier(ClearButton(text: $pixelTextEmpty))
                            .font(.system(device == .mac ? .body : .title, design: .monospaced))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(RoundedRectangle(cornerRadius: device == .mac ? 6 : 8).stroke(Color("teal"), lineWidth: device == .mac ? 2.5 : 3))
                            .keyboardType(.decimalPad)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                }
            }
            VStack (alignment: .center) {
                VStack {
                    Button(action: {
                        save(scaleResult: "", baselineResult: "\(Int(baseTextEmpty) ?? 16)", calcResult: "\(Int(pixelTextEmpty) ?? 16)px is {class}-\(String(format: "%.0f", pxToTws(baseInt: Double(baseTextEmpty) ?? 16, pixelInt: Double(pixelTextEmpty) ?? 16)))")
                        let item = ResultItem(pxResult: "", emResult: "", lhResult: "", twResult: "\(Int(pixelTextEmpty) ?? 16)px is {class}-\(String(format: "%.0f", pxToTws(baseInt: Double(baseTextEmpty) ?? 16, pixelInt: Double(pixelTextEmpty) ?? 16))) with a baseline of \(Int(baseTextEmpty) ?? 16)px")
                        self.twResults.items.insert(item, at: 0)
                        self.hideKeyboard()
                        print(item)
                        if device == .phone {
                            save.notificationOccurred(.success)
                        }
                        self.show_toast = true
                        resetDefaults()
                    }, label: {
                        Text("Save result")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    })
                    .padding(.vertical, 16)
                    .padding(.horizontal, 48)
                    .background(Color("teal"))
                    .clipShape(Capsule())
                    .contentShape(Capsule(style: .continuous))
                    .hoverEffect(.highlight)
                }
                if device == .mac {
                    VStack {
                        Button(action: {
                            save(scaleResult: "", baselineResult: "\(Int(baseTextEmpty) ?? 16)", calcResult: "\(Int(pixelTextEmpty) ?? 16)px is {class}-\(String(format: "%.0f", pxToTws(baseInt: Double(baseTextEmpty) ?? 16, pixelInt: Double(pixelTextEmpty) ?? 16)))")
                            let item = ResultItem(pxResult: "", emResult: "", lhResult: "", twResult: "\(Int(pixelTextEmpty) ?? 16)px is {class}-\(String(format: "%.0f", pxToTws(baseInt: Double(baseTextEmpty) ?? 16, pixelInt: Double(pixelTextEmpty) ?? 16))) with a baseline of \(Int(baseTextEmpty) ?? 16)px")
                            self.twResults.items.insert(item, at: 0)
                            print(item)
                            self.show_toast = true
                            resetDefaults()
                        }) {
                            Text("Save result")
                                .frame(maxWidth: 100, maxHeight: 24)
                        }
                        .buttonStyle(MacButtonStyle())
                    }
                }
            }
            .padding().padding(.vertical, 24)
        }
    }
}

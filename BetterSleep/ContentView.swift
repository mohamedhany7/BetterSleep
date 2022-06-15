//
//  ContentView.swift
//  BetterSleep
//
//  Created by Mohamed Hany on 15/06/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var selectedCoffeeAmount = 1
    private var coffeeAmount = Array(1...10)
    
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    Section{
                        DatePicker("Will wake up at:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            //.labelsHidden()
                            .font(.headline)
                    }
                    
                    Section{
                        Text("Desired amount of sleeping hours")
                            .font(.headline)

                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    Section{
                        Picker("Daily coffee intake", selection: $selectedCoffeeAmount) {
                            ForEach(coffeeAmount, id: \.self) { amount in
                                Text(String(amount))
                            }
                        }
                    }
                    
                    Section{
                        Text("Your ideal bedtime is…")
                            .font(.headline)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        Text(alertMessage)
                            .font(.title.bold())
                            .foregroundColor(.blue)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(selectedCoffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

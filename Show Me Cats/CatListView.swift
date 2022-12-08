//
//  CatListView.swift
//  Show Me Cats
//
//  Created by Jason Stelzel on 12/5/22.
//

import SwiftUI

//    let userDefaults = UserDefaults.standard
//    userDefaults.setValue("MyValue", forKey: "MyKey")
 



struct CatListView: View {

//    init(@ViewBuilder content: () -> CatListView, onDismiss: (() -> Void)?) {
//        content()
//            .onDisappear(perform: saveUserDefaults())
//        }
//
//    func saveUserDefaults() {
//        let userDefaults = UserDefaults.standard
//        userDefaults.setValue(bufferSize, forKey: "bufferSize")
//        return
//    }

    @State private var images: [UIImage] = []
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State private var timeToWait: Timer?
    @State private var showingIndex = false
    @State private var getCatsTimer: Timer?
    @State private var tooManyCatCalls = false

    private var client = URLSessionHTTPClient()
    let url = URL(string:"https://cataas.com/cat")!

    @State private var bufferSize = 0.0
    private var bufferSizeDefault = 20.0
    @State private var bufferCount = 0
    @State private var durationFade: TimeInterval = 0.0
    private var durationFadeDefault = 2.0
    @State private var durationWait: TimeInterval = 0.0
    private var durationWaitDefault = 2.8
    @State private var controlsAreVisible = false

    
        

    var body: some View {
        if (self.bufferCount < 1) {
            ProgressView()
                .onAppear{
                    getCats()
                    loadUserDefaults()
                }
            
        } else {
            ZStack {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: self.images[index])
                        .resizable()
                        .opacity(index == self.currentIndex ? 1 : 0)
                        .animation(.easeInOut(duration: self.durationFade), value: index == self.currentIndex)
                }
                if (controlsAreVisible){
                    VStack {
                        showSizeSlider()
                        fadeSlider()
                        waitSlider()
                        slideNumber()
                    }
                    .background(Color(CGColor(srgbRed: 0.35, green: 0.35, blue: 0.5, alpha: 0.5)))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .padding(.horizontal,20)
                }
            }
            .onAppear {
                self.waitTimer()
            }
            .onDisappear {
                print ("Saving userDefaults...")
                saveUserDefaults()
            }
            .onTapGesture(count: 1, perform: toggleControls)
        }
    }
    
    
    private func toggleControls() {
        controlsAreVisible.toggle()
    }
    
    
    func showSizeSlider() -> some View {
        HStack {
            Text("Image Count = " + String(Int(bufferSize)))
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
            Slider(value: $bufferSize, in: 1...300, step: 1.0)
                .onChange(of: bufferSize) { _ in
                    getCats()
                }
        }
        .padding(.top,10)
        .padding(.horizontal,20)
        .padding(.bottom,0)
    }
    
    
    func fadeSlider() -> some View {
        HStack {
            Text("Fade Time " + String(format: "%.1f", durationFade))
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
            Slider(value: $durationFade, in: 0...8, step: 0.1)
        }
        .padding(.vertical,0)
        .padding(.horizontal,20)
    }
    
    
    func waitSlider() -> some View {
        HStack {
            Text("Wait Time " + String(format: "%.1f", durationWait))
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
            Slider(value: $durationWait, in: 0...8, step: 0.1)
        }
        .padding(.vertical,0)
        .padding(.horizontal,20)
    }
    
    
    func slideNumber() -> some View {
        HStack {
            Text("Slide Number")
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
            Spacer()
            Text(String(currentIndex))
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
        }
        .padding(.top,5)
        .padding(.horizontal,20)
        .padding(.bottom,10)
    }
    
    
    private func waitTimer() {
        timeToWait = Timer.scheduledTimer(withTimeInterval: durationWait, repeats: false) { _ in
            startTimer()
        }
    }
    
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: durationFade, repeats: false) { _ in
            self.currentIndex = (self.currentIndex + 1) % self.images.count
            print ("image count = \(images.count)")
            waitTimer()
        }
    }
    
    
    func saveUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(bufferSize, forKey: "bufferSize")
        userDefaults.setValue(durationFade, forKey: "durationFade")
        userDefaults.setValue(durationWait, forKey: "durationWait")
        return
    }
    
    
    func loadUserDefaults() {
        let userDefaults = UserDefaults.standard
        bufferSize = userDefaults.double(forKey: "bufferSize")
        print ("Buffer Size recovered = \(bufferSize)")
        if bufferSize == 0.0 {
            bufferSize = bufferSizeDefault
        }

        durationFade = userDefaults.double(forKey: "durationFade")
        print ("durationFade recovered = \(durationFade)")
        if durationFade == 0.0 {
            durationFade = durationFadeDefault
        }

        durationWait = userDefaults.double(forKey: "durationWait")
        print ("durationWait Size recovered = \(durationWait)")
        if durationWait == 0.0 {
            durationWait = durationWaitDefault
        }

    }


    func downloadImageData(url: URL) {
        client.get(from: url, completion: { result in
                switch result {
                case let .success(data, _):
                    print ("success, add some cat data")
                    self.addCatImage(data: data)
                case let .failure(error):
                    print ("An error occurred, \(error)")
                    if (bufferCount < Int(bufferSize)) {downloadImageData(url: url)}
                }
            })
    }
    
    
    func addCatImage(data: Data) {
        self.bufferCount += 1
        let image = UIImage(data: data)
        self.images.append(image!)
        print ("Buffer Count =\(bufferCount)")
        if (bufferCount < Int(bufferSize)) {downloadImageData(url: url)}
    }
    
    
    func getCats() {
            print ("Get Cats")
        if bufferSize == 0 { bufferSize = bufferSizeDefault }
        if !tooManyCatCalls {
            self.tooManyCatCalls = true
            downloadImageData(url: url)
            getCatsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.tooManyCatCalls = false
            }
        }

    }
    
}

    struct CatListView_Previews: PreviewProvider {
        static var previews: some View {
            CatListView()
        }
    }


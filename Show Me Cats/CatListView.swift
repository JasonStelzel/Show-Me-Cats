//
//  CatListView.swift
//  Show Me Cats
//
//  Created by Jason Stelzel on 12/5/22.
//

import SwiftUI

struct CatListView: View {

    @State private var images: [UIImage] = []
    @State private var currentIndex = 0
    @State private var fadeTimer: Timer?
    @State private var waitTimer: Timer?
    @State private var showingIndex = false
    @State private var getCatsTimer: Timer?

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
    @State private var internetConnectivity = true


    var body: some View {
        if (self.bufferCount < 1) {
            VStack {
                    if (internetConnectivity){
                        ProgressView()
                    } else {
                        Text("Internet Connectivity Issue")
                    }
                }
                .onAppear{
                    loadUserDefaults()
                    getCats()
                }
            
        } else {
            ZStack {
                slideShow()
                if (controlsAreVisible){
                    controlPanel()
                }
            }
            .onAppear {
                self.waitTime()
            }
            .onDisappear {
                print ("Saving userDefaults...")
                saveUserDefaults()
                memoryCleanup()
            }
            .onTapGesture(count: 1, perform: toggleControls)
        }
    }
    
    
    func slideShow () -> some View {
        ForEach(0..<images.count, id: \.self) { index in
            Image(uiImage: self.images[index])
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .opacity(index == self.currentIndex ? 1 : 0)
                .animation(.easeInOut(duration: self.durationFade), value: index == self.currentIndex)
        }
    }
    
    
    // todo: refactor control panel into separate file
    private func toggleControls() {
        controlsAreVisible.toggle()
    }
    
    
    func controlPanel() -> some View {
        VStack {
            showSizeSlider()
            fadeSlider()
            waitSlider()
            imageNumber()
        }
        .background(Color(CGColor(srgbRed: 0.35, green: 0.35, blue: 0.5, alpha: 0.5)))
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .padding(.horizontal,20)
    }
    
    
    func showSizeSlider() -> some View {
        HStack {
            Text("Total Images " + String(Int(bufferSize)))
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
            Slider(value: $bufferSize, in: 1...300, step: 1.0){ editing in
                if !editing {
                    getCats()
                }
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
    
    
    func imageNumber() -> some View {
        HStack {
            Text("Image Number")
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
            Text(String(currentIndex))
                .foregroundColor(Color(cgColor: CGColor(gray: 1.0, alpha: 1.0)))
        }
        .padding(.top,0)
        .padding(.horizontal,20)
        .padding(.bottom,10)
    }
    
    
    private func waitTime() {
        waitTimer = Timer.scheduledTimer(withTimeInterval: durationWait, repeats: false) { _ in
            fadeTime()
        }
    }
    
    
    private func fadeTime() {
        fadeTimer = Timer.scheduledTimer(withTimeInterval: durationFade, repeats: false) { _ in
            self.currentIndex = (self.currentIndex + 1) % self.images.count
            waitTime()
        }
    }
    
    
    // todo: address non-View related code
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
    
    
    func memoryCleanup() {
        images = []
        bufferCount = 0
        fadeTimer?.invalidate()
        waitTimer?.invalidate()
        getCatsTimer?.invalidate()
    }


    // todo: move networking code out of View
    func downloadImageData(url: URL) {
        client.get(from: url, completion: { result in
                switch result {
                case let .success(data, _):
                    internetConnectivity = true
                    print ("success, add some cat data")
                    self.addCatImage(data: data)
                case let .failure(error):
                    internetConnectivity = false
                    print ("An error occurred, \(error)")
                    if (bufferCount < Int(bufferSize)) {downloadImageData(url: url)}
                }
            })
    }
    
    
    func addCatImage(data: Data) {
        if (images.count < Int(bufferSize)) {
            if let image = UIImage(data: data) {
                self.bufferCount += 1
                print ("Buffer Count =\(bufferCount)")
                self.images.append(image)
                if (bufferCount < Int(bufferSize)) { downloadImageData(url: url) }
            }

        }
        print ("image count after add = \(images.count)")
    }
    
    
    func getCats() {
        print ("Get Cats")
        if bufferSize == 0 { bufferSize = bufferSizeDefault }
        downloadImageData(url: url)
    }

    
}




struct CatListView_Previews: PreviewProvider {
    static var previews: some View {
        CatListView()
    }
}


//
//  LabelButtonWeather.swift
//  WeatherApp-SwiftUI
//
//  Created by Akbar Eka Putra on 24/04/24.
//

import SwiftUI

struct LabelButtonWeather: View {
    var title: String
    var bgColor: Color
    var textColor: Color
    
    var body: some View {
        Text(title)
            .frame(width: 280, height: 50)
            .background(bgColor)
            .foregroundColor(textColor)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(10)
    }
}

////cara 1
//struct LabelButtonWeather_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelButtonWeather(title: "test", bgColor: .blue, textColor: .white)
//    }
//}

//cara 2
#Preview {
    LabelButtonWeather(title: "test", bgColor: .blue, textColor: .white)
}

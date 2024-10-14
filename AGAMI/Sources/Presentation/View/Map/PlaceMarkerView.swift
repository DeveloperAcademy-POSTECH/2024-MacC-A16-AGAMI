//
//  PlaceMarkerView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI

struct PlaceMarkerView: View {
    @State private var imagCnt = 3
    
    var body: some View {
        BubbleView()
            .overlay {
                if imagCnt > 1 {
                    ZStack {
                        Circle()
                            .frame(width: 30, height: 30)
                        
                        Text(String(imagCnt))
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .offset(x: 30, y: -35)
                }
            }
    }
}

struct BubbleView: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 65, height: 65)
                
                Image("bear")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Triangle()
                .frame(width: 10, height: 10)
        }
        .foregroundStyle(.white)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 삼각형의 세 점을 정의
        let topLeftPoint = CGPoint(x: rect.minX, y: rect.minY)
        let topRightPoint = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomCenterPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        // 경로를 시작점에서부터 그리기 시작
        path.move(to: topLeftPoint)
        path.addLine(to: topRightPoint)
        path.addLine(to: bottomCenterPoint)
        path.addLine(to: topLeftPoint)
        
        return path
    }
}

#Preview {
    PlaceMarkerView()
}

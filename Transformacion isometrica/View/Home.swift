//
//  Home.swift
//  Transformacion isometrica
//
//  Created by Victor Tejeda on 16/10/22.
//

import SwiftUI

struct Home: View {
    @State var animate: Bool = false
    //MARK: Propiedades de la aniamcion
    @State var b: CGFloat = 0
    @State var c: CGFloat = 0
    var body: some View {
        VStack(spacing: 20){
            //  MARK: Declara mi propia vista.
            IsometricView(depth: animate ? 35: 0) {
                ImageView()
            } bottom: {
                ImageView()
            } side: {
                ImageView()
            }
            .frame(width: 180, height: 330)
            //MARK: Animaciones con estas proyeciones
            // la Proyeccion de animacion necesita datos animados
            .modifier(CustomProjection(b: b, c: c))
            .rotation3DEffect(.init(degrees:animate ? 45 : 0), axis: (x: 0, y: 0, z: 1))
            .scaleEffect(0.75)
            .offset(x: animate ? 12 : 0)//posicion de mi imagen aqui se arreglo
            
            VStack(alignment: .leading, spacing: 25) {
                Text("Transformacion Isometrica")
                    .font(.title.bold())
                
                HStack {
                    Button("Animacion") {
                        withAnimation(.easeOut(duration: 2.5)) {
                            animate = true
                            b = -0.2
                            c = -0.3
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
             
                    Button("Resert") {
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.5)) {
                            animate = false
                            b = 0
                            c = 0
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal,15)
            .padding(.top,25)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
        @ViewBuilder
    func ImageView()->some View {
        Image("Big")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 180, height: 330)
            .clipped()
    }
}

struct CustomProjection: GeometryEffect {
    
        var b: CGFloat
        var c: CGFloat
        
        var AnimatableData: AnimatablePair<CGFloat,CGFloat> {
            get {
                return AnimatablePair(b, c)
            }
            set {
                b = newValue.first
                c = newValue.second
            }
        }
    func effectValue(size: CGSize) -> ProjectionTransform {
        return .init(.init(a: 1, b: b, c: c, d: 1, tx: 0, ty: 0))
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

//MARK: custom View
struct IsometricView<Content: View,Bottom: View,Side: View>: View {
    var content: Content
    var bottom: Bottom
    var side: Side
    
    // MARK: Transformacion de profundidad
    var depth: CGFloat
    
    init(depth: CGFloat, @ViewBuilder content: @escaping()->Content,@ViewBuilder bottom: @escaping()->Bottom,@ViewBuilder side: @escaping()->Side) {
        self.depth = depth
        self.content = content()
        self.bottom = bottom()
        self.side = side()
    }
    
    var body: some View {
            Color.clear
            // Para que la geometría ocupe el espacio especificado
                .overlay {
                    GeometryReader {
                        let size = $0.size
                        
                        ZStack{
                            content
                            DepthView(isBottom: true,size: size)
                            DepthView(size: size)
                        }
                        .frame(width: size.width, height: size.height)
                    }
                }
    }
    // MARK: Profundidad de Vistas
    @ViewBuilder
    func DepthView(isBottom: Bool = false,size: CGSize)->some View {
        ZStack {
            //MARK: si no deseo la imagen original pero necesito un estiramiento en el costado y en la parte inferior, uso este método
            if isBottom {
                bottom
                    .scaleEffect(y: depth, anchor: .bottom)
                    .frame(height: depth, alignment: .bottom)
                //MARK: oscureciendo contenido con desenfoque
                    .overlay(content: {
                        Rectangle()
                            .fill(.black.opacity(0.50))
                            .blur(radius: 2.5)
                    })
                    .clipped()
                //MARK: Aplicando Transformacion
                //MARK: mi constumbre de proyeccion de valores
                    .projectionEffect(.init(.init(a: 1, b: 0, c: 1, d: 1, tx: 0, ty: 0)))
                    .offset(y: depth)
                    .frame(maxHeight: .infinity,alignment: .bottom)
            } else {
                side
                    .scaleEffect(x: depth, anchor: .trailing)
                    .frame(width: depth, alignment: .trailing)
                    .overlay(content: {
                        Rectangle()
                            .fill(.black.opacity(0.50))
                            .blur(radius: 2.5)
                    } )
                    .clipped()
                //MARK: Aplicando Transformacion
                //MARK: mi constumbre de proyeccion de valores
                    .projectionEffect(.init(.init(a: 1, b: 1, c: 0, d: 1, tx: 0, ty: 0)))
                //MARK: cambio de Offset, Transfromando Valores por tu deseo
                    .offset(x: depth)
                    .frame(maxWidth: .infinity,alignment: .trailing)
            }
        }
    }
}

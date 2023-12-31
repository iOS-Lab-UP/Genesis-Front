//
//  DoctorDashboardView.swift
//  Genesis
//
//  Created by Sara M on 22/11/23.
//

import SwiftUI

struct DoctorDashboardView: View {
    let imageData = [12, 13, 14, 15, 16] // Dummy array for demonstration
    @State private var showFullScreenImage: Int? // State variable for selected image
    @State private var currentTime = Date()
    @State private var minutos = "5"
    @ObservedObject var globalDataModel = GlobalDataModel.shared
    @State var showProfileView = false
    @State var showMedRecordView = false
    @State var navigateToNewView = false

    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        
        NavigationView{
            ZStack {
                VStack {
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)){
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color("bluey"))
                        VStack(alignment: .leading){
                            Text(currentTime, formatter: DateFormatter.timeFormatter)
                                .onReceive(timer) { input in
                                    currentTime = input
                                }
                            
                                .fontWeight(.medium)
                                .foregroundColor(Color.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.black)
                                .cornerRadius(20)
                            Spacer()
                            Text("En esta semana tienes " + minutos + " pacientes por atender")
                                .font(.title3)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.bold)
                            
                            
                            Button(action: {}, label: {
                                Text("Get started")
                                    .font(.footnote)
                                    .foregroundStyle(.black)
                                    .padding(5)
                            })
                            
                        }
                        .padding()
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 15)
                    Text(" ")
                        .font(.footnote)
                    
                    
                    HStack {
                        Text("Pacientes recientes ")
                            .bold()
                            .padding(.leading, 20)
    
                        Spacer()
                        //NavigationLink(destination: AddPatientsView()){
                          //  Text("Ver Todos")
                        //}

                        
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        // Horizontal stack for aligning items horizontally
                        HStack(spacing: 20) { // Spacing between elements in the HStack
                            // Loop through imageData
                            ForEach(imageData, id: \.self) { data in
                                Button(action: {
                                    showFullScreenImage = data
                                }) {
                                    NavigationLink(destination: NewPatientDetailsView()){
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 25.0)
                                                .fill(LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: Color("blackish"), location: 0.75),
                                                        .init(color: Color("yellowsito"), location: 0.25)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom))
                                            
                                                .frame(width: 150, height: 150)
                                            VStack {
                                                HStack {
                                                    Image("imagenPaciente")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 45, height: 45)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                                        .shadow(radius: 10)
                                                        .padding(.leading,10)
                                                    Spacer()
                                                }
                                                
                                                HStack {
                                                    Text("Sara Miranda")
                                                        .foregroundColor(.white)
                                                        .bold()
                                                        .padding(.leading,10)
                                                    Spacer()
                                                }
                                                HStack{
                                                    Text("Diagnosis")
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .padding(.leading,10)
                                                    Spacer()
                                                }
                                                Text(" ")
                                                HStack {
                                                    Image(systemName: "clock.fill")
                                                        .symbolRenderingMode(.hierarchical)
                                                        .font(.system(size: 18, weight: .light))
                                                        .foregroundColor(Color.black.opacity(0.7))
                                                    Text("\(data):00 PM")
                                                        .font(.body)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }.padding() // Padding around the HStack
                    }
                    Spacer()
                    
                    NavigationLink(destination: AgregarPacienteView()){
                        Text("Agregar Paciente")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(.white))
                            .padding()
                            .padding(.horizontal, 25)
                            .background(Color("blackish"))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    Spacer()
                    Spacer()
                }
                
            }.fullScreenCover(isPresented: $showProfileView){
                ProfileView()
                    .environmentObject(globalDataModel)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        VStack {
                            Text("Hola, Dr.")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .bold()
                        }
                        
                        Spacer()
                        
                        ZStack{
                            AsyncImage(url: URL(string: globalDataModel.userProfileImageUrl ?? "")) { image in
                                
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        navigateToNewView = true
                                        
                                    }
                            } placeholder: {
                                ZStack {
                                    Circle().foregroundColor(.purple)
                                }
                            }
                            .frame(width: 45, height: 45)
                            
                            Button(action:{showProfileView.toggle()}){
                               Circle()
                                    .foregroundStyle(Color.clear)
                                    .frame(width: 45, height: 45)
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct DoctorDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorDashboardView()
    }
}

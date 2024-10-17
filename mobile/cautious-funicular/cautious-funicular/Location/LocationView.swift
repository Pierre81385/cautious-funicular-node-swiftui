//
//  LocationView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/22/24.
//

import SwiftUI
import MapKit

struct UserMapView: View {
    @State var sender: UserData?
    @State var recipient: UserData?
    @State var locationManager: LocationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        VStack{
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .notDetermined { Text(locationManager.errorMessage ?? "Error loading map.")
            } else {
                Map(position: $position) {
                    let senderLocation = CLLocationCoordinate2D(latitude: sender?.latitude ?? 0.0, longitude: sender?.longitude ?? 0.0)
                    if(senderLocation.longitude != 0.0) {
                        Marker(coordinate: senderLocation, label: {
                            VStack{
                                Image(systemName: "person.crop.circle.fill")
                                Text(sender?.username ?? "")
                            }
                        })
                    }
                    let recipientLocation = CLLocationCoordinate2D(latitude: recipient?.latitude ?? 0.0, longitude: recipient?.longitude ?? 0.0)
                    if (recipientLocation.longitude != 0.0) {
                        Marker(coordinate: recipientLocation, label: {
                            VStack{
                                Image(systemName: "person.crop.circle.fill")
                                Text(recipient?.username ?? "")
                            }
                        })
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapScaleView()
                    MapUserLocationButton()
                    MapCompass()
                                    .mapControlVisibility(.visible)
                    MapScaleView()
                    MapPitchToggle()
            }
                
            }
        }.onAppear{
            locationManager.checkAuthorizationStatus()
        }
    }
}

#Preview {
    UserMapView()
}

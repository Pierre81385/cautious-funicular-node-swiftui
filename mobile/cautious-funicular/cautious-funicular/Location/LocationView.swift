//
//  LocationView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/22/24.
//

import SwiftUI
import MapKit

struct UserMapView: View {
    @State var locationManager: LocationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        VStack{
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .notDetermined { Text(locationManager.errorMessage ?? "Error loading map.")
            } else {
                Map(position: $position) {
                           //Marker("Garage", coordinate: garage)
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

import Foundation
import Combine
import os.log

class RemoteDataSource {
  static let endpoint = URL(string: "https://ssd-api.jpl.nasa.gov/fireball.api" )

  private var subscriptions: Set<AnyCancellable> = []
  private func dataTaskPublisher(for url: URL) -> AnyPublisher<Data, URLError> {
    URLSession.shared.dataTaskPublisher(for: url)
      .compactMap { data, response -> Data? in
        guard let httpResponse = response as? HTTPURLResponse else {
          os_log(.error, log: OSLog.default, "Data download had no http response")
          return nil
        }
        guard httpResponse.statusCode == 200 else {
          os_log(.error, log: OSLog.default, "Data download returned http status: %d", httpResponse.statusCode)
          return nil
        }
        return data
      }
      .eraseToAnyPublisher()
  }

  var fireballDataPublisher: AnyPublisher<[FireballData], URLError> {
    guard let endpoint = RemoteDataSource.endpoint else {
      return Fail(error: URLError(URLError.badURL)).eraseToAnyPublisher()
    }

    return dataTaskPublisher(for: endpoint)
      .decode(type: FireballsAPIData.self, decoder: JSONDecoder())
      .mapError { _ in
        return URLError(URLError.Code.badServerResponse)
      }
      .map { fireballs in
        os_log(.info, log: OSLog.default, "Downloaded \(fireballs.data.count) fireballs")
        return fireballs.data.compactMap { FireballData($0) }
      }
      .eraseToAnyPublisher()
  }
}

struct FireballsAPIData: Decodable {
  let signature: [String: String]
  let count: String
  let fields: [String]
  let data: [[String?]]
}

struct FireballData: Decodable {
  private static var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
  }()

  let dateTimeStamp: Date
  let latitude: Double
  let longitude: Double
  let altitude: Double
  let velocity: Double
  let radiatedEnergy: Double
  let impactEnergy: Double

  init?(_ values: [String?]) {
    // API fields: ["date","energy","impact-e","lat","lat-dir","lon","lon-dir","alt","vel"]

    guard !values.isEmpty,
      let dateValue = values[0],
      let date = FireballData.dateFormatter.date(from: dateValue) else {
      return nil
    }

    dateTimeStamp = date

    var energy: Double = 0
    var impact: Double = 0
    var lat: Double = 0
    var lon: Double = 0
    var alt: Double = 0
    var vel: Double = 0

    values.enumerated().forEach { value in
      guard let field = value.element else { return }

      if value.offset == 1 {
        energy = Double(field) ?? 0
      } else if value.offset == 2 {
        impact = Double(field) ?? 0
      } else if value.offset == 3 {
        lat = Double(field) ?? 0
      } else if value.offset == 4 && field == "S" {
        lat = -lat
      } else if value.offset == 5 {
        lon = Double(field) ?? 0
      } else if value.offset == 6 && field == "W" {
        lon = -lon
      } else if value.offset == 7 {
        alt = Double(field) ?? 0
      } else if value.offset == 8 {
        vel = Double(field) ?? 0
      }
    }

    radiatedEnergy = energy
    impactEnergy = impact
    latitude = lat
    longitude = lon
    altitude = alt
    velocity = vel
  }
}

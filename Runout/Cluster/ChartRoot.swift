import Foundation

/// One Codable chart under a single UserDefaults key. Schema 1 holds the Limit,
/// the unit label, and one metric record per daykey.
struct ChartRoot: Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var limit: LimitGauge
    var days: [ClusterDay]

    static let empty = ChartRoot(schemaVersion: currentSchema, limit: .standard, days: [])

    func day(_ daykey: Int) -> ClusterDay {
        days.first { $0.daykey == daykey } ?? .bare(daykey: daykey)
    }

    mutating func replace(_ day: ClusterDay) {
        if let index = days.firstIndex(where: { $0.daykey == day.daykey }) {
            days[index] = day
        } else {
            days.append(day)
        }
    }
}

extension ChartRoot: Codable {
    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case limit
        case days
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            limit = try container.decode(LimitGauge.self, forKey: .limit)
            days = try container.decode([ClusterDay].self, forKey: .days)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported chart schema \(version)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(limit, forKey: .limit)
        try container.encode(days, forKey: .days)
    }
}

enum ChartLoadNotice: Equatable, Sendable {
    case recoveredBackup
    case startedEmpty
}

enum ChartCoding {
    static func encode(_ root: ChartRoot) -> Result<Data, Error> {
        Result { try JSONEncoder().encode(root) }
    }

    static func decode(_ data: Data) -> Result<ChartRoot, Error> {
        Result { try JSONDecoder().decode(ChartRoot.self, from: data) }
    }
}

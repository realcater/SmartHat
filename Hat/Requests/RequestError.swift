enum RequestError {
    case noConnection
    case serverUnavailable
    case unauthorised
    case notFound
    case duplicate
    case gameEnded
    case JSONParseError
    case other
    
    var warning: String {
        switch self {
            case .noConnection: return "Нет связи или сервер не отвечает"
            case .serverUnavailable: return "Сервер не доступен"
            case .unauthorised: return "Пользователь не авторизован"
            case .notFound: return "Не найдено"
            case .duplicate: return "Этот никнейм уже занят"
            case .JSONParseError: return "Ошибка данных"
            case .gameEnded: return "Игра завершена"
            case .other: return "Ошибка сервера"
        }
    }
}

//
//  Game+extension.swift
//  Hat
//
//  Created by Realcater on 16.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

extension Game {
    var everyPlayerReady: Bool {
        return !data.players.map{ $0.accepted && $0.inGame }.contains(false)
    }
    
    var tellerNumber: Int {
        return turn % data.players.count
    }
    var listenerNumber: Int {
        let bigRoundLength = data.players.count * (data.players.count-1)
        let turnInBigRound = turn % bigRoundLength
        let round = turnInBigRound / data.players.count
        return (tellerNumber+round+1) % data.players.count
    }
    var prevTellerNumber: Int {
        return (turn-1) % data.players.count
    }
    var prevListenerNumber: Int {
        let bigRoundLength = data.players.count * (data.players.count-1)
        let turnInBigRound = (turn-1) % bigRoundLength
        let round = turnInBigRound / data.players.count
        return (prevTellerNumber+round+1) % data.players.count
    }
    var currentTeller: Player {
        return data.players[tellerNumber]
    }
    var currentListener: Player {
        return data.players[listenerNumber]
    }
    var isOneFullCircle: Bool {
        return (turn > 0) && (turn % ((data.players.count)*(data.players.count-1)) == 0)
    }
    var timeFromExplain: Int? {
        //guard let time = explainTime?.timeIntervalSinceNow else { return nil }
        let time = -Int(explainTime.convertFromZ()!.timeIntervalSinceNow)
        return ((time < 0) || (time > data.settings.roundDuration)) ? nil : time
    }
    
    func clear() {
        data.basketWords = []
        data.basketStatus = []
        data.wordsData = []
        guessedThisTurn = 0
    }
    
    func getRandomWordFromPool() -> Bool {
        if data.leftWords.count == 0 { return false }
        let number = Int.random(in: 0 ..< data.leftWords.count)
        data.currentWord = data.leftWords[number]
        return true
    }
    
    func setWordGuessed(time: Int) {
        data.wordsData.append(WordData(word: data.currentWord, timeGuessed: time, guessedStatus: .guessed))
        Helper.move(str: data.currentWord, from: &data.leftWords, to: &data.guessedWords)
        currentTeller.tellGuessed+=1
        currentListener.listenGuessed+=1
        data.basketWords.append(data.currentWord)
        data.basketStatus.append(.guessed)
        guessedThisTurn += 1
    }
    
    func setWordMissed(time: Int) {
        data.wordsData.append(WordData(word: data.currentWord, timeGuessed: time, guessedStatus: .missed))
        Helper.move(str: data.currentWord, from: &data.leftWords, to: &data.missedWords)
        data.basketWords.append(data.currentWord)
        data.basketStatus.append(.missed)
    }
    
    func setWordLeft(time: Int) {
        data.wordsData.append(WordData(word: data.currentWord, timeGuessed: time, guessedStatus: .left))
        data.basketWords.append(data.currentWord)
        data.basketStatus.append(.left)
    }
    
    func changeStatusInBasket(for num: Int) {
        let word = data.basketWords[num]
        switch data.basketStatus[num] {
        case .guessed:
            Helper.move(str: word, from: &data.guessedWords, to: &data.leftWords)
            data.basketStatus[num] = .left
            data.players[prevListenerNumber].listenGuessed-=1
            data.players[prevTellerNumber].tellGuessed-=1
        case .missed:
            Helper.move(str: word, from: &data.missedWords, to: &data.guessedWords)
            data.basketStatus[num] = .guessed
            data.players[prevListenerNumber].listenGuessed+=1
            data.players[prevTellerNumber].tellGuessed+=1
        case .left:
            Helper.move(str: word, from: &data.leftWords, to: &data.missedWords)
            data.basketStatus[num] = .missed
        }
    }
    func basketWordToShow(for num: Int) -> String {
        return data.basketStatus[num] == .left ? "XXXXXXXX" : data.basketWords[num]
    }
}

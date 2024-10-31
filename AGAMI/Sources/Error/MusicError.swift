//
//  MusicError.swift
//  AGAMI
//
//  Created by 박현수 on 10/31/24.
//

enum MusicAuthorizationError: Error {
    case denied
}

enum MusicServiceError: Error {
    case playlistNotFound
    case songNotFound
}

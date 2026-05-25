package cz.uhk.pro2.tulipani.security;

import org.springframework.stereotype.Service;

@Service
public class JwtService {

    public String generateToken(String subject) {
        throw new UnsupportedOperationException("TODO: implement JWT generation");
    }

    public String extractSubject(String token) {
        throw new UnsupportedOperationException("TODO: implement JWT parsing");
    }

    public boolean isTokenValid(String token, String subject) {
        throw new UnsupportedOperationException("TODO: implement JWT validation");
    }
}
package com.travislai.wms.auth.application.dto;

import java.util.List;

public record LoginResponse(String token, List<String> roles, String nickname) {
}


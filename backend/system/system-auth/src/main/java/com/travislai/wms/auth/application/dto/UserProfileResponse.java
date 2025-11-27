package com.travislai.wms.auth.application.dto;

import java.util.List;

public record UserProfileResponse(Long id,
                                  String username,
                                  String nickname,
                                  List<String> roles,
                                  List<String> permissions) {
}


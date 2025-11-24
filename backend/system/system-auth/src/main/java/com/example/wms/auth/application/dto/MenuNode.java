package com.example.wms.auth.application.dto;

import java.util.List;

public record MenuNode(Long id,
                       Long parentId,
                       String title,
                       String path,
                       String component,
                       String type,
                       String permission,
                       Integer sort,
                       String icon,
                       List<MenuNode> children) {
}


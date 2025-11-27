package com.travislai.wms.auth.application.assembler;

import com.travislai.wms.auth.application.dto.MenuNode;
import com.travislai.wms.auth.domain.entity.SysMenu;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public final class MenuAssembler {

    private MenuAssembler() {
    }

    public static List<MenuNode> buildTree(List<SysMenu> menus) {
        Map<Long, MenuNode> cache = menus.stream()
                .collect(Collectors.toMap(SysMenu::getId, MenuAssembler::toNode));
        List<MenuNode> roots = new ArrayList<>();
        for (SysMenu menu : menus) {
            MenuNode current = cache.get(menu.getId());
            if (menu.getParentId() == null || menu.getParentId() == 0) {
                roots.add(current);
                continue;
            }
            MenuNode parent = cache.get(menu.getParentId());
            if (parent != null) {
                parent.children().add(current);
            }
        }
        roots.sort(Comparator.comparing(MenuNode::sort));
        roots.forEach(MenuAssembler::sortChildrenRecursively);
        return roots;
    }

    private static MenuNode toNode(SysMenu menu) {
        return new MenuNode(menu.getId(), menu.getParentId(), menu.getTitle(), menu.getPath(),
                menu.getComponent(), menu.getType(), menu.getPermission(), menu.getSort(),
                menu.getIcon(), new ArrayList<>());
    }

    private static void sortChildrenRecursively(MenuNode node) {
        node.children().sort(Comparator.comparing(MenuNode::sort, Comparator.nullsLast(Integer::compareTo)));
        node.children().forEach(MenuAssembler::sortChildrenRecursively);
    }
}


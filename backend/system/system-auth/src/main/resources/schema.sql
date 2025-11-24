create table if not exists sys_user (
    id serial primary key,
    username varchar(64) not null unique,
    password varchar(128) not null,
    nickname varchar(64),
    status varchar(16) not null default 'ENABLED',
    deleted boolean not null default false,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp
);

create table if not exists sys_role (
    id serial primary key,
    code varchar(64) not null unique,
    name varchar(64) not null,
    status varchar(16) not null default 'ENABLED'
);

create table if not exists sys_menu (
    id serial primary key,
    parent_id int,
    title varchar(64) not null,
    path varchar(128),
    component varchar(128),
    type varchar(16),
    permission varchar(128),
    sort int default 0,
    icon varchar(64)
);

create table if not exists sys_user_role (
    id serial primary key,
    user_id int not null references sys_user(id),
    role_id int not null references sys_role(id)
);

create table if not exists sys_role_menu (
    id serial primary key,
    role_id int not null references sys_role(id),
    menu_id int not null references sys_menu(id)
);

insert into sys_user (username, password, nickname, status)
    values ('admin', 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7', '系统管理员', 'ENABLED')
    on conflict (username) do nothing;

insert into sys_role (code, name)
    values ('ADMIN', '超级管理员')
    on conflict (code) do nothing;

insert into sys_user_role (user_id, role_id)
    select u.id, r.id
    from sys_user u, sys_role r
    where u.username = 'admin'
      and r.code = 'ADMIN'
      and not exists(select 1 from sys_user_role sur where sur.user_id = u.id and sur.role_id = r.id);

insert into sys_menu (id, parent_id, title, path, component, type, permission, sort, icon)
values
    (1, 0, '运营驾驶舱', '/dashboard', 'DashboardView', 'MENU', 'dashboard:view', 1, 'dashboard'),
    (2, 0, '用户管理', '/users', 'UserListView', 'MENU', 'user:list', 2, 'user'),
    (3, 2, '角色管理', '/roles', 'RoleListView', 'MENU', 'role:list', 3, 'shield'),
    (4, 2, '菜单管理', '/menus', 'MenuListView', 'MENU', 'menu:list', 4, 'menu')
on conflict (id) do nothing;

insert into sys_role_menu (role_id, menu_id)
    select r.id, m.id
    from sys_role r
             join sys_menu m on m.id in (1, 2, 3, 4)
    where r.code = 'ADMIN'
      and not exists(select 1 from sys_role_menu srm where srm.role_id = r.id and srm.menu_id = m.id);


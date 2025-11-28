-- =============================================
-- Auth Service Database Schema
-- =============================================
-- Description: Creates authentication and authorization tables
-- Service: system-auth
-- Date: 2025-11-27
-- =============================================

-- =============================================
-- User Table (用户表)
-- =============================================
CREATE TABLE IF NOT EXISTS sys_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    nickname VARCHAR(64),
    status VARCHAR(16) NOT NULL DEFAULT 'ENABLED',
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- Role Table (角色表)
-- =============================================
CREATE TABLE IF NOT EXISTS sys_role (
    id SERIAL PRIMARY KEY,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(64) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ENABLED'
);

-- =============================================
-- Menu Table (菜单表)
-- =============================================
CREATE TABLE IF NOT EXISTS sys_menu (
    id SERIAL PRIMARY KEY,
    parent_id INT,
    title VARCHAR(64) NOT NULL,
    path VARCHAR(128),
    component VARCHAR(128),
    type VARCHAR(16),
    permission VARCHAR(128),
    sort INT DEFAULT 0,
    icon VARCHAR(64)
);

-- =============================================
-- User-Role Relation Table (用户角色关联表)
-- =============================================
CREATE TABLE IF NOT EXISTS sys_user_role (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES sys_user(id),
    role_id INT NOT NULL REFERENCES sys_role(id)
);

-- =============================================
-- Role-Menu Relation Table (角色菜单关联表)
-- =============================================
CREATE TABLE IF NOT EXISTS sys_role_menu (
    id SERIAL PRIMARY KEY,
    role_id INT NOT NULL REFERENCES sys_role(id),
    menu_id INT NOT NULL REFERENCES sys_menu(id)
);

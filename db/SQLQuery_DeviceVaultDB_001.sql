/***************************************************************************************************
Script Name			: 	SQLQuery_DeviceVaultDB_001.sql
Client's Name		: 	Tomas Agustin Albanesi
Create Date			: 	14/09/2024
Created By			: 	Tomas A. Albanesi
Description			:	Database and tables creation
Revision			:	2024-09-14
****************************************************************************************************/

/****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2024-09-14          Tomas A. Albanesi   Initial revision.
***************************************************************************************************/

----------------------------------------------------------------------------------------------------

-- Crear la base de datos
CREATE DATABASE DeviceVaultDB;
GO

-- Usar la base de datos creada
USE DeviceVaultDB;
GO

-- Crear tabla de Marcas
CREATE TABLE Brands (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,   -- ID único para cada marca
    BrandCode NVARCHAR(50) NOT NULL,         -- Código de la marca para generar el DeviceID
    BrandName NVARCHAR(100) NOT NULL         -- Nombre de la marca
);
GO

-- Crear tabla de Modelos
CREATE TABLE Models (
    ModelID INT IDENTITY(1,1) PRIMARY KEY,   -- ID único para cada modelo
    ModelCode NVARCHAR(50) NOT NULL,         -- Código del modelo para generar el DeviceID
    ModelName NVARCHAR(100) NOT NULL,        -- Nombre del modelo
    BrandID INT NOT NULL,                    -- ID de la marca asociada (FK)
    FOREIGN KEY (BrandID) REFERENCES Brands(BrandID)
);
GO

-- Crear tabla de Tipos
CREATE TABLE DeviceTypes (
    TypeID INT IDENTITY(1,1) PRIMARY KEY,    -- ID único para cada tipo
    TypeCode NVARCHAR(50) NOT NULL,          -- Código del tipo para generar el DeviceID
    TypeName NVARCHAR(100) NOT NULL          -- Nombre del tipo
);
GO

-- Crear tabla de Propietarios
CREATE TABLE Owners (
    OwnerID INT IDENTITY(1,1) PRIMARY KEY,    -- ID único para cada propietario
    OwnerName NVARCHAR(100) NOT NULL,         -- Nombre del propietario
    OwnerEmail NVARCHAR(100)                  -- Correo electrónico del propietario
);
GO

-- Crear tabla de Dispositivos
CREATE TABLE Devices (
    DeviceID INT IDENTITY(1,1) PRIMARY KEY,   -- ID único para cada dispositivo
    DeviceCode NVARCHAR(50) NOT NULL,         -- Código del dispositivo (Generado a partir de BrandCode, ModelCode y TypeCode)
    DeviceName NVARCHAR(100) NOT NULL,        -- Nombre del dispositivo
    BrandID INT NOT NULL,                    -- ID de la marca asociada (FK)
    ModelID INT NOT NULL,                    -- ID del modelo asociado (FK)
    TypeID INT NOT NULL,                     -- ID del tipo asociado (FK)
    OwnerID INT,                             -- ID del propietario asociado (FK, opcional)
    PurchaseDate DATE,                       -- Fecha de compra
    WarrantyExpiryDate DATE,                 -- Fecha de vencimiento de la garantía
    Location NVARCHAR(100),                  -- Ubicación del dispositivo
    FOREIGN KEY (BrandID) REFERENCES Brands(BrandID),
    FOREIGN KEY (ModelID) REFERENCES Models(ModelID),
    FOREIGN KEY (TypeID) REFERENCES DeviceTypes(TypeID),
    FOREIGN KEY (OwnerID) REFERENCES Owners(OwnerID)
);
GO

-- Crear tabla de RibbonPages
CREATE TABLE RibbonPages (
    RibbonPageID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada RibbonPage
    RibbonPageName NVARCHAR(100) NOT NULL       -- Nombre del RibbonPage
);
GO

-- Crear tabla de RibbonGroups
CREATE TABLE RibbonGroups (
    RibbonGroupID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada RibbonGroup
    RibbonGroupName NVARCHAR(100) NOT NULL,       -- Nombre del RibbonGroup
    RibbonPageID INT NOT NULL,                    -- ID del RibbonPage asociado (FK)
    FOREIGN KEY (RibbonPageID) REFERENCES RibbonPages(RibbonPageID)
);
GO

-- Crear tabla de BarButtonItems
CREATE TABLE BarButtonItems (
    BarButtonItemID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada BarButtonItem
    ButtonName NVARCHAR(100) NOT NULL,              -- Nombre del BarButtonItem
    RibbonGroupID INT NOT NULL,                     -- ID del RibbonGroup asociado (FK)
    FOREIGN KEY (RibbonGroupID) REFERENCES RibbonGroups(RibbonGroupID)
);
GO

-- Crear tabla de Formularios
CREATE TABLE Forms (
    FormID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada formulario
    FormName NVARCHAR(100) NOT NULL,       -- Nombre del formulario
    BarButtonItemID INT,                   -- ID del BarButtonItem asociado (FK)
    FOREIGN KEY (BarButtonItemID) REFERENCES BarButtonItems(BarButtonItemID)
);
GO

-- Crear tabla de Acciones
CREATE TABLE Actions (
    ActionID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada acción
    ActionName NVARCHAR(50) NOT NULL,        -- Nombre de la acción (Agregar, Editar, Ver, etc.)
    FormID INT NOT NULL,                     -- ID del formulario asociado (FK)
    FOREIGN KEY (FormID) REFERENCES Forms(FormID)
);
GO

-- Crear tabla de Permisos
CREATE TABLE Permissions (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada permiso
    ActionID INT NOT NULL,                      -- ID de la acción (FK)
    PermissionName NVARCHAR(50) NOT NULL,       -- Descripción del permiso
    FOREIGN KEY (ActionID) REFERENCES Actions(ActionID)
);
GO

-- Crear tabla de Roles
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada rol
    RoleName NVARCHAR(50) NOT NULL         -- Nombre del rol
);
GO

-- Crear tabla de Usuarios
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,      -- ID único para cada usuario
    Username NVARCHAR(50) NOT NULL UNIQUE,     -- Nombre de usuario
    PasswordHash NVARCHAR(255) NOT NULL,       -- Hash de la contraseña
    Email NVARCHAR(100),                       -- Correo electrónico del usuario
    FullName NVARCHAR(100),                    -- Nombre completo del usuario
    CanResetPassword BIT NOT NULL DEFAULT 0,   -- Puede restablecer la contraseña (0: No, 1: Sí)
    DefaultPasswordHash NVARCHAR(255)          -- Hash de la contraseña por defecto
);
GO

-- Crear tabla de UserRoles (Relación entre Usuarios y Roles)
CREATE TABLE UserRoles (
    UserRoleID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada relación
    UserID INT NOT NULL,                       -- ID del usuario (FK)
    RoleID INT NOT NULL,                       -- ID del rol (FK)
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

-- Crear tabla de RolePermissions (Relación entre Roles y Permisos)
CREATE TABLE RolePermissions (
    RolePermissionID INT IDENTITY(1,1) PRIMARY KEY,  -- ID único para cada relación
    RoleID INT NOT NULL,                            -- ID del rol (FK)
    PermissionID INT NOT NULL,                      -- ID del permiso (FK)
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    FOREIGN KEY (PermissionID) REFERENCES Permissions(PermissionID)
);
GO
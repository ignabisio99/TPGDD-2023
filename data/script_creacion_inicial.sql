USE [GD1C2023]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'APROBANDO')
	EXEC('CREATE SCHEMA APROBANDO')
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name = 'DROP_TABLES')
	EXEC('CREATE PROCEDURE [APROBANDO].[DROP_TABLES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[DROP_TABLES]
AS
BEGIN
	DECLARE @sql NVARCHAR(500) = ''
	
	DECLARE cursorTablas CURSOR FOR
	SELECT DISTINCT 'ALTER TABLE [' + tc.TABLE_SCHEMA + '].[' +  tc.TABLE_NAME + '] DROP [' + rc.CONSTRAINT_NAME + '];'
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	ON tc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
	WHERE tc.TABLE_SCHEMA = 'APROBANDO'

	OPEN cursorTablas
	FETCH NEXT FROM cursorTablas INTO @sql

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		EXEC sp_executesql @sql
		FETCH NEXT FROM cursorTablas INTO @Sql
	END

	CLOSE cursorTablas
	DEALLOCATE cursorTablas
	
	EXEC sp_MSforeachtable 'DROP TABLE ?', @whereand='AND schema_name(schema_id) = ''APROBANDO'' AND o.name NOT LIKE ''BI_%'''
END
GO

EXEC [APROBANDO].[DROP_TABLES]
GO


IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_TABLES')
   EXEC('CREATE PROCEDURE [APROBANDO].[CREATE_TABLES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[CREATE_TABLES]
AS
BEGIN

	CREATE TABLE [APROBANDO].[provincia] (
		provincia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		provincia NVARCHAR(255)
	);

CREATE TABLE [APROBANDO].[localidad](
		localidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		provincia_codigo INTEGER REFERENCES [APROBANDO].[provincia],
		localidad NVARCHAR(255)
);

CREATE TABLE [APROBANDO].[direccion](
		direccion_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		localidad_codigo INTEGER REFERENCES [APROBANDO].[localidad],
		direccion NVARCHAR(255)
);

	CREATE TABLE [APROBANDO].[producto] (
		producto_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		producto_id NVARCHAR(50),
		nombre NVARCHAR(50),
		descripcion NVARCHAR(50)
	);


	CREATE TABLE [APROBANDO].[tipo_local] (
		tipo_local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_local NVARCHAR(50) NOT NULL
	);

	CREATE TABLE [APROBANDO].[dia] (
		dia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		dia NVARCHAR(50) NOT NULL
	);

	CREATE TABLE [APROBANDO].[tipo_estado_mensajeria] (
		tipo_estado_mensajeria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado NVARCHAR(50) NOT NULL
	);

	CREATE TABLE [APROBANDO].[tipo_medio_pago] (
		t_medio_pago_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_medio_pago NVARCHAR(50) NOT NULL		
	);

	CREATE TABLE [APROBANDO].[tipo_movilidad] (
		movilidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		movilidad NVARCHAR(50) NOT NULL
	);

	CREATE TABLE [APROBANDO].[tipo_paquete] (
		tipo_paquete_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_paquete NVARCHAR(50) NOT NULL,
		ancho_max DECIMAL(18,2),
		largo_max DECIMAL(18,2),
		alto_max DECIMAL(18,2),
		peso_max DECIMAL(18,2),
		precio DECIMAL(18,2)
	);

	CREATE TABLE [APROBANDO].[usuario] (
		usuario_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		telefono DECIMAL(18,0),
		mail NVARCHAR(255),
		fecha_de_nacimiento DATE,
		dni DECIMAL(18,0),
		nombre NVARCHAR(255),
		apellido NVARCHAR(255),
		fecha_de_registro DATETIME2(3)
	);


	CREATE TABLE [APROBANDO].[tipo_estado_pedido] (
		t_estado_pedido_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado_pedido NVARCHAR(50) NOT NULL
	);


	CREATE TABLE [APROBANDO].[tipo_de_reclamo](
		tipo_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_de_reclamo NVARCHAR(50) NOT NULL
	);

	CREATE TABLE [APROBANDO].[tipo_cupon](
		tipo_cupon_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_cupon NVARCHAR(50) NOT NULL
	);

	CREATE TABLE [APROBANDO].[tarjeta](
		tarjeta_codigo INTEGER IDENTITY(1,1) PRIMARY KEY, 
		numero NVARCHAR(50) NOT NULL,
		marca NVARCHAR(100) NOT NULL
	);

		CREATE TABLE [APROBANDO].[tarjeta_por_usuario](
		tarjeta_codigo INTEGER REFERENCES [APROBANDO].[tarjeta] NOT NULL,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL
		PRIMARY KEY(tarjeta_codigo,usuario_codigo)
	);

	CREATE TABLE [APROBANDO].[medio_de_pago] (
		medio_pago_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_medio_pago INTEGER REFERENCES [APROBANDO].[tipo_medio_pago] NOT NULL,
		tarjeta_codigo INTEGER, 
		usuario_codigo  INTEGER, 
		FOREIGN KEY (tarjeta_codigo,usuario_codigo) REFERENCES [APROBANDO].[tarjeta_por_usuario](tarjeta_codigo,usuario_codigo) 
	);

	CREATE TABLE [APROBANDO].[categoria] (
		categoria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_local_codigo INTEGER REFERENCES [APROBANDO].[tipo_local],
		categoria NVARCHAR(50)
	);

CREATE TABLE [APROBANDO].[local] (
		local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		categoria INTEGER REFERENCES [APROBANDO].[categoria],
		nombre NVARCHAR(255) NOT NULL,
		direccion INTEGER REFERENCES [APROBANDO].[direccion] NOT NULL
	);

		CREATE TABLE [APROBANDO].[pedido](
		pedido_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		nro_pedido DECIMAL(18,0) NOT NULL,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL,
		local_codigo INTEGER REFERENCES [APROBANDO].[local] NOT NULL,
		medio_de_pago INTEGER REFERENCES [APROBANDO].[medio_de_pago] NOT NULL,
		fecha_pedido DATETIME,
		tarifa_delivery DECIMAL(18,2),
		total DECIMAL(18,2),
		observaciones VARCHAR(255),
		tiempo_estimado_entrega DECIMAL(18,2),
		fecha_entrga DATETIME,
		calificacion DECIMAL(18,0),
		total_cupones DECIMAL(18,2)
	);		

CREATE TABLE [APROBANDO].[estado_pedido] (
		estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado_pedido],
		nro_pedido INTEGER REFERENCES [APROBANDO].[pedido],
		fecha_estado DATE
	);



CREATE TABLE [APROBANDO].[horario_apertura] (
		horario_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		local_codigo INTEGER REFERENCES [APROBANDO].[local],
		dia INTEGER REFERENCES [APROBANDO].[dia],
		horario_inicio DECIMAL(18,0),
		horario_fin DECIMAL(18,0)
	);



CREATE TABLE [APROBANDO].[direccion_por_usuario](
		direccion_codigo INTEGER REFERENCES [APROBANDO].[direccion] NOT NULL,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL,
		tipo_direccion NVARCHAR(50),
		PRIMARY KEY(direccion_codigo,usuario_codigo)
);

CREATE TABLE [APROBANDO].[operador](
		operador_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario],
);

	CREATE TABLE [APROBANDO].[cupon](
		cupon_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		cupon_nro DECIMAL(18,0) NOT NULL,
		tipo_cupon INTEGER REFERENCES [APROBANDO].[tipo_cupon],
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL,
		fecha_alta DATETIME,
		fecha_vencimiento DATETIME,
		usado BIT,
		monto decimal(18,2)
	);


CREATE TABLE [APROBANDO].[reclamo](
		reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		nro_reclamo DECIMAL(18,0) NOT NULL,
		usuario INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL,
		pedido_codigo INTEGER REFERENCES [APROBANDO].[pedido] NOT NULL,
		tipo_de_reclamo INTEGER REFERENCES [APROBANDO].[tipo_de_reclamo],
		operador_codigo INTEGER REFERENCES [APROBANDO].[operador],
		cupon INTEGER REFERENCES [APROBANDO].[cupon],
		descripcion NVARCHAR(255),
		fecha_reclamo DATETIME,
		fecha_solucion DATETIME,
		calificacion DECIMAL(18,0),
		solucion NVARCHAR(255)
);

CREATE TABLE [APROBANDO].[tipo_estado_reclamo](
		tipo_estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado NVARCHAR(50) NOT NULL
);

CREATE TABLE [APROBANDO].[estado_de_reclamo](
		estado_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		reclamo_codigo INTEGER REFERENCES [APROBANDO].[reclamo],
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado_reclamo] NOT NULL,
		fecha_estado DATETIME
);

CREATE TABLE [APROBANDO].[repartidor](
		repartidor_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL,
		movilidad INTEGER REFERENCES [APROBANDO].[tipo_movilidad]
	);


CREATE TABLE [APROBANDO].[envio_mensajeria](
		envio_msj_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		nro_envio_msj DECIMAL(18,0) NOT NULL,
		usuario INTEGER REFERENCES [APROBANDO].[usuario] NOT NULL,
		direccion_origen INTEGER REFERENCES [APROBANDO].[direccion],
		direccion_destino INTEGER REFERENCES [APROBANDO].[direccion],
		tipo_paquete_codigo INTEGER REFERENCES [APROBANDO].[tipo_paquete],
		repartidor_codigo INTEGER REFERENCES [APROBANDO].[repartidor],
		medio_de_pago_codigo INTEGER REFERENCES [APROBANDO].[medio_de_pago],
		fecha_envio_msj NVARCHAR(255),
		distancia_en_km DECIMAL(18,2),
		valor_asegurado DECIMAL(18,2),
		observaciones NVARCHAR(255),
		precio_envio DECIMAL(18,2),
		precio_seguro DECIMAL(18,2),
		propina DECIMAL(18,2),
		total DECIMAL(18,2),
		tiempo_estimado_entrega DECIMAL(18,2),
		fecha_hora_entrega DATETIME,
		calificacion DECIMAL(18,0)
);

CREATE TABLE [APROBANDO].[estado_mensajeria](
		estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado_mensajeria],
		envio_msj_codigo INTEGER REFERENCES [APROBANDO].[envio_mensajeria],
		fecha_estado DATETIME
);


CREATE TABLE [APROBANDO].[envio](
		envio_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		direccion INTEGER REFERENCES [APROBANDO].[direccion],
		precio DECIMAL(18,2),
		propina DECIMAL(18,2),
		repartidor_codigo INTEGER REFERENCES [APROBANDO].[repartidor] NOT NULL,
		nro_pedido INTEGER REFERENCES [APROBANDO].[pedido] NOT NULL
);

CREATE TABLE [APROBANDO].[producto_local] (
		producto_codigo INTEGER NOT NULL REFERENCES [APROBANDO].[producto],
		local_codigo INTEGER NOT NULL REFERENCES [APROBANDO].[local],
		PRIMARY KEY (producto_codigo,local_codigo),
		precio_en_local DECIMAL(18,2) 
);



CREATE TABLE [APROBANDO].[item] (
		producto_codigo INTEGER NOT NULL,
		local_codigo INTEGER NOT NULL,
		nro_pedido INTEGER NOT NULL REFERENCES [APROBANDO].[pedido],
		FOREIGN KEY (producto_codigo,local_codigo) REFERENCES [APROBANDO].[producto_local](producto_codigo,local_codigo),
		PRIMARY KEY (producto_codigo,local_codigo,nro_pedido),
		cantidad DECIMAL(18,0),
		precio_unitario DECIMAL(18,2) NOT NULL,
		total DECIMAL(18,0)
);




	CREATE TABLE [APROBANDO].[cupon_canjeado](
		cupon_codigo INTEGER REFERENCES [APROBANDO].[cupon],
		pedido_codigo INTEGER REFERENCES [APROBANDO].[pedido],
		importe DECIMAL(18,2),
		PRIMARY KEY(cupon_codigo,pedido_codigo)
	);

	

	CREATE TABLE [APROBANDO].[localidad_por_repartidor](
		localidad_codigo INTEGER REFERENCES [APROBANDO].[localidad],
		repartidor_codigo INTEGER REFERENCES [APROBANDO].[repartidor],
		activa BIT
	);

END
GO

EXEC [APROBANDO].[CREATE_TABLES]
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_INDEXES')
	EXEC('CREATE PROCEDURE [APROBANDO].[CREATE_INDEXES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[CREATE_INDEXES]
AS
BEGIN
	CREATE INDEX index_localidad ON [APROBANDO].[localidad](localidad);
	CREATE INDEX index_dni ON [APROBANDO].[usuario](dni);
END
GO

EXEC [APROBANDO].[CREATE_INDEXES]

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='MIGRAR')
	EXEC('CREATE PROCEDURE [APROBANDO].[MIGRAR] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[MIGRAR]
AS
BEGIN

	--provincia

	INSERT INTO [APROBANDO].[provincia] (provincia)
		SELECT DISTINCT ENVIO_MENSAJERIA_PROVINCIA
		FROM [gd_esquema].[Maestra]
		WHERE ENVIO_MENSAJERIA_PROVINCIA IS NOT NULL
		UNION
		SELECT DISTINCT DIRECCION_USUARIO_PROVINCIA
		FROM [gd_esquema].[Maestra]
		WHERE DIRECCION_USUARIO_PROVINCIA IS NOT NULL	
		UNION
		SELECT DISTINCT LOCAL_PROVINCIA
		FROM [gd_esquema].Maestra
		WHERE LOCAL_PROVINCIA IS NOT NULL

	--localidad
	

	INSERT INTO [APROBANDO].[localidad] (localidad,provincia_codigo)
		SELECT DISTINCT ENVIO_MENSAJERIA_LOCALIDAD,provincia_codigo
		FROM [gd_esquema].[Maestra] join [APROBANDO].provincia
		ON ENVIO_MENSAJERIA_PROVINCIA = provincia
		WHERE ENVIO_MENSAJERIA_LOCALIDAD IS NOT NULL
		UNION
		SELECT DISTINCT DIRECCION_USUARIO_LOCALIDAD,provincia_codigo
		FROM [gd_esquema].[Maestra] join [APROBANDO].provincia
		ON DIRECCION_USUARIO_PROVINCIA= provincia
		WHERE DIRECCION_USUARIO_LOCALIDAD IS NOT NULL
		UNION
		SELECT DISTINCT LOCAL_LOCALIDAD,provincia_codigo
		FROM [gd_esquema].[Maestra] join [APROBANDO].provincia
		ON LOCAL_PROVINCIA = provincia
		WHERE LOCAL_LOCALIDAD IS NOT NULL

	--direccion(los repartidores y operadores tendrían el campo tipo de direccion y la localidad en null ya que no lo especifican)

	INSERT INTO [APROBANDO].[direccion] (direccion,localidad_codigo)
	SELECT DISTINCT DIRECCION_USUARIO_DIRECCION, localidad_codigo
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] p on p.provincia = DIRECCION_USUARIO_PROVINCIA 
	JOIN [APROBANDO].[localidad] l ON DIRECCION_USUARIO_LOCALIDAD = l.localidad and l.provincia_codigo = p.provincia_codigo
	WHERE DIRECCION_USUARIO_DIRECCION IS NOT NULL
	UNION
	SELECT DISTINCT LOCAL_DIRECCION, localidad_codigo
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] p on p.provincia = LOCAL_PROVINCIA
	JOIN [APROBANDO].[localidad] l ON LOCAL_LOCALIDAD = l.localidad and l.provincia_codigo = p.provincia_codigo 
	WHERE LOCAL_DIRECCION IS NOT NULL
	UNION 
	SELECT DISTINCT OPERADOR_RECLAMO_DIRECCION, NULL
	FROM [gd_esquema].[Maestra]
	WHERE OPERADOR_RECLAMO_DIRECCION IS NOT NULL
	UNION
	SELECT DISTINCT REPARTIDOR_DIRECION, NULL
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_DIRECION IS NOT NULL
	UNION
	SELECT DISTINCT ENVIO_MENSAJERIA_DIR_DEST,localidad_codigo
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] p on p.provincia = ENVIO_MENSAJERIA_PROVINCIA
	JOIN [APROBANDO].[localidad] l 
	ON ENVIO_MENSAJERIA_LOCALIDAD = l.localidad AND l.provincia_codigo = p.provincia_codigo
	WHERE ENVIO_MENSAJERIA_DIR_DEST IS NOT NULL
	UNION
	SELECT DISTINCT ENVIO_MENSAJERIA_DIR_ORIG,localidad_codigo
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] p on p.provincia = ENVIO_MENSAJERIA_PROVINCIA
	JOIN [APROBANDO].[localidad] l ON ENVIO_MENSAJERIA_LOCALIDAD = l.localidad and l.provincia_codigo = p.provincia_codigo
	WHERE ENVIO_MENSAJERIA_DIR_ORIG IS NOT NULL

	--usuario

	INSERT INTO [APROBANDO].[usuario] (nombre,apellido,dni,telefono,mail,fecha_de_nacimiento,fecha_de_registro)
	SELECT DISTINCT USUARIO_NOMBRE,USUARIO_APELLIDO,USUARIO_DNI,USUARIO_TELEFONO,USUARIO_MAIL,USUARIO_FECHA_NAC,USUARIO_FECHA_REGISTRO
	FROM [gd_esquema].[Maestra]
	WHERE USUARIO_DNI IS NOT NULL
	UNION 
	SELECT DISTINCT REPARTIDOR_NOMBRE,REPARTIDOR_APELLIDO,REPARTIDOR_DNI,REPARTIDOR_TELEFONO,REPARTIDOR_EMAIL,REPARTIDOR_FECHA_NAC,NULL
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_DNI IS NOT NULL
	UNION
	SELECT DISTINCT OPERADOR_RECLAMO_NOMBRE,OPERADOR_RECLAMO_APELLIDO,OPERADOR_RECLAMO_DNI,OPERADOR_RECLAMO_TELEFONO,OPERADOR_RECLAMO_MAIL,OPERADOR_RECLAMO_FECHA_NAC,NULL
	FROM [gd_esquema].[Maestra]
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL

	--direccion por usuario

	INSERT INTO [APROBANDO].[direccion_por_usuario] (direccion_codigo,usuario_codigo,tipo_direccion)
	SELECT DISTINCT d.direccion_codigo,u.usuario_codigo,DIRECCION_USUARIO_NOMBRE
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] p on DIRECCION_USUARIO_PROVINCIA = p.provincia
	JOIN [APROBANDO].[localidad] l on DIRECCION_USUARIO_LOCALIDAD = l.localidad and p.provincia_codigo = l.provincia_codigo 
	JOIN [APROBANDO].[direccion] d on DIRECCION_USUARIO_DIRECCION = d.direccion and d.localidad_codigo = l.localidad_codigo
	JOIN [APROBANDO].[usuario] u on u.dni = USUARIO_DNI
	WHERE DIRECCION_USUARIO_NOMBRE IS NOT NULL
	UNION 
	SELECT DISTINCT d.direccion_codigo,u.usuario_codigo,NULL
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[direccion] d on OPERADOR_RECLAMO_DIRECCION = d.direccion 
	JOIN [APROBANDO].[usuario] u on u.dni = OPERADOR_RECLAMO_DNI
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL
	UNION 
	SELECT DISTINCT d.direccion_codigo,u.usuario_codigo,NULL
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[direccion] d on REPARTIDOR_DIRECION = d.direccion 
	JOIN [APROBANDO].[usuario] u on u.dni = REPARTIDOR_DNI
	WHERE REPARTIDOR_DNI IS NOT NULL

	--OPERADOR

	INSERT INTO [APROBANDO].[operador] (usuario_codigo)
	SELECT DISTINCT u.usuario_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u ON u.dni = OPERADOR_RECLAMO_DNI
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL AND u.fecha_de_registro IS NULL

	--tipo movilidad

	INSERT INTO [APROBANDO].[tipo_movilidad] (movilidad)
	SELECT DISTINCT REPARTIDOR_TIPO_MOVILIDAD
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_TIPO_MOVILIDAD IS NOT NULL

	-- repartidor 

	INSERT INTO [APROBANDO].[repartidor] (usuario_codigo,movilidad)
	SELECT DISTINCT u.usuario_codigo, tm.movilidad_codigo 
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u ON u.dni = REPARTIDOR_DNI
	JOIN [APROBANDO].[tipo_movilidad] tm on REPARTIDOR_TIPO_MOVILIDAD = tm.movilidad
	WHERE REPARTIDOR_DNI IS NOT NULL

	-- localidad por repartidor

	INSERT INTO [APROBANDO].[localidad_por_repartidor](localidad_codigo,repartidor_codigo,activa)
	SELECT DISTINCT l.localidad_codigo, r.repartidor_codigo, NULL
	FROM [gd_esquema].[Maestra] JOIN 
	[APROBANDO].[usuario] ur on ur.dni = REPARTIDOR_DNI
	JOIN repartidor r on r.usuario_codigo = ur.usuario_codigo
	JOIN [APROBANDO].[provincia] p on p.provincia = LOCAL_PROVINCIA
	JOIN [APROBANDO].[localidad] l on LOCAL_LOCALIDAD = l.localidad and l.provincia_codigo = p.provincia_codigo
	WHERE REPARTIDOR_DNI IS NOT NULL AND LOCAL_LOCALIDAD IS NOT NULL

	-- tipo cupon 

	INSERT INTO [APROBANDO].[tipo_cupon](tipo_cupon)
	SELECT DISTINCT CUPON_TIPO
	FROM [gd_esquema].[Maestra]
	WHERE CUPON_TIPO IS NOT NULL
	UNION
	SELECT DISTINCT CUPON_RECLAMO_TIPO
	FROM [gd_esquema].[Maestra]
	WHERE CUPON_RECLAMO_TIPO IS NOT NULL

	-- cupon 

	INSERT INTO [APROBANDO].[cupon](cupon_nro,fecha_alta,fecha_vencimiento,usuario_codigo,monto,usado,tipo_cupon)
	SELECT DISTINCT CUPON_NRO,CUPON_FECHA_ALTA,CUPON_FECHA_VENCIMIENTO,u.usuario_codigo,CUPON_MONTO,1,tc.tipo_cupon_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u on u.dni = USUARIO_DNI
	JOIN [APROBANDO].[tipo_cupon] tc on tc.tipo_cupon = CUPON_TIPO
	WHERE CUPON_NRO IS NOT NULL
	UNION
	SELECT DISTINCT CUPON_RECLAMO_NRO,CUPON_RECLAMO_FECHA_ALTA,CUPON_RECLAMO_FECHA_VENCIMIENTO,u.usuario_codigo,CUPON_RECLAMO_MONTO,1,tc.tipo_cupon_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u on u.dni = USUARIO_DNI
	JOIN [APROBANDO].[tipo_cupon] tc on tc.tipo_cupon = CUPON_RECLAMO_TIPO
	WHERE CUPON_RECLAMO_NRO IS NOT NULL

	-- tipo reclamo

	INSERT INTO [APROBANDO].[tipo_de_reclamo](tipo_de_reclamo)
	SELECT DISTINCT RECLAMO_TIPO 
	FROM [gd_esquema].[Maestra]
	WHERE RECLAMO_TIPO IS NOT NULL

	-- tarjeta

    INSERT INTO [APROBANDO].[tarjeta] (numero,marca)
    SELECT DISTINCT MEDIO_PAGO_NRO_TARJETA, MARCA_TARJETA
    FROM [gd_esquema].[Maestra]
    WHERE MEDIO_PAGO_NRO_TARJETA IS NOT NULL

    -- tarjeta por usuario

    INSERT INTO [APROBANDO].[tarjeta_por_usuario] (tarjeta_codigo, usuario_codigo)
    SELECT DISTINCT t.tarjeta_codigo, u.usuario_codigo 
    FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[tarjeta] t ON t.numero = MEDIO_PAGO_NRO_TARJETA
    JOIN [APROBANDO].[usuario] u ON u.dni = USUARIO_DNI
    WHERE USUARIO_DNI IS NOT NULL

    -- tipo medio de pago

    INSERT INTO [APROBANDO].[tipo_medio_pago] (tipo_medio_pago)
    SELECT DISTINCT MEDIO_PAGO_TIPO
    FROM [gd_esquema].[Maestra]
    WHERE MEDIO_PAGO_TIPO IS NOT NULL

	  -- medio de pago

    INSERT INTO [APROBANDO].[medio_de_pago] (tipo_medio_pago, tarjeta_codigo, usuario_codigo)
    SELECT DISTINCT tmp.t_medio_pago_codigo, t.tarjeta_codigo, u.usuario_codigo
    FROM [gd_esquema].[Maestra]
	JOIN [APROBANDO].[tipo_medio_pago] tmp ON MEDIO_PAGO_TIPO = tmp.tipo_medio_pago
    JOIN [APROBANDO].[tarjeta] t ON MEDIO_PAGO_NRO_TARJETA = t.numero
    JOIN [APROBANDO].[usuario] u ON USUARIO_DNI = u.dni
    WHERE USUARIO_DNI IS NOT NULL AND MEDIO_PAGO_NRO_TARJETA IS NOT NULL

    -- tipo estado reclamo

    INSERT INTO [APROBANDO].[tipo_estado_reclamo] (tipo_estado)
    SELECT DISTINCT RECLAMO_ESTADO
    FROM [gd_esquema].[Maestra]
    WHERE RECLAMO_ESTADO IS NOT NULL

	-- dia

	INSERT INTO [APROBANDO].[dia](dia)
	SELECT DISTINCT HORARIO_LOCAL_DIA
	FROM [gd_esquema].[Maestra]
	WHERE HORARIO_LOCAL_DIA IS NOT NULL

	--  tipo estado pedido 

	INSERT INTO [APROBANDO].[tipo_estado_pedido](tipo_estado_pedido)
	SELECT DISTINCT PEDIDO_ESTADO
	FROM [gd_esquema].[Maestra]
	WHERE PEDIDO_ESTADO IS NOT NULL

	-- tipo estado mensajeria

    INSERT INTO [APROBANDO].[tipo_estado_mensajeria] (tipo_estado)
    SELECT DISTINCT ENVIO_MENSAJERIA_ESTADO
    FROM [gd_esquema].[Maestra]
    WHERE ENVIO_MENSAJERIA_ESTADO IS NOT NULL

	-- tipo local

	INSERT INTO [APROBANDO].[tipo_local] (tipo_local)
	SELECT DISTINCT LOCAL_TIPO
	FROM [gd_esquema].[Maestra]
	WHERE LOCAL_TIPO IS NOT NULL

	-- categoria FALTA IMPLEMENTACION DE CATEGORIA (NO HAY NADA EN LA TABLA MAESTRA)


	INSERT INTO [APROBANDO].[categoria] (tipo_local_codigo, categoria)
	SELECT DISTINCT t.tipo_local_codigo,NULL
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[tipo_local] t ON LOCAL_TIPO = t.tipo_local

	-- local FALTA IMPLEMENTACION DE CATEGORIA (NO HAY NADA EN LA TABLA MAESTRA)

	INSERT INTO [APROBANDO].[local] (categoria, direccion, nombre)
	SELECT DISTINCT c.categoria_codigo, d.direccion_codigo, LOCAL_NOMBRE
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] p on p.provincia = LOCAL_PROVINCIA
	JOIN [APROBANDO].[localidad] l on l.localidad = LOCAL_LOCALIDAD and l.provincia_codigo = p.provincia_codigo
	JOIN [APROBANDO].[direccion] d ON LOCAL_DIRECCION = d.direccion and d.localidad_codigo = l.localidad_codigo
	JOIN [APROBANDO].[tipo_local] tl on LOCAL_TIPO = tl.tipo_local
	JOIN [APROBANDO].[categoria] c on c.tipo_local_codigo = tl.tipo_local_codigo
	WHERE LOCAL_DIRECCION IS NOT NULL
	

	-- horario apertura

	INSERT INTO [APROBANDO].[horario_apertura] (local_codigo, dia, horario_inicio, horario_fin)
	SELECT DISTINCT l.local_codigo, d.dia_codigo, HORARIO_LOCAL_HORA_APERTURA, HORARIO_LOCAL_HORA_CIERRE
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[local] l ON LOCAL_NOMBRE = l.nombre
	JOIN [APROBANDO].[dia] d ON HORARIO_LOCAL_DIA = d.dia
	WHERE LOCAL_NOMBRE IS NOT NULL AND HORARIO_LOCAL_DIA IS NOT NULL

	-- producto 

	INSERT INTO [APROBANDO].[producto] (nombre, descripcion, producto_id)
	SELECT DISTINCT PRODUCTO_LOCAL_NOMBRE, PRODUCTO_LOCAL_DESCRIPCION, PRODUCTO_LOCAL_CODIGO 
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_LOCAL_NOMBRE IS NOT NULL

	-- producto local

	INSERT INTO [APROBANDO].[producto_local] (local_codigo, producto_codigo, precio_en_local)
	SELECT DISTINCT l.local_codigo, p.producto_codigo, PRODUCTO_LOCAL_PRECIO
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[provincia] prov ON LOCAL_PROVINCIA = prov.provincia
	JOIN [APROBANDO].[localidad] loc on loc.localidad = LOCAL_LOCALIDAD and loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[direccion] dir on dir.direccion = LOCAL_DIRECCION and dir.localidad_codigo = loc.localidad_codigo
	JOIN [APROBANDO].[local] l ON LOCAL_NOMBRE = l.nombre and l.direccion = dir.direccion_codigo
	JOIN [APROBANDO].[producto] p ON PRODUCTO_LOCAL_NOMBRE = p.nombre
	WHERE LOCAL_NOMBRE IS NOT NULL AND PRODUCTO_LOCAL_NOMBRE IS NOT NULL

	-- tipo paquete

	INSERT INTO [APROBANDO].[tipo_paquete] (tipo_paquete,ancho_max, largo_max, alto_max, peso_max, precio)
	SELECT DISTINCT PAQUETE_TIPO,PAQUETE_ANCHO_MAX, PAQUETE_LARGO_MAX, PAQUETE_ALTO_MAX, PAQUETE_PESO_MAX, PAQUETE_TIPO_PRECIO
	FROM [gd_esquema].[Maestra] 
	WHERE PAQUETE_TIPO_PRECIO IS NOT NULL

	--envio mensajeria 
		
	INSERT INTO [APROBANDO].[envio_mensajeria] (nro_envio_msj,distancia_en_km,valor_asegurado,observaciones,precio_envio,
		precio_seguro,propina,total,tiempo_estimado_entrega,fecha_hora_entrega,calificacion,usuario,tipo_paquete_codigo
		,repartidor_codigo,medio_de_pago_codigo,direccion_origen,direccion_destino,fecha_envio_msj)
	SELECT DISTINCT ENVIO_MENSAJERIA_NRO, 
	ENVIO_MENSAJERIA_KM, ENVIO_MENSAJERIA_VALOR_ASEGURADO, 
	ENVIO_MENSAJERIA_OBSERV, ENVIO_MENSAJERIA_PRECIO_ENVIO, 
	ENVIO_MENSAJERIA_PRECIO_SEGURO, ENVIO_MENSAJERIA_PROPINA, 
	ENVIO_MENSAJERIA_TOTAL, ENVIO_MENSAJERIA_TIEMPO_ESTIMADO,
	ENVIO_MENSAJERIA_FECHA_ENTREGA, ENVIO_MENSAJERIA_CALIFICACION,
	u.usuario_codigo,tp.tipo_paquete_codigo,r.repartidor_codigo,
	mp.medio_pago_codigo,dir1.direccion_codigo,dir2.direccion_codigo,ENVIO_MENSAJERIA_FECHA
	FROM [gd_esquema].[Maestra]
	JOIN [APROBANDO].[usuario] u ON USUARIO_DNI = u.dni
	JOIN [APROBANDO].[tipo_paquete] tp ON PAQUETE_TIPO = tp.tipo_paquete 
	JOIN [APROBANDO].[usuario] ur ON REPARTIDOR_DNI = ur.dni
	JOIN [APROBANDO].[repartidor] r ON ur.usuario_codigo = r.usuario_codigo
	JOIN [APROBANDO].[tipo_medio_pago] tmp ON tmp.tipo_medio_pago = MEDIO_PAGO_TIPO
	JOIN [APROBANDO].[tarjeta] tar ON tar.numero = MEDIO_PAGO_NRO_TARJETA
	JOIN [APROBANDO].[medio_de_pago] mp ON mp.tipo_medio_pago + u.usuario_codigo + tar.tarjeta_codigo = tmp.t_medio_pago_codigo + mp.usuario_codigo + mp.tarjeta_codigo
	JOIN [APROBANDO].[provincia] prov on prov.provincia = ENVIO_MENSAJERIA_PROVINCIA
	JOIN [APROBANDO].[localidad] loc1 ON ENVIO_MENSAJERIA_LOCALIDAD = loc1.localidad and prov.provincia_codigo = loc1.provincia_codigo
	JOIN [APROBANDO].[direccion] dir1 ON dir1.direccion = ENVIO_MENSAJERIA_DIR_ORIG AND dir1.localidad_codigo = loc1.localidad_codigo
	JOIN [APROBANDO].[direccion] dir2 ON dir2.direccion = ENVIO_MENSAJERIA_DIR_DEST AND dir2.localidad_codigo = loc1.localidad_codigo
	WHERE USUARIO_DNI IS NOT NULL AND PAQUETE_TIPO IS NOT NULL AND REPARTIDOR_DNI IS NOT NULL AND MEDIO_PAGO_TIPO IS NOT NULL 


	-- estado mensajeria
	
	INSERT INTO [APROBANDO].[estado_mensajeria] (tipo_estado,envio_msj_codigo, fecha_estado)
	SELECT DISTINCT tem.tipo_estado_mensajeria_codigo, m.envio_msj_codigo, ENVIO_MENSAJERIA_FECHA
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[tipo_estado_mensajeria] tem ON ENVIO_MENSAJERIA_ESTADO = tem.tipo_estado
	JOIN [APROBANDO].[envio_mensajeria] m ON ENVIO_MENSAJERIA_NRO = m.nro_envio_msj
	WHERE ENVIO_MENSAJERIA_ESTADO IS NOT NULL AND ENVIO_MENSAJERIA_NRO IS NOT NULL

	-- pedido 	

	INSERT INTO [APROBANDO].[pedido] (nro_pedido,usuario_codigo, local_codigo, medio_de_pago, fecha_pedido, tarifa_delivery, total, observaciones,
	tiempo_estimado_entrega, fecha_entrga, calificacion, total_cupones)
	SELECT DISTINCT PEDIDO_NRO,u.usuario_codigo, l.local_codigo, mp.medio_pago_codigo, PEDIDO_FECHA, PEDIDO_TARIFA_SERVICIO,
	PEDIDO_TOTAL_SERVICIO + PEDIDO_TOTAL_PRODUCTOS + PEDIDO_PRECIO_ENVIO + PEDIDO_PROPINA - PEDIDO_TOTAL_CUPONES, PEDIDO_OBSERV,
	PEDIDO_TIEMPO_ESTIMADO_ENTREGA, PEDIDO_FECHA_ENTREGA, PEDIDO_CALIFICACION, PEDIDO_TOTAL_CUPONES
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u ON USUARIO_DNI = u.dni
	JOIN [APROBANDO].[provincia] prov ON LOCAL_PROVINCIA = prov.provincia
	JOIN [APROBANDO].[localidad] loc on loc.localidad = LOCAL_LOCALIDAD and loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[direccion] dir on dir.direccion = LOCAL_DIRECCION and dir.localidad_codigo = loc.localidad_codigo
	JOIN [APROBANDO].[local] l ON LOCAL_NOMBRE = l.nombre and dir.direccion_codigo = l.direccion
	JOIN [APROBANDO].[tipo_medio_pago] tmp ON MEDIO_PAGO_TIPO = tmp.tipo_medio_pago
	JOIN [APROBANDO].[tarjeta] tarjeta ON MEDIO_PAGO_NRO_TARJETA = tarjeta.numero
	JOIN [APROBANDO].[medio_de_pago] mp ON tmp.t_medio_pago_codigo = mp.tipo_medio_pago AND mp.tarjeta_codigo = tarjeta.tarjeta_codigo 
	WHERE USUARIO_DNI IS NOT NULL AND LOCAL_NOMBRE IS NOT NULL AND MEDIO_PAGO_NRO_TARJETA IS NOT NULL AND PEDIDO_NRO IS NOT NULL

	-- item

	INSERT INTO [APROBANDO].[item] (producto_codigo, local_codigo, nro_pedido, cantidad, precio_unitario, total)
	SELECT DISTINCT p.producto_codigo, l.local_codigo, pe.pedido_codigo, 
	SUM(PRODUCTO_CANTIDAD), PRODUCTO_LOCAL_PRECIO, PEDIDO_TOTAL_PRODUCTOS
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[producto] p ON PRODUCTO_LOCAL_NOMBRE = p.nombre
	JOIN [APROBANDO].[provincia] prov ON LOCAL_PROVINCIA = prov.provincia
	JOIN [APROBANDO].[localidad] loc on loc.localidad = LOCAL_LOCALIDAD and loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[direccion] dir on dir.direccion = LOCAL_DIRECCION and dir.localidad_codigo = loc.localidad_codigo
	JOIN [APROBANDO].[local] l ON LOCAL_NOMBRE = l.nombre and dir.direccion_codigo = l.direccion
	JOIN [APROBANDO].[pedido] pe ON PEDIDO_NRO = pe.nro_pedido
	WHERE PRODUCTO_LOCAL_CODIGO IS NOT NULL AND LOCAL_NOMBRE IS NOT NULL AND PEDIDO_NRO IS NOT NULL
	GROUP BY p.producto_codigo, l.local_codigo, pe.pedido_codigo, PRODUCTO_LOCAL_PRECIO, PEDIDO_TOTAL_PRODUCTOS

	
	-- estado_pedido REVISAR FECHA

	INSERT INTO [APROBANDO].[estado_pedido] (tipo_estado, nro_pedido, fecha_estado)
	SELECT DISTINCT te.t_estado_pedido_codigo, p.pedido_codigo, PEDIDO_FECHA_ENTREGA
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[tipo_estado_pedido] te ON PEDIDO_ESTADO = te.tipo_estado_pedido
	JOIN [APROBANDO].[pedido] p ON PEDIDO_NRO = p.nro_pedido 
	WHERE PEDIDO_ESTADO IS NOT NULL AND PEDIDO_NRO IS NOT NULL

	-- cupon canjeado (un cupon se puede usar en muchos pedidos)

	INSERT INTO [APROBANDO].[cupon_canjeado] (cupon_codigo, pedido_codigo, importe)
	SELECT DISTINCT c.cupon_codigo, p.pedido_codigo, ma.CUPON_MONTO
	FROM [gd_esquema].[Maestra] ma JOIN [APROBANDO].[cupon] c ON ma.CUPON_NRO = c.cupon_nro
	JOIN [APROBANDO].[pedido] p ON ma.PEDIDO_NRO = p.nro_pedido
	WHERE ma.CUPON_NRO IS NOT NULL AND ma.PEDIDO_NRO IS NOT NULL


	-- envio REVISAR DNI REPARTIDOR


	INSERT INTO [APROBANDO].[envio] (direccion, precio, propina, repartidor_codigo, nro_pedido)
	SELECT DISTINCT d.direccion_codigo, PEDIDO_PRECIO_ENVIO, PEDIDO_PROPINA, rep.repartidor_codigo, p.pedido_codigo
	FROM [gd_esquema].[Maestra] 
	JOIN [APROBANDO].[usuario] u ON REPARTIDOR_DNI = u.dni
	JOIN [APROBANDO].[repartidor] rep ON rep.usuario_codigo = u.usuario_codigo
	JOIN [APROBANDO].[pedido] p ON PEDIDO_NRO = p.nro_pedido
	JOIN [APROBANDO].[provincia] prov on prov.provincia = DIRECCION_USUARIO_PROVINCIA 
	JOIN [APROBANDO].[localidad] l ON l.localidad = DIRECCION_USUARIO_LOCALIDAD and l.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[direccion] d ON d.direccion = DIRECCION_USUARIO_DIRECCION AND d.localidad_codigo = l.localidad_codigo
	WHERE DIRECCION_USUARIO_DIRECCION IS NOT NULL AND REPARTIDOR_DNI IS NOT NULL AND PEDIDO_NRO IS NOT NULL

	---- reclamo
	
	INSERT INTO [APROBANDO].[reclamo] (nro_reclamo, usuario, pedido_codigo, tipo_de_reclamo, operador_codigo, cupon,
	descripcion, fecha_reclamo, fecha_solucion, calificacion, solucion)
	SELECT DISTINCT RECLAMO_NRO, u.usuario_codigo, p.pedido_codigo, tr.tipo_reclamo_codigo, op.operador_codigo,
	c.cupon_codigo, RECLAMO_DESCRIPCION, RECLAMO_FECHA, RECLAMO_FECHA_SOLUCION, RECLAMO_CALIFICACION, RECLAMO_SOLUCION
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u ON USUARIO_DNI = u.dni
	JOIN [APROBANDO].[pedido] p ON PEDIDO_NRO = p.nro_pedido
	JOIN [APROBANDO].[tipo_de_reclamo] tr ON RECLAMO_TIPO = tr.tipo_de_reclamo
	JOIN [APROBANDO].[usuario] o ON OPERADOR_RECLAMO_DNI = o.dni
	JOIN [APROBANDO].[operador] op ON op.usuario_codigo = o.usuario_codigo
	LEFT JOIN [APROBANDO].[cupon] c ON Maestra.CUPON_RECLAMO_NRO= c.cupon_nro 
	WHERE RECLAMO_NRO IS NOT NULL AND USUARIO_DNI IS NOT NULL AND PEDIDO_NRO IS NOT NULL AND RECLAMO_TIPO IS NOT NULL AND 
	OPERADOR_RECLAMO_DNI IS NOT NULL

	-- estado de reclamo

	INSERT INTO [APROBANDO].[estado_de_reclamo] (reclamo_codigo, tipo_estado, fecha_estado)
	SELECT DISTINCT r.reclamo_codigo, tr.tipo_estado_codigo, RECLAMO_FECHA
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[reclamo] r ON RECLAMO_NRO = r.nro_reclamo
	LEFT JOIN [APROBANDO].[tipo_estado_reclamo] tr ON RECLAMO_ESTADO = tr.tipo_estado
	WHERE RECLAMO_NRO IS NOT NULL AND RECLAMO_FECHA IS NOT NULL

	

	
END
GO

EXEC [APROBANDO].[MIGRAR]
GO	

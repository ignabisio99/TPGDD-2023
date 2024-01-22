USE [GD1C2023]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'APROBANDO')
	EXEC('CREATE SCHEMA APROBANDO')
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='DROP_TABLES_BI')
	EXEC('CREATE PROCEDURE [APROBANDO].[DROP_TABLES_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[DROP_TABLES_BI]
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
	
	EXEC sp_MSforeachtable 'DROP TABLE ?', @whereand ='AND schema_name(schema_id) = ''APROBANDO'' AND o.name LIKE ''BI_%'''
END
GO

EXEC [APROBANDO].[DROP_TABLES_BI]
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_TABLES_BI')
   EXEC('CREATE PROCEDURE [APROBANDO].[CREATE_TABLES_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[CREATE_TABLES_BI] 
AS 
BEGIN

CREATE TABLE [APROBANDO].[BI_tiempo] (
	fecha INTEGER IDENTITY(1,1) PRIMARY KEY,
	anio NVARCHAR(4),
	mes NVARCHAR(2)
	)

CREATE TABLE [APROBANDO].[BI_provincia] (
	provincia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	provincia NVARCHAR(255)
	)

CREATE TABLE [APROBANDO].[BI_localidad] (
	localidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	localidad NVARCHAR(255),
	provincia_codigo INTEGER REFERENCES [APROBANDO].[BI_provincia]
	)

CREATE TABLE [APROBANDO].[BI_tipo_local] (
	tipo_local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_local NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_local] (
	local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(255),
	tipo_local_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_local],
	localidad_codigo INTEGER REFERENCES [APROBANDO].[BI_localidad]
	)

CREATE TABLE [APROBANDO].[BI_categoria] (
	categoria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	categoria NVARCHAR(50),
	tipo_local_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_local]
	)

CREATE TABLE [APROBANDO].[BI_rango_etario] (
	rango_id INTEGER IDENTITY (1,1) PRIMARY KEY,
	rango_menor INT,
	rango_mayor INT
	)

CREATE TABLE [APROBANDO].[BI_tipo_movilidad] (
	movilidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	movilidad NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_estado_mensajeria] (
	tipo_estado_mensajeria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_estado NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_paquete] (
	tipo_paquete_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	ancho_max DECIMAL(18,2),
	largo_max DECIMAL(18,2),
	alto_max DECIMAL(18,2),
	peso_max DECIMAL(18,2),
	precio DECIMAL(18,2),
	tipo_paquete NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_de_reclamo] (
	tipo_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_de_reclamo NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_estado_reclamo] (
	tipo_estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_estado NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_dia] (
	dia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	dia NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_medio_pago] (
	medio_pago_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_medio_pago NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_estado_pedido] (
	t_estado_pedido_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_estado_pedido NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_rango_horario] (
	rango_id INTEGER IDENTITY(1,1) PRIMARY KEY,
	hora_inicial TIME,
	hora_final TIME
	)

-- Hechos:

CREATE TABLE [APROBANDO].[BI_hecho_pedido](
	hecho_pedido_codigo INTEGER IDENTITY(1,1),
	tipo_estado_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_estado_pedido],
	dia_codigo INTEGER REFERENCES [APROBANDO].[BI_dia],    
	rango_horario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_horario],
	local_codigo INTEGER REFERENCES [APROBANDO].[BI_local],
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	medio_pago_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_medio_pago],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	localidad INTEGER REFERENCES [APROBANDO].[BI_localidad],
	tipo_movilidad INTEGER REFERENCES [APROBANDO].[BI_tipo_movilidad],
	monto_total DECIMAL(18,2),
	monto_envio DECIMAL(18,2),
	calificacion_promedio DECIMAL(18,0),
	monto_cupones DECIMAL(18,2),
	cantidad DECIMAL(18,0),
	tiempo_entrega_promedio DECIMAL(18,2),
	PRIMARY KEY(hecho_pedido_codigo, tipo_estado_codigo, dia_codigo, rango_horario_codigo, local_codigo, fecha, medio_pago_codigo, rango_etario_codigo, localidad, tipo_movilidad)
	)


CREATE TABLE [APROBANDO].[BI_hecho_reclamo](
	hecho_reclamo_codigo INTEGER IDENTITY(1,1),
	dia_codigo INTEGER REFERENCES [APROBANDO].[BI_dia],
	rango_horario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_horario],
	local_codigo INTEGER REFERENCES [APROBANDO].[BI_local],
	tipo_reclamo_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_de_reclamo],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	tipo_estado_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_estado_pedido],
	tiempo_resolucion INTEGER,
	monto_en_cupon DECIMAL(18,2),
	cantidad DECIMAL(18,2),
	PRIMARY KEY(hecho_reclamo_codigo, dia_codigo, rango_horario_codigo, local_codigo, tipo_reclamo_codigo, rango_etario_codigo, fecha, tipo_estado_codigo)
	)


CREATE TABLE [APROBANDO].[BI_hecho_envio_mensajeria](
	hecho_envio_mensajeria_codigo INTEGER IDENTITY(1,1),
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	rango_horario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_horario],
	dia_codigo INTEGER REFERENCES [APROBANDO].[BI_dia],
	tipo_movilidad_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_movilidad],
	localidad_codigo INTEGER REFERENCES [APROBANDO].[BI_localidad],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	tipo_paquete_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_paquete],
	tipo_estado_msj_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_estado_mensajeria],
	medio_pago_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_medio_pago],
	monto DECIMAL(18,2),
	valor_asegurado DECIMAL(18,2),
	tiempo_entrega INT,
	cantidad DECIMAL (18,0),
	PRIMARY KEY(hecho_envio_mensajeria_codigo, fecha, rango_horario_codigo, dia_codigo, tipo_movilidad_codigo, localidad_codigo, rango_etario_codigo,
	 tipo_paquete_codigo, tipo_estado_msj_codigo, medio_pago_codigo)
	)

END
GO

EXEC [APROBANDO].[CREATE_TABLES_BI]
GO


IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='MIGRAR_BI')
	EXEC('CREATE PROCEDURE [APROBANDO].[MIGRAR_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[MIGRAR_BI]
AS
BEGIN

	--DIMESIONES:

	-- BI_tiempo

	INSERT INTO [APROBANDO].[BI_tiempo] (anio, mes)
	(
	SELECT DISTINCT YEAR(fecha_pedido), MONTH(fecha_pedido)
	FROM [APROBANDO].[pedido]
	UNION
	SELECT DISTINCT YEAR(fecha_reclamo), MONTH(fecha_reclamo)
	FROM [APROBANDO].[reclamo]
	UNION 
	SELECT DISTINCT YEAR(fecha_envio_msj), MONTH(fecha_envio_msj)
	FROM [APROBANDO].[envio_mensajeria]
	)

	--BI_provincia

	INSERT INTO [APROBANDO].[BI_provincia] (provincia)
	(select provincia from [APROBANDO].[provincia])
	
	--BI_localidad

	INSERT INTO [APROBANDO].[BI_localidad] (localidad, provincia_codigo)
	(select loc.localidad, biprov.provincia_codigo from [APROBANDO].[localidad] loc
	JOIN [APROBANDO].[provincia] prov on loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia)

	--BI_tipo_movilidad
	
	INSERT INTO [APROBANDO].[BI_tipo_movilidad] (movilidad)
	(select movilidad from [APROBANDO].[tipo_movilidad]) 


	--BI_tipo_local

	INSERT INTO [APROBANDO].[BI_tipo_local] (tipo_local)
	(select tipo_local from [APROBANDO].[tipo_local])

	--BI_tipo_estado_mensajeria

	INSERT INTO [APROBANDO].[BI_tipo_estado_mensajeria] (tipo_estado)
	(select tipo_estado from [APROBANDO].[tipo_estado_mensajeria])

	--BI_tipo_paquete

	INSERT INTO [APROBANDO].[BI_tipo_paquete] (ancho_max,largo_max,alto_max,peso_max,precio,tipo_paquete)
	(select ancho_max,largo_max,alto_max,peso_max,precio,tipo_paquete from [APROBANDO].[tipo_paquete])

	--BI_tipo_de_reclamo

	INSERT INTO [APROBANDO].[BI_tipo_de_reclamo] (tipo_de_reclamo)
	(select t.tipo_de_reclamo from [APROBANDO].[tipo_de_reclamo] t)

	--BI_tipo_estado_reclamo

	INSERT INTO [APROBANDO].[BI_tipo_estado_reclamo] (tipo_estado)
	(select t.tipo_estado from [APROBANDO].[tipo_estado_reclamo] t)

	--BI_tipo_estado_pedido

	INSERT INTO [APROBANDO].[BI_tipo_estado_pedido] (tipo_estado_pedido)
	(select t.tipo_estado_pedido from [APROBANDO].[tipo_estado_pedido] t)

	--BI_dia

	INSERT INTO [APROBANDO].[BI_dia] (dia)
	(select d.dia from [APROBANDO].[dia] d)

	--BI_tipo_medio_pago

	INSERT INTO [APROBANDO].[BI_tipo_medio_pago] (tipo_medio_pago)
	(select t.tipo_medio_pago from [APROBANDO].[tipo_medio_pago] t)

	--BI_categoria (va a estar en null la categoria, no existe en la tabla maestra => no existe en las tablas de la entrega pasada)

	INSERT INTO [APROBANDO].[BI_categoria] (categoria,tipo_local_codigo)
	(select c.categoria,bitip.tipo_local_codigo from [APROBANDO].[categoria] c
	JOIN [APROBANDO].[tipo_local] t on t.tipo_local_codigo = c.tipo_local_codigo
	JOIN [APROBANDO].[BI_tipo_local] bitip on t.tipo_local = bitip.tipo_local)

	--BI_rango_etario

	INSERT INTO [APROBANDO].[BI_rango_etario] (rango_menor,rango_mayor)
	values (0,25),(25,35),(35,55),(55,150)

	--BI_local

	INSERT INTO [APROBANDO].[BI_local](nombre,tipo_local_codigo,localidad_codigo)
	(select l.nombre,bitl.tipo_local_codigo,biloc.localidad_codigo from [APROBANDO].[local] l
	JOIN [APROBANDO].[categoria] c on l.categoria = c.categoria_codigo
	JOIN [APROBANDO].[tipo_local] tl on tl.tipo_local_codigo = c.tipo_local_codigo
	JOIN [APROBANDO].[BI_tipo_local] bitl on bitl.tipo_local = tl.tipo_local
	JOIN [APROBANDO].[direccion] dir on dir.direccion_codigo = l.direccion
	JOIN [APROBANDO].[localidad] loc on loc.localidad_codigo = dir.localidad_codigo
	JOIN [APROBANDO].[provincia] prov on loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia
	JOIN [APROBANDO].[BI_localidad] biloc on loc.localidad = biloc.localidad and biloc.provincia_codigo = biprov.provincia_codigo
	)


	--BI_rango_horario

	 INSERT INTO [APROBANDO].[BI_rango_horario] (hora_inicial,hora_final) 
	 VALUES ('08:00:00','10:00:00'),
	 ('10:00:00','12:00:00'),
	 ('12:00:00','14:00:00'),
	 ('14:00:00','16:00:00'),
	 ('16:00:00','18:00:00'),
	 ('18:00:00','20:00:00'),
	 ('20:00:00','22:00:00'),
	 ('22:00:00','23:59:59')

	 --HECHOS 
	

	--hecho pedido 
	
	INSERT INTO [APROBANDO].[BI_hecho_pedido] 
	(tipo_estado_codigo,dia_codigo,rango_horario_codigo,
	local_codigo,fecha,medio_pago_codigo,rango_etario_codigo
	,localidad,tipo_movilidad,
	monto_total,monto_envio,
	calificacion_promedio,
	monto_cupones,
	cantidad,tiempo_entrega_promedio)

	(select bite.t_estado_pedido_codigo, bidia.dia_codigo, birh.rango_id,
	bil.local_codigo,ti.fecha,bitmp.medio_pago_codigo, bire.rango_id
	,biloc.localidad_codigo,bitm.movilidad_codigo,
	sum(p.total),sum(en.precio), 
	avg(p.calificacion),
	sum(p.total_cupones),
	count(*), avg(DATEDIFF(minute, p.fecha_pedido, p.fecha_entrga))

	from [APROBANDO].[pedido] p 
	JOIN [APROBANDO].[estado_pedido] e on e.nro_pedido = p.pedido_codigo
	JOIN [APROBANDO].[tipo_estado_pedido] te on e.tipo_estado = te.t_estado_pedido_codigo
	JOIN [APROBANDO].[BI_tipo_estado_pedido] bite on bite.tipo_estado_pedido = te.tipo_estado_pedido
	JOIN [APROBANDO].[BI_dia] bidia on bidia.dia = 
		case DATEPART(WEEKDAY,p.fecha_pedido)
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Lunes'
			WHEN 3 THEN 'Martes'
			WHEN 4 THEN 'Miercoles'
			WHEN 5 THEN 'Jueves'
			WHEN 6 THEN 'Viernes'
			WHEN 7 THEN 'Sabado'  
		end
	JOIN [APROBANDO].[BI_rango_horario] birh on
	convert(time,p.fecha_pedido) <= birh.hora_final and 
	convert(time,p.fecha_pedido) > birh.hora_inicial
	JOIN [APROBANDO].[local] l on l.local_codigo = p.local_codigo
	JOIN [APROBANDO].[BI_local] bil on l.nombre = bil.nombre
	JOIN [APROBANDO].[BI_tiempo] ti on ti.anio = YEAR(p.fecha_pedido) and ti.mes = MONTH(p.fecha_pedido)
	JOIN [APROBANDO].[medio_de_pago] mp on mp.medio_pago_codigo = p.medio_de_pago
	JOIN [APROBANDO].[tipo_medio_pago] tmp on tmp.t_medio_pago_codigo = mp.tipo_medio_pago
	JOIN [APROBANDO].[BI_tipo_medio_pago] bitmp on bitmp.tipo_medio_pago = tmp.tipo_medio_pago
	JOIN [APROBANDO].[usuario] u on u.usuario_codigo = p.usuario_codigo
	JOIN [APROBANDO].[BI_rango_etario] bire on 
	DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) > bire.rango_menor 
	and DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) <= bire.rango_mayor
	JOIN [APROBANDO].[envio] en on en.nro_pedido = p.nro_pedido
	JOIN [APROBANDO].[direccion] dir on dir.direccion_codigo = en.direccion
	JOIN [APROBANDO].[localidad] loc on loc.localidad_codigo = dir.localidad_codigo
	JOIN [APROBANDO].[provincia] prov on prov.provincia_codigo = loc.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia
	JOIN [APROBANDO].[BI_localidad] biloc on  biloc.localidad = loc.localidad and biloc.provincia_codigo = biprov.provincia_codigo
	JOIN [APROBANDO].[repartidor] rep on rep.repartidor_codigo = en.repartidor_codigo
	JOIN [APROBANDO].[tipo_movilidad] tm on tm.movilidad_codigo = rep.movilidad
	JOIN [APROBANDO].[BI_tipo_movilidad] bitm on bitm.movilidad = tm.movilidad
	GROUP BY bite.t_estado_pedido_codigo, bidia.dia_codigo, birh.rango_id,
	bil.local_codigo,ti.fecha,bitmp.medio_pago_codigo, bire.rango_id,
	biloc.localidad_codigo,bitm.movilidad_codigo
	)

	--hecho envio_mensajeria

	INSERT INTO [APROBANDO].[BI_hecho_envio_mensajeria]
	(fecha,rango_horario_codigo,dia_codigo,tipo_movilidad_codigo,
	localidad_codigo,rango_etario_codigo,tipo_paquete_codigo,tipo_estado_msj_codigo,medio_pago_codigo,
	monto,valor_asegurado, tiempo_entrega, cantidad)

	(select ti.fecha, birh.rango_id, bidia.dia_codigo, bitim.movilidad_codigo,
			biloc.localidad_codigo, bire.rango_id, bitp.tipo_paquete_codigo,bitem.tipo_estado_mensajeria_codigo,bitmp.medio_pago_codigo, 
			sum(e.total),sum(e.valor_asegurado),avg(DATEDIFF(minute, e.fecha_envio_msj,e.fecha_hora_entrega)),count(*)
	
	from [APROBANDO].[envio_mensajeria] e 
	JOIN [APROBANDO].[BI_tiempo] ti on ti.anio = YEAR(e.fecha_envio_msj) and ti.mes = MONTH(e.fecha_envio_msj)
	JOIN [APROBANDO].[BI_rango_horario] birh on
	convert(time,e.fecha_envio_msj) < birh.hora_final and 
	convert(time,e.fecha_envio_msj) >= birh.hora_inicial
	JOIN [APROBANDO].[BI_dia] bidia on bidia.dia = 
		case DATEPART(WEEKDAY,e.fecha_envio_msj)
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Lunes'
			WHEN 3 THEN 'Martes'
			WHEN 4 THEN 'Miercoles'
			WHEN 5 THEN 'Jueves'
			WHEN 6 THEN 'Viernes'
			WHEN 7 THEN 'Sabado'  
		end
	JOIN [APROBANDO].[repartidor] rep on rep.repartidor_codigo = e.repartidor_codigo
	JOIN [APROBANDO].[tipo_movilidad] tim on tim.movilidad_codigo = rep.movilidad
	JOIN [APROBANDO].[BI_tipo_movilidad] bitim on bitim.movilidad = tim.movilidad
	JOIN [APROBANDO].[direccion] dir on dir.direccion_codigo = e.direccion_origen
	JOIN [APROBANDO].[localidad] loc on loc.localidad_codigo = dir.localidad_codigo
	JOIN [APROBANDO].[provincia] prov on prov.provincia_codigo = loc.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia
	JOIN [APROBANDO].[BI_localidad] biloc on  biloc.localidad = loc.localidad and biloc.provincia_codigo = biprov.provincia_codigo
	JOIN [APROBANDO].[usuario] u on u.usuario_codigo = e.usuario
	JOIN [APROBANDO].[BI_rango_etario] bire on 
	DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) > bire.rango_menor 
	and DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) <= bire.rango_mayor
	JOIN [APROBANDO].[tipo_paquete] tp on tp.tipo_paquete_codigo = e.tipo_paquete_codigo
	JOIN [APROBANDO].[BI_tipo_paquete] bitp on bitp.tipo_paquete = tp.tipo_paquete
	JOIN [APROBANDO].[estado_mensajeria] em on em.envio_msj_codigo = e.envio_msj_codigo
	JOIN [APROBANDO].[tipo_estado_mensajeria] tem on tem.tipo_estado_mensajeria_codigo = em.tipo_estado
	JOIN [APROBANDO].[BI_tipo_estado_mensajeria] bitem on bitem.tipo_estado = tem.tipo_estado
	JOIN [APROBANDO].[medio_de_pago] mp on mp.medio_pago_codigo = e.medio_de_pago_codigo
	JOIN [APROBANDO].[tipo_medio_pago] tmp on tmp.t_medio_pago_codigo = mp.tipo_medio_pago
	JOIN [APROBANDO].[BI_tipo_medio_pago] bitmp on bitmp.tipo_medio_pago = tmp.tipo_medio_pago
	group by ti.fecha, birh.rango_id, bidia.dia_codigo, bitim.movilidad_codigo,
			 biloc.localidad_codigo, bire.rango_id, bitp.tipo_paquete_codigo,bitem.tipo_estado_mensajeria_codigo,bitmp.medio_pago_codigo
	)


	--hecho reclamo

	INSERT INTO [APROBANDO].[BI_hecho_reclamo] 
	(dia_codigo,rango_horario_codigo,local_codigo,tipo_reclamo_codigo,
	rango_etario_codigo,fecha,tipo_estado_codigo,
	tiempo_resolucion,monto_en_cupon,cantidad)

	(select bidia.dia_codigo, birh.rango_id, l.local_codigo,bitr.tipo_reclamo_codigo,
	bire.rango_id,ti.fecha, biter.tipo_estado_codigo,
	avg(DATEDIFF(minute, r.fecha_reclamo, r.fecha_solucion)),sum(c.monto),count(*)
	 
	from [APROBANDO].[reclamo] r
	JOIN [APROBANDO].[BI_dia] bidia on bidia.dia = 
		case DATEPART(WEEKDAY,r.fecha_reclamo)
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Lunes'
			WHEN 3 THEN 'Martes'
			WHEN 4 THEN 'Miercoles'
			WHEN 5 THEN 'Jueves'
			WHEN 6 THEN 'Viernes'
			WHEN 7 THEN 'Sabado'  
		end
	JOIN [APROBANDO].[BI_rango_horario] birh on
	convert(time,r.fecha_reclamo) < birh.hora_final and 
	convert(time,r.fecha_reclamo) >= birh.hora_inicial
	JOIN [APROBANDO].[pedido] p on r.pedido_codigo = p.pedido_codigo
	JOIN [APROBANDO].[local] l on l.local_codigo = p.local_codigo
	JOIN [APROBANDO].[BI_local] bil on l.nombre = bil.nombre
	JOIN [APROBANDO].[tipo_de_reclamo] tr on tr.tipo_reclamo_codigo = r.tipo_de_reclamo
	JOIN [APROBANDO].[BI_tipo_de_reclamo] bitr on bitr.tipo_de_reclamo = tr.tipo_de_reclamo
	JOIN [APROBANDO].[operador] o on o.operador_codigo = r.operador_codigo
	JOIN [APROBANDO].[usuario] u on u.usuario_codigo = o.usuario_codigo
	JOIN [APROBANDO].[BI_rango_etario] bire on 
	DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) > bire.rango_menor 
	and DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) <= bire.rango_mayor
	JOIN [APROBANDO].[BI_tiempo] ti on ti.anio = YEAR(r.fecha_reclamo) and ti.mes = MONTH(r.fecha_reclamo)
	JOIN [APROBANDO].[estado_de_reclamo] er on er.reclamo_codigo = r.reclamo_codigo
	JOIN [APROBANDO].[tipo_estado_reclamo] ter on ter.tipo_estado_codigo = er.tipo_estado
	JOIN [APROBANDO].[BI_tipo_estado_reclamo] biter on biter.tipo_estado = ter.tipo_estado
	JOIN [APROBANDO].[cupon] c on c.cupon_codigo = r.cupon
	group by bidia.dia_codigo, birh.rango_id, l.local_codigo,bitr.tipo_reclamo_codigo,
	bire.rango_id,ti.fecha, biter.tipo_estado_codigo
	)

END
GO

EXEC [APROBANDO].[MIGRAR_BI]
GO


--VISTAS

--1 
/* Día de la semana y franja horaria con mayor cantidad de pedidos según la
localidad y categoría del local, para cada mes de cada año */

--lo hago con tipo de local xq categoria no hay



IF EXISTS(SELECT 1 FROM sys.views WHERE name='CANTIDAD_PEDIDOS' AND type='v')
	DROP VIEW [APROBANDO].[CANTIDAD_PEDIDOS]
GO

CREATE VIEW [APROBANDO].[CANTIDAD_PEDIDOS] AS
SELECT *
FROM (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY t.mes, t.anio, l.localidad, tl.tipo_local
                           ORDER BY COUNT(*) DESC) AS rn,
        d.dia,
        r.hora_inicial,
		r.hora_final,
        l.localidad,
        tl.tipo_local,
        t.mes,
        t.anio,
        COUNT(*) AS 'cantidad pedidos'
    FROM [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_rango_horario] r on r.rango_id = p.rango_horario_codigo 
	JOIN [APROBANDO].[BI_dia] d on d.dia_codigo = p.dia_codigo
	JOIN [APROBANDO].[BI_tiempo] t on t.fecha = p.fecha
    JOIN [APROBANDO].[BI_local] lo ON p.local_codigo = lo.local_codigo
	JOIN [APROBANDO].[BI_tipo_local] tl ON lo.tipo_local_codigo = tl.tipo_local_codigo
	JOIN [APROBANDO].[BI_localidad] l ON l.localidad_codigo= lo.localidad_codigo
    GROUP BY t.anio,t.mes, d.dia,r.hora_inicial,r.hora_final, l.localidad, tl.tipo_local
) AS subquery
WHERE rn = 1;
GO

--2
/* Monto total no cobrado por cada local en función de los pedidos
cancelados según el día de la semana y la franja horaria (cuentan como
pedidos cancelados tanto los que cancela el usuario como el local).
*/


IF EXISTS(SELECT 1 FROM sys.views WHERE name='MONTO_NO_COBRADO' AND type='v')
	DROP VIEW [APROBANDO].[MONTO_NO_COBRADO]
GO

CREATE VIEW [APROBANDO].[MONTO_NO_COBRADO] AS

	(SELECT SUM(p.monto_total) as 'monto no cobrado',l.nombre,d.dia,rh.hora_inicial,rh.hora_final 
	from [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_local] l on l.local_codigo = p.local_codigo
	JOIN [APROBANDO].[BI_dia] d on d.dia_codigo = p.dia_codigo
	JOIN [APROBANDO].[BI_rango_horario] rh on rh.rango_id = p.rango_horario_codigo
	WHERE p.tipo_estado_codigo= 2
	GROUP BY l.nombre, d.dia, rh.hora_inicial,rh.hora_final)
GO

--3
/* 
Valor promedio mensual que tienen los envíos de pedidos en cada
localidad.	
*/


IF EXISTS(SELECT 1 FROM sys.views WHERE name='VALOR_PROMEDIO_MENSUAL' AND type='v')
	DROP VIEW [APROBANDO].[VALOR_PROMEDIO_MENSUAL]
GO

CREATE VIEW [APROBANDO].[VALOR_PROMEDIO_MENSUAL] AS
	
	(SELECT AVG(p.monto_envio) as 'monto envios' ,t.mes,t.anio ,l.localidad 
	from [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_tiempo] t on p.fecha = t.fecha
	JOIN [APROBANDO].[BI_localidad] l on l.localidad_codigo = p.localidad
	GROUP BY t.mes,t.anio, l.localidad
	)
GO

--4 

/* Desvío promedio en tiempo de entrega según el tipo de movilidad, el día
de la semana y la franja horaria.
El desvío debe calcularse en minutos y representa la diferencia entre la
fecha/hora en que se realizó el pedido y la fecha/hora que se entregó en
comparación con los minutos de tiempo estimados.
Este indicador debe tener en cuenta todos los envíos, es decir, sumar tanto
los envíos de pedidos como los de mensajería.
 */


IF EXISTS(SELECT 1 FROM sys.views WHERE name='DESVIO_TIEMPO_ENTREGA' AND type='v')
	DROP VIEW [APROBANDO].[DESVIO_TIEMPO_ENTREGA]
GO

CREATE VIEW [APROBANDO].[DESVIO_TIEMPO_ENTREGA] AS 
 SELECT tipo_movilidad, dia_semana, rango_horario_inicial, rango_horario_final, AVG(tiempo_entrega) AS desvio_promedio_en_min 
 from (
	select tm.movilidad as tipo_movilidad, d.dia as dia_semana, rh.hora_inicial as rango_horario_inicial,
			rh.hora_final as rango_horario_final, p.tiempo_entrega_promedio as tiempo_entrega
	from [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_tipo_movilidad] tm on tm.movilidad_codigo = p.tipo_movilidad
	JOIN [APROBANDO].[BI_dia] d on d.dia_codigo = p.dia_codigo
	JOIN [APROBANDO].[BI_rango_horario] rh on rh.rango_id = p.rango_horario_codigo
	UNION ALL
	select tm.movilidad as tipo_movilidad, d.dia as dia_semana, rh.hora_inicial as rango_horario_inicial,
			rh.hora_final as rango_horario_final, em.tiempo_entrega as tiempo_entrega
	FROM [APROBANDO].[BI_hecho_envio_mensajeria] em
	JOIN [APROBANDO].[BI_tipo_movilidad] tm on tm.movilidad_codigo = em.tipo_movilidad_codigo
	JOIN [APROBANDO].[BI_dia] d on d.dia_codigo = em.dia_codigo
	JOIN [APROBANDO].[BI_rango_horario] rh on rh.rango_id = em.rango_horario_codigo
 ) AS subquery
 GROUP BY tipo_movilidad, dia_semana, rango_horario_inicial, rango_horario_final 
GO

--5
/* Monto total de los cupones utilizados por mes en función del rango etario
de los usuarios. */


IF EXISTS(SELECT 1 FROM sys.views WHERE name='MONTO_TOTAL_CUPONES' AND type='v')
	DROP VIEW [APROBANDO].[MONTO_TOTAL_CUPONES]
GO

CREATE VIEW [APROBANDO].[MONTO_TOTAL_CUPONES] AS 
	SELECT SUM(p.monto_cupones) as 'total cupones',t.mes,t.anio,re.rango_menor,re.rango_mayor 
	FROM [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_tiempo] t on p.fecha = t.fecha
	JOIN [APROBANDO].[BI_rango_etario] re on re.rango_id = p.rango_etario_codigo
	GROUP BY t.mes,t.anio,re.rango_menor,re.rango_mayor
GO

--6 

/* 
 Promedio de calificación mensual por local
*/

IF EXISTS(SELECT 1 FROM sys.views WHERE name='CALIFICACION_MENSUAL' AND type='v')
	DROP VIEW [APROBANDO].[CALIFICACION_MENSUAL]
GO

CREATE VIEW [APROBANDO].[CALIFICACION_MENSUAL] as 
	SELECT AVG(p.calificacion_promedio) as 'promedio calificacion',t.mes,t.anio, l.nombre FROM [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_tiempo] t on p.fecha = t.fecha
	JOIN [APROBANDO].[BI_local] l on p.local_codigo = l.local_codigo 
	GROUP BY t.mes,t.anio,l.nombre
GO

--7 

/* Porcentaje de pedidos y mensajería entregados mensualmente según el
rango etario de los repartidores y la localidad.
Este indicador se debe tener en cuenta y sumar tanto los envíos de pedidos
como los de mensajería.
El porcentaje se calcula en función del total general de pedidos y envíos
mensuales entregados. */


IF EXISTS(SELECT 1 FROM sys.views WHERE name='PORCENTAJES_PEDIDOS_Y_MENSAJERIA' AND type='v')
	DROP VIEW [APROBANDO].[PORCENTAJES_PEDIDOS_Y_MENSAJERIA]
GO

CREATE VIEW [APROBANDO].[PORCENTAJES_PEDIDOS_Y_MENSAJERIA] AS
SELECT rango_etario_menor,rango_etario_mayor, localidad, mes, anio, 
    SUM(cantidad * 100.0) / SUM(cantidad) OVER (PARTITION BY mes,anio) AS porcentaje_entregados
FROM (
	SELECT re.rango_menor as rango_etario_menor ,re.rango_mayor as rango_etario_mayor
	,lo.localidad as localidad,ti.mes as mes ,ti.anio as anio, p.cantidad as cantidad 
	FROM [APROBANDO].[BI_hecho_pedido] p
	JOIN [APROBANDO].[BI_rango_etario] re on p.rango_etario_codigo = re.rango_id
	JOIN [APROBANDO].[BI_localidad] lo on p.localidad = lo.localidad_codigo
	JOIN [APROBANDO].[BI_tiempo] ti on ti.fecha = p.fecha
	UNION ALL
	SELECT re.rango_menor as rango_etario_menor ,re.rango_mayor as rango_etario_mayor
	,lo.localidad as localidad,ti.mes as mes ,ti.anio as anio, em.cantidad as cantidad
	FROM [APROBANDO].[BI_hecho_envio_mensajeria] em
	JOIN [APROBANDO].[BI_rango_etario] re on em.rango_etario_codigo = re.rango_id
	JOIN [APROBANDO].[BI_localidad] lo on em.localidad_codigo = lo.localidad_codigo
	JOIN [APROBANDO].[BI_tiempo] ti on ti.fecha = em.fecha
)AS subquery
GROUP BY rango_etario_menor,rango_etario_mayor, localidad, mes, anio, cantidad
GO

--8 

/* Promedio mensual del valor asegurado (valor declarado por el usuario) de
los paquetes enviados a través del servicio de mensajería en función del
tipo de paquete. */


IF EXISTS(SELECT 1 FROM sys.views WHERE name='PROMEDIO_VALOR_ASEGURADO' AND type='v')
	DROP VIEW [APROBANDO].[PROMEDIO_VALOR_ASEGURADO]
GO

CREATE VIEW [APROBANDO].[PROMEDIO_VALOR_ASEGURADO] AS 
SELECT AVG(hm.valor_asegurado) as 'promedio valor asegurado',t.mes,t.anio,tp.tipo_paquete 
FROM [APROBANDO].[BI_hecho_envio_mensajeria] hm
JOIN [APROBANDO].[BI_tipo_paquete] tp on hm.tipo_paquete_codigo = tp.tipo_paquete_codigo
JOIN [APROBANDO].[BI_tiempo] t on hm.fecha = t.fecha
GROUP BY tp.tipo_paquete, t.anio,t.mes
GO
--9

/* Cantidad de reclamos mensuales recibidos por cada local en función del
día de la semana y rango horario. */

 IF EXISTS(SELECT 1 FROM sys.views WHERE name='CANTIDAD_RECLAMOS_MENSUALES' AND type='v')
	DROP VIEW [APROBANDO].[CANTIDAD_RECLAMOS_MENSUALES]
GO

CREATE VIEW [APROBANDO].[CANTIDAD_RECLAMOS_MENSUALES] AS 
SELECT SUM(r.cantidad) as 'cantidad reclamos',d.dia,rh.hora_inicial,rh.hora_final,t.mes,t.anio 
FROM [APROBANDO].[BI_hecho_reclamo] r 
JOIN [APROBANDO].[BI_dia] d on d.dia_codigo = r.dia_codigo
JOIN [APROBANDO].[BI_rango_horario] rh on rh.rango_id = r.rango_horario_codigo
JOIN [APROBANDO].[BI_tiempo] t on t.fecha = r.fecha
GROUP BY d.dia,rh.hora_inicial,rh.hora_final,t.mes,t.anio
GO


--10 

/* Tiempo promedio de resolución de reclamos mensual según cada tipo de
reclamo y rango etario de los operadores.
El tiempo de resolución debe calcularse en minutos y representa la
diferencia entre la fecha/hora en que se realizó el reclamo y la fecha/hora
que se resolvió. */ 

IF EXISTS(SELECT 1 FROM sys.views WHERE name='TIEMPO_PROMEDIO_RECLAMOS' AND type='v')
	DROP VIEW [APROBANDO].[TIEMPO_PROMEDIO_RECLAMOS]
GO

CREATE VIEW [APROBANDO].[TIEMPO_PROMEDIO_RECLAMOS] AS 
	SELECT AVG(r.tiempo_resolucion) as 'tiempo resolucion',tr.tipo_de_reclamo,t.mes,t.anio,re.rango_menor,re.rango_mayor 
	FROM [APROBANDO].[BI_hecho_reclamo] r
	JOIN [APROBANDO].[BI_tipo_de_reclamo] tr on r.tipo_reclamo_codigo = tr.tipo_reclamo_codigo
	JOIN [APROBANDO].[BI_tiempo] t on t.fecha = r.fecha
	JOIN [APROBANDO].[BI_rango_etario] re on re.rango_id = r.rango_etario_codigo
	GROUP BY tr.tipo_de_reclamo,t.mes,t.anio,re.rango_menor,re.rango_mayor 
GO

--11 

/*  Monto mensual generado en cupones a partir de reclamos */


IF EXISTS(SELECT 1 FROM sys.views WHERE name='MONTO_CUPONES_RECLAMOS' AND type='v')
	DROP VIEW [APROBANDO].[MONTO_CUPONES_RECLAMOS]
GO

CREATE VIEW [APROBANDO].[MONTO_CUPONES_RECLAMOS] AS
	SELECT SUM(r.monto_en_cupon) as 'monto por cupones',t.mes,t.anio FROM [APROBANDO].[BI_hecho_reclamo] r
	JOIN [APROBANDO].[BI_tiempo] t on t.fecha = r.fecha
	GROUP BY t.mes,t.anio
GO

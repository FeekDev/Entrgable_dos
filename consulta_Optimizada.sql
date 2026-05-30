SELECT c.documento, c.nombre, v.codigo_v, p.id, p.nombre, iv.valor_vta, iv.cantidad, v.valor

FROM venta v

JOIN cliente c ON v.clienteid = c.documento

JOIN vendedor ve ON v.vendedorid = ve.documento

JOIN item_venta iv ON v.codigo_v = iv.codigo_v

JOIN productos p ON iv.codigo_p = p.id

WHERE 

    v.fecha between '2026-01-01' and '2026-12-31'

    AND c.nombre LIKE 'Cliente%'

    AND p.nombre LIKE 'Producto%'
WITH regional_sales AS (
select DISTINCT on (client_id) date_added, full_number, op, office, type, loan  
from (
select microloan.client_id, date_added, substring (microloan.full_number for 4) as op, office.name_short as office, microloan.full_number, credit_product.name, operation.type, microloan.loan_state as loan 
from operation 
LEFT JOIN public.microloan ON operation.loan_id = microloan.id 
LEFT JOIN public.client ON microloan.client_id = client.id 
LEFT JOIN public.credit_product ON microloan.creditproduct_id = credit_product.id 
LEFT JOIN public.office ON operation.office_id = office.id 
WHERE date_added = (
SELECT MAX(date_added) FROM operation WHERE operation.loan_id  = microloan.id and date_added >= '2020-01-01 00:00:00' and date_added <= '2020-01-30 23:59:59') 
GROUP BY date_added, microloan.client_id, office, microloan.full_number, credit_product.name, operation.type, microloan.loan_state ORDER BY microloan.client_id DESC) as t GROUP BY client_id, date_added, full_number, op, office, name, type, loan ORDER BY client_id, max(date_added))
select OP, count(op) as всего, count(CASE WHEN type = 3 and loan = 2 then type END) as новый, count(CASE WHEN type = 1 and loan = 2 then type END) as лонгация_оп, count(CASE WHEN type = 2 and loan = 2 then type END) as лонгация_цо, count(CASE WHEN type = 1 and loan = 3 then type END) as закрыт_оп, count(CASE WHEN type = 2 and loan = 3 then type END) as закрыт_цо, count(CASE WHEN type = 4 and loan = 3 then type END) as закрыт_прощение, count(CASE WHEN type = 3 and loan = 3 then type END) as bad from regional_sales GROUP by OP

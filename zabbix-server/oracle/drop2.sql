begin
  for i in (select 'drop ' || object_type || ' ' || object_name as stmt
                from user_objects
                where object_type in ('VIEW', 'PACKAGE', 'SEQUENCE', 'PROCEDURE', 'FUNCTION', 'INDEX')) loop
    execute immediate i.stmt;
  end loop;
end;
/

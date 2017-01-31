
-- *********************************************************************************   
-- SCOPE DEFINITION v1.0.2
-- *********************************************************************************   
create or replace view custom_Kit_Completness_Scope_LookupTable as 
select appli_id, a.object_id, lkp_type, b.object_name, b.object_type_str, b.object_mangling, b.object_type_ext, b.object_language_name 
from FP_Lookup_Tables a join CDT_OBJECTS b on a.object_id = b.object_id 
order by object_name ASC
/

-- *********************************************************************************   
--BOUNDARY DEFINITION v1.0.2
-- *********************************************************************************   
create or replace view custom_Kit_Completness_Boundary_DelIgnTransac as
select t.appli_id, t.form_id, t.object_id, t.det, t.ftr, t.tf, t.tf_ex, t.isinput, t.user_fp_value, t.user_isinput, t.cal_flags, t.cal_mergeroot_id 
from dss_transaction t 
where t.appli_id in (select appli_id from fp_cms_application) 
and not exists(select 1 from ctt_object_applications oa, fp_cms_application a 
			where t.form_id = oa.object_id 	
			and oa.application_id = a.module_id);
			
create or replace view custom_Kit_Completness_Boundary_DelIgnDataEntity as
select df.appli_id, df.object_id, df.maintable_id, df.det, df.ret, df.ilf, df.ilf_ex, df.isinternal,  df.user_fp_value, df.user_isinternal, df.cal_flags, df.cal_mergeroot_id 
from dss_datafunction df 
where not exists(select 1 from ctt_object_applications oa, fp_cms_application a 
			where df.maintable_id = oa.object_id 
			and oa.application_id = a.module_id)
/

-- *********************************************************************************   			
--Functional Size - Data Entity  v1.0.2
-- *********************************************************************************   
create or replace view custom_Kit_Completness_FunctionalSize_DataEntity as
select cob.object_name as LogicalFile, 
cob.object_fullname as LogicalFileFullname, 
dtf.DET as DET, 
dtf.RET as RET,
case dtf.isinternal when 0 then 'EIF' when 1 then 'ILF' END as DefaultType,
case dtf.user_isinternal when 0 then 'EIF' when 1 then 'ILF' END as OverwriteType,
dtf.ilf_ex as DefaultFPValue,
dtf.user_fp_value as OverwriteFPValue,
case dtf.cal_flags when 0 then 'STD' when 2 then 'Root' when 4 then 'Child' when 4 then 'Child' when 8 then 'Deleted' when 10 then 'Root and Deleted' when 128 then 'Deleted' when 136 then 'Root and Deleted' when 138 then 'Child and Deleted' when 256 then 'Root and Ignored'  when 258 then 'Child and Ignored' END as Status
from dss_datafunction dtf, cdt_objects cob
where dtf.maintable_id = cob.object_id
and dtf.cal_flags in (0,2)
order by 9 ASC
/

-- *********************************************************************************   
--Functional Size - Transaction  v1.0.2		
-- *********************************************************************************   
create or replace view custom_Kit_Completness_FunctionalSize_Transaction as
select cob.object_name as transaction, 
cob.object_fullname as transactionfullname, 
dtr.DET as DET, 
DTR.FTR as FTR,
case DTR.isinput when 0 then 'EI' when 1 then 'EO_EQ' END as DefaultType,
case DTR.isinput when 0 then 'EI' when 1 then 'EO' when 2 then 'EQ' END as OverwriteType,
DTR.tf_ex as DefaultFPValue,
DTR.user_fp_value as OverwriteFPValue,
case DTR.cal_flags when 0 then 'STD' when 2 then 'Root' when 4 then 'Child' when 4 then 'Child' when 8 then 'Deleted' when 10 then 'Root and Deleted' when 128 then 'Deleted' when 136 then 'Root and Deleted' when 138 then 'Child and Deleted' when 256 then 'Root and Ignored'  when 258 then 'Child and Ignored' END as Status
from dss_transaction dtr, cdt_objects cob
where dtr.form_id = cob.object_id
and dtr.cal_mergeroot_id = 0 -- not a sub transaction
and dtr.cal_flags not in (  8, 10, 126, 128,136, 138, 256, 258 ) -- transaction standalone or Root
order by 9 ASC, 2 ASC
/

		
-- *********************************************************************************   
--Functional Size - Detail Grouped Data Entity  v1.0.2		
-- *********************************************************************************   
create or replace view custom_Kit_Completness_FunctionalSize_DetailGroupDataEntity as
select * from (
select dtf.object_id as maintable_id,
cob.object_name as transaction, 
cob.object_fullname as transactionfullname,
dtf.DET as DET, 
dtf.RET as RET,
case dtf.isinternal when 0 then 'EIF' when 1 then 'ILF' END as DefaultType,
case dtf.user_isinternal when 0 then 'EIF' when 1 then 'ILF' END as OverwriteType,
dtf.ilf_ex as DefaultFPValue,
dtf.user_fp_value as OverwriteFPValue,
case dtf.cal_flags when 0 then 'STD' when 2 then 'Root' when 4 then 'Child' when 4 then 'Child' when 8 then 'Deleted' when 10 then 'Root and Deleted' when 128 then 'Deleted' when 136 then 'Root and Deleted' when 138 then 'Child and Deleted' when 256 then 'Root and Ignored'  when 258 then 'Child and Ignored' END as Status,
dtf.cal_mergeroot_id as ParentID
from dss_datafunction dtf, cdt_objects cob
where dtf.maintable_id = cob.object_id
and dtf.cal_mergeroot_id = 0 -- not a sub transaction
and dtf.cal_flags not in (  8, 10, 126, 128,136, 138, 256, 258 ) -- transaction standalone or Root
union all
select dtf.cal_mergeroot_id as form_id,' |-------' || cob.object_name as transaction, 
cob.object_fullname as transactionfullname, 
dtf.DET as DET, 
dtf.RET as RET,
case dtf.isinternal when 0 then 'EIF' when 1 then 'ILF' END as DefaultType,
case dtf.user_isinternal when 0 then 'EIF' when 1 then 'ILF' END as OverwriteType,
dtf.ilf_ex as DefaultFPValue,
dtf.user_fp_value as OverwriteFPValue,
case dtf.cal_flags when 0 then 'STD' when 2 then 'Root' when 4 then 'Child' when 4 then 'Child' when 8 then 'Deleted' when 10 then 'Root and Deleted' when 128 then 'Deleted' when 136 then 'Root and Deleted' when 138 then 'Child and Deleted' when 256 then 'Root and Ignored'  when 258 then 'Child and Ignored' END as Status,
dtf.cal_mergeroot_id as ParentID
from dss_datafunction dtf, cdt_objects cob
where dtf.maintable_id = cob.object_id
and dtf.cal_mergeroot_id > 0 -- not a sub transaction
and dtf.cal_flags not in (  8, 10, 126, 128,136, 138, 256, 258 ) -- transaction standalone or Root
) as result
where Status in ('Root', 'Child')
order by 1 ASC, 10 DESC
/

-- *********************************************************************************   
--Functional Size - Detail Grouped Transaction  v1.0.2
-- *********************************************************************************   
create or replace view custom_Kit_Completness_FunctionalSize_DetailGroupTransaction as
select * from (
select dtr.object_id as form_id,
cob.object_name as transaction, 
cob.object_fullname as transactionfullname, 
dtr.DET as DET, 
DTR.FTR as FTR,
case DTR.isinput when 0 then 'EI' when 1 then 'EO_EQ' END as DefaultType,
case DTR.isinput when 0 then 'EI' when 1 then 'EO' when 2 then 'EQ' END as OverwriteType,
DTR.tf_ex as DefaultFPValue,
DTR.user_fp_value as OverwriteFPValue,
case DTR.cal_flags when 0 then 'STD' when 2 then 'Root' when 4 then 'Child' when 4 then 'Child' when 8 then 'Deleted' when 10 then 'Root and Deleted' when 128 then 'Deleted' when 136 then 'Root and Deleted' when 138 then 'Child and Deleted' when 256 then 'Root and Ignored'  when 258 then 'Child and Ignored' END as Status,
DTR.cal_mergeroot_id as ParentID
from dss_transaction dtr, cdt_objects cob
where dtr.form_id = cob.object_id
and dtr.cal_mergeroot_id = 0 -- not a sub transaction
and dtr.cal_flags not in (  8, 10, 126, 128,136, 138, 256, 258 ) -- transaction standalone or Root
union all
select dtr.cal_mergeroot_id as form_id,' |-------' || cob.object_name as transaction, cob.object_fullname as transactionfullname, dtr.DET as DET, DTR.FTR as FTR,
case DTR.isinput when 0 then 'EI' when 1 then 'EO_EQ' END as DefaultType,
case DTR.isinput when 0 then 'EI' when 1 then 'EO' when 2 then 'EQ' END as OverwriteType,
DTR.tf_ex as DefaultFPValue,
DTR.user_fp_value as OverwriteFPValue,
case DTR.cal_flags when 0 then 'STD' when 2 then 'Root' when 4 then 'Child' when 4 then 'Child' when 8 then 'Deleted' when 10 then 'Root and Deleted' when 128 then 'Deleted' when 136 then 'Root and Deleted' when 138 then 'Child and Deleted' when 256 then 'Root and Ignored'  when 258 then 'Child and Ignored' END as Status,
DTR.cal_mergeroot_id as ParentID
from dss_transaction dtr, cdt_objects cob
where dtr.form_id = cob.object_id
and dtr.cal_mergeroot_id > 0 -- not a sub transaction
and dtr.cal_flags not in (  8, 10, 126, 128,136, 138, 256, 258 ) -- transaction standalone or Root
) as result
where Status in ('Root', 'Child')
order by 1 ASC, 10 DESC
/

-- with workers as (
--     select rw.seven_letter, rw.email_address, concat(rw.seven_letter, substring(rw.email_address, position('@' in rw.email_address))) mailbox, rwf.job_category, db.branchcode, db.rollupbranchname, r1.remote_flag_yn, r1.work_location_name
--     from enterprise_reference_domain.broker.ref_worker rw
--     inner join enterprise_reference_domain.broker.ref_worker_flattened rwf on rwf.seven_letter = rw.seven_letter
--     inner join nast_truckload_domain.broker.dim_branch db on db.branchcode = rw.branch_cost_center_code
--     left join enterprise_reference_domain.broker.ref_worker_location r1 on r1.worker_id = rw.worker_id
-- )

-- ,mailboxes as (
-- select distinct mailboxname, case when b.mailbox is not null then 'Individual' else 'Shared' end mailboxtype --mailboxtype
-- from (
-- select a.sender,
-- b.value:MailboxId::string as mailboxid,
-- b.value:MailboxName::string as mailboxname,
-- b.value:MailboxType::string as mailboxtype
-- from asot_communication.email.classifiedemailnotification_events a,
-- lateral flatten(input => a.MAILBOXES) b
-- where b.value:MailboxId::string is not null
-- ) a
-- left join workers b on b.mailbox = a.mailboxname
-- )

with workdays_month as (
    select distinct 
        d.monthstartdate,
        sum(case when d.workdayflag = 'TRUE' then 1 else 0 end) as workdays

    from nast_truckload_domain.broker.dim_date d
    where 
        date >= '2024-01-01' and date < current_date()
    group by d.monthstartdate
)

,emails_expanded as
(
select e.conversation_id, 
e.message_id, 
e.subject,
e.email_text, 
e.sender, 
substring(e.sender, position('@' in e.sender) + 1) sender_domain,
f.value recipient_flattened, 
substring(f.value, position('@' in f.value) + 1) recipient_domain,
case when lower(substring(f.value, position('@' in f.value) + 1)) = 'chrobinson.com' then 1 else 0 end recipient_is_chr,
TO_TIMESTAMP(e.time_sent_utc) AS time_sent_utc,
TO_TIMESTAMP(e.time_received_utc) time_received_utc,
TO_DATE(e.time_sent_utc) AS sent_date,
EXTRACT(HOUR FROM e.time_sent_utc) AS sent_hour,
e.mailboxes,
e.classification,
-- e.classifications,
e.categories
from asot_communication.email.classifiedemailnotification_events e,
--outer=FALSE removes rows where the array is null
lateral flatten(input => e.recipients, outer => FALSE) f
where to_date(e.time_sent_utc) between {startdate} and {enddate}
and lower(e.sender) not like '%noreply%'
and lower(classification) like '%tracking%'
QUALIFY count(distinct message_id) over (partition by conversation_id) > 1
)

,cleaned_emails as
(
select 
    e.conversation_id,
    e.message_id,
    e.subject,
    e.email_text,
    e.sender,
    e.sender_domain,
    case when lower(e.sender_domain) = 'chrobinson.com' then 1 else 0 end sender_is_chr,
    -- e.recipients,
    array_agg(distinct e.recipient_flattened) recipient,
    array_agg(distinct e.recipient_domain) recipient_domain,
    array_agg(distinct e.recipient_is_chr) recipient_is_chr,
    -- array_agg(distinct w2.seven_letter) recipient_seven_letter,
    to_timestamp(e.time_sent_utc) time_sent_utc,
    to_date(e.time_sent_utc) sent_date,
    extract(hour from e.time_sent_utc) sent_hour,
    e.time_received_utc,
    mailboxes,
    classification,
    -- classifications,
    categories,
    -- w.mailbox,
    -- w.seven_letter,
    -- case when boxes.mailboxtype is not null then boxes.mailboxtype else 'Shared' end sender_mailboxtype,
    -- row_number() over (partition by conversation_id order by e.time_sent_utc) conversation_row_num
    from emails_expanded e
    -- left join workers w on w.email_address = e.sender
    -- left join workers w2 on w2.email_address = e.recipient_flattened
    -- left join mailboxes boxes on boxes.mailboxname = w.mailbox
group by all
)

,final_emails as
(
select a.*,
d.monthstartdate,
wd.workdays
from cleaned_emails a
left join nast_truckload_domain.broker.dim_date d on d.date = cast(a.time_sent_utc as date)
left join workdays_month wd on wd.monthstartdate = d.monthstartdate
)

select * from final_emails

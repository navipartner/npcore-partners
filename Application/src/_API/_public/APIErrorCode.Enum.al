enum 6059810 "NPR API Error Code"
{
    Extensible = true;

    value(0; generic_error)
    {
        Caption = 'An error occurred. See HTTP status code.', Locked = true;
    }

    value(10; unsupported_http_method)
    {
        Caption = 'The http method is not supported for this endpoint.', Locked = true;
    }

    value(20; resource_not_found)
    {
        Caption = 'The selected resource does not exist.', Locked = true;
    }
    value(6248189; globalsale_duplicate_key)
    {
        Caption = 'Duplicate key.', Locked = true;
    }
    value(6060000; capacity_exceeded)
    {
        Caption = 'The capacity has been exceeded. Entry is not allowed.', Locked = true;
    }
    value(6060001; invalid_reference)
    {
        Caption = 'The reference is invalid.', Locked = true;
    }
    value(6060002; reservation_not_found)
    {
        Caption = 'The required reservation for the ticket was not found.', Locked = true;
    }
    value(6060003; not_valid)
    {
        Caption = 'The ticket is not valid.', Locked = true;
    }
    value(6060005; reservation_mismatch)
    {
        Caption = 'Your reservation is not for the current event.', Locked = true;
    }
    value(6060008; admission_not_open)
    {
        Caption = 'The admission code is not open.', Locked = true;
    }
    value(6060009; admission_not_open_entry)
    {
        Caption = 'The admission code is not open for this entry.', Locked = true;
    }
    value(6060010; not_confirmed)
    {
        Caption = 'The ticket has not been confirmed.', Locked = true;
    }
    value(6060014; reservation_not_for_today)
    {
        Caption = 'The reservation is not valid for today.', Locked = true;
    }
    value(6060015; reservation_capacity_exceeded)
    {
        Caption = 'The reservation capacity has been exceeded.', Locked = true;
    }
    value(6060016; ticket_canceled)
    {
        Caption = 'The ticket has been canceled.', Locked = true;
    }
    value(6060017; ticket_not_valid_yet)
    {
        Caption = 'The ticket is not valid yet.', Locked = true;
    }
    value(6060018; ticket_expired)
    {
        Caption = 'The ticket has expired.', Locked = true;
    }
    value(6060019; quantity_change_not_allowed)
    {
        Caption = 'The quantity change is not allowed.', Locked = true;
    }
    value(6060021; no_default_schedule)
    {
        Caption = 'No default schedule could be found.', Locked = true;
    }
    value(6060022; missing_payment)
    {
        Caption = 'The ticket is missing a payment transaction.', Locked = true;
    }
    value(6060023; schedule_entry_expired)
    {
        Caption = 'The schedule entry has expired.', Locked = true;
    }
    value(6060028; reservation_not_for_now)
    {
        Caption = 'The reservation is not valid for now.', Locked = true;
    }
    value(6060030; concurrent_capacity_exceeded)
    {
        Caption = 'The concurrent capacity has been exceeded.', Locked = true;
    }
    value(6060031; reschedule_not_allowed)
    {
        Caption = 'Rescheduling is not allowed.', Locked = true;
    }
    value(6060032; invalid_admission_code)
    {
        Caption = 'The admission code is invalid.', Locked = true;
    }
    value(6060033; has_payment)
    {
        Caption = 'The ticket has already been paid.', Locked = true;
    }
    value(6060035; duration_exceeded)
    {
        Caption = 'The admission duration has expired.', Locked = true;
    }
    value(6060036; ticket_blocked)
    {
        Caption = 'The ticket is blocked.', Locked = true;
    }
    value(6060037; ticket_not_valid_for_suggested_admission)
    {
        Caption = 'The ticket is not valid for the suggested admission.', Locked = true;
    }
    value(6060038; ticket_not_allowed)
    {
        Caption = 'The ticket is not allowed.', Locked = true;
    }
    value(6060039; wallet_expired)
    {
        Caption = 'The wallet has expired.', Locked = true;
    }

    value(6060133; member_blocked)
    {
        Caption = 'Member is blocked.', Locked = true;
    }

    value(6060134; member_card_blocked)
    {
        Caption = 'Member card is blocked.', Locked = true;
    }

    value(6060135; member_card_not_allowed)
    {
        Caption = 'Member card is not allowed.', Locked = true;
    }

    value(6060136; member_card_expired)
    {
        Caption = 'Member card has expired.', Locked = true;
    }

    value(6060137; membership_setup_missing_ticket_item)
    {
        Caption = 'Membership setup is missing ticket item.', Locked = true;
    }
    value(6060138; membership_setup_missing)
    {
        Caption = 'Membership setup is missing.', Locked = true;
    }

    value(6060139; membership_blocked)
    {
        Caption = 'Membership is blocked', Locked = true;
    }

    value(6060140; member_unique_id_violation)
    {
        Caption = 'Member with same unique id already exists.', Locked = true;
    }
    value(6060141; member_count_exceeded)
    {
        Caption = 'Member count exceeded.', Locked = true;
    }

    value(6060142; member_card_exists)
    {
        Caption = 'Member card already exists.', Locked = true;
    }

    value(6060143; no_admin_member)
    {
        Caption = 'No admin member found.', Locked = true;
    }

    value(6060144; member_card_blank)
    {
        Caption = 'Member card is blank.', Locked = true;
    }

    value(6060145; invalid_contact)
    {
        Caption = 'The provided contact number is not valid in context of the customer.', Locked = true;
    }

    value(6060146; age_verification_setup)
    {
        Caption = 'Add member failed on age verification because item number for sales was not provided.', Locked = true;
    }

    value(6060147; age_verification)
    {
        Caption = 'Age verification failed.', Locked = true;
    }

    value(6060148; allow_member_merge_not_set)
    {
        Caption = 'This request violates the community’s member identity uniqueness rule. See the API documentation for merge options.', Locked = true;
    }

    value(6060149; member_card_limitation_error)
    {
        Caption = 'Limitations on member card apply and deny admission.', Locked = true;
    }

    value(6060150; denied_by_speedgate)
    {
        Caption = 'The reference number was denied by the gate.', Locked = true;
    }
    value(6060151; scanner_not_found)
    {
        Caption = 'The scanner was not found.', Locked = true;
    }
    value(6060152; scanner_id_required)
    {
        Caption = 'The scanner id is required.', Locked = true;
    }
    value(6060153; scanner_not_enabled)
    {
        Caption = 'The scanner is not enabled.', Locked = true;
    }
    value(6060154; number_not_whitelisted)
    {
        Caption = 'The reference number was not whitelisted by the gate.', Locked = true;
    }
    value(6060155; number_rejected)
    {
        Caption = 'The reference number was actively rejected by gate setup.', Locked = true;
    }

}
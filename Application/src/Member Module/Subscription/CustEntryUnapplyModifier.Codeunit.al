codeunit 6248200 "NPR CustEntry-Unapply Modifier"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostUnApplyCustomerCommit', '', false, false)]
#else    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", OnBeforePostUnApplyCustomerCommit, '', false, false)]
#endif
    local procedure HideProgressWindowOnSubscriptionPosting(var HideProgressWindow: Boolean)
    begin
        HideProgressWindow := true;
    end;
}
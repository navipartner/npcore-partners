#if not BC17
codeunit 6248553 "NPR Spfy Customer Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";

    internal procedure ProcessDataLogRecord(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        case DataLogEntry."Table ID" of
            Database::"NPR Spfy Store-Customer Link":
                begin
                    TaskCreated := ProcessStoreCustomerLink(DataLogEntry);
                end;
            Database::"NPR Spfy Entity Metafield":
                begin
                    TaskCreated := SpfyMetafieldMgt.ProcessMetafield(DataLogEntry);
                end;
            else
                exit;
        end;
        Commit();
    end;

    local procedure ScheduleCustomerSync(DataLogEntry: Record "NPR Data Log Record"; Customer: Record Customer; SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        clear(NcTask);
        case true of
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify:
                begin
                    case true of
                        not SpfyStoreCustomerLink."Sync. to this Store" and not SpfyStoreCustomerLink."Synchronization Is Enabled":
                            exit;
                        SpfyStoreCustomerLink."Sync. to this Store" and not SpfyStoreCustomerLink."Synchronization Is Enabled":
                            NcTask.Type := NcTask.Type::Insert;
                        not SpfyStoreCustomerLink."Sync. to this Store" and SpfyStoreCustomerLink."Synchronization Is Enabled":
                            NcTask.Type := NcTask.Type::Delete;
                        else
                            NcTask.Type := NcTask.Type::Modify;
                    end;
                end;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete:
                NcTask.Type := NcTask.Type::Delete;
        end;

        RecRef.GetTable(Customer);
        exit(SpfyScheduleSend.InitNcTask(SpfyStoreCustomerLink."Shopify Store Code", RecRef, Customer."No.", NcTask.Type, NcTask));
    end;

    local procedure ProcessStoreCustomerLink(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        RecRef: RecordRef;
    begin
        if DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Rename, DataLogEntry."Type of Change"::Delete] then
            exit;

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreCustomerLink);
        if not SpfyStoreCustomerLink.Find() or not Customer.Get(SpfyStoreCustomerLink."No.") then
            exit;
        if not (SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled") then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then
            exit;
        if not TestRequiredFields(Customer, false) then
            exit;

        DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Modify;
        exit(ScheduleCustomerSync(DataLogEntry, Customer, SpfyStoreCustomerLink));
    end;

    internal procedure ProcessMetafield(SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; var ShopifyStoreCode: Code[20]; var TaskRecordValue: Text): Boolean
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        RecRef: RecordRef;
    begin
        if SpfyEntityMetafield."Table No." <> Database::"NPR Spfy Store-Customer Link" then
            exit;

        RecRef := SpfyEntityMetafield."BC Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreCustomerLink);
        if SpfyStoreCustomerLink.Type <> SpfyStoreCustomerLink.Type::Customer then
            exit;
        if not Customer.Get(SpfyStoreCustomerLink."No.") then
            exit;
        if not (SpfyStoreCustomerLink.Find() and (SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled")) then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then
            exit;
        if not TestRequiredFields(Customer, false) then
            exit;

        ShopifyStoreCode := SpfyStoreCustomerLink."Shopify Store Code";
        TaskRecordValue := Customer."No.";
        exit(true);
    end;

    internal procedure TestRequiredFields(Customer: Record Customer; WithError: Boolean): Boolean
    begin
        if WithError then begin
            if Customer.Blocked = Customer.Blocked::All then
                Customer.FieldError(Blocked);
            exit(true);
        end;

        exit(
            Customer.Blocked <> Customer.Blocked::All);
    end;

    internal procedure AutoEnableCustomerSync(Customer: Record Customer)
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
    begin
        if Customer."E-Mail" = '' then
            exit;
        SpfyStore.SetRange("Auto Sync New Customers", SpfyStore."Auto Sync New Customers"::MembershipOnly);
        if SpfyStore.IsEmpty() then
            exit;
        if not SpfyIntegrationMgt.IsEnabledForAnyStore(Enum::"NPR Spfy Integration Area"::"Sales Orders") then
            exit;

        SpfyStore.FindSet();
        repeat
            if SpfyIntegrationMgt.IsEnabled(Enum::"NPR Spfy Integration Area"::"Sales Orders", SpfyStore) then begin
                SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
                SpfyStoreCustomerLink."No." := Customer."No.";
                SpfyStoreCustomerLink."Shopify Store Code" := SpfyStore.Code;
                if not SpfyStoreCustomerLink.Find() then begin
                    SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
                    SpfyStoreCustomerLink.Find();
                end;
                if not SpfyStoreCustomerLink."Sync. to this Store" then
                    SpfyStoreCustomerLink.Validate("Sync. to this Store", true);  //also modifies the record during field validation
            end;
        until SpfyStore.Next() = 0;
    end;

    internal procedure FindCustomerByShopifyID(ShopifyStoreCode: Code[20]; CustomerId: Text[30]; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link") Found: Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
    begin
        Clear(SpfyStoreCustomerLink);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Spfy Store-Customer Link", "NPR Spfy ID Type"::"Entry ID", CustomerId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SpfyStoreCustomerLink);
                    SpfyStoreCustomerLink.Mark(
                        (SpfyStoreCustomerLink.Type = SpfyStoreCustomerLink.Type::Customer) and (SpfyStoreCustomerLink."No." <> '') and
                        (SpfyStoreCustomerLink."Shopify Store Code" = ShopifyStoreCode));
                end;
            until ShopifyAssignedID.Next() = 0;
        SpfyStoreCustomerLink.MarkedOnly(true);
        Found := not SpfyStoreCustomerLink.IsEmpty();
    end;

    local procedure CheckCustomerIsSynchronized(Customer: Record Customer): Boolean
    begin
        Customer.CalcFields("NPR Spfy Synced Customer");
        exit(Customer."NPR Spfy Synced Customer");
    end;

    internal procedure CustomerIsPlannedForSync(Customer: Record Customer): Boolean
    begin
        Customer.CalcFields("NPR Spfy Synced Cust.(Planned)");
        exit(Customer."NPR Spfy Synced Cust.(Planned)");
    end;

    internal procedure UpdateMarketingConsentState(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Member: Record "NPR MM Member";
    begin
        if not FindMember(SpfyStoreCustomerLink, Member) then
            exit;
        UpdateMarketingConsentState(Member, SpfyStoreCustomerLink);
    end;

    internal procedure UpdateMarketingConsentState(Member: Record "NPR MM Member")
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin
        MembershipRole.SetRange("Member Entry No.", Member."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        MembershipRole.SetLoadFields("Membership Entry No.");
        if not MembershipRole.FindFirst() then
            exit;
        Membership.SetLoadFields("Customer No.");
        if not Membership.Get(MembershipRole."Membership Entry No.") then
            exit;
        UpdateMarketingConsentState(Member, Membership."Customer No.");
    end;

    internal procedure UpdateMarketingConsentState(Member: Record "NPR MM Member"; CustomerNo: Code[20])
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLink2: Record "NPR Spfy Store-Customer Link";
    begin
        if CustomerNo = '' then
            exit;
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", CustomerNo);
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyStoreCustomerLink.ReadIsolation := IsolationLevel::UpdLock;
#endif
        if SpfyStoreCustomerLink.FindSet() then
            repeat
                SpfyStoreCustomerLink2 := SpfyStoreCustomerLink;
                if UpdateMarketingConsentState(Member, SpfyStoreCustomerLink2) then
                    SpfyStoreCustomerLink2.Modify();
            until SpfyStoreCustomerLink.Next() = 0;
    end;

    local procedure UpdateMarketingConsentState(Member: Record "NPR MM Member"; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"): Boolean
    var
        EmailMarketingState: Enum "NPR Spfy EMail Marketing State";
    begin
        case Member."E-Mail News Letter" of
            Member."E-Mail News Letter"::NOT_SPECIFIED:
                EmailMarketingState := EmailMarketingState::UNKNOWN;
            Member."E-Mail News Letter"::NO:
                EmailMarketingState := EmailMarketingState::UNSUBSCRIBED;
            Member."E-Mail News Letter"::YES:
                EmailMarketingState := EmailMarketingState::SUBSCRIBED;
        end;
        if EmailMarketingState in [EmailMarketingState::UNKNOWN, SpfyStoreCustomerLink."E-mail Marketing State"] then
            exit(false);
        SpfyStoreCustomerLink."E-mail Marketing State" := EmailMarketingState;
        SpfyStoreCustomerLink."Marketing State Updated in BC" := true;
        exit(true);
    end;

    internal procedure UpdateMemberNewsletterSubscription(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Member: Record "NPR MM Member";
        xMember: Record "NPR MM Member";
        SpfyStoreCustomerLink2: Record "NPR Spfy Store-Customer Link";
    begin
        if SpfyStoreCustomerLink.Type <> SpfyStoreCustomerLink.Type::Customer then
            exit;

        SpfyStoreCustomerLink2.SetRange(Type, SpfyStoreCustomerLink.Type);
        SpfyStoreCustomerLink2.SetRange("No.", SpfyStoreCustomerLink."No.");
        SpfyStoreCustomerLink2.SetFilter("Shopify Store Code", '<>%1', SpfyStoreCustomerLink."Shopify Store Code");
        SpfyStoreCustomerLink2.SetRange("Sync. to this Store", true);
        if SpfyStoreCustomerLink2.Find('-') then
            repeat
                if SpfyIntegrationMgt.IsEnabled(Enum::"NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink2."Shopify Store Code") then
                    if SpfyStoreCustomerLink2."E-mail Marketing State" <> SpfyStoreCustomerLink."E-mail Marketing State" then
                        exit;  //different states in different stores - do not update member
            until SpfyStoreCustomerLink2.Next() = 0;

        if not FindMember(SpfyStoreCustomerLink, Member) then
            exit;
        xMember := Member;
        case SpfyStoreCustomerLink."E-mail Marketing State" of
            SpfyStoreCustomerLink."E-mail Marketing State"::SUBSCRIBED:
                Member."E-Mail News Letter" := Member."E-Mail News Letter"::YES;
            SpfyStoreCustomerLink."E-mail Marketing State"::UNSUBSCRIBED:
                Member."E-Mail News Letter" := Member."E-Mail News Letter"::NO;
            else  //UNKNOWN, INVALID, NOT_SUBSCRIBED, PENDING, REDACTED
                Member."E-Mail News Letter" := Member."E-Mail News Letter"::NOT_SPECIFIED;
        end;
        if Member."E-Mail News Letter" = xMember."E-Mail News Letter" then
            exit;
        Member.Modify();

        //Update other store-customer links for the same customer
        SpfyStoreCustomerLink2.SetRange("Sync. to this Store");
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyStoreCustomerLink2.ReadIsolation := IsolationLevel::UpdLock;
#endif
        if SpfyStoreCustomerLink2.FindSet() then
            repeat
                if UpdateMarketingConsentState(Member, SpfyStoreCustomerLink2) then
                    SpfyStoreCustomerLink2.Modify();
            until SpfyStoreCustomerLink2.Next() = 0;
    end;

    local procedure FindMember(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; var Member: Record "NPR MM Member"): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin
        if SpfyStoreCustomerLink.Type <> SpfyStoreCustomerLink.Type::Customer then
            exit(false);

        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", SpfyStoreCustomerLink."No.");
        Membership.SetRange(Blocked, false);
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit(false);

        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        MembershipRole.SetLoadFields("Member Entry No.");
        if not MembershipRole.FindFirst() then
            exit(false);

        exit(Member.Get(MembershipRole."Member Entry No."));
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeRenameEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeRenameEvent, '', true, false)]
#endif
    local procedure CheckNotShopifyCustomerOnRename(var Rec: Record Customer)
    var
        RenameNotAllowedErr: Label 'Shopify enabled customers cannot be renamed.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckCustomerIsSynchronized(Rec) then
            Error(RenameNotAllowedErr);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeDeleteEvent, '', true, false)]
#endif
    local procedure CheckNotShopifyCustomerOnDelete(var Rec: Record Customer)
    var
        DeleteNotAllowedErr: Label 'The customer has already been synchronized with one or more Shopify stores. First, you will need to disable customer synchronization with all Shopify stores and wait for the changes to sync with Shopify. Only then will you be able to delete the customer from Business Central.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckCustomerIsSynchronized(Rec) then
            Error(DeleteNotAllowedErr);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure RefreshxRec(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec.IsTemporary() then
            exit;

#if not (BC18 or BC19 or BC20 or BC21)
        xRec.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        xRec.SetLoadFields();
        if not xRec.Get(Rec."No.") then
            Clear(xRec);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterModifyEvent, '', false, false)]
#endif
    local procedure Customer_OnAfterModifyEvent_PropagateToLink(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
        xParsedFirstName: Text[100];
        xParsedLastName: Text[100];
        NewParsedFirstName: Text[100];
        NewParsedLastName: Text[100];
        NameChanged: Boolean;
        EmailChanged: Boolean;
        PhoneChanged: Boolean;
        AddressChanged: Boolean;
        LinkChanged: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        NameChanged := (Rec.Name <> xRec.Name) or (Rec."Name 2" <> xRec."Name 2");
        EmailChanged := Rec."E-Mail" <> xRec."E-Mail";
        PhoneChanged := Rec."Phone No." <> xRec."Phone No.";
        AddressChanged :=
            (Rec.Address <> xRec.Address) or (Rec."Address 2" <> xRec."Address 2") or
            (Rec.City <> xRec.City) or (Rec.County <> xRec.County) or
            (Rec."Post Code" <> xRec."Post Code") or (Rec."Country/Region Code" <> xRec."Country/Region Code");
        if not (NameChanged or EmailChanged or PhoneChanged or AddressChanged) then
            exit;

        if NameChanged then begin
            SpfySendCustomers.GetParsedNames(xRec, xParsedFirstName, xParsedLastName);
            SpfySendCustomers.GetParsedNames(Rec, NewParsedFirstName, NewParsedLastName);
        end;

        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", Rec."No.");
        if not SpfyStoreCustomerLink.FindSet() then
            exit;
        repeat
            LinkChanged := false;
            if NameChanged then
                if (SpfyStoreCustomerLink."First Name" in ['', xParsedFirstName]) and
                   (SpfyStoreCustomerLink."Last Name" in ['', xParsedLastName])
                then begin
                    SpfyStoreCustomerLink."First Name" := NewParsedFirstName;
                    SpfyStoreCustomerLink."Last Name" := NewParsedLastName;
                    LinkChanged := true;
                end;
            if EmailChanged then
                if SpfyStoreCustomerLink."E-Mail" in ['', xRec."E-Mail"] then begin
                    SpfyStoreCustomerLink."E-Mail" := Rec."E-Mail";
                    LinkChanged := true;
                end;
            if PhoneChanged then
                if SpfyStoreCustomerLink."Phone No." in ['', xRec."Phone No."] then begin
                    SpfyStoreCustomerLink."Phone No." := Rec."Phone No.";
                    LinkChanged := true;
                end;
            if AddressChanged then
                if (SpfyStoreCustomerLink.Address in ['', xRec.Address]) and
                   (SpfyStoreCustomerLink."Address 2" in ['', xRec."Address 2"]) and
                   (SpfyStoreCustomerLink.City in ['', xRec.City]) and
                   (SpfyStoreCustomerLink.County in ['', xRec.County]) and
                   (SpfyStoreCustomerLink."Post Code" in ['', xRec."Post Code"]) and
                   (SpfyStoreCustomerLink."Country/Region Code" in ['', xRec."Country/Region Code"])
                then begin
                    SpfyStoreCustomerLink.Address := Rec.Address;
                    SpfyStoreCustomerLink."Address 2" := Rec."Address 2";
                    SpfyStoreCustomerLink.City := Rec.City;
                    SpfyStoreCustomerLink.County := Rec.County;
                    SpfyStoreCustomerLink."Post Code" := Rec."Post Code";
                    SpfyStoreCustomerLink."Country/Region Code" := Rec."Country/Region Code";
                    SpfyStoreCustomerLink."Address Updated in BC" := true;
                    LinkChanged := true;
                end;
            if LinkChanged then
                SpfyStoreCustomerLink.Modify(true);
        until SpfyStoreCustomerLink.Next() = 0;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Phone No.', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, 'Phone No.', false, false)]
#endif
    local procedure WarnOnInvalidShopifyPhoneNo(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec.IsTemporary() then
            exit;
        SpfyIntegrationMgt.ConfirmInvalidShopifyPhoneNoOnChange(Rec."Phone No.", xRec."Phone No.");
    end;
}
#endif
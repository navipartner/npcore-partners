#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151001 "NPR NPEmail POS Receipt OnSale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    // Obsolete workflow interface stubs - kept only because EMAIL_RCPT_ON_SALE enum value cannot be deleted yet (AS0083).
    // Remove together with the enum value in the next major version.
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Obsolete: Send POS Receipt Email after sale (SendGrid)';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", OnAfterEndSale, '', false, false)]
    local procedure SendReceiptEmailOnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        POSEntry: Record "NPR POS Entry";
    begin
        if not NewEmailExperienceFeature.IsFeatureEnabled() then
            exit;

        if SalePOS."Header Type" = SalePOS."Header Type"::Cancelled then
            exit;

        Sender.GetLastSalePOSEntry(POSEntry);
        if POSEntry."Entry No." = 0 then
            exit;

        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::Other, POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale"]) then
            exit;

        SendReceiptEmail(POSEntry);
    end;

    local procedure SendReceiptEmail(POSEntry: Record "NPR POS Entry")
    var
        NPEmail: Codeunit "NPR NP Email";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        EmailAddress: Text[250];
    begin
        if not TryGetValidatedReceiptProfile(POSEntry, POSReceiptProfile) then
            exit;

        EmailAddress := GetEmailAddress(POSEntry);
        if EmailAddress = '' then
            exit;

        NPEmail.TrySendEmail(
            POSReceiptProfile."E-mail Template Id",
            POSEntry,
            EmailAddress,
            GetLanguageCode(POSEntry)
        );
    end;

    local procedure TryGetValidatedReceiptProfile(POSEntry: Record "NPR POS Entry"; var POSReceiptProfile: Record "NPR POS Receipt Profile"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit(false);

        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit(false);

        if POSReceiptProfile."E-mail Template Id" = '' then
            exit(false);

        if not POSReceiptProfile."E-mail Receipt On Sale" then
            exit(false);

        exit(true);
    end;

    local procedure GetEmailAddress(POSEntry: Record "NPR POS Entry"): Text[250]
    var
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        case true of
            POSEntry."Customer No." <> '':
                begin
                    if Customer.Get(POSEntry."Customer No.") then
                        exit(Customer."E-Mail");
                end;
            POSEntry."Contact No." <> '':
                begin
                    if Contact.Get(POSEntry."Contact No.") then
                        exit(Contact."E-Mail");
                end;
        end;
    end;

    local procedure GetLanguageCode(POSEntry: Record "NPR POS Entry") LanguageCode: Code[10]
    var
        Customer: Record Customer;
    begin
        LanguageCode := '';
        if Customer.Get(POSEntry."Customer No.") then
            LanguageCode := Customer."Language Code";
    end;
}
#endif

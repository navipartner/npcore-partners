#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151001 "NPR POS Action: NpEmailPOSRcpt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Send POS Receipt Email after sale (SendGrid)';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'SendReceiptEmail':
                FrontEnd.WorkflowResponse(SendReceiptEmailResponse(Sale));
        end;
    end;

    local procedure SendReceiptEmailResponse(Sale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        POSEntry: Record "NPR POS Entry";
    begin
        Sale.GetLastSalePOSEntry(POSEntry);
        Response.Add('success', SendReceiptEmail(POSEntry));
    end;

    internal procedure AddPostEndOfSaleWorkflow(Sale: Codeunit "NPR POS Sale"; var PostWorkflows: JsonObject)
    var
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        POSEntry: Record "NPR POS Entry";
        ActionParameters: JsonObject;
    begin
        if not NewEmailExperienceFeature.IsFeatureEnabled() then
            exit;

        Sale.GetLastSalePOSEntry(POSEntry);

        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::Other, POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale"]) then
            exit;

        // Add workflow - validation of receipt profile and email happens in SendReceiptEmail
        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::EMAIL_RCPT_ON_SALE), ActionParameters);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionNpEmailPOSRcpt.js###
'const main=async({workflow:s})=>{try{(await s.respond("SendReceiptEmail")).success?console.log("Receipt email sent successfully"):console.warn("Receipt email not sent - no valid email address or configuration")}catch(e){console.error("Email send failed:",e)}};'
        );
    end;

    local procedure SendReceiptEmail(POSEntry: Record "NPR POS Entry"): Boolean
    var
        NPEmail: Codeunit "NPR NP Email";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        EmailAddress: Text[250];
    begin
        if not TryGetValidatedReceiptProfile(POSEntry, POSReceiptProfile) then
            exit(false);

        EmailAddress := GetEmailAddress(POSEntry);
        if EmailAddress = '' then
            exit(false);

        exit(NPEmail.TrySendEmail(
            POSReceiptProfile."E-mail Template Id",
            POSEntry,
            EmailAddress,
            GetLanguageCode(POSEntry)
        ));
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

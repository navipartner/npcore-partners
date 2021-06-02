codeunit 6151061 "NPR GDPR Anon. Req. WS"
{
    procedure AnonymizationRequest(CustomerNo: Code[20]; ContactNo: Code[20]): Boolean
    begin
        exit(InsertRequestEntry(CustomerNo, ContactNo) <> 0);
    end;

    procedure CanCustomerBeAnonymized(CustomerNo: Code[20]; ContactNo: Code[20]; var ResponseCode: Integer) OkToAnonymize: Boolean
    var
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request";
        Customer: Record Customer;
        Contact: Record Contact;
        NPGDPRManagement: Codeunit "NPR NP GDPR Management";
        LimitingDateformula: DateFormula;
        RequestEntryNo: Integer;
        GDPRAnonymizationRequestReasonLbl: Label 'Anonymization checker responded with: %1', Locked = true;
    begin
        ResponseCode := -1;
        if (not Customer.Get(CustomerNo)) then
            exit(true);

        if (ContactNo <> '') then
            if (not Contact.Get(ContactNo)) then
                exit(true);

        if (not GDPRSetup.Get()) then
            GDPRSetup.Init();

        RequestEntryNo := InsertRequestEntry(CustomerNo, ContactNo);
        if (RequestEntryNo = 0) then
            exit(false);

        GDPRAnonymizationRequest.Get(RequestEntryNo);

        if (Evaluate(LimitingDateformula, '-' + Format(GDPRSetup."Anonymize After"))) then begin
            OkToAnonymize := NPGDPRManagement.IsCustomerValidForAnonymization(CustomerNo, true, LimitingDateformula, ResponseCode);
        end else begin
            OkToAnonymize := NPGDPRManagement.IsCustomerValidForAnonymization(CustomerNo, false, LimitingDateformula, ResponseCode);
        end;

        GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::APPROVED;
        if (not OkToAnonymize) then begin
            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::DECLINED;
            GDPRAnonymizationRequest.Reason := StrSubstNo(GDPRAnonymizationRequestReasonLbl, ResponseCode);
        end;
        GDPRAnonymizationRequest.Modify();

        exit(OkToAnonymize);
    end;

    local procedure InsertRequestEntry(CustomerNo: Code[20]; ContactNo: Code[20]) EntryNo: Integer
    var
        GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        GDPRAnonymizationRequest.Init();
        GDPRAnonymizationRequest."Customer No." := CustomerNo;

        if (not Customer.Get(CustomerNo)) then
            exit(0);

        GDPRAnonymizationRequest.Type := GDPRAnonymizationRequest.Type::COMPANY;
        if (ContactNo <> '') then begin
            if (not Contact.Get(ContactNo)) then
                exit(0);

            if (Contact.Type = Contact.Type::Person) then
                GDPRAnonymizationRequest.Type := GDPRAnonymizationRequest.Type::PERSON;

        end;

        GDPRAnonymizationRequest."Request Received" := CurrentDateTime();

        if (Customer."NPR Anonymized") then begin
            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::ANONYMIZED;
            GDPRAnonymizationRequest."Processed At" := Customer."NPR Anonymized Date";
        end;

        if (GDPRAnonymizationRequest.Insert()) then
            EntryNo := GDPRAnonymizationRequest."Entry No.";

        exit(EntryNo);
    end;
}


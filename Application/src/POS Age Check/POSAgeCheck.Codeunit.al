codeunit 6151323 "NPR POS Age Check"
{
    Access = Internal;

    procedure LineAgeLimit(POSSaleLine: Record "NPR POS Sale Line"): Integer
    var
        ItemCategory: Record "Item Category";
    begin
        if POSSaleLine."Line Type" <> POSSaleLine."Line Type"::Item then
            exit(0);
        if POSSaleLine."Item Category Code" = '' then
            exit(0);
        ItemCategory.SetLoadFields("NPR Age Limit");
        if not ItemCategory.Get(POSSaleLine."Item Category Code") then
            exit(0);
        exit(ItemCategory."NPR Age Limit");
    end;

    procedure RequiredAgeLimit(POSSale: Record "NPR POS Sale") RequiredLimit: Integer
    var
        POSSaleLine: Record "NPR POS Sale Line";
        LineLimit: Integer;
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetFilter("Item Category Code", '<>%1', '');
        POSSaleLine.SetLoadFields("Line Type", "Item Category Code");
        if POSSaleLine.FindSet() then
            repeat
                LineLimit := LineAgeLimit(POSSaleLine);
                if LineLimit > RequiredLimit then
                    RequiredLimit := LineLimit;
            until POSSaleLine.Next() = 0;
    end;

    procedure IsApproved(POSSale: Record "NPR POS Sale"; RequiredLimit: Integer): Boolean
    begin
        if RequiredLimit = 0 then
            exit(true);
        exit(POSSale."Age Check Approved Limit" >= RequiredLimit);
    end;

    procedure NeedsApproval(POSSale: Record "NPR POS Sale"): Boolean
    begin
        exit(not IsApproved(POSSale, RequiredAgeLimit(POSSale)));
    end;

    procedure RequiredErrorMessage(): Text
    var
        AgeCheckRequiredLbl: Label 'The sale contains age-restricted items and the age check has not been approved.';
    begin
        exit(AgeCheckRequiredLbl);
    end;

    procedure ClearApproval(var POSSale: Record "NPR POS Sale")
    begin
        POSSale."Age Check Method" := POSSale."Age Check Method"::None;
        POSSale."Age Check Approved Limit" := 0;
        POSSale."Age Check Salesperson Code" := '';
        POSSale."Age Check Approved At" := 0DT;
    end;

    procedure ApproveByStaff(var POSSale: Record "NPR POS Sale"; Credential: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if not FindSalespersonByCredential(Credential, Salesperson) then
            exit(false);
        if Salesperson.Blocked then
            exit(false);
        if not SalespersonAllowedOnPOSUnit(Salesperson, POSSale."Register No.") then
            exit(false);

        RecordApproval(POSSale, Enum::"NPR POS Age Check Method"::Staff, Salesperson.Code);
        exit(true);
    end;

    procedure AddToJson(POSSale: Record "NPR POS Sale"; var Json: Codeunit "NPR Json Builder")
    var
        RequiredLimit: Integer;
    begin
        RequiredLimit := RequiredAgeLimit(POSSale);
        Json.StartObject('ageCheck')
            .AddProperty('requiredLimit', RequiredLimit)
            .AddProperty('approvedLimit', POSSale."Age Check Approved Limit")
            .AddProperty('approved', IsApproved(POSSale, RequiredLimit))
            .EndObject();
    end;

    local procedure FindSalespersonByCredential(Credential: Text; var Salesperson: Record "Salesperson/Purchaser"): Boolean
    begin
        Credential := DelChr(Credential, '<>', ' ');
        if Credential = '' then
            exit(false);
        if StrLen(Credential) > MaxStrLen(Salesperson."NPR Register Password") then
            exit(false);

        Salesperson.ReadIsolation := IsolationLevel::ReadCommitted;
        Salesperson.SetLoadFields(Code, Blocked, "NPR POS Unit Group");
        Salesperson.SetRange("NPR Register Password", Credential);
        exit(Salesperson.FindFirst());
    end;

    local procedure SalespersonAllowedOnPOSUnit(Salesperson: Record "Salesperson/Purchaser"; POSUnitNo: Code[10]): Boolean
    var
        POSUnitGroupLine: Record "NPR POS Unit Group Line";
    begin
        if Salesperson."NPR POS Unit Group" = '' then
            exit(true);
        POSUnitGroupLine.SetRange("POS Unit", POSUnitNo);
        POSUnitGroupLine.SetRange("No.", Salesperson."NPR POS Unit Group");
        exit(not POSUnitGroupLine.IsEmpty());
    end;

    local procedure RecordApproval(var POSSale: Record "NPR POS Sale"; Method: Enum "NPR POS Age Check Method"; SalespersonCode: Code[20])
    var
        RequiredLimit: Integer;
    begin
        RequiredLimit := RequiredAgeLimit(POSSale);
        if RequiredLimit = 0 then
            exit;

        POSSale."Age Check Method" := Method;
        POSSale."Age Check Approved Limit" := RequiredLimit;
        POSSale."Age Check Salesperson Code" := SalespersonCode;
        POSSale."Age Check Approved At" := CurrentDateTime();
        POSSale.Modify();
    end;
}

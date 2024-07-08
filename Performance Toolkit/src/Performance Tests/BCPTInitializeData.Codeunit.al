codeunit 88007 "NPR BCPT Initialize Data" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        SelectLatestVersion();

        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        InitializeData();
    end;

    var
        BCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;
        NoOfPOSUnits: Integer;
        NoOfPOSUnitsParamLbl: Label 'NoOfPOSUnits', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';
        GetLastPosUnitErr: Label 'Unable to find last created POS Unit';
        GetGenBusinessPostingGroupErr: Label 'Unable to find Gen. Business Posting Group';


    local procedure InitTest();
    begin
        if Evaluate(NoOfPOSUnits, BCPTTestContext.GetParameter(NoOfPOSUnitsParamLbl)) then;

        if NoOfPOSUnits < 50 then
            NoOfPOSUnits := 50;
        if NoOfPOSUnits > 10000 then
            NoOfPOSUnits := 10000;
    end;

    local procedure InitializeData()
    begin
        RemoveOldPOSUnitsAndRelatedRecords();
        CreatePOSUnits();
        CreateMiscData();
        DiscoverActions();
    end;

    local procedure RemoveOldPOSUnitsAndRelatedRecords()
    var
        POSStore: Record "NPR POS Store";
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSUnit: Record "NPR POS Unit";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        POSStore.SetRange(Code, '1001', '11000');
        if not POSStore.IsEmpty() then
            POSStore.DeleteAll();

        POSPostingSetup.SetRange("POS Store Code", '1001', '11000');
        if not POSPostingSetup.IsEmpty() then
            POSPostingSetup.DeleteAll();

        POSUnit.SetRange("No.", '1001', '11000');
        if not POSUnit.IsEmpty() then
            POSUnit.DeleteAll();

        POSPaymentBin.SetRange("No.", '1001', '11000');
        if not POSPaymentBin.IsEmpty() then
            POSPaymentBin.DeleteAll();
    end;

    local procedure CreatePOSUnits()
    var
        i: Integer;
    begin
        for i := 1 to NoOfPOSUnits do
            CreatePOSUnitAndRelatedRecords(i + 1000);
    end;

    local procedure CreatePOSUnitAndRelatedRecords(NewRecordId: Integer)
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        CreatePOSStore(POSStore, NewRecordId);
        CreatePOSUnit(POSUnit, POSStore.Code, NewRecordId);
    end;

    local procedure CreatePOSStore(var POSStore: Record "NPR POS Store"; NewRecordId: Integer)
    begin
        if POSStore.Get(NewRecordId) then
            exit;

        POSStore.Init();
        POSStore.Validate(Code, Format(NewRecordId));
        POSStore."POS Posting Profile" := 'DEFAULT';
        POSStore.Insert(true);

        CreatePOSPostingSetupSet(POSStore.Code);
    end;

    local procedure CreatePOSPostingSetupSet(POSStoreCode: Code[10])
    var
        POSPostingSetup, POSPostingSetup2 : Record "NPR POS Posting Setup";
    begin
        POSPostingSetup.Init();
        POSPostingSetup."POS Store Code" := POSStoreCode;

        POSPostingSetup2.SetRange("POS Store Code", '01');
        POSPostingSetup2.SetFilter("POS Payment Method Code", 'K|EURO|USD|GBP');
        POSPostingSetup2.SetFilter("POS Payment Bin Code", 'BANK|SAFE');
        if POSPostingSetup2.FindSet() then
            repeat
                POSPostingSetup."POS Payment Method Code" := POSPostingSetup2."POS Payment Method Code";
                POSPostingSetup."POS Payment Bin Code" := POSPostingSetup2."POS Payment Bin Code";
                POSPostingSetup."Account Type" := POSPostingSetup2."Account Type";
                POSPostingSetup."Account No." := POSPostingSetup2."Account No.";
                POSPostingSetup."Difference Account Type" := POSPostingSetup2."Difference Account Type";
                POSPostingSetup."Difference Acc. No." := POSPostingSetup2."Difference Acc. No.";
                POSPostingSetup."Difference Acc. No. (Neg)" := POSPostingSetup2."Difference Acc. No. (Neg)";
                POSPostingSetup.Insert();
            until POSPostingSetup2.Next() = 0;
    end;

    local procedure CreatePOSUnit(var POSUnit: Record "NPR POS Unit"; POSStoreCode: Code[10]; NewRecordId: Integer)
    var
        POSPaymentBin: record "NPR POS Payment Bin";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin
        if POSUnit.Get(NewRecordId) then
            exit;

        POSUnit.Init();
        POSUnit.Validate("No.", Format(NewRecordId));
        POSUnit."POS Store Code" := POSStoreCode;
        POSUnit."POS Audit Profile" := 'DEFAULT';
        POSUnit."POS End of Day Profile" := 'DEFAULT';
        POSUnit.Insert(true);

        CreatePOSPaymentBin(POSPaymentBin, NewRecordId);
        POSUnit."Default POS Payment Bin" := POSPaymentBin."No.";
        POSUnit.Modify();

        POSManagePOSUnit.OpenPosUnit(POSUnit);
    end;

    local procedure CreatePOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin"; NewRecordId: Integer)
    begin
        POSPaymentBin.Init();
        POSPaymentBin.Validate("No.", Format(NewRecordId));
        POSPaymentBin.Insert();
    end;

    local procedure CreateMiscData()
    begin
        InsertGeneralPostingSetup();
        InsertVATPostingSetup();
        InsertUserSetup();
        InsertReminderTerms();
    end;

    local procedure GetFirstGenBusPostGroup(Filter: Text) ReturnCode: Code[20]
    var
        GenBusPostGroup: Record "Gen. Business Posting Group";
    begin
        GenBusPostGroup.Reset();
        GenBusPostGroup.SetFilter(Code, Filter);
        if GenBusPostGroup.FindFirst() then
            ReturnCode := GenBusPostGroup.Code
        else
            Error(GetGenBusinessPostingGroupErr);
    end;

    local procedure InsertGeneralPostingSetup()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        DomesticGenBusPosGroupCode: Code[20];
        ExportGenBusPosGroupCode: Code[20];
    begin
        DomesticGenBusPosGroupCode := GetFirstGenBusPostGroup('INDENLANDS|DOMESTIC');
        ExportGenBusPosGroupCode := GetFirstGenBusPostGroup('UDLAND|EXPORT');

        if not GeneralPostingSetup.Get(DomesticGenBusPosGroupCode, 'MISC') then begin
            GeneralPostingSetup.Validate("Gen. Bus. Posting Group", DomesticGenBusPosGroupCode);
            GeneralPostingSetup.Validate("Gen. Prod. Posting Group", 'MISC');
            GeneralPostingSetup.Validate("Sales Account", '01030');
            GeneralPostingSetup.Validate("Sales Credit Memo Account", '01030');
            GeneralPostingSetup.Validate("Purch. Account", '02100');
            GeneralPostingSetup.Validate("Purch. Credit Memo Account", '02100');
            GeneralPostingSetup.Validate("COGS Account", '02010');
            GeneralPostingSetup.Validate("Inventory Adjmt. Account", '02800');
            GeneralPostingSetup.Insert(true);
        end;

        if not GeneralPostingSetup.Get(ExportGenBusPosGroupCode, 'MISC') then begin
            GeneralPostingSetup.Validate("Gen. Bus. Posting Group", ExportGenBusPosGroupCode);
            GeneralPostingSetup.Validate("Gen. Prod. Posting Group", 'MISC');
            GeneralPostingSetup.Validate("Sales Account", '01010');
            GeneralPostingSetup.Validate("Sales Credit Memo Account", '01010');
            GeneralPostingSetup.Validate("Purch. Account", '16200');
            GeneralPostingSetup.Validate("Purch. Credit Memo Account", '16200');
            GeneralPostingSetup.Validate("COGS Account", '02010');
            GeneralPostingSetup.Validate("Inventory Adjmt. Account", '02800');
            GeneralPostingSetup.Validate("Direct Cost Applied Account", '16200');
            GeneralPostingSetup.Insert(true);
        end;
    end;

    local procedure InsertVATPostingSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        DomesticGenBusPosGroupCode: Code[20];
        ExportGenBusPosGroupCode: Code[20];
    begin
        DomesticGenBusPosGroupCode := GetFirstGenBusPostGroup('INDENLANDS|DOMESTIC');
        ExportGenBusPosGroupCode := GetFirstGenBusPostGroup('UDLAND|EXPORT');

        if not VATPostingSetup.Get(DomesticGenBusPosGroupCode, 'VAT25') then begin
            VATPostingSetup.Validate("VAT Bus. Posting Group", DomesticGenBusPosGroupCode);
            VATPostingSetup.Validate("VAT Prod. Posting Group", 'VAT25');
            VATPostingSetup.Validate("VAT Identifier", 'VAT25');
            VATPostingSetup.Validate("VAT %", 25);
            VATPostingSetup.Validate("Sales VAT Account", '24010');
            VATPostingSetup.Validate("Purchase VAT Account", '24020');
            VATPostingSetup.Validate("Tax Category", 'S');
            VATPostingSetup.Insert(true);
        end;

        if not VATPostingSetup.Get(ExportGenBusPosGroupCode, 'VAT25') then begin
            VATPostingSetup.Validate("VAT Bus. Posting Group", ExportGenBusPosGroupCode);
            VATPostingSetup.Validate("VAT Prod. Posting Group", 'VAT25');
            VATPostingSetup.Validate("VAT Identifier", 'VAT25');
            VATPostingSetup.Validate("VAT %", 25);
            VATPostingSetup.Validate("Sales VAT Account", '24010');
            VATPostingSetup.Validate("Purchase VAT Account", '24020');
            VATPostingSetup.Validate("Tax Category", 'E');
            VATPostingSetup.Insert(true);
        end;
    end;

    local procedure DiscoverActions()
    var
        TempPOSAction: Record "NPR POS Action" temporary;
    begin
        TempPOSAction.DiscoverActions();
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(GetDefaultNoOfPOSUnitsParameter());
    end;

    local procedure GetDefaultNoOfPOSUnitsParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfPOSUnitsParamLbl + '=' + Format(2000), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        ValidateNoOfPOSUnitsParameter(CopyStr(SelectStr(1, Parameters), 1, 1000));
    end;

    local procedure ValidateNoOfPOSUnitsParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, NoOfPOSUnitsParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(NoOfPOSUnitsParamLbl + '='));
            if Evaluate(NoOfPOSUnits, Parameter) then
                exit;
        end;

        Error(ParamValidationErr, GetDefaultNoOfPOSUnitsParameter());
    end;

    local procedure GetLastCreatedPosUnit(var POSUnit: Record "NPR POS Unit")
    begin
        POSUnit.Reset();
        POSUnit.SetCurrentKey(SystemCreatedAt);
        POSUnit.SetAscending(SystemCreatedAt, true);
        if not POSUnit.FindLast() then
            Error(GetLastPosUnitErr);
    end;

    local procedure EnsureUserSetupExistsForUser(User: Record User; POSUnit: Record "NPR POS Unit")
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(User."User Name") then begin
            UserSetup."NPR POS Unit No." := POSUnit."No.";
            UserSetup.Modify();
        end else begin
            UserSetup.Init();
            UserSetup."User ID" := User."User Name";
            UserSetup."NPR POS Unit No." := POSUnit."No.";
            UserSetup.Insert();
        end;
    end;

    local procedure InsertUserSetup()
    var
        User: Record User;
        POSUnit: Record "NPR POS Unit";
    begin
        GetLastCreatedPosUnit(POSUnit);

        if User.FindSet() then
            repeat
                EnsureUserSetupExistsForUser(User, POSUnit)
            until User.Next() = 0;
    end;

    local procedure InsertReminderTerms()
    var
        ReminderTerms: Record "Reminder Terms";
    begin
        if not ReminderTerms.Get('FOREIGN') then begin
            ReminderTerms.Init();
            ReminderTerms.Code := 'FOREIGN';
            ReminderTerms.Insert();
        end;
    end;
}
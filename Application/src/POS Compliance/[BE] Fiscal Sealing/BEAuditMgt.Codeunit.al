codeunit 6059817 "NPR BE Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddBEAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        CheckAreDataSetAndAccordingToCompliance(FrontEnd);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSStore(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSStoreIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSUnit(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSUnitIfAlreadyUsed(xRec);
    end;

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        BEFiscalizationSetup: Record "NPR BE Fiscalisation Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        BEFiscalizationSetup.ChangeCompany(CompanyName);
        if BEFiscalizationSetup.Get() then
            BEFiscalizationSetup.Delete();
    end;
#endif

    local procedure AddBEAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure CheckAreDataSetAndAccordingToCompliance(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        DummyInteger: Integer;
        CannotBeGreaterErr: Label 'Value from field %1 in table %2 cannot be greater than 99999999.', Comment = '%1 - field caption, %2 - table caption';
        CannotEvaluateErr: Label 'Value %1 from field %2 in table %3 cannot be evaluated into an integer.', Comment = '%1 - value that is being evaluate, %2 - field caption, %3 - table caption';
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not Evaluate(DummyInteger, POSUnit."No.") then
            Error(CannotEvaluateErr, POSUnit."No.", POSUnit.FieldCaption("No."), POSUnit.TableCaption());

        if DummyInteger > 99999999 then
            Error(CannotBeGreaterErr, POSUnit.FieldCaption("No."), POSUnit.TableCaption());

        POSSetup.GetPOSStore(POSStore);
        if not Evaluate(DummyInteger, POSStore.Code) then
            Error(CannotEvaluateErr, POSStore.Code, POSStore.FieldCaption(Code), POSStore.TableCaption());

        if DummyInteger > 99999999 then
            Error(CannotBeGreaterErr, POSStore.FieldCaption(Code), POSStore.TableCaption());
    end;

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not Initialized then begin
            if not POSAuditProfile.Get(POSAuditProfileCode) then
                exit(false);

            if POSAuditProfile."Audit Handler" <> HandlerCode() then
                exit(false);

            Initialized := true;
            Enabled := true;
        end;

        exit(Enabled);
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;

        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if POSAuditLog."Action Type" <> POSAuditLog."Action Type"::DIRECT_SALE_END then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");

        InsertBEPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertBEPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        BEPOSAuditLogAuxInfo, PrevBEPOSAuditLogAuxInfo : Record "NPR BE POS Audit Log Aux. Info";
        NextSealSerialNo, PreviousSealNo : Integer;
    begin
        if FindPreviousBEPOSAuditLogAuxInfo(PrevBEPOSAuditLogAuxInfo, POSUnit) then begin
            PreviousSealNo := PrevBEPOSAuditLogAuxInfo."Seal No.";
            NextSealSerialNo := PrevBEPOSAuditLogAuxInfo."Seal Serial No." + 1;
        end else begin
            PreviousSealNo := 0;
            NextSealSerialNo := 1000;
        end;

        BEPOSAuditLogAuxInfo.Init();
        BEPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        BEPOSAuditLogAuxInfo."Previous Seal No." := PreviousSealNo;
        BEPOSAuditLogAuxInfo."Posting Date" := POSEntry."Posting Date";
        BEPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        BEPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        BEPOSAuditLogAuxInfo."Seal Serial No." := NextSealSerialNo;
        BEPOSAuditLogAuxInfo."Amount Incl. Tax" := POSEntry."Amount Incl. Tax";
        BEPOSAuditLogAuxInfo."Seal No." := CalcSealNo(BEPOSAuditLogAuxInfo);
        BEPOSAuditLogAuxInfo.Insert();
    end;

    local procedure FindPreviousBEPOSAuditLogAuxInfo(var PrevBEPOSAuditLogAuxInfo: Record "NPR BE POS Audit Log Aux. Info"; POSUnit: Record "NPR POS Unit"): Boolean
    begin
        PrevBEPOSAuditLogAuxInfo.SetCurrentKey("POS Unit No.", "Seal Serial No.");
        PrevBEPOSAuditLogAuxInfo.SetRange("POS Unit No.", POSUnit."No.");
        exit(PrevBEPOSAuditLogAuxInfo.FindLast());
    end;

    local procedure CalcSealNo(BEPOSAuditLogAuxInfo: Record "NPR BE POS Audit Log Aux. Info"): Integer
    var
        POSStoreCodeAsInt, PostingDateAsInt, POSUnitNoAsInt, SealNo, SumDetailLines, TotalReceiptAmount : Integer;
        SealNoAsText: Text;
    begin
        Evaluate(PostingDateAsInt, ConvertDateToText(BEPOSAuditLogAuxInfo."Posting Date"));
        Evaluate(POSStoreCodeAsInt, BEPOSAuditLogAuxInfo."POS Store Code");
        Evaluate(POSUnitNoAsInt, BEPOSAuditLogAuxInfo."POS Unit No.");
        SumDetailLines := BEPOSAuditLogAuxInfo."Amount Incl. Tax" * 100;
        TotalReceiptAmount := BEPOSAuditLogAuxInfo."Amount Incl. Tax" * 100;
        SealNo :=
            BEPOSAuditLogAuxInfo."Previous Seal No." +
            PostingDateAsInt +
            POSStoreCodeAsInt +
            POSUnitNoAsInt +
            BEPOSAuditLogAuxInfo."Seal Serial No." +
            SumDetailLines +
            TotalReceiptAmount;

        if SealNo > 99999999 then begin
            SealNoAsText := Format(SealNo);
            SealNoAsText := CopyStr(SealNoAsText, StrLen(SealNoAsText) - 8 + 1);
            Evaluate(SealNo, SealNoAsText);
        end;

        exit(SealNo);
    end;

    local procedure ConvertDateToText(DateToConvert: Date) DateAsText: Text
    begin
        DateAsText := Format(DateToConvert, 0, '<Day,2><Month,2><Year4>');
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        BEPOSAuditLogAuxInfo: Record "NPR BE POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - BE POS Audit Log Aux. Info table caption';
    begin
        BEPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not BEPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, BEPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        BEPOSAuditLogAuxInfo: Record "NPR BE POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - BE POS Audit Log Aux. Info table caption';
    begin
        if not IsEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        BEPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not BEPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", BEPOSAuditLogAuxInfo.TableCaption());
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'BE_FISCALSEALING', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;
}
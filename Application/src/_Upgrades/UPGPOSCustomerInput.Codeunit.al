codeunit 6150731 "NPR UPG POS Customer Input"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradePOSCustomerInputEntryInput();
    end;

    local procedure UpgradePOSCustomerInputEntryInput()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Customer Input', 'UpgradePOSCustomerInputEntryInputTransfer');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradePOSCustomerInputEntryInputTransfer')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePOSCustomerInputEntryInputTransfer();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradePOSCustomerInputEntryInputTransfer'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSCustomerInputEntryInputTransfer()
    var
#IF (BC17 OR BC18 OR BC19 OR BC20)
        POSCostumerInput: Record "NPR POS Costumer Input";
#ENDIF
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20)
        if not POSCostumerInput.FindSet() then
            exit;
        repeat
            InsertPOSCustomerInputEntry(POSCostumerInput);
        until POSCostumerInput.Next() = 0;
#ELSE
        DataTransferPOSCustomerInputEntry();
        //delete extra no signature lines created, since we cannot filter on blob fields with DataTransfer
        DeleteExtraSignatureRows();
#ENDIF
    end;

#IF (BC17 OR BC18 OR BC19 OR BC20)
    local procedure InsertPOSCustomerInputEntry(var POSCostumerInput: Record "NPR POS Costumer Input")
    var
        POSCustomerInputEntry: Record "NPR POS Customer Input Entry";
        SignatureText: Text;
        OutStr: OutStream;
        InStr: InStream;
    begin
        if POSCostumerInput.Signature.HasValue() then begin
            Clear(POSCustomerInputEntry);
            POSCustomerInputEntry.Init();
            POSCustomerInputEntry."POS Entry No." := POSCostumerInput."POS Entry No.";
            POSCustomerInputEntry."Date & Time" := POSCostumerInput."Date & Time";
            POSCustomerInputEntry.Context := POSCostumerInput.Context;
            POSCustomerInputEntry."Information Collected" := POSCustomerInputEntry."Information Collected"::Signature;
            POSCustomerInputEntry.Signature := POSCostumerInput.Signature;
            POSCostumerInput.CalcFields(Signature);
            POSCostumerInput.Signature.CreateInStream(InStr);
            InStr.ReadText(SignatureText);
            POSCustomerInputEntry.Signature.CreateOutStream(OutStr);
            OutStr.WriteText(SignatureText);
            POSCustomerInputEntry.Insert();
        end;
        if POSCostumerInput."Phone Number" <> '' then begin
            Clear(POSCustomerInputEntry);
            POSCustomerInputEntry.Init();
            POSCustomerInputEntry."POS Entry No." := POSCostumerInput."POS Entry No.";
            POSCustomerInputEntry."Date & Time" := POSCostumerInput."Date & Time";
            POSCustomerInputEntry.Context := POSCostumerInput.Context;
            POSCustomerInputEntry."Information Collected" := POSCustomerInputEntry."Information Collected"::"Phone No.";
            POSCustomerInputEntry."Information Value" := POSCostumerInput."Phone Number";
            POSCustomerInputEntry.Signature.CreateOutStream(OutStr);
            POSCustomerInputEntry.Insert();
        end;
        if POSCostumerInput."E-Mail" <> '' then begin
            Clear(POSCustomerInputEntry);
            POSCustomerInputEntry.Init();
            POSCustomerInputEntry."POS Entry No." := POSCostumerInput."POS Entry No.";
            POSCustomerInputEntry."Date & Time" := POSCostumerInput."Date & Time";
            POSCustomerInputEntry.Context := POSCostumerInput.Context;
            POSCustomerInputEntry."Information Collected" := POSCustomerInputEntry."Information Collected"::"E-Mail";
            POSCustomerInputEntry."Information Value" := POSCostumerInput."E-Mail";
            POSCustomerInputEntry.Signature.CreateOutStream(OutStr);
            POSCustomerInputEntry.Insert();
        end;
    end;
#ELSE
    local procedure DataTransferPOSCustomerInputEntry()
    var
        POSCustomerInputEntry: Record "NPR POS Customer Input Entry";
        POSCostumerInput: Record "NPR POS Costumer Input";
        DTransfer: DataTransfer;
    begin
        DTransfer.SetTables(Database::"NPR POS Costumer Input", Database::"NPR POS Customer Input Entry");
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("POS Entry No."), POSCustomerInputEntry.FieldNo("POS Entry No."));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("Date & Time"), POSCustomerInputEntry.FieldNo("Date & Time"));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo(Context), POSCustomerInputEntry.FieldNo(Context));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo(Signature), POSCustomerInputEntry.FieldNo(Signature));
        DTransfer.AddConstantValue(POSCustomerInputEntry."Information Collected"::Signature, POSCustomerInputEntry.FieldNo("Information Collected"));
        DTransfer.CopyRows();

        Clear(DTransfer);
        DTransfer.SetTables(Database::"NPR POS Costumer Input", Database::"NPR POS Customer Input Entry");
        DTransfer.AddSourceFilter(POSCostumerInput.FieldNo("Phone Number"), '<>%1', '');
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("POS Entry No."), POSCustomerInputEntry.FieldNo("POS Entry No."));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("Date & Time"), POSCustomerInputEntry.FieldNo("Date & Time"));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo(Context), POSCustomerInputEntry.FieldNo(Context));
        DTransfer.AddConstantValue(POSCustomerInputEntry."Information Collected"::"Phone No.", POSCustomerInputEntry.FieldNo("Information Collected"));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("Phone Number"), POSCustomerInputEntry.FieldNo("Information Value"));
        DTransfer.CopyRows();

        Clear(DTransfer);
        DTransfer.SetTables(Database::"NPR POS Costumer Input", Database::"NPR POS Customer Input Entry");
        DTransfer.AddSourceFilter(POSCostumerInput.FieldNo("E-Mail"), '<>%1', '');
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("POS Entry No."), POSCustomerInputEntry.FieldNo("POS Entry No."));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("Date & Time"), POSCustomerInputEntry.FieldNo("Date & Time"));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo(Context), POSCustomerInputEntry.FieldNo(Context));
        DTransfer.AddConstantValue(POSCustomerInputEntry."Information Collected"::"E-Mail", POSCustomerInputEntry.FieldNo("Information Collected"));
        DTransfer.AddFieldValue(POSCostumerInput.FieldNo("E-Mail"), POSCustomerInputEntry.FieldNo("Information Value"));
        DTransfer.CopyRows();
    end;

    local procedure DeleteExtraSignatureRows()
    var
        POSCustomerInputEntry: Record "NPR POS Customer Input Entry";
    begin
        POSCustomerInputEntry.SetRange("Information Collected", POSCustomerInputEntry."Information Collected"::Signature);
        if not POSCustomerInputEntry.FindSet() then
            exit;
        repeat
            if not POSCustomerInputEntry.Signature.HasValue() then
                POSCustomerInputEntry.Delete();
        until POSCustomerInputEntry.Next() = 0;
    end;
#ENDIF

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Customer Input");
    end;
}

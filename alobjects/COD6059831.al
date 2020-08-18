codeunit 6059831 "RFID Mgt."
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object
    // NPR5.53/MMV /20191114 CASE 377115 Removed confirm dialog. Added event instead for any future customization.
    // NPR5.55/MMV /20200305 CASE 391561 Rolled back part of #377115
    // NPR5.55/MMV /20200708 CASE 407265 Split insert item cross reference function into two to avoid locking reads.


    trigger OnRun()
    begin
    end;

    var
        TXT_SAVE_RFID: Label 'Transfer all RFID values to Item Cross Reference? (Only do this if tag printing was successful and will be used!)';
        ERR_RFID_CLASH: Label 'RFID value already exists';
        ERR_RFID_VALUE_LENGTH: Label 'RFID value %1 is longer than limit';

    procedure LogRFIDPrint(var RetailJournalLine: Record "Retail Journal Line";BatchID: Guid)
    var
        RFIDPrintLog: Record "RFID Print Log";
    begin
        //-NPR5.55 [407265]
        RFIDPrintLog.Init;
        RFIDPrintLog."Item No." := RetailJournalLine."Item No.";
        RFIDPrintLog."Variant Code" := RetailJournalLine."Variant Code";
        RFIDPrintLog.Barcode := RetailJournalLine.Barcode;
        RFIDPrintLog.Description := RetailJournalLine.Description;
        RFIDPrintLog."RFID Tag Value" := RetailJournalLine."RFID Tag Value";
        RFIDPrintLog."Batch ID" := BatchID;
        RFIDPrintLog."User ID" := UserId;
        RFIDPrintLog."Printed At" := CurrentDateTime;
        RFIDPrintLog.Insert;
        //+NPR5.55 [407265]
    end;

    procedure GetNextRFIDValue(): Text
    var
        RFIDSetup: Record "RFID Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        BigInt: BigInteger;
        HexValue: Text;
    begin
        RFIDSetup.Get;
        RFIDSetup.TestField("RFID Value No. Series");
        RFIDSetup.TestField("RFID Hex Value Length");
        Evaluate(BigInt,NoSeriesManagement.GetNextNo(RFIDSetup."RFID Value No. Series",WorkDate,true));
        HexValue := IntToHex(BigInt);

        if StrLen(HexValue) > RFIDSetup."RFID Hex Value Length" then
          Error(ERR_RFID_VALUE_LENGTH, HexValue);

        exit(RFIDSetup."RFID Hex Value Prefix" + PadLeft(HexValue,'0',RFIDSetup."RFID Hex Value Length"));
    end;

    procedure CheckItemCrossReference(TagValue: Text)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.55 [407265]
        ItemCrossReference.SetCurrentKey("Cross-Reference No.");
        ItemCrossReference.SetRange("Cross-Reference No.", TagValue);
        if not ItemCrossReference.IsEmpty then
          ItemCrossReference.FieldError("Cross-Reference No.", ERR_RFID_CLASH);
        //+NPR5.55 [407265]
    end;

    procedure InsertItemCrossReference(ItemNo: Text;VariantCode: Text;TagValue: Text)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        ItemCrossReference.Init;
        ItemCrossReference.Validate("Item No.", ItemNo);
        ItemCrossReference.Validate("Variant Code", VariantCode);
        ItemCrossReference.Validate("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.Validate("Cross-Reference No.", TagValue);
        ItemCrossReference.Validate("Is Retail Serial No.", true);
        ItemCrossReference.Insert(true);
    end;

    local procedure IntToHex(BigInt: BigInteger): Text
    var
        IntPtr: DotNet npNetIntPtr;
    begin
        IntPtr := IntPtr.IntPtr(BigInt);
        exit(IntPtr.ToString('X'));
    end;

    local procedure PadLeft(Value: Text;PadChar: Text[1];Length: Integer): Text
    begin
        if StrLen(Value) >= Length then
          exit(Value);
        exit(PadStr('', Length - StrLen(Value), PadChar) + Value);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSaveItemCrossReferenceValue(var RetailJournalLine: Record "Retail Journal Line")
    begin
    end;
}


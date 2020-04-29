codeunit 6059831 "RFID Mgt."
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object
    // NPR5.53/MMV /20191114 CASE 377115 Removed confirm dialog. Added event instead for any future customization.


    trigger OnRun()
    begin
    end;

    var
        TXT_SAVE_RFID: Label 'Transfer all RFID values to Item Cross Reference? (Only do this if tag printing was successful and will be used!)';
        ERR_RFID_CLASH: Label 'RFID value already exists';
        ERR_RFID_VALUE_LENGTH: Label 'RFID value %1 is longer than limit';

    procedure SaveRFIDValues(var RecRef: RecordRef)
    var
        RetailJournalLine: Record "Retail Journal Line";
        FieldRef: FieldRef;
    begin
        //-NPR5.53 [377115]
        // FieldRef := RecRef.FIELD(RetailJournalLine.FIELDNO("RFID Tag Value"));
        // FieldRef.SETFILTER('<>%1', '');
        // IF NOT RecRef.FINDSET THEN
        //  EXIT;
        //
        // IF NOT CONFIRM(TXT_SAVE_RFID, TRUE) THEN
        //  EXIT;
        //
        // REPEAT
        //  RecRef.SETTABLE(RetailJournalLine);
        //  InsertItemCrossReference(RetailJournalLine."Item No.", RetailJournalLine."Variant Code", RetailJournalLine."RFID Tag Value");
        // UNTIL RecRef.NEXT = 0;

        RecRef.SetTable(RetailJournalLine);
        RetailJournalLine.SetFilter("RFID Tag Value", '<>%1', '');
        if not RetailJournalLine.FindSet then
          exit;

        OnBeforeSaveItemCrossReferenceValues(RetailJournalLine);

        repeat
          InsertItemCrossReference(RetailJournalLine."Item No.", RetailJournalLine."Variant Code", RetailJournalLine."RFID Tag Value");
        until RetailJournalLine.Next = 0;
        //+NPR5.53 [377115]
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

    procedure InsertItemCrossReference(ItemNo: Text;VariantCode: Text;TagValue: Text)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        ItemCrossReference.SetCurrentKey("Cross-Reference No.");
        ItemCrossReference.SetRange("Cross-Reference No.", TagValue);
        if ItemCrossReference.FindFirst then
          ItemCrossReference.FieldError("Cross-Reference No.", ERR_RFID_CLASH);

        ItemCrossReference.Reset;

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
    local procedure OnBeforeSaveItemCrossReferenceValues(var RetailJournalLine: Record "Retail Journal Line")
    begin
    end;
}


codeunit 6059831 "RFID Mgt."
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object


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
        FieldRef := RecRef.Field(RetailJournalLine.FieldNo("RFID Tag Value"));
        FieldRef.SetFilter('<>%1', '');
        if not RecRef.FindSet then
          exit;

        if not Confirm(TXT_SAVE_RFID, true) then
          exit;

        repeat
          RecRef.SetTable(RetailJournalLine);
          InsertItemCrossReference(RetailJournalLine."Item No.", RetailJournalLine."Variant Code", RetailJournalLine."RFID Tag Value");
        until RecRef.Next = 0;
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
        ItemCrossReference.Validate("Rfid Tag", true);
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
}


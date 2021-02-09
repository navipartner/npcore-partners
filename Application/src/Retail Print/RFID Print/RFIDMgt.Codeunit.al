codeunit 6059831 "NPR RFID Mgt."
{
    var
        ERR_RFID_CLASH: Label 'RFID value already exists';
        ERR_RFID_VALUE_LENGTH: Label 'RFID value %1 is longer than limit', Comment = '%1=HexValue of RFIDSetup."RFID Value No. Series"';

    procedure LogRFIDPrint(var RetailJournalLine: Record "NPR Retail Journal Line"; BatchID: Guid)
    var
        RFIDPrintLog: Record "NPR RFID Print Log";
    begin
        RFIDPrintLog.Init();
        RFIDPrintLog."Item No." := RetailJournalLine."Item No.";
        RFIDPrintLog."Variant Code" := RetailJournalLine."Variant Code";
        RFIDPrintLog.Barcode := RetailJournalLine.Barcode;
        RFIDPrintLog.Description := RetailJournalLine.Description;
        RFIDPrintLog."RFID Tag Value" := RetailJournalLine."RFID Tag Value";
        RFIDPrintLog."Batch ID" := BatchID;
        RFIDPrintLog."User ID" := UserId();
        RFIDPrintLog."Printed At" := CurrentDateTime();
        RFIDPrintLog.Insert();
    end;

    procedure GetNextRFIDValue(): Text
    var
        RFIDSetup: Record "NPR RFID Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        BigInt: BigInteger;
        HexValue: Text;
    begin
        RFIDSetup.Get;
        RFIDSetup.TestField("RFID Value No. Series");
        RFIDSetup.TestField("RFID Hex Value Length");
        Evaluate(BigInt, NoSeriesManagement.GetNextNo(RFIDSetup."RFID Value No. Series", WorkDate, true));
        HexValue := IntToHex(BigInt);

        if StrLen(HexValue) > RFIDSetup."RFID Hex Value Length" then
            Error(ERR_RFID_VALUE_LENGTH, HexValue);

        exit(RFIDSetup."RFID Hex Value Prefix" + PadLeft(HexValue, '0', RFIDSetup."RFID Hex Value Length"));
    end;

    procedure CheckItemReference(TagValue: Text)
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetCurrentKey("Reference No.");
        ItemReference.SetRange("Reference No.", TagValue);
        if not ItemReference.IsEmpty() then
            ItemReference.FieldError("Reference No.", ERR_RFID_CLASH);
    end;

    procedure InsertItemReference(ItemNo: Text; VariantCode: Text; TagValue: Text)
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.Init();
        ItemReference.Validate("Item No.", ItemNo);
        ItemReference.Validate("Variant Code", VariantCode);
        ItemReference.Validate("Reference Type", ItemReference."Reference Type"::"Retail Serial No.");
        ItemReference.Validate("Reference No.", TagValue);
        ItemReference.Insert(true);
    end;

    local procedure IntToHex(BigInt: BigInteger): Text
    var
        HexValue: Text;
    begin
        ToHexadecimal(BigInt, HexValue);
        exit(Reverse(HexValue));
    end;

    local procedure PadLeft(Value: Text; PadChar: Text[1]; Length: Integer): Text
    begin
        if StrLen(Value) >= Length then
            exit(Value);
        exit(PadStr('', Length - StrLen(Value), PadChar) + Value);
    end;

    local procedure Reverse(CurrValue: Text): Text
    var
        ReverseValue: Text;
        I, J : Integer;
    begin
        if CurrValue = '' then
            exit;
        J := 0;
        FOR I := StrLen(CurrValue) DOWNTO 1 DO BEGIN
            J += 1;
            ReverseValue[J] := CurrValue[I];
        END;
        exit(ReverseValue);
    end;

    local procedure ToHexadecimal(var Result: BigInteger; var HexReminder: Text)
    var
        Reminder: Integer;
    begin
        Reminder := Result mod 16;
        if (Result = 0) and (Reminder = 0) then begin
            if HexReminder = '' then
                HexReminder := '0';
            exit;
        end;

        Result := Result div 16;

        case Reminder of
            0:
                begin
                    HexReminder += '0';
                end;
            1:
                begin
                    HexReminder += '1';
                end;
            2:
                begin
                    HexReminder += '2';
                end;
            3:
                begin
                    HexReminder += '3';
                end;
            4:
                begin
                    HexReminder += '4';
                end;
            5:
                begin
                    HexReminder += '5';
                end;
            6:
                begin
                    HexReminder += '6';
                end;
            7:
                begin
                    HexReminder += '7';
                end;
            8:
                begin
                    HexReminder += '8';
                end;
            9:
                begin
                    HexReminder += '9';
                end;
            10:
                begin
                    HexReminder += 'A';
                end;
            11:
                begin
                    HexReminder += 'B';
                end;
            12:
                begin
                    HexReminder += 'C';
                end;
            13:
                begin
                    HexReminder += 'D';
                end;
            14:
                begin
                    HexReminder += 'E';
                end;
            15:
                begin
                    HexReminder += 'F';
                end;
        end;
        ToHexadecimal(Result, HexReminder);
    end;


    [IntegrationEvent(false, false)]
    procedure OnBeforeSaveItemReferenceValue(var RetailJournalLine: Record "NPR Retail Journal Line")
    begin
    end;
}


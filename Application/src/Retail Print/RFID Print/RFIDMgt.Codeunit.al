codeunit 6059831 "NPR RFID Mgt."
{
    Access = Internal;

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
#pragma warning disable AA0139
        RFIDPrintLog."User ID" := UserId();
#pragma warning restore AA0139
        RFIDPrintLog."Printed At" := CurrentDateTime();
        RFIDPrintLog.Insert();
    end;

    procedure GetNextRFIDValue(): Text
    var
        RFIDSetup: Record "NPR RFID Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        BigInt: BigInteger;
        HexValue: Text;
    begin
        RFIDSetup.Get();
        RFIDSetup.TestField("RFID Value No. Series");
        RFIDSetup.TestField("RFID Hex Value Length");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        Evaluate(BigInt, NoSeriesManagement.GetNextNo(RFIDSetup."RFID Value No. Series", WorkDate(), false));
#ELSE
        Evaluate(BigInt, NoSeriesManagement.GetNextNo(RFIDSetup."RFID Value No. Series", WorkDate(), true));
#ENDIF
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
        if not ItemReference.IsEmpty() then begin
            ItemReference.FindFirst();
            ItemReference.FieldError("Reference No.", ERR_RFID_CLASH);
        end;
    end;

    procedure InsertItemReference(ItemNo: Text; VariantCode: Text; TagValue: Text)
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.Init();
        ItemReference.Validate("Item No.", ItemNo);
        ItemReference.Validate("Variant Code", VariantCode);
        ItemReference.Validate("Reference Type", ItemReference."Reference Type"::"NPR Retail Serial No.");
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
    internal procedure OnBeforeSaveItemReferenceValue(var RetailJournalLine: Record "NPR Retail Journal Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure DiscontinueBarcodeOnAfterSale(SalePOS: Record "NPR POS Sale")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ItemReference: Record "Item Reference";
        IsHandled: Boolean;
        ItemReferenceMgt: Codeunit "NPR Item Reference Mgt.";
    begin
        if (SalePOS."Sales Ticket No." = '') then
            exit;

        ItemReferenceMgt.OnBeforeDiscontinueBarcode(SalePOS, IsHandled);
        if IsHandled then
            exit;

        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetCurrentKey("Document No.", "Line No.");
        POSEntrySalesLine.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetFilter("Retail Serial No.", '<>%1', '');

        if POSEntrySalesLine.FindSet() then begin
            repeat
                ItemReference.SetRange("Item No.", POSEntrySalesLine."No.");
                ItemReference.SetRange("Variant Code", POSEntrySalesLine."Variant Code");
                ItemReference.SetRange("Unit of Measure", POSEntrySalesLine."Unit of Measure Code");
                ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"NPR Retail Serial No.");
                ItemReference.SetRange("Reference No.", POSEntrySalesLine."Retail Serial No.");

                if ItemReference.FindFirst() then begin
                    if POSEntrySalesLine.Quantity > 0 then begin
                        ItemReference."NPR Discontinued Barcode" := true;
                        ItemReference."NPR Discontinued Reason" := ItemReference."NPR Discontinued Reason"::Sale;
                    end else begin
                        ItemReference."NPR Discontinued Barcode" := false;
                        ItemReference."NPR Discontinued Reason" := ItemReference."NPR Discontinued Reason"::Return;
                    end;

                    ItemReference.Modify(true);
                end;
            until POSEntrySalesLine.Next() = 0;
        end;
    end;
}

table 6150741 "NPR IT POS Paym. Method Mapp."
{
    Access = Internal;
    Caption = 'IT POS Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR IT POS Paym. Method Mapp.";
    LookupPageId = "NPR IT POS Paym. Method Mapp.";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(3; "POS Unit No."; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(4; "IT Payment Method"; Enum "NPR IT Payment Method")
        {
            Caption = 'IT Payment Method';
            DataClassification = CustomerContent;
        }
        field(5; "IT Payment Method Index"; Integer)
        {
            Caption = 'IT Payment Method Index';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidatePaymentMethodIndex();
            end;
        }
        field(6; "IT Payment Method Description"; Text[20])
        {
            Caption = 'IT Payment Method Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Payment Method Code")
        {
            Clustered = true;
        }
        key(Key2; "Payment Method Code") { }
        key(Key3; "POS Unit No.") { }
    }

    local procedure ValidatePaymentMethodIndex()
    begin
        if "Payment Method Code" = '' then
            exit;

        case "IT Payment Method" of
            "NPR IT Payment Method"::"0":
                CheckPaymMethIndexRange(0, 5);
            "NPR IT Payment Method"::"2":
                CheckPaymMethIndexRange(1, 10);
            "NPR IT Payment Method"::"3":
                CheckPaymMethIndexRange(1, 10);
            else
                exit;
        end;
    end;

    local procedure CheckPaymMethIndexRange(FromRange: Integer; ToRange: Integer)
    var
        RangeValueNotSupportedErr: Label 'Index value not supported. Index must be in range %1-%2.', Comment = '%1 = From Range, %2 = To Range';
        ErrorMessage: Text;
    begin
        if not ("IT Payment Method Index" in [FromRange .. ToRange]) then begin
            ErrorMessage := StrSubstNo(RangeValueNotSupportedErr, FromRange, ToRange);
            Error(ErrorMessage);
        end;
    end;

    internal procedure InitITPOSPaymentMethods()
    var
        POSUnit: Record "NPR POS Unit";
        ITPOSPaymentMethodMapping: Record "NPR IT POS Paym. Method Mapp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EntryNo: Integer;
    begin
        POSPaymentMethod.SetFilter("Processing Type", '%1|%2|%3', "NPR Payment Processing Type"::CASH, "NPR Payment Processing Type"::CHECK, "NPR Payment Processing Type"::EFT);
        if not POSPaymentMethod.FindSet() then
            exit;
        if not POSUnit.FindSet() then
            exit;

        EntryNo := GetLastEntryNo();
        repeat
            repeat
                ITPOSPaymentMethodMapping.SetRange("POS Unit No.", POSUnit."No.");
                ITPOSPaymentMethodMapping.SetRange("Payment Method Code", POSPaymentMethod.Code);
                if not ITPOSPaymentMethodMapping.FindFirst() then begin
                    ITPOSPaymentMethodMapping.Init();
                    EntryNo := EntryNo + 1;
                    ITPOSPaymentMethodMapping."Entry No." := EntryNo;
                    ITPOSPaymentMethodMapping."Payment Method Code" := POSPaymentMethod.Code;
                    ITPOSPaymentMethodMapping."POS Unit No." := POSUnit."No.";
                    ITPOSPaymentMethodMapping.Insert();
                end
            until POSPaymentMethod.Next() = 0;
        until POSUnit.Next() = 0;
    end;

    local procedure GetLastEntryNo(): Integer
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
}
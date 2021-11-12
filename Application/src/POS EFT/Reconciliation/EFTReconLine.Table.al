table 6014617 "NPR EFT Recon. Line"
{
    Caption = 'EFT Reconciliation Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reconciliation No."; Code[20])
        {
            Caption = 'Reconciliation No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Reconciliation";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(30; "Fee Amount"; Decimal)
        {
            Caption = 'Fee';
            DataClassification = CustomerContent;
        }
        field(40; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(100; "Application Account ID"; Code[30])
        {
            Caption = 'Application Account ID';
            DataClassification = CustomerContent;
        }
        field(110; "Card Type"; Text[4])
        {
            Caption = 'Card Type';
            DataClassification = CustomerContent;
        }
        field(120; "Card Name"; Text[24])
        {
            Caption = 'Card Name';
            DataClassification = CustomerContent;
        }
        field(130; "Card Number"; Text[30])
        {
            Caption = 'Card Number';
            DataClassification = CustomerContent;
        }
        field(140; "Reference Number"; Text[50])
        {
            Caption = 'Reference Number';
            DataClassification = CustomerContent;
        }
        field(150; "Hardware ID"; Text[200])
        {
            Caption = 'Hardware ID';
            DataClassification = CustomerContent;
        }
        field(190; "Alt. Reference Number"; Text[30])
        {
            Caption = 'Alt. Reference Number';
            DataClassification = CustomerContent;
        }
        field(200; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(202; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(205; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(300; "Applied Entry No."; Integer)
        {
            Caption = 'Applied Entry No.';
            DataClassification = CustomerContent;
        }
        field(310; "Applied Amount"; Decimal)
        {
            Caption = 'Applied Amount';
            DataClassification = CustomerContent;
        }
        field(320; "Applied Fee Amount"; Decimal)
        {
            Caption = 'Applied Fee Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Reconciliation No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;


    procedure ApplyTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        if "Applied Entry No." <> 0 then
            exit;
        "Applied Entry No." := EFTTransactionRequest."Entry No.";
        "Applied Amount" := EFTTransactionRequest."Result Amount";
        "Applied Fee Amount" := EFTTransactionRequest."Fee Amount";
        POSPaymentLine.SetRange("Document No.", EFTTransactionRequest."Sales Ticket No.");
        POSPaymentLine.SetRange("POS Unit No.", EFTTransactionRequest."Register No.");
        POSPaymentLine.SetRange(EFT, true);
        if POSPaymentLine.FindFirst() then begin
            "Shortcut Dimension 1 Code" := POSPaymentLine."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := POSPaymentLine."Shortcut Dimension 2 Code";
            "Dimension Set ID" := POSPaymentLine."Dimension Set ID";
        end;
        Modify(true);
    end;


    procedure UnApply()
    begin
        if "Applied Entry No." = 0 then
            exit;
        "Applied Entry No." := 0;
        "Applied Amount" := 0;
        "Applied Fee Amount" := 0;
        Modify(true);
    end;
}


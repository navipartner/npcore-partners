table 6014615 "NPR EFT Recon. Bank Amount"
{
    Caption = 'EFT Recon. Bank Amount';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reconciliation No."; Code[20])
        {
            Caption = 'Reconciliation No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Reconciliation";
        }
        field(2; "Application Account ID"; Code[30])
        {
            Caption = 'Application Account ID';
            DataClassification = CustomerContent;
        }
        field(100; "Bank Information"; Text[50])
        {
            Caption = 'Bank Information';
            DataClassification = CustomerContent;
        }
        field(110; "Bank Transfer Date"; Date)
        {
            Caption = 'Bank Transfer Date';
            DataClassification = CustomerContent;
        }
        field(120; "Bank Amount"; Decimal)
        {
            Caption = 'Bank Amount';
            DataClassification = CustomerContent;
        }
        field(130; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(140; "Transaction Fee Amount"; Decimal)
        {
            Caption = 'Transaction Fee Amount';
            DataClassification = CustomerContent;
        }
        field(150; "Subscription Amount"; Decimal)
        {
            Caption = 'Subscription Amount';
            DataClassification = CustomerContent;
        }
        field(160; "Adjustment Amount"; Decimal)
        {
            Caption = 'Adjustment Amount';
            DataClassification = CustomerContent;
        }
        field(170; "Chargeback Amount"; Decimal)
        {
            Caption = 'Chargeback Amount';
            DataClassification = CustomerContent;
        }
        field(200; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(202; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(205; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(210; "Exclude from Posting"; Boolean)
        {
            Caption = 'Exclude from Posting';
            DataClassification = CustomerContent;
        }
        field(300; "Line Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line".Amount where("Reconciliation No." = field("Reconciliation No."),
                                                              "Application Account ID" = field("Application Account ID"),
                                                              "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                              "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code")));
            Caption = 'Line Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "Line Fee Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line"."Fee Amount" where("Reconciliation No." = field("Reconciliation No."),
                                                                    "Application Account ID" = field("Application Account ID"),
                                                                    "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                                    "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code")));
            Caption = 'Line Fee Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320; "No. Of Lines"; Integer)
        {
            CalcFormula = count("NPR EFT Recon. Line" where("Reconciliation No." = field("Reconciliation No."),
                                                         "Application Account ID" = field("Application Account ID"),
                                                         "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                         "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code")));
            Caption = 'No. Of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(330; "Applied Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line"."Applied Amount" where("Reconciliation No." = field("Reconciliation No."),
                                                                        "Application Account ID" = field("Application Account ID"),
                                                                        "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                                        "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code")));
            Caption = 'Applied Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(340; "Applied Fee Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line"."Applied Fee Amount" where("Reconciliation No." = field("Reconciliation No."),
                                                                            "Application Account ID" = field("Application Account ID"),
                                                                            "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                                            "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code")));
            Caption = 'Applied Fee Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(350; "No. Of Applied Lines"; Integer)
        {
            CalcFormula = count("NPR EFT Recon. Line" where("Reconciliation No." = field("Reconciliation No."),
                                                         "Application Account ID" = field("Application Account ID"),
                                                         "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                         "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code"),
                                                         "Applied Entry No." = filter(<> 0)));
            Caption = 'No. Of Applied Lines';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Reconciliation No.", "Application Account ID")
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
}


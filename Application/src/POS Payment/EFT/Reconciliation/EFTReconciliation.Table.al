table 6014616 "NPR EFT Reconciliation"
{
    Access = Internal;
    Caption = 'EFT Reconciliation';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR EFT Reconciliation List";
    LookupPageID = "NPR EFT Reconciliation List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Provider Code"; Code[20])
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Recon. Provider";
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Created,Reconciling,Posted';
            OptionMembers = Created,Reconciling,Posted;
        }
        field(30; "Account ID"; Text[30])
        {
            Caption = 'Account ID';
            DataClassification = CustomerContent;
        }
        field(40; "Advis ID"; Text[30])
        {
            Caption = 'Advis ID';
            DataClassification = CustomerContent;
        }
        field(50; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; Filename; Text[80])
        {
            Caption = 'Filename';
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
        field(120; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(130; "Transaction Fee Amount"; Decimal)
        {
            Caption = 'Transaction Fee Amount';
            DataClassification = CustomerContent;
        }
        field(140; "First Transaction Date"; Date)
        {
            Caption = 'First Transaction Date';
            DataClassification = CustomerContent;
        }
        field(150; "Last Transaction Date"; Date)
        {
            Caption = 'Last Transaction Date';
            DataClassification = CustomerContent;
        }
        field(160; "Bank Amount"; Decimal)
        {
            Caption = 'Bank Amount';
            DataClassification = CustomerContent;
        }
        field(200; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(210; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(300; "Line Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line".Amount where("Reconciliation No." = field("No."),
                                                              "Shortcut Dimension 1 Code" = field(filter("Global Dimension 1 Filter")),
                                                              "Shortcut Dimension 2 Code" = field(filter("Global Dimension 2 Filter"))));
            Caption = 'Line Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "Line Fee Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line"."Fee Amount" where("Reconciliation No." = field("No."),
                                                                    "Shortcut Dimension 1 Code" = field(filter("Global Dimension 1 Filter")),
                                                                    "Shortcut Dimension 2 Code" = field(filter("Global Dimension 2 Filter"))));
            Caption = 'Line Fee Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320; "No. Of Lines"; Integer)
        {
            CalcFormula = count("NPR EFT Recon. Line" where("Reconciliation No." = field("No."),
                                                         "Shortcut Dimension 1 Code" = field(filter("Global Dimension 1 Filter")),
                                                         "Shortcut Dimension 2 Code" = field(filter("Global Dimension 2 Filter"))));
            Caption = 'No. Of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(330; "Applied Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line"."Applied Amount" where("Reconciliation No." = field("No."),
                                                                        "Shortcut Dimension 1 Code" = field(filter("Global Dimension 1 Filter")),
                                                                        "Shortcut Dimension 2 Code" = field(filter("Global Dimension 2 Filter"))));
            Caption = 'Applied Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(340; "Applied Fee Amount"; Decimal)
        {
            CalcFormula = sum("NPR EFT Recon. Line"."Applied Fee Amount" where("Reconciliation No." = field("No."),
                                                                            "Shortcut Dimension 1 Code" = field(filter("Global Dimension 1 Filter")),
                                                                            "Shortcut Dimension 2 Code" = field(filter("Global Dimension 2 Filter"))));
            Caption = 'Applied Fee Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(350; "No. Of Applied Lines"; Integer)
        {
            CalcFormula = count("NPR EFT Recon. Line" where("Reconciliation No." = field("No."),
                                                         "Applied Entry No." = filter(<> 0),
                                                         "Shortcut Dimension 1 Code" = field(filter("Global Dimension 1 Filter")),
                                                         "Shortcut Dimension 2 Code" = field(filter("Global Dimension 2 Filter"))));
            Caption = 'No. Of Applied Lines';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Provider Code", "Bank Transfer Date")
        {
        }
    }

    var
        StatusPostedText: label '%1 is %2';


    procedure CheckUnpostedStatus()
    begin
        if Status = Status::Posted then
            Error(StatusPostedText, TableCaption, Status);
    end;
}


table 6151081 "ExRv Voucher"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher

    Caption = 'External Retail Voucher';
    DataClassification = CustomerContent;
    DrillDownPageID = "ExRv Vouchers";
    LookupPageID = "ExRv Vouchers";

    fields
    {
        field(1; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "ExRv Voucher Type";
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Issued at"; DateTime)
        {
            Caption = 'Issued at';
            DataClassification = CustomerContent;
        }
        field(15; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(25; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(30; "Source Type"; Option)
        {
            Caption = 'Source Table No.';
            DataClassification = CustomerContent;
            OptionCaption = 'Gift Voucher';
            OptionMembers = "Gift Voucher";
        }
        field(35; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Type" = CONST("Gift Voucher")) "Gift Voucher"."No.";
        }
        field(40; "Reference No."; Code[20])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(45; "Online Reference No."; Code[20])
        {
            Caption = 'Online Reference No.';
            DataClassification = CustomerContent;
        }
        field(100; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(105; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(110; "Closed at"; Date)
        {
            Caption = 'Closed at';
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim;
            end;
        }
        field(485; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(490; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Voucher Type", "No.")
        {
        }
    }

    fieldgroups
    {
    }

    [IntegrationEvent(TRUE, false)]
    procedure IsOpen()
    begin
    end;

    procedure ShowDocDim()
    var
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then
            Modify;
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify;

        if OldDimSetID <> "Dimension Set ID" then
            Modify;
    end;
}


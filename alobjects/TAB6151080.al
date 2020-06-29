table 6151080 "ExRv Voucher Type"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher

    Caption = 'External Retail Voucher Type';
    DrillDownPageID = "ExRv Voucher Types";
    LookupPageID = "ExRv Voucher Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(10; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                 "Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(15; "Source Type"; Option)
        {
            Caption = 'Source Table No.';
            OptionCaption = 'Gift Voucher';
            OptionMembers = "Gift Voucher";
        }
        field(20; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
        }
        field(25; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(64; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
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
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(1000; Amount; Decimal)
        {
            CalcFormula = Sum ("ExRv Voucher".Amount WHERE("Voucher Type" = FIELD(Code),
                                                           "Posting Date" = FIELD("Date Filter")));
            Caption = 'Amount';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "Remaining Amount"; Decimal)
        {
            CalcFormula = Sum ("ExRv Voucher"."Remaining Amount" WHERE("Voucher Type" = FIELD(Code),
                                                                       "Posting Date" = FIELD("Date Filter")));
            Caption = 'Remaining Amount';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ShowDocDim()
    var
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', TableCaption, Code),
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
        if Code <> '' then
            Modify;

        if OldDimSetID <> "Dimension Set ID" then
            Modify;
    end;
}


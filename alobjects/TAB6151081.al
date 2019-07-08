table 6151081 "ExRv Voucher"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher

    Caption = 'External Retail Voucher';
    DrillDownPageID = "ExRv Vouchers";
    LookupPageID = "ExRv Vouchers";

    fields
    {
        field(1;"Voucher Type";Code[20])
        {
            Caption = 'Voucher Type';
            NotBlank = true;
            TableRelation = "ExRv Voucher Type";
        }
        field(5;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(10;"Issued at";DateTime)
        {
            Caption = 'Issued at';
        }
        field(15;Amount;Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2:5;
        }
        field(20;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(25;Posted;Boolean)
        {
            Caption = 'Posted';
        }
        field(30;"Source Type";Option)
        {
            Caption = 'Source Table No.';
            OptionCaption = 'Gift Voucher';
            OptionMembers = "Gift Voucher";
        }
        field(35;"Source No.";Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Source Type"=CONST("Gift Voucher")) "Gift Voucher"."No.";
        }
        field(40;"Reference No.";Code[20])
        {
            Caption = 'Reference No.';
        }
        field(45;"Online Reference No.";Code[20])
        {
            Caption = 'Online Reference No.';
        }
        field(100;Open;Boolean)
        {
            Caption = 'Open';
        }
        field(105;"Remaining Amount";Decimal)
        {
            Caption = 'Remaining Amount';
            DecimalPlaces = 2:5;
        }
        field(110;"Closed at";Date)
        {
            Caption = 'Closed at';
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim;
            end;
        }
        field(485;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
            end;
        }
        field(490;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1;"Voucher Type","No.")
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
          DimMgt.EditDimensionSet2(
            "Dimension Set ID",StrSubstNo('%1 %2',TableCaption,"No."),
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then
          Modify;
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber,ShortcutDimCode,"Dimension Set ID");
        if "No." <> '' then
          Modify;

        if OldDimSetID <> "Dimension Set ID" then
          Modify;
    end;
}


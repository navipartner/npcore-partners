table 6150902 "HC Register"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector: Created object based on Table 6014407
    // NPR5.48/TJ  /20181113 CASE 331992 Using proper table ID for dimension validation

    Caption = 'HC Register';
    DataClassification = CustomerContent;
    LookupPageID = "HC Register List";
    Permissions =;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
            DataClassification = CustomerContent;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(11; Account; Code[20])
        {
            Caption = 'Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if Account <> '' then begin
                    if Account = "Gift Voucher Account" then
                        Error(ErrGavekort);

                    if Account = "Credit Voucher Account" then
                        Error(ErrTilgode);
                end;
            end;
        }
        field(12; "Gift Voucher Account"; Code[20])
        {
            Caption = 'Gift Voucher Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if "Gift Voucher Account" <> '' then begin
                    if "Gift Voucher Account" = Account then
                        Error(ErrKasse);
                    if "Gift Voucher Account" = "Credit Voucher Account" then
                        Error(ErrTilgode);
                    if "Gift Voucher Account" = "Gift Voucher Discount Account" then
                        Error(Text1060006, "Gift Voucher Account", FieldCaption("Gift Voucher Discount Account"));
                end;
            end;
        }
        field(13; "Credit Voucher Account"; Code[20])
        {
            Caption = 'Credit Voucher Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "Credit Voucher Account" <> '' then begin
                    if "Credit Voucher Account" = Account then
                        Error(ErrKasse);

                    if "Credit Voucher Account" = "Gift Voucher Account" then
                        Error(ErrGavekort);
                end;
            end;
        }
        field(14; "Difference Account"; Code[20])
        {
            Caption = 'Difference Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(15; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            DataClassification = CustomerContent;
            TableRelation = IF ("Balanced Type" = CONST(Finans)) "G/L Account"
            ELSE
            IF ("Balanced Type" = CONST(Bank)) "Bank Account";
        }
        field(16; "Difference Account - Neg."; Code[20])
        {
            Caption = 'Difference Account - Neg.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(17; "Gift Voucher Discount Account"; Code[20])
        {
            Caption = 'Gift Voucher Discount Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if "Gift Voucher Discount Account" <> '' then
                    if "Gift Voucher Discount Account" = "Gift Voucher Account" then
                        Error(Text1060006, "Gift Voucher Discount Account", FieldCaption("Gift Voucher Account"));
            end;
        }
        field(25; Rounding; Code[20])
        {
            Caption = 'Rounding';
            DataClassification = CustomerContent;
            Description = 'Kontonummer til ¢reafrunding.';
            TableRelation = "G/L Account"."No." WHERE(Blocked = CONST(false));

            trigger OnValidate()
            begin
                /*Finanskonto.GET(Rounding);
                Finanskonto.TESTFIELD(Blocked,FALSE);
                Finanskonto.TESTFIELD("Direct Posting",TRUE);
                */

            end;
        }
        field(26; "Register Change Account"; Code[20])
        {
            Caption = 'Change G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(90; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(91; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(92; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(329; "Balanced Type"; Option)
        {
            Caption = 'Balanced Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Finance,Bank';
            OptionMembers = Finans,Bank;

            trigger OnValidate()
            begin
                if "Balanced Type" <> xRec."Balanced Type" then
                    "Balance Account" := '';
            end;
        }
        field(411; "Sales Ticket Filter"; Code[20])
        {
            Caption = 'Sales Ticket Filter';
            FieldClass = FlowFilter;
        }
        field(412; "Sales Person Filter"; Code[20])
        {
            Caption = 'Sales Person Filter';
            FieldClass = FlowFilter;
        }
        field(414; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
            SumIndexFields = "Opening Cash";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        AuditRoll: Record "HC Audit Roll";
    begin
    end;

    trigger OnRename()
    begin
        Error(Text1060003, xRec."Register No.");
    end;

    var
        Text1060000: Label 'You cannot enter register %1 manually!';
        Text1060001: Label 'c:\npk.dll';
        Text1060002: Label 'You must delete register %1 on the computer which the register is allocated to! Contact your Solution Center, if necessary.';
        Text1060003: Label 'Register %1 cannot be renamed!';
        Text1060004: Label 'Register initialisation %1';
        Text1060005: Label 'Open register through sales menu';
        RetailSetup: Record "HC Retail Setup";
        DimMgt: Codeunit DimensionManagement;
        Decimal: Decimal;
        PostCode: Record "Post Code";
        Text1060006: Label 'Acount No. %1 is used for  %2.';
        Text1060007: Label 'You have to specify a no. series for the CleanCash, before is will work correctly!!!';
        ErrGavekort: Label 'Acount No. %1 is used for Gift Vouchers.';
        ErrTilgode: Label 'Acount No. %1 is used for Credit Vouchers!';
        ErrKasse: Label 'Acount No. %1 is used for Register Acount!';
        Text1060008: Label 'Warning:\You are about to delete register %1\Last entry is registered on %2\Do you wish to delete it anyway?';
        Text1060009: Label 'Warning:\You are about to delete register %1\Do you wish to delete it anyway?';

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        //-NPR5.48 [331992]
        //DimMgt.SaveDefaultDim(DATABASE::Register,"Register No.",FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"HC Register", "Register No.", FieldNumber, ShortcutDimCode);
        //+NPR5.48 [331992]
        Modify;
    end;
}


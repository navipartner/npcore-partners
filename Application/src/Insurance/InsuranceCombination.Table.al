table 6014518 "NPR Insurance Combination"
{
    Access = Internal;
    // NPR5.38/MHA /20180104  CASE 301054 Added ConstValue to TextConstants ErrAmount and ErrZero

    Caption = 'Insurance Combination';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Company; Code[50])
        {
            Caption = 'Company';
            NotBlank = true;
            TableRelation = "NPR Insurance Companies";
            DataClassification = CustomerContent;
        }
        field(2; Type; Code[50])
        {
            Caption = 'Type';
            NotBlank = true;
            TableRelation = "NPR Insurance Category".Kategori;
            DataClassification = CustomerContent;
        }
        field(3; "Amount From"; Decimal)
        {
            Caption = 'Amount From';
            DataClassification = CustomerContent;
        }
        field(4; "To Amount"; Decimal)
        {
            Caption = 'To Amount';
            DataClassification = CustomerContent;
        }
        field(5; "Insurance Amount"; Decimal)
        {
            Caption = 'Insurance Amount';
            DataClassification = CustomerContent;
        }
        field(6; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(7; "Amount as Percentage"; Boolean)
        {
            Caption = 'Amount as percentage of value';
            DataClassification = CustomerContent;
        }
        field(8; "Ticket tekst"; Text[30])
        {
            Caption = 'Ticket tekst';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Company, Type, "Amount From", "To Amount")
        {
            MaintainSIFTIndex = false;
        }
        key(Key2; Type, "Amount From", "To Amount")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "To Amount" < "Amount From" then
            Error(ErrAmount);
        if "Amount From" <= 0 then
            Error(ErrZero);
    end;

    var
        ErrAmount: Label 'Invalid amount range';
        ErrZero: Label 'Amount from should be greater than 0';
}


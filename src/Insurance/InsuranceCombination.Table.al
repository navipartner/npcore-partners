table 6014518 "NPR Insurance Combination"
{
    // NPR5.38/MHA /20180104  CASE 301054 Added ConstValue to TextConstants ErrAmount and ErrZero

    Caption = 'Insurance Combination';

    fields
    {
        field(1; Company; Code[50])
        {
            Caption = 'Company';
            NotBlank = true;
            TableRelation = "NPR Insurance Companies";
        }
        field(2; Type; Code[50])
        {
            Caption = 'Type';
            NotBlank = true;
            TableRelation = "NPR Insurance Category".Kategori;
        }
        field(3; "Amount From"; Decimal)
        {
            Caption = 'Amount From';
        }
        field(4; "To Amount"; Decimal)
        {
            Caption = 'To Amount';
        }
        field(5; "Insurance Amount"; Decimal)
        {
            Caption = 'Insurance Amount';
        }
        field(6; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            MinValue = 0;
        }
        field(7; "Amount as Percentage"; Boolean)
        {
            Caption = 'Amount as percentage of value';
        }
        field(8; "Ticket tekst"; Text[30])
        {
            Caption = 'Ticket tekst';
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


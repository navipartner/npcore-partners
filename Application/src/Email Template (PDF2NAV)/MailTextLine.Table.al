table 6014521 "NPR Mail Text Line"
{
    Caption = 'Mail Text Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Mail Type"; Option)
        {
            Caption = 'Mail Type';
            Description = 'Husk at rette i counter på form 6014546';
            OptionCaption = 'Purchase Order,Purchase Invoice,Purchase Cr. Memo,Purchase Receipt,Sales Order,Sales Invoice,Sales Cr. Memo,Sales Quote,Sales Receipt,Purchase Quote,Greeting';
            OptionMembers = "Purchase Order","Purchase Invoice","Purchase Cr. Memo","Purchase Receipt","Sales Order","Sales Invoice","Sales Cr. Memo","Sales Quote","Sales Receipt","Purchase Quote",Greeting;
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line Text"; Text[250])
        {
            Caption = 'Line Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Mail Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}


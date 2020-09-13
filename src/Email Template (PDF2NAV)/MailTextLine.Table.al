table 6014521 "NPR Mail Text Line"
{
    // NPR3.0c, NPK, DL, 26-03-07, Tilf¢jet k¢bstilbud som option
    // NPR5.39/TJ  /20180212 CASE 302634 Renamed OptionString property of field 1 "Mail Type" to english

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


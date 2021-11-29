table 6151014 "NPR NpRv Voucher Entry"
{
    Caption = 'Retail Voucher Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Voucher Entries";
    LookupPageID = "NPR NpRv Voucher Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher";
        }
        field(10; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.49,NPR5.50';
            OptionCaption = ',Issue Voucher,Payment,Manual Archive,Partner Issue Voucher,Partner Payment,Top-up,Synchronisation,Partner Top-up';
            OptionMembers = ,"Issue Voucher",Payment,"Manual Archive","Partner Issue Voucher","Partner Payment","Top-up",Synchronisation,"Partner Top-up";
        }
        field(15; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Type";
        }
        field(17; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(30; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(35; Correction; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(40; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(53; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'POS Entry,Invoice,Credit Memo';
            OptionMembers = "POS Entry",Invoice,"Credit Memo";
        }
        field(55; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(57; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(60; "External Document No."; Code[50])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            Editable = false;
            NotBlank = true;
        }
        field(65; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(67; "Partner Code"; Code[20])
        {
            Caption = 'Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NPR NpRv Partner";
        }
        field(70; "Closed by Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Closed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(75; "Closed by Partner Code"; Code[20])
        {
            Caption = 'Closed by Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NPR NpRv Partner";
        }
        field(80; "Partner Clearing"; Boolean)
        {
            Caption = 'Partner Clearing';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Voucher No.")
        {
            SumIndexFields = Amount, "Remaining Amount";
        }
        key(Key3; "Entry Type", "Register No.", "Document No.")
        {
        }
        key(Key4; "Entry Type", "Document Type", "Document No.")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'New key (Key6: "Entry Type", "Document Type", "Document No.", "Document Line No.") introduced';
        }
        key(Key5; "Voucher Type")
        {
        }
        key(Key6; "Entry Type", "Document Type", "Document No.", "Document Line No.")
        {
        }
    }
}

table 6151409 "NPR Magento Payment Line"
{

    Caption = 'Payment Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Payment Line List";
    LookupPageID = "NPR Magento Payment Line List";

    fields
    {
        field(1; "Document Table No."; Integer)
        {
            Caption = 'Document Table No.';
            DataClassification = CustomerContent;
        }
        field(5; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(10; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(15; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(16; "Payment Type"; Option)
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            Description = 'MAG1.05,MAG2.01';
            InitValue = "Payment Method";
            OptionCaption = ' ,,,,,Voucher,Payment Method';
            OptionMembers = " ",,,,,Voucher,"Payment Method";
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(24; "Account Type"; Enum "Payment Balance Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(25; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(30; "No."; Code[50])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
        }
        field(35; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(37; "Allow Adjust Amount"; Boolean)
        {
            Caption = 'Allow Adjust Amount';
            DataClassification = CustomerContent;
            Description = 'MAG2.05';
        }
        field(40; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(50; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            DataClassification = CustomerContent;
        }
        field(55; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(60; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(70; "External Reference No."; Code[50])
        {
            Caption = 'External Reference No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
        }
        field(80; "Payment Gateway Shopper Ref."; Text[50])
        {
            Caption = 'Payment Gateway Shopper Ref.';
            DataClassification = CustomerContent;
        }
        field(100; "Payment Gateway Code"; Code[10])
        {
            Caption = 'Payment Gateway Code';
            DataClassification = CustomerContent;
            Description = 'MAG1.20';
            TableRelation = "NPR Magento Payment Gateway";
        }
        field(105; "Date Captured"; Date)
        {
            Caption = 'Date Captured';
            DataClassification = CustomerContent;
            Description = 'MAG1.20';
        }
        field(110; "Date Refunded"; Date)
        {
            Caption = 'Date Refunded';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
        }
        field(200; "Last Amount"; Decimal)
        {
            Caption = 'Last Amount';
            DataClassification = CustomerContent;
            Description = 'MAG2.02';
        }
        field(205; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.02';
        }
        field(210; "Charge ID"; Code[20])
        {
            Caption = 'Charge ID';
            DataClassification = CustomerContent;
            Description = 'MAG3.00';
        }
    }

    keys
    {
        key(Key1; "Document Table No.", "Document Type", "Document No.", "Line No.")
        {
            SumIndexFields = Amount;
        }
        key(Key2; "Payment Type", "No.", Amount)
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if "Payment Type" = "Payment Type"::Voucher then begin
            CreditVoucher.SetRange(Status, CreditVoucher.Status::Cancelled);
            CreditVoucher.SetRange("External Reference No.", "No.");
            CreditVoucher.DeleteAll(true);

            GiftVoucher.SetRange(Status, GiftVoucher.Status::Cancelled);
            GiftVoucher.SetRange("External Reference No.", "No.");
            GiftVoucher.DeleteAll(true);
        end;
    end;

    var
        CreditVoucher: Record "NPR Credit Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
}


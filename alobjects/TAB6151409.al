table 6151409 "Magento Payment Line"
{
    // MAG1.03/MHA /20150113  CASE 199932 Renamed table from Payment Line to be inluded in NaviConnect
    // MAG1.05/TS  /20150223  CASE 201682 Renamed caption for payment type WebVoucher to Voucher
    // MAG1.20/TR  /20150828  CASE 219645 Edited fields Payment Gateway Code and Date Captured
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20160928  CASE 250694 Added field 110 "Date Refunded" and 70 "External Reference No."
    // MAG2.02/MHA /20170222  CASE 264711 Added fields 200 "Last Amount" and 205 "Last Posting No."
    // MAG2.05/MHA /20170712  CASE 283588 Added field 37 "Allow Adjust Amount"
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to fields 70 and 205
    // MAG2.19/MMV /20190314 CASE 347687 Added field 80

    Caption = 'Payment Line';
    DrillDownPageID = "Magento Payment Line List";
    LookupPageID = "Magento Payment Line List";

    fields
    {
        field(1;"Document Table No.";Integer)
        {
            Caption = 'Document Table No.';
        }
        field(5;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(10;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(15;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(16;"Payment Type";Option)
        {
            Caption = 'Payment Type';
            Description = 'MAG1.05,MAG2.01';
            InitValue = "Payment Method";
            OptionCaption = ' ,,,,,Voucher,Payment Method';
            OptionMembers = " ",,,,,Voucher,"Payment Method";
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(24;"Account Type";Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(25;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type"=CONST("G/L Account")) "G/L Account"
                            ELSE IF ("Account Type"=CONST("Bank Account")) "Bank Account";
        }
        field(30;"No.";Code[50])
        {
            Caption = 'No.';
            Description = 'MAG2.01';
        }
        field(35;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(37;"Allow Adjust Amount";Boolean)
        {
            Caption = 'Allow Adjust Amount';
            Description = 'MAG2.05';
        }
        field(40;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(50;"Source Table No.";Integer)
        {
            Caption = 'Source Table No.';
        }
        field(55;"Source No.";Code[20])
        {
            Caption = 'Source No.';
        }
        field(60;Posted;Boolean)
        {
            Caption = 'Posted';
            Description = 'MAG2.00';
        }
        field(70;"External Reference No.";Code[50])
        {
            Caption = 'External Reference No.';
            Description = 'MAG2.01';
        }
        field(80;"Payment Gateway Shopper Ref.";Text[50])
        {
            Caption = 'Payment Gateway Shopper Ref.';
        }
        field(100;"Payment Gateway Code";Code[10])
        {
            Caption = 'Payment Gateway Code';
            Description = 'MAG1.20';
            TableRelation = "Magento Payment Gateway";
        }
        field(105;"Date Captured";Date)
        {
            Caption = 'Date Captured';
            Description = 'MAG1.20';
        }
        field(110;"Date Refunded";Date)
        {
            Caption = 'Date Refunded';
            Description = 'MAG2.01';
        }
        field(200;"Last Amount";Decimal)
        {
            Caption = 'Last Amount';
            Description = 'MAG2.02';
        }
        field(205;"Last Posting No.";Code[20])
        {
            Caption = 'Last Posting No.';
            Description = 'MAG2.02';
        }
    }

    keys
    {
        key(Key1;"Document Table No.","Document Type","Document No.","Line No.")
        {
            SumIndexFields = Amount;
        }
        key(Key2;"Payment Type","No.",Amount)
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
          CreditVoucher.SetRange(Status,CreditVoucher.Status::Cancelled);
          //-MAG2.00
          //CreditVoucher.SETRANGE("Certificate Number","No.");
          CreditVoucher.SetRange("External Reference No.","No.");
          //+MAG2.00
          CreditVoucher.DeleteAll(true);

          GiftVoucher.SetRange(Status,GiftVoucher.Status::Cancelled);
          //-MAG2.00
          //GiftVoucher.SETRANGE("Certificate Number","No.");
          GiftVoucher.SetRange("External Reference No.","No.");
          //+MAG2.00
          GiftVoucher.DeleteAll(true);
        end;
    end;

    var
        CreditVoucher: Record "Credit Voucher";
        GiftVoucher: Record "Gift Voucher";
}


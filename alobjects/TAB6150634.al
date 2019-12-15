table 6150634 "POS Posting Buffer"
{
    // NPR5.36/BR  /20170712  CASE 279551 Object Created
    // NPR5.37/BR  /20171012  CASE 293227 Changed Compressedion options: Added field POS Ledger Register and changed primary key (replaced POS Store and POS Unit with POS Ledger Register)
    // NPR5.38/BR  /20171108  CASE 294718 Added fields Applies-to Doc. Type and Applies-to Doc. No., added Applies-to Doc. No. to Primary Key
    // NPR5.38/BR  /20171108  CASE 294720 Added External Document No.
    // NPR5.38/BR  /20171214  CASE 299888 Renamed from POS Ledg. Register No. to POS Period Register No. (incl. Captions)
    // NPR5.38/BR  /20180105  CASE 301054 Removed Salesperson code, Reason code, POS Period Register, Payment Method Code POS from primary Key
    // NPR5.38/BR  /20180122  CASE 302693 Added Type = Payout

    Caption = 'POS Posting Buffer';

    fields
    {
        field(1;"Line Type";Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Sales,Payment,Payout';
            OptionMembers = Sales,Payment,Payout;
        }
        field(2;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(3;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
        }
        field(4;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(5;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(6;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(7;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,Customer,Voucher,Payout';
            OptionMembers = " ","G/L Account",Item,Customer,Voucher,Payout;
        }
        field(8;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(9;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(10;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(11;"Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(12;"VAT Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(13;"VAT Prod. Posting Group";Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(14;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
        }
        field(15;"Reason Code";Code[10])
        {
            Caption = 'Reason Code';
        }
        field(16;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
        }
        field(17;"POS Payment Bin Code";Code[10])
        {
            Caption = 'POS Payment Bin Code';
            TableRelation = "POS Payment Bin";
        }
        field(18;"POS Payment Method Code";Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "POS Payment Method";
        }
        field(20;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(21;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(22;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(23;"POS Period Register";Integer)
        {
            Caption = 'POS Period Register';
            Description = 'NPR5.37';
            TableRelation = "POS Period Register";
        }
        field(50;Amount;Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(51;"Amount (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
        }
        field(52;"Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount Amount';
        }
        field(53;"Discount Amount (LCY)";Decimal)
        {
            Caption = 'Discount Amount (LCY)';
        }
        field(54;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(60;"Rounding Amount";Decimal)
        {
            Caption = 'Rounding Amount';
        }
        field(61;"Rounding Amount (LCY)";Decimal)
        {
            Caption = 'Rounding Amount (LCY)';
        }
        field(70;"VAT Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount';
        }
        field(71;"VAT Calculation Type";Option)
        {
            Caption = 'VAT Calculation Type';
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(72;"VAT Base Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
        }
        field(73;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(74;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(75;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(76;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 1:5;
        }
        field(77;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';
        }
        field(78;"VAT Difference";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Difference';
        }
        field(79;"VAT %";Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 1:1;
        }
        field(80;"VAT Amount (LCY)";Decimal)
        {
            Caption = 'VAT Amount (LCY)';
        }
        field(85;"VAT Amount Discount";Decimal)
        {
            Caption = 'VAT Amount Discount';
        }
        field(86;"VAT Amount Discount (LCY)";Decimal)
        {
            Caption = 'VAT Amount Discount (LCY)';
        }
        field(90;"Applies-to Doc. Type";Option)
        {
            Caption = 'Applies-to Doc. Type';
            Description = 'NPR5.38';
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(91;"Applies-to Doc. No.";Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            Description = 'NPR5.38';
        }
        field(92;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
            Description = 'NPR5.38';
        }
    }

    keys
    {
        key(Key1;"Posting Date","POS Entry No.","Line Type","Document No.","Line No.",Type,"No.","Gen. Bus. Posting Group","Gen. Prod. Posting Group","VAT Bus. Posting Group","VAT Prod. Posting Group","Currency Code","POS Payment Bin Code","Dimension Set ID","Tax Area Code","Applies-to Doc. No.")
        {
        }
    }

    fieldgroups
    {
    }
}


table 6014426 "NPR Retail Document Lines"
{
    Caption = 'Retail Document Line';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(8; "Unit price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(10; "Line discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;
        }
        field(11; "Line discount amount"; Decimal)
        {
            Caption = 'Line Discount Amount';
            DataClassification = CustomerContent;
        }
        field(12; "Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Unit Cost (LCY)';
            DataClassification = CustomerContent;
        }
        field(13; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(14; "Quantity in order"; Decimal)
        {
            Caption = 'Quantity in order';
            DataClassification = CustomerContent;
        }
        field(15; "Quantity received"; Decimal)
        {
            Caption = 'Quantity received';
            DataClassification = CustomerContent;
        }
        field(16; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
            DataClassification = CustomerContent;
        }
        field(17; "Received (LCY)"; Decimal)
        {
            Caption = 'Received (LCY)';
            DataClassification = CustomerContent;
        }
        field(18; "Outstanding quantity"; Decimal)
        {
            Caption = 'Outstanding quantity';
            DataClassification = CustomerContent;
        }
        field(19; "Unit of measure"; Code[10])
        {
            Caption = 'Unit of measure';
            Description = 'NPR5.48';
            DataClassification = CustomerContent;
        }
        field(20; "Std. quantity"; Decimal)
        {
            Caption = 'Std. quantity';
            DataClassification = CustomerContent;
        }
        field(21; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(22; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
            DataClassification = CustomerContent;
        }
        field(23; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item),Catalouge items';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)","Catalouge items";
            DataClassification = CustomerContent;
        }
        field(24; "Received last"; Date)
        {
            Caption = 'Received last';
            DataClassification = CustomerContent;
        }
        field(25; "Letter printed"; Boolean)
        {
            Caption = 'Letter printed';
            DataClassification = CustomerContent;
        }
        field(26; Color; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
        }
        field(27; Size; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }
        field(28; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(31; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(32; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(34; "Price including VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(35; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
        }
        field(36; "Rental Amount incl. VAT"; Decimal)
        {
            Caption = 'Rental Amount incl. VAT';
            DataClassification = CustomerContent;
        }
        field(37; "Total Rental Amount incl. VAT"; Decimal)
        {
            Caption = 'Total Rental Amount incl. VAT';
            DataClassification = CustomerContent;
        }
        field(38; Accessory; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
        }
        field(39; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
        }
        field(40; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
        }
        field(41; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(42; "Qty. to Ship"; Decimal)
        {
            Caption = 'Qty. to Ship';
            DataClassification = CustomerContent;
        }
        field(43; "Delivery Item"; Boolean)
        {
            Caption = 'Delivery Item';
            DataClassification = CustomerContent;
        }
        field(44; "Deposit item"; Boolean)
        {
            Caption = 'Deposit item';
            DataClassification = CustomerContent;
        }
        field(45; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(46; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(47; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(77; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(90; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
        }
        field(91; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
        }
        field(100; "Printing filter"; Integer)
        {
            Caption = 'Printing filter';
            FieldClass = FlowFilter;
        }
        field(104; "VAT Difference"; Decimal)
        {
            Caption = 'VAT Difference';
            DataClassification = CustomerContent;
        }
        field(106; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
        }
        field(110; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            DataClassification = CustomerContent;
        }
        field(200; "Package quantity"; Decimal)
        {
            Caption = 'Package quantity';
            DataClassification = CustomerContent;
        }
        field(201; "Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
        }
        field(202; "Serial No. not Created"; Code[50])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(1000; HjemOverUd; Boolean)
        {
            Caption = 'Home Preceeds out';
            DataClassification = CustomerContent;
        }
        field(1001; "Vat %"; Decimal)
        {
            Caption = 'Vat %';
            DataClassification = CustomerContent;
        }
        field(1002; "Date of rental"; Date)
        {
            Caption = 'Date of rental';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}


table 6150901 "HC Audit Roll"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector: Created object based on Table 6014407
    // NPR5.38/JDH /20180119 CASE 302570 Changed Option String on Field Sale Type to English
    // NPR5.39/TJ  /20180206 CASE 302634 Removed unused variable H�ndterFejlUnderBonUdskr
    // NPR5.39/BR  /20180220 CASE 305744 Aligned Caption with OptionString
    // NPR5.39/BR  /20180221 CASE 225415 Renumberd fields in 5xxxx range
    // NPR5.48/MHA /20181121 CASE 326055 Added field 5022 "Reference"

    Caption = 'HC Audit Roll';
    DrillDownPageID = "HC Audit Roll";
    LookupPageID = "HC Audit Roll";
    PasteIsValid = false;

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = "HC Register";
        }
        field(2;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(3;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,,"Open/Close";
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("G/L")) "G/L Account"."No."
                            ELSE IF (Type=CONST(Payment)) "HC Payment Type POS"."No."
                            ELSE IF (Type=CONST(Customer)) Customer."No."
                            ELSE IF (Type=CONST(Item)) Item."No." WHERE (Blocked=CONST(false));
            ValidateTableRelation = false;
        }
        field(7;Lokationskode;Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(10;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(11;Unit;Text[10])
        {
            Caption = 'Unit';
        }
        field(12;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
        }
        field(17;"VAT %";Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(19;"Line Discount %";Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(20;"Line Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Line Discount Amount';
        }
        field(25;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(26;"Posted Doc. No.";Code[20])
        {
            Caption = 'Posted Doc. No.';
        }
        field(30;Amount;Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(31;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DecimalPlaces = 2:2;
        }
        field(40;"Department Code";Code[10])
        {
            Caption = 'Department Code DONT USE';
            Description = 'Not used. use "Shortcut Dimension 1 Code" instead';
        }
        field(43;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';
        }
        field(44;"Customer/Item Discount %";Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(48;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(49;"Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(50;"VAT Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(51;"VAT Prod. Posting Group";Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(52;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(55;Cost;Decimal)
        {
            Caption = 'Cost';
        }
        field(59;"Gift voucher ref.";Code[20])
        {
            Caption = 'Gift voucher ref.';
        }
        field(60;"Credit voucher ref.";Code[20])
        {
            Caption = 'Credit voucher ref.';
        }
        field(70;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(71;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(75;"Bin Code";Code[10])
        {
            Caption = 'Bin Code';
            TableRelation = Bin;
        }
        field(85;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            Description = '248534';
            TableRelation = "Tax Area";
        }
        field(86;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
            Description = '248534';
        }
        field(87;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            Description = '248534';
            TableRelation = "Tax Group";
        }
        field(88;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';
            Description = '248534';
        }
        field(90;"Return Reason Code";Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(95;"Clustered Key";Integer)
        {
            AutoIncrement = true;
            Caption = 'Clustered Key';
        }
        field(100;"Unit Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(101;"System-Created Entry";Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(102;"Variant Code";Code[20])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));
        }
        field(105;"Allocated No.";Code[10])
        {
            Caption = 'Allocated No.';
        }
        field(107;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Faktura,Ordre,Kreditnota,Returordre;
        }
        field(110;"Retail Document Type";Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(111;"Retail Document No.";Code[20])
        {
            Caption = 'No.';
        }
        field(140;"Sales Document Type";Integer)
        {
            Caption = 'Sales Document Type';
        }
        field(141;"Sales Document No.";Code[20])
        {
            Caption = 'Sales Document No.';
        }
        field(143;"Sales Document Prepayment";Boolean)
        {
            Caption = 'Sales Document Prepayment';
        }
        field(144;"Sales Doc. Prepayment %";Decimal)
        {
            Caption = 'Sales Doc. Prepayment %';
        }
        field(145;"Sales Document Invoice";Boolean)
        {
            Caption = 'Sales Document Invoice';
        }
        field(146;"Sales Document Ship";Boolean)
        {
            Caption = 'Sales Document Ship';
        }
        field(160;"POS Sale ID";Integer)
        {
            Caption = 'POS Sale ID';
            Description = '262628';
        }
        field(200;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(400;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = '264918';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
        }
        field(500;"Cash Terminal Approved";Boolean)
        {
            Caption = 'Cash Terminal Approved';
        }
        field(550;"Drawer Opened";Boolean)
        {
            Caption = 'Drawer Opened';
            Description = 'NPR4.001.000, for indication of opening on drawer.';
        }
        field(1000;"Starting Time";Time)
        {
            Caption = 'Starting Time';
        }
        field(1001;"Closing Time";Time)
        {
            Caption = 'Closing Time';
        }
        field(1002;"Receipt Type";Option)
        {
            Caption = 'Ticket Type';
            OptionCaption = ' ,Negative Sales Ticket,Change,Outpayment,Return Item,Sales in Negative Receipt';
            OptionMembers = " ","Negative receipt","Change money",Outpayment,"Return items","Sales in negative receipt";
        }
        field(2000;"Closing Cash";Decimal)
        {
            Caption = 'Closing Cash';
        }
        field(2001;"Opening Cash";Decimal)
        {
            Caption = 'Opening Cash';
        }
        field(2002;"Transferred to Balance Account";Decimal)
        {
            Caption = 'Transferred to Balance Account';
        }
        field(2003;Difference;Decimal)
        {
            Caption = 'Difference';
        }
        field(2005;"Change Register";Decimal)
        {
            Caption = 'Change Cash Register';
        }
        field(3000;Posted;Boolean)
        {
            Caption = 'Posted';
        }
        field(3001;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(3002;"Internal Posting No.";Integer)
        {
            Caption = 'Internal Posting No.';
        }
        field(5002;Color;Code[20])
        {
            Caption = 'Color';
        }
        field(5003;Size;Code[20])
        {
            Caption = 'Size';
        }
        field(5004;"Serial No. not Created";Code[30])
        {
            Caption = 'Serial No. not Created';
        }
        field(5020;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
        }
        field(5021;"Customer Type";Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ord.,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(5022;Reference;Text[50])
        {
            Caption = 'Reference';
            Description = 'NPR5.48';
        }
        field(5024;"Payment Type No.";Code[10])
        {
            Caption = 'Payment Type No.';
            NotBlank = true;
        }
        field(6000;"N3 Debit Sale Conversion";Boolean)
        {
            Caption = 'N3 Debit Sale Conversion';
        }
        field(6001;"Buffer Document Type";Option)
        {
            Caption = 'Buffer Document Type';
            Description = 'NP-retail 1.8';
            OptionCaption = ' ,Payment,Invoice,Credit Note,Interest Note,Reminder';
            OptionMembers = " ",Betaling,Faktura,Kreditnota,Rentenota,Rykker;
        }
        field(6002;"Buffer ID";Code[20])
        {
            Caption = 'Buffer ID';
            Description = 'NP-retail 1.8';
        }
        field(6003;"Buffer Invoice No.";Code[20])
        {
            Caption = 'Buffer Invoice No.';
            Description = 'NP-retail 1.8';
        }
        field(6004;"Reason Code";Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(6005;"Description 2";Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.23';
        }
        field(6007;"Money bag no.";Code[20])
        {
            Caption = 'Money bag no.';
        }
        field(6008;"External Document No.";Code[20])
        {
            Caption = 'External Document No.';
        }
        field(6009;LineCounter;Decimal)
        {
            Caption = 'LineCounter';
            Description = 'Hack til hurtigt count vha. sum index fields.';
            InitValue = 1;
        }
        field(6015;Offline;Boolean)
        {
            Caption = 'Offline';
        }
        field(6025;"Customer Post Code";Code[20])
        {
            Caption = 'Customer Post Code';
        }
        field(6030;"Currency Amount";Decimal)
        {
            Caption = 'Currency Amount';
        }
        field(6035;"Item Entry Posted";Boolean)
        {
            Caption = 'Item Entry Posted';
            InitValue = false;
        }
        field(6055;Send;Date)
        {
            Caption = 'Send';
            Description = 'Bruges ifm. replikering til at afg�ren om det felt er udl�st eller ej';
        }
        field(6060;"Offline receipt no.";Code[20])
        {
            Caption = 'Offline receipt no.';
        }
        field(10003;Balancing;Boolean)
        {
            Caption = 'Balancing';
        }
        field(10004;Vendor;Code[20])
        {
            Caption = 'Vendor';
        }
        field(10013;"Invoiz Guid";Text[150])
        {
            Caption = 'Invoiz Guid';
        }
        field(10020;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
            InitValue = 0;
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date")
        {
            SumIndexFields = "Amount Including VAT";
        }
        key(Key2;"Clustered Key")
        {
        }
        key(Key3;"Register No.","Sales Ticket No.","Sale Type",Type,"No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Currency Amount","Line Discount Amount",Cost,Amount,"Unit Cost",Quantity;
        }
        key(Key4;"Register No.","Sale Type",Type,"No.","Sale Date","Discount Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,Cost,"Line Discount Amount";
        }
        key(Key5;"Register No.","Sales Ticket No.","Sale Type",Type)
        {
            Enabled = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Line Discount Amount",Cost,Amount,"Unit Cost";
        }
        key(Key6;"Register No.",Posted,"Sale Date",Type,"Credit voucher ref.")
        {
        }
        key(Key7;"Sale Type",Type,"No.",Posted)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Currency Amount";
        }
        key(Key8;"Register No.","Sales Ticket No.","Sale Date","Sale Type",Type,"No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Cost,"Line Discount Amount",Amount;
        }
        key(Key9;Posted,"Serial No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
        key(Key10;"Register No.","Sales Ticket No.",Type,"Closing Time",Description,"Sale Date","Salesperson Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = true;
            SumIndexFields = "Amount Including VAT","Line Discount Amount";
        }
        key(Key11;Send,Type,"Sale Type")
        {
            Enabled = false;
            MaintainSQLIndex = false;
        }
        key(Key12;Offline,"Offline receipt no.",Posted,"Sale Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key13;"Sales Ticket No.",Type)
        {
        }
        key(Key14;"Sale Date","Sale Type",Type,"Gift voucher ref.","Register No.","Closing Time","Salesperson Code","Receipt Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Quantity,"Line Discount Amount",Amount,Cost;
        }
        key(Key15;"Register No.","Sale Date","Sale Type",Type,Quantity,"Receipt Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,Cost;
        }
        key(Key16;"Sale Type",Type,"Starting Time","Closing Time","Sale Date","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code",Lokationskode)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Quantity,LineCounter;
        }
        key(Key17;"Retail Document Type","Retail Document No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key18;"Salesperson Code","Register No.","Sale Date")
        {
            SumIndexFields = Amount;
        }
        key(Key19;"Sale Type",Type,"Item Entry Posted")
        {
            MaintainSQLIndex = false;
        }
        key(Key20;"Sale Date","Invoiz Guid")
        {
            MaintainSQLIndex = false;
        }
        key(Key21;"Customer No.")
        {
        }
        key(Key22;"Register No.","Sales Ticket No.","Line No.")
        {
            SumIndexFields = "Amount Including VAT",Amount,Cost;
        }
        key(Key23;"Register No.","Sales Ticket No.","Sale Type","Cash Terminal Approved")
        {
            SumIndexFields = "Amount Including VAT";
        }
        key(Key24;"Sales Ticket No.","Line No.")
        {
        }
        key(Key25;"Sale Date","Sales Ticket No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text1060000: Label 'Do you want sales ticket %1 on A4 print?';
        Revisionsrec: Record "HC Audit Roll";
        RetailSetup: Record "HC Retail Setup";
        Finanskonto: Record "G/L Account";
        DimMgt: Codeunit DimensionManagement;
        Kasse: Record "HC Register";
        Text1060001: Label '%1 %2 has %3 %4. It is not possible to insert %5 with %6 %7.';
        Text1060002: Label 'Error at insert into the audit roll. \Sales ticket no. %1 <> Sales Ticket No. of set register status %2. \Status = %3.';

    procedure GetNoOfSales(): Integer
    var
        AuditRoll2: Record "HC Audit Roll";
        NoOfSales: Integer;
        LastSalesTicketNo: Code[20];
    begin
        //-NPR4.10
        AuditRoll2.CopyFilters(Rec);

        //-NPR4.11
        //AuditRoll2.SETRANGE("Sale Type", AuditRoll2."Sale Type"::Salg);
        //+NPR4.11
        if AuditRoll2.FindSet then repeat
          if (AuditRoll2."Sales Ticket No." <> LastSalesTicketNo) then
            NoOfSales += 1;
          LastSalesTicketNo := AuditRoll2."Sales Ticket No.";
        until AuditRoll2.Next = 0;

        exit(NoOfSales);
        //+NPR4.10
    end;
}


table 6150903 "HC Audit Roll Posting"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector: Created object based on Table 6014424
    // NPR5.39/TJ  /20180206 CASE 302634 Changed OptionString property of field 3 "Sale Type" to english version
    // NPR5.39/BR  /20180220 CASE 305744 Aligned Caption with OptionString
    // NPR5.39/BR  /20180221 CASE 225415 Renumberd fields in 5xxxx range
    // NPR5.43/JDH /20180620 CASE 317453 Removed non existing table relation from Field 40 (ref to old Department table 11)
    // NPR5.48/MHA /20181121 CASE 326055 Added field 5022 "Reference"
    // NPR5.48/TJ  /20181114 CASE 331992 Applying dimensions
    // NPR5.48/TJ  /20190128 CASE 340446 Fixed TableRelation property for field No. to properly point to table HC Payment Type POS

    Caption = 'HC Audit Roll Posting';

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
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,"Open/Close";
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

            trigger OnValidate()
            begin
                exit;
            end;
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
        field(200;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(400;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
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
            OptionCaption = ' ,Negative receipt,Change money,Outpayment,Return items,Sales in negative receipt';
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
            Description = 'Bruges ifm. replikering til at afg¢ren om det felt er udlæst eller ej';
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
        field(10005;"Balanced on Sales Ticket No.";Code[20])
        {
            Caption = 'Balanced on Sales Ticket No.';
            Description = 'Bruges ifm. samling af flere kasser.';
        }
        field(10008;Photobag;Code[20])
        {
            Caption = 'Photobag';
        }
        field(10013;"Invoiz Guid";Text[150])
        {
            Caption = 'Invoiz Guid';
        }
        field(6014511;"Label No.";Code[8])
        {
            Caption = 'Label Number';
            Description = 'NPR4.004.004 - Benyttes i forbindelse med Smart Safety forsikring';
        }
        field(6014539;"CleanCash Reciept No.";Code[10])
        {
            Caption = 'CleanCash Reciept No.';
            Description = 'CleanCash';
        }
        field(6014540;"CleanCash Serial No.";Text[30])
        {
            Caption = 'CleanCash Serial No.';
            Description = 'CleanCash';
        }
        field(6014541;"CleanCash Control Code";Text[100])
        {
            Caption = 'CleanCash Control Code';
            Description = 'CleanCash';
        }
        field(6014542;"CleanCash Copy Serial No.";Text[30])
        {
            Caption = 'CleanCash Copy Serial No.';
            Description = 'CleanCash';
        }
        field(6014543;"CleanCash Copy Control Code";Text[100])
        {
            Caption = 'CleanCash Copy Control Code';
            Description = 'CleanCash';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date")
        {
        }
        key(Key2;"Sale Date","Sales Ticket No.","Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key3;"Gen. Bus. Posting Group","Gen. Prod. Posting Group","Sale Type",Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Line Discount Amount";
        }
        key(Key4;"Register No.",Posted,"Sale Date",Type)
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key5;"Register No.","Closing Time","Sale Type",Description,Type,"Sales Ticket No.","Sale Date")
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Line Discount Amount";
        }
        key(Key6;"Sale Type",Type,"No.","Posting Date","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key7;Posted)
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key8;"Register No.","Sale Date","Sale Type",Type,Posted,"Item Entry Posted",Quantity)
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,"Unit Cost","Line Discount Amount",Cost;
        }
        key(Key9;"Sale Type",Type,"Gen. Bus. Posting Group","Gen. Prod. Posting Group","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Line Discount Amount";
        }
        key(Key10;"Sale Date","Sale Type",Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key11;Type,Balancing)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key12;"Sale Type",Type,"Customer Type","Customer No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key13;"Sale Type",Type,"Item Entry Posted")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key14;"Sales Ticket No.","Sale Type",Type,"Customer Type","Customer No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,"Unit Cost","Line Discount Amount",Cost;
        }
        key(Key15;"Sale Type",Type,"Gen. Bus. Posting Group","Gen. Prod. Posting Group","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID","VAT Bus. Posting Group","VAT Prod. Posting Group")
        {
            SumIndexFields = "Amount Including VAT","Line Discount Amount";
        }
    }

    fieldgroups
    {
    }

    procedure TransferFromRev(var Revisionsrulle: Record "HC Audit Roll";var RevPost: Record "HC Audit Roll Posting" temporary;var Dlg: Dialog): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        exit(DoTransferFromRev(Revisionsrulle, RevPost, Dlg, true));
    end;

    procedure TransferFromRevItemLedger(var Revisionsrulle: Record "HC Audit Roll";var RevPost: Record "HC Audit Roll Posting" temporary;var Dlg: Dialog): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        exit(DoTransferFromRevItemLedger(Revisionsrulle, RevPost, Dlg, true));
    end;

    procedure TransferFromTemp(var Target: Record "HC Audit Roll Posting" temporary;var Source: Record "HC Audit Roll Posting" temporary)
    begin
        //TransferFromTemp()
        Target.SetFilter( "Register No.", Source.GetFilter( "Register No." ));
        Target.SetFilter( "Sales Ticket No.", Source.GetFilter( "Sales Ticket No." ));
        Target.SetFilter( "Sale Type", Source.GetFilter( "Sale Type" ));
        Target.SetFilter( "Line No.", Source.GetFilter( "Line No." ));
        Target.SetFilter( "No.", Source.GetFilter( "No." ));
        Target.SetFilter( "Sale Date", Source.GetFilter( "Sale Date" ));
        Target.SetFilter( Type, Source.GetFilter( Type ));
        Target.SetFilter( Lokationskode, Source.GetFilter( Lokationskode ));
        Target.SetFilter( "Shortcut Dimension 1 Code", Source.GetFilter( "Shortcut Dimension 1 Code" ));
        Target.SetFilter( "Shortcut Dimension 2 Code", Source.GetFilter( "Shortcut Dimension 2 Code" ));

        if Source.FindSet then repeat
          Target.TransferFields( Source );
          Target.Insert;
        until Source.Next = 0;
    end;

    procedure UpdateChanges(var Dlg: Dialog)
    var
        Revisionsrulle: Record "HC Audit Roll";
        Total: Integer;
        nCount: Integer;
    begin
        DoUpdateChanges(Dlg, true);
    end;

    procedure CopyAllFilters(var RevRulle: Record "HC Audit Roll")
    begin
        //CopyAllFilters

        RevRulle.SetFilter( "Register No.", GetFilter( "Register No." ));
        RevRulle.SetFilter( "Sales Ticket No.", GetFilter( "Sales Ticket No."));
        RevRulle.SetFilter( "Sale Date", GetFilter( "Sale Date" ));
        RevRulle.SetFilter( "Line No.", GetFilter( "Line No." ));
        RevRulle.SetFilter( "Gen. Bus. Posting Group", GetFilter( "Gen. Bus. Posting Group" ));
        RevRulle.SetFilter( "Gen. Prod. Posting Group", GetFilter( "Gen. Prod. Posting Group" ));
        RevRulle.SetFilter( "Shortcut Dimension 1 Code", GetFilter( "Shortcut Dimension 1 Code" ));
        RevRulle.SetFilter( "Shortcut Dimension 2 Code", GetFilter( "Shortcut Dimension 2 Code" ));
        RevRulle.SetFilter( "Sale Type", GetFilter( "Sale Type" ));
        RevRulle.SetFilter( Type, GetFilter( Type ));
        RevRulle.SetFilter( "No.", GetFilter( "No." ));
        RevRulle.SetFilter( Balancing, GetFilter( Balancing ));
        RevRulle.SetFilter( "Customer Type", GetFilter( "Customer Type" ));
        RevRulle.SetFilter( "Customer No.", GetFilter( "Customer No." ));
        RevRulle.SetFilter( "Item Entry Posted", GetFilter( "Item Entry Posted" ));
    end;

    procedure TransferFromRevSilent(var Revisionsrulle: Record "HC Audit Roll";var RevPost: Record "HC Audit Roll Posting" temporary): Integer
    var
        Dlg: Dialog;
    begin
        exit(DoTransferFromRev(Revisionsrulle, RevPost, Dlg, false));
    end;

    procedure TransferFromRevSilentItemLedg(var Revisionsrulle: Record "HC Audit Roll";var RevPost: Record "HC Audit Roll Posting" temporary): Integer
    var
        Dlg: Dialog;
    begin
        exit(DoTransferFromRevItemLedger(Revisionsrulle, RevPost, Dlg, false));
    end;

    procedure UpdateChangesSilent()
    var
        Revisionsrulle: Record "HC Audit Roll";
        Dlg: Dialog;
    begin
        DoUpdateChanges(Dlg, false);
    end;

    procedure DoTransferFromRev(var Revisionsrulle: Record "HC Audit Roll";var RevPost: Record "HC Audit Roll Posting" temporary;var Dlg: Dialog;UpdateDialog: Boolean): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        Revisionsrulle.SetCurrentKey( "Register No.", Posted, "Sale Date" );
        Revisionsrulle.SetRange( Posted, false );

        RevPost.SetFilter( "Register No.", Revisionsrulle.GetFilter( "Register No." ));
        RevPost.SetFilter( "Sales Ticket No.", Revisionsrulle.GetFilter( "Sales Ticket No." ));
        RevPost.SetFilter( "Sale Type", Revisionsrulle.GetFilter( "Sale Type" ));
        RevPost.SetFilter( "Line No.", Revisionsrulle.GetFilter( "Line No." ));
        RevPost.SetFilter( "No.", Revisionsrulle.GetFilter( "No." ));
        RevPost.SetFilter( "Sale Date", Revisionsrulle.GetFilter( "Sale Date" ));
        RevPost.SetFilter( Type, Revisionsrulle.GetFilter( Type ));
        RevPost.SetFilter( Lokationskode, Revisionsrulle.GetFilter( Lokationskode ));
        RevPost.SetFilter( "Shortcut Dimension 1 Code", Revisionsrulle.GetFilter( "Shortcut Dimension 1 Code" ));
        RevPost.SetFilter( "Shortcut Dimension 2 Code", Revisionsrulle.GetFilter( "Shortcut Dimension 2 Code" ));
        if UpdateDialog then
          Total := Revisionsrulle.Count;
        if Revisionsrulle.Find('-') then repeat
          nCount += 1;
          Revisionsrulle.Description := CopyStr(Revisionsrulle.Description,1,50);
          RevPost.TransferFields( Revisionsrulle );
          //-NPR5.48 [331992]
          RevPost.ApplyDimensions();
          //+NPR5.48 [331992]
          RevPost.Insert;
          if UpdateDialog then
            Dlg.Update( 100, Round( nCount / Total * 10000, 1 ));
        until Revisionsrulle.Next = 0;
        Revisionsrulle.SetRange( Posted );
        if UpdateDialog then
          Dlg.Update( 100, 10000 );
        exit(nCount);
    end;

    procedure DoTransferFromRevItemLedger(var Revisionsrulle: Record "HC Audit Roll";var RevPost: Record "HC Audit Roll Posting" temporary;var Dlg: Dialog;UpdateDialog: Boolean): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        Revisionsrulle.SetCurrentKey( "Sale Type", Type, "Item Entry Posted" );
        Revisionsrulle.SetFilter(Type, '=%1', Revisionsrulle.Type::Item);
        Revisionsrulle.SetRange( "Item Entry Posted", false );

        RevPost.SetFilter( "Register No.", Revisionsrulle.GetFilter( "Register No." ));
        RevPost.SetFilter( "Sales Ticket No.", Revisionsrulle.GetFilter( "Sales Ticket No." ));
        RevPost.SetFilter( "Sale Type", Revisionsrulle.GetFilter( "Sale Type" ));
        RevPost.SetFilter( "Line No.", Revisionsrulle.GetFilter( "Line No." ));
        RevPost.SetFilter( "No.", Revisionsrulle.GetFilter( "No." ));
        RevPost.SetFilter( "Sale Date", Revisionsrulle.GetFilter( "Sale Date" ));
        RevPost.SetFilter( Type, Revisionsrulle.GetFilter( Type ));
        RevPost.SetFilter( Lokationskode, Revisionsrulle.GetFilter( Lokationskode ));
        RevPost.SetFilter( "Shortcut Dimension 1 Code", Revisionsrulle.GetFilter( "Shortcut Dimension 1 Code" ));
        RevPost.SetFilter( "Shortcut Dimension 2 Code", Revisionsrulle.GetFilter( "Shortcut Dimension 2 Code" ));
        if UpdateDialog then
          Total := Revisionsrulle.Count;
        if Revisionsrulle.Find('-') then repeat
          nCount += 1;
          Revisionsrulle.Description := CopyStr(Revisionsrulle.Description,1,50);
          RevPost.TransferFields( Revisionsrulle );
          //-NPR5.48 [331992]
          RevPost.ApplyDimensions();
          //+NPR5.48 [331992]
          RevPost.Insert;
          if UpdateDialog then
            Dlg.Update( 100, Round( nCount / Total * 10000, 1 ));
        until Revisionsrulle.Next = 0;
        Revisionsrulle.SetRange( Posted );
        if UpdateDialog then
          Dlg.Update( 100, 10000 );
        exit(nCount);
    end;

    procedure DoUpdateChanges(var Dlg: Dialog;UpdateDialog: Boolean)
    var
        Revisionsrulle: Record "HC Audit Roll";
        Total: Integer;
        nCount: Integer;
    begin
        //-NPR5.23
        if UpdateDialog then
          Total := Count;
        if Find('-') then repeat
          if UpdateDialog then begin
            nCount += 1;
            Dlg.Update( 103, Round( nCount / Total * 10000, 1 ));
          end;
          Revisionsrulle.Get( "Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date" );
          Revisionsrulle.TransferFields( Rec );
          Revisionsrulle.Modify;
        until Next = 0;
        if UpdateDialog then
          Dlg.Update( 103, 10000 );
        //+NPR5.23
    end;

    procedure ApplyDimensions()
    var
        HCRetailSetup: Record "HC Retail Setup";
        HCDimMgt: Codeunit "HC Dimension Mgt.";
    begin
        //-NPR5.48 [331992]
        HCRetailSetup.Get;
        case HCRetailSetup."Dimensions Posting Type" of
          HCRetailSetup."Dimensions Posting Type"::" ":
            exit;
          HCRetailSetup."Dimensions Posting Type"::Delete:
            begin
              "Shortcut Dimension 1 Code" := '';
              "Shortcut Dimension 2 Code" := '';
              "Dimension Set ID" := 0;
            end;
          HCRetailSetup."Dimensions Posting Type"::Recreate:
            CreateDim(
              DATABASE::"HC Register","Register No.",
              DATABASE::Customer,"Customer No.",
              DATABASE::"Salesperson/Purchaser","Salesperson Code",
              HCDimMgt.TypeToTable(Type),"No.");
          HCRetailSetup."Dimensions Posting Type"::Custom:
            OnCustomApplyDimensions();
        end;
        //+NPR5.48 [331992]
    end;

    procedure CreateDim(Type1: Integer;No1: Code[20];Type2: Integer;No2: Code[20];Type3: Integer;No3: Code[20];Type4: Integer;No4: Code[20])
    var
        HCRetailSetup: Record "HC Retail Setup";
        TableID: array [10] of Integer;
        No: array [10] of Code[20];
        DimMgt: Codeunit DimensionManagement;
    begin
        //-NPR5.48 [331992]
        HCRetailSetup.Get;
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(TableID,No,HCRetailSetup."Posting Source Code","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code",0,0);
        //+NPR5.48 [331992]
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnCustomApplyDimensions()
    begin
    end;
}


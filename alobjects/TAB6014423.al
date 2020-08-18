table 6014423 Period
{
    // NPR4.12/MMV/20150619 CASE 216240 Updated some danish text constant captions
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.35/TJ  /20170809 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused function
    // NPR5.38/BR  /20171108 CASE 295190 Removed SQL Data Type = Integer from field Sales Ticket No.
    // NPR5.48/BHR /20181120 CASE 329505 New fields 165-168
    // NPR5.48/BHR /20190108 CASE 341465 Add missing captions for fields

    Caption = 'Period';
    LookupPageID = "Register Period List";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
            Editable = false;
            NotBlank = true;
        }
        field(3;Status;Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Passive,Ongoing,Balanced,Saved';
            OptionMembers = Passiv,Ongoing,Balanced,Saved;
        }
        field(4;"Balancing Time";Time)
        {
            Caption = 'Balancing Time';
            Editable = false;
            InitValue = 000000T;
            NotBlank = true;

            trigger OnValidate()
            begin
                if Period.Get("No."-1) then
                  if "Balancing Time" < Period."Balancing Time" then
                    Error(Text1060000,"No.",Period."Balancing Time");
            end;
        }
        field(5;"Last Date Active";Date)
        {
            Caption = 'Last Date Active';
            Editable = false;
        }
        field(6;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            Editable = false;
            TableRelation = Register."Register No.";
        }
        field(7;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            Editable = false;
        }
        field(8;Register;Integer)
        {
            Caption = 'Cash Register';
            Editable = false;
        }
        field(9;"Date Opened";Date)
        {
            Caption = 'Date Opened';
            Description = 'overf¢r fra kasse';
            Editable = false;
        }
        field(10;"Date Closed";Date)
        {
            Caption = 'Date Closed';
            Editable = false;
        }
        field(11;"Date Saved";Date)
        {
            Caption = 'Date Saved';
            Editable = false;
        }
        field(12;"Opening Time";Time)
        {
            Caption = 'Opening Time';
            Editable = false;
        }
        field(13;"Closing Time";Time)
        {
            Caption = 'Closing Time';
            Editable = false;
        }
        field(14;"Saving  Time";Time)
        {
            Caption = 'Saving Time';
            Editable = false;
        }
        field(15;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            TableRelation = "Audit Roll"."Sales Ticket No." WHERE (Type=CONST("Open/Close"));
        }
        field(16;"Opening Sales Ticket No.";Code[10])
        {
            Caption = 'Opening Sales Ticket No.';
            Editable = false;
        }
        field(17;Comment;Text[250])
        {
            Caption = 'Comment';
        }
        field(20;"Opening Cash";Decimal)
        {
            Caption = 'Opening Cash';
            Editable = false;
        }
        field(21;"Net. Cash Change";Decimal)
        {
            Caption = 'Net. Cash Change';
            Editable = false;
        }
        field(22;"Net. Credit Voucher Change";Decimal)
        {
            Caption = 'Net. Credit Voucher Change';
            Editable = false;
        }
        field(23;"Net. Gift Voucher Change";Decimal)
        {
            Caption = 'Net. Gift Voucher Change';
            Editable = false;
        }
        field(24;"Net. Terminal Change";Decimal)
        {
            Caption = 'Net. Terminal Change';
            Editable = false;
        }
        field(25;"Net. Dankort Change";Decimal)
        {
            Caption = 'Dankort';
            Editable = false;
        }
        field(26;"Net. VisaCard Change";Decimal)
        {
            Caption = 'Net. VisaCard Change';
            Editable = false;
        }
        field(27;"Net. Change Other Cedit Cards";Decimal)
        {
            Caption = 'Net. Change Other Cedit Cards';
            Editable = false;
        }
        field(28;"Gift Voucher Sales";Decimal)
        {
            Caption = 'Gift Voucher Sales';
            Editable = false;
        }
        field(29;"Credit Voucher issuing";Decimal)
        {
            Caption = 'Credit Voucher issuing';
            Editable = false;
        }
        field(30;"Cash Received";Decimal)
        {
            Caption = 'Cash Received';
            Editable = false;
        }
        field(31;"Pay Out";Decimal)
        {
            Caption = 'Pay Out';
            Editable = false;
        }
        field(32;"Debit Sale";Decimal)
        {
            Caption = 'Debit Sale';
            Editable = false;
        }
        field(33;"Negative Sales Count";Integer)
        {
            Caption = 'NegSalesQty';
            Editable = false;
        }
        field(34;"Negative Sales Amount";Decimal)
        {
            Caption = 'NegSalesAmt';
            Editable = false;
        }
        field(35;Cheque;Decimal)
        {
            Caption = 'Cheque';
            Editable = false;
        }
        field(36;"Balanced Cash Amount";Decimal)
        {
            Caption = 'Balanced Cash Amount';
            Editable = false;
        }
        field(37;"Closing Cash";Decimal)
        {
            Caption = 'Closing Cash';
            Editable = false;
        }
        field(38;Difference;Decimal)
        {
            Caption = 'Difference';
            Editable = false;
        }
        field(39;"Deposit in Bank";Decimal)
        {
            Caption = 'Deposit in Bank';
            Editable = false;
        }
        field(40;"Balance Per Denomination";Text[250])
        {
            Caption = 'Balance Per Denomination';
            Description = 'm¢nt optalt streng separeret af '';''';
            Editable = false;
        }
        field(41;"Balanced Sec. Currency";Text[250])
        {
            Caption = 'Balanced Sec. Currency';
        }
        field(42;"Balanced Euro";Text[250])
        {
            Caption = 'Balanced Euro';
        }
        field(43;"Change Register";Decimal)
        {
            Caption = 'Change Cash Register';
        }
        field(50;"Gift Voucher Debit";Decimal)
        {
            Caption = 'Gift Voucher Debit';
        }
        field(51;"Euro Difference";Decimal)
        {
            Caption = 'Euro Difference';
        }
        field(100;"LCY Count";Text[250])
        {
            Caption = 'LCY Count';
        }
        field(101;"Euro Count";Text[250])
        {
            Caption = 'Euro Count';
        }
        field(102;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(1,"Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code","Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
                Modify;
            end;
        }
        field(103;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(2,"Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code","Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
                Modify;
            end;
        }
        field(104;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(105;"Money bag no.";Code[20])
        {
            Caption = 'Money bag no.';
        }
        field(106;"Alternative Register No.";Code[20])
        {
            Caption = 'Alternative Cash Register No.';
        }
        field(107;"Sales (Qty)";Integer)
        {
            Caption = 'No. of sales';
        }
        field(108;"Sales (LCY)";Decimal)
        {
            Caption = 'Total sales amount';
        }
        field(109;"Cancelled Sales";Integer)
        {
            Caption = 'Cancelled sales';
        }
        field(110;"Campaign Discount (LCY)";Decimal)
        {
            Caption = 'Campaign Discount';
        }
        field(111;"Mix Discount (LCY)";Decimal)
        {
            Caption = 'Mix Discount';
        }
        field(112;"Quantity Discount (LCY)";Decimal)
        {
            Caption = 'Quantity Discount';
        }
        field(113;"Line Discount (LCY)";Decimal)
        {
            Caption = 'Line Discount';
        }
        field(114;"Custom Discount (LCY)";Decimal)
        {
            Caption = 'Custom Discount';
        }
        field(115;"Total Discount (LCY)";Decimal)
        {
            Caption = 'Total Discount';
        }
        field(116;"Net Turnover (LCY)";Decimal)
        {
            Caption = 'Net Turnover';
        }
        field(117;"Net Cost (LCY)";Decimal)
        {
            Caption = 'Net Cost';
        }
        field(118;"Currencies Amount (LCY)";Decimal)
        {
            Caption = 'Currencies Amount';
        }
        field(119;"Profit Amount (LCY)";Decimal)
        {
            Caption = 'Profit Amount';
        }
        field(120;"Profit %";Decimal)
        {
            Caption = 'Profit %';
        }
        field(121;"Turnover Including VAT";Decimal)
        {
            Caption = 'Turnover Including VAT';
        }
        field(125;"Debit Sales (Qty)";Integer)
        {
            Caption = 'Debit Sales (Qty)';
        }
        field(130;"Item Return Amount (LCY)";Decimal)
        {
            Caption = 'Item Return Amount (LCY)';
        }
        field(131;"Item Return Quantity";Decimal)
        {
            Caption = 'Item Return Quantity';
        }
        field(150;"No. Of Goods Sold";Decimal)
        {
            Caption = 'No. Of Goods Sold';
            Description = 'Statistics made for swedish black box';
        }
        field(151;"No. Of Cash Receipts";Decimal)
        {
            Caption = 'No. Of Cash Receipts';
            Description = 'Statistics made for swedish black box';
        }
        field(152;"No. Of Cash Box Openings";Decimal)
        {
            Caption = 'No. Of Cash Box Openings';
            Description = 'Statistics made for swedish black box';
        }
        field(153;"No. Of Receipt Copies";Decimal)
        {
            Caption = 'No. Of Receipt Copies';
            Description = 'Statistics made for swedish black box';
        }
        field(160;"VAT Info String";Text[100])
        {
            Caption = 'VAT Info String';
            Description = 'Statistics made for swedish black box';
        }
        field(165;"Order Amount";Decimal)
        {
            Caption = 'Order Amount';
        }
        field(166;"Invoice Amount";Decimal)
        {
            Caption = 'Invoice Amount';
        }
        field(167;"Return Amount";Decimal)
        {
            Caption = 'Return Amount';
        }
        field(168;"Credit Memo Amount";Decimal)
        {
            Caption = 'Credit Memo Amount';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","No.")
        {
        }
        key(Key2;Status)
        {
        }
        key(Key3;"Register No.",Register,"Sales Ticket No.")
        {
        }
        key(Key4;"Register No.",Status,"No.")
        {
        }
        key(Key5;"Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Location Code")
        {
        }
        key(Key6;"Sales Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        RetailSetup.Get();
        RetailSetup.TestField("Use Adv. dimensions",true);
        if Period.Find('+') then
          "No." := Period."No." + 1
        else
          "No." := 1;
    end;

    var
        Text1060000: Label 'Ending time for period %1 must be after %2 o''clock';
        Period: Record Period;
        RetailSetup: Record "Retail Setup";
        NPRDimMgt: Codeunit NPRDimensionManagement;

    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        RetailSetup.Get;
        if RetailSetup."Use Adv. dimensions" then begin
          NPRDimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
          NPRDimMgt.SaveDefaultDim(DATABASE::Register,"Register No.",FieldNumber,ShortcutDimCode);
          Modify;
        end;
    end;

    procedure WriteBalancingInfo()
    begin
        "Balanced Sec. Currency"      := StrSubstNo('%1;%2;%3;%4;%5;%6;%7;%8;%9;%10;%11;%12;%13;%14;%15;%16;',"Opening Cash",
                                                                   "Net. Cash Change", "Net. Credit Voucher Change",
                                                                   "Net. Gift Voucher Change","Net. Terminal Change",
                                                                   "Net. Dankort Change","Net. VisaCard Change",
                                                                   "Net. Change Other Cedit Cards","Gift Voucher Sales",
                                                                   "Credit Voucher issuing","Cash Received","Pay Out","Debit Sale",
                                                                   "Negative Sales Count","Negative Sales Amount","Gift Voucher Debit");
    end;

    procedure LookUpShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        //Opsætning.GET;
        //IF Opsætning."Brug dimensionsstyring" THEN
          NPRDimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
    end;
}


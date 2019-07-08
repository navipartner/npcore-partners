table 6014414 "Period Discount Line"
{
    // //001 - Ohm - 230904
    //   udmarkeret for at kunne modtage skanner signal
    // 
    // //xxx - Ohm - 05.10.04 - IF Status = Status::Aktiv // alle steder
    // 
    // // NaviShop2.00.00
    // Fields Added:
    //   Internet Number
    // 
    // OnInsert()
    // If lisenced changes is replicated to webshoptable
    // 
    // OnDelete()
    // If lisenced changes is replicated to webshoptable
    // 
    // OnModify()
    // If lisenced changes is replicated to webshoptable
    // NPR70.00.01.00/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR70.00.02.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // NPR4.14/MH/20150818  CASE 220972 Deleted deprecated Web fields and function, calcPriceWithoutTax()
    // NPR5.23/JDH /20160516 CASE 240916 Removed old VariaX Solution
    // NPR5.26/BHR/20160712 CASE 246594 Field 210
    // NPR5.27/TJ/20160926 CASE 248284 Removing unused variables and fields, renaming fields and variables to use standard naming procedures
    // NPR5.29/BHR/20161119 CASE Add fields 35,36
    // NPR5.38/AP  /20171103  CASE 295330 Setting editable=no on flowfields (101, 102, 200 and 201)
    // NPR5.38/MHA /20171106  CASE 295330 Renamed Option "Balanced" to "Closed" for field 6 "Status"
    // NPR5.38/TS  /20171207  CASE 299031 Added field Page No. in advert
    // NPR5.38/TS  /20171213  CASE 299274 Added fields Priority and Page Number
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization. Made several fields true fields instead of flowfields and added a key using all of them.
    // NPR5.50/THRO/20190528  CASE 299278 Corect Campaign Profit Calculation annd campaign price calculated based on profit

    Caption = 'Period Discount Line';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            Editable = false;
            NotBlank = true;
            TableRelation = "Period Discount".Code;
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                CalcFields(Description,"Unit Price");

                //-NPR5.23 [240916]
                // Variation.SETCURRENTKEY("EAN Code");
                // Variation.SETRANGE("EAN Code","Item No.");
                // IF Variation.FIND('-') THEN BEGIN
                //  "Item No."      :=Variation."Item Code";
                //  "Variant Code"  :=Variation."Variant Code";
                // END;
                //+NPR5.23 [240916]

                Item.Get("Item No.");
                "Vendor No.":=Item."Vendor No.";
                "Vendor Item No.":=Item."Vendor Item No.";
            end;
        }
        field(3;Description;Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4;"Unit Price";Decimal)
        {
            CalcFormula = Lookup(Item."Unit Price" WHERE ("No."=FIELD("Item No.")));
            Caption = 'Unit Price';
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 9.999.999;
            MinValue = 0;

            trigger OnValidate()
            begin
                Validate("Campaign Unit Cost");
            end;
        }
        field(5;"Campaign Unit Price";Decimal)
        {
            Caption = 'Period Price';
            MaxValue = 9.999.999;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcFields("Unit Price");
                //-NPR5.40 [294655]
                //CALCFIELDS(Status);
                //+NPR5.40 [294655]
                //IF Status = Status::Aktiv THEN ERROR(Text1060004);
                "Discount Amount" := Round("Unit Price" - "Campaign Unit Price");
                "Discount %" := Round(("Unit Price" - "Campaign Unit Price") / "Unit Price" * 100);
                //-NPR4.14
                //calcPriceWithoutTax();
                //+NPR4.14
                Validate("Campaign Unit Cost");
            end;
        }
        field(6;Status;Option)
        {
            Caption = 'Status';
            Description = 'NPR5.38';
            Editable = false;
            OptionCaption = 'Await,Active,Closed';
            OptionMembers = Await,Active,Closed;
        }
        field(7;"Starting Date";Date)
        {
            Caption = 'Starting Date';
            Editable = false;
        }
        field(8;"Ending Date";Date)
        {
            Caption = 'Closing Date';
            Editable = false;
        }
        field(10;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcFields("Unit Price");
                "Campaign Unit Price" := Round("Unit Price" * ((100-"Discount %") / 100));
                if "Unit Price" < "Campaign Unit Price" then Error(Text1060003);
                "Discount Amount" := Round("Unit Price" - "Campaign Unit Price");
                //-NPR4.14
                //calcPriceWithoutTax();
                //+NPR4.14
            end;
        }
        field(11;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
            MaxValue = 9.999.999;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcFields("Unit Price");
                "Campaign Unit Price" := Round("Unit Price" - "Discount Amount");
                if "Unit Price" < "Campaign Unit Price" then Error(Text1060003);
                "Discount %" := Round(("Unit Price" - "Campaign Unit Price") / "Unit Price" * 100);
                //-NPR4.14
                //calcPriceWithoutTax();
                //+NPR4.14
            end;
        }
        field(12;"Unit Price Incl. VAT";Boolean)
        {
            CalcFormula = Lookup(Item."Price Includes VAT" WHERE ("No."=FIELD("Item No.")));
            Caption = 'Price Includes VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13;"Campaign Unit Cost";Decimal)
        {
            Caption = 'Period Cost';

            trigger OnValidate()
            var
                ItemGroup: Record "Item Group";
                UnitCost: Decimal;
            begin

                if Item.Get("Item No.") then begin
                  ItemGroup.Get(Item."Item Group");
                  //-NPR5.50 [299278]
                  if Item."Price Includes VAT" then begin
                  //+NPR5.50 [299278]
                    VATPostingSetup.SetRange(VATPostingSetup."VAT Bus. Posting Group",ItemGroup."VAT Bus. Posting Group");
                    VATPostingSetup.SetRange(VATPostingSetup."VAT Prod. Posting Group",ItemGroup."VAT Prod. Posting Group");
                    if VATPostingSetup.Find('-') then
                      VATPct := VATPostingSetup."VAT %";
                  //-NPR5.50 [299278]
                  end else
                    VATPct := 0;

                  //IF Item."Price Includes VAT" THEN BEGIN
                  //  IF "Campaign Unit Cost" <> 0 THEN
                  //    Profit := ROUND(("Campaign Unit Price"/(1 + VATPct / 100) - "Campaign Unit Cost"),0.001)
                  //  ELSE Profit:=ROUND(("Campaign Unit Price"/(1 + VATPct / 100) - Item."Unit Cost"),0.001) ;
                  //    IF ("Campaign Unit Price"/(1 + VATPct / 100)) <> 0 THEN
                  //    "Campaign Profit" := ROUND(Profit/("Campaign Unit Price"/(1 + VATPct / 100))*100,0.01)
                  //  ELSE
                  //    DG := 0;
                  //END ELSE BEGIN
                  //  IF "Campaign Unit Cost" <> 0 THEN Profit := ROUND ("Campaign Unit Price"-"Campaign Unit Cost")
                  //    ELSE
                  //  Profit:= "Campaign Unit Price"-Item."Unit Cost";
                  //  "Campaign Profit" := ROUND((Profit / "Campaign Unit Price" * 100),0.01);
                  //END;
                  if "Campaign Unit Cost" <> 0 then
                    UnitCost := "Campaign Unit Cost" * (1 + (VATPct/100))
                  else
                    UnitCost := Item."Unit Cost" * (1 + (VATPct/100));
                  Profit := Round("Campaign Unit Price" - UnitCost,0.001);
                  "Campaign Profit" := 0;
                  if ("Campaign Unit Price" <> 0) and (UnitCost <> 0) then begin
                    "Campaign Profit" := Round((1 - UnitCost / "Campaign Unit Price") * 100,0.001);
                  end;
                  //+NPR5.50 [299278]

                end;
            end;
        }
        field(14;Profit;Decimal)
        {
            Caption = 'Revenue %';
        }
        field(20;Comment;Boolean)
        {
            CalcFormula = Exist("Retail Comment" WHERE ("Table ID"=CONST(6014414),
                                                        "No."=FIELD(Code),
                                                        "No. 2"=FIELD("Item No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21;"Unit Cost Purchase";Decimal)
        {
            Caption = 'Period purchase price';
        }
        field(24;"Distribution Item";Boolean)
        {
            Caption = 'Distributionitem';
        }
        field(25;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
        }
        field(26;"Vendor Item No.";Code[20])
        {
            Caption = 'Vendor Item No.';
        }
        field(27;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(28;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
        }
        field(30;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(31;"Global Dimension 1 Filter";Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
        }
        field(32;"Global Dimension 2 Filter";Code[20])
        {
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
        }
        field(33;"Location Filter";Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
        }
        field(35;"Starting Time";Time)
        {
            Caption = 'Starting Date';
            Editable = false;
        }
        field(36;"Ending Time";Time)
        {
            Caption = 'Closing Date';
            Editable = false;
        }
        field(101;Inventory;Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Item No."=FIELD("Item No."),
                                                                  "Posting Date"=FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code"=FIELD("Location Filter")));
            Caption = 'Inventory Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102;"Quantity On Purchase Order";Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE ("Document Type"=CONST(Order),
                                                                               Type=CONST(Item),
                                                                               "No."=FIELD("Item No."),
                                                                               "Order Date"=FIELD("Date Filter"),
                                                                               "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
                                                                               "Location Code"=FIELD("Location Filter")));
            Caption = 'Quantity in Purchase Order';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200;"Quantity Sold";Decimal)
        {
            CalcFormula = -Sum("Item Ledger Entry".Quantity WHERE ("Item No."=FIELD("Item No."),
                                                                   "Discount Type"=CONST(Period),
                                                                   "Discount Code"=FIELD(Code),
                                                                   "Entry Type"=CONST(Sale),
                                                                   "Posting Date"=FIELD("Date Filter"),
                                                                   "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                   "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'Sold Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201;Turnover;Decimal)
        {
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE ("Item No."=FIELD("Item No."),
                                                                           "Discount Type"=CONST(Period),
                                                                           "Discount Code"=FIELD(Code),
                                                                           "Item Ledger Entry Type"=CONST(Sale),
                                                                           "Posting Date"=FIELD("Date Filter"),
                                                                           "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
                                                                           "Location Code"=FIELD("Location Filter")));
            Caption = 'Turnover';
            Editable = false;
            FieldClass = FlowField;
        }
        field(202;"Internet Special Id";Integer)
        {
            AutoIncrement = true;
            Caption = 'Internet Special ID';
        }
        field(203;"Campaign Profit";Decimal)
        {
            Caption = 'Campaign Profit';

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
                ItemGroup: Record "Item Group";
                UnitCost: Decimal;
            begin
                //-NPR5.50 [299278]
                if ("Campaign Profit" < 100) and Item.Get("Item No.") then begin
                  GLSetup.Get();
                  ItemGroup.Get(Item."Item Group");
                  if Item."Price Includes VAT" then begin
                    VATPostingSetup.SetRange(VATPostingSetup."VAT Bus. Posting Group",ItemGroup."VAT Bus. Posting Group");
                    VATPostingSetup.SetRange(VATPostingSetup."VAT Prod. Posting Group",ItemGroup."VAT Prod. Posting Group");
                    if VATPostingSetup.Find('-') then
                      VATPct := VATPostingSetup."VAT %";
                  end else
                    VATPct := 0;

                  if "Campaign Unit Cost" <> 0 then
                    UnitCost := "Campaign Unit Cost"
                  else
                    UnitCost := Item."Unit Cost";
                  "Campaign Unit Price" := Round((UnitCost / (1 - "Campaign Profit" / 100)) * (1 + VATPct/100),
                                                 GLSetup."Unit-Amount Rounding Precision");
                end;
                //+NPR5.50 [299278]
            end;
        }
        field(210;"Cross-Reference No.";Code[20])
        {
            Caption = 'Cross-Reference No.';

            trigger OnLookup()
            var
                BarcodeLibrary: Codeunit "Barcode Library";
            begin
                //-NPR5.26 [246594]
                BarcodeLibrary.CallCrossRefNoLookupPeriodicDiscount(Rec);
                //+NPR5.26 [246594]
            end;
        }
        field(215;"Page no. in advert";Integer)
        {
            Caption = 'Page no. in advert';
            Description = 'NPR5.38';
        }
        field(217;Priority;Code[10])
        {
            Caption = 'Priority';
            Description = 'NPR5.38';
        }
        field(219;"Pagenumber in paper";Text[30])
        {
            Caption = 'Pagenumber in paper';
            Description = 'NPR5.38';
        }
        field(220;Photo;Boolean)
        {
            Caption = 'Photo';
            Description = 'NPR5.38';
        }
    }

    keys
    {
        key(Key1;"Code","Item No.","Variant Code")
        {
        }
        key(Key2;"Item No.")
        {
        }
        key(Key3;"Last Date Modified")
        {
        }
        key(Key4;"Item No.","Variant Code",Status,"Starting Date","Ending Date","Starting Time","Ending Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RetailComment: Record "Retail Comment";
    begin
        RetailComment.SetRange("Table ID",6014414);
        RetailComment.SetRange("No.",Code);
        RetailComment.SetRange("No. 2","Item No.");
        RetailComment.DeleteAll;
    end;

    trigger OnInsert()
    var
        QtyDiscLine: Record "Quantity Discount Line";
    begin
        QtyDiscLine.SetRange( "Item No.", "Item No." );
        if QtyDiscLine.Find('-') then
          Message( Text1060005 );

        UpdatePeriodDiscount;

        //-NPR5.40 [294655]
        UpdateLine();
        //+NPR5.40 [294655]
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        UpdatePeriodDiscount;

        //-NPR5.40 [294655]
        UpdateLine();
        //+NPR5.40 [294655]
    end;

    trigger OnRename()
    var
        RetailComment: Record "Retail Comment";
        RetailComment2: Record "Retail Comment";
    begin
        UpdatePeriodDiscount;

        RetailComment.SetRange("Table ID",6014414);
        RetailComment.SetRange("No.",xRec.Code);
        RetailComment.SetRange("No. 2",xRec."Item No.");
        if RetailComment.Find('-') then
          repeat
            RetailComment2.Copy(RetailComment);
            if Code <> xRec.Code then begin
              RetailComment2.Validate("No.",Code);
              if not RetailComment2.Insert(true) then
                RetailComment2.Modify(true);
            end;
            if "Item No." <> xRec."Item No." then begin
              RetailComment2.Validate("No. 2","Item No.");
              if not RetailComment2.Insert(true) then
                RetailComment2.Modify(true);
            end;
          until RetailComment.Next = 0;
        RetailComment.DeleteAll;

        //-NPR5.40 [294655]
        UpdateLine();
        //+NPR5.40 [294655]
    end;

    var
        Text1060003: Label 'The special offer price exceeds the normal retail price!';
        Item: Record Item;
        Text1060005: Label 'This items includes multi unit prices, which will be controlled by period discounts';
        VATPostingSetup: Record "VAT Posting Setup";
        DG: Decimal;
        VATPct: Decimal;

    procedure UpdatePeriodDiscount()
    var
        PeriodDiscount: Record "Period Discount";
    begin
        if PeriodDiscount.Get(Rec.Code) then begin
          PeriodDiscount."Last Date Modified" := Today;
          PeriodDiscount.Modify;
        end;
    end;

    procedure ShowComment()
    var
        RetailComment: Record "Retail Comment";
    begin
        RetailComment.SetRange("Table ID",6014414);
        if Code <> '' then
          if "Item No." <> '' then begin
            RetailComment.SetRange("No.",Code);
            RetailComment.SetRange("No. 2","Item No.");
            /*FORMREF
            NPRBem�rkningslinjeFrm.SETTABLEVIEW(NPRBem�rkningslinjeRec);
            NPRBem�rkningslinjeFrm.RUNMODAL;
            */
          end;

    end;

    local procedure UpdateLine()
    var
        PeriodDiscount: Record "Period Discount";
    begin
        //-NPR5.40 [294655]
        if PeriodDiscount.Get(Code) then begin
          "Starting Date" := PeriodDiscount."Starting Date";
          "Ending Date" := PeriodDiscount."Ending Date";
          "Starting Time" := PeriodDiscount."Starting Time";
          "Ending Time" := PeriodDiscount."Ending Time";
          Status := PeriodDiscount.Status;
        end;
        //+NPR5.40 [294655]
    end;
}


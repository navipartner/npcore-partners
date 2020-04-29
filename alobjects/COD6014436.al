codeunit 6014436 "Retail Sales Line Code"
{
    // NPR70.00.01.04/BHR/20150120 CASE 203485. Block Item Sales on pos
    // NPR4.10/VB  /20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.16/TS  /20150818  CASE 218497 Added code to search Item in Item Cross Reference
    // NPR4.16/BHR /20151014  CASE 224603 Checks for totalAmount Discount < total sales amount
    //                                    Corrected bug in case amountincludingvat=0 , discount should still be calculated.
    // NPR4.16/JDH /20151110  CASE 225285 Removed Color and Size functionality
    // NPR5.00/VB  /20151221  CASE 229375 Limiting search box to 50 characters
    // NPR5.00/VB  /20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 229375 NP Retail 2016
    // NPR5.26/BHR /20160811  CASE 246712 Exclude discount on -ve enties and prevent discount when total is less than 0
    // NPR5.26/MMV /20160830  CASE 241549 Updated register closing print.
    // NPR5.27/JDH /20161017  CASE 252191 Removed validation from accessory lines to MainItemline.
    // NPR5.29/JDH /20170105  CASE 260472 Moved description Control to new CU
    // NPR5.29/MHA /20170117  CASE 263043 Added functions to restructure sequence in GetTrueItemNo(): UpdSaleLineFromAlternativeNo(), UpdSaleLineFromEan(), UpdSaleLineFromItemCrossRef()
    // NPR5.29/BHR /20172301  CASE 264081 Condition To validate field for type::Service
    // NPR5.30/MHA /20170221  CASE 266782 Added Check on string is Number before STRCHECKSUM in UpdSaleLineFromEan()
    // NPR5.31/BR  /20170321  CASE 267602 Check on blocked Variant
    // NPR5.31/MHA /20170210  CASE 262904 Deleted Functions: InitDiscountPriorities(),RunDiscounts(),RunDiscount(),ApplyTempSaleLines(),GenerateTempSalesLines()
    // NPR5.31/AP  /20170302  CASE 248534 Refactoring VAT, Sales Tax
    // NPR5.31/AP  /20170302  CASE 266785 Removing wrong usage of location codes, dimensions etc.
    // NPR5.31/MHA /20170413  CASE 272109 BOM Parent Items is set to Type "BOM List" which will result in Comment Line in BomComponent()
    // NPR5.38/MMV /20171123  CASE 297223 Pull item base UoM until the POS properly supports working in non base UoM.
    // NPR5.40/TSA /20180214  CASE 305045 Added cascade of quantity to accessory items in QuantityValidate(), not depending on accessory line number scheme
    // NPR5.40/MMV /20180220  CASE 294655 Performance optimization
    // NPR5.40.01/JDH/20180417 CASE 311666 Changed Calculation of line amount to after unit price has been updated
    // NPR5.41/JC  /20180424  CASE 312492 Disable Item group check as some customers might not use it
    // NPR5.41/MMV /20180430  CASE 313378 Changed implementation of 311666 to fix unit price bug.
    // NPR5.42/MMV /20180504  CASE 297569 Allow custom discount block by default.
    // NPR5.42/MMV /20180524  CASE 315838 SQL performance
    // NPR5.43/JDH /20180703  CASE 321227 Reintroduced a modifyall, that was needed before a Findset, due to changing values in the current key
    // NPR5.45/MHA /20180803  CASE 323705 Signature changed on SaleLinePOS.FindItemSalesPrice()
    // NPR5.45/MHA /20180821  CASE 324395 Deleted functions BOMComponent(),GetTrueItemNo(),SetItemData(),TestItem(),UpdSaleLineFromAlternativeNo(),UpdSaleLineFromEan(),UpdSaleLineFromItemCrossRef(),Unit()
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    TableNo = "Sale POS";

    trigger OnRun()
    var
        npc: Record "Retail Setup";
        Revisionsrulle: Record "Audit Roll";
        ReportSelectionRetail: Record "Report Selection Retail";
        RecRef: RecordRef;
        RetailReportSelMgt: Codeunit "Retail Report Selection Mgt.";
    begin
        npc.Get;

        if npc."Print Register Report" then begin
          Clear(Revisionsrulle);
          Revisionsrulle.SetRange("Register No.","Register No.");
          Revisionsrulle.SetRange("Sales Ticket No.","Sales Ticket No.");
          if (Revisionsrulle.Count <> 0) then begin
            //-NPR5.26 [24154]
            RecRef.GetTable(Revisionsrulle);
            RetailReportSelMgt.SetRegisterNo("Register No.");
            RetailReportSelMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Register Balancing");
            //+NPR5.26 [24154]
          end;
        end;
    end;

    var
        RetailSetup: Record "Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Marshaller: Codeunit "POS Event Marshaller";

    procedure AskReasonCode(): Code[10]
    var
        ReasonCode: Record "Reason Code";
        Text001: Label 'You must choose reason of discount!';
        Register: Record Register;
        RetailFormCode: Codeunit "Retail Form Code";
        ReasonCodes: Page "Reason Codes";
        Text002: Label 'Error';
        ReasonDescription: Text[50];
        ReasonNoSeriesCode: Code[20];
        TxtEnterReasonCodeTS: Label 'Enter Reason Description';
    begin
        RetailSetup.Get;
        Register.Get( RetailFormCode.FetchRegisterNumber );
        if RetailSetup."Reason on Discount" = RetailSetup."Reason on Discount"::Check then begin
          Clear(ReasonCodes);
          ReasonCodes.LookupMode( true );
          ReasonCodes.Editable( false );
          if ReasonCodes.RunModal = ACTION::LookupOK then begin
            ReasonCodes.GetRecord( ReasonCode );
            exit(ReasonCode.Code);
          end else
            if Register.Touchscreen then
              Marshaller.DisplayError(Text002,Text001,true)
            else
              Error(Text001);
        end else if RetailSetup."Reason on Discount" = RetailSetup."Reason on Discount"::Create then begin
          ReasonDescription := CopyStr(Marshaller.SearchBox(TxtEnterReasonCodeTS,RetailSetup.FieldCaption("Reason on Discount"),50),1,50);

          NoSeriesMgt.InitSeries(RetailSetup."Reason Code No. Series",'',0D, ReasonNoSeriesCode, RetailSetup."Reason Code No. Series");

          ReasonCode.Init;
          ReasonCode.Code := CopyStr(ReasonNoSeriesCode,1,10); //Extend Code Field to 20
          ReasonCode.Description := ReasonDescription;
          ReasonCode.Insert(true);
          exit(ReasonCode.Code);
        end;

        exit('');
    end;

    procedure CalcAmounts(var SaleLinePOS: Record "Sale Line POS")
    var
        Item: Record Item;
    begin
        Item.Get( SaleLinePOS."No." );
        SaleLinePOS.GetAmount( SaleLinePOS, Item, SaleLinePOS."Unit Price" );
    end;

    procedure GetAltNoType(validering1: Code[50]): Integer
    var
        AltNo: Record "Alternative No.";
    begin
        AltNo.Reset;
        AltNo.SetCurrentKey("Alt. No.",Type);
        AltNo.SetRange("Alt. No.", validering1);

        if AltNo.FindFirst then begin
          if AltNo.Count = 1 then
            exit(AltNo.Type)
          else begin
            exit(AltNo.Type::Item);
          end;
        end else
          exit(AltNo.Type::Item);
    end;

    procedure GetSalesAmountInclVAT(SalePOS: Record "Sale POS") Total: Decimal
    var
        SalesLinePOS: Record "Sale Line POS";
    begin
        with SalePOS do begin
          SalesLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
          SalesLinePOS.SetRange("Register No.","Register No.");
          SalesLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SalesLinePOS.SetFilter(Type,'%1|%2',SalesLinePOS.Type::Item,SalesLinePOS.Type::"G/L Entry");
          SalesLinePOS.SetFilter("Sale Type",'%1|%2',SalesLinePOS."Sale Type"::Sale,SalesLinePOS."Sale Type"::Deposit);
          SalesLinePOS.CalcSums(Amount,"Amount Including VAT");
          exit(SalesLinePOS."Amount Including VAT");
        end;
    end;

    procedure LineExists(var Eksp: Record "Sale POS"): Boolean
    var
        EkspLinie: Record "Sale Line POS";
    begin
        EkspLinie.SetRange("Register No.", Eksp."Register No.");
        EkspLinie.SetRange("Sales Ticket No.", Eksp."Sales Ticket No.");
        EkspLinie.SetRange(Date, Eksp.Date);
        if EkspLinie.FindFirst then exit(true)
        else exit(false);
    end;

    procedure OnAfterInsertSalesLine(var "Sales Line": Record "Sale Line POS";var SalesLineCopy: Record "Sale Line POS")
    var
        Item: Record Item;
        DiscountPct: Decimal;
        EkspeditionsMenu: Codeunit "Retail Sales Code";
        FirstLinie: Record "Sale Line POS";
        Register: Record Register;
        SalePOS: Record "Sale POS";
    begin
        Register.Get("Sales Line"."Register No.");
        RetailSetup.Get;

        case "Sales Line".Type of
          "Sales Line".Type::Item :
            begin
              SalesLineCopy := "Sales Line";
              SalePOS.Reset;
              SalePOS.Get("Sales Line"."Register No.","Sales Line"."Sales Ticket No.");
              DiscountPct := EkspeditionsMenu.ExtractCombination( SalesLineCopy );
              Commit;
              EkspeditionsMenu.ExtractAccessory( SalesLineCopy, false );

              if not ( DiscountPct = 0 ) then begin
                "Sales Line"."Discount Type" := "Sales Line"."Discount Type"::Combination;
                "Sales Line"."Discount %" := DiscountPct;
                "Sales Line"."Discount Amount" := "Sales Line"."Unit Price" * "Sales Line".Quantity * DiscountPct / 100;
                "Sales Line"."Amount Including VAT" := "Sales Line"."Unit Price" * "Sales Line".Quantity * ( 100 - DiscountPct ) / 100;
                "Sales Line".Amount := "Sales Line"."Amount Including VAT" * ( 100 - "Sales Line"."VAT %" ) / 100;
                if FirstLinie.Get( "Sales Line"."Register No.",
                                   "Sales Line"."Sales Ticket No.",
                                   "Sales Line".Date,
                                   "Sales Line"."Sale Type",
                                   "Sales Line"."Line No." + 100 ) then begin
                  "Sales Line"."Combination No." := FirstLinie."Combination No.";
                  "Sales Line"."Discount Code" := "Sales Line"."Combination No.";
                end;
              end;

              if Item.Get("Sales Line"."No.") then begin
                if Item."Guarantee voucher" and ( "Sales Line".Quantity > 0 ) and not "Sales Line".GuaranteePrinted then begin
                  case Register."Sales Ticket Print Output" of
                    Register."Sales Ticket Print Output"::STANDARD,
                    Register."Sales Ticket Print Output"::DEVELOPMENT :
                      begin
                        "Sales Line".PrintWarrantyCertificate("Sales Line",'AUTO',false);
                        "Sales Line".GuaranteePrinted := true;
                        if "Sales Line".Modify then;
                      end;
                  end;
                end;
              end;
            end;
        end;
    end;

    procedure QuantityValidate(var Rec: Record "Sale Line POS";var xRec: Record "Sale Line POS")
    var
        VareEnhed: Record "Item Unit of Measure";
        Item: Record Item;
        Linie: Record "Sale Line POS";
        OldUnitPrice: Decimal;
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;

        with Rec do begin
          VareEnhed.SetRange( "Item No.", "No." );
          VareEnhed.SetRange( Code, "Unit of Measure Code" );
          if VareEnhed.FindFirst then
            Validate( "Quantity (Base)", VareEnhed."Qty. per Unit of Measure" * Quantity )
          else
            Validate( "Quantity (Base)", Quantity );

          if NegPriceZero and ( Quantity > 0 ) then begin
            NegPriceZero := false;
            "Eksp. Salgspris" := false;
          end;

          Item.Get( "No." );

          if ( not Silent ) and ( xRec.Quantity <> 0 ) then begin
            //-NPR5.40 [305045] TSD is numbering lines differently. Implmented "Main Line No." as reference
            // NOTE: TSD Allows auto split key on new lines
            Linie.SetFilter ("Register No.", '=%1', "Register No." );
            Linie.SetFilter ("Sales Ticket No.", '=%1', "Sales Ticket No." );
            Linie.SetFilter ("Sale Type", '=%1', "Sale Type"::Sale );
            Linie.SetFilter ("Main Line No.", '=%1', "Line No.");
            Linie.SetFilter (Accessory, '=%1', true ); // not really required, would also be one solution for combination items below
            Linie.SetFilter ("Main Item No.", '=%1', "No." ); // not really required, would also be one solution for combination items below
            if (Linie.FindSet (true,false)) then repeat
              Linie.Silent := true;
              Linie.Validate (Quantity, Linie.Quantity * Quantity / xRec.Quantity );
              Linie.Silent := false;
              Linie.SetSkipCalcDiscount (true);
              Linie.Modify;
            until Linie.Next = 0;
            Linie.Reset;

            Linie.SetFilter ("Main Line No.", '=%1', 0); // STD will have "Main Line No." as 0 and this function should not interfer in TSD.
            //+NPR5.40 [305045]

            Linie.SetRange( "Register No.", "Register No." );
            Linie.SetRange( "Sales Ticket No.", "Sales Ticket No." );
            Linie.SetRange( "Sale Type", "Sale Type"::Sale );
            Linie.SetRange( "Line No.", "Line No." , "Line No." + 9999);
            Linie.SetRange( Accessory, true );
            Linie.SetRange( "Main Item No.", "No." );
            if Linie.FindSet(true,false) then repeat
              Linie.Silent := true;
              Linie.Validate( Quantity, Linie.Quantity * Quantity / xRec.Quantity );
              Linie.Silent := false;
              //-NPR5.31 [262904]
              Linie.SetSkipCalcDiscount(true);
              //+NPR5.31 [262904]
              Linie.Modify;
            until Linie.Next = 0;
            Linie.Reset;

            Linie.SetRange( "Register No.", "Register No." );
            Linie.SetRange( "Sales Ticket No.", "Sales Ticket No." );
            Linie.SetRange( Date, Date );
            Linie.SetRange( "Sale Type", "Sale Type"::Sale );
            Linie.SetRange( "Line No.", "Line No.", "Line No." + 9999 );
            Linie.SetRange( "Combination Item", true );
            Linie.SetRange( "Main Item No.", "No." );
            Linie.SetRange( "Combination No.", "Combination No." );
            if Linie.FindSet(true,false) then repeat
              Linie.Silent := true;
              Linie.Validate( Quantity, Linie.Quantity * Quantity / xRec.Quantity );
              Linie.Silent := false;
              //-NPR5.31 [262904]
              Linie.SetSkipCalcDiscount(true);
              //+NPR5.31 [262904]
              Linie.Modify;
            until Linie.Next = 0;
          end;
          if ( "Discount Type" = "Discount Type"::Manual ) and ( "Discount %" <> 0 ) then
            Validate( "Discount %" );

          //-NPR5.41 [313378]
          UpdateAmounts(Rec);
          //+NPR5.41 [313378]

          if not Item."Group sale" then begin
            //-NPR5.41 [313378]
            OldUnitPrice := "Unit Price";
            //+NPR5.41 [313378]
            //-NPR5.45  [323705]
            //"Unit Price"    := FindItemSalesPrice( Rec );
            "Unit Price" := Rec.FindItemSalesPrice();
            //+NPR5.45  [323705]
            //-NPR5.41 [313378]
            if OldUnitPrice <> "Unit Price" then
              UpdateAmounts(Rec);
            //+NPR5.41 [313378]
          end;

          //-NPR5.41 [313378]
          //-NPR5.40.01 [311666]
          //GetAmount( Rec, Item, "Unit Price" );
          //+NPR5.40.01 [311666]
          //+NPR5.41 [313378]
        end;
    end;

    procedure SetupObjectNoList(var TempObject: Record AllObj temporary)
    var
        "Object": Record AllObj;
        DiscountPriorities: array [5] of Integer;
        Index: Integer;
        NumberOfObjects: Integer;
    begin
        NumberOfObjects := 4;
        DiscountPriorities[1] := DATABASE::"Mixed Discount";
        DiscountPriorities[2] := DATABASE::"Sales Line Discount";
        DiscountPriorities[3] := DATABASE::"Period Discount";
        DiscountPriorities[4] := DATABASE::"Quantity Discount Header";

        //-NPR5.46 [322752]
        //Object.SETRANGE(Type,Object.Type::Table);
        Object.SetRange("Object Type",Object."Object Type"::Table);
        //+NPR5.46 [322752]
        for Index := 1 to NumberOfObjects do begin
          //-NPR5.46 [322752]
          //Object.SETRANGE(Object.ID,DiscountPriorities[Index]);
          Object.SetRange("Object ID",DiscountPriorities[Index]);
          //+NPR5.46 [322752]
          if Object.FindFirst then begin
            TempObject := Object;
            TempObject.Insert;
          end;
        end;
    end;

    procedure "-- Manual Discount Handling"()
    begin
    end;

    procedure ApplyDiscountPercentOnLines(var SalePOS: Record "Sale POS";DiscountPct: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);

        SaleLinePOS.SetRange("Custom Disc Blocked",false);
        SaleLinePOS.SetSkipCalcDiscount(true);
        //-NPR5.42 [315838]
        // SaleLinePOS.MODIFYALL( "Discount Type", SaleLinePOS."Discount Type"::Manual );
        //
        // IF SaleLinePOS.FINDSET THEN REPEAT
        //-NPR5.43 [321227]
        SaleLinePOS.ModifyAll("Discount Type", SaleLinePOS."Discount Type"::Manual);
        //+NPR5.43 [321227]

        if SaleLinePOS.FindSet(true) then repeat
          SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        //+NPR5.42 [315838]
          if SaleLinePOS."Amount Including VAT" >= 0 then begin
            SaleLinePOS."Discount %"      := DiscountPct;
            SaleLinePOS."Discount Amount" := 0;
        //-NPR5.42 [315838]
        //    Item.GET( SaleLinePOS."No." );
        //    SaleLinePOS.GetAmount( SaleLinePOS, Item, SaleLinePOS."Unit Price" );
        //    SaleLinePOS.MODIFY;
            SaleLinePOS.UpdateAmounts(SaleLinePOS);
        //+NPR5.42 [315838]
          end;
        //-NPR5.42 [315838]
          SaleLinePOS.Modify;
        //+NPR5.42 [315838]
        until SaleLinePOS.Next = 0;
    end;

    procedure ApplyFilterOnLines(var SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS.SetCurrentKey( "Register No.", "Sales Ticket No.", Date, "Sale Type", Type, "Discount Type" );
        SaleLinePOS.SetRange( "Register No.", SalePOS."Register No." );
        SaleLinePOS.SetRange( "Sales Ticket No.", SalePOS."Sales Ticket No." );
        SaleLinePOS.SetRange( "Sale Type", SaleLinePOS."Sale Type"::Sale );
        SaleLinePOS.SetRange( Type, SaleLinePOS.Type::Item );
        //-NPR5.26 [246712]
        SaleLinePOS.SetFilter(Quantity,'>%1',0);
        //+NPR5.26 [246712]
    end;

    procedure GetLinesTotalDiscountableValue(var SalePOS: Record "Sale POS") TotalLineValue: Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);

        if SaleLinePOS.FindSet then repeat
          if not (SaleLinePOS."Custom Disc Blocked") then begin
            if SaleLinePOS."Price Includes VAT" then
              TotalLineValue +=  SaleLinePOS.Quantity * SaleLinePOS."Unit Price"
            else
              TotalLineValue += SaleLinePOS.Quantity * ( SaleLinePOS."Unit Price" * ( ( 100 + SaleLinePOS."VAT %" ) / 100) );
          end else begin
            if SaleLinePOS."Price Includes VAT" then
              TotalLineValue += SaleLinePOS."Amount Including VAT"
            else
              TotalLineValue += SaleLinePOS."Amount Including VAT" * ( 100 + SaleLinePOS."VAT %" ) / 100;
          end;
        until SaleLinePOS.Next = 0;
    end;

    procedure SetTotalDiscountAmount(var SalePOS: Record "Sale POS";TotalDiscountAmount: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        t001: Label 'Total discount amount entered must be less than the Sale Total!';
        TotalPrice: Decimal;
        DiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);

        TotalPrice  := GetLinesTotalDiscountableValue(SalePOS);
        //-NPR4.16
        if TotalPrice < TotalDiscountAmount then
          Error(t001);
        //+NPR4.16
        DiscountPct := TotalDiscountAmount / TotalPrice * 100;

        ApplyDiscountPercentOnLines(SalePOS,DiscountPct)
    end;

    procedure SetTotalAmount(var SalePOS: Record "Sale POS";Amount: Decimal): Boolean
    var
        t001: Label 'Total Amount entered must be less than the Sale Total!';
        SaleLinePOS: Record "Sale Line POS";
        DiscountPct: Decimal;
        TotalPrice: Decimal;
    begin
        ApplyFilterOnLines(SalePOS,SaleLinePOS);
        TotalPrice  := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := (TotalPrice - Amount) / TotalPrice * 100;
        //-NPR5.26 [246712]
        if DiscountPct < 0 then
          Error(t001);
        //+NPR5.26 [246712]
        ApplyDiscountPercentOnLines(SalePOS,DiscountPct)
    end;
}


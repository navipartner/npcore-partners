codeunit 6014481 "Sales Price Maintenance Event"
{
    // NPR5.25/CLVA/20160628 CASE 244461 Sales Price Maintenance
    // NPR5.33/BHR /20161013 CASE 254736 Initialisation of Salesprices for staff.
    // NPR5.33/CLVA/20170607 CASE 272906 Added support for item group exclusions
    // NPR5.38/BR  /20171011 CASE 288383 Restructured to also trigger on other updates of relevant fields
    // NPR5.49/TJ  /20190225 CASE 345782 Function UpdateSalesPricesForStaff set as global
    // NPR5.51/CLVA/20190704 CASE 360328 Added recursive item group validation
    // NPR5.51/CLVA/20180710 CASE 361213 Added item check
    // NPR5.51/MHA /20190722 CASE 358985 Added hook OnGetVATPostingSetup() in UpdateSalesPricesForStaff()


    trigger OnRun()
    begin
        EventTest(true);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, true)]
    local procedure ItemOnAfterModifyEvent(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    begin
        //-NPR5.38 [288383]
        if not RunTrigger then
          exit;
        if (Rec."Unit Cost" = xRec."Unit Cost") and
           (Rec."Last Direct Cost" = xRec."Last Direct Cost") and
           (Rec."Unit Price" = xRec."Unit Price") and
           (Rec."Standard Cost" = xRec."Standard Cost") and
           (Rec."Item Group" = xRec."Item Group") then
          exit;
        UpdateSalesPricesForStaff(Rec);
        //+NPR5.38 [288383]
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Last Direct Cost', true, true)]
    local procedure OnAfterValidateLastDirectCostEvent(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    begin
        //-NPR5.38 [288383]
        UpdateSalesPricesForStaff(Rec);
        //+NPR5.38 [288383]
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Price/Profit Calculation', true, true)]
    local procedure OnAfterValidatePriceProfitCalcEvent(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    begin
        //-NPR5.38 [288383]
        UpdateSalesPricesForStaff(Rec);
        //+NPR5.38 [288383]
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Price', true, true)]
    local procedure OnAfterValidateUnitPriceEvent(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    begin
        //-NPR5.38 [288383]
        UpdateSalesPricesForStaff(Rec);
        //+NPR5.38 [288383]
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterPostItemJnlLine', '', true, true)]
    local procedure OnAfterPostItemJournalLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        //-NPR5.38 [288383]
        if Item.Get(ItemJournalLine."Item No.") then
          UpdateSalesPricesForStaff(Item);
        //+NPR5.38 [288383]
    end;

    local procedure ConvertPriceLCYToFCY(PricesInCurrency: Boolean;ExchRateDate: Date;Currency: Record Currency;var UnitPrice: Decimal;CurrencyFactor: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
          UnitPrice := CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate,Currency.Code,UnitPrice,CurrencyFactor);
          UnitPrice := Round(UnitPrice,Currency."Unit-Amount Rounding Precision");
        end;
    end;

    local procedure EventTest(RuntriggerTest: Boolean)
    var
        Item: Record Item;
    begin
        //-NPR5.33 [254736]
        // Item.GET('CR0-IW0081');
        // Item.Description := 'TEST 01';
        //
        // IF RuntriggerTest THEN
        //  Item.MODIFY(TRUE)
        // ELSE
        //  Item.MODIFY(FALSE);

        Item.SetRange("No.",'0000050536191');
        if Item.FindSet then
         repeat
          if Item."No." <> '' then
           if Item.Modify(true) then;
        until Item.Next=0;
        //-NPR5.33 [254736]
    end;

    procedure UpdateSalesPricesForStaff(var Item: Record Item)
    var
        SalesPriceMaintenanceSetup: Record "Sales Price Maintenance Setup";
        "Sales Price": Record "Sales Price";
        Found: Boolean;
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerPriceGroup: Record "Customer Price Group";
        Campaign: Record Campaign;
        VATPct: Decimal;
        ChangeKey: Boolean;
        VATBusPostingGrp: Code[10];
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyFactor: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchRateDate: Date;
        UnitPrice: Decimal;
        PricesInCurrency: Boolean;
        RecRef: RecordRef;
        BreakLoop: Boolean;
        SalesPriceMaintenanceGroups: Record "Sales Price Maintenance Groups";
        TmpItem: Record Item;
        POSTaxCalculation: Codeunit "POS Tax Calculation";
        Handled: Boolean;
    begin
        //-NPR5.38 [288383] Moved from Subscriber function to it's own
        RecRef.GetTable(Item);
        if RecRef.IsTemporary then
          exit;

        //-NPR5.51 [361213]
        if not TmpItem.Get(Item."No.") then
          exit;
        //+NPR5.51 [361213]

        if SalesPriceMaintenanceSetup.FindFirst then begin

          ExchRateDate := Today;
          GeneralLedgerSetup.Get;

          repeat
            //-NPR5.33
            SalesPriceMaintenanceSetup.CalcFields("Exclude Item Groups");
            BreakLoop := SalesPriceMaintenanceSetup."Exclude All Item Groups";
            if not BreakLoop then begin
              if Item."Item Group" <> '' then
                //-NPR5.51
                //IF SalesPriceMaintenanceSetup."Exclude Item Groups" > 0 THEN
                  //IF SalesPriceMaintenanceGroups.GET(SalesPriceMaintenanceSetup.Id,Item."Item Group") THEN
                  //  BreakLoop := TRUE;
                if SalesPriceMaintenanceSetup."Exclude Item Groups" > 0 then begin
                  Clear(SalesPriceMaintenanceGroups);
                  SalesPriceMaintenanceGroups.SetRange(Id,SalesPriceMaintenanceSetup.Id);
                  if SalesPriceMaintenanceGroups.FindSet then begin
                    repeat
                      if not BreakLoop then
                        BreakLoop := ExcludeItemGroup(Item."Item Group", SalesPriceMaintenanceGroups."Item Group");
                    until SalesPriceMaintenanceGroups.Next = 0;
                  end;
                end;
                //+NPR5.51
            end;

            if not BreakLoop then begin
            //+NPR5.33
              VATPct := 0;
              VATBusPostingGrp := '';
              PricesInCurrency := false;

              Clear("Sales Price");
              "Sales Price".SetRange("Item No.",Item."No.");
              "Sales Price".SetRange("Sales Type",SalesPriceMaintenanceSetup."Sales Type");
              "Sales Price".SetRange("Sales Code",SalesPriceMaintenanceSetup."Sales Code");
              "Sales Price".SetRange("Currency Code",SalesPriceMaintenanceSetup."Currency Code");

              if not "Sales Price".FindFirst then begin
                Clear("Sales Price");
                "Sales Price".Init;
                "Sales Price".Validate("Item No.",Item."No.");
                "Sales Price".Validate("Sales Type",SalesPriceMaintenanceSetup."Sales Type");
                "Sales Price".Validate("Sales Code",SalesPriceMaintenanceSetup."Sales Code");
                "Sales Price".Validate("Currency Code",SalesPriceMaintenanceSetup."Currency Code");
                "Sales Price".Insert(true);
              end;

              case SalesPriceMaintenanceSetup."Sales Type" of
                SalesPriceMaintenanceSetup."Sales Type"::"All Customers":
                  begin
                    if VATPostingSetup.Get(SalesPriceMaintenanceSetup."VAT Bus. Posting Gr. (Price)",Item."VAT Prod. Posting Group") then begin
                      //-NPR5.51 [358985]
                      POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup,Handled);
                      //+NPR5.51 [358985]
                      VATPct := VATPostingSetup."VAT %";
                      VATBusPostingGrp := VATPostingSetup."VAT Bus. Posting Group";
                    end;
                  end;
                SalesPriceMaintenanceSetup."Sales Type"::Campaign:
                  begin
                    //Do we need this??
                  end;
                SalesPriceMaintenanceSetup."Sales Type"::Customer:
                  begin
                    Customer.Get(SalesPriceMaintenanceSetup."Sales Code");
                    if Customer."VAT Bus. Posting Group" <> '' then
                      if VATPostingSetup.Get(Customer."VAT Bus. Posting Group",Item."VAT Prod. Posting Group") then begin
                        //-NPR5.51 [358985]
                        POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup,Handled);
                        //+NPR5.51 [358985]
                        VATPct := VATPostingSetup."VAT %";
                        VATBusPostingGrp := VATPostingSetup."VAT Bus. Posting Group";
                      end;
                  end;
                SalesPriceMaintenanceSetup."Sales Type"::"Customer Price Group":
                  begin
                    CustomerPriceGroup.Get(SalesPriceMaintenanceSetup."Sales Code");
                    if CustomerPriceGroup."Price Includes VAT" and (CustomerPriceGroup."VAT Bus. Posting Gr. (Price)" <> '') then
                      if VATPostingSetup.Get(CustomerPriceGroup."VAT Bus. Posting Gr. (Price)",Item."VAT Prod. Posting Group") then begin
                        //-NPR5.51 [358985]
                        POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup,Handled);
                        //+NPR5.51 [358985]
                        VATPct := VATPostingSetup."VAT %";
                        VATBusPostingGrp := VATPostingSetup."VAT Bus. Posting Group";
                      end;
                  end;
              end;

              if SalesPriceMaintenanceSetup.Factor = 0 then
                SalesPriceMaintenanceSetup.Factor := 1;

              if (SalesPriceMaintenanceSetup."Currency Code" <> '') and (SalesPriceMaintenanceSetup."Currency Code" <> GeneralLedgerSetup."LCY Code") then begin
                if Currency.Get(SalesPriceMaintenanceSetup."Currency Code") then begin
                  Currency.SetRecFilter();
                  CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ExchRateDate,Currency.Code);
                  PricesInCurrency := true;
                end else begin
                  CurrencyFactor := 1
                end;
              end else begin
                CurrencyFactor := 1
              end;

              case SalesPriceMaintenanceSetup."Internal Unit Price" of
                SalesPriceMaintenanceSetup."Internal Unit Price"::"Unit Cost" :
                  begin
                    if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                      UnitPrice := Item."Unit Cost" * SalesPriceMaintenanceSetup.Factor
                    else
                      UnitPrice := (Item."Unit Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                  end;
                SalesPriceMaintenanceSetup."Internal Unit Price"::"Last Direct Cost" :
                  begin
                    if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                      UnitPrice := Item."Last Direct Cost" * SalesPriceMaintenanceSetup.Factor
                    else
                      UnitPrice := (Item."Last Direct Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                  end;
                SalesPriceMaintenanceSetup."Internal Unit Price"::"Standard Cost" :
                  begin
                    if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                      UnitPrice := Item."Standard Cost" * SalesPriceMaintenanceSetup.Factor
                    else
                      UnitPrice := (Item."Standard Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                  end;
                SalesPriceMaintenanceSetup."Internal Unit Price"::"Unit Price" :
                  begin
                    if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                      UnitPrice := Item."Unit Price" * SalesPriceMaintenanceSetup.Factor
                    else
                      UnitPrice := (Item."Unit Price" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                  end;
              end;

              ConvertPriceLCYToFCY(PricesInCurrency,ExchRateDate,Currency,UnitPrice,CurrencyFactor);
              "Sales Price".Validate("Unit Price",UnitPrice);

              "Sales Price".Validate("Price Includes VAT",SalesPriceMaintenanceSetup."Prices Including VAT");
              "Sales Price".Validate("Allow Invoice Disc.",SalesPriceMaintenanceSetup."Allow Invoice Disc.");
              "Sales Price".Validate("Allow Line Disc.",SalesPriceMaintenanceSetup."Allow Line Disc.");
              "Sales Price".Validate("VAT Bus. Posting Gr. (Price)",VATBusPostingGrp);

              "Sales Price".Modify(true)
            //-NPR5.33
            end;
            //+NPR5.33
          until SalesPriceMaintenanceSetup.Next = 0;
        end;
        //+NPR5.38 [288383]
    end;

    local procedure ExcludeItemGroup(Current_ItemGroup: Code[10];ItemGroup_To_Exclude: Code[10]): Boolean
    var
        Item: Record Item;
        ItemGroup: Record "Item Group";
    begin
        //-NPR5.51
        ItemGroup.Get(ItemGroup_To_Exclude);
        ItemGroup.Get(Current_ItemGroup);

        if ItemGroup."Parent Item Group No." = '' then
          exit(false);

        if (ItemGroup."Parent Item Group No." = ItemGroup_To_Exclude) or (ItemGroup."Belongs In Main Item Group" = ItemGroup_To_Exclude) then
          exit(true);

        if ExcludeItemGroup(ItemGroup."Parent Item Group No.", ItemGroup_To_Exclude) then
          exit(true);
        //+NPR5.51
    end;
}


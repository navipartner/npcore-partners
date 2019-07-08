codeunit 6150706 "POS Sale Line"
{
    // NPR5.30/ANEN/20170307  CASE 268254 Adding call to item variant lookup page
    // NPR5.30/ANEN/20170308  CASE 268254 Setting dimensions and location from register on line Init
    // NPR5.32/ANEN/20170309  CASE 268251 In InsertLine adding copy for serial number
    // NPR5.32/ANEN/20170316  CASE 267346 Changning InsertDepositLine to be general and not only handle customer deposit
    // 
    // NPR5.32/ANEN/20170321  CASE 269583 Adding description to deposit line
    // NPR5.34/ANEN/20170719  CASE 270255 Addind discount fields to InsertLine
    // NPR5.36/TSA /20170901  CASE 288919 Added a set of "Line No" to 0, as a call to GetNewSaleLine would increase line no. twice for first line
    // NPR5.36/MHA /20170905  CASE 286812 Added Publisher functions OnAfterDeletePOSSaleLine() and OnAfterSetQuantity()
    // NPR5.37/MHA /20171011  CASE 293084 Added function GetNextLineNo()
    // NPR5.37/MHA /20171023  CASE 267346 G/L Quantity Validation should only be triggered for Old Gift Voucher/Credit Voucher Lines
    // NPR5.37/TSA /20171025  CASE 294454 Fixed sortorder in GetNextLineNo()
    // NPR5.38/ANEN/20171031  CASE 275242 Added function SetDescription
    // NPR5.38/MMV /20171120  CASE 296802 Added function DeleteAll
    // NPR5.38/MHA /20180105  CASE 301053 Renamed parameter DataSet to CurrDataSet in function ToDataSet() as the word is reserved in V2
    // NPR5.38/20180126  CASE 303067 Changed SaleLinePOS parameter to VAR in Publisher functions OnAfterInsertPOSSaleLine(),OnBeforeSetQuantity(),OnAfterSetQuantity()
    // NPR5.40/TSA /20180209 CASE 303065 Added AutoSplitKey functionality for insert new line
    // NPR5.40/MMV /20180219 CASE 294655 Optimized CalculateBalance for NST cache instead of SIFT index.
    //                                   Allow prefilled unit price.
    // NPR5.40/TSA /20180329 CASE 308522 Changed Variant Lookup page from standard to "NPR Item Variant"
    // NPR5.42/MHA /20180409 CASE 310148 Changed function OnAfterInsertPOSSaleLine() to public
    // NPR5.42/MMV /20180523 CASE 315838 Do not sort when calculating balance
    // NPR5.43/MHA /20180619 CASE 319425 Added OnBeforeInsertSaleLine- and OnAfterInsertSaleLine POS Workflow
    // NPR5.44/MHA /20180718 CASE 319425 Removed COMMIT from OnAfterInsertSaleLine POS Workflow
    // NPR5.44/MHA /20180724 CASE 300254 Changed function OnAfterSetQuantity() from Local to Global
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External
    // NPR5.45/MHA /20180807 CASE 323626 POS Discount Calculation is invoked explicitly
    // NPR5.45/MHA /20180817 CASE 324576 Silent should be reset after filling Variant Code in InsertLine()
    // NPR5.45/TSA /20180817 CASE 325341 ResendAllOnAfterInsertPOSSaleLine() functions sends the wrong record
    // NPR5.45/MHA /20180820 CASE 321266 Extended POS Sales Workflow with Set functionality
    // NPR5.46/MHA /20180928 CASE 329523 POSSale.RefreshCurrent() is now invoked after every transactional change
    // NPR5.48/MMV /20181108 CASE 300557 Unified line insertion methods and added InsertLineRaw() for easier correct custom line insertions.
    // NPR5.48/JDH /20181114 CASE 335967 Unit of Measure Code added
    // NPR5.48/TSA /20190204 CASE 344901 Added call to UpdateAmounts for deposit lines
    // NPR5.49/TJ  /20190201 CASE 335739 Using POS View Profile instead of Register
    // NPR5.50/MMV /20190403 CASE 300557 Added init handling and IsEmpty function
    // NPR5.50/TSA /20190424 CASE 342090 Readjustment of tax calculation when a line is deleted.
    // NPR5.50/TSA /20190507 CASE 345348 Made OnBeforeDeletePOSSaleLine, OnAfterDeletePOSSaleLine, OnBeforeSetQuantity public


    trigger OnRun()
    begin
    end;

    var
        Rec: Record "Sale Line POS";
        Sale: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        Setup: Codeunit "POS Setup";
        FrontEnd: Codeunit "POS Front End Management";
        QTY_CHANGE_NOT_ALLOWED: Label 'When type of sales is %1, quantity must be 1 or -1.';
        ITEM_REQUIRES_VARIANT: Label 'Variant is required for item %1.';
        TEXTDEPOSIT: Label 'Deposit';
        InsertLineWithAutoSplitKey: Boolean;
        AUTOSPLIT_ERROR: Label 'Autosplit key can''t insert the new line %1 as it already exists. Highlight a different line before selling next item.';
        Text000: Label 'Before Sale Line POS is inserted';
        Text001: Label 'After Sale Line POS is inserted';
        Initialized: Boolean;

    [Scope('Personalization')]
    procedure Init(RegisterNo: Code[20];SalesTicketNo: Code[20];SaleIn: Codeunit "POS Sale";SetupIn: Codeunit "POS Setup";FrontEndIn: Codeunit "POS Front End Management")
    var
        Register: Record Register;
        POSViewProfile: Record "POS View Profile";
    begin
        Clear(Rec);
        Clear(Sale);

        with Rec do begin
          FilterGroup(2);
          SetRange("Register No.",RegisterNo);
          SetRange("Sales Ticket No.",SalesTicketNo);
          SetFilter(Type,'<>%1',Type::Payment);
          FilterGroup(0);
        end;

        Sale.Get(RegisterNo,SalesTicketNo);

        POSSale := SaleIn;
        Setup := SetupIn;
        FrontEnd := FrontEndIn;

        if (Register.Get (RegisterNo)) then
          //-NPR5.49 [335739]
          //InsertLineWithAutoSplitKey := (Register."Line Order on Screen" = Register."Line Order on Screen"::AutoSplitKey);
          InsertLineWithAutoSplitKey := (POSViewProfile."Line Order on Screen" = POSViewProfile."Line Order on Screen"::AutoSplitKey);
          //+NPR5.49 [335739]

        //-NPR5.50 [300557]
        Initialized := true;
        //+NPR5.50 [300557]
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        //-NPR5.50 [300557]
        if WithError and (not Initialized) then
          Error('Codeunit POS Sale Line was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
        //+NPR5.50 [300557]
    end;

    local procedure InitLine()
    var
        Register: Record Register;
    begin
        with Rec do begin
          "Line No." := GetNextLineNo();

          Init;
          "Register No."     := Sale."Register No.";
          "Sales Ticket No." := Sale."Sales Ticket No.";
          Date               := Sale.Date;
          "Sale Type"        := "Sale Type"::Sale;
          Type               := Type::Item;

          if Register.Get (Setup.Register()) then begin
            "Location Code" := Register."Location Code";
            "Shortcut Dimension 1 Code" := Register."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := Register."Global Dimension 2 Code";
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure GetNextLineNo() NextLineNo: Integer
    var
        SaleLinePOS: Record "Sale Line POS";
    begin

        //-NPR5.40 [303065]
        if ((InsertLineWithAutoSplitKey) and (Rec."Line No." <> 0)) then begin
          SaleLinePOS.SetCurrentKey ("Register No.","Sales Ticket No.","Line No.");
          SaleLinePOS.SetFilter ("Register No.", '=%1', Sale."Register No.");
          SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', Sale."Sales Ticket No.");
          SaleLinePOS.SetFilter ("Line No.", '>%1', Rec."Line No.");
          if (SaleLinePOS.FindFirst ()) then begin
            NextLineNo := Round ((SaleLinePOS."Line No." - Rec."Line No.") / 2, 1) + Rec."Line No.";
            SaleLinePOS.SetFilter ("Line No.", '=%1', NextLineNo);
            if (SaleLinePOS.IsEmpty()) then
              exit (NextLineNo);

            Error (AUTOSPLIT_ERROR, NextLineNo);
          end;
          SaleLinePOS.Reset;
        end;
        //+NPR5.40 [303065]

        //-NPR5.37 [294454]
        SaleLinePOS.SetCurrentKey ("Register No.","Sales Ticket No.","Line No.");
        //+NPR5.37 [294454]

        //-NPR5.37 [293084]
        SaleLinePOS.SetRange("Register No.",Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
        //+NPR5.37 [293084]
    end;

    [Scope('Personalization')]
    procedure GetNewSaleLine(var SaleLinePOS: Record "Sale Line POS")
    begin
        InitLine();
        SaleLinePOS := Rec;
    end;

    [Scope('Personalization')]
    procedure RefreshCurrent(): Boolean
    begin
        exit (Rec.Find());
    end;

    [Scope('Personalization')]
    procedure SetFirst()
    begin
        Rec.FindFirst ();
    end;

    [Scope('Personalization')]
    procedure SetLast()
    begin
        Rec.FindLast ();
    end;

    [Scope('Personalization')]
    procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find);
    end;

    [Scope('Personalization')]
    procedure GetCurrentSaleLine(var SaleLinePOS: Record "Sale Line POS")
    begin
        RefreshCurrent();
        SaleLinePOS.Copy (Rec);
    end;

    [Scope('Personalization')]
    procedure InsertLine(var Line: Record "Sale Line POS") Return: Boolean
    var
        Contact: Record Contact;
        Linie: Record "Sale Line POS";
        "Linie 2": Record "Sale Line POS";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
        LinieInteger: Integer;
        Mikspris: Record "Mixed Discount Line";
        cust: Record Customer;
        t001: Label 'Customer club member does not exist';
        GL: Record "G/L Account";
        t002: Label 'G/L Account\ "%1 - %2"\ is not prepared for outpayment on register';
        tmpStr: Text[250];
        ItemVariant: Record "Item Variant";
        PrefilledUnitPrice: Decimal;
    begin
        with Rec do begin
          InitLine();

          // TODO: copy information from Line to Rec
          Type := Line.Type;
          "Sale Type" := Line."Sale Type";

          Silent := (Line."Variant Code" <> '');

          //-NPR5.30 [268254]
          if ( (Line.Type = Line.Type::Item) and (not Silent) and (ItemVariantIsRequired(Line."No.")) ) then begin
            FillVariantThroughLookUp(Line."No.", Line."Variant Code");
            if Line."Variant Code" = '' then
              Error(ITEM_REQUIRES_VARIANT, Line."No.");
            Silent := (Line."Variant Code" <> '');
          end;
          //+NPR5.30 [268254]

          "Variant Code" := Line."Variant Code";
          Validate("No.",Line."No.");
          //-NPR5.48 [335967]
          if Line."Unit of Measure Code" <> '' then
            Validate("Unit of Measure Code", Line."Unit of Measure Code");
          //+NPR5.48 [335967]

          //-NPR5.45 [324576]
          Silent := false;
          //+NPR5.45 [324576]

          if Line.Description <> '' then
            Description := Line.Description;

          Validate(Quantity,Line.Quantity);

          "Customer No. Line" := Line."Customer No. Line";

          if ("Sale Type" = "Sale Type"::"Out payment") then begin
            "Unit Price" := Line."Unit Price";
            Amount := Line.Amount;
            "Amount Including VAT" := Line."Amount Including VAT";
           end;


          //-NPR5.32 [268251]
          if Line."Serial No." <> '' then begin //Because existing validation code cant handle blank serial number
          Validate("Serial No.", Line."Serial No.");
          end else begin
            "Serial No." := Line."Serial No.";
          end;
          Validate("Serial No. not Created", Line."Serial No. not Created");
          //+NPR5.32 [268251]

          //-NPR5.34 [270255]
          Validate("Discount Type", Line."Discount Type");
          Validate("Discount Code", Line."Discount Code");

          Validate("Allow Line Discount", Line."Allow Line Discount");
          if Line."Discount %" > 0 then
            Validate("Discount %", Line."Discount %");

          Validate("Allow Invoice Discount",Line."Allow Invoice Discount");
          Validate("Invoice Discount Amount", Line."Invoice Discount Amount");
          //-NPR5.40 [294655]
          if Line."Unit Price" <> 0 then
            Validate("Unit Price", Line."Unit Price");
          //+NPR5.40 [294655]
          //+NPR5.34 [270255]

        //-NPR5.48 [300557]
        //  InvokeOnBeforeInsertSaleLineWorkflow(Rec);
        //  Return := INSERT(TRUE);
        //  POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOS(Rec);
        //  InvokeOnAfterInsertSaleLineWorkflow(Rec);
        //  Line := Rec;
        // END;
        //
        // POSSale.RefreshCurrent();
        end;

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
        //+NPR5.48 [300557]
    end;

    [Scope('Personalization')]
    procedure DeleteLine()
    var
        xRec: Record "Sale Line POS";
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
        RecalcSaleLinePOS: Record "Sale Line POS";
    begin

        if (not RefreshCurrent ()) then
          exit;

        OnBeforeDeletePOSSaleLine (Rec);
        xRec := Rec;
        with Rec do begin
          Delete(true);

          //-NPR5.45 [323626]
          POSSalesDiscountCalcMgt.OnAfterDeleteSaleLinePOS(xRec);
          //+NPR5.45 [323626]

          //-NPR5.50 [342090]
          // IF NOT FIND('><') THEN;
          if (Find('><')) then begin
            UpdateAmounts (Rec);
            Modify ();
          end;
          //+NPR5.50 [342090]

        end;
        OnAfterDeletePOSSaleLine(xRec);

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

    [Scope('Personalization')]
    procedure DeleteAll()
    var
        xRec: Record "Sale Line POS";
    begin

        //-NPR5.38 [296802]
        //-NPR5.42 [315838]
        //IF Rec.FINDSET THEN REPEAT
        if Rec.FindSet(true) then repeat
        //+NPR5.42 [315838]
          OnBeforeDeletePOSSaleLine(Rec);
          xRec := Rec;
          Rec.Delete(true);
          OnAfterDeletePOSSaleLine(xRec);
        until Rec.Next = 0;
        //+NPR5.38 [296802]

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

    [Scope('Personalization')]
    procedure IsEmpty(): Boolean
    begin
        //-NPR5.50 [300557]
        CheckInit(true);
        exit(Rec.IsEmpty);
        //+NPR5.50 [300557]
    end;

    [Scope('Personalization')]
    procedure SetQuantity(Quantity: Decimal)
    var
        xRec: Record "Sale Line POS";
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
    begin

        RefreshCurrent ();
        OnBeforeSetQuantity (Rec, Quantity);

        //-NPR5.37 [267346]
        //IF ((Rec.Type = Rec.Type::"G/L Entry") AND (ABS (Quantity) <> 1)) THEN
        if ((Rec.Type = Rec.Type::"G/L Entry") and (Abs (Quantity) <> 1)) and (Rec."Gift Voucher Ref." + Rec."Credit voucher ref." <> '') then
          Error (QTY_CHANGE_NOT_ALLOWED, Rec.Type);
        //+NPR5.37 [267346]

        //-NPR5.45 [323626]
        xRec := Rec;
        //+NPR5.45 [323626]
        Rec.Validate(Quantity,Quantity);
        Rec.Modify(true);
        //-NPR5.45 [323626]
        POSSalesDiscountCalcMgt.OnAfterModifySaleLinePOS(Rec,xRec);
        //+NPR5.45 [323626]
        //-NPR5.36 [286812]
        OnAfterSetQuantity(Rec);
        //+NPR5.36 [286812]

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

    [Scope('Personalization')]
    procedure SetUnitPrice(UnitPriceLCY: Decimal)
    begin

        RefreshCurrent ();

        Rec.Validate ("Unit Price", UnitPriceLCY);

        if (Rec.Type = Rec.Type::Item) then
          Rec."Initial Group Sale Price" := UnitPriceLCY;

        Rec.Modify(true);

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

    [Scope('Personalization')]
    procedure SetDescription(NewDescription: Text)
    begin
        //-NPR5.38 [275242]
        RefreshCurrent ();

        if NewDescription <> '' then
            Rec.Description := CopyStr(NewDescription, 1, MaxStrLen(Rec.Description));

        Rec.Modify(true);

        //+NPR5.38 [275242]

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

    [Scope('Personalization')]
    procedure CalculateBalance(var AmountExclVAT: Decimal;var VATAmount: Decimal;var TotalAmount: Decimal)
    var
        SaleLine: Record "Sale Line POS";
        RetailFormCode: Codeunit "Retail Form Code";
        OutPaymentAmount: Decimal;
    begin
        AmountExclVAT := 0;
        VATAmount := 0;
        TotalAmount := 0;

        with Rec do begin
          if ("Register No." <> '') and ("Sales Ticket No." <> '') then begin
        //-NPR5.42 [315838]
        //    SaleLine.SETCURRENTKEY("Register No.","Sales Ticket No.","Line No.");
        //+NPR5.42 [315838]
            SaleLine.SetRange("Register No.", "Register No.");
            SaleLine.SetRange("Sales Ticket No.", "Sales Ticket No.");
            if SaleLine.FindSet then begin
              repeat
                if SaleLine."Sale Type" in [SaleLine."Sale Type"::Sale, SaleLine."Sale Type"::Deposit] then begin
                  AmountExclVAT += SaleLine.Amount;
                  TotalAmount += SaleLine."Amount Including VAT";
                end else if SaleLine."Sale Type" = SaleLine."Sale Type"::"Out payment" then
                  if SaleLine."Discount Type" <> SaleLine."Discount Type"::Rounding then
                    OutPaymentAmount += SaleLine."Amount Including VAT";
              until SaleLine.Next = 0;
              VATAmount := TotalAmount - AmountExclVAT;
              TotalAmount -= OutPaymentAmount;
            end;
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure ToDataset(var CurrDataSet: DotNet DataSet;DataSource: DotNet DataSource0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        DataMgt: Codeunit "POS Data Management";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
    begin
        //-NPR5.38 [301053]
        // DataMgt.RecordToDataSet(Rec,DataSet,DataSource,POSSession,FrontEnd);
        //
        // CalculateBalance(AmountExclVAT,VATAmount,TotalAmount);
        // DataSet.Totals.Add('AmountExclVAT',AmountExclVAT);
        // DataSet.Totals.Add('VATAmount',VATAmount);
        // DataSet.Totals.Add('TotalAmount',TotalAmount);
        DataMgt.RecordToDataSet(Rec,CurrDataSet,DataSource,POSSession,FrontEnd);

        CalculateBalance(AmountExclVAT,VATAmount,TotalAmount);
        CurrDataSet.Totals.Add('AmountExclVAT',AmountExclVAT);
        CurrDataSet.Totals.Add('VATAmount',VATAmount);
        CurrDataSet.Totals.Add('TotalAmount',TotalAmount);
        //+NPR5.38 [301053]
    end;

    [Scope('Personalization')]
    procedure GetDepositLine(var LinePOS: Record "Sale Line POS")
    begin
        SetDepositLineType (LinePOS);
    end;

    local procedure SetDepositLineType(var LinePOS: Record "Sale Line POS")
    begin
        with LinePOS do begin
          "Register No." := Sale."Register No.";
          "Sales Ticket No." := Sale."Sales Ticket No.";
          Date := Sale.Date;
          "Sale Type" := "Sale Type"::Deposit;
          Quantity := 1;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertDepositLine(var Line: Record "Sale Line POS";ForeignCurrencyAmount: Decimal) Return: Boolean
    begin
        with Rec do begin
          InitLine ();

          SetDepositLineType (Rec);

          Rec.Type := Line.Type;
          Rec."No." := Line."No.";
          Rec.Description := Line.Description;
          Rec.Quantity := Line.Quantity;
          Rec.Amount := Line.Amount;
          Rec."Unit Price" := Line."Unit Price";
          Rec."Amount Including VAT" := Line."Amount Including VAT";

          //-NPR5.48 [344901]
          Rec.UpdateAmounts (Rec);
          //+NPR5.48 [344901]

          if Rec.Description = '' then
            Rec.Description := TEXTDEPOSIT;

        //-NPR5.48 [300557]
        //  InvokeOnBeforeInsertSaleLineWorkflow(Rec);
        //  Return := INSERT (TRUE);
        //  InvokeOnAfterInsertSaleLineWorkflow(Rec);
        // END;
        //
        // GetCurrentSaleLine (Line);
        // POSSale.RefreshCurrent();
        end;

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
        //+NPR5.48 [300557]
    end;

    [Scope('Personalization')]
    procedure ResendAllOnAfterInsertPOSSaleLine()
    var
        SaleLinePOS: Record "Sale Line POS";
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
    begin

        SaleLinePOS.CopyFilters (Rec);
        if (SaleLinePOS.FindSet ()) then
          repeat
            InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);
          until (SaleLinePOS.Next()=0);

        //-NPR5.48 [300557]
        POSSalesDiscountCalcMgt.RecalculateAllSaleLinePOS(Sale);
        //+NPR5.48 [300557]

        POSSale.RefreshCurrent();
    end;

    local procedure FillVariantThroughLookUp(ItemNo: Code[20];var VariantCode: Code[10])
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemVariants: Page "NPR Item Variants";
        Register: Record Register;
    begin
        //NPR5.30 [268254]
        if ItemNo = '' then exit;
        if not Item.Get(ItemNo) then exit;

        ItemVariant.SetFilter(ItemVariant."Item No.", Item."No.");
        ItemVariant.SetFilter(ItemVariant.Blocked, '=%1', false);
        if ItemVariant.IsEmpty then exit;

        //-NPR5.40 [308522]
        if (Register.Get (Sale."Register No.")) then
          ItemVariants.SetLocationCodeFilter (Register."Location Code");
        //+NPR5.40 [308522]

        ItemVariants.Editable(false);
        ItemVariants.LookupMode(true);
        ItemVariants.SetTableView(ItemVariant);
        if ItemVariants.RunModal = ACTION::LookupOK then begin
          ItemVariants.GetRecord(ItemVariant);
          VariantCode := ItemVariant.Code;
        end else begin
          VariantCode := '';
        end;
    end;

    local procedure ItemVariantIsRequired(var ItemNo: Code[20]) IsRequired: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        //NPR5.30 [268254]
        if ItemNo = '' then exit;
        if not Item.Get(ItemNo) then exit;

        ItemVariant.SetFilter(ItemVariant."Item No.", Item."No.");
        ItemVariant.SetFilter(ItemVariant.Blocked, '=%1', false);

        IsRequired := not ItemVariant.IsEmpty;
    end;

    procedure InsertLineRaw(var Line: Record "Sale Line POS";HandleReturnValue: Boolean): Boolean
    begin
        //-NPR5.48 [300557]
        // Note: if you are bulk inserting, you'll improve performance by using ResendAllOnAfterInsertPOSSaleLine() at the end instead of calling this function inside a loop.

        // Best practice usage:
        // Use GetNewSaleLine() to get a clean line with pre-filled primary key.
        // fill it with information.
        // Call this function with it.

        Line.TestField("Register No.", Sale."Register No.");
        Line.TestField("Sales Ticket No.", Sale."Sales Ticket No.");
        Line.TestField(Date, Sale.Date);

        exit(InsertLineInternal(Line, HandleReturnValue));
        //+NPR5.48 [300557]
    end;

    local procedure InsertLineInternal(var Line: Record "Sale Line POS";HandleReturnValue: Boolean) ReturnValue: Boolean
    var
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
    begin
        //-NPR5.48 [300557]
        Rec := Line;

        InvokeOnBeforeInsertSaleLineWorkflow(Rec);

        if HandleReturnValue then
          ReturnValue := Rec.Insert(true)
        else begin
          Rec.Insert(true);
          ReturnValue := true;
        end;

        POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOS(Rec);
        InvokeOnAfterInsertSaleLineWorkflow(Rec);
        POSSale.RefreshCurrent();

        Line := Rec;
        //+NPR5.48 [300557]
    end;

    local procedure "--Publishers"()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnAfterDeletePOSSaleLine(SaleLinePOS: Record "Sale Line POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.36 [286812]
        //+NPR5.36 [286812]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnAfterSetQuantity(var SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.36 [286812]
        //+NPR5.36 [286812]
        //-NPR5.38 [303067]
        //+NPR5.38 [303067]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeSetQuantity(var SaleLinePOS: Record "Sale Line POS";var NewQuantity: Decimal)
    begin
        //-NPR5.38 [303067]
        //+NPR5.38 [303067]
    end;

    local procedure "--- POS Sales Workflow"()
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;

    local procedure OnBeforeInsertSaleLineCode(): Code[20]
    begin
        //-NPR5.43 [319425]
        exit('BEFORE_INSERT_LINE');
        //+NPR5.43 [319425]
    end;

    local procedure OnAfterInsertSaleLineCode(): Code[20]
    begin
        //-NPR5.43 [319425]
        exit('AFTER_INSERT_LINE');
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "POS Sales Workflow")
    begin
        //-NPR5.43 [319425]
        Sender.DiscoverPOSSalesWorkflow(OnBeforeInsertSaleLineCode(),Text000,CurrCodeunitId(),'OnBeforeInsertSaleLine');
        Sender.DiscoverPOSSalesWorkflow(OnAfterInsertSaleLineCode(),Text001,CurrCodeunitId(),'OnAfterInsertSaleLine');
        //+NPR5.43 [319425]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.43 [319425]
        exit(CODEUNIT::"POS Sale Line");
        //+NPR5.43 [319425]
    end;

    [Scope('Personalization')]
    procedure InvokeOnBeforeInsertSaleLineWorkflow(var SaleLinePOS: Record "Sale Line POS")
    var
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.43 [319425]
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        //-NPR5.45 [321266]
        POSSalesWorkflowStep.SetFilter("Set Code",'=%1','');
        if POSUnit.Get(SaleLinePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set",OnBeforeInsertSaleLineCode()) then
          POSSalesWorkflowStep.SetRange("Set Code",POSSalesWorkflowSetEntry."Set Code");
        //+NPR5.45 [321266]
        POSSalesWorkflowStep.SetRange("Workflow Code",OnBeforeInsertSaleLineCode());
        POSSalesWorkflowStep.SetRange(Enabled,true);
        if not POSSalesWorkflowStep.FindSet then
          exit;

        repeat
          OnBeforeInsertSaleLine(POSSalesWorkflowStep,SaleLinePOS);
        until POSSalesWorkflowStep.Next = 0;
        //+NPR5.43 [319425]
    end;

    [Scope('Personalization')]
    procedure InvokeOnAfterInsertSaleLineWorkflow(var SaleLinePOS: Record "Sale Line POS")
    var
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.43 [319425]
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        //-NPR5.45 [321266]
        POSSalesWorkflowStep.SetFilter("Set Code",'=%1','');
        if POSUnit.Get(SaleLinePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set",OnAfterInsertSaleLineCode()) then
          POSSalesWorkflowStep.SetRange("Set Code",POSSalesWorkflowSetEntry."Set Code");
        //+NPR5.45 [321266]
        POSSalesWorkflowStep.SetRange("Workflow Code",OnAfterInsertSaleLineCode());
        POSSalesWorkflowStep.SetRange(Enabled,true);
        if not POSSalesWorkflowStep.FindSet then
          exit;

        repeat
          //-NPR5.44 [319425]
          //ASSERTERROR BEGIN
          //  OnAfterInsertSaleLine(POSSalesWorkflowStep,SaleLinePOS);
          //  COMMIT;
          //  ERROR('');
          //END;
          OnAfterInsertSaleLine(POSSalesWorkflowStep,SaleLinePOS);
          //+NPR5.44 [319425]
        until POSSalesWorkflowStep.Next = 0;
        //+NPR5.43 [319425]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSaleLine(POSSalesWorkflowStep: Record "POS Sales Workflow Step";var SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSaleLine(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;
}


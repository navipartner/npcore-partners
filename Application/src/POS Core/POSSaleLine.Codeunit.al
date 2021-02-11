codeunit 6150706 "NPR POS Sale Line"
{
    trigger OnRun()
    begin
    end;

    var
        Rec: Record "NPR Sale Line POS";
        xRec: Record "NPR Sale Line POS";
        Sale: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        QTY_CHANGE_NOT_ALLOWED: Label 'When type of sales is %1, quantity must be 1 or -1.';
        ITEM_REQUIRES_VARIANT: Label 'Variant is required for item %1.';
        TEXTDEPOSIT: Label 'Deposit';
        InsertLineWithAutoSplitKey: Boolean;
        AUTOSPLIT_ERROR: Label 'Autosplit key can''t insert the new line %1 as it already exists. Highlight a different line before selling next item.';
        Text000: Label 'Before Sale Line POS is inserted';
        Text001: Label 'After Sale Line POS is inserted';
        Initialized: Boolean;
        CannotCalcPriceInclVATErr: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        ItemCountWhenCalculatedBalance: Decimal;
        UseLinePriceVATParams: Boolean;
        InsertWithAutoSplitKeyForced: Boolean;
        IsAutoSplitKeyRecord: Boolean;
        UsePresetLineNo: Boolean;

    procedure Init(RegisterNo: Code[20]; SalesTicketNo: Code[20]; SaleIn: Codeunit "NPR POS Sale"; SetupIn: Codeunit "NPR POS Setup"; FrontEndIn: Codeunit "NPR POS Front End Management")
    var
        POSViewProfile: Record "NPR POS View Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        Clear(Rec);
        Clear(Sale);

        with Rec do begin
            FilterGroup(2);
            SetRange("Register No.", RegisterNo);
            SetRange("Sales Ticket No.", SalesTicketNo);
            SetFilter(Type, '<>%1', Type::Payment);
            FilterGroup(0);
        end;

        Sale.Get(RegisterNo, SalesTicketNo);

        POSSale := SaleIn;
        Setup := SetupIn;
        FrontEnd := FrontEndIn;

        Setup.GetPOSViewProfile(POSViewProfile);
        InsertLineWithAutoSplitKey := (POSViewProfile."Line Order on Screen" = POSViewProfile."Line Order on Screen"::AutoSplitKey);

        Initialized := true;
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        if WithError and (not Initialized) then
            Error('Codeunit POS Sale Line was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
    end;

    local procedure InitLine()
    var
        Register: Record "NPR Register";
        POSStore: Record "NPR POS Store";
    begin
        if not (UsePresetLineNo and (Rec."Line No." <> 0)) then
            Rec."Line No." := GetNextLineNo();

        Rec.Init();
        Rec."Register No." := Sale."Register No.";
        Rec."Sales Ticket No." := Sale."Sales Ticket No.";
        Rec.Date := Sale.Date;
        Rec."Sale Type" := Rec."Sale Type"::Sale;
        Rec.Type := Rec.Type::Item;

        Setup.GetPOSStore(POSStore);
        Rec."Location Code" := POSStore."Location Code";
    end;

    procedure GetNextLineNo() NextLineNo: Integer
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        IsAutoSplitKeyRecord := false;
        if (InsertLineWithAutoSplitKey or InsertWithAutoSplitKeyForced) and (Rec."Line No." <> 0) then begin
            SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
            SaleLinePOS.SetFilter("Register No.", '=%1', Sale."Register No.");
            SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', Sale."Sales Ticket No.");
            SaleLinePOS.SetFilter("Line No.", '>%1', Rec."Line No.");
            if (SaleLinePOS.FindFirst()) then begin
                NextLineNo := Round((SaleLinePOS."Line No." - Rec."Line No.") / 2, 1) + Rec."Line No.";
                SaleLinePOS.SetFilter("Line No.", '=%1', NextLineNo);
                IsAutoSplitKeyRecord := SaleLinePOS.IsEmpty();
                if IsAutoSplitKeyRecord then
                    exit(NextLineNo);

                Error(AUTOSPLIT_ERROR, NextLineNo);
            end;
            SaleLinePOS.Reset;
        end;

        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
    end;

    procedure GetNewSaleLine(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        InitLine();
        SaleLinePOS := Rec;
    end;

    procedure RefreshCurrent(): Boolean
    begin
        exit(Rec.Find());
    end;

    procedure SetFirst()
    begin
        Rec.FindFirst();
    end;

    procedure SetLast()
    begin
        Rec.FindLast();
    end;

    procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find);
    end;

    procedure GetCurrentSaleLine(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        RefreshCurrent();
        SaleLinePOS.Copy(Rec);
    end;

    procedure InsertLine(var Line: Record "NPR Sale Line POS") Return: Boolean
    var
        Contact: Record Contact;
        Linie: Record "NPR Sale Line POS";
        "Linie 2": Record "NPR Sale Line POS";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LinieInteger: Integer;
        Mikspris: Record "NPR Mixed Discount Line";
        cust: Record Customer;
        t001: Label 'Customer club member does not exist';
        GL: Record "G/L Account";
        t002: Label 'G/L Account\ "%1 - %2"\ is not prepared for outpayment on register';
        tmpStr: Text[250];
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        PrefilledUnitPrice: Decimal;
    begin
        with Rec do begin
            if UsePresetLineNo then
                "Line No." := Line."Line No.";

            InitLine();

            // TODO: copy information from Line to Rec
            Type := Line.Type;
            "Sale Type" := Line."Sale Type";

            Silent := (Line."Variant Code" <> '');

            if ((Line.Type = Line.Type::Item) and (not Silent) and (ItemVariantIsRequired(Line."No."))) then begin
                FillVariantThroughLookUp(Line."No.", Line."Variant Code");
                if Line."Variant Code" = '' then
                    Error(ITEM_REQUIRES_VARIANT, Line."No.");
                Silent := (Line."Variant Code" <> '');
            end;

            "Variant Code" := Line."Variant Code";
            Validate("No.", Line."No.");
            if Line."Unit of Measure Code" <> '' then
                Validate("Unit of Measure Code", Line."Unit of Measure Code");

            Silent := false;

            if Line.Description <> '' then
                Description := Line.Description;

            Validate(Quantity, Line.Quantity);

            "Customer No. Line" := Line."Customer No. Line";
            Validate("NPRE Seating Code", Line."NPRE Seating Code");

            if ("Sale Type" = "Sale Type"::"Out payment") then begin
                "Unit Price" := Line."Unit Price";
                Amount := Line.Amount;
                "Amount Including VAT" := Line."Amount Including VAT";
            end;

            if Line."Serial No." <> '' then begin //Because existing validation code cant handle blank serial number
                Validate("Serial No.", Line."Serial No.");
            end else begin
                "Serial No." := Line."Serial No.";
            end;
            Validate("Serial No. not Created", Line."Serial No. not Created");

            Validate("Discount Type", Line."Discount Type");
            Validate("Discount Code", Line."Discount Code");

            Validate("Allow Line Discount", Line."Allow Line Discount");
            if Line."Discount %" > 0 then
                Validate("Discount %", Line."Discount %");

            Validate("Allow Invoice Discount", Line."Allow Invoice Discount");
            Validate("Invoice Discount Amount", Line."Invoice Discount Amount");

            if (Line."Unit Price" <> 0) and UseLinePriceVATParams then
                ConvertPriceToVAT(Line."Price Includes VAT", Line."VAT Bus. Posting Group", Line."VAT Prod. Posting Group", Rec, Line."Unit Price")
            else
                if (Type = Type::Item) and ("No." <> '') and (Line."Unit Price" <> 0) then begin
                    Item.Get("No.");
                    if Item."Price Includes VAT" then begin
                        Item.TestField("VAT Bus. Posting Gr. (Price)");
                        Item.TestField("VAT Prod. Posting Group");
                    end;
                    ConvertPriceToVAT(Item."Price Includes VAT", Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group", Rec, Line."Unit Price");
                end;
            if (Line."Unit Price" <> 0) or Line."Manual Item Sales Price" then
                Validate("Unit Price", Line."Unit Price");
        end;

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
    end;

    procedure DeleteLine()
    var
        xRec: Record "NPR Sale Line POS";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        RecalcSaleLinePOS: Record "NPR Sale Line POS";
    begin
        if (not RefreshCurrent()) then
            exit;

        OnBeforeDeletePOSSaleLine(Rec);
        xRec := Rec;
        with Rec do begin
            Delete(true);

            POSSalesDiscountCalcMgt.OnAfterDeleteSaleLinePOS(xRec);

            if (Find('><')) then begin
                UpdateAmounts(Rec);
                Modify();
            end;
        end;
        OnAfterDeletePOSSaleLine(xRec);

        POSSale.RefreshCurrent();
    end;

    procedure DeleteAll()
    var
        xRec: Record "NPR Sale Line POS";
    begin
        if Rec.FindSet(true) then
            repeat
                OnBeforeDeletePOSSaleLine(Rec);
                xRec := Rec;
                Rec.Delete(true);
                OnAfterDeletePOSSaleLine(xRec);
            until Rec.Next = 0;

        POSSale.RefreshCurrent();
    end;

    procedure UpdateLine()
    begin
        OnUpdateLine(Rec);
    end;

    procedure IsEmpty(): Boolean
    begin
        CheckInit(true);
        exit(Rec.IsEmpty);
    end;

    procedure SetQuantity(Quantity: Decimal)
    var
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        RefreshCurrent();
        OnBeforeSetQuantity(Rec, Quantity);

        xRec := Rec;
        Rec.Validate(Quantity, Quantity);
        Rec.Modify(true);
        POSSalesDiscountCalcMgt.OnAfterModifySaleLinePOS(Rec, xRec);
        OnAfterSetQuantity(Rec);

        POSSale.RefreshCurrent();
    end;

    procedure SetUnitPrice(UnitPriceLCY: Decimal)
    begin
        RefreshCurrent();

        Rec.Validate("Unit Price", UnitPriceLCY);

        if (Rec.Type = Rec.Type::Item) then
            Rec."Initial Group Sale Price" := UnitPriceLCY;

        Rec.Modify(true);
        POSSale.RefreshCurrent();
    end;

    procedure SetDescription(NewDescription: Text)
    begin
        RefreshCurrent();

        if NewDescription <> '' then
            Rec.Description := CopyStr(NewDescription, 1, MaxStrLen(Rec.Description));

        Rec.Modify(true);
        POSSale.RefreshCurrent();
    end;

    procedure CalculateBalance(var AmountExclVAT: Decimal; var VATAmount: Decimal; var TotalAmount: Decimal)
    var
        SaleLine: Record "NPR Sale Line POS";
        OutPaymentAmount: Decimal;
    begin
        AmountExclVAT := 0;
        VATAmount := 0;
        TotalAmount := 0;

        ItemCountWhenCalculatedBalance := 0;

        with Rec do begin
            if ("Register No." <> '') and ("Sales Ticket No." <> '') then begin
                SaleLine.SetRange("Register No.", "Register No.");
                SaleLine.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLine.SetFilter(Type, '<>%1', Type::Comment);
                if SaleLine.FindSet then begin
                    repeat
                        ItemCountWhenCalculatedBalance += SaleLine.Quantity;
                        if SaleLine."Sale Type" in [SaleLine."Sale Type"::Sale, SaleLine."Sale Type"::Deposit] then begin
                            AmountExclVAT += SaleLine.Amount;
                            TotalAmount += SaleLine."Amount Including VAT";
                        end else
                            if SaleLine."Sale Type" = SaleLine."Sale Type"::"Out payment" then
                                if SaleLine."Discount Type" <> SaleLine."Discount Type"::Rounding then begin
                                    OutPaymentAmount += SaleLine."Amount Including VAT";
                                end;
                    until SaleLine.Next = 0;
                    VATAmount := TotalAmount - AmountExclVAT;
                    TotalAmount -= OutPaymentAmount;
                end;
            end;
        end;
    end;

    procedure ToDataset(var CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
    begin
        DataMgt.RecordToDataSet(Rec, CurrDataSet, DataSource, POSSession, FrontEnd);
        CalculateBalance(AmountExclVAT, VATAmount, TotalAmount);
        CurrDataSet.Totals.Add('AmountExclVAT', AmountExclVAT);
        CurrDataSet.Totals.Add('VATAmount', VATAmount);
        CurrDataSet.Totals.Add('TotalAmount', TotalAmount);
        CurrDataSet.Totals.Add('ItemCount', ItemCountWhenCalculatedBalance);
    end;

    procedure GetDepositLine(var LinePOS: Record "NPR Sale Line POS")
    begin
        SetDepositLineType(LinePOS);
    end;

    local procedure SetDepositLineType(var LinePOS: Record "NPR Sale Line POS")
    begin
        with LinePOS do begin
            "Register No." := Sale."Register No.";
            "Sales Ticket No." := Sale."Sales Ticket No.";
            Date := Sale.Date;
            "Sale Type" := "Sale Type"::Deposit;
            Quantity := 1;
        end;
    end;

    procedure InsertDepositLine(var Line: Record "NPR Sale Line POS"; ForeignCurrencyAmount: Decimal) Return: Boolean
    begin
        with Rec do begin
            InitLine();

            SetDepositLineType(Rec);

            Rec.Type := Line.Type;
            Rec."No." := Line."No.";
            Rec.Description := Line.Description;
            Rec.Quantity := Line.Quantity;
            Rec.Amount := Line.Amount;
            Rec."Unit Price" := Line."Unit Price";
            Rec."Amount Including VAT" := Line."Amount Including VAT";
            Rec.UpdateAmounts(Rec);

            if Rec.Description = '' then
                Rec.Description := TEXTDEPOSIT;
        end;

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
    end;

    procedure ResendAllOnAfterInsertPOSSaleLine()
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        SaleLinePOS.CopyFilters(Rec);
        if (SaleLinePOS.FindSet()) then
            repeat
                InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);
            until (SaleLinePOS.Next() = 0);

        POSSalesDiscountCalcMgt.RecalculateAllSaleLinePOS(Sale);

        POSSale.RefreshCurrent();
    end;

    local procedure FillVariantThroughLookUp(ItemNo: Code[20]; var VariantCode: Code[10])
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemVariants: Page "NPR Item Variants";
        POSStore: Record "NPR POS Store";
    begin
        if ItemNo = '' then exit;
        if not Item.Get(ItemNo) then exit;

        ItemVariant.SetFilter(ItemVariant."Item No.", Item."No.");
        ItemVariant.SetFilter(ItemVariant."NPR Blocked", '=%1', false);
        if ItemVariant.IsEmpty() then exit;

        if POSStore.Get(Sale."POS Store Code") then
            ItemVariants.SetLocationCodeFilter(POSStore."Location Code");

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
        if ItemNo = '' then exit;
        if not Item.Get(ItemNo) then exit;

        ItemVariant.SetFilter(ItemVariant."Item No.", Item."No.");
        ItemVariant.SetFilter(ItemVariant."NPR Blocked", '=%1', false);

        IsRequired := not ItemVariant.IsEmpty;
    end;

    procedure InsertLineRaw(var Line: Record "NPR Sale Line POS"; HandleReturnValue: Boolean): Boolean
    begin
        Line.TestField("Register No.", Sale."Register No.");
        Line.TestField("Sales Ticket No.", Sale."Sales Ticket No.");
        Line.TestField(Date, Sale.Date);

        exit(InsertLineInternal(Line, HandleReturnValue));
    end;

    local procedure InsertLineInternal(var Line: Record "NPR Sale Line POS"; HandleReturnValue: Boolean) ReturnValue: Boolean
    var
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
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
    end;

    //--- Publishers ---

    [IntegrationEvent(TRUE, false)]
    procedure OnAfterDeletePOSSaleLine(SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnUpdateLine(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnAfterSetQuantity(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeSetQuantity(var SaleLinePOS: Record "NPR Sale Line POS"; var NewQuantity: Decimal)
    begin
    end;

    //--- POS Sales Workflow ---

    local procedure OnBeforeInsertSaleLineCode(): Code[20]
    begin
        exit('BEFORE_INSERT_LINE');
    end;

    local procedure OnAfterInsertSaleLineCode(): Code[20]
    begin
        exit('AFTER_INSERT_LINE');
    end;

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnBeforeInsertSaleLineCode(), Text000, CurrCodeunitId(), 'OnBeforeInsertSaleLine');
        Sender.DiscoverPOSSalesWorkflow(OnAfterInsertSaleLineCode(), Text001, CurrCodeunitId(), 'OnAfterInsertSaleLine');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sale Line");
    end;

    procedure InvokeOnBeforeInsertSaleLineWorkflow(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        if POSUnit.Get(SaleLinePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnBeforeInsertSaleLineCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnBeforeInsertSaleLineCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet then
            exit;

        repeat
            OnBeforeInsertSaleLine(POSSalesWorkflowStep, SaleLinePOS);
        until POSSalesWorkflowStep.Next = 0;
    end;

    procedure InvokeOnAfterInsertSaleLineWorkflow(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        if POSUnit.Get(SaleLinePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnAfterInsertSaleLineCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnAfterInsertSaleLineCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet then
            exit;

        repeat
            OnAfterInsertSaleLine(POSSalesWorkflowStep, SaleLinePOS);
        until POSSalesWorkflowStep.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATBusPostingGr: Code[10]; FromVATProdPostingGr: Code[10]; SaleLinePOS: Record "NPR Sale Line POS"; var UnitPrice: Decimal)
    var
        Currency: Record Currency;
        VATPostingSetup: Record "VAT Posting Setup";
        PriceRecalculated: Boolean;
    begin
        PriceRecalculated := false;
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);

            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      CannotCalcPriceInclVATErr,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            if SaleLinePOS."Price Includes VAT" then
                if (VATPostingSetup."VAT %" = SaleLinePOS."VAT %") and
                   (VATPostingSetup."VAT Calculation Type" = SaleLinePOS."VAT Calculation Type")
                then
                    exit;

            case SaleLinePOS."VAT Calculation Type" of
                SaleLinePOS."VAT Calculation Type"::"Normal VAT",
                SaleLinePOS."VAT Calculation Type"::"Full VAT",
                SaleLinePOS."VAT Calculation Type"::"Sales Tax":
                    begin
                        if SaleLinePOS."Price Includes VAT" then
                            UnitPrice := UnitPrice * (100 + SaleLinePOS."VAT %") / (100 + VATPostingSetup."VAT %")
                        else
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                SaleLinePOS."VAT Calculation Type"::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
            PriceRecalculated := true;
        end else
            if SaleLinePOS."Price Includes VAT" then begin
                UnitPrice := UnitPrice * (1 + SaleLinePOS."VAT %" / 100);
                PriceRecalculated := true;
            end;

        if PriceRecalculated then begin
            if SaleLinePOS."Currency Code" <> '' then
                Currency.Get(SaleLinePOS."Currency Code")
            else
                Currency.InitRoundingPrecision;
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end;
    end;

    procedure RefreshxRec()
    begin
        xRec := Rec;
    end;

    procedure GetxRec(var xSaleLinePOS: Record "NPR Sale Line POS")
    begin
        xSaleLinePOS := xRec;
    end;

    procedure SetUseLinePriceVATParams(Use: Boolean)
    begin
        UseLinePriceVATParams := Use;
    end;

    procedure ForceInsertWithAutoSplitKey(Set: Boolean)
    begin
        InsertWithAutoSplitKeyForced := Set;
    end;

    procedure InsertedWithAutoSplitKey(): Boolean
    begin
        exit(IsAutoSplitKeyRecord);
    end;

    procedure SetUsePresetLineNo(Set: Boolean)
    begin
        UsePresetLineNo := Set;
    end;
}
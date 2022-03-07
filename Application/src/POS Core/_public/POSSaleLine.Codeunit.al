codeunit 6150706 "NPR POS Sale Line"
{
    trigger OnRun()
    begin
    end;

    var
        Rec: Record "NPR POS Sale Line";
        xRec: Record "NPR POS Sale Line";
        Sale: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
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
    begin
        Clear(Rec);
        Clear(Sale);

        Rec.FilterGroup(2);
        Rec.SetRange("Register No.", RegisterNo);
        Rec.SetRange("Sales Ticket No.", SalesTicketNo);
        Rec.SetFilter(Type, '<>%1', Rec.Type::Payment);
        Rec.FilterGroup(0);

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
        SaleLinePOS: Record "NPR POS Sale Line";
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
            SaleLinePOS.Reset();
        end;

        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast() then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
    end;

    procedure GetNewSaleLine(var SaleLinePOS: Record "NPR POS Sale Line")
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
        exit(Rec.Find());
    end;

    procedure GetCurrentSaleLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        RefreshCurrent();
        SaleLinePOS.Copy(Rec);
    end;

    procedure InsertLine(var Line: Record "NPR POS Sale Line") Return: Boolean
    begin
        exit(InsertLine(Line, true));
    end;

    procedure InsertLine(var Line: Record "NPR POS Sale Line"; IncludeDiscountFields: Boolean) Return: Boolean
    var
        Item: Record Item;
    begin
        if UsePresetLineNo then
            Rec."Line No." := Line."Line No.";

        InitLine();

        Rec.Type := Line.Type;
        Rec."Sale Type" := Line."Sale Type";

        Rec.SetSkipUpdateDependantQuantity(Line."Variant Code" <> '');

        if (Line.Type = Line.Type::Item) and (Line."Variant Code" = '') then begin
            Line."Variant Code" := FillVariantThroughLookUp(Line."No.");
            Rec.SetSkipUpdateDependantQuantity(Line."Variant Code" <> '');
        end;

        Rec."Variant Code" := Line."Variant Code";
        Rec.Validate("No.", Line."No.");
        if Line."Unit of Measure Code" <> '' then
            Rec.Validate("Unit of Measure Code", Line."Unit of Measure Code");

        Rec.SetSkipUpdateDependantQuantity(false);

        if Line.Description <> '' then
            Rec.Description := Line.Description;

        Rec.Validate(Quantity, Line.Quantity);

        Rec.Validate("NPRE Seating Code", Line."NPRE Seating Code");

        if (Rec."Sale Type" = Rec."Sale Type"::"Out payment") then begin
            Rec."Unit Price" := Line."Unit Price";
            Rec.Amount := Line.Amount;
            Rec."Amount Including VAT" := Line."Amount Including VAT";
            Rec."Reason Code" := Line."Reason Code";
        end;

        if Line."Serial No." <> '' then begin //Because existing validation code cant handle blank serial number
            Rec.Validate("Serial No.", Line."Serial No.");
        end else begin
            Rec."Serial No." := Line."Serial No.";
        end;
        Rec.Validate("Serial No. not Created", Line."Serial No. not Created");

        if IncludeDiscountFields then begin
            Rec.Validate("Discount Type", Line."Discount Type");
            Rec.Validate("Discount Code", Line."Discount Code");

            Rec.Validate("Allow Line Discount", Line."Allow Line Discount");
            if not Rec."Allow Line Discount" then
                Rec.Validate("Discount %", 0)
            else
                if Line."Discount %" > 0 then
                    Rec.Validate("Discount %", Line."Discount %");
        end;

        if (Line."Unit Price" <> 0) and UseLinePriceVATParams then
            ConvertPriceToVAT(Line."Price Includes VAT", Line."VAT Bus. Posting Group", Line."VAT Prod. Posting Group", Rec, Line."Unit Price")
        else
            if (Rec.Type = Rec.Type::Item) and (Rec."No." <> '') and (Line."Unit Price" <> 0) then begin
                Item.Get(Rec."No.");
                if Item."Price Includes VAT" then begin
                    Item.TestField("VAT Bus. Posting Gr. (Price)");
                    Item.TestField("VAT Prod. Posting Group");
                end;
                ConvertPriceToVAT(Item."Price Includes VAT", Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group", Rec, Line."Unit Price");
            end;
        if (Line."Unit Price" <> 0) or Line."Manual Item Sales Price" then
            Rec.Validate("Unit Price", Line."Unit Price");

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
    end;

    procedure DeleteLine()
    var
        LocalxRec: Record "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        if (not RefreshCurrent()) then
            exit;

        OnBeforeDeletePOSSaleLine(Rec);
        LocalxRec := Rec;
        Rec.Delete(true);

        POSSalesDiscountCalcMgt.OnAfterDeleteSaleLinePOS(LocalxRec);

        if (Rec.Find('><')) then begin
            Rec.UpdateAmounts(Rec);
            Rec.Modify();
        end;
        OnAfterDeletePOSSaleLine(LocalxRec);

        POSSale.RefreshCurrent();
    end;

    procedure DeleteAll()
    var
        LocalxRec: Record "NPR POS Sale Line";
    begin
        if Rec.FindSet(true) then
            repeat
                OnBeforeDeletePOSSaleLine(Rec);
                LocalxRec := Rec;
                Rec.Delete(true);
                OnAfterDeletePOSSaleLine(LocalxRec);
            until Rec.Next() = 0;

        POSSale.RefreshCurrent();
    end;

    procedure UpdateLine()
    begin
        OnUpdateLine(Rec);
    end;

    procedure IsEmpty(): Boolean
    begin
        CheckInit(true);
        exit(Rec.IsEmpty());
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
        SaleLine: Record "NPR POS Sale Line";
        OutPaymentAmount: Decimal;
    begin
        AmountExclVAT := 0;
        VATAmount := 0;
        TotalAmount := 0;

        ItemCountWhenCalculatedBalance := 0;

        if (Rec."Register No." <> '') and (Rec."Sales Ticket No." <> '') then begin
            SaleLine.SetRange("Register No.", Rec."Register No.");
            SaleLine.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
            SaleLine.SetFilter(Type, '<>%1', Rec.Type::Comment);
            if SaleLine.FindSet() then begin
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
                until SaleLine.Next() = 0;
                VATAmount := TotalAmount - AmountExclVAT;
                TotalAmount -= OutPaymentAmount;
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
        CurrDataSet.Totals().Add('AmountExclVAT', AmountExclVAT);
        CurrDataSet.Totals().Add('VATAmount', VATAmount);
        CurrDataSet.Totals().Add('TotalAmount', TotalAmount);
        CurrDataSet.Totals().Add('ItemCount', ItemCountWhenCalculatedBalance);
    end;

    procedure GetDepositLine(var LinePOS: Record "NPR POS Sale Line")
    begin
        SetDepositLineType(LinePOS);
    end;

    procedure InitPayoutPayInLine(var LinePOS: Record "NPR POS Sale Line")
    begin
        SetPayoutPayInLineType(LinePOS);
    end;

    local procedure SetDepositLineType(var LinePOS: Record "NPR POS Sale Line")
    begin
        LinePOS."Register No." := Sale."Register No.";
        LinePOS."Sales Ticket No." := Sale."Sales Ticket No.";
        LinePOS.Date := Sale.Date;
        LinePOS."Sale Type" := LinePOS."Sale Type"::Deposit;
        LinePOS.Quantity := 1;
    end;

    local procedure SetPayoutPayInLineType(var LinePOS: Record "NPR POS Sale Line")
    begin
        LinePOS."Register No." := Sale."Register No.";
        LinePOS."Sales Ticket No." := Sale."Sales Ticket No.";
        LinePOS.Date := Sale.Date;
        LinePOS.Type := LinePOS.Type::"G/L Entry";
        LinePOS."Sale Type" := LinePOS."Sale Type"::"Out payment";
        LinePOS.Quantity := 1;
    end;

    procedure InsertDepositLine(var Line: Record "NPR POS Sale Line"; ForeignCurrencyAmount: Decimal) Return: Boolean
    begin
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

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
    end;

    procedure ResendAllOnAfterInsertPOSSaleLine()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
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

    local procedure FillVariantThroughLookUp(ItemNo: Code[20]): Code[10]
    var
        ItemVariantBuffer: Record "NPR Item Variant Buffer";
    begin
        FillVariantBuffer(ItemNo, ItemVariantBuffer);
        if ItemVariantBuffer.IsEmpty() then
            exit('');

        if Page.RunModal(Page::"NPR Item Variants Lookup", ItemVariantBuffer) = ACTION::LookupOK then
            exit(ItemVariantBuffer.Code)
        else
            Error(ITEM_REQUIRES_VARIANT, ItemNo);
    end;

    local procedure FillVariantBuffer(ItemNo: Code[20]; var TempItemVariantBuffer: Record "NPR Item Variant Buffer")
    var
        ItemVariantsQuery: Query "NPR Item Variants";
    begin
        ItemVariantsQuery.SetRange(Item_No_, ItemNo);
        ItemVariantsQuery.Open();

        while ItemVariantsQuery.Read() do begin
            TempItemVariantBuffer.Init();
            TempItemVariantBuffer.Code := ItemVariantsQuery.Code;
            TempItemVariantBuffer.Description := ItemVariantsQuery.Description;
            TempItemVariantBuffer."Description 2" := ItemVariantsQuery.Description_2;
            TempItemVariantBuffer.Insert();
        end;
        ItemVariantsQuery.Close();
    end;

    procedure InsertLineRaw(var Line: Record "NPR POS Sale Line"; HandleReturnValue: Boolean): Boolean
    begin
        Line.TestField("Register No.", Sale."Register No.");
        Line.TestField("Sales Ticket No.", Sale."Sales Ticket No.");
        Line.TestField(Date, Sale.Date);

        exit(InsertLineInternal(Line, HandleReturnValue));
    end;

    local procedure InsertLineInternal(var Line: Record "NPR POS Sale Line"; HandleReturnValue: Boolean) ReturnValue: Boolean
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

        Rec.UpdateAmounts(Rec);
        POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOS(Rec);
        InvokeOnAfterInsertSaleLineWorkflow(Rec);
        POSSale.RefreshCurrent();

        Line := Rec;
    end;

    //--- Publishers ---

    [IntegrationEvent(true, false)]
    internal procedure OnAfterDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnUpdateLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterSetQuantity(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetQuantity(var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow", 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnBeforeInsertSaleLineCode(), Text000, CurrCodeunitId(), 'OnBeforeInsertSaleLine');
        Sender.DiscoverPOSSalesWorkflow(OnAfterInsertSaleLineCode(), Text001, CurrCodeunitId(), 'OnAfterInsertSaleLine');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sale Line");
    end;

    procedure InvokeOnBeforeInsertSaleLineWorkflow(var SaleLinePOS: Record "NPR POS Sale Line")
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
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnBeforeInsertSaleLine(POSSalesWorkflowStep, SaleLinePOS);
        until POSSalesWorkflowStep.Next() = 0;
    end;

    procedure InvokeOnAfterInsertSaleLineWorkflow(var SaleLinePOS: Record "NPR POS Sale Line")
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
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnAfterInsertSaleLine(POSSalesWorkflowStep, SaleLinePOS);
        until POSSalesWorkflowStep.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATBusPostingGr: Code[20]; FromVATProdPostingGr: Code[20]; SaleLinePOS: Record "NPR POS Sale Line"; var UnitPrice: Decimal)
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
                Currency.InitRoundingPrecision();
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end;
    end;

    procedure RefreshxRec()
    begin
        xRec := Rec;
    end;

    procedure GetxRec(var xSaleLinePOS: Record "NPR POS Sale Line")
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

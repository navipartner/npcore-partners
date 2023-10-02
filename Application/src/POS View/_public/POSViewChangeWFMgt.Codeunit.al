codeunit 6150728 "NPR POS View Change WF Mgt."
{
    TableNo = "NPR POS Sales Workflow Step";

    trigger OnRun()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsInitialized() then
            Error(SessionNotInitializedErrorMessageLbl);
        OnAfterLogin(Rec, POSSession);
        Commit();
    end;

    var
        Text000: Label 'When POS View is changed to Payment';
        BlockPaymentWFDescriptionLbl: Label 'Block payment if Sale contains Items with insufficient Inventory';
        Text003: Label 'When POS View is changed from Login to Sale';
        SessionNotInitializedErrorMessageLbl: Label 'Session is not initialized.';

    // Discovery

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow", 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnPaymentViewCode(), Text000, CurrCodeunitId(), 'OnPaymentView');
        Sender.DiscoverPOSSalesWorkflow(OnAfterLoginCode(), Text003, CurrCodeunitId(), 'OnAfterLogin');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS View Change WF Mgt.");
    end;

    // OnPaymentView Workflow

    local procedure OnPaymentViewCode(): Code[20]
    begin
        exit('PAYMENT_VIEW');
    end;

    internal procedure InvokeOnPaymentViewWorkflow()
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        StartTime: DateTime;
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        StartTime := CurrentDateTime;

        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnPaymentViewCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnPaymentViewCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnPaymentView(POSSalesWorkflowStep, POSSession);
        until POSSalesWorkflowStep.Next() = 0;

        POSSession.AddServerStopwatch('PAYMENT_VIEW_WORKFLOWS', CurrentDateTime - StartTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPaymentView(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    begin
    end;


    // OnAfterLogin Workflow

    local procedure OnAfterLoginCode(): Code[20]
    begin
        exit('AFTER_LOGIN');
    end;

    [Obsolete('Use OnAfterLogin in cdu 6151544 "NPR POS Login Events"', 'NPR27.0')]
    local procedure OnAfterLogin_OnRun(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    begin
        Commit();
        if not Codeunit.Run(Codeunit::"NPR POS View Change WF Mgt.", POSSalesWorkflowStep) then;
    end;

    [Obsolete('Use OnAfterLogin in cdu 6151544 "NPR POS Login Events"', 'NPR27.0')]
    internal procedure InvokeOnAfterLoginWorkflow(var POSSession: Codeunit "NPR POS Session")
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        StartTime: DateTime;
        POSSale: Codeunit "NPR POS Sale";
    begin
        StartTime := CurrentDateTime;

        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnAfterLoginCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnAfterLoginCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnAfterLogin_OnRun(POSSalesWorkflowStep);
        until POSSalesWorkflowStep.Next() = 0;

        POSSession.AddServerStopwatch('AFTER_LOGIN_WORKFLOWS', CurrentDateTime - StartTime);
    end;

    [Obsolete('Use OnAfterLogin in cdu 6151544 "NPR POS Login Events"', 'NPR27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterLogin(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    begin
    end;

    // Test Item Inventory

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'TestItemInventory':
                begin
                    Rec.Description := CopyStr(BlockPaymentWFDescriptionLbl, 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := 10;
                    Rec.Enabled := false;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS View Change WF Mgt.", 'OnPaymentView', '', true, true)]
    local procedure TestItemInventory(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    var
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempErrorMessage: Record "Error Message" temporary;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'TestItemInventory' then
            exit;

        if not SetupSalesItems(POSSession, TempSaleLinePOS) then
            exit;
        FindNotInStockLines(TempSaleLinePOS, TempErrorMessage);

        if TempErrorMessage.HasErrors(false) then
            TempErrorMessage.ShowErrorMessages(true);
    end;

    local procedure FindNotInStockLines(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var ErrorMessage: Record "Error Message")
    begin
        if not TempSaleLinePOS.FindSet() then
            exit;

        repeat
            TempSaleLinePOS."MR Anvendt antal" := CalcInventory(TempSaleLinePOS);
            if TempSaleLinePOS."MR Anvendt antal" < TempSaleLinePOS."Quantity (Base)" then
                LogErrorMessage(TempSaleLinePOS, ErrorMessage);
        until TempSaleLinePOS.Next() = 0;
    end;

    local procedure CalcInventory(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Decimal
    var
        Item: Record Item;
    begin
        if not Item.Get(TempSaleLinePOS."No.") then
            exit(0);

        if TempSaleLinePOS."Bin Code" <> '' then
            exit(CheckBinContent(TempSaleLinePOS));

        Item.SetRange("Variant Filter", TempSaleLinePOS."Variant Code");
        Item.SetRange("Location Filter", TempSaleLinePOS."Location Code");
        if TempSaleLinePOS."Serial No." <> '' then
            if SpecificItemTrackingExist(Item) then
                Item.SetRange("Serial No. Filter", TempSaleLinePOS."Serial No.");
        Item.CalcFields(Inventory);
        exit(Item.Inventory);
    end;

    local procedure SetupSalesItems(var POSSession: Codeunit "NPR POS Session"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if not TempSaleLinePOS.IsTemporary then
            exit(false);

        Clear(TempSaleLinePOS);
        TempSaleLinePOS.DeleteAll();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        if SaleLinePOS.IsEmpty then
            exit(false);

        SaleLinePOS.FindSet();
        repeat
            SetupSalesItem(SaleLinePOS, TempSaleLinePOS);
        until SaleLinePOS.Next() = 0;
        TempSaleLinePOS.Reset();

        exit(TempSaleLinePOS.FindFirst());
    end;

    local procedure SetupSalesItem(SaleLinePOS: Record "NPR POS Sale Line"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        Item: Record Item;
    begin
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;
        if Item.IsNonInventoriableType() then
            exit;
        if Item."NPR Group sale" then
            exit;
        if not Item.PreventNegativeInventory() then
            exit;

        TempSaleLinePOS.SetRange("No.", SaleLinePOS."No.");
        TempSaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
        TempSaleLinePOS.SetRange("Location Code", SaleLinePOS."Location Code");
        TempSaleLinePOS.SetRange("Serial No.", SaleLinePOS."Serial No.");
        TempSaleLinePOS.SetRange("Bin Code", SaleLinePOS."Bin Code");
        if TempSaleLinePOS.FindFirst() then begin
            TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
            TempSaleLinePOS."Quantity (Base)" += SaleLinePOS."Quantity (Base)";
            TempSaleLinePOS.Modify();
        end else begin
            TempSaleLinePOS.Init();
            TempSaleLinePOS := SaleLinePOS;
            TempSaleLinePOS.Insert();
        end;
    end;

    local procedure SpecificItemTrackingExist(Item: Record Item): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if Item."Item Tracking Code" = '' then
            exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);
        if ItemTrackingCode."SN Specific Tracking" then
            exit(true);
        exit(false);
    end;

    local procedure CheckBinContent(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Decimal
    var
        BinContent: Record "Bin Content";
    begin
        if not BinContent.Get(TempSaleLinePOS."Location Code", TempSaleLinePOS."Bin Code", TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code", TempSaleLinePOS."Unit of Measure Code") then
            exit;
        BinContent.SetRange("Serial No. Filter", TempSaleLinePOS."Serial No.");
        BinContent.CalcFields(Quantity);
        exit(BinContent.Quantity);
    end;

    local procedure LogErrorMessage(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var ErrorMessage: Record "Error Message")
    var
        Msg: Text;
        AvailableInventoryDescLbl: Label 'The available inventory for item %1 - %2 is lower than the entered quantity at this location.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description';
        AvailableInventoryDesc2Lbl: Label 'The available inventory for item %1 - %2 %3 is lower than the entered quantity at this location.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description,%3=SaleLinePOS."Description 2"';
        AvailableInventoryBinDescLbl: Label 'The available inventory for item %1 - %2 is lower than the entered quantity in this Bin.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description';
        AvailableInventoryBinDesc2Lbl: Label 'The available inventory for item %1 - %2 %3 is lower than the entered quantity in this Bin.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description,%3=SaleLinePOS."Description 2"';
    begin
        Clear(Msg);
        if TempSaleLinePOS."Bin Code" = '' then begin
            if TempSaleLinePOS."Description 2" <> '' then
                Msg := StrSubstNo(AvailableInventoryDesc2Lbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description, TempSaleLinePOS."Description 2")
            else
                Msg := StrSubstNo(AvailableInventoryDescLbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description);
        end else begin
            if TempSaleLinePOS."Description 2" <> '' then
                Msg := StrSubstNo(AvailableInventoryBinDesc2Lbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description, TempSaleLinePOS."Description 2")
            else
                Msg := StrSubstNo(AvailableInventoryBinDescLbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description);
        end;

        ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, Msg);
    end;

}
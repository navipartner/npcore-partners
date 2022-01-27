codeunit 6150728 "NPR POS View Change WF Mgt."
{
    Access = Internal;
    TableNo = "NPR POS Sales Workflow Step";

    trigger OnRun()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSession(POSSession, true);
        OnAfterLogin(Rec, POSSession);
        Commit();
    end;

    var
        Text000: Label 'When POS View is changed to Payment';
        Text001: Label 'Block payment if Sale contains Items with insufficient Inventory';
        Text002: Label 'Insufficient Inventory:';
        Text003: Label 'When POS View is changed from Login to Sale';

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

    procedure InvokeOnPaymentViewWorkflow(var POSSession: Codeunit "NPR POS Session")
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

    local procedure OnAfterLogin_OnRun(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    begin
        Commit();
        if not Codeunit.Run(Codeunit::"NPR POS View Change WF Mgt.", POSSalesWorkflowStep) then;
    end;

    procedure InvokeOnAfterLoginWorkflow(var POSSession: Codeunit "NPR POS Session")
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
                    Rec.Description := Text001;
                    Rec."Sequence No." := 10;
                    Rec.Enabled := false;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS View Change WF Mgt.", 'OnPaymentView', '', true, true)]
    local procedure TestItemInventory(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    var
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        ErrorMessage: Text;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'TestItemInventory' then
            exit;

        if not SetupSalesItems(POSSession, TempSaleLinePOS) then
            exit;
        if not FindNotInStockLines(TempSaleLinePOS) then
            exit;

        ErrorMessage := GetInventoryErrorMessage(TempSaleLinePOS);
        Error(ErrorMessage);
    end;

    local procedure FindNotInStockLines(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    begin
        if not TempSaleLinePOS.FindSet() then
            exit(false);

        repeat
            TempSaleLinePOS."MR Anvendt antal" := CalcInventory(TempSaleLinePOS);
            if TempSaleLinePOS."MR Anvendt antal" >= TempSaleLinePOS."Quantity (Base)" then
                TempSaleLinePOS.Delete()
            else
                TempSaleLinePOS.Modify();
        until TempSaleLinePOS.Next() = 0;

        exit(TempSaleLinePOS.FindFirst());
    end;

    local procedure CalcInventory(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Decimal
    var
        Item: Record Item;
    begin
        if not Item.Get(TempSaleLinePOS."No.") then
            exit(0);

        Item.SetRange("Variant Filter", TempSaleLinePOS."Variant Code");
        Item.SetRange("Location Filter", TempSaleLinePOS."Location Code");
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
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
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
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;
        if Item.Type = Item.Type::Service then
            exit;
        if Item."NPR Group sale" then
            exit;

        TempSaleLinePOS.SetRange("No.", SaleLinePOS."No.");
        TempSaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
        TempSaleLinePOS.SetRange("Location Code", SaleLinePOS."Location Code");
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

    local procedure GetInventoryErrorMessage(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary) ErrorMessage: Text
    begin
        ErrorMessage := Text002;
        if TempSaleLinePOS.FindSet() then
            repeat
                ErrorMessage += NewLine() + TempSaleLinePOS."No.";
                ErrorMessage += ' ' + TempSaleLinePOS.Description;
                if TempSaleLinePOS."Description 2" <> '' then
                    ErrorMessage += ' ' + TempSaleLinePOS."Description 2";
                ErrorMessage += ': ' + Format(TempSaleLinePOS."MR Anvendt antal");
            until TempSaleLinePOS.Next() = 0;

        exit(ErrorMessage);
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;
}

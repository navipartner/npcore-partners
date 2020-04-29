codeunit 6150728 "POS View Change Workflow Mgt."
{
    // NPR5.43/MHA /20180613  CASE 318395 Object created
    // NPR5.45/MHA /20180820  CASE 321266 Extended POS Sales Workflow with Set functionality
    // NPR5.49/MHA /20190206  CASE 343617 Added OnAfterLogin Workflow
    // NPR5.49/MHA /20190301  CASE 347382 Added function SetupSalesItem() to skip Non Inventory Items


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'When POS View is changed to Payment';
        Text001: Label 'Block payment if Sale contains Items with insufficient Inventory';
        Text002: Label 'Insufficient Inventory:';
        Text003: Label 'When POS View is changed from Login to Sale';

    local procedure "--- Discovery"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnPaymentViewCode(),Text000,CurrCodeunitId(),'OnPaymentView');
        //-NPR5.49 [343617]
        Sender.DiscoverPOSSalesWorkflow(OnAfterLoginCode(),Text003,CurrCodeunitId(),'OnAfterLogin');
        //+NPR5.49 [343617]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"POS View Change Workflow Mgt.");
    end;

    local procedure "--- OnPaymentView Workflow"()
    begin
    end;

    local procedure OnPaymentViewCode(): Code[20]
    begin
        exit('PAYMENT_VIEW');
    end;

    procedure InvokeOnPaymentViewWorkflow(var POSSession: Codeunit "POS Session")
    var
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        POSUnit: Record "POS Unit";
        SalePOS: Record "Sale POS";
        StartTime: DateTime;
        POSSale: Codeunit "POS Sale";
        FrontEnd: Codeunit "POS Front End Management";
    begin
        StartTime := CurrentDateTime;

        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        //-NPR5.45 [321266]
        POSSalesWorkflowStep.SetFilter("Set Code",'=%1','');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set",OnPaymentViewCode()) then
          POSSalesWorkflowStep.SetRange("Set Code",POSSalesWorkflowSetEntry."Set Code");
        //+NPR5.45 [321266]
        POSSalesWorkflowStep.SetRange("Workflow Code",OnPaymentViewCode());
        POSSalesWorkflowStep.SetRange(Enabled,true);
        if not POSSalesWorkflowStep.FindSet then
          exit;

        repeat
          OnPaymentView(POSSalesWorkflowStep,POSSession);
        until POSSalesWorkflowStep.Next = 0;

        POSSession.AddServerStopwatch('PAYMENT_VIEW_WORKFLOWS',CurrentDateTime - StartTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPaymentView(POSSalesWorkflowStep: Record "POS Sales Workflow Step";var POSSession: Codeunit "POS Session")
    begin
    end;

    local procedure "--- OnAfterLogin Workflow"()
    begin
    end;

    local procedure OnAfterLoginCode(): Code[20]
    begin
        //-NPR5.49 [343617]
        exit('AFTER_LOGIN');
        //+NPR5.49 [343617]
    end;

    procedure InvokeOnAfterLoginWorkflow(var POSSession: Codeunit "POS Session")
    var
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        POSUnit: Record "POS Unit";
        SalePOS: Record "Sale POS";
        StartTime: DateTime;
        POSSale: Codeunit "POS Sale";
        FrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.49 [343617]
        StartTime := CurrentDateTime;

        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code",'=%1','');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set",OnAfterLoginCode()) then
          POSSalesWorkflowStep.SetRange("Set Code",POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code",OnAfterLoginCode());
        POSSalesWorkflowStep.SetRange(Enabled,true);
        if not POSSalesWorkflowStep.FindSet then
          exit;

        repeat
          Commit;
          asserterror begin
            OnAfterLogin(POSSalesWorkflowStep,POSSession);
            Commit;
            Error('');
          end;
        until POSSalesWorkflowStep.Next = 0;

        POSSession.AddServerStopwatch('AFTER_LOGIN_WORKFLOWS',CurrentDateTime - StartTime);
        //+NPR5.49 [343617]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLogin(POSSalesWorkflowStep: Record "POS Sales Workflow Step";var POSSession: Codeunit "POS Session")
    begin
        //-NPR5.49 [343617]
        //+NPR5.49 [343617]
    end;

    local procedure "--- Test Item Inventory"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Codeunit, 6150728, 'OnPaymentView', '', true, true)]
    local procedure TestItemInventory(POSSalesWorkflowStep: Record "POS Sales Workflow Step";var POSSession: Codeunit "POS Session")
    var
        TempSaleLinePOS: Record "Sale Line POS" temporary;
        ErrorMessage: Text;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'TestItemInventory' then
          exit;

        if not SetupSalesItems(POSSession,TempSaleLinePOS) then
          exit;
        if not FindNotInStockLines(TempSaleLinePOS) then
          exit;

        ErrorMessage := GetInventoryErrorMessage(TempSaleLinePOS);
        Error(ErrorMessage);
    end;

    local procedure FindNotInStockLines(var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    begin
        if not TempSaleLinePOS.FindSet then
          exit(false);

        repeat
          TempSaleLinePOS."MR Anvendt antal" := CalcInventory(TempSaleLinePOS);
          if TempSaleLinePOS."MR Anvendt antal" >= TempSaleLinePOS."Quantity (Base)" then
            TempSaleLinePOS.Delete
          else
            TempSaleLinePOS.Modify;
        until TempSaleLinePOS.Next = 0;

        exit(TempSaleLinePOS.FindFirst);
    end;

    local procedure CalcInventory(var TempSaleLinePOS: Record "Sale Line POS" temporary): Decimal
    var
        Item: Record Item;
    begin
        if not Item.Get(TempSaleLinePOS."No.") then
          exit(0);

        Item.SetRange("Variant Filter",TempSaleLinePOS."Variant Code");
        Item.SetRange("Location Filter",TempSaleLinePOS."Location Code");
        Item.CalcFields(Inventory);
        exit(Item.Inventory);
    end;

    local procedure SetupSalesItems(var POSSession: Codeunit "POS Session";var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    var
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
    begin
        if not TempSaleLinePOS.IsTemporary then
          exit(false);

        Clear(TempSaleLinePOS);
        TempSaleLinePOS.DeleteAll;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        if SaleLinePOS.IsEmpty then
          exit(false);

        SaleLinePOS.FindSet;
        repeat
          //-NPR5.49 [347382]
          // TempSaleLinePOS.SETRANGE("No.",SaleLinePOS."No.");
          // TempSaleLinePOS.SETRANGE("Variant Code",SaleLinePOS."Variant Code");
          // TempSaleLinePOS.SETRANGE("Location Code",SaleLinePOS."Location Code");
          // IF TempSaleLinePOS.FINDFIRST THEN BEGIN
          //  TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
          //  TempSaleLinePOS."Quantity (Base)" += SaleLinePOS."Quantity (Base)";
          //  TempSaleLinePOS.MODIFY;
          // END ELSE BEGIN
          //  TempSaleLinePOS.INIT;
          //  TempSaleLinePOS := SaleLinePOS;
          //  TempSaleLinePOS.INSERT;
          // END;
          SetupSalesItem(SaleLinePOS,TempSaleLinePOS);
          //+NPR5.49 [347382]
        until SaleLinePOS.Next = 0;
        TempSaleLinePOS.Reset;

        exit(TempSaleLinePOS.FindFirst);
    end;

    local procedure SetupSalesItem(SaleLinePOS: Record "Sale Line POS";var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        Item: Record Item;
    begin
        //-NPR5.49 [347382]
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit;
        if not Item.Get(SaleLinePOS."No.") then
          exit;
        if Item.Type = Item.Type::Service then
          exit;
        if Item."Group sale" then
          exit;

        TempSaleLinePOS.SetRange("No.",SaleLinePOS."No.");
        TempSaleLinePOS.SetRange("Variant Code",SaleLinePOS."Variant Code");
        TempSaleLinePOS.SetRange("Location Code",SaleLinePOS."Location Code");
        if TempSaleLinePOS.FindFirst then begin
          TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
          TempSaleLinePOS."Quantity (Base)" += SaleLinePOS."Quantity (Base)";
          TempSaleLinePOS.Modify;
        end else begin
          TempSaleLinePOS.Init;
          TempSaleLinePOS := SaleLinePOS;
          TempSaleLinePOS.Insert;
        end;
        //+NPR5.49 [347382]
    end;

    local procedure GetInventoryErrorMessage(var TempSaleLinePOS: Record "Sale Line POS" temporary) ErrorMessage: Text
    begin
        ErrorMessage := Text002;
        if TempSaleLinePOS.FindSet then
          repeat
            ErrorMessage += NewLine() + TempSaleLinePOS."No.";
            ErrorMessage += ' ' + TempSaleLinePOS.Description;
            if TempSaleLinePOS."Description 2" <> '' then
              ErrorMessage += ' ' + TempSaleLinePOS."Description 2";
            ErrorMessage += ': ' + Format(TempSaleLinePOS."MR Anvendt antal");
          until TempSaleLinePOS.Next = 0;

        exit(ErrorMessage);
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;
}


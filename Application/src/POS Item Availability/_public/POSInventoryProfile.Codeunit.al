codeunit 6059917 "NPR POS Inventory Profile"
{
    var
        _this: Codeunit "NPR POS Inventory Profile";
        POSItemCheckAvailability: Codeunit "NPR POS Item-Check Avail.";

    procedure ProfileExist(POSInventoryProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Inventory Profile";
    begin
        Rec.SetRange(Code, POSInventoryProfileCode);
        exit(not Rec.IsEmpty());
    end;

    procedure IsStockWarningEnabeld(POSInventoryProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Inventory Profile";
    begin
        Rec.Get(POSInventoryProfileCode);
        exit(Rec."Stockout Warning");
    end;

    procedure SetxDataset(SalePOS: Record "NPR POS Sale")
    begin
        POSItemCheckAvailability.SetxDataset(SalePOS);
    end;

    procedure SetxDataset(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        POSItemCheckAvailability.SetxDataset(SaleLinePOS);
    end;    

    procedure IsStockWarningEnabeldIfProfileExist(POSInventoryProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Inventory Profile";
    begin
        if not Rec.Get(POSInventoryProfileCode) then
            exit;
        exit(Rec."Stockout Warning");
    end;

    procedure UpsertProfile(POSInventoryProfileCode: Code[20]; Description: Text; EnableStockWarning: Boolean): Text[30]
    var
        Rec: Record "NPR POS Inventory Profile";
    begin
        if not Rec.Get(POSInventoryProfileCode) then begin
            Rec.Code := POSInventoryProfileCode;
            Rec.Init();
            Rec.Insert();
        end;
        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
        Rec."Stockout Warning" := EnableStockWarning;
        Rec.Modify();
    end; 

    procedure Bind()
    begin
        BindSubscription(_this);
    end;

    procedure Unbind()
    begin
        UnBindSubscription(_this);
    end;

    procedure DefineScopeAndCheckAvailabilityBindSubscription(SalePOS: Record "NPR POS Sale"; AskConfirmation: Boolean): Boolean
    begin
        exit(POSItemCheckAvailability.DefineScopeAndCheckAvailability(SalePOS, AskConfirmation));
    end;    

    procedure CheckAvailability_PosSale(SalePOS: Record "NPR POS Sale"; AskConfirmation: Boolean): Boolean
    begin
        exit(POSItemCheckAvailability.CheckAvailability_PosSale(SalePOS, AskConfirmation));
    end;

    procedure CheckAvailability_PosSale(SalePOS: Record "NPR POS Sale"; var Scope: Record "NPR POS Sale Line"; AskConfirmation: Boolean): Boolean
    begin
        exit(POSItemCheckAvailability.CheckAvailability_PosSale(SalePOS, Scope, AskConfirmation));
    end;

    procedure CheckAvailability_PosSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line"; AskConfirmation: Boolean): Boolean
    begin
        exit(POSItemCheckAvailability.CheckAvailability_PosSaleLine(SaleLinePOS, xSaleLinePOS, AskConfirmation));
    end;    

    procedure SetIgnoreProfile(Set: Boolean)
    begin
        POSItemCheckAvailability.SetIgnoreProfile(Set);
    end;

    procedure GetAvailabilityIssuesFound(): Boolean
    begin
        exit(POSItemCheckAvailability.GetAvailabilityIssuesFound());
    end;    

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Item-Check Avail.", 'OnItemNotAvailable', '', true, true)]
    local procedure OnItemNotAvailableBeforeAskForCnofirmation(var PosItemAvailability: Record "NPR POS Item Availability"; var Scope: Record "NPR POS Sale Line"; PosInventoryProfile: Record "NPR POS Inventory Profile"; AskConfirmation: Boolean; var Handled: Boolean; var Confirmed: Boolean)
    begin
        OnItemNotAvailable(PosItemAvailability, Scope, PosInventoryProfile."Stockout Warning", AskConfirmation, Handled, Confirmed);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemNotAvailable(var PosItemAvailability: Record "NPR POS Item Availability"; var Scope: Record "NPR POS Sale Line"; StockoutWarning: Boolean; AskConfirmation: Boolean; var Handled: Boolean; var Confirmed: Boolean)
    begin
    end;    
}
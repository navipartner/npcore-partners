codeunit 85030 "NPR Library - Sales Events"
{
    SingleInstance = true;

    var
        _CustomerGenBusPostingGroups: List of [Code[20]];
        _GenProdPostingGroups: List of [Code[20]];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnTestInitialize', '', false, false)]
    local procedure OnTestInitialize(CallerCodeunitID: Integer)
    begin
        Clear(_CustomerGenBusPostingGroups);
        Clear(_GenProdPostingGroups);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Sales", 'OnAfterCreateCustomer', '', false, false)]
    local procedure OnAfterCreateCustomer(var Customer: Record Customer)
    var
        Salesperson: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesperson(Salesperson);
        Customer."Salesperson Code" := Salesperson.Code;
        Customer.Modify();

        RegisterCustomerGenBusPostingGroup(Customer."Gen. Bus. Posting Group");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Inventory", 'OnAfterCreateItem', '', false, false)]
    local procedure OnAfterCreateItem(var Item: Record Item)
    begin
        EnsureInventoryPostingSetup(Item."Inventory Posting Group");
        RegisterGenProductPostingGroup(Item."Gen. Prod. Posting Group");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Sales", 'OnAfterCreateSalesLineWithShipmentDate', '', false, false)]
    local procedure OnAfterCreateSalesLineWithShipmentDate(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Type: Option; No: Code[20]; ShipmentDate: Date; Quantity: Decimal)
    begin
        EnsureGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
    end;

    internal procedure RegisterGenProductPostingGroup(GenProdPostingGroup: Code[20])
    var
        GenBusPostingGroup: Code[20];
    begin
        if (GenProdPostingGroup = '') or _GenProdPostingGroups.Contains(GenProdPostingGroup) then
            exit;

        _GenProdPostingGroups.Add(GenProdPostingGroup);
        foreach GenBusPostingGroup in _CustomerGenBusPostingGroups do
            EnsureGeneralPostingSetup(GenBusPostingGroup, GenProdPostingGroup);
    end;

    local procedure RegisterCustomerGenBusPostingGroup(GenBusPostingGroup: Code[20])
    var
        GenProdPostingGroup: Code[20];
    begin
        if (GenBusPostingGroup = '') or _CustomerGenBusPostingGroups.Contains(GenBusPostingGroup) then
            exit;

        _CustomerGenBusPostingGroups.Add(GenBusPostingGroup);
        foreach GenProdPostingGroup in _GenProdPostingGroups do
            EnsureGeneralPostingSetup(GenBusPostingGroup, GenProdPostingGroup);
    end;

    local procedure EnsureGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if GenProdPostingGroup = '' then
            exit;

        NPRLibraryPOSMasterData.CreateGeneralPostingSetupForSale(GenBusPostingGroup, GenProdPostingGroup);
    end;

    local procedure EnsureInventoryPostingSetup(InventoryPostingGroupCode: Code[20])
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        Modified: Boolean;
    begin
        if not InventoryPostingGroup.Get(InventoryPostingGroupCode) or
           (InventoryPostingGroup.Description <> InventoryPostingGroup.Code)
        then
            exit;

        if not InventoryPostingSetup.Get('', InventoryPostingGroupCode) then begin
            InventoryPostingSetup.Init();
            InventoryPostingSetup."Invt. Posting Group Code" := InventoryPostingGroupCode;
            InventoryPostingSetup.Insert(true);
        end;

        if InventoryPostingSetup."Inventory Account" = '' then begin
            InventoryPostingSetup.Validate("Inventory Account", LibraryERM.CreateGLAccountNo());
            Modified := true;
        end;
        if InventoryPostingSetup."Inventory Account (Interim)" = '' then begin
            InventoryPostingSetup.Validate("Inventory Account (Interim)", LibraryERM.CreateGLAccountNo());
            Modified := true;
        end;
        if InventoryPostingSetup."WIP Account" = '' then begin
            InventoryPostingSetup.Validate("WIP Account", LibraryERM.CreateGLAccountNo());
            Modified := true;
        end;
        if InventoryPostingSetup."Material Variance Account" = '' then begin
            InventoryPostingSetup.Validate("Material Variance Account", LibraryERM.CreateGLAccountNo());
            Modified := true;
        end;
        if InventoryPostingSetup."Capacity Variance Account" = '' then begin
            InventoryPostingSetup.Validate("Capacity Variance Account", LibraryERM.CreateGLAccountNo());
            Modified := true;
        end;
        if Modified then
            InventoryPostingSetup.Modify(true);
    end;
}

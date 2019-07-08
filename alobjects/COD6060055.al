codeunit 6060055 "Item Status Management"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created


    trigger OnRun()
    begin
    end;

    var
        TextErrorStatusNotActive: Label 'Item %1 has status %2. This status does not have %3 activated.';

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnInsertItemSetInitalStatus(var Rec: Record Item;RunTrigger: Boolean)
    var
        ItemStatus: Record "Item Status";
    begin
        if Rec."Item Status" <> '' then
          exit;
        ItemStatus.Reset;
        ItemStatus.SetRange(Initial,true);
        if ItemStatus.FindFirst then
          Rec.Validate("Item Status",ItemStatus.Code)
        else
          Rec.Validate("Item Status",CreateInitialStatus);
    end;

    [EventSubscriber(ObjectType::Codeunit, 21, 'OnAfterCheckItemJnlLine', '', true, true)]
    local procedure OnAfterCheckItemJnlLineCheckIfAllowed(var ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemStatus: Record "Item Status";
    begin
        if not Item.Get(ItemJnlLine."Item No.") then
          exit;
        if Item."Item Status" = '' then
          exit;
        if not ItemStatus.Get(Item."Item Status") then
          exit;
        if ItemStatus.Description = '' then
          ItemStatus.Description := ItemStatus.Code;
        case ItemJnlLine."Entry Type" of
          ItemJnlLine."Entry Type"::Purchase :
            if not ItemStatus."Purchase Post" then
              Error(TextErrorStatusNotActive,Item."No.",ItemStatus.Description,ItemStatus.FieldCaption("Purchase Post"));
          ItemJnlLine."Entry Type"::Sale:
            if not ItemStatus."Sales Post" then
              Error(TextErrorStatusNotActive,Item."No.",ItemStatus.Description,ItemStatus.FieldCaption("Sales Post"));
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteItemCheckIfAllowed(var Rec: Record Item;RunTrigger: Boolean)
    var
        ItemStatus: Record "Item Status";
    begin
        if Rec."Item Status" = '' then
          exit;
        if not ItemStatus.Get(Rec."Item Status") then
          exit;
        if ItemStatus.Description = '' then
          ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Delete Allowed" then
          Error(TextErrorStatusNotActive,Rec."No.",ItemStatus.Description,ItemStatus.FieldCaption("Delete Allowed"));
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeRenameEvent', '', true, true)]
    local procedure OnBeforeRenameItemCheckIfAllowed(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    var
        ItemStatus: Record "Item Status";
    begin
        if Rec."Item Status" = '' then
          exit;
        if not ItemStatus.Get(Rec."Item Status") then
          exit;
        if ItemStatus.Description = '' then
          ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Rename Allowed" then
          Error(TextErrorStatusNotActive,xRec."No.",ItemStatus.Description,ItemStatus.FieldCaption("Rename Allowed"));
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnBeforeValidateNoSalesLine(var Rec: Record "Sales Line";var xRec: Record "Sales Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemStatus: Record "Item Status";
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;
        if not Item.Get(Rec."No.") then
          exit;
        if Item."Item Status" = '' then
          exit;
        if not ItemStatus.Get(Item."Item Status") then
          exit;
        if ItemStatus.Description = '' then
          ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Sales Insert" then
          Error(TextErrorStatusNotActive,Item."No.",ItemStatus.Description,ItemStatus.FieldCaption("Sales Insert"));
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnBeforeValidateNoPurchaseLine(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemStatus: Record "Item Status";
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;
        if not Item.Get(Rec."No.") then
          exit;
        if Item."Item Status" = '' then
          exit;
        if not ItemStatus.Get(Item."Item Status") then
          exit;
        if ItemStatus.Description = '' then
          ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Purchase Insert" then
          Error(TextErrorStatusNotActive,Item."No.",ItemStatus.Description,ItemStatus.FieldCaption("Purchase Insert"));
    end;

    local procedure CreateInitialStatus(): Code[10]
    var
        InitialStatusCode: Code[10];
        ItemStatus: Record "Item Status";
        TxtInitialStatusDescription: Label 'New';
    begin
        InitialStatusCode := '01NEW';
        if ItemStatus.Get(InitialStatusCode) then begin
          ItemStatus.Validate(Initial,true);
          ItemStatus.Modify(true);
        end else begin
          ItemStatus.Init;
          ItemStatus.Validate(Code,InitialStatusCode);
          ItemStatus.Validate(Description,TxtInitialStatusDescription);
          ItemStatus.Validate(Initial,true);
          ItemStatus.Insert(true);
        end;
        exit(InitialStatusCode);
    end;
}


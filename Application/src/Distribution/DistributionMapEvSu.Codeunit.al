codeunit 6014409 "NPR Distribution Map Ev. Su."
{
    Access = Internal;
    #region Purchase Line

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PurchaseLineOnAfterDelete(var Rec: Record "Purchase Line")
    var
        DistribTableMap: Record "NPR Distribution Map";
    begin
        if Rec.IsTemporary() then
            exit;

        if DistribTableMap.Get(Database::"Purchase Line", Rec.SystemId) then
            DistribTableMap.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure PurchaseLineOnAfterModify(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        DistribTableMap: Record "NPR Distribution Map";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Type <> Rec.Type::Item then
            exit;

        if (Rec."No." = xRec."No.") and
            (Rec."Variant Code" = xRec."Variant Code") and
            (Rec."Location Code" = xRec."Location Code") and
            (Rec."Outstanding Quantity" = xRec."Outstanding Quantity")
        then
            exit;

        if DistribTableMap.Get(Database::"Purchase Line", Rec.SystemId) then begin
            DistribTableMap."Item No." := Rec."No.";
            DistribTableMap."Variant Code" := Rec."Variant Code";
            DistribTableMap."Location Code" := Rec."Location Code";
            DistribTableMap.Quantity := Rec."Outstanding Quantity";
            DistribTableMap.Modify();
        end;
    end;

    #endregion

    #region Transfer Line

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure TransferLineOnAfterDelete(var Rec: Record "Transfer Line")
    var
        DistribTableMap: Record "NPR Distribution Map";
    begin
        if Rec.IsTemporary() then
            exit;

        if DistribTableMap.Get(Database::"Transfer Line", Rec.SystemId) then
            DistribTableMap.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure TransferLineOnAfterModify(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line")
    var
        DistribTableMap: Record "NPR Distribution Map";
    begin
        if Rec.IsTemporary() then
            exit;

        if (Rec."Item No." = xRec."Item No.") and
            (Rec."Variant Code" = xRec."Variant Code") and
            (Rec."Transfer-to Code" = xRec."Transfer-from Code") and
            (Rec."Outstanding Quantity" = xRec."Outstanding Quantity")
        then
            exit;

        if DistribTableMap.Get(Database::"Transfer Line", Rec.SystemId) then begin
            DistribTableMap."Item No." := Rec."Item No.";
            DistribTableMap."Variant Code" := Rec."Variant Code";
            DistribTableMap."Location Code" := Rec."Transfer-to Code";
            DistribTableMap.Quantity := Rec."Outstanding Quantity";
            DistribTableMap.Modify();
        end;
    end;

    #endregion
}

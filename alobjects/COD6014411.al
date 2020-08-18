codeunit 6014411 "NPR Event Dimension Mgt"
{
    // NPR5.55/TJ  /20200407 Reintroducing funcionality for BC130+. Code restored from NAV2017 and slightly refactored


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterSetupObjectNoList', '', true, false)]
    local procedure DimensionMgtOnLoadDimensions(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        InsertObject(TempAllObjWithCaption,DATABASE::"Item Group");
        InsertObject(TempAllObjWithCaption,DATABASE::"Mixed Discount");
        InsertObject(TempAllObjWithCaption,DATABASE::"Period Discount");
        InsertObject(TempAllObjWithCaption,DATABASE::"Quantity Discount Header");
        InsertObject(TempAllObjWithCaption,DATABASE::"POS Store");
        InsertObject(TempAllObjWithCaption,DATABASE::"POS Unit");
        InsertObject(TempAllObjWithCaption,DATABASE::"NPRE Seating");
    end;

    local procedure InsertObject(var TempAllObjWithCaption: Record AllObjWithCaption temporary;TableID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table,TableID) then
          exit;
        AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID",TableID);
        if AllObjWithCaption.FindFirst then begin
          TempAllObjWithCaption := AllObjWithCaption;
          TempAllObjWithCaption.Insert;
        end;
    end;
}


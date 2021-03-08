codeunit 6014411 "NPR Event Dimension Mgt"
{
    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterSetupObjectNoList', '', true, false)]
    local procedure DimensionMgtOnLoadDimensions(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        InsertObject(TempAllObjWithCaption, DATABASE::"Item Category");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR Mixed Discount");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR Period Discount");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR Quantity Discount Header");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR POS Store");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR POS Unit");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR NPRE Seating");
    end;

    local procedure InsertObject(var TempAllObjWithCaption: Record AllObjWithCaption temporary; TableID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table, TableID) then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableID);
        if AllObjWithCaption.FindFirst then begin
            TempAllObjWithCaption := AllObjWithCaption;
            TempAllObjWithCaption.Insert;
        end;
    end;
}


#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151026 "NPR NPRE Menu Last Updated Sub"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu", OnBeforeModifyEvent, '', false, false)]
    local procedure MenuOnBeforeModify(var Rec: Record "NPR NPRE Menu")
    begin
        Rec."Last Updated" := CurrentDateTime;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterInsertEvent, '', false, false)]
    local procedure MenuCategoryOnAfterInsert(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterModifyEvent, '', false, false)]
    local procedure MenuCategoryOnAfterModify(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuCategoryOnAfterDelete(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterInsertEvent, '', false, false)]
    local procedure MenuItemOnAfterInsert(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterModifyEvent, '', false, false)]
    local procedure MenuItemOnAfterModify(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuItemOnAfterDelete(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterInsertEvent, '', false, false)]
    local procedure MenuCatTransOnAfterInsert(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterModifyEvent, '', false, false)]
    local procedure MenuCatTransOnAfterModify(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuCatTransOnAfterDelete(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterInsertEvent, '', false, false)]
    local procedure MenuItemTransOnAfterInsert(var Rec: Record "NPR NPRE Menu Item Translation")
    begin
        UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterModifyEvent, '', false, false)]
    local procedure MenuItemTransOnAfterModify(var Rec: Record "NPR NPRE Menu Item Translation")
    begin
        UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuItemTransOnAfterDelete(var Rec: Record "NPR NPRE Menu Item Translation")
    begin
        UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Upsell", OnAfterInsertEvent, '', false, false)]
    local procedure UpsellOnAfterInsert(var Rec: Record "NPR NPRE Upsell")
    begin
        UpdateMenuLastUpdatedFromUpsell(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Upsell", OnAfterModifyEvent, '', false, false)]
    local procedure UpsellOnAfterModify(var Rec: Record "NPR NPRE Upsell")
    begin
        UpdateMenuLastUpdatedFromUpsell(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Upsell", OnAfterDeleteEvent, '', false, false)]
    local procedure UpsellOnAfterDelete(var Rec: Record "NPR NPRE Upsell")
    begin
        UpdateMenuLastUpdatedFromUpsell(Rec);
    end;

    local procedure UpdateMenuLastUpdated(RestaurantCode: Code[20]; MenuCode: Code[20])
    var
        Menu: Record "NPR NPRE Menu";
    begin
        if (RestaurantCode = '') or (MenuCode = '') then
            exit;
        if not Menu.Get(RestaurantCode, MenuCode) then
            exit;
        Menu."Last Updated" := CurrentDateTime;
        Menu.Modify();
    end;

    local procedure UpdateMenuLastUpdatedFromMenuItemTranslation(MenuItemTranslation: Record "NPR NPRE Menu Item Translation")
    var
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        if not MenuItem.GetBySystemId(MenuItemTranslation."External System Id") then
            exit;
        UpdateMenuLastUpdated(MenuItem."Restaurant Code", MenuItem."Menu Code");
    end;

    local procedure UpdateMenuLastUpdatedFromUpsell(Upsell: Record "NPR NPRE Upsell")
    var
        MenuItem: Record "NPR NPRE Menu Item";
        Menu: Record "NPR NPRE Menu";
    begin
        case Upsell."External Table" of
            Upsell."External Table"::MenuItem:
                begin
                    if not MenuItem.GetBySystemId(Upsell."External System Id") then
                        exit;
                    UpdateMenuLastUpdated(MenuItem."Restaurant Code", MenuItem."Menu Code");
                end;
            Upsell."External Table"::Menu:
                begin
                    if not Menu.GetBySystemId(Upsell."External System Id") then
                        exit;
                    UpdateMenuLastUpdated(Menu."Restaurant Code", Menu.Code);
                end;
        end;
    end;
}
#endif

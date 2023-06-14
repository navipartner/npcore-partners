page 6150883 "NPR Restaurants Step"
{
    Extensible = False;
    Caption = 'Restaurants';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Restaurant";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies the value of the Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Service Flow Profile"; Rec."Service Flow Profile")
                {
                    ToolTip = 'Specifies the selected Service Flow Profile. A new profile can be created if needed.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies whether the order will be automatically sent to the kitchen once captured.';
                    ApplicationArea = NPRRetail;
                }
                field("Resend All On New Lines"; Rec."Resend All On New Lines")
                {
                    ToolTip = 'Specifies whether all lines on the waiter pad are sent to the kitchen when new lines are added to the waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                {
                    ToolTip = 'Specifies whether the kitchen printing is active.';
                    ApplicationArea = NPRRetail;
                }
                field("KDS Active"; Rec."KDS Active")
                {
                    ToolTip = 'Specifies whether the KDS is active.';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                {
                    ToolTip = 'Specifies the assignment method of the order ID.';
                    ApplicationArea = NPRRetail;
                }
                field("Station Req. Handl. On Serving"; Rec."Station Req. Handl. On Serving")
                {
                    ToolTip = 'Specifies how kitchen station production requests should be handled, if the product has been served prior to finishing production.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        Restaurants: Record "NPR NPRE Restaurant";
    begin
        Rec.DeleteAll();

        if Restaurants.FindSet() then
            repeat
                Rec := Restaurants;
                if not Rec.Insert() then
                    Rec.Modify();
            until Restaurants.Next() = 0;
    end;

    internal procedure RestaurantsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateRestaurants()
    var
        Restaurants: Record "NPR NPRE Restaurant";
    begin
        if Rec.FindSet() then
            repeat
                Restaurants := Rec;
                if not Restaurants.Insert() then
                    Restaurants.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempRestaurants(var TempRestaurant: Record "NPR NPRE Restaurant")
    begin
        TempRestaurant.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempRestaurant := Rec;
                if not TempRestaurant.Insert() then
                    TempRestaurant.Modify();
            until Rec.Next() = 0;
    end;
}

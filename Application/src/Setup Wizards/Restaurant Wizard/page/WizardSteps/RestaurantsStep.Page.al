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
                    ToolTip = 'Specifies a code to identify this restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies a text that describes the restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies optional information in addition to the name.';
                    ApplicationArea = NPRRetail;
                }
                field("Service Flow Profile"; Rec."Service Flow Profile")
                {
                    ToolTip = 'Specifies the service flow profile, assigned to the restaurant. Service flow profiles define general restaurant servise flow options, such as at what stage waiter pads should be closed, or when seating should be cleared.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies if system should automatically create or update kitchen orders as soon as new products are saved to waiter pads.';
                    ApplicationArea = NPRRetail;
                }
                field("Resend All On New Lines"; Rec."Resend All On New Lines")
                {
                    ToolTip = 'Specifies if each time, when a new set of products are saved to a waiter pad, system should resend to kitchen both new and existing products from the waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                {
                    ToolTip = 'Specifies whether the kitchen printing is active.';
                    ApplicationArea = NPRRetail;
                }
                field("KDS Active"; Rec."KDS Active")
                {
                    ToolTip = 'Specifies whether the Kitchen Display Systme (KDS) is active.';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                {
                    ToolTip = 'Specifies whether sistem should updated existing kitchen order or create a new one, when a new set of products is added to an existing waiter pad. This can affect the order products are prepared at kitchen stations.';
                    ApplicationArea = NPRRetail;
                }
                field("Station Req. Handl. On Serving"; Rec."Station Req. Handl. On Serving")
                {
                    ToolTip = 'Specifies how existing kitchen station production requests should be handled, if a product has been served prior to finishing production.';
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

page 6150884 "NPR Seating Locations Step"
{
    Extensible = False;
    Caption = 'Seating Locations';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Seating Location";
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
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR NPRE Restaurants", TempRestaurants_) = Action::LookupOK then begin
                            Rec."Restaurant Code" := TempRestaurants_.Code;
                        end;
                    end;
                }
                field("POS Store"; Rec."POS Store")
                {
                    ToolTip = 'Specifies the value of the POS Store field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        TempRestaurants_: Record "NPR NPRE Restaurant" temporary;

    internal procedure CopyLiveData()
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        Rec.DeleteAll();

        if SeatingLocation.FindSet() then
            repeat
                Rec := SeatingLocation;
                if not Rec.Insert() then
                    Rec.Modify();
            until SeatingLocation.Next() = 0;
    end;

    internal procedure SeatingLocationsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateSeatingLocations()
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if Rec.FindSet() then
            repeat
                SeatingLocation := Rec;
                if not SeatingLocation.Insert() then
                    SeatingLocation.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempRestaurants(var TempRestaurant: Record "NPR NPRE Restaurant")
    begin
        if TempRestaurant.FindSet() then
            repeat
                TempRestaurants_ := TempRestaurant;
                if TempRestaurants_.Insert() then;
            until TempRestaurant.Next() = 0;
    end;

    internal procedure CopyTempSeatingLocations(var TempSeatingLocations: Record "NPR NPRE Seating Location")
    begin
        TempSeatingLocations.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempSeatingLocations := Rec;
                if not TempSeatingLocations.Insert() then
                    TempSeatingLocations.Modify();
            until Rec.Next() = 0;
    end;
}

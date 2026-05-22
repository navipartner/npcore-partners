page 6150667 "NPR NPRE Seating Location"
{
    Extensible = False;
    Caption = 'Seating Locations';
    ContextSensitiveHelpPage = 'docs/restaurant/explanation/seating_layout/';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Layout';
    SourceTable = "NPR NPRE Seating Location";
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this seating location.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field(Control6014404; Rec.Seatings)
                {
                    Editable = false;
                    ToolTip = 'Specifies the total number of seatings (tables) created at the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field(Seats; Rec.Seats)
                {
                    Editable = false;
                    ToolTip = 'Specifies the total number of guests that can be simultaneously seated at the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store"; Rec."POS Store")
                {
                    ToolTip = 'Specifies the POS store this seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies if system should automatically create or update kitchen orders as soon as new products are saved to waiter pads.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Number of Guests"; Rec."Default Number of Guests")
                {
                    ToolTip = 'Specifies the default number of guests, when a new waiter pad is created for the seating location. <Default> means that the value is going to be inherited from restaurant the seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(NewSeatingLocation)
            {
                Caption = 'New';
                Image = NewDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Create a new seating location.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TempSeatingLocation: Record "NPR NPRE Seating Location" temporary;
                    SeatingLocation: Record "NPR NPRE Seating Location";
                begin
                    TempSeatingLocation.Init();
                    ApplyFiltersAsDefaults(Rec, TempSeatingLocation);
                    TempSeatingLocation.Insert();
                    if Page.RunModal(Page::"NPR NPRE Seating Location Card", TempSeatingLocation) = Action::LookupOK then begin
                        SeatingLocation := TempSeatingLocation;
                        SeatingLocation.Insert(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(EditSeatingLocation)
            {
                Caption = 'Edit';
                Image = Edit;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                ToolTip = 'Edit the selected seating location.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TempSeatingLocation: Record "NPR NPRE Seating Location" temporary;
                    SeatingLocation: Record "NPR NPRE Seating Location";
                begin
                    TempSeatingLocation := Rec;
                    TempSeatingLocation.Insert();
                    if Page.RunModal(Page::"NPR NPRE Seating Location Card", TempSeatingLocation) = Action::LookupOK then begin
                        SeatingLocation.Get(Rec.Code);
                        if TempSeatingLocation.Code <> SeatingLocation.Code then
                            SeatingLocation.Rename(TempSeatingLocation.Code);
                        if Format(TempSeatingLocation) <> Format(SeatingLocation) then begin
                            SeatingLocation.TransferFields(TempSeatingLocation, false);
                            SeatingLocation.Modify(true);
                        end;
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        area(navigation)
        {
            group(Layout)
            {
                Caption = 'Layout';
                Image = ServiceZones;
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Seating List";
                    RunPageLink = "Seating Location" = FIELD(Code);
                    ToolTip = 'View seatings defined at the location.';
                    ApplicationArea = NPRRetail;

                }
            }
        }
    }

    local procedure ApplyFiltersAsDefaults(var SourceRec: Record "NPR NPRE Seating Location"; var TargetRec: Record "NPR NPRE Seating Location")
    var
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        FldRef: FieldRef;
        TargetFldRef: FieldRef;
        i: Integer;
    begin
        RecRef.GetTable(SourceRec);
        TargetRecRef.GetTable(TargetRec);
        for i := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(i);
            if (FldRef.Class = FieldClass::Normal) and (FldRef.GetFilter() <> '') then
                if FldRef.GetRangeMin() = FldRef.GetRangeMax() then begin
                    TargetFldRef := TargetRecRef.Field(FldRef.Number);
                    TargetFldRef.Value := FldRef.GetRangeMin();
                end;
        end;
        TargetRecRef.SetTable(TargetRec);
    end;
}

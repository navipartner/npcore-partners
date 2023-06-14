page 6150893 "NPR Kitch. Stat. Selec. Step"
{
    Extensible = False;
    Caption = 'Kitchen Stations Selection Setup';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Kitchen Station Slct.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the value of the Seating Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ToolTip = 'Specifies the value of the Print Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ToolTip = 'Specifies the value of the Kitchen Station field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        TempKitchenStations_.SetRange("Restaurant Code", Rec."Production Restaurant Code");
                        if Page.RunModal(Page::"NPR NPRE Kitchen Stations", TempKitchenStations_) = Action::LookupOK then begin
                            Rec."Kitchen Station" := TempKitchenStations_.Code;
                        end;
                    end;
                }
            }
        }
    }
    var
        TempKitchenStations_: Record "NPR NPRE Kitchen Station" temporary;

    internal procedure CopyLiveData()
    var
        KitchenStationsSelectionSetup: Record "NPR NPRE Kitchen Station Slct.";
    begin
        Rec.DeleteAll();

        if KitchenStationsSelectionSetup.FindSet() then
            repeat
                Rec := KitchenStationsSelectionSetup;
                if not Rec.Insert() then
                    Rec.Modify();
            until KitchenStationsSelectionSetup.Next() = 0;
    end;

    internal procedure KitchenStationSelectionSetupToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateKitchenStationSelectionSetup()
    var
        KitchenStationsSelectionSetup: Record "NPR NPRE Kitchen Station Slct.";
    begin
        if Rec.FindSet() then
            repeat
                KitchenStationsSelectionSetup := Rec;
                if not KitchenStationsSelectionSetup.Insert() then
                    KitchenStationsSelectionSetup.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempKitchenStations(var TempKitchenStations: Record "NPR NPRE Kitchen Station")
    begin

        If TempKitchenStations.FindSet() then
            repeat
                TempKitchenStations_ := TempKitchenStations;
                if TempKitchenStations_.Insert() then;
            until TempKitchenStations.Next() = 0;
    end;
}

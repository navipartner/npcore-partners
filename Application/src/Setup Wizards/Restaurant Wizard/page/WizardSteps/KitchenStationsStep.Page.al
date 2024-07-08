page 6150892 "NPR Kitchen Stations Step"
{
    Extensible = False;
    Caption = 'Kitchen Stations';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Kitchen Station";
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
                field("Description 2"; Rec."Description 2")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        KitchenStations: Record "NPR NPRE Kitchen Station";
    begin
        Rec.DeleteAll();

        if KitchenStations.FindSet() then
            repeat
                Rec := KitchenStations;
                if not Rec.Insert() then
                    Rec.Modify();
            until KitchenStations.Next() = 0;
    end;

    internal procedure KitchenStationsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateKitchenStations()
    var
        KitchenStations: Record "NPR NPRE Kitchen Station";
    begin
        if Rec.FindSet() then
            repeat
                KitchenStations := Rec;
                if not KitchenStations.Insert() then
                    KitchenStations.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempKitchenStations(var TempKitchenStations: Record "NPR NPRE Kitchen Station")
    begin
        TempKitchenStations.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempKitchenStations := Rec;
                if not TempKitchenStations.Insert() then
                    TempKitchenStations.Modify();
            until Rec.Next() = 0;
    end;
}

page 6150879 "NPR Item Routing Prof. Step"
{
    Extensible = False;
    Caption = 'Item Routing Profiles';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Item Routing Profile";
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
                field(AssignedFlowStatuses; Rec.AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {
                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Serving Steps field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsString())
                {
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowPrintCategories();
                    end;
                }
            }
        }
    }

    var
        FlowStatus: Record "NPR NPRE Flow Status";

    internal procedure CopyLiveData()
    var
        ItemRoutingProfiles: Record "NPR NPRE Item Routing Profile";
    begin
        Rec.DeleteAll();

        if ItemRoutingProfiles.FindSet() then
            repeat
                Rec := ItemRoutingProfiles;
                if not Rec.Insert() then
                    Rec.Modify();
            until ItemRoutingProfiles.Next() = 0;
    end;

    internal procedure ItemRoutingProfilesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateItemRoutingProfiles()
    var
        ItemRoutingProfiles: Record "NPR NPRE Item Routing Profile";
    begin
        if Rec.FindSet() then
            repeat
                ItemRoutingProfiles := Rec;
                if not ItemRoutingProfiles.Insert() then
                    ItemRoutingProfiles.Modify();
            until Rec.Next() = 0;
    end;
}

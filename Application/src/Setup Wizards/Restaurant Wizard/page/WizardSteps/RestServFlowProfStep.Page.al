page 6150881 "NPR Rest.Serv.Flow.Prof. Step"
{
    Extensible = False;
    Caption = 'Restaurant Service Flow Profiles';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Serv.Flow Profile";
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
                field("Close Waiter Pad On"; Rec."Close Waiter Pad On")
                {
                    ToolTip = 'Specifies the value of the Close Waiter Pad On field';
                    ApplicationArea = NPRRetail;
                }
                field("Only if Fully Paid"; Rec."Only if Fully Paid")
                {
                    ToolTip = 'Specifies whether waiter pads will be closed only after full payment';
                    ApplicationArea = NPRRetail;
                }
                field("Clear Seating On"; Rec."Clear Seating On")
                {
                    ToolTip = 'Specifies the value of the Clear Seating On field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Status after Clearing"; Rec."Seating Status after Clearing")
                {
                    ToolTip = 'Specifies the value of the Seating Status after Clearing field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        RestServFlowProfiles: Record "NPR NPRE Serv.Flow Profile";
    begin
        Rec.DeleteAll();

        if RestServFlowProfiles.FindSet() then
            repeat
                Rec := RestServFlowProfiles;
                if not Rec.Insert() then
                    Rec.Modify();
            until RestServFlowProfiles.Next() = 0;
    end;

    internal procedure RestServFlowProfilesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateRestServFlowProfiles()
    var
        RestServFlowProfiles: Record "NPR NPRE Serv.Flow Profile";
    begin
        if Rec.FindSet() then
            repeat
                RestServFlowProfiles := Rec;
                if not RestServFlowProfiles.Insert() then
                    RestServFlowProfiles.Modify();
            until Rec.Next() = 0;
    end;
}

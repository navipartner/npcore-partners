page 6151537 "NPR Nc Endpoint Types"
{
    Caption = 'Nc Endpoint Types';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Nc Endpoint Type";
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Endpoints)
            {
                Caption = 'Endpoints';
                Image = Export;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Nc Endpoints";
                RunPageLink = "Endpoint Type" = FIELD(Code);
                RunPageView = SORTING(Code)
                              ORDER(Ascending);

                ToolTip = 'Executes the Endpoints action';
                ApplicationArea = NPRNaviConnect;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetupEndpointTypes();
    end;
}


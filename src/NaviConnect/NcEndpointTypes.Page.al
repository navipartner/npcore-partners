page 6151537 "NPR Nc Endpoint Types"
{
    // NC2.01\BR\20160921  CASE 247479 Object created

    Caption = 'Nc Endpoint Types';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Nc Endpoint Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Nc Endpoints";
                RunPageLink = "Endpoint Type" = FIELD(Code);
                RunPageView = SORTING(Code)
                              ORDER(Ascending);
                ApplicationArea=All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetupEndpointTypes;
    end;
}


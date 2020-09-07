page 6151056 "NPR Distrib. Group"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group';
    PageType = Card;
    SourceTable = "NPR Distrib. Group";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Warehouse Location"; "Warehouse Location")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Overhead Pct."; "Warehouse Overhead Pct.")
                {
                    ApplicationArea = All;
                }
            }
            part(Control10; "NPR Distrib. Grp Memb Listpart")
            {
                SubPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea=All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Distributions setup")
            {
                Caption = 'Distribution setup';
                Image = Setup;
                Promoted = true;
                RunObject = Page "NPR Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea=All;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        DistributionLines: Record "NPR Distribution Lines";
    begin
    end;
}


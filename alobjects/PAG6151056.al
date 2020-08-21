page 6151056 "Distribution Group"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group';
    PageType = Card;
    SourceTable = "Distribution Group";

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
            part(Control10; "Distribution Grp Memb Listpart")
            {
                SubPageLink = "Distribution Group" = FIELD(Code);
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
                RunObject = Page "Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        DistributionLines: Record "Distribution Lines";
    begin
    end;
}


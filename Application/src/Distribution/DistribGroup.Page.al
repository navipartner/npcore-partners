page 6151056 "NPR Distrib. Group"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Warehouse Location"; "Warehouse Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warehouse Location field';
                }
                field("Warehouse Overhead Pct."; "Warehouse Overhead Pct.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warehouse Overhead Pct. field';
                }
            }
            part(Control10; "NPR Distrib. Grp Memb Listpart")
            {
                SubPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea = All;
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
				PromotedOnly = true;
                RunObject = Page "NPR Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution setup action';
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        DistributionLines: Record "NPR Distribution Lines";
    begin
    end;
}


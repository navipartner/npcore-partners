page 6151056 "NPR Distrib. Group"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Distrib. Group";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
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
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Warehouse Location"; Rec."Warehouse Location")
                {

                    ToolTip = 'Specifies the value of the Warehouse Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Warehouse Overhead Pct."; Rec."Warehouse Overhead Pct.")
                {

                    ToolTip = 'Specifies the value of the Warehouse Overhead Pct. field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control10; "NPR Distrib. Grp Memb Listpart")
            {
                SubPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea = NPRRetail;

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
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);

                ToolTip = 'Executes the Distribution setup action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
    end;
}


page 6014667 "Stock-Take Template Card"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created

    Caption = 'Stock-Take Template Card';
    PageType = Card;
    SourceTable = "Stock-Take Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Stock Take Method";"Stock Take Method")
                {
                }
                field("Adjustment Method";"Adjustment Method")
                {
                }
                field("Counting Method";"Counting Method")
                {
                }
                field("Suggested Unit Cost Source";"Suggested Unit Cost Source")
                {
                }
                field("Transfer Action";"Transfer Action")
                {
                }
                field("Aggregation Level";"Aggregation Level")
                {
                }
                field("Session Based Loading";"Session Based Loading")
                {
                }
                field("Session Based Transfer";"Session Based Transfer")
                {
                }
                field("Data Release";"Data Release")
                {
                }
                field("Defaul Profile";"Defaul Profile")
                {
                }
                field("Allow User Modification";"Allow User Modification")
                {
                }
                field("Allow Unit Cost Change";"Allow Unit Cost Change")
                {
                }
            }
            group(Scope)
            {
                field("Location Code";"Location Code")
                {
                }
                field("Item Group Filter";"Item Group Filter")
                {
                }
                field("Vendor Code Filter";"Vendor Code Filter")
                {
                }
            }
            group(Transfer)
            {
                field("Item Journal Template Name";"Item Journal Template Name")
                {
                }
                field("Item Journal Batch Name";"Item Journal Batch Name")
                {
                }
                field("Item Journal Batch Usage";"Item Journal Batch Usage")
                {
                }
                field("Items Out-of-Scope";"Items Out-of-Scope")
                {
                }
                field("Suppress Not Counted";"Suppress Not Counted")
                {
                }
                field("Items in Scope Not Counted";"Items in Scope Not Counted")
                {
                }
                field("Barcode Not Accepted";"Barcode Not Accepted")
                {
                }
                field("Blocked Item";"Blocked Item")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup6150643)
            {
                action("Create Default Templates")
                {
                    Caption = 'Create Default Templates';
                    Ellipsis = true;
                    Image = CreateInteraction;

                    trigger OnAction()
                    begin
                        PhysInvMgr.CreateDefaultTemplates ();
                    end;
                }
            }
        }
    }

    var
        PhysInvMgr: Codeunit "Stock-Take Manager";
}


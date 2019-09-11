page 6014668 "Stock-Take Configuration Card"
{
    // NPR4.16/TS/20150527 CASE213313  Page Created
    // NPR5.51/TSA /20190722 CASE 359375 Added field "Keep Worksheets"

    Caption = 'Stock-Take Configuration Card';
    PageType = Card;
    SourceTable = "Stock-Take Configuration";

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
                field("Stock-Take Template Code";"Stock-Take Template Code")
                {
                }
                field("Inventory Calc. Date";"Inventory Calc. Date")
                {
                }
                field("Stock Take Method";"Stock Take Method")
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
                group(Control6014401)
                {
                    ShowCaption = false;
                    field("Data Release";"Data Release")
                    {
                    }
                    field("Keep Worksheets";"Keep Worksheets")
                    {
                    }
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
                field("Adjustment Method";"Adjustment Method")
                {
                }
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
                field("Items in Scope Not Counted";"Items in Scope Not Counted")
                {
                }
                field("Suppress Not Counted";"Suppress Not Counted")
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
            group(Configuration)
            {
                Caption = 'Configuration';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID"=CONST(6014665),
                                  "No."=FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    var
                        NPRDimMgt: Codeunit NPRDimensionManagement;
                    begin
                    end;
                }
            }
        }
    }
}


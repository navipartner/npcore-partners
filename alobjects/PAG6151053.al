page 6151053 "Item Hiearachy Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hiearachy Lines';
    PageType = List;
    SourceTable = "Item Hierarchy Line";
    SourceTableView = SORTING("Linked Table Key Value");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = "Item Hierarchy Level";
                IndentationControls = "Linked Table Key Value";
                ShowAsTree = true;
                field(Hierachy;"Related Table Desc Field Value")
                {
                    Caption = 'Hierachy';
                }
                field("Item Hierarchy Level";"Item Hierarchy Level")
                {
                    Caption = 'Level';
                }
                field("Item Hierachy Description";"Item Hierachy Description")
                {
                    Caption = 'Description';
                }
                field("Item No.";"Item No.")
                {
                }
                field(Description;"Item Desc.")
                {
                    Caption = 'Item Description';
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Linked Table Key Value";"Linked Table Key Value")
                {
                    Visible = false;
                }
                field("Related Table Key Field Value";"Related Table Key Field Value")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Hierachy Lines")
            {
                Caption = 'Create Hierachy Lines';
                Image = Item;

                trigger OnAction()
                var
                    ItemHierarchy: Record "Item Hierarchy";
                    ItemHierarchyMgmt: Codeunit "Item Hierarchy Mgmt.";
                begin
                    ItemHierarchy.Get(GetFilter("Item Hierarchy Code"));
                    ItemHierarchyMgmt.CreateItemHierarchyLines(ItemHierarchy);
                end;
            }
            action("Add Hierachy Item")
            {
                Caption = 'Add Hierachy Item';
                Image = NewItem;
                Promoted = true;

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    REPORT.RunModal(6151050,true,true,Rec);
                end;
            }
        }
    }
}


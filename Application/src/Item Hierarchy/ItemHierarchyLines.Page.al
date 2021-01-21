page 6151053 "NPR Item Hierarchy Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hiearachy Lines';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Item Hierarchy Line";
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
                field(Hierachy; "Related Table Desc Field Value")
                {
                    ApplicationArea = All;
                    Caption = 'Hierachy';
                    ToolTip = 'Specifies the value of the Hierachy field';
                }
                field("Item Hierarchy Level"; "Item Hierarchy Level")
                {
                    ApplicationArea = All;
                    Caption = 'Level';
                    ToolTip = 'Specifies the value of the Level field';
                }
                field("Item Hierachy Description"; "Item Hierachy Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Description; "Item Desc.")
                {
                    ApplicationArea = All;
                    Caption = 'Item Description';
                    ToolTip = 'Specifies the value of the Item Description field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Linked Table Key Value"; "Linked Table Key Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Linked Table Key Value field';
                }
                field("Related Table Key Field Value"; "Related Table Key Field Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Related Table Key Field Value field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Create Hierachy Lines action';

                trigger OnAction()
                var
                    ItemHierarchy: Record "NPR Item Hierarchy";
                    ItemHierarchyMgmt: Codeunit "NPR Item Hierarchy Mgmt.";
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
				PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Add Hierachy Item action';

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    REPORT.RunModal(6151050, true, true, Rec);
                end;
            }
        }
    }
}


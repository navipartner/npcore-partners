page 6151053 "NPR Item Hierarchy Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hiearachy Lines';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Item Hierarchy Line";
    SourceTableView = SORTING("Linked Table Key Value");
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec."Item Hierarchy Level";
                IndentationControls = "Linked Table Key Value";
                ShowAsTree = true;
                field(Hierachy; Rec."Related Table Desc Field Value")
                {

                    Caption = 'Hierachy';
                    ToolTip = 'Specifies the value of the Hierachy field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Hierarchy Level"; Rec."Item Hierarchy Level")
                {

                    Caption = 'Level';
                    ToolTip = 'Specifies the value of the Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Hierachy Description"; Rec."Item Hierachy Description")
                {

                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec."Item Desc.")
                {

                    Caption = 'Item Description';
                    ToolTip = 'Specifies the value of the Item Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Linked Table Key Value"; Rec."Linked Table Key Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Linked Table Key Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Related Table Key Field Value"; Rec."Related Table Key Field Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Related Table Key Field Value field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Create Hierachy Lines action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ItemHierarchy: Record "NPR Item Hierarchy";
                    ItemHierarchyMgmt: Codeunit "NPR Item Hierarchy Mgmt.";
                begin
                    ItemHierarchy.Get(Rec.GetFilter("Item Hierarchy Code"));
                    ItemHierarchyMgmt.CreateItemHierarchyLines(ItemHierarchy);
                end;
            }
            action("Add Hierachy Item")
            {
                Caption = 'Add Hierachy Item';
                Image = NewItem;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Add Hierachy Item action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    REPORT.RunModal(6151050, true, true, Rec);
                end;
            }
        }
    }
}


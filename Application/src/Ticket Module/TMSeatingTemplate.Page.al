page 6151131 "NPR TM Seating Template"
{
    // TM1.45/TSA/20200122  CASE 322432-01 Transport TM1.45 - 22 January 2020

    Caption = 'Seating Template';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Seating Template";
    SourceTableView = SORTING("Admission Code", Path);
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = "Indent Level";
                IndentationControls = "Seating Code", Description;
                ShowAsTree = true;
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Seating Code"; "Seating Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Seating Code field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field(Capacity; Capacity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity field';
                }
                field("Reservation Category"; "Reservation Category")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reservation Category field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Style = StandardAccent;
                    StyleExpr = AccentuatedPrice;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Price field';

                    trigger OnValidate()
                    var
                        SeatingTemplate: Record "NPR TM Seating Template";
                    begin

                        if (Confirm(UPDATE_CHILDREN, true)) then begin
                            SeatingTemplate.SetFilter("Admission Code", '=%1', Rec."Admission Code");
                            SeatingTemplate.SetFilter(Path, '%1', StrSubstNo('%1/*', Rec.Path));
                            SeatingTemplate.ModifyAll("Unit Price", Rec."Unit Price");
                        end;

                        CurrPage.Update(false);
                    end;
                }
                field(UnitPrice; UnitPrice)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Unit Price';
                    Style = StandardAccent;
                    StyleExpr = AccentuatedPrice;
                    ToolTip = 'Specifies the value of the Unit Price field';

                    trigger OnValidate()
                    var
                        SeatingTemplate: Record "NPR TM Seating Template";
                    begin

                        if (Confirm(UPDATE_CHILDREN, true)) then begin
                            SeatingTemplate.SetFilter("Admission Code", '=%1', Rec."Admission Code");
                            SeatingTemplate.SetFilter(Path, '%1', StrSubstNo('%1/*', Rec.Path));
                            SeatingTemplate.ModifyAll("Unit Price", Rec."Unit Price");
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field(Ordinal; Ordinal)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ordinal field';
                }
                field(Path; Path)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Path field';
                }
                field("Indent Level"; "Indent Level")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Indent Level field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Delete")
            {
                ToolTip = 'Remove area.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Delete';
                Image = Delete;
                Promoted = true;
                PromotedIsBig = true;


                trigger OnAction()
                begin

                    DeleteNode();
                end;
            }
            action("Add Root")
            {
                ToolTip = 'Add a new top area.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Add Root';
                Image = Add; 


                trigger OnAction()
                begin

                    if (GetFilter("Admission Code") <> '') then
                        SeatingManagement.AddRoot(GetFilter("Admission Code"), '');
                end;
            }
            action("Add Parent")
            {
                ToolTip = 'Add a parent area to selected area.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Add Parent';
                Image = Add; 

            }
            action("Add Child")
            {
                ToolTip = 'Add a sub area to the selected area.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Add Child';
                Image = Add; 


                trigger OnAction()
                begin

                    SeatingManagement.AddChild(Rec."Entry No.");
                end;
            }
            action("Add Sibling")
            {
                ToolTip = 'Add an area on the same level as selected area.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Add Sibling';
                Image = Add;


                trigger OnAction()
                begin

                    SeatingManagement.AddSibling(Rec."Entry No.");
                end;
            }
            action("Structure Wizard")
            {
                ToolTip = 'Start the area create wizard.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Structure Wizard';
                Image = Action; 


                trigger OnAction()
                var
                    SeatingTemplate: Record "NPR TM Seating Template";
                begin

                    SeatingManagement.RowsAndSeatWizard(Rec."Entry No.", 1, SeatingTemplate);
                end;
            }
            action("Numbering Wizard")
            {
                ToolTip = 'Start the seat number wizard.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Numbering Wizard';
                Image = Action; 
            


                trigger OnAction()
                var
                    SeatingTemplate: Record "NPR TM Seating Template";
                begin

                    CurrPage.SetSelectionFilter(SeatingTemplate);
                    SeatingManagement.RowsAndSeatWizard(Rec."Entry No.", 2, SeatingTemplate);
                end;
            }
            action("Split Wizard")
            {
                ToolTip = 'Start the area split wizard.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Split Wizard';
                Image = Action; 


                trigger OnAction()
                var
                    SeatingTemplate: Record "NPR TM Seating Template";
                begin

                    CurrPage.SetSelectionFilter(SeatingTemplate);
                    SeatingManagement.RowsAndSeatWizard(Rec."Entry No.", 3, SeatingTemplate);
                end;
            }
            group(Order)
            {
                Caption = 'Order';
                action("Move Up")
                {
                    ToolTip = 'Move area up.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Move Up';
                    Enabled = MoveUpEnabled;
                    Image = MoveUp;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Up';


                    trigger OnAction()
                    begin

                        MoveUp(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Move Down")
                {
                    ToolTip = 'Move area down.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Move Down';
                    Enabled = MoveDownEnabled;
                    Image = MoveDown;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Down';


                    trigger OnAction()
                    begin

                        MoveDown(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Indentation)
            {
                Caption = 'Indent';
                action(DoUnindent)
                {
                    ToolTip = 'Unindent area.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Unindent';
                    Image = DecreaseIndent;


                    trigger OnAction()
                    var
                        SeatingTemplate: Record "NPR TM Seating Template";
                    begin

                        UnIndent(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Action6014422)
                {
                    ToolTip = 'Indent area. ';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Indent';
                    Image = Indent; 


                    trigger OnAction()
                    begin

                        Indent(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AccentuatedPrice := false;
        UnitPrice := "Unit Price";
        if (UnitPrice = 0) then begin
            UnitPrice := SeatingManagement.GetInheritedUnitPice(Rec."Parent Entry No.");
            AccentuatedPrice := true;
        end;
    end;

    trigger OnInit()
    begin
        MoveDownEnabled := true;
        MoveUpEnabled := true;
    end;

    var
        SeatingManagement: Codeunit "NPR TM Seating Mgt.";
        AccentuatedPrice: Boolean;
        MoveUpEnabled: Boolean;
        MoveDownEnabled: Boolean;
        UPDATE_CHILDREN: Label 'Do you want to update all children?';
        UnitPrice: Decimal;

    local procedure DeleteNode()
    var
        SeatingTemplate: Record "NPR TM Seating Template";
    begin

        CurrPage.SetSelectionFilter(SeatingTemplate);
        if (SeatingTemplate.FindSet(true, true)) then begin
            repeat
                SeatingManagement.DeleteNode(SeatingTemplate."Entry No.");
            until (SeatingTemplate.Next() = 0);
        end;
    end;

    local procedure MoveUp(RecToMove: Record "NPR TM Seating Template")
    begin

        SeatingManagement.MoveNodeUp(RecToMove);
    end;

    local procedure MoveDown(RecToMove: Record "NPR TM Seating Template")
    begin

        SeatingManagement.MoveNodeDown(RecToMove);
    end;

    local procedure Indent(RecToIndent: Record "NPR TM Seating Template")
    begin

        SeatingManagement.IndentNode(RecToIndent);
    end;

    local procedure UnIndent(RecToUnIndent: Record "NPR TM Seating Template")
    begin

        SeatingManagement.UnIndentNode(RecToUnIndent);
    end;
}


﻿page 6014561 "NPR RP Data Items"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Data Items';
    PageType = Worksheet;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR RP Data Items";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Name;
                IndentationColumn = Rec.Level;
                IndentationControls = "Data Source";
                field("Data Source"; Rec."Data Source")
                {
                    Style = Strong;
                    StyleExpr = Rec.Level = 0;
                    ToolTip = 'Specifies the value of the Data Source field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Iteration Type"; Rec."Iteration Type")
                {

                    ToolTip = 'Specifies the value of the Iteration Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Key ID"; Rec."Key ID")
                {

                    ToolTip = 'Specifies the value of the Key ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Sort Order"; Rec."Sort Order")
                {

                    ToolTip = 'Specifies the value of the Sort Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Fields"; Rec."Total Fields")
                {

                    ToolTip = 'Specifies the value of the Total Fields field';
                    ApplicationArea = NPRRetail;
                }
                field("Field ID"; Rec."Field ID")
                {

                    ToolTip = 'Specifies the value of the Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Skip Template If Empty"; Rec."Skip Template If Empty")
                {

                    ToolTip = 'Specifies the value of the Skip Template If Empty field';
                    ApplicationArea = NPRRetail;
                }
                field("Skip Template If Not Empty"; Rec."Skip Template If Not Empty")
                {

                    ToolTip = 'Specifies the value of the Skip Template If Not Empty field';
                    ApplicationArea = NPRRetail;
                }
                field("Has Constraints"; Rec."Has Constraints")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Checked if the data item line has any constraints applied to it.';
                }
            }
            part(Control6014404; "NPR RP Data Item Links")
            {
                ShowFilter = false;
                SubPageLink = "Data Item Code" = FIELD(Code),
                              "Parent Line No." = FIELD("Parent Line No."),
                              "Child Line No." = FIELD("Line No."),
                              "Parent Table ID" = FIELD("Parent Table ID"),
                              "Table ID" = FIELD("Table ID");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Unindent)
            {
                Caption = 'Unindent';
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Unindent action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    UnindentLine()
                end;
            }
            action(Indent)
            {
                Caption = 'Indent';
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Indent action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    IndentLine()
                end;
            }
            action(Constraints)
            {
                Caption = 'Constraints';
                Image = FilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Data Item Constr.";
                RunPageLink = "Data Item Code" = FIELD(Code),
                              "Data Item Line No." = FIELD("Line No.");

                ToolTip = 'Executes the Constraints action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    internal procedure IndentLine()
    var
        DataItem: Record "NPR RP Data Items";
    begin
        CurrPage.SetSelectionFilter(DataItem);
        if DataItem.FindSet() then
            repeat
                DataItem.Validate(Level, DataItem.Level + 1);
                DataItem.Modify(true);
            until DataItem.Next() = 0;
    end;

    internal procedure UnindentLine()
    var
        DataItem: Record "NPR RP Data Items";
    begin
        CurrPage.SetSelectionFilter(DataItem);
        if DataItem.FindSet() then
            repeat
                if DataItem.Level > 0 then begin
                    DataItem.Validate(Level, DataItem.Level - 1);
                    DataItem.Modify(true);
                end;
            until DataItem.Next() = 0;
    end;

    internal procedure ShowItemDataLinks()
    var
        DataItemLinks: Page "NPR RP Data Item Links";
        DataItemLink: Record "NPR RP Data Item Links";
    begin
        DataItemLink.SetRange("Data Item Code", Rec.Code);
        DataItemLink.SetRange("Child Line No.", Rec."Line No.");
        DataItemLink.SetRange("Parent Line No.", Rec."Parent Line No.");
        DataItemLink.SetRange("Parent Table ID", Rec."Parent Table ID");
        DataItemLink.SetRange("Table ID", Rec."Table ID");
        DataItemLinks.SetTableView(DataItemLink);
        DataItemLinks.RunModal();
    end;
}


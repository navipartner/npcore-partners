page 6014561 "NPR RP Data Items"
{
    // NPR5.34/MMV /20170724 CASE 284505 Indent multiple.
    // NPR5.40/MMV /20180208 CASE 304639 Added new fields 30,31
    // NPR5.50/MMV /20190502 CASE 353588 Added support for distinct iteration.

    AutoSplitKey = true;
    Caption = 'Data Items';
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR RP Data Items";

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
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Rec.Level = 0;
                    ToolTip = 'Specifies the value of the Data Source field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Iteration Type"; Rec."Iteration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Iteration Type field';
                }
                field("Key ID"; Rec."Key ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key ID field';
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort Order field';
                }
                field("Total Fields"; Rec."Total Fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Fields field';
                }
                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field ID field';
                }
                field("Skip Template If Empty"; Rec."Skip Template If Empty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Template If Empty field';
                }
                field("Skip Template If Not Empty"; Rec."Skip Template If Not Empty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Template If Not Empty field';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Unindent action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Indent action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Constraints action';
            }
        }
    }

    procedure IndentLine()
    var
        DataItem: Record "NPR RP Data Items";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // VALIDATE(Level, Level+1);
        // MODIFY(TRUE);

        CurrPage.SetSelectionFilter(DataItem);
        if DataItem.FindSet() then
            repeat
                DataItem.Validate(Level, DataItem.Level + 1);
                DataItem.Modify(true);
            until DataItem.Next() = 0;
        //+NPR5.34 [284505]
    end;

    procedure UnindentLine()
    var
        DataItem: Record "NPR RP Data Items";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // IF Level > 0 THEN
        //  VALIDATE(Level, Level-1);
        // MODIFY(TRUE);

        CurrPage.SetSelectionFilter(DataItem);
        if DataItem.FindSet() then
            repeat
                if DataItem.Level > 0 then begin
                    DataItem.Validate(Level, DataItem.Level - 1);
                    DataItem.Modify(true);
                end;
            until DataItem.Next() = 0;
        //+NPR5.34 [284505]
    end;

    procedure ShowItemDataLinks()
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


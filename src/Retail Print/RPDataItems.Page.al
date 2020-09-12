page 6014561 "NPR RP Data Items"
{
    // NPR5.34/MMV /20170724 CASE 284505 Indent multiple.
    // NPR5.40/MMV /20180208 CASE 304639 Added new fields 30,31
    // NPR5.50/MMV /20190502 CASE 353588 Added support for distinct iteration.

    AutoSplitKey = true;
    Caption = 'Data Items';
    PageType = Worksheet;
    ShowFilter = false;
    SourceTable = "NPR RP Data Items";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Name;
                IndentationColumn = Level;
                IndentationControls = "Data Source";
                field("Data Source"; "Data Source")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Level = 0;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Iteration Type"; "Iteration Type")
                {
                    ApplicationArea = All;
                }
                field("Key ID"; "Key ID")
                {
                    ApplicationArea = All;
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
                }
                field("Total Fields"; "Total Fields")
                {
                    ApplicationArea = All;
                }
                field("Field ID"; "Field ID")
                {
                    ApplicationArea = All;
                }
                field("Skip Template If Empty"; "Skip Template If Empty")
                {
                    ApplicationArea = All;
                }
                field("Skip Template If Not Empty"; "Skip Template If Not Empty")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Data Item Constr.";
                RunPageLink = "Data Item Code" = FIELD(Code),
                              "Data Item Line No." = FIELD("Line No.");
                ApplicationArea = All;
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
        if DataItem.FindSet then
            repeat
                DataItem.Validate(Level, DataItem.Level + 1);
                DataItem.Modify(true);
            until DataItem.Next = 0;
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
        if DataItem.FindSet then
            repeat
                if DataItem.Level > 0 then begin
                    DataItem.Validate(Level, DataItem.Level - 1);
                    DataItem.Modify(true);
                end;
            until DataItem.Next = 0;
        //+NPR5.34 [284505]
    end;

    procedure ShowItemDataLinks()
    var
        DataItemLinks: Page "NPR RP Data Item Links";
        DataItemLink: Record "NPR RP Data Item Links";
    begin
        DataItemLink.SetRange("Data Item Code", Code);
        DataItemLink.SetRange("Child Line No.", "Line No.");
        DataItemLink.SetRange("Parent Line No.", "Parent Line No.");
        DataItemLink.SetRange("Parent Table ID", "Parent Table ID");
        DataItemLink.SetRange("Table ID", "Table ID");
        DataItemLinks.SetTableView(DataItemLink);
        DataItemLinks.RunModal;
    end;
}


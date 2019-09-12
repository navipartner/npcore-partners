page 6014561 "RP Data Items"
{
    // NPR5.34/MMV /20170724 CASE 284505 Indent multiple.
    // NPR5.40/MMV /20180208 CASE 304639 Added new fields 30,31
    // NPR5.50/MMV /20190502 CASE 353588 Added support for distinct iteration.

    AutoSplitKey = true;
    Caption = 'Data Items';
    PageType = Worksheet;
    ShowFilter = false;
    SourceTable = "RP Data Items";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Name;
                IndentationColumn = Level;
                IndentationControls = "Data Source";
                field("Data Source";"Data Source")
                {
                    Style = Strong;
                    StyleExpr = Level = 0;
                }
                field(Name;Name)
                {
                }
                field("Iteration Type";"Iteration Type")
                {
                }
                field("Key ID";"Key ID")
                {
                }
                field("Sort Order";"Sort Order")
                {
                }
                field("Total Fields";"Total Fields")
                {
                }
                field("Field ID";"Field ID")
                {
                }
                field("Skip Template If Empty";"Skip Template If Empty")
                {
                }
                field("Skip Template If Not Empty";"Skip Template If Not Empty")
                {
                }
            }
            part(Control6014404;"RP Data Item Links")
            {
                ShowFilter = false;
                SubPageLink = "Data Item Code"=FIELD(Code),
                              "Parent Line No."=FIELD("Parent Line No."),
                              "Child Line No."=FIELD("Line No."),
                              "Parent Table ID"=FIELD("Parent Table ID"),
                              "Table ID"=FIELD("Table ID");
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
                RunObject = Page "RP Data Item Constraints";
                RunPageLink = "Data Item Code"=FIELD(Code),
                              "Data Item Line No."=FIELD("Line No.");
            }
        }
    }

    procedure IndentLine()
    var
        DataItem: Record "RP Data Items";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // VALIDATE(Level, Level+1);
        // MODIFY(TRUE);

        CurrPage.SetSelectionFilter(DataItem);
        if DataItem.FindSet then repeat
          DataItem.Validate(Level, DataItem.Level+1);
          DataItem.Modify(true);
        until DataItem.Next = 0;
        //+NPR5.34 [284505]
    end;

    procedure UnindentLine()
    var
        DataItem: Record "RP Data Items";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // IF Level > 0 THEN
        //  VALIDATE(Level, Level-1);
        // MODIFY(TRUE);

        CurrPage.SetSelectionFilter(DataItem);
        if DataItem.FindSet then repeat
          if DataItem.Level > 0 then begin
            DataItem.Validate(Level, DataItem.Level-1);
            DataItem.Modify(true);
          end;
        until DataItem.Next = 0;
        //+NPR5.34 [284505]
    end;

    procedure ShowItemDataLinks()
    var
        DataItemLinks: Page "RP Data Item Links";
        DataItemLink: Record "RP Data Item Links";
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


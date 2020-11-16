page 6014630 "NPR RP Templ. Line Designer"
{
    // NPR5.32/MMV /20170424 CASE 241995 Retail Print 2.0
    // NPR5.34/MMV /20170724 CASE 284505 Indent multiple lines at once.
    // NPR5.51/MMV /20190712 CASE 360972 Added field 70

    AutoSplitKey = true;
    Caption = 'Template Line Designer';
    PageType = ListPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR RP Template Line";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                IndentationColumn = Level;
                IndentationControls = Type;
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = "Type" = 1;
                }
                field("Type Option"; "Type Option")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field("Prefix Next Line"; "Prefix Next Line")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Data Item Name"; "Data Item Name")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = "Type" = 1;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Operator; Operator)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Field 2 Name"; "Field 2 Name")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Attribute; Attribute)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Template Column No."; "Template Column No.")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Postfix; Postfix)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Pad Char"; "Pad Char")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Align; Align)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Bold; Bold)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Width; Width)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Height; Height)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field("Start Char"; "Start Char")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Max Length"; "Max Length")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Underline; Underline)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Blank Zero"; "Blank Zero")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Skip If Empty"; "Skip If Empty")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Comments; Comments)
                {
                    ApplicationArea = All;
                }
                field("Processing Codeunit"; "Processing Codeunit")
                {
                    ApplicationArea = All;
                }
                field("Processing Function ID"; "Processing Function ID")
                {
                    ApplicationArea = All;
                }
                field("Processing Function Parameter"; "Processing Function Parameter")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    procedure IndentLine()
    var
        TemplateLine: Record "NPR RP Template Line";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // VALIDATE(Level,Level+1);
        // MODIFY(TRUE);
        CurrPage.SetSelectionFilter(TemplateLine);
        if TemplateLine.FindSet then
            repeat
                TemplateLine.Validate(Level, TemplateLine.Level + 1);
                TemplateLine.Modify(true);
            until TemplateLine.Next = 0;
        //+NPR5.34 [284505]
    end;

    procedure UnindentLine()
    var
        TemplateLine: Record "NPR RP Template Line";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // IF Level > 0 THEN
        //  VALIDATE(Level,Level-1);
        // MODIFY(TRUE);

        CurrPage.SetSelectionFilter(TemplateLine);
        if TemplateLine.FindSet then
            repeat
                if TemplateLine.Level > 0 then begin
                    TemplateLine.Validate(Level, TemplateLine.Level - 1);
                    TemplateLine.Modify(true);
                end;
            until TemplateLine.Next = 0;
        //+NPR5.34 [284505]
    end;
}


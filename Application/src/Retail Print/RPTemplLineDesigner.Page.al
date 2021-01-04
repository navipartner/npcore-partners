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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Type Option"; "Type Option")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    ToolTip = 'Specifies the value of the Type Option field';
                }
                field("Prefix Next Line"; "Prefix Next Line")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix Next Line field';
                }
                field("Data Item Name"; "Data Item Name")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field(Operator; Operator)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Operator field';
                }
                field("Field 2 Name"; "Field 2 Name")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Field 2 Name field';
                }
                field(Attribute; Attribute)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Attribute field';
                }
                field("Template Column No."; "Template Column No.")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    ToolTip = 'Specifies the value of the Column No. field';
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix field';
                }
                field(Postfix; Postfix)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Postfix field';
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Default Value field';
                }
                field("Pad Char"; "Pad Char")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    ToolTip = 'Specifies the value of the Pad Char field';
                }
                field(Align; Align)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    ToolTip = 'Specifies the value of the Align field';
                }
                field(Bold; Bold)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Bold field';
                }
                field(Width; Width)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    ToolTip = 'Specifies the value of the Barcode Size/Width field';
                }
                field(Height; Height)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    ToolTip = 'Specifies the value of the Height field';
                }
                field("Start Char"; "Start Char")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Start Char field';
                }
                field("Max Length"; "Max Length")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Underline; Underline)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Underline field';
                }
                field("Blank Zero"; "Blank Zero")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Blank Zero field';
                }
                field("Skip If Empty"; "Skip If Empty")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                    ToolTip = 'Specifies the value of the Skip If Empty field';
                }
                field(Comments; Comments)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comments field';
                }
                field("Processing Codeunit"; "Processing Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Codeunit field';
                }
                field("Processing Function ID"; "Processing Function ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Function ID field';
                }
                field("Processing Function Parameter"; "Processing Function Parameter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Function Parameter field';
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


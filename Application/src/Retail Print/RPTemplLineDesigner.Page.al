page 6014630 "NPR RP Templ. Line Designer"
{
    // NPR5.32/MMV /20170424 CASE 241995 Retail Print 2.0
    // NPR5.34/MMV /20170724 CASE 284505 Indent multiple lines at once.
    // NPR5.51/MMV /20190712 CASE 360972 Added field 70

    AutoSplitKey = true;
    Caption = 'Template Line Designer';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR RP Template Line";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Type;
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Type Option"; Rec."Type Option")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Type Option field';
                }
                field("Prefix Next Line"; Rec."Prefix Next Line")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix Next Line field';
                }
                field("Data Item Name"; Rec."Data Item Name")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field(Operator; Rec.Operator)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Operator field';
                }
                field("Field 2 Name"; Rec."Field 2 Name")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Field 2 Name field';
                }
                field(Attribute; Rec.Attribute)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Attribute field';
                }
                field("Template Column No."; Rec."Template Column No.")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Column No. field';
                }
                field(Prefix; Rec.Prefix)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix field';
                }
                field(Postfix; Rec.Postfix)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Postfix field';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Default Value field';
                }
                field("Pad Char"; Rec."Pad Char")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Pad Char field';
                }
                field(Align; Rec.Align)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Align field';
                }
                field(Bold; Rec.Bold)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Bold field';
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Barcode Size/Width field';
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Height field';
                }
                field("Start Char"; Rec."Start Char")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Start Char field';
                }
                field("Max Length"; Rec."Max Length")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Underline; Rec.Underline)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Underline field';
                }
                field("Blank Zero"; Rec."Blank Zero")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Blank Zero field';
                }
                field("Skip If Empty"; Rec."Skip If Empty")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Skip If Empty field';
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comments field';
                }
                field("Processing Codeunit"; Rec."Processing Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Codeunit field';
                }
                field("Processing Function ID"; Rec."Processing Function ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Function ID field';
                }
                field("Processing Function Parameter"; Rec."Processing Function Parameter")
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
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // VALIDATE(Level,Level+1);
        // MODIFY(TRUE);
        CurrPage.SetSelectionFilter(RPTemplateLine);
        if RPTemplateLine.FindSet() then
            repeat
                RPTemplateLine.Validate(Level, RPTemplateLine.Level + 1);
                RPTemplateLine.Modify(true);
            until RPTemplateLine.Next() = 0;
        //+NPR5.34 [284505]
    end;

    procedure UnindentLine()
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        //-NPR5.34 [284505]
        // FIND;
        // IF Level > 0 THEN
        //  VALIDATE(Level,Level-1);
        // MODIFY(TRUE);

        CurrPage.SetSelectionFilter(RPTemplateLine);
        if RPTemplateLine.FindSet() then
            repeat
                if RPTemplateLine.Level > 0 then begin
                    RPTemplateLine.Validate(Level, RPTemplateLine.Level - 1);
                    RPTemplateLine.Modify(true);
                end;
            until RPTemplateLine.Next() = 0;
        //+NPR5.34 [284505]
    end;
}


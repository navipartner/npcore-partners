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
    ApplicationArea = NPRRetail;

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

                    Style = Strong;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Type Option"; Rec."Type Option")
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Type Option field';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Next Line"; Rec."Prefix Next Line")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix Next Line field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Name"; Rec."Data Item Name")
                {

                    Style = Strong;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Operator; Rec.Operator)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Operator field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 2 Name"; Rec."Field 2 Name")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Field 2 Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Attribute; Rec.Attribute)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Attribute field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Column No."; Rec."Template Column No.")
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Column No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Prefix; Rec.Prefix)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field(Postfix; Rec.Postfix)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Postfix field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Value"; Rec."Default Value")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Default Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Pad Char"; Rec."Pad Char")
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Pad Char field';
                    ApplicationArea = NPRRetail;
                }
                field(Align; Rec.Align)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Align field';
                    ApplicationArea = NPRRetail;
                }
                field(Bold; Rec.Bold)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Bold field';
                    ApplicationArea = NPRRetail;
                }
                field(Width; Rec.Width)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Barcode Size/Width field';
                    ApplicationArea = NPRRetail;
                }
                field(Height; Rec.Height)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Height field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Char"; Rec."Start Char")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Start Char field';
                    ApplicationArea = NPRRetail;
                }
                field("Max Length"; Rec."Max Length")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Max Length field';
                    ApplicationArea = NPRRetail;
                }
                field(Underline; Rec.Underline)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Underline field';
                    ApplicationArea = NPRRetail;
                }
                field("Blank Zero"; Rec."Blank Zero")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Blank Zero field';
                    ApplicationArea = NPRRetail;
                }
                field("Skip If Empty"; Rec."Skip If Empty")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Skip If Empty field';
                    ApplicationArea = NPRRetail;
                }
                field(Comments; Rec.Comments)
                {

                    ToolTip = 'Specifies the value of the Comments field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Codeunit"; Rec."Processing Codeunit")
                {

                    ToolTip = 'Specifies the value of the Processing Codeunit field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Function ID"; Rec."Processing Function ID")
                {

                    ToolTip = 'Specifies the value of the Processing Function ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Function Parameter"; Rec."Processing Function Parameter")
                {

                    ToolTip = 'Specifies the value of the Processing Function Parameter field';
                    ApplicationArea = NPRRetail;
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


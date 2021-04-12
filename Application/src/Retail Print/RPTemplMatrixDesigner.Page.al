page 6014637 "NPR RP Templ. Matrix Designer"
{
    // NPR4.02/MMV/20150223 CASE 204483 Made "Field Text Start" visible and changed the Caption.
    // NPR4.10/MMV/20150506 CASE 167059 Added field "Print With Next".
    // NPR4.10/MMV720150513 CASE 207985 Added field Attribute
    // NPR4.14/MMV/20150825 CASE 181190 Added field 43 : "Next Record"
    // NPR4.15.01/MMV/20150918 CASE 181190 Added field 44 : "Master Record No."
    //                                     Removed field 43.
    // NPR5.32/MMV /20170424 CASE 241995 Retail Print 2.0
    // NPR5.44/MMV /20180706 CASE 315362 Added field 60
    // NPR5.46/MMV /20180911 CASE 314067 Added field 52
    // NPR5.51/MMV /20190712 CASE 360972 Added field 70

    AutoSplitKey = true;
    Caption = 'Template Matrix Designer';
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
                ShowCaption = false;
                field("Type Option"; Rec."Type Option")
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Type Option field';
                }
                field(X; Rec.X)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    Width = 4;
                    ToolTip = 'Specifies the value of the X field';
                }
                field(Y; Rec.Y)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    Width = 4;
                    ToolTip = 'Specifies the value of the Y field';
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
                field("Default Value Record Required"; Rec."Default Value Record Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only Fill Default Value On Data field';
                }
                field(Align; Rec.Align)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Align field';
                }
                field(Rotation; Rec.Rotation)
                {
                    ApplicationArea = All;
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Rotation field';
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
                field("Root Record No."; Rec."Root Record No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Root Record No. field';
                }
                field("Data Item Record No."; Rec."Data Item Record No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Data Item Record No. field';
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
}


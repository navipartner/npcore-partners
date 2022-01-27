page 6014637 "NPR RP Templ. Matrix Designer"
{
    Extensible = False;
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

    ShowFilter = false;
    SourceTable = "NPR RP Template Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Type Option"; Rec."Type Option")
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Type Option field';
                    ApplicationArea = NPRRetail;
                }
                field(X; Rec.X)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    Width = 4;
                    ToolTip = 'Specifies the value of the X field';
                    ApplicationArea = NPRRetail;
                }
                field(Y; Rec.Y)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    Width = 4;
                    ToolTip = 'Specifies the value of the Y field';
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
                field("Default Value Record Required"; Rec."Default Value Record Required")
                {

                    ToolTip = 'Specifies the value of the Only Fill Default Value On Data field';
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
                field(Rotation; Rec.Rotation)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Rotation field';
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
                field("Root Record No."; Rec."Root Record No.")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Root Record No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Record No."; Rec."Data Item Record No.")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Data Item Record No. field';
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
}


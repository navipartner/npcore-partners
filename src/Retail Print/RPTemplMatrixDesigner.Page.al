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
    ShowFilter = false;
    SourceTable = "NPR RP Template Line";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Type Option"; "Type Option")
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(X; X)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    Width = 4;
                }
                field(Y; Y)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    Width = 4;
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
                field("Default Value Record Required"; "Default Value Record Required")
                {
                    ApplicationArea = All;
                }
                field(Align; Align)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Rotation; Rotation)
                {
                    ApplicationArea = All;
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
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
                field("Root Record No."; "Root Record No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Data Item Record No."; "Data Item Record No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
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
}


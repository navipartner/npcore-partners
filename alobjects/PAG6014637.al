page 6014637 "RP Template Matrix Designer"
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

    AutoSplitKey = true;
    Caption = 'Template Matrix Designer';
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "RP Template Line";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Type Option";"Type Option")
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(X;X)
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    Width = 4;
                }
                field(Y;Y)
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                    Width = 4;
                }
                field("Prefix Next Line";"Prefix Next Line")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Data Item Name";"Data Item Name")
                {
                    Style = Strong;
                    StyleExpr = "Type" = 1;
                }
                field("Field Name";"Field Name")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Operator;Operator)
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Field 2 Name";"Field 2 Name")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Attribute;Attribute)
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Prefix;Prefix)
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field(Postfix;Postfix)
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Default Value";"Default Value")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Default Value Record Required";"Default Value Record Required")
                {
                }
                field(Align;Align)
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Rotation;Rotation)
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Width;Width)
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field(Height;Height)
                {
                    Enabled = NOT ("Prefix Next Line" OR ("Type" = 1));
                    Style = Subordinate;
                    StyleExpr = "Prefix Next Line" OR ("Type" = 1);
                }
                field("Start Char";"Start Char")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Max Length";"Max Length")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Blank Zero";"Blank Zero")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Skip If Empty";"Skip If Empty")
                {
                    Enabled = NOT ("Type" = 1);
                    Style = Subordinate;
                    StyleExpr = "Type" = 1;
                }
                field("Root Record No.";"Root Record No.")
                {
                    BlankZero = true;
                }
                field("Data Item Record No.";"Data Item Record No.")
                {
                    BlankZero = true;
                }
                field(Comments;Comments)
                {
                }
                field("Processing Codeunit";"Processing Codeunit")
                {
                }
                field("Processing Function ID";"Processing Function ID")
                {
                }
            }
        }
    }

    actions
    {
    }
}


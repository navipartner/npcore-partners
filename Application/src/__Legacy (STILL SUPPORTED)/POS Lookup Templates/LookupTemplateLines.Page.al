page 6014672 "NPR Lookup Template Lines"
{
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.

    Caption = 'Lookup Template Lines';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Lookup Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Row No."; "Row No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Row No. field';
                }
                field("Col No."; "Col No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Col No. field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field(Class; Class)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Class field';
                }
                field("Caption Type"; "Caption Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Caption Type field';
                }
                field("Caption Text"; "Caption Text")
                {
                    ApplicationArea = All;
                    Enabled = "Caption Type" = 0;
                    ToolTip = 'Specifies the value of the Caption Text field';
                }
                field("Caption Table No."; "Caption Table No.")
                {
                    ApplicationArea = All;
                    Enabled = ("Caption Type" = 1) OR ("Caption Type" = 2);
                    ToolTip = 'Specifies the value of the Caption Table No. field';
                }
                field("Caption Table Name"; "Caption Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Caption Table Name field';
                }
                field("Caption Field No."; "Caption Field No.")
                {
                    ApplicationArea = All;
                    Enabled = ("Caption Type" = 1) OR ("Caption Type" = 2);
                    ToolTip = 'Specifies the value of the Caption Field No. field';
                }
                field("Caption Field Name"; "Caption Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Caption Field Name field';
                }
                field("Related Table No."; "Related Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Related Table No. field';
                }
                field("Related Table Name"; "Related Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Related Table Name field';
                }
                field("Related Field No."; "Related Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Related Field No. field';
                }
                field("Text Align"; "Text Align")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text Align field';
                }
                field("Font Size (pt)"; "Font Size (pt)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Font Size (pt) field';
                }
                field("Width (CSS)"; "Width (CSS)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Width (CSS) field';
                }
                field("Number Format"; "Number Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number Format field';
                }
                field(Searchable; Searchable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Searchable field';
                }
            }
        }
    }

    actions
    {
    }
}


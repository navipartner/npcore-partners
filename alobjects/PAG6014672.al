page 6014672 "Lookup Template Lines"
{
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.

    Caption = 'Lookup Template Lines';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Lookup Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Row No."; "Row No.")
                {
                    ApplicationArea = All;
                }
                field("Col No."; "Col No.")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field(Class; Class)
                {
                    ApplicationArea = All;
                }
                field("Caption Type"; "Caption Type")
                {
                    ApplicationArea = All;
                }
                field("Caption Text"; "Caption Text")
                {
                    ApplicationArea = All;
                    Enabled = "Caption Type" = 0;
                }
                field("Caption Table No."; "Caption Table No.")
                {
                    ApplicationArea = All;
                    Enabled = ("Caption Type" = 1) OR ("Caption Type" = 2);
                }
                field("Caption Table Name"; "Caption Table Name")
                {
                    ApplicationArea = All;
                }
                field("Caption Field No."; "Caption Field No.")
                {
                    ApplicationArea = All;
                    Enabled = ("Caption Type" = 1) OR ("Caption Type" = 2);
                }
                field("Caption Field Name"; "Caption Field Name")
                {
                    ApplicationArea = All;
                }
                field("Related Table No."; "Related Table No.")
                {
                    ApplicationArea = All;
                }
                field("Related Table Name"; "Related Table Name")
                {
                    ApplicationArea = All;
                }
                field("Related Field No."; "Related Field No.")
                {
                    ApplicationArea = All;
                }
                field("Text Align"; "Text Align")
                {
                    ApplicationArea = All;
                }
                field("Font Size (pt)"; "Font Size (pt)")
                {
                    ApplicationArea = All;
                }
                field("Width (CSS)"; "Width (CSS)")
                {
                    ApplicationArea = All;
                }
                field("Number Format"; "Number Format")
                {
                    ApplicationArea = All;
                }
                field(Searchable; Searchable)
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


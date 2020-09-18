page 6060085 "NPR MCS Recomm. Lines"
{
    // NPR5.30/BR  /20170228  CASE 252646 Object Created

    Caption = 'MCS Recommendations Lines';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MCS Recommendations Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Model No."; "Model No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Log Entry No."; "Log Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Seed Item No."; "Seed Item No.")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Rating; Rating)
                {
                    ApplicationArea = All;
                    AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
                    AutoFormatType = 10;
                }
                field("Date Time"; "Date Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}


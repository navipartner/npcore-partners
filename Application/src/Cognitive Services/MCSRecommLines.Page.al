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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Model No."; "Model No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Model No. field';
                }
                field("Log Entry No."; "Log Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Log Entry No. field';
                }
                field("Seed Item No."; "Seed Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seed Item No. field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Line No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Register No. field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Rating; Rating)
                {
                    ApplicationArea = All;
                    AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
                    AutoFormatType = 10;
                    ToolTip = 'Specifies the value of the Rating field';
                }
                field("Date Time"; "Date Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Date Time field';
                }
            }
        }
    }

    actions
    {
    }
}


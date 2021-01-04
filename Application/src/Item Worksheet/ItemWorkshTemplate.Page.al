page 6060058 "NPR Item Worksh. Template"
{
    // NPR5.25\BR  \20160804  CASE 246088 Object Created
    // NPR5.29\BR \20161215 CASE 261123 Added field "Match by Item No. Only"
    // NPR5.35\BR \20170821 CASE 268786 Added field "Leave Skipped line on Register"
    // NPR5.42/RA/20180507  CASE 310681 Added fiedl "Don't Apply Internal Barcode"

    Caption = 'Item Worksheet Template';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Item Worksh. Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Register Lines"; "Register Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Register Lines field';
                }
                field("Delete Processed Lines"; "Delete Processed Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Processed Lines field';

                    trigger OnValidate()
                    begin
                        //-NPR5.35 [268786]
                        SetFieldsEditable;
                        //+NPR5.35 [268786]
                    end;
                }
                field("Leave Skipped Line on Register"; "Leave Skipped Line on Register")
                {
                    ApplicationArea = All;
                    Editable = LeaveSkippedLineonRegisterEditable;
                    ToolTip = 'Specifies the value of the Leave Skipped Line on Register field';
                }
                field("Sales Price Handling"; "Sales Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Handling field';
                }
                field("Purchase Price Handling"; "Purchase Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Handling field';
                }
                field("Combine Variants to Item by"; "Combine Variants to Item by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Combine Variants to Item by field';
                }
                field("Match by Item No. Only"; "Match by Item No. Only")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Match by Item No. Only field';
                }
                field("Delete Unvalidated Duplicates"; "Delete Unvalidated Duplicates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Unvalidated Duplicates field';
                }
                field("Do not Apply Internal Barcode"; "Do not Apply Internal Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do not apply Internal Barcode field';
                }
            }
            group(Numbering)
            {
                field("Item No. Creation by"; "Item No. Creation by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Creation by field';
                }
                field("Item No. Prefix"; "Item No. Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Prefix field';
                }
                field("Prefix Code"; "Prefix Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix Code field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
            }
            group(Validation)
            {
                field("Error Handling"; "Error Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Handling field';
                }
                field("Test Validation"; "Test Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Validation field';
                }
            }
            group(Barcodes)
            {
                field("Create Internal Barcodes"; "Create Internal Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Internal Barcodes field';
                }
                field("Create Vendor  Barcodes"; "Create Vendor  Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Vendor  Barcodes field';
                }
            }
            group("Web Integration")
            {
                field("Allow Web Service Update"; "Allow Web Service Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Web Service Update field';
                }
                field("Item Info Query Name"; "Item Info Query Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Name field';
                }
                field("Item Info Query Type"; "Item Info Query Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Type field';
                }
                field("Item Info Query By"; "Item Info Query By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query By field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.35 [268786]
        SetFieldsEditable;
        //+NPR5.35 [268786]
    end;

    var
        LeaveSkippedLineonRegisterEditable: Boolean;

    local procedure SetFieldsEditable()
    begin
        //-NPR5.35 [268786]
        LeaveSkippedLineonRegisterEditable := "Delete Processed Lines";
        //+NPR5.35 [268786]
    end;
}


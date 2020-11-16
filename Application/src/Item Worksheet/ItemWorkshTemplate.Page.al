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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Register Lines"; "Register Lines")
                {
                    ApplicationArea = All;
                }
                field("Delete Processed Lines"; "Delete Processed Lines")
                {
                    ApplicationArea = All;

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
                }
                field("Sales Price Handling"; "Sales Price Handling")
                {
                    ApplicationArea = All;
                }
                field("Purchase Price Handling"; "Purchase Price Handling")
                {
                    ApplicationArea = All;
                }
                field("Combine Variants to Item by"; "Combine Variants to Item by")
                {
                    ApplicationArea = All;
                }
                field("Match by Item No. Only"; "Match by Item No. Only")
                {
                    ApplicationArea = All;
                }
                field("Delete Unvalidated Duplicates"; "Delete Unvalidated Duplicates")
                {
                    ApplicationArea = All;
                }
                field("Do not Apply Internal Barcode"; "Do not Apply Internal Barcode")
                {
                    ApplicationArea = All;
                }
            }
            group(Numbering)
            {
                field("Item No. Creation by"; "Item No. Creation by")
                {
                    ApplicationArea = All;
                }
                field("Item No. Prefix"; "Item No. Prefix")
                {
                    ApplicationArea = All;
                }
                field("Prefix Code"; "Prefix Code")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
            }
            group(Validation)
            {
                field("Error Handling"; "Error Handling")
                {
                    ApplicationArea = All;
                }
                field("Test Validation"; "Test Validation")
                {
                    ApplicationArea = All;
                }
            }
            group(Barcodes)
            {
                field("Create Internal Barcodes"; "Create Internal Barcodes")
                {
                    ApplicationArea = All;
                }
                field("Create Vendor  Barcodes"; "Create Vendor  Barcodes")
                {
                    ApplicationArea = All;
                }
            }
            group("Web Integration")
            {
                field("Allow Web Service Update"; "Allow Web Service Update")
                {
                    ApplicationArea = All;
                }
                field("Item Info Query Name"; "Item Info Query Name")
                {
                    ApplicationArea = All;
                }
                field("Item Info Query Type"; "Item Info Query Type")
                {
                    ApplicationArea = All;
                }
                field("Item Info Query By"; "Item Info Query By")
                {
                    ApplicationArea = All;
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


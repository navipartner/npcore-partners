page 6060058 "Item Worksheet Template"
{
    // NPR5.25\BR  \20160804  CASE 246088 Object Created
    // NPR5.29\BR \20161215 CASE 261123 Added field "Match by Item No. Only"
    // NPR5.35\BR \20170821 CASE 268786 Added field "Leave Skipped line on Register"
    // NPR5.42/RA/20180507  CASE 310681 Added fiedl "Don't Apply Internal Barcode"

    Caption = 'Item Worksheet Template';
    PageType = Card;
    SourceTable = "Item Worksheet Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
                }
                field("Register Lines";"Register Lines")
                {
                }
                field("Delete Processed Lines";"Delete Processed Lines")
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.35 [268786]
                        SetFieldsEditable;
                        //+NPR5.35 [268786]
                    end;
                }
                field("Leave Skipped Line on Register";"Leave Skipped Line on Register")
                {
                    Editable = LeaveSkippedLineonRegisterEditable;
                }
                field("Sales Price Handling";"Sales Price Handling")
                {
                }
                field("Purchase Price Handling";"Purchase Price Handling")
                {
                }
                field("Combine Variants to Item by";"Combine Variants to Item by")
                {
                }
                field("Match by Item No. Only";"Match by Item No. Only")
                {
                }
                field("Delete Unvalidated Duplicates";"Delete Unvalidated Duplicates")
                {
                }
                field("Do not Apply Internal Barcode";"Do not Apply Internal Barcode")
                {
                }
            }
            group(Numbering)
            {
                field("Item No. Creation by";"Item No. Creation by")
                {
                }
                field("Item No. Prefix";"Item No. Prefix")
                {
                }
                field("Prefix Code";"Prefix Code")
                {
                }
                field("No. Series";"No. Series")
                {
                }
            }
            group(Validation)
            {
                field("Error Handling";"Error Handling")
                {
                }
                field("Test Validation";"Test Validation")
                {
                }
            }
            group(Barcodes)
            {
                field("Create Internal Barcodes";"Create Internal Barcodes")
                {
                }
                field("Create Vendor  Barcodes";"Create Vendor  Barcodes")
                {
                }
            }
            group("Web Integration")
            {
                field("Allow Web Service Update";"Allow Web Service Update")
                {
                }
                field("Item Info Query Name";"Item Info Query Name")
                {
                }
                field("Item Info Query Type";"Item Info Query Type")
                {
                }
                field("Item Info Query By";"Item Info Query By")
                {
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


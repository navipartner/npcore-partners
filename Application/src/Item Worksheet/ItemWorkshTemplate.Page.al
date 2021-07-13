page 6060058 "NPR Item Worksh. Template"
{
    Caption = 'Item Worksheet Template';
    PageType = Card;
    SourceTable = "NPR Item Worksh. Template";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field("Register Lines"; Rec."Register Lines")
                {

                    ToolTip = 'Specifies the value of the Register Lines field.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {

                    ToolTip = 'Specifies the value of the Delete Processed Lines field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetFieldsEditable();
                    end;
                }
                field("Leave Skipped Line on Register"; Rec."Leave Skipped Line on Register")
                {

                    Editable = LeaveSkippedLineonRegisterEditable;
                    ToolTip = 'Specifies the value of the Leave Skipped Line on Register field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Handling"; Rec."Sales Price Handling")
                {

                    ToolTip = 'Specifies the value of the Sales Price Handling field.';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handling")
                {

                    ToolTip = 'Specifies the value of the Purchase Price Handling field.';
                    ApplicationArea = NPRRetail;
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {

                    ToolTip = 'Specifies the value of the Combine Variants to Item by field.';
                    ApplicationArea = NPRRetail;
                }
                field("Match by Item No. Only"; Rec."Match by Item No. Only")
                {

                    ToolTip = 'Specifies the value of the Match by Item No. Only field.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Unvalidated Duplicates"; Rec."Delete Unvalidated Duplicates")
                {

                    ToolTip = 'Specifies the value of the Delete Unvalidated Duplicates field.';
                    ApplicationArea = NPRRetail;
                }
                field("Do not Apply Internal Barcode"; Rec."Do not Apply Internal Barcode")
                {

                    ToolTip = 'Specifies the value of the Do not apply Internal Barcode field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Numbering)
            {
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {

                    ToolTip = 'Specifies the value of the Item No. Creation by field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {

                    ToolTip = 'Specifies the value of the Item No. Prefix field.';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Code"; Rec."Prefix Code")
                {

                    ToolTip = 'Specifies the value of the Prefix Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Validation)
            {
                field("Error Handling"; Rec."Error Handling")
                {

                    ToolTip = 'Specifies the value of the Error Handling field.';
                    ApplicationArea = NPRRetail;
                }
                field("Test Validation"; Rec."Test Validation")
                {

                    ToolTip = 'Specifies the value of the Test Validation field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Barcodes)
            {
                field("Create Internal Barcodes"; Rec."Create Internal Barcodes")
                {

                    ToolTip = 'Specifies the value of the Create Internal Barcodes field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {

                    ToolTip = 'Specifies the value of the Create Vendor  Barcodes field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Web Integration")
            {
                field("Allow Web Service Update"; Rec."Allow Web Service Update")
                {

                    ToolTip = 'Specifies the value of the Allow Web Service Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query Name"; Rec."Item Info Query Name")
                {

                    ToolTip = 'Specifies the value of the Item Info Query Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query Type"; Rec."Item Info Query Type")
                {

                    ToolTip = 'Specifies the value of the Item Info Query Type field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Info Query By"; Rec."Item Info Query By")
                {

                    ToolTip = 'Specifies the value of the Item Info Query By field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        SetFieldsEditable();
    end;

    var
        LeaveSkippedLineonRegisterEditable: Boolean;

    local procedure SetFieldsEditable()
    begin
        LeaveSkippedLineonRegisterEditable := Rec."Delete Processed Lines";
    end;
}


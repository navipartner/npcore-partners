page 6060058 "NPR Item Worksh. Template"
{
    Caption = 'Item Worksheet Template';
    PageType = Card;
    SourceTable = "NPR Item Worksh. Template";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Register Lines"; Rec."Register Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Register Lines field.';
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Processed Lines field.';

                    trigger OnValidate()
                    begin
                        SetFieldsEditable();
                    end;
                }
                field("Leave Skipped Line on Register"; Rec."Leave Skipped Line on Register")
                {
                    ApplicationArea = All;
                    Editable = LeaveSkippedLineonRegisterEditable;
                    ToolTip = 'Specifies the value of the Leave Skipped Line on Register field.';
                }
                field("Sales Price Handling"; Rec."Sales Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Handling field.';
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Handling field.';
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Combine Variants to Item by field.';
                }
                field("Match by Item No. Only"; Rec."Match by Item No. Only")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Match by Item No. Only field.';
                }
                field("Delete Unvalidated Duplicates"; Rec."Delete Unvalidated Duplicates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Unvalidated Duplicates field.';
                }
                field("Do not Apply Internal Barcode"; Rec."Do not Apply Internal Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do not apply Internal Barcode field.';
                }
            }
            group(Numbering)
            {
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Creation by field.';
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. Prefix field.';
                }
                field("Prefix Code"; Rec."Prefix Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix Code field.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field.';
                }
            }
            group(Validation)
            {
                field("Error Handling"; Rec."Error Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Handling field.';
                }
                field("Test Validation"; Rec."Test Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Validation field.';
                }
            }
            group(Barcodes)
            {
                field("Create Internal Barcodes"; Rec."Create Internal Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Internal Barcodes field.';
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Vendor  Barcodes field.';
                }
            }
            group("Web Integration")
            {
                field("Allow Web Service Update"; Rec."Allow Web Service Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Web Service Update field.';
                }
                field("Item Info Query Name"; Rec."Item Info Query Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Name field.';
                }
                field("Item Info Query Type"; Rec."Item Info Query Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query Type field.';
                }
                field("Item Info Query By"; Rec."Item Info Query By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Info Query By field.';
                }
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        SetFieldsEditable;
    end;

    var
        LeaveSkippedLineonRegisterEditable: Boolean;

    local procedure SetFieldsEditable()
    begin
        LeaveSkippedLineonRegisterEditable := Rec."Delete Processed Lines";
    end;
}


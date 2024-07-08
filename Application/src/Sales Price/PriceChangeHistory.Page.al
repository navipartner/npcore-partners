page 6150828 "NPR Price Change History"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Price Change History';
    PageType = List;
    SourceTable = "NPR Price Change History";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ToolTip = 'Specifies the value of the Allow Invoice Disc. field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ToolTip = 'Specifies the value of the Allow Line Disc. field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    ToolTip = 'Specifies the value of the Defines field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Asset ID"; Rec."Asset ID")
                {
                    ToolTip = 'Specifies the value of the Asset ID field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Asset No."; Rec."Asset No.")
                {
                    ToolTip = 'Specifies the value of the Product No. (custom) field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Asset Type"; Rec."Asset Type")
                {
                    ToolTip = 'Specifies the value of the Product Type field.';
                    ApplicationArea = NPRRetail;
                }
                field("Assign-to No."; Rec."Assign-to No.")
                {
                    ToolTip = 'Specifies the value of the Assign-to No. field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Assign-to Parent No."; Rec."Assign-to Parent No.")
                {
                    ToolTip = 'Specifies the value of the Assign-to Parent No. field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Cost Factor"; Rec."Cost Factor")
                {
                    ToolTip = 'Specifies the value of the Cost Factor field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Direct Unit Cost field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the value of the Ending Date field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ToolTip = 'Specifies the value of the Line Amount field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ToolTip = 'Specifies the value of the Line Discount % field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ToolTip = 'Specifies the value of the Minimum Quantity field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Parent Source No."; Rec."Parent Source No.")
                {
                    ToolTip = 'Specifies the value of the Assign-to Parent No. (custom) field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Price Change Date"; Rec."Price Change Date")
                {
                    ToolTip = 'Specifies the value of the Price Change Date field.';
                    ApplicationArea = NPRRetail;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    ToolTip = 'Specifies the value of the Price Includes VAT field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ToolTip = 'Specifies the value of the Price List Code field.';
                    ApplicationArea = NPRRetail;
                    Visible = true;
                }
                field("Price Type"; Rec."Price Type")
                {
                    ToolTip = 'Specifies the value of the Price Type field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Product No."; Rec."Product No.")
                {
                    ToolTip = 'Specifies the value of the Product No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Group"; Rec."Source Group")
                {
                    ToolTip = 'Specifies the value of the Source Group field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ToolTip = 'Specifies the value of the Assign-to ID field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Assign-to No. (custom) field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the value of the Assign-to Type field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the value of the Starting Date field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Price Status field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Unit Cost field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code (custom) field.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code Lookup"; Rec."Unit of Measure Code Lookup")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code (custom) field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Lookup"; Rec."Variant Code Lookup")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ToolTip = 'Specifies the value of the Work Type Code field.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
            }
        }
    }
}
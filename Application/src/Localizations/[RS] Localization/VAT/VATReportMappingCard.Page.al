page 6151117 "NPR VAT Report Mapping Card"
{
    Caption = 'RS VAT Report Mapping Card';
    Extensible = false;
    PageType = Card;
    SourceTable = "NPR VAT Report Mapping";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the number of the report field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the description related to the report field.';
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                field("Purchase Payment Base"; Rec."Purchase Payment Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Base of the Purchase Payment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Payment Base");
                    end;
                }
                field("Purchase Invoice Base"; Rec."Purchase Invoice Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Purchase Payment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Invoice Base");
                    end;
                }
                field("Purchase Cr. Memo Base"; Rec."Purchase Cr. Memo Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where Base of the Purchase Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Cr. Memo Base");
                    end;
                }
                field("Non-Deductable Base"; Rec."Non-Deductable Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where Base of the Non-Deductable VAT should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Non-Deductable Base");
                    end;
                }
                field("VAT Base Purchase Full VAT"; Rec."VAT Base Purchase Full VAT")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Full VAT Base should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."VAT Base Purchase Full VAT");
                    end;
                }
                field("Prep. Purchase Invoice Base"; Rec."Prep. Purchase Invoice Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where Base of the Purchase Prepayment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Purchase Invoice Base");
                    end;
                }
                field("Prep. Purchase Cr. Memo Base"; Rec."Prep. Purchase Cr. Memo Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where Base of the Purchase Prepayment Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Purchase Cr. Memo Base");
                    end;
                }
                field("Purchase Payment Amount"; Rec."Purchase Payment Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where VAT Amount of the Purchase Payment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Payment Amount");
                    end;
                }
                field("Purchase Invoice Amount"; Rec."Purchase Invoice Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Purchase Invoice should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Invoice Amount");
                    end;
                }
                field("Purchase Cr. Memo Amount"; Rec."Purchase Cr. Memo Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Purchase Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Cr. Memo Amount");
                    end;
                }
                field("Non-Deductable Amount"; Rec."Non-Deductable Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Non-Deductable VAT should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Non-Deductable Amount");
                    end;
                }
                field("Deductable Amount"; Rec."Deductable Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Deductable VAT Amount should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Deductable Amount");
                    end;
                }
                field("Prep. Purchase Invoice Amount"; Rec."Prep. Purchase Invoice Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Purchase Invoice should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Purchase Invoice Amount");
                    end;
                }
                field("Prep. Purchase Cr. Memo Amount"; Rec."Prep. Purchase Cr. Memo Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Purchase Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Purchase Cr. Memo Amount");
                    end;
                }
            }
            group(Sales)
            {
                Caption = 'Sales';

                field("Sales Payment Base"; Rec."Sales Payment Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Base of the Sales Payment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Payment Base");
                    end;
                }
                field("Sales Invoice Base"; Rec."Sales Invoice Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Base of the Sales Invoice should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Invoice Base");
                    end;
                }
                field("Sales Cr. Memo Base"; Rec."Sales Cr. Memo Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Base of the Sales Payment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Cr. Memo Base");
                    end;
                }
                field("VAT Base Full VAT"; Rec."VAT Base Full VAT")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Full VAT Base should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."VAT Base Full VAT");
                    end;
                }
                field("Prep. Sales Invoice Base"; Rec."Prep. Sales Invoice Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Base of the Sales Prepayment Invoice should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Sales Invoice Base");
                    end;
                }
                field("Prep. Sales Cr. Memo Base"; Rec."Prep. Sales Cr. Memo Base")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the Base of the Sales Prepayment Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Sales Cr. Memo Base");
                    end;
                }
                field("Sales Payment Amount"; Rec."Sales Payment Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Sales Payment should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Payment Amount");
                    end;
                }
                field("Sales Invoice Amount"; Rec."Sales Invoice Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Sales Invoice should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Invoice Amount");
                    end;
                }
                field("Sales Cr. Memo Amount"; Rec."Sales Cr. Memo Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Sales Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Cr. Memo Amount");
                    end;
                }
                field(DummyCaption2Lbl; DummyCaptionLbl)
                {
                    ApplicationArea = NPRRSLocal;
                    Editable = false;
                    ShowCaption = false;
                }
                field("Prep. Sales Invoice Amount"; Rec."Prep. Sales Invoice Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Sales Prepayment Invoice should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Sales Invoice Amount");
                    end;
                }
                field("Prep. Sales Cr. Memo Amount"; Rec."Prep. Sales Cr. Memo Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    ToolTip = 'Specifies the field where the VAT Amount of the Sales Prepayment Credit Memo should be written in the report.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Sales Cr. Memo Amount");
                    end;
                }
            }
            group("Book of Incoming Invoices")
            {
                field("Book of Inc. Inv. Base"; Rec."Book of Inc. Inv. Base")
                {
                    ApplicationArea = NPRRSLocal;
                    Caption = 'Invoice Base';
                    ToolTip = 'Specifies the field where the Invoice Base should be written in the Book of Incoming Invoices.';
                }
                field("Book of Inc. Inv. Amount"; Rec."Book of Inc. Inv. Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    Caption = 'Invoice Amount';
                    ToolTip = 'Specifies the field where the Invoice VAT Amount should be written in the Book of Incoming Invoices.';
                }
            }
            group("Book of Outgoing Invoices")
            {
                field("Book of Out. Inv. Base"; Rec."Book of Out. Inv. Base")
                {
                    ApplicationArea = NPRRSLocal;
                    Caption = 'Invoice Base';
                    ToolTip = 'Specifies the field where the Invoice Base should be written in the Book of Outgoing Invoices.';
                }
                field("Book of Out. Inv. Amount"; Rec."Book of Out. Inv. Amount")
                {
                    ApplicationArea = NPRRSLocal;
                    Caption = 'Invoice Amount';
                    ToolTip = 'Specifies the field where the Invoice VAT Amount should be written in the Book of Outgoing Invoices.';
                }
            }
        }
    }

    local procedure LookupField(var RecField: Integer)
    var
        "Field": Record "Field";
        TableFilter: Record "Table Filter";
        FieldSelection: Codeunit "Field Selection";
    begin
        "Field".SetRange(TableNo, Database::"NPR VAT EV Entry");
        "Field".SetRange(Type, "Field".Type::Decimal);
        if FieldSelection.Open("Field") then begin
            if "Field"."No." = RecField then
                exit;
            TableFilter.CheckDuplicateField("Field");
            RecField := "Field"."No.";
        end;
    end;

    var
        DummyCaptionLbl: Label '', Locked = true;
}
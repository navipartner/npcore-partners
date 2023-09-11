page 6151117 "NPR VAT Report Mapping Card"
{
    Caption = 'VAT Report Mapping Card';
    PageType = Card;
    SourceTable = "NPR VAT Report Mapping";
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRSLocal;
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                field("Purchase Payment Base"; Rec."Purchase Payment Base")
                {
                    ToolTip = 'Specifies the value of the Base Field field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Payment Base");
                    end;
                }
                field("Purchase Invoice Base"; Rec."Purchase Invoice Base")
                {
                    ToolTip = 'Specifies the value of the Purchase Invoice Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Invoice Base");
                    end;
                }
                field("Purchase Cr. Memo Base"; Rec."Purchase Cr. Memo Base")
                {
                    ToolTip = 'Specifies the value of the Purchase Cr. Memo Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Cr. Memo Base");
                    end;
                }
                field("Non-Deductable Base"; Rec."Non-Deductable Base")
                {
                    ToolTip = 'Specifies the value of the Non-Deductable Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Non-Deductable Base");
                    end;
                }
                field(DummyCaptionLbl; DummyCaptionLbl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Prep. Purchase Invoice Base"; Rec."Prep. Purchase Invoice Base")
                {
                    ToolTip = 'Specifies the value of the Prepayment Purchase Invoice Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Purchase Invoice Base");
                    end;
                }
                field("Purchase Payment Amount"; Rec."Purchase Payment Amount")
                {
                    ToolTip = 'Specifies the value of the Purchase Payment Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Payment Amount");
                    end;
                }
                field("Purchase Invoice Amount"; Rec."Purchase Invoice Amount")
                {
                    ToolTip = 'Specifies the value of the Purchase Invoice Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Invoice Amount");
                    end;
                }
                field("Purchase Cr. Memo Amount"; Rec."Purchase Cr. Memo Amount")
                {
                    ToolTip = 'Specifies the value of the Purchase Cr. Memo Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Purchase Cr. Memo Amount");
                    end;
                }
                field("Non-Deductable Amount"; Rec."Non-Deductable Amount")
                {
                    ToolTip = 'Specifies the value of the Non-Deductable Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Non-Deductable Amount");
                    end;
                }
                field("Deductable Amount"; Rec."Deductable Amount")
                {
                    ToolTip = 'Specifies the value of the Deductable Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Deductable Amount");
                    end;
                }
                field("Prep. Purchase Invoice Amount"; Rec."Prep. Purchase Invoice Amount")
                {
                    ToolTip = 'Specifies the value of the Prepayment Purchase Invoice Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Purchase Invoice Amount");
                    end;
                }
            }
            group(Sales)
            {
                Caption = 'Sales';

                field("Sales Payment Base"; Rec."Sales Payment Base")
                {
                    ToolTip = 'Specifies the value of the Sales Payment Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Payment Base");
                    end;
                }
                field("Sales Invoice Base"; Rec."Sales Invoice Base")
                {
                    ToolTip = 'Specifies the value of the Sales Invoice Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Invoice Base");
                    end;
                }
                field("Sales Cr. Memo Base"; Rec."Sales Cr. Memo Base")
                {
                    ToolTip = 'Specifies the value of the Sales Cr. Memo Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Cr. Memo Base");
                    end;
                }
                field("VAT Base Full VAT"; Rec."VAT Base Full VAT")
                {
                    ToolTip = 'Specifies the value of the VAT Base Full VAT field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."VAT Base Full VAT");
                    end;
                }
                field("Prep. Sales Invoice Base"; Rec."Prep. Sales Invoice Base")
                {
                    ToolTip = 'Specifies the value of the Prepayment Sales Invoice Base field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Sales Invoice Base");
                    end;
                }
                field("Sales Payment Amount"; Rec."Sales Payment Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Payment Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Payment Amount");
                    end;
                }
                field("Sales Invoice Amount"; Rec."Sales Invoice Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Invoice Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Invoice Amount");
                    end;
                }
                field("Sales Cr. Memo Amount"; Rec."Sales Cr. Memo Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Cr. Memo Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Sales Cr. Memo Amount");
                    end;
                }
                field(DummyCaption2Lbl; DummyCaptionLbl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Prep. Sales Invoice Amount"; Rec."Prep. Sales Invoice Amount")
                {
                    ToolTip = 'Specifies the value of the Prepayment Sales Invoice Amount field.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(Rec."Prep. Sales Invoice Amount");
                    end;
                }
            }
            group("Book of Incoming Invoices")
            {
                field("Book of Inc. Inv. Base"; Rec."Book of Inc. Inv. Base")
                {
                    Caption = 'Invoice Base';
                    ToolTip = 'Specifies the value of the Invoice Base field.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Book of Inc. Inv. Amount"; Rec."Book of Inc. Inv. Amount")
                {
                    Caption = 'Invoice Amount';
                    ToolTip = 'Specifies the value of the Invoice Amount field.';
                    ApplicationArea = NPRRSLocal;
                }
            }
            group("Book of Outgoing Invoices")
            {
                field("Book of Out. Inv. Base"; Rec."Book of Out. Inv. Base")
                {
                    Caption = 'Invoice Base';
                    ToolTip = 'Specifies the value of the Invoice Base field.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Book of Out. Inv. Amount"; Rec."Book of Out. Inv. Amount")
                {
                    Caption = 'Invoice Amount';
                    ToolTip = 'Specifies the value of the Invoice Amount field.';
                    ApplicationArea = NPRRSLocal;
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

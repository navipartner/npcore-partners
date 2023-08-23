page 6060058 "NPR Item Worksh. Template"
{
    Extensible = False;
    Caption = 'Item Worksheet Template';
    ContextSensitiveHelpPage = 'docs/retail/item_worksheet/reference/template/template_ref/';
    PageType = Card;
    SourceTable = "NPR Item Worksh. Template";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies  the name of the worksheet.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the template.';
                    ApplicationArea = NPRRetail;
                }
                field("Register Lines"; Rec."Register Lines")
                {
                    ToolTip = 'When checked, a registered item worksheet and the related records will be created.';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {
                    ToolTip = 'If checked, all lines will be removed from the item worksheet when successfully registered.';
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
                field("Sales Price Handling"; Rec."Sales Price Handl.")
                {
                    ToolTip = 'Specifies the value of the Sales Price Handling field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SalesPriceListHandling := Rec."Sales Price Handl." = Rec."Sales Price Handl."::PriceList;

                        if not SalesPriceListHandling then
                            Rec."Sales Price List Code" := '';

                        CurrPage.Update(true);
                    end;
                }
                field("Sales Price List"; Rec."Sales Price List Code")
                {
                    ToolTip = 'Specifies the value of the Sales Price List field.';
                    ApplicationArea = NPRRetail;
                    Editable = SalesPriceListHandling;
                    ShowMandatory = SalesPriceListHandling;
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handl.")
                {
                    ToolTip = 'Specifies the value of the Purchase Price Handling field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        PurchasePriceListHandling := Rec."Purchase Price Handl." = Rec."Purchase Price Handl."::PriceList;

                        if not PurchasePriceListHandling then
                            Rec."Purchase Price List Code" := '';
                        
                        CurrPage.Update(true);
                    end;
                }
                field("Purchase Price List"; Rec."Purchase Price List Code")
                {
                    ToolTip = 'Specifies the value of the Purchase Price List field.';
                    ApplicationArea = NPRRetail;
                    Editable = PurchasePriceListHandling;
                    ShowMandatory = PurchasePriceListHandling;
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {
                    ToolTip = 'Specifies under which criteria variants should be combined';
                    ApplicationArea = NPRRetail;
                }
                field("Combine as Background Task"; Rec."Combine as Background Task")
                {
                    ToolTip = 'Specifies whether combining variants process should be executed as a background task.';
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
                    ToolTip = 'If enabled, the Internal Barcode field isn''t applied.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Numbering)
            {
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {
                    ToolTip = 'Determines how the item number will be created for all new items.';
                    ApplicationArea = NPRRetail;
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {
                    ToolTip = 'Specifies if the prefix will be used when generating the item number. ';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Code"; Rec."Prefix Code")
                {
                    ToolTip = 'Specifies the prefix of maximum three characters. This is used for the item number prefix when the From Template option is selected.';
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
                    ToolTip = 'Defines the error handling when validating or registering the worksheet lines.';
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
                    ToolTip = 'Defines the creation of barcodes when registering the worksheet lines, if varieties are used, only the barcodes for variants will be created based on varieties.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {
                    ToolTip = 'Defines if and when the vendor barcodes are used during the line registration. ';
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
        SalesPriceListHandling: Boolean;
        PurchasePriceListHandling: Boolean;

    local procedure SetFieldsEditable()
    begin
        LeaveSkippedLineonRegisterEditable := Rec."Delete Processed Lines";
        SalesPriceListHandling := Rec."Sales Price Handl." = Rec."Sales Price Handl."::PriceList;
        PurchasePriceListHandling := Rec."Purchase Price Handl." = Rec."Purchase Price Handl."::PriceList;
    end;
}


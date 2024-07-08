page 6060058 "NPR Item Worksh. Template"
{
#if not BC17
    AboutText = 'An Item Worksheet is a structured template used for managing item-related data in a business context, aiding in the creation and organization of various aspects of items.';
    AboutTitle = 'About Item Worksheet Template';
#endif
    Caption = 'Item Worksheet Template';
    ContextSensitiveHelpPage = 'docs/retail/item_worksheet/reference/template/template_ref/';
    Extensible = False;
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
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies  the name of the worksheet.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the template.';
                }
                field("Register Lines"; Rec."Register Lines")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'When checked, a registered item worksheet and the related records will be created.';
                }
                field("Delete Processed Lines"; Rec."Delete Processed Lines")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If checked, all lines will be removed from the item worksheet when successfully registered.';

                    trigger OnValidate()
                    begin
                        SetFieldsEditable();
                    end;
                }
                field("Leave Skipped Line on Register"; Rec."Leave Skipped Line on Register")
                {
                    ApplicationArea = NPRRetail;
                    Editable = LeaveSkippedLineonRegisterEditable;
                    ToolTip = 'Specifies the value of the Leave Skipped Line on Register field.';
                }
                field("Sales Price Handling"; Rec."Sales Price Handl.")
                {
#if not BC17
                    AboutText = 'In the "Sales Price Handling" field there are options which include updating the unit price on the Item Card ("Item"), inserting prices into the Sales Price table with variations ("Item+Variant"), considering effective dates ("Item+Date"), and combining variations with effective dates ("Item+Variant+Date"), even allowing for different currencies.';
                    AboutTitle = 'Manage the processing of sales prices.';
#endif
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Price Handling field.';

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
                    ApplicationArea = NPRRetail;
                    Editable = SalesPriceListHandling;
                    ShowMandatory = SalesPriceListHandling;
                    ToolTip = 'Specifies the code of the Sales Price List, which associates it with the item, and determines the pricing information used for sales transactions.';
                }
                field("Purchase Price Handling"; Rec."Purchase Price Handl.")
                {
#if not BC17
                    AboutText = 'In the "Purchase Price Handling" field, you can specify how purchase prices are managed. Options include updating the Last Direct Unit Cost on the Item Card ("Item"), inserting prices into the Purchase Price table with variations ("Item+Variant"), considering effective dates ("Item+Date"), and combining variations with effective dates ("Item+Variant+Date"), even allowing for different currencies.';
                    AboutTitle = 'Manage the processing of purchase prices.';
#endif
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Purchase Price Handling field.';

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
                    ApplicationArea = NPRRetail;
                    Editable = PurchasePriceListHandling;
                    ShowMandatory = PurchasePriceListHandling;
                    ToolTip = 'Specifies the code of the Purchase Price List, which associates it with the item, and determines the pricing information used for purchase transactions.';
                }
                field("Combine Variants to Item by"; Rec."Combine Variants to Item by")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies under which criteria variants should be combined';
                }
                field("Combine as Background Task"; Rec."Combine as Background Task")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the process of combining variants should be executed as a background task.';
                }
                field("Match by Item No. Only"; Rec."Match by Item No. Only")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enabling this option restricts matching to item numbers exclusively, enhancing precision in search results by focusing on item number matches.';
                }
                field("Delete Unvalidated Duplicates"; Rec."Delete Unvalidated Duplicates")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enabling this option allows the system to automatically remove unvalidated duplicate entries, ensuring data accuracy and consistency.';
                }
                field("Do not Apply Internal Barcode"; Rec."Do not Apply Internal Barcode")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If enabled, the Internal Barcode field isn''t applied.';
                }
            }
            group(Numbering)
            {
#if not BC17
                AboutText = 'This section of the page deals with how item numbers are formatted and created for new items in the worksheet, including the use of prefixes and various generation options.';
                AboutTitle = 'Manage the item''s numbering';
#endif
                field("Item No. Creation by"; Rec."Item No. Creation by")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Determines how the item number will be created for all new items.';
                }
                field("Item No. Prefix"; Rec."Item No. Prefix")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the prefix will be used when generating the item number. ';
                }
                field("Prefix Code"; Rec."Prefix Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the prefix of maximum three characters. This is used for the item number prefix when the From Template option is selected.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. Series field.';
                }
            }
            group(Validation)
            {
                field("Error Handling"; Rec."Error Handling")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the error handling when validating or registering the worksheet lines.';
                }
                field("Test Validation"; Rec."Test Validation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Test Validation field.';
                }
            }
            group(Barcodes)
            {
#if not BC17
                AboutText = 'In the "Barcodes" section, you can specify how barcodes are generated when registering worksheet lines, including options like creating them as alternative item numbers or cross reference numbers. Additionally, you can define the use of vendor barcodes during line registration with similar options.';
                AboutTitle = 'Manage the item''s barcodes';
#endif
                field("Create Internal Barcodes"; Rec."Create Internal Barcodes")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the creation of barcodes when registering the worksheet lines, if varieties are used, only the barcodes for variants will be created based on varieties.';
                }
                field("Create Vendor  Barcodes"; Rec."Create Vendor  Barcodes")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines if and when the vendor barcodes are used during the line registration. ';
                }
            }
            group("Web Integration")
            {
#if not BC17
                AboutText = 'This section allows you to set up and configure various options related to item information queries, including whether web service updates are allowed and how query parameters are defined.';
                AboutTitle = 'Manage Web Integrations';
#endif
                field("Allow Web Service Update"; Rec."Allow Web Service Update")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Web Service Update field.';
                }
                field("Item Info Query Name"; Rec."Item Info Query Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item Info Query Name field.';
                }
                field("Item Info Query Type"; Rec."Item Info Query Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item Info Query Type field.';
                }
                field("Item Info Query By"; Rec."Item Info Query By")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item Info Query By field.';
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
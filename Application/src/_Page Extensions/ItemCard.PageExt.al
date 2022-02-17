pageextension 6014430 "NPR Item Card" extends "Item Card"
{
    PromotedActionCategories = 'New,Process,Report,Item,History,Special Sales Prices & Discounts,Approve,Request Approval,Magento';
    layout
    {
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                ToolTip = 'Specifies a description extension, should more information be required for the item.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter(Type)
        {
            field("NPR Item Status"; Rec."NPR Item Status")
            {

                ToolTip = 'Specifies the actions allowed for the item.';
                ApplicationArea = NPRRetail;
            }

            field("NPR Item Brand"; Rec."NPR Item Brand")
            {

                ToolTip = 'Specifies the make of the item.';
                ApplicationArea = NPRRetail;
            }

        }

        addafter("Unit Cost")
        {
            field("NPR AverageCostACY"; AverageCostACY)
            {

                Caption = 'Average Cost ACY';
                ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                ApplicationArea = NPRRetail;
                trigger OnDrillDown()
                begin
                    CODEUNIT.RUN(CODEUNIT::"Show Avg. Calc. - Item", Rec);
                end;
            }
        }

        addafter("Item Category Code")
        {
            field("NPR Statistics Group"; Rec."Statistics Group")
            {

                ToolTip = 'Allow the user to specify a statistics group code for statistical reporting purposes.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter(AssemblyBOM)
        {
            field("NPR Explode BOM auto"; Rec."NPR Explode BOM auto")
            {

                ToolTip = 'Specifies whether the BOM is expanded to show the individual items on the BOM automatically.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Sales Blocked")
        {
            field("NPR Custom Discount Blocked"; Rec."NPR Custom Discount Blocked")
            {

                ToolTip = 'Specifies whether the custom discount is blocked for the item.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Search Description")
        {
            field("NPR Inventory Value Zero"; Rec."Inventory Value Zero")
            {

                ToolTip = 'Specifies whether items with no inventory values are allowed.';
                ApplicationArea = NPRRetail;
            }

        }

        addafter("Service Item Group")
        {
            field("NPR Group sale"; Rec."NPR Group sale")
            {

                ToolTip = 'Specifies various items on sale.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Unit Price")
        {
            field("NPR Unit List Price"; Rec."Unit List Price")
            {

                ToolTip = 'Specifies the price of a single unit of measure for a sold product.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {

                ToolTip = 'Specifies how many units are packed in one parcel.';
                ApplicationArea = NPRRetail;
            }
        }

        addbefore("Cost Details")
        {
            group("NPR Dimensions")
            {
                Caption = 'Dimensions';
                field("NPR Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the default Global Dimension 1 Code for the item.';
                    ApplicationArea = NPRRetail;
                }

                field("NPR Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the default Global Dimension 2 Code for the item.';
                    ApplicationArea = NPRRetail;
                }
            }
        }

        addafter("VAT Bus. Posting Gr. (Price)")
        {
            group("NPR DiscountonPOS")
            {
                Caption = 'Discounts on POS';
                field("NPR Has Mixed Discount"; Rec."NPR Has Mixed Discount")
                {

                    ToolTip = 'Specifies whether the item has Mixed Discount lines defined.';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        MixedDiscountLine: Record "NPR Mixed Discount Line";
                        MixedDiscountLines: Page "NPR Mixed Discount Lines";
                    begin
                        MixedDiscountLines.Editable(false);
                        MixedDiscountLine.Reset();
                        MixedDiscountLine.SetRange("No.", Rec."No.");
                        MixedDiscountLines.SetTableView(MixedDiscountLine);
                        MixedDiscountLines.RunModal();
                    end;
                }

                field("NPR Has Quantity Discount"; Rec."NPR Has Quantity Discount")
                {

                    ToolTip = 'Specifies whether the item has Quantity Discount lines defined.';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
                        QuantityDiscountCard: Page "NPR Quantity Discount Card";
                    begin
                        QuantityDiscountCard.Editable(false);
                        QuantityDiscountHeader.Reset();
                        QuantityDiscountHeader.SetFilter("Item No.", Rec."No.");
                        QuantityDiscountCard.SetTableView(QuantityDiscountHeader);
                        QuantityDiscountCard.RunModal();
                    end;
                }

                field("NPR Has Period Discount"; Rec."NPR Has Period Discount")
                {

                    ToolTip = 'Specifies whether the item has Period Discount lines defined.';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                        CampaignDiscountLines: Page "NPR Campaign Discount Lines";
                    begin
                        CampaignDiscountLines.Editable(false);
                        PeriodDiscountLine.Reset();
                        PeriodDiscountLine.SetRange("Item No.", Rec."No.");
                        CampaignDiscountLines.SetTableView(PeriodDiscountLine);
                        CampaignDiscountLines.RunModal();
                    end;
                }
            }
        }


        addafter("Prices & Sales")
        {
            group("NPR Variety")
            {
                Caption = 'Variety';
                field("NPR Has Variants"; Rec."NPR Has Variants")
                {

                    ToolTip = 'Specifies whether the item has Variant lines defined.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety Group"; Rec."NPR Variety Group")
                {

                    ToolTip = 'Specifies the value of the Variety Group.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 1"; Rec."NPR Variety 1")
                {

                    ToolTip = 'Specifies the value of the Variety 1.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 1 Table"; Rec."NPR Variety 1 Table")
                {

                    ToolTip = 'Specifies the value to be used for the Variety 1.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 2"; Rec."NPR Variety 2")
                {

                    ToolTip = 'Specifies the value of the Variety 2.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 2 Table"; Rec."NPR Variety 2 Table")
                {

                    ToolTip = 'Specifies the value to be used for the Variety 2.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 3"; Rec."NPR Variety 3")
                {

                    ToolTip = 'Specifies the value of the Variety 3.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 3 Table"; Rec."NPR Variety 3 Table")
                {

                    ToolTip = 'Specifies the value to be used for the Variety 3.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 4"; Rec."NPR Variety 4")
                {

                    ToolTip = 'Specifies the value of the Variety 4.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Variety 4 Table"; Rec."NPR Variety 4 Table")
                {

                    ToolTip = 'Specifies the value to be used for the Variety 4';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Cross Variety No."; Rec."NPR Cross Variety No.")
                {

                    ToolTip = 'Specifies the default cross value to be used on the Variety Matrix.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("NPR Properties")
            {
                group("NPR Group1")
                {
                    ShowCaption = false;

                    field("NPR Item AddOn No."; ItemAdditionalFields."Item Addon No.")
                    {
                        Caption = 'Item AddOn No.';
                        ToolTip = 'Allows the user to link additional items.';
                        ApplicationArea = NPRRetail;
                        trigger OnValidate()
                        begin
                            Rec.SetItemAdditionalFields(ItemAdditionalFields);
                        end;
                    }
                    field("NPR NPRE Item Routing Profile"; Rec."NPR NPRE Item Routing Profile")
                    {

                        ToolTip = 'Specifies the NPRE Item Routing Profile.';
                        ApplicationArea = NPRRetail;
                    }
                }

                group("NPR Group2")
                {
                    ShowCaption = false;

                    field("NPR Guarantee voucher"; Rec."NPR Guarantee voucher")
                    {

                        ToolTip = 'Specifies if the voucher type will be Guarantee.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR No Print on Reciept"; Rec."NPR No Print on Reciept")
                    {

                        ToolTip = 'Specifies if the No is printed on the receipt.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Ticket Type"; Rec."NPR Ticket Type")
                    {

                        ToolTip = 'Specifies the ticket type that will be used with the item.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Print Tags"; Rec."NPR Print Tags")
                    {

                        ToolTip = 'Specifies the item print tags.';
                        ApplicationArea = NPRRetail;
                        trigger OnValidate()
                        var
                            PrintTagsPage: Page "NPR Print Tags";
                        begin

                            CLEAR(PrintTagsPage);
                            PrintTagsPage.SetTagText(Rec."NPR Print Tags");
                            IF PrintTagsPage.RunModal() = ACTION::OK THEN
                                Rec."NPR Print Tags" := PrintTagsPage.ToText();

                        end;
                    }
                }
            }

            group("NPR MagentoEnabled")
            {
                Caption = 'Magento';
                Visible = MagentoEnabled;

                group("NPR Group3")
                {
                    ShowCaption = true;
                    field("NPR Magento Item"; Rec."NPR Magento Item")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies if the item will also be used as a Magento Item.';
                        ApplicationArea = NPRRetail;
                        trigger OnValidate()
                        begin
                            NPR_SetMagentoEnabled();
                        end;
                    }
                    field("NPR Magento Status"; Rec."NPR Magento Status")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies if the item is active or not as a Magento Item.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Magento Name"; Rec."NPR Magento Name")
                    {

                        ToolTip = 'Specifies the item Magento Name.';
                        ApplicationArea = NPRRetail;
                        trigger OnValidate()
                        begin
                            NPR_ValidateSEOLink();
                        end;
                    }
                    field("NPR Magento Description"; Format(Rec."NPR Magento Desc.".HasValue))
                    {

                        Caption = 'Magento Description';
                        ToolTip = 'Specifies the item Magento Description.';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
                            Rec."NPR Magento Desc.".ExportStream(OutStr);
                            if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    Rec."NPR Magento Desc.".ImportStream(InStr, Rec.FieldCaption("NPR Magento Desc."));
                                end else
                                    Clear(Rec."NPR Magento Desc.");
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field("NPR Magento Short Description"; Format(Rec."NPR Magento Short Desc.".HasValue))
                    {

                        Caption = 'Magento Short Description';
                        ToolTip = 'Specifies the item Magento Short Description.';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
                            Rec."NPR Magento Short Desc.".ExportStream(OutStr);
                            if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    Rec."NPR Magento Short Desc.".ImportStream(InStr, Rec.FieldCaption("NPR Magento Short Desc."));
                                end else
                                    Clear(Rec."NPR Magento Short Desc.");
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field("NPR Magento Brand"; Rec."NPR Magento Brand")
                    {

                        Visible = MagentoEnabledBrand;
                        ToolTip = 'Specifies the item Magento Brand.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR MagentoUnitPrice"; Rec."Unit Price")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the Magento''s item Unit Price.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Product New From"; Rec."NPR Product New From")
                    {

                        ToolTip = 'Specifies the start date for the item to be tagged as New Product.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Product New To"; Rec."NPR Product New To")
                    {

                        ToolTip = 'Specifies the end date for the item to be tagged as New Product.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Featured From"; Rec."NPR Featured From")
                    {

                        ToolTip = 'Specifies the start date for the item to be tagged as Featured.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Featured To"; Rec."NPR Featured To")
                    {

                        ToolTip = 'Specifies the end date for the item to be tagged as Featured.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Special Price"; Rec."NPR Special Price")
                    {

                        Visible = MagentoEnabledSpecialPrices;
                        ToolTip = 'Specifies the Special Price for the Item to be displayed on the Webshop.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Special Price From"; Rec."NPR Special Price From")
                    {

                        Visible = MagentoEnabledSpecialPrices;
                        ToolTip = 'Specifies the start date for the item to apply the special price.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Special Price To"; Rec."NPR Special Price To")
                    {

                        Visible = MagentoEnabledSpecialPrices;
                        ToolTip = 'Specifies the end date for the item to apply the special price.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Custom Options"; NPRCustomOptionCount)
                    {
                        Caption = 'Custom Options';
                        Visible = MagentoEnabledCustomOptions;
                        ToolTip = 'Shows custom options when Magento is enabled.';
                        ApplicationArea = NPRRetail;
                        trigger OnAssistEdit()
                        var
                            MagentoItemCustomOptions: Page "NPR Magento Item Cstm Options";
                        begin
                            Clear(MagentoItemCustomOptions);
                            MagentoItemCustomOptions.SetItemNo(Rec."No.");
                            MagentoItemCustomOptions.Run();
                        end;
                    }
                    field("NPR Backorder"; Rec."NPR Backorder")
                    {

                        ToolTip = 'Specifies whether to allow back order when processing sales order.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Display Only"; Rec."NPR Display Only")
                    {

                        ToolTip = 'Specifies if the item is for Display Only.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Display only Text"; Rec."NPR Display only Text")
                    {

                        ToolTip = 'Specifies the Display Only Text.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Seo Link"; Rec."NPR Seo Link")
                    {

                        ToolTip = 'Specifies the value of the Seo Link field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Meta Title"; Rec."NPR Meta Title")
                    {

                        ToolTip = 'Specifies the value of the Meta Title field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Meta Description"; Rec."NPR Meta Description")
                    {

                        ToolTip = 'Specifies the value of the Meta Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Attribute Set ID"; Rec."NPR Attribute Set ID")
                    {

                        AssistEdit = true;
                        Editable = NOT Rec."NPR Magento Item";
                        Visible = MagentoEnabledAttributeSet;
                        ToolTip = 'Specifies the attribute to be assigned to the Magento item.';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
                        begin
                            if Rec."NPR Attribute Set ID" <> 0 then begin
                                CurrPage.Update(true);
                                MagentoAttributeSetMgt.EditItemAttributes(Rec."No.", '');
                            end;
                        end;
                    }
                }

                group("NPR Group4")
                {
                    ShowCaption = false;
                    Visible = MagentoPictureVarietyTypeVisible;
                    field("NPR Magento Picture Variety Type"; Rec."NPR Magento Pict. Variety Type")
                    {

                        ToolTip = 'Specifies how the Magento picture is related to the variety e.g. color, size.';
                        ApplicationArea = NPRRetail;
                    }
                }
                part("NPR Magento Category Links"; "NPR Magento Category Links")
                {
                    Caption = 'Category Links';
                    SubPageLink = "Item No." = FIELD("No.");
                    Visible = NOT MagentoEnabledMultiStore;
                    ApplicationArea = NPRRetail;

                }
                part("NPR Product Relations"; "NPR Magento Product Relations")
                {
                    Caption = 'Product Relations';
                    SubPageLink = "From Item No." = FIELD("No.");
                    Visible = MagentoEnabledProductRelations;
                    ApplicationArea = NPRRetail;

                }
            }
            group("NPR Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {

                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the item attribute value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, Rec."No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {

                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the item attribute value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, Rec."No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {

                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;
                    ToolTip = 'Specifies the item attribute value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, Rec."No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {

                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the item attribute value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, Rec."No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {

                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the item attribute value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, Rec."No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {

                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the item attributes value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 6, Rec."No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {

                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the item attributes value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 7, Rec."No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {

                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the item attributes value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 8, Rec."No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {

                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the item attributes value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 9, Rec."No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {

                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the item attributes value.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 10, Rec."No.", NPRAttrTextArray[10]);
                    end;
                }
            }

        }

        addafter(ItemAttributesFactbox)
        {
            part(NPRMagentoPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {

                Visible = MagentoEnabled;
                ApplicationArea = NPRRetail;
            }
            part(NPRPicture; "NPR Magento Item Pict. Factbox")

            {

                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "No." = FIELD("No.");
                Visible = MagentoEnabled;
                ApplicationArea = NPRRetail;
            }
            part("NPR Discount FactBox"; "NPR Discount FactBox")
            {

                Caption = 'Discounts';
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRRetail;
            }
        }
    }
    actions
    {
        modify(ItemsByLocation)
        {
            Promoted = true;
            PromotedOnly = true;
            PromotedCategory = Process;
        }
#if BC17
        modify("Cross Re&ferences")
        {
            Visible = not ItemReferenceVisible;
        }
#endif
        addafter("Va&riants")
        {
            action("NPR NPR_VarietyMatrix")
            {
                Caption = 'Variety Matrix';
                Image = ItemAvailability;
                ShortCutKey = 'Ctrl+Alt+v';

                ToolTip = 'Executes the display Variety Matrix action. View or edit varieties for the item/';
                ApplicationArea = NPRRetail;
            }
            action("NPR AttributeValues")
            {
                Caption = 'All Attributes Values';
                Image = ShowList;

                ToolTip = 'View or edit all the attributes attached to this item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NPRAttrManagement: Codeunit "NPR Attribute Management";
                begin
                    NPRAttrManagement.ShowMasterDataAttributeValues(Database::Item, Rec."No.");
                end;
            }
        }
        addafter("Application Worksheet")
        {
            action("NPR POSSalesEntries")
            {
                Caption = 'POS Sales Entries';
                Image = Entries;

                ToolTip = 'View all the POS entries for this item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSSalesLineListFromItem(Rec);
                end;
            }
        }

        addafter("Item Journal")
        {
            action("NPR RetailItemJournal")
            {
                Caption = 'Retail Item Journal';
                Image = Journals;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page 6014402;

                ToolTip = 'Open a list of retail journals where you can the physical of retail items on inventory.';
                ApplicationArea = NPRRetail;
            }

            action("NPR RetailItemReclassJnl")
            {
                Caption = 'Retail Item Reclassification Journal';
                Image = Journals;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page 6014403;

                ToolTip = 'Change information on item ledger entries, such as dimensions, location codes, bin codes, and serial or lot number.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Item Tracing")
        {
            group("NPR TransferTo")
            {
                Caption = 'Transfer to';
                Image = Action;

                action("NPR TransfertoRetailJounal")
                {
                    Caption = 'Transfer to Retail Journal';
                    Image = TransferToGeneralJournal;

                    ToolTip = 'Allows user to create a Retail Journal Transfer.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailJournalHeader: Record "NPR Retail Journal Header";
                        RetailJournalLine: Record "NPR Retail Journal Line";
                        InputDialog: Page "NPR Input Dialog";
                        TempInt: Integer;
                        TempQty: Integer;
                        t001: Label 'Quantity to be transfered to UPDATED?';
                    begin
                        IF PAGE.RUNMODAL(PAGE::"NPR Retail Journal List", RetailJournalHeader) <> ACTION::LookupOK THEN
                            EXIT;

                        RetailJournalLine.Reset();
                        RetailJournalLine.SETRANGE("No.", RetailJournalHeader."No.");
                        IF RetailJournalLine.FIND('+') THEN
                            TempInt := RetailJournalLine."Line No." + 10000
                        ELSE
                            TempInt := 10000;

                        TempQty := 1;

                        InputDialog.SetInput(1, TempQty, t001);
                        IF InputDialog.RunModal() = ACTION::OK THEN
                            InputDialog.InputInteger(1, TempQty);

                        RetailJournalLine.Init();
                        RetailJournalLine."No." := RetailJournalHeader."No.";
                        RetailJournalLine."Line No." := TempInt;
                        RetailJournalLine.VALIDATE("Item No.", Rec."No.");
                        RetailJournalLine.VALIDATE("Quantity to Print", TempQty);
                        RetailJournalLine.Insert();

                    end;

                }
            }

            group("NPR Print")
            {
                Caption = 'Print';
                Image = Print;

                action("NPR PriceLabel")
                {
                    Caption = 'Price Label';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Image = BinLedger;
                    ShortcutKey = 'Ctrl+Alt+L';

                    ToolTip = 'Allows user to print Price Label for the item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        PrintLabelAndDisplay: Codeunit "NPR Label Library";
                    begin
                        PrintLabelAndDisplay.ResolveVariantAndPrintItem(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                    end;

                }
            }

            group("NPR Variant")
            {
                Caption = 'Variant';
                Description = 'Action';
                Image = Setup;
                action("NPR VarietyMatrix")
                {
                    Caption = 'Variety Matrix';
                    Promoted = True;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Image = ItemVariant;
                    ShortCutKey = 'Ctrl+Alt+I';

                    ToolTip = 'Executes the display Variety Matrix action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTWrapper: Codeunit "NPR Variety Wrapper";
                    begin
                        VRTWrapper.ShowVarietyMatrix(Rec, 0);
                    end;
                }

                action("NPR VarietyMaintenance")
                {
                    Caption = 'Variety Maintenance';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Image = ItemVariant;

                    ToolTip = 'Execute the display Variety Maintenance action. Allows you to view and edit variety for the item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTWrapper: Codeunit "NPR Variety Wrapper";
                    begin
                        VRTWrapper.ShowMaintainItemMatrix(Rec, 0);
                    end;
                }

                action("NPR NPRMissingBarcode")
                {
                    Caption = 'Add missing Barcode(s)';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    Image = BarCode;
                    ToolTip = 'New item reference(s), if not found, will be created based on No. Series set in Variety Setup. How many references are going to be created, it depends on Variety Setup. For details, please check group Barcode (Item Ref.) under the Variety Setup.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.AssignBarcodes(Rec);
                    end;
                }
                action("NPR NPRCreateBarcode")
                {
                    Caption = 'Create Barcode';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    Image = BarCode;
                    ToolTip = 'Window for setting custom barcode will be opened. After setting barcode, new item reference, if not found, will be created with value entered in opened window.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.AssignCustomBarcode(Rec."No.");
                    end;
                }
            }
            group("NPR Related")
            {
                Caption = 'Related';
                action("NPR Accessories")
                {
                    Caption = 'Accessories';
                    Image = Allocations;

                    ToolTip = 'Executes the Accessories action. Allows you to link other items to the item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        AccessorySparePart.FILTERGROUP := 2;


                        AccessorySparePart.SETRANGE(Code, Rec."No.");
                        AccessorySparePart.SETRANGE(Type, AccessorySparePart.Type::Accessory);
                        AccessorySparePart.FILTERGROUP := 2;

                        PAGE.RUNMODAL(PAGE::"NPR Accessory List", AccessorySparePart);
                    end;
                }

                separator(NPR_Separator61514222)
                { }
                action("NPR POSInfo")
                {
                    Caption = 'POS Info';
                    Image = Info;
                    RunObject = Page 6150643;
                    RunPageLink = "Table ID" = const(27), "Primary Key" = field("No.");

                    ToolTip = 'Executes the POS Info action. Allows you to link a POS info code with the item.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        addafter(SalesPriceListsDiscounts)
        {
            group("NPR PriceManagement")
            {
                Caption = 'Price Management';
                action("NPR MultipleUnitPrices")
                {
                    Caption = 'Multiple Unit Prices';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page 6014466;
                    RunPageLink = "Item No." = field("No.");
                    RunPageMode = Edit;

                    ToolTip = 'Setup different unit prices for the item. An item price is automatically granted on the invoice line when the specified criteria are such as quantity are met.';
                    ApplicationArea = NPRRetail;
                }
                action("NPR PeriodDiscount")
                {
                    Caption = 'Period Discount';
                    Image = Period;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ShortCutKey = 'Ctrl+P';

                    ToolTip = 'View all period discount specified for this item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                        CampaignDiscountLines: Page "NPR Campaign Discount Lines";
                    begin
                        CLEAR(CampaignDiscountLines);
                        CampaignDiscountLines.EDITABLE(FALSE);
                        PeriodDiscountLine.Reset();
                        PeriodDiscountLine.SETRANGE(Status, PeriodDiscountLine.Status::Active);
                        PeriodDiscountLine.SETRANGE("Item No.", Rec."No.");
                        CampaignDiscountLines.SETTABLEVIEW(PeriodDiscountLine);
                        CampaignDiscountLines.RunModal();
                    end;
                }
                action("NPR MixDiscount")
                {
                    Caption = 'Mix Discount';
                    Image = Discount;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ShortcutKey = 'Ctrl+F';

                    ToolTip = 'View all mix discount specified for this item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MixedDiscountLine: Record "NPR Mixed Discount Line";
                        MixedDiscountLines: Page "NPR Mixed Discount Lines";

                    begin
                        CLEAR(MixedDiscountLines);
                        MixedDiscountLines.EDITABLE(FALSE);
                        MixedDiscountLine.Reset();
                        MixedDiscountLine.SETRANGE("No.", Rec."No.");
                        MixedDiscountLines.SETTABLEVIEW(MixedDiscountLine);
                        MixedDiscountLines.RunModal();
                    end;

                }
            }
        }

        addafter(Resources)
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                action("NPR Pictures")
                {
                    Caption = 'Pictures';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category9;
                    Visible = MagentoEnabled;
                    Image = Picture;

                    ToolTip = 'Allows you to assign a picture to the item. You can either take a picture or import it.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoVariantPictureList: page "NPR Magento Item Pict. List";
                    begin
                        Rec.TestField("No.");
                        Rec.FilterGroup(2);
                        MagentoVariantPictureList.SetItemNo(Rec."No.");
                        Rec.FILTERGROUP(0);
                        MagentoVariantPictureList.RUN();
                    end;
                }

                action("NPR Videos")
                {
                    Caption = 'Videos';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category9;
                    Image = Camera;
                    Visible = MagentoEnabled;
                    RunObject = page 6151455;
                    RunPageLink = "Item No." = field("No.");

                    ToolTip = 'Executes the Videos action';
                    ApplicationArea = NPRRetail;
                }

                action("NPR Webshops")
                {
                    Caption = 'Webshops';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category9;
                    Visible = MagentoEnabled and MagentoEnabledMultistore;
                    Image = Web;

                    ToolTip = 'Executes the Webshops action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoStoreItem: Record "NPR Magento Store Item";
                        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
                    begin
                        MagentoItemMgt.SetupMultiStoreData(Rec);
                        MagentoStoreItem.FILTERGROUP(0);
                        MagentoStoreItem.SETRANGE("Item No.", Rec."No.");
                        MagentoStoreItem.FILTERGROUP(2);
                        PAGE.RUN(PAGE::"NPR Magento Store Items", MagentoStoreItem);

                    end;

                }
                action("NPR DisplayConfig")
                {
                    Caption = 'Display Config';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category9;
                    Visible = MagentoEnabled AND MagentoEnabledDisplayConfig;
                    Image = ViewPage;

                    ToolTip = 'Executes the Display Config action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoDisplayConfig: Record "NPR Magento Display Config";
                        MagentoDisplayConfigPage: page "NPR Magento Display Config";
                    begin
                        MagentoDisplayConfig.SETRANGE("No.", Rec."No.");
                        MagentoDisplayConfig.SETRANGE(Type, MagentoDisplayConfig.Type::Item);
                        MagentoDisplayConfigPage.SETTABLEVIEW(MagentoDisplayConfig);
                        MagentoDisplayConfigPage.Run();
                    end;
                }

            }
        }

        addlast(Functions)
        {
            action("NPR Add to Purchase Order")
            {
                Caption = 'Add to Purchase Order';
                ToolTip = 'You will create new or select one of existing Purcase Orders and add Item with all its variants (if Item has them).';
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = NPRRetail;
                Image = MakeOrder;

                trigger OnAction();
                var
                    CreatePurchaseOrder: Report "NPR Crt. Purc. Order From Item";
                begin
                    CreatePurchaseOrder.SetValues(Rec);
                    CreatePurchaseOrder.Run();
                end;
            }
        }
    }

    var
        NPRAttrTextArray: array[40] of Text;
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        MagentoEnabled: Boolean;
        MagentoEnabledAttributeSet: Boolean;
        MagentoEnabledCustomOptions: Boolean;
        MagentoEnabledDisplayConfig: Boolean;
        MagentoEnabledBrand: Boolean;
        MagentoEnabledMultistore: Boolean;
        MagentoEnabledProductRelations: Boolean;
        MagentoEnabledSpecialPrices: Boolean;
        MagentoPictureVarietyTypeVisible: Boolean;
        OriginalRec: Record Item;
        AccessorySparePart: Record "NPR Accessory/Spare Part";
        ItemAdditionalFields: Record "NPR Item Additional Fields";
        ItemCostMgt: Codeunit ItemCostManagement;
        NPRCustomOptionCount: Integer;
        AverageCostACY: Decimal;
        Text6151400: Label 'Update Seo Link?';

    trigger OnOpenPage()
    begin
        NPR_SetMagentoEnabled();
        CurrPage.NPRMagentoPictureDragDropAddin.Page.SetAutoOverwrite(true);
        NPRAttrManagement.GetAttributeVisibility(DATABASE::Item, NPRAttrVisibleArray);
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];
        NPRAttrEditable := CurrPage.EDITABLE();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SaveItemAdditionalFields();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.SaveItemAdditionalFields();
    end;

    trigger OnClosePage()
    begin
        Rec.SaveItemAdditionalFields();
    end;

    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Item, Rec."No.");
        NPRAttrEditable := CurrPage.EDITABLE();
        CalcMagentoItemCustomOption();
    end;

    local procedure CalcMagentoItemCustomOption()
    var
        NPRMagentoItemCustomOption: Record "NPR Magento Item Custom Option";
    begin
        NPRMagentoItemCustomOption.SetRange("Item No.", Rec."No.");
        NPRMagentoItemCustomOption.SetRange(Enabled, true);
        NPRCustomOptionCount := NPRMagentoItemCustomOption.Count();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        OriginalRec := Rec;
        CurrPage.NPRMagentoPictureDragDropAddin.Page.SetItemNo(Rec."No.");
        CurrPage.NPRMagentoPictureDragDropAddin.Page.SetHidePicture(true);
        ItemCostMgt.CalculateAverageCost(Rec, AverageCostACY, AverageCostACY);
        Rec.GetItemAdditionalFields(ItemAdditionalFields);
    end;

    procedure NPR_SetMagentoEnabled()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;

        MagentoEnabled := true;
        MagentoEnabledBrand := MagentoSetup."Brands Enabled";
        MagentoEnabledAttributeSet := MagentoSetup."Attributes Enabled";
        MagentoEnabledSpecialPrices := MagentoSetup."Special Prices Enabled";
        MagentoEnabledMultistore := MagentoSetup."Multistore Enabled";
        MagentoEnabledDisplayConfig := MagentoSetup."Customers Enabled";
        MagentoEnabledProductRelations := MagentoSetup."Product Relations Enabled";
        MagentoEnabledCustomOptions := MagentoSetup."Custom Options Enabled";
        MagentoPictureVarietyTypeVisible :=
          (MagentoSetup."Variant System" = MagentoSetup."Variant System"::Variety) and
          (MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::"Select on Item");
    end;

    local procedure NPR_ValidateSEOLink()
    var
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
    begin
        if Rec."NPR Seo Link" <> '' then
            if not Confirm(Text6151400, false) then
                exit;

        Rec."NPR Seo Link" := Rec."NPR Magento Name";
        MagentoItemMgt.UpdateItemSeoLink(Rec);
    end;
}
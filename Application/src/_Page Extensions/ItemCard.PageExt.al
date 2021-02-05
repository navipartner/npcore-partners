pageextension 6014430 "NPR Item Card" extends "Item Card"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description 2 field';
            }
        }

        addafter(Type)
        {
            field("NPR Item Status"; Rec."NPR Item Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Item Status field';
            }

            field("NPR Item Group"; Rec."NPR Item Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Item Group field';
            }

            field("NPR Item Brand"; Rec."NPR Item Brand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Item Brand field';
            }

        }

        addafter("Unit Cost")
        {
            field("NPR NPR_AverageCostACY"; AverageCostACY)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the AverageCostACY field';
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
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Statistics Group field';
                trigger OnValidate()
                begin
                    NPR_CheckItemGroup();
                end;
            }
        }

        addafter(AssemblyBOM)
        {
            field("NPR Explode BOM auto"; Rec."NPR Explode BOM auto")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Explode BOM auto field';
            }
        }

        modify("Search Description")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify(Blocked)
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Costing Method")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Standard Cost")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Last Direct Cost")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Price/Profit Calculation")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Profit %")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Gen. Prod. Posting Group")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("VAT Prod. Posting Group")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Sales Unit of Measure")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Purch. Unit of Measure")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }


        modify("Reorder Point")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }

        modify("Maximum Inventory")
        {
            trigger OnAfterValidate()
            begin
                NPR_CheckItemGroup();
            end;
        }



        addafter("Sales Blocked")
        {
            field("NPR Blocked on Pos"; Rec."NPR Blocked on Pos")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Blocked on Pos field';
            }

            field("NPR Custom Discount Blocked"; Rec."NPR Custom Discount Blocked")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Custom Discount Blocked field';
            }
        }

        addafter("Search Description")
        {
            field("NPR Inventory Value Zero"; Rec."Inventory Value Zero")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Inventory Value Zero field';
            }

        }

        addafter(Inventory)
        {
            field("NPR Sales (Qty.)"; Rec."Sales (Qty.)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sales (Qty.) field';
            }
        }

        addafter("Service Item Group")
        {
            field("NPR Group sale"; Rec."NPR Group sale")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Group sale field';
            }
        }

        addafter("Unit Price")
        {
            field("NPR Unit List Price"; Rec."Unit List Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Unit List Price field';
            }
            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Units per Parcel field';
            }
        }

        addbefore("Cost Details")
        {
            group("NPR NPR_Dimensions")
            {
                Caption = 'Dimensions';
                field("NPR Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }

                field("NPR Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
            }
        }

        addafter("VAT Bus. Posting Gr. (Price)")
        {
            group("NPR NPR_DiscountonPOS")
            {
                Caption = 'Discounts on POS';
                field("NPR Has Mixed Discount"; Rec."NPR Has Mixed Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Has Mixed Discount field';
                    trigger OnDrillDown()
                    var
                        MixedDiscountLines: Page "NPR Mixed Discount Lines";
                        MixedDiscountLine: Record "NPR Mixed Discount Line";
                    begin
                        MixedDiscountLines.Editable(false);
                        MixedDiscountLine.Reset;
                        MixedDiscountLine.SetRange("No.", Rec."No.");
                        MixedDiscountLines.SetTableView(MixedDiscountLine);
                        MixedDiscountLines.RunModal;
                    end;
                }

                field("NPR Has Quantity Discount"; Rec."NPR Has Quantity Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Has Quantity Discount field';
                    trigger OnDrillDown()
                    var
                        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
                        QuantityDiscountCard: Page "NPR Quantity Discount Card";
                    begin
                        QuantityDiscountCard.Editable(false);
                        QuantityDiscountHeader.Reset;
                        QuantityDiscountHeader.SetFilter("Item No.", Rec."No.");
                        QuantityDiscountCard.SetTableView(QuantityDiscountHeader);
                        QuantityDiscountCard.RunModal;
                    end;
                }

                field("NPR Has Period Discount"; Rec."NPR Has Period Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Has Period Discount field';
                    trigger OnDrillDown()
                    var
                        CampaignDiscountLines: Page "NPR Campaign Discount Lines";
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                    begin
                        CampaignDiscountLines.Editable(false);
                        PeriodDiscountLine.Reset;
                        PeriodDiscountLine.SetRange("Item No.", Rec."No.");
                        CampaignDiscountLines.SetTableView(PeriodDiscountLine);
                        CampaignDiscountLines.RunModal;
                    end;
                }
            }
        }


        addafter("Prices & Sales")
        {
            group("NPR NPR_Variety")
            {
                Caption = 'Variety';
                field("NPR Has Variants"; Rec."NPR Has Variants")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Has Variants field';
                }
                field("NPR Variety Group"; Rec."NPR Variety Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety Group field';
                }
                field("NPR Variety 1"; Rec."NPR Variety 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 1 field';
                }
                field("NPR Variety 1 Table"; Rec."NPR Variety 1 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 1 Table field';
                }
                field("NPR Variety 2"; Rec."NPR Variety 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 2 field';
                }
                field("NPR Variety 2 Table"; Rec."NPR Variety 2 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 2 Table field';
                }
                field("NPR Variety 3"; Rec."NPR Variety 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 3 field';
                }
                field("NPR Variety 3 Table"; Rec."NPR Variety 3 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 3 Table field';
                }
                field("NPR Variety 4"; Rec."NPR Variety 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 4 field';
                }
                field("NPR Variety 4 Table"; Rec."NPR Variety 4 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Variety 4 Table field';
                }
                field("NPR Cross Variety No."; Rec."NPR Cross Variety No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Cross Variety No. field';
                }
            }
            group("NPR Properties")
            {
                group("NPR NPR_Control6150684")
                {
                    ShowCaption = false;

                    field("NPR Item AddOn No."; Rec."NPR Item AddOn No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Item AddOn No. field';
                    }
                    field("NPR Guarantee Index"; Rec."NPR Guarantee Index")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Guarantee Index field';
                    }
                    field("NPR Insurrance category"; Rec."NPR Insurrance category")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Insurrance category field';
                    }

                    field("NPR NPRE Item Routing Profile"; Rec."NPR NPRE Item Routing Profile")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR NPRE Item Routing Profile field';
                    }
                }

                group("NPR NPR_Control6150669")
                {
                    ShowCaption = false;

                    field("NPR Guarantee voucher"; Rec."NPR Guarantee voucher")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Guarantee voucher field';
                    }
                    field("NPR No Print on Reciept"; Rec."NPR No Print on Reciept")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR No Print on Reciept field';
                    }
                    field("NPR Ticket Type"; Rec."NPR Ticket Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Ticket Type field';
                    }
                    field("NPR Print Tags"; Rec."NPR Print Tags")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Print Tags field';
                        trigger OnValidate()
                        var
                            PrintTagsPage: Page 6014417;
                        begin

                            CLEAR(PrintTagsPage);
                            PrintTagsPage.SetTagText(Rec."NPR Print Tags");
                            IF PrintTagsPage.RUNMODAL = ACTION::OK THEN
                                Rec."NPR Print Tags" := PrintTagsPage.ToText;

                        end;
                    }
                }
            }

            group("NPR NPR_MagentoEnabled")
            {
                Caption = 'Magento';
                Visible = MagentoEnabled;

                group("NPR NPR_Control6014404")
                {
                    ShowCaption = true;
                    field("NPR Magento Item"; Rec."NPR Magento Item")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the NPR Magento Item field';
                        trigger OnValidate()
                        begin
                            NPR_SetMagentoEnabled();
                        end;
                    }
                    field("NPR Magento Status"; Rec."NPR Magento Status")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the NPR Magento Status field';
                    }
                    field("NPR Magento Name"; Rec."NPR Magento Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Magento Name field';
                        trigger OnValidate()
                        begin
                            IF Rec."NPR Seo Link" <> '' THEN
                                IF NOT CONFIRM(Text6151400, FALSE) THEN
                                    EXIT;
                            Rec.VALIDATE("NPR Seo Link", Rec."NPR Magento Name");
                        end;
                    }
                    field("NPR Magento Description"; Format(Rec."NPR Magento Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Magento Description';
                        ToolTip = 'Specifies the value of the Magento Description field';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);

                            FieldRef := RecRef.Field(Rec.FieldNo("NPR Magento Description"));

                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);

                            end;
                        end;
                    }
                    field("NPR Magento Short Description"; Format(Rec."NPR Magento Short Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Magento Short Description';
                        ToolTip = 'Specifies the value of the Magento Short Description field';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(Rec.FieldNo("NPR Magento Short Description"));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field("NPR Magento Brand"; Rec."NPR Magento Brand")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledBrand;
                        ToolTip = 'Specifies the value of the NPR Magento Brand field';
                    }
                    field("NPR NPR_MagentoUnitPrice"; Rec."Unit Price")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Unit Price field';
                    }
                    field("NPR Product New From"; Rec."NPR Product New From")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Product New From field';
                    }
                    field("NPR Product New To"; Rec."NPR Product New To")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Product New To field';
                    }
                    field("NPR Featured From"; Rec."NPR Featured From")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Featured From field';
                    }
                    field("NPR Featured To"; Rec."NPR Featured To")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Featured To field';
                    }
                    field("NPR Special Price"; Rec."NPR Special Price")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledSpecialPrices;
                        ToolTip = 'Specifies the value of the NPR Special Price field';
                    }
                    field("NPR Special Price From"; Rec."NPR Special Price From")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledSpecialPrices;
                        ToolTip = 'Specifies the value of the NPR Special Price From field';
                    }
                    field("NPR Special Price To"; Rec."NPR Special Price To")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledSpecialPrices;
                        ToolTip = 'Specifies the value of the NPR Special Price To field';
                    }
                    field("NPR Custom Options"; Rec."NPR Custom Options")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledCustomOptions;
                        ToolTip = 'Specifies the value of the NPR Custom Options field';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            MagentoItemCustomOptions: Page "NPR Magento Item Cstm Options";
                        begin
                            Clear(MagentoItemCustomOptions);
                            MagentoItemCustomOptions.SetItemNo(Rec."No.");
                            MagentoItemCustomOptions.Run;
                        end;
                    }
                    field("NPR Backorder"; Rec."NPR Backorder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Backorder field';
                    }
                    field("NPR Display Only"; Rec."NPR Display Only")
                    {
                        ApplicationArea = All;
                        ToolTip = 'test';
                    }
                    field("NPR Display only Text"; Rec."NPR Display only Text")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Display only Text field';
                    }
                    field("NPR Seo Link"; Rec."NPR Seo Link")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Seo Link field';
                    }
                    field("NPR Meta Title"; Rec."NPR Meta Title")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Meta Title field';
                    }
                    field("NPR Meta Description"; Rec."NPR Meta Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Meta Description field';
                    }
                    field("NPR Attribute Set ID"; Rec."NPR Attribute Set ID")
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Editable = NOT Rec."NPR Magento Item";
                        Visible = MagentoEnabledAttributeSet;
                        ToolTip = 'Specifies the value of the NPR Attribute Set ID field';

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

                group("NPR NPR_Control6151430")
                {
                    ShowCaption = false;
                    Visible = MagentoPictureVarietyTypeVisible;
                    field("NPR Magento Picture Variety Type"; Rec."NPR Magento Pict. Variety Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Magento Pict. Variety Type field';
                    }
                }
                part("NPR Magento Category Links"; "NPR Magento Category Links")
                {
                    Caption = 'Category Links';
                    SubPageLink = "Item No." = FIELD("No.");
                    Visible = NOT MagentoEnabledMultiStore;
                    ApplicationArea = All;
                }
                part("NPR Product Relations"; "NPR Magento Product Relations")
                {
                    Caption = 'Product Relations';
                    SubPageLink = "From Item No." = FIELD("No.");
                    Visible = MagentoEnabledProductRelations;
                    ApplicationArea = All;
                }
            }
            group("NPR Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, Rec."No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, Rec."No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, Rec."No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, Rec."No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, Rec."No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 6, Rec."No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 7, Rec."No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 8, Rec."No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 9, Rec."No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

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
                ApplicationArea = All;
                Visible = MagentoEnabled;
            }
            part(NPRPicture; "NPR Magento Item Pict. Factbox")

            {
                ApplicationArea = All;
                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "No." = FIELD("No.");
                Visible = MagentoEnabled;
            }
            part("NPR Discount FactBox"; "NPR Discount FactBox")
            {
                ApplicationArea = All;
                Caption = 'Discounts';
                SubPageLink = "No." = FIELD("No.");
            }
            part(NPRAttributes; "NPR NP Attributes FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("No.");
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
        addafter("Va&riants")
        {
            action("NPR VarietyMatrix")
            {
                Caption = 'Variety Matrix';
                Image = ItemAvailability;
                ShortCutKey = 'Ctrl+Alt+v';
                ApplicationArea = All;
                ToolTip = 'Executes the Variety Matrix action';
            }
            action("NPR AttributeValues")
            {
                Caption = 'All Attributes Values';
                Image = ShowList;
                ApplicationArea = All;
                ToolTip = 'Executes the All Attributes Values action';
            }
        }
        addafter("Application Worksheet")
        {
            action("NPR POSSalesEntries")
            {
                Caption = 'POS Sales Entries';
                Image = Entries;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Sales Entries action';
            }
        }
        addafter("Return Orders")
        {
            action("NPR NPR_RecommendedItems")
            {
                Caption = 'Recommended Items';
                Image = SuggestLines;
                RunObject = Page "NPR MCS Recomm. Lines";
                RunPageLink = "Seed Item No." = field("No."), "Table No." = const(27);
                ApplicationArea = All;
                ToolTip = 'Executes the Recommended Items action';
            }
        }

        addafter("Item Journal")
        {
            action("NPR NPR_RetailItemJournal")
            {
                Caption = 'Retail Item Journal';
                Image = Journals;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page 6014402;
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Item Journal action';
            }

            action("NPR NPR_RetailItemReclassJnl")
            {
                Caption = 'Retail Item Reclassification Journal';
                Image = Journals;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page 6014403;
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Item Reclassification Journal action';
            }
        }

        addafter("Item Tracing")
        {
            action("NPR NPR_ReplicateItem")
            {
                Caption = 'Replicate Item';
                Image = Copy;
                ApplicationArea = All;
                ToolTip = 'Executes the Replicate Item action';

                trigger OnAction()
                begin
                    NPR_ReplicateItem();
                end;

            }
        }

        addafter("NPR NPR_ReplicateItem")
        {
            group("NPR NPR_TransferTo")
            {
                Caption = 'Transfer to';
                Image = Action;

                action("NPR NPR_TransfertoRetailJounal")
                {
                    Caption = 'Transfer to Retail Journal';
                    Image = TransferToGeneralJournal;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Transfer to Retail Journal action';

                    trigger OnAction()
                    var
                        RetailJournalHeader: Record 6014451;
                        RetailJournalLine: Record 6014422;
                        InputDialog: Page 6014449;
                        TempInt: Integer;
                        TempQty: Integer;
                        t001: Label 'Quantity to be transfered to UPDATED?';
                    begin
                        IF PAGE.RUNMODAL(PAGE::"NPR Retail Journal List", RetailJournalHeader) <> ACTION::LookupOK THEN
                            EXIT;

                        RetailJournalLine.RESET;
                        RetailJournalLine.SETRANGE("No.", RetailJournalHeader."No.");
                        IF RetailJournalLine.FIND('+') THEN
                            TempInt := RetailJournalLine."Line No." + 10000
                        ELSE
                            TempInt := 10000;

                        TempQty := 1;

                        InputDialog.SetInput(1, TempQty, t001);
                        IF InputDialog.RUNMODAL = ACTION::OK THEN
                            InputDialog.InputInteger(1, TempQty);

                        RetailJournalLine.INIT;
                        RetailJournalLine."No." := RetailJournalHeader."No.";
                        RetailJournalLine."Line No." := TempInt;
                        RetailJournalLine.VALIDATE("Item No.", Rec."No.");
                        RetailJournalLine.VALIDATE("Quantity to Print", TempQty);
                        RetailJournalLine.INSERT;

                    end;

                }
            }

            group("NPR NPR_Print")
            {
                Caption = 'Print';
                Image = Print;

                action("NPR NPR_PriceLabel")
                {
                    Caption = 'Price Label';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Image = BinLedger;
                    ShortcutKey = 'Shift+F8';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';

                    trigger OnAction()
                    var
                        PrintLabelAndDisplay: Codeunit 6014413;
                        ReportSelectionRetail: Record 6014404;
                    begin
                        PrintLabelAndDisplay.ResolveVariantAndPrintItem(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                    end;

                }
            }

            group("NPR NPR_Variant")
            {
                Caption = 'Variant';
                Description = 'Action';
                Image = Setup;
                action("NPR NPR_VarietyMatrix")
                {
                    Caption = 'Variety Matrix';
                    Promoted = True;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Image = ItemVariant;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety Matrix action';

                    trigger OnAction()
                    var
                        VRTWrapper: Codeunit 6059970;
                    begin
                        VRTWrapper.ShowVarietyMatrix(Rec, 0);
                    end;
                }

                action("NPR NPR_VarietyMaintenance")
                {
                    Caption = 'Variety Maintenance';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    Image = ItemVariant;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety Maintenance action';

                    trigger OnAction()
                    var
                        VRTWrapper: Codeunit 6059970;
                    begin
                        VRTWrapper.ShowMaintainItemMatrix(Rec, 0);
                    end;
                }

                action("NPR NPR_MissingBarcode")
                {
                    Caption = 'Add missing Barcode(s)';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    Image = BarCode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Add missing Barcode(s) action';

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit 6059972;
                    begin
                        VRTCloneData.AssignBarcodes(Rec);
                    end;
                }
            }
            group("NPR NPR_Related")
            {
                Caption = 'Related';
                action("NPR NPR_Accessories")
                {
                    Caption = 'Accessories';
                    Image = Allocations;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Accessories action';

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
                action("NPR NPR_POSInfo")
                {
                    Caption = 'POS Info';
                    Image = Info;
                    RunObject = Page 6150643;
                    RunPageLink = "Table ID" = const(27), "Primary Key" = field("No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Info action';
                }
            }
            group("NPR NPR_PriceManagement")
            {
                Caption = 'Price Management';
                action("NPR NPR_MultipleUnitPrices")
                {
                    Caption = 'Multiple Unit Prices';
                    Image = Price;
                    RunObject = Page 6014466;
                    RunPageLink = "Item No." = field("No.");
                    RunPageMode = Edit;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Multiple Unit Prices action';
                }
                action("NPR NPR_PeriodDiscount")
                {
                    Caption = 'Period Discount';
                    Image = Period;
                    ShortCutKey = 'Ctrl+P';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Period Discount action';

                    trigger OnAction()
                    var
                        CampaignDiscountLines: Page 6014454;
                        PeriodDiscountLine: Record 6014414;
                    begin
                        CLEAR(CampaignDiscountLines);
                        CampaignDiscountLines.EDITABLE(FALSE);
                        PeriodDiscountLine.RESET;
                        PeriodDiscountLine.SETRANGE(Status, PeriodDiscountLine.Status::Active);
                        PeriodDiscountLine.SETRANGE("Item No.", Rec."No.");
                        CampaignDiscountLines.SETTABLEVIEW(PeriodDiscountLine);
                        CampaignDiscountLines.RUNMODAL;
                    end;
                }
                action("NPR NPR_MixDiscount")
                {
                    Caption = 'Mix Discount';
                    Image = Discount;
                    ShortcutKey = 'Ctrl+F';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Mix Discount action';

                    trigger OnAction()
                    var
                        MixedDiscountLines: Page 6014451;
                        MixedDiscountLine: Record 6014412;

                    begin
                        CLEAR(MixedDiscountLines);
                        MixedDiscountLines.EDITABLE(FALSE);
                        MixedDiscountLine.RESET;
                        MixedDiscountLine.SETRANGE("No.", Rec."No.");
                        MixedDiscountLines.SETTABLEVIEW(MixedDiscountLine);
                        MixedDiscountLines.RUNMODAL;
                    end;

                }
            }
        }

        addafter(Resources)
        {
            group("NPR NPR_Magento")
            {
                Caption = 'Magento';
                action("NPR NPR_Pictures")
                {
                    Caption = 'Pictures';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled;
                    Image = Picture;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pictures action';

                    trigger OnAction()
                    var
                        MagentoVariantPictureList: page 6151413;
                    begin
                        Rec.TestField("No.");
                        Rec.FilterGroup(2);
                        MagentoVariantPictureList.SetItemNo(Rec."No.");
                        Rec.FILTERGROUP(0);
                        MagentoVariantPictureList.RUN();
                    end;
                }

                action("NPR NPR_Videos")
                {
                    Caption = 'Videos';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Image = Camera;
                    RunObject = page 6151455;
                    RunPageLink = "Item No." = field("No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Videos action';
                }

                action("NPR NPR_Webshops")
                {
                    Caption = 'Webshops';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled and MagentoEnabledMultistore;
                    Image = Web;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Webshops action';

                    trigger OnAction()
                    var
                        MagentoStoreItem: Record 6151420;
                        MagentoItemMgt: Codeunit 6151407;
                    begin
                        MagentoItemMgt.SetupMultiStoreData(Rec);
                        MagentoStoreItem.FILTERGROUP(0);
                        MagentoStoreItem.SETRANGE("Item No.", Rec."No.");
                        MagentoStoreItem.FILTERGROUP(2);
                        PAGE.RUN(PAGE::"NPR Magento Store Items", MagentoStoreItem);

                    end;

                }
                action("NPR NPR_DisplayConfig")
                {
                    Caption = 'Display Config';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledDisplayConfig;
                    Image = ViewPage;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Display Config action';

                    trigger OnAction()
                    var
                        MagentoDisplayConfig: Record 6151435;
                        MagentoDisplayConfigPage: page 6151443;
                    begin
                        MagentoDisplayConfig.SETRANGE("No.", Rec."No.");
                        MagentoDisplayConfig.SETRANGE(Type, MagentoDisplayConfig.Type::Item);
                        MagentoDisplayConfigPage.SETTABLEVIEW(MagentoDisplayConfig);
                        MagentoDisplayConfigPage.RUN;
                    end;
                }

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
        NPRAttrVisible11: Boolean;
        NPRAttrVisible12: Boolean;
        NPRAttrVisible13: Boolean;
        NPRAttrVisible14: Boolean;
        NPRAttrVisible15: Boolean;
        NPRAttrVisible16: Boolean;
        NPRAttrVisible17: Boolean;
        NPRAttrVisible18: Boolean;
        NPRAttrVisible19: Boolean;
        NPRAttrVisible20: Boolean;
        NPRAttrVisible21: Boolean;
        NPRAttrVisible22: Boolean;
        NPRAttrVisible23: Boolean;
        NPRAttrVisible24: Boolean;
        NPRAttrVisible25: Boolean;
        NPRAttrVisible26: Boolean;
        NPRAttrVisible27: Boolean;
        NPRAttrVisible28: Boolean;
        NPRAttrVisible29: Boolean;
        NPRAttrVisible30: Boolean;
        NPRAttrVisible31: Boolean;
        NPRAttrVisible32: Boolean;
        NPRAttrVisible33: Boolean;
        NPRAttrVisible34: Boolean;
        NPRAttrVisible35: Boolean;
        NPRAttrVisible36: Boolean;
        NPRAttrVisible37: Boolean;
        NPRAttrVisible38: Boolean;
        NPRAttrVisible39: Boolean;
        NPRAttrVisible40: Boolean;

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
        ItemCostMgt: Codeunit ItemCostManagement;
        AverageCostLCY: Decimal;
        AverageCostACY: Decimal;
        SearchNo: code[20];

        Barcode: code[13];

        Text10600012: Label 'Enter item number for new item';

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
        NPRAttrVisible11 := NPRAttrVisibleArray[11];
        NPRAttrVisible12 := NPRAttrVisibleArray[12];
        NPRAttrVisible13 := NPRAttrVisibleArray[13];
        NPRAttrVisible14 := NPRAttrVisibleArray[14];
        NPRAttrVisible15 := NPRAttrVisibleArray[15];
        NPRAttrVisible16 := NPRAttrVisibleArray[16];
        NPRAttrVisible17 := NPRAttrVisibleArray[17];
        NPRAttrVisible18 := NPRAttrVisibleArray[18];
        NPRAttrVisible19 := NPRAttrVisibleArray[19];
        NPRAttrVisible20 := NPRAttrVisibleArray[20];
        NPRAttrVisible21 := NPRAttrVisibleArray[21];
        NPRAttrVisible22 := NPRAttrVisibleArray[22];
        NPRAttrVisible23 := NPRAttrVisibleArray[23];
        NPRAttrVisible24 := NPRAttrVisibleArray[24];
        NPRAttrVisible25 := NPRAttrVisibleArray[25];
        NPRAttrVisible26 := NPRAttrVisibleArray[26];
        NPRAttrVisible27 := NPRAttrVisibleArray[27];
        NPRAttrVisible28 := NPRAttrVisibleArray[28];
        NPRAttrVisible29 := NPRAttrVisibleArray[29];
        NPRAttrVisible30 := NPRAttrVisibleArray[30];
        NPRAttrVisible31 := NPRAttrVisibleArray[31];
        NPRAttrVisible32 := NPRAttrVisibleArray[32];
        NPRAttrVisible33 := NPRAttrVisibleArray[33];
        NPRAttrVisible34 := NPRAttrVisibleArray[34];
        NPRAttrVisible35 := NPRAttrVisibleArray[35];
        NPRAttrVisible36 := NPRAttrVisibleArray[36];
        NPRAttrVisible37 := NPRAttrVisibleArray[37];
        NPRAttrVisible38 := NPRAttrVisibleArray[38];
        NPRAttrVisible39 := NPRAttrVisibleArray[39];
        NPRAttrVisible40 := NPRAttrVisibleArray[40];
        NPRAttrEditable := CurrPage.EDITABLE();

    end;

    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Item, Rec."No.");
        NPRAttrEditable := CurrPage.EDITABLE();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        OriginalRec := Rec;
        CurrPage.NPRMagentoPictureDragDropAddin.Page.SetItemNo(Rec."No.");
        CurrPage.NPRMagentoPictureDragDropAddin.Page.SetHidePicture(true);
        ItemCostMgt.CalculateAverageCost(Rec, AverageCostACY, AverageCostACY);
    end;


    procedure NPR_SetMagentoEnabled()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
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

    procedure NPR_CheckItemGroup()
    begin
        IF (Rec."NPR Item Group" = '') THEN
            Rec.FIELDERROR("NPR Item Group");
    end;

    procedure NPR_ReplicateItem()
    var
        InputDialog: Page "NPR Input Dialog";
        NewItemNo: Code[20];
        ItemCopy: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ItemUnitofMeasureNew: Record "Item Unit of Measure";
    begin
        NewItemNo := '';

        InputDialog.SetInput(1, NewItemNo, Text10600012);
        if InputDialog.RunModal = ACTION::OK then
            InputDialog.InputCode(1, NewItemNo)
        else
            Error('');

        ItemCopy.Copy(Rec);

        ItemCopy.Validate("No.", NewItemNo);
        ItemCopy."Vendor Item No." := '';
        ItemCopy."Search Description" := '';
        ItemCopy."Reorder Point" := 0;
        ItemCopy."Reorder Quantity" := 0;
        ItemCopy."Maximum Inventory" := 0;
        ItemCopy."Units per Parcel" := 0;
        ItemCopy."Search Description" := Rec.Description;
        ItemCopy."NPR Label Barcode" := '';
        ItemCopy."Net Weight" := 0;
        Rec.CalcFields("NPR Magento Description");
        ItemCopy."NPR Magento Description" := Rec."NPR Magento Description";
        ItemCopy.Insert(true);

        ItemUnitofMeasure.SetRange("Item No.", Rec."No.");
        if ItemUnitofMeasure.Find('-') then begin
            repeat
                ItemUnitofMeasureNew.Copy(ItemUnitofMeasure);
                ItemUnitofMeasureNew."Item No." := NewItemNo;
                if ItemUnitofMeasureNew.Insert then;
            until ItemUnitofMeasure.Next = 0;
        end;

        Rec.Get(ItemCopy."No.");
        CurrPage.Update(false);
    end;
}
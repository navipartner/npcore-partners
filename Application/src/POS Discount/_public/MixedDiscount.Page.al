page 6014450 "NPR Mixed Discount"
{
    Caption = 'Mix Discount';
    ContextSensitiveHelpPage = 'retail/Discounts/explanation/discount_types.html';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Mixed Discount";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                grid(Control6150664)
                {
                    GridLayout = Rows;
                    ShowCaption = false;
                    group(Control1)
                    {
                        ShowCaption = false;
                        group(Control6014423)
                        {
                            ShowCaption = false;
                            field("Code"; Rec.Code)
                            {
                                ToolTip = 'Defines the unique code of Mixed Discount';
                                ApplicationArea = NPRRetail;

                                trigger OnAssistEdit()
                                begin
                                    if Rec.Assistedit(xRec) then
                                        CurrPage.Update();
                                end;
                            }
                            field(Description; Rec.Description)
                            {
                                Importance = Promoted;
                                ToolTip = 'Defines the name of Mixed Discount';
                                ApplicationArea = NPRRetail;
                            }
                            group(Control6014409)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Mix Type" <> 2);
                                field("Mix Type"; Rec."Mix Type")
                                {
                                    OptionCaption = 'Standard,Combination';
                                    ToolTip = 'Defines the Mix Type of Mixed Discount';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        UpdateLineView();
                                    end;
                                }
                            }
                            group(Control6014410)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Mix Type" <> 1);
                                group(Control6014428)
                                {
                                    ShowCaption = false;
                                    Visible = (Rec."Discount Type" <> Rec."Discount Type"::"Multiple Discount Levels");
                                    field(Lot; Rec.Lot)
                                    {
                                        ToolTip = 'Define Quantity on Lines - All items and quantity on lines must be bought';
                                        ApplicationArea = NPRRetail;

                                        trigger OnValidate()
                                        begin
                                            UpdateLineView();
                                            CurrPage.Update(true);
                                        end;
                                    }
                                }
                                group(Control6014413)
                                {
                                    ShowCaption = false;
                                    Visible = (NOT Rec.Lot);
                                    field("Min. Quantity"; Rec."Min. Quantity")
                                    {
                                        ToolTip = 'Defines the Minimum Quantity of Mixed Discount';
                                        ApplicationArea = NPRRetail;
                                    }
                                    field("Max. Quantity"; Rec."Max. Quantity")
                                    {
                                        ToolTip = 'Defines the Maximum Quantity of Mixed Discount';
                                        ApplicationArea = NPRRetail;
                                    }
                                }
                            }
                            group(Control6014422)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Mix Type" = 1) OR (Rec.Lot);
                                field(ItemQtyPerLot; Rec.CalcMinQty())
                                {
                                    Caption = 'Item Qty. per Lot';
                                    DecimalPlaces = 0 : 5;
                                    ToolTip = 'Defines the Item Quantity per Lot for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                            group(Control6014407)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Discount Type" <> Rec."Discount Type"::"Total Discount Amt. per Min. Qty.") AND (Rec."Discount Type" <> Rec."Discount Type"::"Multiple Discount Levels") AND (NOT Rec."Lot");
                                field(MinimumDiscount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, false))
                                {
                                    Caption = 'Min. Discount Amount';
                                    ToolTip = 'Defines the Minimum Discount Amount for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                                field(MaximumDiscount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, true))
                                {
                                    Caption = 'Max. Discount Amount';
                                    Editable = false;
                                    ToolTip = 'Defines the Maximum Discount Amount for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                            group(Control6014417)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Discount Type" <> Rec."Discount Type"::"Total Discount Amt. per Min. Qty.") AND (Rec."Lot");
                                field(Discount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, true))
                                {
                                    Caption = 'Discount Amount';
                                    Editable = false;
                                    ToolTip = 'Defines the Discount Amount for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                        }
                    }
                    group(Control2)
                    {
                        ShowCaption = false;
                        group(Control6014420)
                        {
                            ShowCaption = false;
                            Visible = (Rec."Mix Type" <> 2);

                            field(Status; Rec.Status)
                            {
                                ToolTip = 'Defines the Status for Mixed Discount';
                                ApplicationArea = NPRRetail;
                            }
                            field("Discount Type"; Rec."Discount Type")
                            {
                                ToolTip = 'Defines the Discount Type for Mixed Discount';
                                ApplicationArea = NPRRetail;

                                trigger OnValidate()
                                begin
                                    UpdateLineView();
                                    CurrPage.Update(true);
                                end;
                            }
                            group(Control6014403)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Discount Type" = Rec."Discount Type"::"Total Amount per Min. Qty.");
                                field("Total Amount"; Rec."Total Amount")
                                {
                                    ToolTip = 'Defines the Total Amount for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                                field("Total Amount Excl. VAT"; Rec."Total Amount Excl. VAT")
                                {
                                    Caption = 'Total Amount Excl. VAT';
                                    ToolTip = 'Specifies whether the Total Amount is tax-exclusive.';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                            group(Control6014426)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Discount Type" = Rec."Discount Type"::"Multiple Discount Levels");
                                field(DiscAmountExclVAT; Rec."Total Amount Excl. VAT")
                                {
                                    Caption = 'Discount Amount Excl. VAT';
                                    ToolTip = 'Specifies whether the discount amounts, specified on the Mix Discount Levels section, are tax-exclusive.';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                            group(Control6014404)
                            {
                                ShowCaption = false;
                                Visible = Rec."Discount Type" = Rec."Discount Type"::"Total Discount %";
                                field("Total Discount %"; Rec."Total Discount %")
                                {
                                    ToolTip = 'Defines the Total Discount % for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                            group(Control6014405)
                            {
                                ShowCaption = false;
                                Visible = Rec."Discount Type" = Rec."Discount Type"::"Total Discount Amt. per Min. Qty.";
                                field("Total Discount Amount"; Rec."Total Discount Amount")
                                {
                                    ToolTip = 'Defines the Total Discount Amount for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                                field(TotalAmtExclVAT; Rec."Total Amount Excl. VAT")
                                {
                                    Caption = 'Total Discount Amount Excl. VAT';
                                    ToolTip = 'Specifies whether the Total Discount Amount is tax-exclusive.';
                                    ApplicationArea = NPRRetail;
                                }
                            }
                            group(Control6014416)
                            {
                                ShowCaption = false;
                                Visible = Rec."Discount Type" = Rec."Discount Type"::"Priority Discount per Min. Qty";
                                field("Item Discount Qty."; Rec."Item Discount Qty.")
                                {
                                    ToolTip = 'Defines the Item Discount Quantity for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                                field("Item Discount %"; Rec."Item Discount %")
                                {
                                    ToolTip = 'Defines the Item Discount % for Mixed Discount';
                                    ApplicationArea = NPRRetail;
                                }
                            }

                        }

                        group(Control6014411)
                        {
                            ShowCaption = false;
                            Visible = Rec."Mix Type" <> 2;
                            field("Block Custom Discount"; Rec."Block Custom Discount")
                            {
                                ToolTip = 'Block the Custom Discount for Mixed Discount';
                                ApplicationArea = NPRRetail;
                            }
                        }

                    }
                }
            }
            group(Conditions)
            {
                Caption = 'Conditions';
                Visible = Rec."Mix Type" <> 2;
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("Starting date"; Rec."Starting date")
                    {
                        Importance = Promoted;
                        ToolTip = 'Defines the Start Date for Mixed Discount';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending date"; Rec."Ending date")
                    {
                        Importance = Promoted;
                        ToolTip = 'Defines the End Date for Mixed Discount';
                        ApplicationArea = NPRRetail;
                    }
                    field("Starting time"; Rec."Starting time")
                    {
                        Visible = false;
                        ToolTip = 'Defines the Start Time for Mixed Discount';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending time"; Rec."Ending time")
                    {
                        Visible = false;
                        ToolTip = 'Defines the End Time for Mixed Discount';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Disc. Group Filter"; Rec."Customer Disc. Group Filter")
                    {
                        AssistEdit = false;
                        ToolTip = 'Defines the Customer Disc. Group Filter for Mixed Discount';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        begin
                            FilterAssist(Rec.FieldNo("Customer Disc. Group Filter"));
                        end;
                    }
                }
            }


            part(Control6014425; "NPR Mixed Disc. Time Interv.")
            {
                SubPageLink = "Mix Code" = FIELD(Code);
                ApplicationArea = NPRRetail;
            }

            part(DiscountLevels; "NPR Mixed Discount Levels")
            {
                SubPageLink = "Mixed Discount Code" = FIELD(Code);
                Visible = DiscountLevelsApplicable;
                ApplicationArea = NPRRetail;
            }
            part(SubForm; "NPR Mixed Discount Lines")
            {
                ShowFilter = false;
                SubPageLink = Code = FIELD(Code);
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6014411),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';
                ToolTip = 'Open the Default Dimensions List';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            group("&Function")
            {
                Caption = '&Function';
                group("Mix Discount")
                {
                    Caption = 'Mix Discount';
                    Image = Administration;
                    action("Transfer Item")
                    {
                        Caption = 'Transfer Item';
                        Image = TransferToLines;
                        ToolTip = 'Transfer an individual item to the Mixed Discount';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            ItemList: Page "Item List";
                        begin
                            ItemList.LookupMode := true;
                            if (ItemList.RunModal() = ACTION::LookupOK) then begin
                                Item.Reset();
                                ItemList.GetRecord(Item);
                                Item.SetRange("No.", Item."No.");
                                TransferToMix();
                            end;
                        end;
                    }
                    action("Transfer Item Category")
                    {
                        Caption = 'Transfer Item Category';
                        Image = TransferToLines;
                        ToolTip = 'Transfer all items from a specific category to the Mixed Discount';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            ItemCategory: Record "Item Category";
                            ItemCategories: Page "Item Categories";
                        begin
                            ItemCategories.LookupMode := true;
                            if (ItemCategories.RunModal() = ACTION::LookupOK) then begin
                                Item.Reset();
                                ItemCategories.GetRecord(ItemCategory);
                                Item.SetRange("Item Category Code", ItemCategory.Code);
                                TransferToMix();
                            end;
                        end;
                    }
                    action("Transfer Vendor")
                    {
                        Caption = 'Transfer Vendor';
                        Image = TransferToLines;
                        ToolTip = 'Transfer items from a specific vendor to the Mixed Discount';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Vendor: Record Vendor;
                            VendorList: Page "Vendor List";
                        begin
                            VendorList.LookupMode := true;
                            if (VendorList.RunModal() = ACTION::LookupOK) then begin
                                VendorList.GetRecord(Vendor);
                                Item.Reset();
                                Item.SetRange("Vendor No.", Vendor."No.");
                                TransferToMix();
                            end;
                        end;
                    }
                    action("Transfer All Items")
                    {
                        Caption = 'Transfer All Items';
                        Image = TransferToLines;
                        ToolTip = 'Transfer all available items to the Mixed Discount';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            OkCancelQst: Label 'Transfer all items to this mix?';
                        begin
                            Item.Reset();
                            if Confirm(OkCancelQst, false) then
                                TransferToMix();
                        end;
                    }
                    action("Compress to Item Disc. Group")
                    {
                        Caption = 'Compress to Item Disc. Group';
                        Image = "Action";
                        ToolTip = 'Compress the Mixed Discount into an Item Discount Group';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            CollapseToItemDiscGroup();
                        end;
                    }
                }

                separator(Separator1160330020)
                {
                }
                action("Send to Retail Journal")
                {
                    Caption = 'Send to Retail Journal';
                    Image = SendTo;
                    ToolTip = 'Send the Mixed Discount to the Retail Journal for accurate tracking and reporting';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailJournalMgt: Codeunit "NPR Retail Journal Code";
                    begin
                        RetailJournalMgt.Mix2RetailJnl(Rec.Code, '');
                    end;
                }
                action("Copy campaign to Department Code")
                {
                    Caption = 'Copy campaign to Department Code';
                    Image = "Action";
                    ToolTip = 'Copy the campaign details to a specific Department Code';
                    ApplicationArea = NPRRetail;
                    ObsoleteTag = 'NPR24.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Not used';
                }
                action("Copy Mixed Discount")
                {
                    Caption = 'Copy Mixed Discount';
                    Image = CopyDocument;
                    Enabled = Rec.Code <> '';
                    ToolTip = 'Copy the Mixed Discount. To copy Mixed Discount lines, Mixed Discount must be created';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MixedDiscount: Record "NPR Mixed Discount";
                        MixedDiscountLine: Record "NPR Mixed Discount Line";
                    begin
                        if Page.RunModal(Page::"NPR Mixed Discount List", MixedDiscount) <> Action::LookupOK then
                            exit;
                        MixedDiscountLine.SetRange(Code, Rec.Code);
                        MixedDiscountLine.DeleteAll();

                        MixedDiscountLine.SetRange(Code, MixedDiscount.Code);
                        if MixedDiscountLine.FindSet() then
                            repeat
                                MixedDiscountLine.Init();
                                MixedDiscountLine.TransferFields(MixedDiscountLine);
                                MixedDiscountLine.Code := Rec.Code;
                                MixedDiscountLine.Insert(true);
                            until MixedDiscountLine.Next() = 0;
                    end;
                }
            }
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                ToolTip = 'Start importing the file from the scanner.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InventorySetup: Record "Inventory Setup";
                    ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
                    RecRef: RecordRef;
                begin
                    if not InventorySetup.Get() then
                        exit;

                    RecRef.GetTable(Rec);
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::MIXEDDISCOUNT, RecRef);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateLineView();
    end;

    var
        Item: Record Item;
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
        CompressItemslbl: Label 'Compressed to Item Discount Group';
        CompChngeContinueQst: Label 'Compression will change one or more Item Disc. Group. Do you wish to continue?';
        DiscountLevelsApplicable: Boolean;

    internal procedure TransferToMix()
    var
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        ItemNoErr: Label 'No Items has been selected for transfer';
        ItemNo2Err: Label 'Item No. %1 allready exists in the mix', Comment = '%1 = Item no.';
        TransferDoneLbl: Label '%1 Item(s) has been transferred to Mix No. %2', Comment = '%1 = No. of item, %2 = mix no.';
    begin
        if Item.IsEmpty() then
            Error(ItemNoErr);

        if Item.FindSet() then
            repeat
                if NPRMixedDiscountLine.Get(Rec.Code, NPRMixedDiscountLine."Disc. Grouping Type"::Item, Item."No.", '') then
                    Error(ItemNo2Err, Item."No.");
                NPRMixedDiscountLine.Init();
                NPRMixedDiscountLine.Code := Rec.Code;
                NPRMixedDiscountLine."No." := Item."No.";
                NPRMixedDiscountLine."Disc. Grouping Type" := NPRMixedDiscountLine."Disc. Grouping Type"::Item;
                NPRMixedDiscountLine.Quantity := 1;
                NPRMixedDiscountLine.Description := Item.Description;
                NPRMixedDiscountLine.Status := Rec.Status;
                NPRMixedDiscountLine.Insert();
            until Item.Next() = 0;
        Message(TransferDoneLbl, Item.Count, Rec.Code);
    end;

    internal procedure CollapseToItemDiscGroup()
    var
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        ItemDiscGrpRec: Record "Item Discount Group";
    begin
        if not Confirm(CompChngeContinueQst, false) then
            exit;

        ItemDiscGrpRec.Init();
        ItemDiscGrpRec.Code := Rec.Code;
        ItemDiscGrpRec.Description := CopyStr(CompressItemsLbl, 1, MaxStrLen(ItemDiscGrpRec.Description));
        if ItemDiscGrpRec.Insert(true) then;

        NPRMixedDiscountLine.ClearMarks();
        NPRMixedDiscountLine.SetRange(Code, Rec.Code);
        if NPRMixedDiscountLine.FindSet() then
            repeat
                if NPRMixedDiscountLine."Disc. Grouping Type" = NPRMixedDiscountLine."Disc. Grouping Type"::Item then begin
                    Item.Reset();
                    if Item.Get(NPRMixedDiscountLine."No.") then
                        if not Item."NPR Group sale" then begin
                            Item."Item Disc. Group" := Rec.Code;
                            Item.Modify(true);
                            NPRMixedDiscountLine.Mark(true);
                        end;
                end;
            until NPRMixedDiscountLine.Next() = 0;

        NPRMixedDiscountLine.MarkedOnly(true);
        NPRMixedDiscountLine.DeleteAll(true);

        NPRMixedDiscountLine.ClearMarks();
        Clear(NPRMixedDiscountLine);
        NPRMixedDiscountLine.Init();
        NPRMixedDiscountLine.Validate(Code, Rec.Code);
        NPRMixedDiscountLine."Disc. Grouping Type" := NPRMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group";
        NPRMixedDiscountLine."No." := Rec.Code;
        NPRMixedDiscountLine.Description := CompressItemslbl;
        if not NPRMixedDiscountLine.Insert(true) then
            if NPRMixedDiscountLine.Modify(true) then;
    end;

    local procedure GetFieldCaption(CaptionFieldNo: Integer) Caption: Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(Rec);
        FieldRef := RecRef.Field(CaptionFieldNo);
        Caption := FieldRef.Caption;
        exit(Caption);
    end;

    local procedure GetPrimaryKeyValue(var RecRef: RecordRef): Text
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRef := KeyRef.FieldIndex(KeyRef.FieldCount);
        exit(FieldRef.Value);
    end;

    local procedure FilterAssist(AssistFieldNo: Integer)
    var
        RecRef: RecordRef;
        Caption: Text;
    begin
        if not SetFiltersOnRecRef(AssistFieldNo, RecRef) then
            exit;
        Caption := GetFieldCaption(AssistFieldNo);
        if not RunDynamicRequestPage(Caption, RecRef) then
            exit;

        UpdateFiltersOnCurrRec(AssistFieldNo, RecRef);
    end;

    local procedure RunDynamicRequestPage(Caption: Text; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        OutStream: OutStream;
        ReturnFilters: Text;
        EntityID: Code[20];
    begin
        EntityID := CopyStr(Caption, 1, 20);
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number) then
            exit(false);
        FilterPageBuilder.SetView(RecRef.Caption, RecRef.GetView());
        FilterPageBuilder.PageCaption := Caption;
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset();
        if ReturnFilters <> '' then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit;
        end;

        exit(true);
    end;

    local procedure SetFiltersOnRecRef(FilterFieldNo: Integer; var RecRef: RecordRef): Boolean
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        case FilterFieldNo of
            Rec.FieldNo("Customer Disc. Group Filter"):
                begin
                    CustomerDiscountGroup.SetFilter(Code, Rec."Customer Disc. Group Filter");
                    RecRef.GetTable(CustomerDiscountGroup);
                    exit(true);
                end;
        end;

        exit(false);
    end;

    local procedure UpdateFiltersOnCurrRec(FilterFieldNo: Integer; RecRef: RecordRef)
    var
        CurrRecRef: RecordRef;
        CurrFieldRef: FieldRef;
        PrimaryKeyFilter: Text;
    begin
        CurrRecRef.GetTable(Rec);
        CurrFieldRef := CurrRecRef.Field(FilterFieldNo);

        if RecRef.IsEmpty then begin
            CurrFieldRef.Value := '';
            CurrRecRef.SetTable(Rec);
            exit;
        end;

        RecRef.FindSet();
        PrimaryKeyFilter := GetPrimaryKeyValue(RecRef);
        while RecRef.Next() <> 0 do
            PrimaryKeyFilter += '|' + GetPrimaryKeyValue(RecRef);

        CurrFieldRef.Value := CopyStr(PrimaryKeyFilter, 1, CurrFieldRef.Length);
        CurrRecRef.SetTable(Rec);
    end;

    local procedure UpdateLineView()
    begin
        CurrPage.SubForm.PAGE.UpdateMixedDiscountView(Rec);
        DiscountLevelsApplicable := Rec."Discount Type" = Rec."Discount Type"::"Multiple Discount Levels";
    end;
}

﻿page 6014450 "NPR Mixed Discount"
{
    Extensible = False;
    Caption = 'Mix Discount';
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

                                ToolTip = 'Specifies the value of the Code field';
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
                                ToolTip = 'Specifies the value of the Description field';
                                ApplicationArea = NPRRetail;
                            }
                            group(Control6014409)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Mix Type" <> 2);
                                field("Mix Type"; Rec."Mix Type")
                                {

                                    OptionCaption = 'Standard,Combination';
                                    ToolTip = 'Specifies the value of the Mix Type field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        UpdateLineView();
                                        CurrPage.Update(true);
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

                                        ToolTip = 'Specifies the value of the Min. Quantity field';
                                        ApplicationArea = NPRRetail;

                                        trigger OnValidate()
                                        begin
                                            CurrPage.Update(true);
                                        end;
                                    }
                                    field("Max. Quantity"; Rec."Max. Quantity")
                                    {

                                        ToolTip = 'Specifies the value of the Max. Quantity field';
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
                                    ToolTip = 'Specifies the value of the Item Qty. per Lot field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update(true);
                                    end;
                                }
                            }
                            group(Control6014407)
                            {
                                ShowCaption = false;
                                Visible = (Rec."Discount Type" <> Rec."Discount Type"::"Total Discount Amt. per Min. Qty.") AND (Rec."Discount Type" <> Rec."Discount Type"::"Multiple Discount Levels") AND (NOT Rec."Lot");
                                field(MinimumDiscount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, false))
                                {

                                    Caption = 'Min. Discount Amount';
                                    ToolTip = 'Specifies the value of the Min. Discount Amount field';
                                    ApplicationArea = NPRRetail;
                                }
                                field(MaximumDiscount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, true))
                                {

                                    Caption = 'Max. Discount Amount';
                                    Editable = false;
                                    ToolTip = 'Specifies the value of the Max. Discount Amount field';
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
                                    ToolTip = 'Specifies the value of the Discount Amount field';
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

                                ToolTip = 'Specifies the value of the Status field';
                                ApplicationArea = NPRRetail;
                            }
                            field("Discount Type"; Rec."Discount Type")
                            {

                                ToolTip = 'Specifies the value of the Discount Type field';
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

                                    ToolTip = 'Specifies the value of the Total Amount field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update(true);
                                    end;
                                }
                                field("Total Amount Excl. VAT"; Rec."Total Amount Excl. VAT")
                                {

                                    ToolTip = 'Specifies the value of the Total Amount Excl. VAT field';
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
                                    ToolTip = 'Specifies the value of the Discount Amount Excl. VAT field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update();
                                    end;
                                }
                            }
                            group(Control6014404)
                            {
                                ShowCaption = false;
                                Visible = Rec."Discount Type" = Rec."Discount Type"::"Total Discount %";
                                field("Total Discount %"; Rec."Total Discount %")
                                {

                                    ToolTip = 'Specifies the value of the Total Discount % field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update(true);
                                    end;
                                }
                            }
                            group(Control6014405)
                            {
                                ShowCaption = false;
                                Visible = Rec."Discount Type" = Rec."Discount Type"::"Total Discount Amt. per Min. Qty.";
                                field("Total Discount Amount"; Rec."Total Discount Amount")
                                {

                                    ToolTip = 'Specifies the value of the Total Discount Amount field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update(true);
                                    end;
                                }
                            }
                            group(Control6014416)
                            {
                                ShowCaption = false;
                                Visible = Rec."Discount Type" = Rec."Discount Type"::"Priority Discount per Min. Qty";
                                field("Item Discount Qty."; Rec."Item Discount Qty.")
                                {

                                    ToolTip = 'Specifies the value of the Item Discount Quantity field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update(true);
                                    end;
                                }
                                field("Item Discount %"; Rec."Item Discount %")
                                {

                                    ToolTip = 'Specifies the value of the Item Discount % field';
                                    ApplicationArea = NPRRetail;

                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update(true);
                                    end;
                                }
                            }

                        }

                        group(Control6014411)
                        {
                            ShowCaption = false;
                            Visible = Rec."Mix Type" <> 2;
                            field("Block Custom Discount"; Rec."Block Custom Discount")
                            {

                                ToolTip = 'Specifies the value of the Block Custom Discount field';
                                ApplicationArea = NPRRetail;
                            }
                        }
                        field("Created the"; Rec."Created the")
                        {

                            Editable = false;
                            ToolTip = 'Specifies the value of the Created Date field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Last Date Modified"; Rec."Last Date Modified")
                        {

                            Editable = false;
                            ToolTip = 'Specifies the value of the Last Date Modified field';
                            ApplicationArea = NPRRetail;
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
                        ToolTip = 'Specifies the value of the Start Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending date"; Rec."Ending date")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the End Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Starting time"; Rec."Starting time")
                    {

                        Visible = false;
                        ToolTip = 'Specifies the value of the Start Time field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending time"; Rec."Ending time")
                    {

                        Visible = false;
                        ToolTip = 'Specifies the value of the End Time field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Disc. Group Filter"; Rec."Customer Disc. Group Filter")
                    {

                        AssistEdit = false;
                        ToolTip = 'Specifies the value of the Customer Disc. Group Filter field';
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

                ToolTip = 'Executes the Dimensions action';
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

                        ToolTip = 'Executes the Transfer Item action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            ItemList: Page "Item List";
                        begin
                            Clear(ItemList);
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

                        ToolTip = 'Executes the Transfer Item Category action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            ItemCategory: Record "Item Category";
                            ItemCategories: Page "Item Categories";
                        begin
                            Clear(ItemCategories);
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

                        ToolTip = 'Executes the Transfer Vendor action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Kreditor: Record Vendor;
                            KreditorForm: Page "Vendor List";
                        begin
                            Clear(KreditorForm);
                            KreditorForm.LookupMode := true;
                            if (KreditorForm.RunModal() = ACTION::LookupOK) then begin
                                KreditorForm.GetRecord(Kreditor);
                                Item.Reset();
                                Item.SetRange("Vendor No.", Kreditor."No.");
                                TransferToMix();
                            end;
                        end;
                    }
                    action("Transfer All Items")
                    {
                        Caption = 'Transfer All Items';
                        Image = TransferToLines;

                        ToolTip = 'Executes the Transfer All Items action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            MsgOkCancel: Label 'Transfer all items to this mix?';
                        begin
                            Item.Reset();
                            if DIALOG.Confirm(MsgOkCancel, false) then
                                TransferToMix();
                        end;
                    }
                    action("Compress to Item Disc. Group")
                    {
                        Caption = 'Compress to Item Disc. Group';
                        Image = "Action";

                        ToolTip = 'Executes the Compress to Item Disc. Group action';
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

                    ToolTip = 'Executes the Send to Retail Journal action';
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

                    ToolTip = 'Executes the Copy campaign to Department Code action';
                    ApplicationArea = NPRRetail;
                }
                action("Copy Mixed Discount")
                {
                    Caption = 'Copy Mixed Discount';
                    Image = CopyDocument;

                    Enabled = Rec.Code <> '';
                    ToolTip = 'Executes the Copy Mixed Discount action. To copy Mixed Discount lines, Mixed Discount must be created.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MixedDiscount1: Record "NPR Mixed Discount";
                        MixedDiscountLine1: Record "NPR Mixed Discount Line";
                    begin
                        if PAGE.RunModal(PAGE::"NPR Mixed Discount List", MixedDiscount1) <> ACTION::LookupOK then
                            exit;
                        MixedDiscountLine1.SetRange(Code, Rec.Code);
                        MixedDiscountLine1.DeleteAll();

                        MixedDiscountLine1.SetRange(Code, MixedDiscount1.Code);
                        if MixedDiscountLine1.FindSet() then
                            repeat
                                MixedDiscountLine.Init();
                                MixedDiscountLine.TransferFields(MixedDiscountLine1);
                                MixedDiscountLine.Code := Rec.Code;
                                MixedDiscountLine.Insert(true);
                            until MixedDiscountLine1.Next() = 0;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateLineView();
    end;

    trigger OnOpenPage()
    begin
        UpdateLineView();
    end;

    var
        Item: Record Item;
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        TxtCompressItems: Label 'Compressed to Item Discount Group';
        TxtCompChngeContinue: Label 'Compression will change one or more Item Disc. Group. Do you wish to continue?';
        DiscountLevelsApplicable: Boolean;
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";

    internal procedure TransferToMix()
    var
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        ErrorNo1: Label 'No Items has been selected for transfer';
        ErrorNo2: Label 'Item No. %1 allready exists in the mix';
        OkMsg: Label '%1 Item(s) has been transferred to Mix No. %2';
        MixedDiscountList: Page "NPR Mixed Discount List";
    begin
        if not Item.Find('-') then
            Error(ErrorNo1);
        Clear(MixedDiscountList);
        repeat
            if NPRMixedDiscountLine.Get(Rec.Code, NPRMixedDiscountLine."Disc. Grouping Type"::"Mix Discount", Item."No.", '') then
                Error(ErrorNo2, Item."No.");
            NPRMixedDiscountLine.Init();
            NPRMixedDiscountLine.Code := Rec.Code;
            NPRMixedDiscountLine."No." := Item."No.";
            NPRMixedDiscountLine.Quantity := 1;
            NPRMixedDiscountLine.Description := Item.Description;
            NPRMixedDiscountLine."Unit cost" := Item."Unit Cost";
            NPRMixedDiscountLine."Unit price incl. VAT" := Item."Price Includes VAT";
            NPRMixedDiscountLine.Status := Rec.Status;
            NPRMixedDiscountLine."Unit price" := Item."Unit Price";
            NPRMixedDiscountLine.Insert();
        until Item.Next() = 0;
        Message(OkMsg, Item.Count, Rec.Code);
    end;

    internal procedure CollapseToItemDiscGroup()
    var
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        ItemDiscGrpRec: Record "Item Discount Group";
    begin
        if not Confirm(TxtCompChngeContinue) then
            exit;

        Clear(ItemDiscGrpRec);
        ItemDiscGrpRec.Init();
        ItemDiscGrpRec.Code := Rec.Code;
        ItemDiscGrpRec.Description := CopyStr(TxtCompressItems, 1, MaxStrLen(ItemDiscGrpRec.Description));
        if ItemDiscGrpRec.Insert(true) then;

        Clear(NPRMixedDiscountLine);
        NPRMixedDiscountLine.ClearMarks();
        NPRMixedDiscountLine.SetRange(Code, Rec.Code);
        if NPRMixedDiscountLine.Find('-') then
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
        NPRMixedDiscountLine.Description := TxtCompressItems;
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


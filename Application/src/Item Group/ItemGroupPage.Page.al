page 6014421 "NPR Item Group Page"
{
    // NPR70.00.01.04/LS/20121222  CASE  201562 added action Create Item From Item Group
    // NPR70.00.02.04/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // VRT1.00/JDH/20150305  CASE 201022 Variety Group Added
    // NPR5.20/JDH/20160218 CASE 234014 restructured Item Group - deleted code on trigger "OnNextRecord" (to get default behaviour)
    // NPR5.23/JDH /20160516 CASE 240916 Removed VariaX References
    // NPR5.26/LS  /20160824 CASE 249735 Removed field "Used" and global variable Text "Text10600001" + Modified action "Page Item List"
    // NPR5.27/JDH /20161018 CASE 255575 Removed action Create item groups as item, since there was no code that did anything in the database
    // NPR5.30/TJ  /20170213 CASE 265534 Added field Config. Template Header to Settings tab
    // NPR5.38/BR  /20180125 CASE 302803 Added Field "Tax Group Code"
    // NPR5.41/TS  /20180105 CASE 300893 Added s to Picture
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.48/BHR /20190107 CASE 334217 Added Field Type

    Caption = 'Item Group';
    PromotedActionCategories = 'New,Process,Prints,History,Items,Test6,Test7,Test8';
    SourceTable = "NPR Item Group";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Webshop Picture"; "Webshop Picture")
                {
                    ApplicationArea = All;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        BlockedOnAfterValidate;
                    end;
                }
            }
            group(Settings)
            {
                Caption = 'Settings';
                field("Parent Item Group No."; "Parent Item Group No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ParentItemGroupOnAfterValidate;
                    end;
                }
                field("Used Goods Group"; "Used Goods Group")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Item Discount Group"; "Item Discount Group")
                {
                    ApplicationArea = All;
                }
                field(Warranty; Warranty)
                {
                    ApplicationArea = All;
                    Caption = 'Warranty certificate';

                    trigger OnValidate()
                    begin
                        GarantibevisOnAfterValidate;
                    end;
                }
                field("Warranty File"; "Warranty File")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        WarrantyFileOnAfterValidate;
                    end;
                }
                field("Insurance Category"; "Insurance Category")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        InsuranceSectOnAfterValidate;
                    end;
                }
                field("Tarif No."; "Tarif No.")
                {
                    ApplicationArea = All;
                }
                field(Level; Level)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Belongs In Main Item Group"; "Belongs In Main Item Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Internet; Internet)
                {
                    ApplicationArea = All;
                }
                field("Variety Group"; "Variety Group")
                {
                    ApplicationArea = All;
                }
                field("Config. Template Header"; "Config. Template Header")
                {
                    ApplicationArea = All;
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group("VAT Setup")
                {
                    Caption = 'VAT Setup';
                    field("VATPostingSetup.""VAT %"""; VATPostingSetup."VAT %")
                    {
                        ApplicationArea = All;
                        Caption = 'VAT %';
                        Editable = false;
                    }
                    field("GLAccountSale.""No."""; GLAccountSale."No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Account Sales VAT';
                        Editable = false;
                    }
                    field("GLAccountSale.Name"; GLAccountSale.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Account Name';
                        Editable = false;
                    }
                    field("GLAccountPurch.""No."""; GLAccountPurch."No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Account Purchase VAT';
                        Editable = false;
                    }
                    field("GLAccountPurch.Name"; GLAccountPurch.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Account Name';
                        Editable = false;
                    }
                    field("GLAccountReverse.""No."""; GLAccountReverse."No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Account Recipient';
                        Editable = false;
                    }
                    field("GLAccountReverse.Name"; GLAccountReverse.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Account Name';
                        Editable = false;
                    }
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.20
                        //GenProdPostGrOnAfterValidate;
                        LoadRecReferences;
                        //+NPR5.20
                    end;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.20
                        //IF ("Gen. Bus. Posting Group" <> '') AND ("VAT Prod. Posting Group" <> '') THEN
                        //  GetVatSetupDescription()
                        //ELSE
                        //  VATPercent := 0;
                        LoadRecReferences;
                        //+NPR5.20
                    end;
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                }
            }
            group(Pictures)
            {
                Caption = 'Pictures';
                field(Control1160330017; Picture)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
            part(SubForm; "NPR Item Group Subpage")
            {
                Caption = 'Child Groups';
                SubPageLink = "Parent Item Group No." = FIELD(FILTER("No."));
                SubPageView = SORTING("No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Picture)
            {
                Caption = 'Picture';
                Image = Picture;
                action("Insert picture")
                {
                    Caption = 'Insert picture';
                    Image = Picture;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        Name: Text[200];
                        TextName: Text[1024];
                        PictureExists: Boolean;
                        Index: Integer;
                        Text001: Label 'Do you want to replace the existing picture of %1 %2?';
                        RecRef: RecordRef;
                    begin
                        PictureExists := Picture.HasValue;

                        Clear(TempBlob);

                        Name := FileManagement.BLOBImport(TempBlob, TextName);

                        RecRef.GetTable(Rec);
                        TempBlob.ToRecordRef(RecRef, FieldNo(Picture));
                        RecRef.SetTable(Rec);

                        if Name = '' then
                            exit;
                        if PictureExists then
                            if not Confirm(Text001, false, TableCaption, "No.") then
                                exit;

                        while (StrPos(Name, '.') > 0) do begin
                            Index := StrPos(Name, '.');
                            Name := CopyStr(Name, Index + 1);
                        end;

                        "Picture Extention" := Name;

                        CurrPage.SaveRecord;
                        Modify;
                    end;
                }
                action("Delete Picture")
                {
                    Caption = 'Delete Picture';
                    Image = Delete;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Text002: Label 'Do you want to delete the picture of %1 %2?';
                    begin
                        if Picture.HasValue then
                            if Confirm(Text002, false, TableCaption, "No.") then begin
                                Clear(Picture);
                                CurrPage.SaveRecord;
                            end;
                    end;
                }
            }
            group(Dimension)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                action("Dimensions-Single")
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(6014410),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                }
            }
            group("&Function")
            {
                Caption = '&Function';
                action("Create Number Series")
                {
                    Caption = 'Create Number Series';
                    Image = CreateSerialNo;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        RetailTableCode.CreateItemGroupNoSeries(Rec);
                    end;
                }
                action("Create Number Series to All Item Groups")
                {
                    Caption = 'Create Number Series to All Item Groups';
                    Image = CreateSerialNo;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ItemGroup: Record "NPR Item Group";
                        MsgCreated: Label 'Number Series has been created for %1 Item Groups';
                    begin
                        ItemGroup.SetFilter("No. Series", '<>%1', '');
                        if ItemGroup.Find('-') then
                            repeat
                                RetailTableCode.CreateItemGroupNoSeries(ItemGroup);
                            until ItemGroup.Next = 0;

                        Message(MsgCreated, ItemGroup.Count);
                    end;
                }
                separator(Separator6150621)
                {
                }
                action("Create Item From Item Group")
                {
                    Caption = 'Create Item(s) From Item Group';
                    Image = ItemGroup;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ItemGroupSelected: Record "NPR Item Group";
                        ItemGroupSelectedMark: Record "NPR Item Group";
                        FilterText: Text;
                    begin
                        //-NPR70.00.01.05
                        CurrPage.SetSelectionFilter(ItemGroupSelected);

                        if ItemGroupSelected.FindSet then
                            repeat
                                FilterText += ItemGroupSelected."No." + '|';
                            until ItemGroupSelected.Next = 0;

                        ItemGroupSelectedMark.SetFilter("No.", CopyStr(FilterText, 1, StrLen(FilterText) - 1));

                        if StrLen(FilterText) > 1 then
                            REPORT.Run(6014610, true, false, ItemGroupSelectedMark)
                        else
                            REPORT.Run(6014610, true, false, ItemGroupSelected);
                        //+NPR70.00.01.05
                    end;
                }
            }
        }
        area(navigation)
        {
            group("&Overview")
            {
                Caption = '&Overview';
                action("&Item Ledger Entries")
                {
                    Caption = '&Item Ledger Entries';
                    Image = Form;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "NPR Item Group No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+N';
                    ApplicationArea = All;
                }
                action("&VAT Posting Grups")
                {
                    Caption = '&VAT Posting Grups';
                    Image = Form;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        VATPostingSetup: Record "VAT Posting Setup";
                    begin
                        if VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
                            PAGE.RunModal(PAGE::"VAT Posting Setup Card", VATPostingSetup)
                        else
                            Error(Text10600000);
                    end;
                }
                action("Page Item List")
                {
                    Caption = '&Item List';
                    Image = ItemWorksheet;
                    RunObject = Page "Item List";
                    RunPageLink = "NPR Item Group" = FIELD("No.");
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.20
        /*
        VATPercent := 0;
        
        IF ("VAT Prod. Posting Group" <> '') AND ("VAT Bus. Posting Group" <> '') THEN
        
        GetVatSetupDescription()
        */
        LoadRecReferences;
        //+NPR5.20

    end;

    var
        Text10600000: Label 'Enter VAT Posting settings on the item group card!';
        RetailTableCode: Codeunit "NPR Retail Table Code";
        FileManagement: Codeunit "File Management";
        Text10600003: Label 'Do you want to update ALL items in this item group using this change?';
        GLAccountSale: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccountPurch: Record "G/L Account";
        GLAccountReverse: Record "G/L Account";

    procedure TestItemGroup(bError: Boolean): Boolean
    var
        ErrPrGr: Label 'Prod. Posting Group must contain a value!';
        ErrVirkGr: Label 'Company Post. Gr. must contain a value!';
        ErrVbGr: Label 'Item Post. Gr. must contain a value!';
    begin
        if "Gen. Prod. Posting Group" = '' then begin
            if bError then
                Error(ErrPrGr)
            else
                Message(ErrPrGr);
            exit(false);
        end;
        if "Gen. Bus. Posting Group" = '' then begin
            if bError then
                Error(ErrVirkGr)
            else
                Message(ErrVirkGr);
            exit(false);
        end;
        if "Inventory Posting Group" = '' then begin
            if bError then
                Error(ErrVbGr)
            else
                Message(ErrVbGr);
            exit(false);
        end;
        exit(true);
    end;

    local procedure BlockedOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure ParentItemGroupOnAfterValidate()
    begin
        CurrPage.Update(true);
    end;

    local procedure GarantibevisOnAfterValidate()
    var
        Item: Record Item;
    begin
        if Confirm(Text10600003, false) then begin
            Item.SetCurrentKey("NPR Item Group");
            Item.SetRange("NPR Item Group", "No.");
            if Item.Find('-') then
                repeat
                    if Warranty then
                        Item."NPR Guarantee voucher" := true else
                        Item."NPR Guarantee voucher" := false;
                    Item.Modify;
                until Item.Next = 0;
        end;
    end;

    local procedure WarrantyFileOnAfterValidate()
    var
        Item: Record Item;
    begin
        if Confirm(Text10600003, false) then begin
            Item.SetCurrentKey("NPR Item Group");
            Item.SetRange("NPR Item Group", "No.");
            if Item.Find('-') then
                repeat
                    Item."NPR Guarantee Index" := "Warranty File";
                    Item.Modify;
                until Item.Next = 0;
        end;
    end;

    local procedure InsuranceSectOnAfterValidate()
    var
        Item: Record Item;
    begin
        if Confirm(Text10600003, false) then begin
            Item.SetCurrentKey("NPR Item Group");
            Item.SetRange("NPR Item Group", "No.");
            if Item.Find('-') then
                repeat
                    Item."NPR Insurrance category" := "Insurance Category";
                    Item.Modify;
                until Item.Next = 0;
        end;
    end;

    local procedure LoadRecReferences()
    begin
        //-NPR5.20
        if not VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
            VATPostingSetup.Init;

        if not GLAccountSale.Get(VATPostingSetup."Sales VAT Account") then
            GLAccountSale.Init;

        if not GLAccountPurch.Get(VATPostingSetup."Purchase VAT Account") then
            GLAccountPurch.Init;

        if not GLAccountReverse.Get(VATPostingSetup."Reverse Chrg. VAT Acc.") then
            GLAccountReverse.Init;
        //+NPR5.20
    end;
}


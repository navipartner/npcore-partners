page 6014421 "Item Group Page"
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
    SourceTable = "Item Group";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Type;Type)
                {
                }
                field("Webshop Picture";"Webshop Picture")
                {
                }
                field("Search Description";"Search Description")
                {
                }
                field(Blocked;Blocked)
                {

                    trigger OnValidate()
                    begin
                        BlockedOnAfterValidate;
                    end;
                }
            }
            group(Settings)
            {
                Caption = 'Settings';
                field("Parent Item Group No.";"Parent Item Group No.")
                {

                    trigger OnValidate()
                    begin
                        ParentItemGroupOnAfterValidate;
                    end;
                }
                field("Used Goods Group";"Used Goods Group")
                {
                }
                field("No. Series";"No. Series")
                {
                }
                field("Item Discount Group";"Item Discount Group")
                {
                }
                field(Warranty;Warranty)
                {
                    Caption = 'Warranty certificate';

                    trigger OnValidate()
                    begin
                        GarantibevisOnAfterValidate;
                    end;
                }
                field("Warranty File";"Warranty File")
                {

                    trigger OnValidate()
                    begin
                        WarrantyFileOnAfterValidate;
                    end;
                }
                field("Insurance Category";"Insurance Category")
                {

                    trigger OnValidate()
                    begin
                        InsuranceSectOnAfterValidate;
                    end;
                }
                field("Tarif No.";"Tarif No.")
                {
                }
                field(Level;Level)
                {
                    Editable = false;
                }
                field("Belongs In Main Item Group";"Belongs In Main Item Group")
                {
                    Editable = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Editable = false;
                }
                field("Base Unit of Measure";"Base Unit of Measure")
                {
                }
                field("Sales Unit of Measure";"Sales Unit of Measure")
                {
                }
                field("Purch. Unit of Measure";"Purch. Unit of Measure")
                {
                }
                field(Internet;Internet)
                {
                }
                field("Variety Group";"Variety Group")
                {
                }
                field("Config. Template Header";"Config. Template Header")
                {
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group("VAT Setup")
                {
                    Caption = 'VAT Setup';
                    field("VATPostingSetup.""VAT %""";VATPostingSetup."VAT %")
                    {
                        Caption = 'VAT %';
                        Editable = false;
                    }
                    field("GLAccountSale.""No.""";GLAccountSale."No.")
                    {
                        Caption = 'Account Sales VAT';
                        Editable = false;
                    }
                    field("GLAccountSale.Name";GLAccountSale.Name)
                    {
                        Caption = 'Account Name';
                        Editable = false;
                    }
                    field("GLAccountPurch.""No.""";GLAccountPurch."No.")
                    {
                        Caption = 'Account Purchase VAT';
                        Editable = false;
                    }
                    field("GLAccountPurch.Name";GLAccountPurch.Name)
                    {
                        Caption = 'Account Name';
                        Editable = false;
                    }
                    field("GLAccountReverse.""No.""";GLAccountReverse."No.")
                    {
                        Caption = 'Account Recipient';
                        Editable = false;
                    }
                    field("GLAccountReverse.Name";GLAccountReverse.Name)
                    {
                        Caption = 'Account Name';
                        Editable = false;
                    }
                }
                field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.20
                        //GenProdPostGrOnAfterValidate;
                        LoadRecReferences;
                        //+NPR5.20
                    end;
                }
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {

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
                field("Inventory Posting Group";"Inventory Posting Group")
                {
                }
                field("VAT Prod. Posting Group";"VAT Prod. Posting Group")
                {
                }
                field("Tax Group Code";"Tax Group Code")
                {
                }
                field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
                {
                }
                field("Costing Method";"Costing Method")
                {
                }
            }
            group(Pictures)
            {
                Caption = 'Pictures';
                field(Control1160330017;Picture)
                {
                    ShowCaption = false;
                }
            }
            part(SubForm;"Item Group Subpage")
            {
                Caption = 'Child Groups';
                SubPageLink = "Parent Item Group No."=FIELD(FILTER("No."));
                SubPageView = SORTING("No.");
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

                    trigger OnAction()
                    var
                        TempBlob: Record TempBlob;
                        Name: Text[200];
                        TextName: Text[1024];
                        PictureExists: Boolean;
                        Index: Integer;
                        Text001: Label 'Do you want to replace the existing picture of %1 %2?';
                    begin
                        PictureExists := Picture.HasValue;

                        Clear (TempBlob) ;

                        Name    := FileManagement.BLOBImport(TempBlob,TextName);
                        Picture := TempBlob.Blob;

                        if Name = '' then
                          exit;
                        if PictureExists then
                          if not Confirm(Text001,false,TableCaption,"No.") then
                            exit;

                        while(StrPos(Name,'.') > 0 ) do begin
                          Index := StrPos(Name,'.');
                          Name  := CopyStr(Name,Index+1);
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

                    trigger OnAction()
                    var
                        Text002: Label 'Do you want to delete the picture of %1 %2?';
                    begin
                        if Picture.HasValue then
                          if Confirm(Text002,false,TableCaption,"No.") then begin
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
                    RunPageLink = "Table ID"=CONST(6014410),
                                  "No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
            }
            group("&Function")
            {
                Caption = '&Function';
                action("Create Number Series")
                {
                    Caption = 'Create Number Series';
                    Image = CreateSerialNo;

                    trigger OnAction()
                    begin
                        RetailTableCode.CreateItemGroupNoSeries( Rec );
                    end;
                }
                action("Create Number Series to All Item Groups")
                {
                    Caption = 'Create Number Series to All Item Groups';
                    Image = CreateSerialNo;

                    trigger OnAction()
                    var
                        ItemGroup: Record "Item Group";
                        MsgCreated: Label 'Number Series has been created for %1 Item Groups';
                    begin
                        ItemGroup.SetFilter( "No. Series", '<>%1', '' );
                        if ItemGroup.Find('-') then repeat
                          RetailTableCode.CreateItemGroupNoSeries( ItemGroup );
                        until ItemGroup.Next = 0;

                        Message( MsgCreated, ItemGroup.Count );
                    end;
                }
                separator(Separator6150621)
                {
                }
                action("Create Item From Item Group")
                {
                    Caption = 'Create Item(s) From Item Group';
                    Image = ItemGroup;

                    trigger OnAction()
                    var
                        ItemGroupSelected: Record "Item Group";
                        ItemGroupSelectedMark: Record "Item Group";
                        FilterText: Text;
                    begin
                        //-NPR70.00.01.05
                        CurrPage.SetSelectionFilter(ItemGroupSelected);

                        if ItemGroupSelected.FindSet then repeat
                          FilterText += ItemGroupSelected."No." +'|';
                        until ItemGroupSelected.Next=0;

                        ItemGroupSelectedMark.SetFilter("No.",CopyStr(FilterText,1,StrLen(FilterText)-1));

                        if StrLen(FilterText) > 1 then
                          REPORT.Run(6014610,true,false,ItemGroupSelectedMark)
                        else
                          REPORT.Run(6014610,true,false,ItemGroupSelected);
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
                    RunPageLink = "Item Group No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+N';
                }
                action("&VAT Posting Grups")
                {
                    Caption = '&VAT Posting Grups';
                    Image = Form;

                    trigger OnAction()
                    var
                        VATPostingSetup: Record "VAT Posting Setup";
                    begin
                        if VATPostingSetup.Get("VAT Bus. Posting Group","VAT Prod. Posting Group") then
                          PAGE.RunModal(PAGE::"VAT Posting Setup Card",VATPostingSetup)
                        else
                          Error(Text10600000);
                    end;
                }
                action("Page Item List")
                {
                    Caption = '&Item List';
                    Image = ItemWorksheet;
                    RunObject = Page "Item List";
                    RunPageLink = "Item Group"=FIELD("No.");
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
        RetailTableCode: Codeunit "Retail Table Code";
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
            Error( ErrPrGr )
          else
            Message( ErrPrGr );
          exit( false );
        end;
        if "Gen. Bus. Posting Group" = '' then begin
          if bError then
            Error( ErrVirkGr )
          else
            Message( ErrVirkGr );
          exit( false );
        end;
        if "Inventory Posting Group" = '' then begin
          if bError then
            Error( ErrVbGr )
          else
            Message( ErrVbGr );
          exit( false );
        end;
        exit( true );
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
          Item.SetCurrentKey("Item Group");
          Item.SetRange("Item Group", "No.");
          if Item.Find('-') then repeat
            if Warranty then
              Item."Guarantee voucher" := true else
              Item."Guarantee voucher" := false;
              Item.Modify;
          until Item.Next = 0;
        end;
    end;

    local procedure WarrantyFileOnAfterValidate()
    var
        Item: Record Item;
    begin
        if Confirm(Text10600003, false) then begin
          Item.SetCurrentKey("Item Group");
          Item.SetRange("Item Group", "No.");
          if Item.Find('-') then repeat
            Item."Guarantee Index" := "Warranty File";
            Item.Modify;
          until Item.Next = 0;
        end;
    end;

    local procedure InsuranceSectOnAfterValidate()
    var
        Item: Record Item;
    begin
        if Confirm(Text10600003, false) then begin
          Item.SetCurrentKey("Item Group");
          Item.SetRange("Item Group", "No.");
          if Item.Find('-') then repeat
            Item."Insurrance category" := "Insurance Category";
            Item.Modify;
          until Item.Next = 0;
        end;
    end;

    local procedure LoadRecReferences()
    begin
        //-NPR5.20
        if not VATPostingSetup.Get("VAT Bus. Posting Group","VAT Prod. Posting Group") then
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


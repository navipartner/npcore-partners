page 6014506 "NPR Used Goods Reg. Card"
{
    // NPR5.26/TS/20160726 CASE 246761 Added code in Item No. Created
    // NPR5.27/TS/20161027 CASE 246761 Removed Unued/Deleted Fields.
    // NPR5.30/TS/20161221  CASE 246761 Renamed variables
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.54/MITH/20200304 CASE 394335 Added button to print label after creating item from used goods.

    Caption = 'Used Item Registration Card';
    SourceTable = "NPR Used Goods Registration";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6150616)
                {
                    ShowCaption = false;
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        OptionCaption = 'MainPost,,SubPost';
                        ToolTip = 'Specifies the value of the Status field';
                    }
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. field';

                        trigger OnAssistEdit()
                        begin
                            //-NPR5.26
                            if Assistedit(xRec) then
                                CurrPage.Update;
                            Link := "No.";
                            //+NPR5.26
                        end;
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Location Code field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                    field(Subject; Subject)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Subject field';
                    }
                    field("Search Name"; "Search Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Search Name field';
                    }
                    field(Serienummer; Serienummer)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Serial No. field';
                    }
                    field(Puljemomsordning; Puljemomsordning)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Pool  VAT System field';
                    }
                    field("Item No. Created"; "Item No. Created")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Generated Item No. field';

                        trigger OnValidate()
                        var
                            SelectedItem: Record Item;
                            FotoOps: Record "NPR Retail Contr. Setup";
                        begin
                            //-NPR5.26
                            if xRec."Item No. Created" <> '' then
                                Error(ErrUsedGoodAlreadySet);

                            FotoOps.Get;
                            if FotoOps."Used Goods Serial No. Mgt." then begin
                                if Serienummer <> '' then begin
                                    FotoOps.TestField("Used Goods Item Tracking Code");
                                    "Brugtvare lagermetode" := "Brugtvare lagermetode"::Serienummer;
                                end else begin
                                    "Brugtvare lagermetode" := FotoOps."Used Goods Inventory Method";
                                end;
                            end else
                                "Brugtvare lagermetode" := FotoOps."Used Goods Inventory Method";


                            SelectedItem.Get("Item No. Created");
                            if SelectedItem."NPR Second-hand number" <> '' then
                                Error(ErrItemAlreadySH);
                            Stand := SelectedItem."NPR Condition";
                            "Salgspris inkl. Moms" := SelectedItem."Unit Price";
                            "Unit Cost" := SelectedItem."Unit Cost";
                            "Item Group No." := SelectedItem."NPR Item Group";
                            Subject := SelectedItem.Description;
                            "Search Name" := SelectedItem."Search Description";
                            //"Brugtvare lagermetode" :=
                            Modify;
                            SelectedItem."NPR Second-hand number" := "No.";
                            SelectedItem."NPR Second-hand" := true;
                            SelectedItem.Modify(true);
                            Message(StrSubstNo(Text10600001, "Item No. Created"));
                            //+NPR5.26
                        end;
                    }
                    field(Link; Link)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Link field';
                    }
                }
                group(Control6150625)
                {
                    ShowCaption = false;
                    field("Purchase Date"; "Purchase Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Purchase Date field';
                    }
                    field(Beholdning; Beholdning)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Inventory field';
                    }
                    field("Unit Cost"; "Unit Cost")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Cost field';
                    }
                    field(Paid; Paid)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Paid field';
                    }
                    field("Salgspris inkl. Moms"; "Salgspris inkl. Moms")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Price Including VAT field';
                    }
                    field("Item Group No."; "Item Group No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Belongs in Item Group No. field';
                    }
                    field(Stand; Stand)
                    {
                        ApplicationArea = All;
                        Caption = 'Condition';
                        ToolTip = 'Specifies the value of the Condition field';
                    }
                }
            }
            group("Customer Information")
            {
                Caption = 'Customer Information';
                field("Purchased By Customer No."; "Purchased By Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Customer No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(By; By)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(Identification; Identification)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID Card field';
                }
                field("Identification Number"; "Identification Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Legitimation No. field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Copy from Main Registration")
            {
                Caption = 'Copy from Main Card';
                Image = Copy;
                ApplicationArea = All;
                ToolTip = 'Executes the Copy from Main Card action';

                trigger OnAction()
                var
                    NoSeriesManagement: Codeunit NoSeriesManagement;
                    UsedGoodsRegistration: Record "NPR Used Goods Registration";
                begin

                    RetailSetup.Get;
                    Clear(UsedGoodsRegistration);
                    //-NPR5.27
                    //IF "Kostercentralen Registered" <> 0D THEN ERROR(Text10600000);
                    //+NPR5.27
                    RetailSetup.TestField("Used Goods No. Management");
                    if Link = '' then
                        Link := "No.";
                    Modify;
                    NoSeriesManagement.InitSeries(RetailSetup."Used Goods No. Management", xRec.Nummerserie, 0D, UsedGoodsRegistration."No.", UsedGoodsRegistration.Nummerserie);
                    UsedGoodsRegistration.Insert;
                    UsedGoodsRegistration."Purchase Date" := "Purchase Date";
                    UsedGoodsRegistration."Purchased By Customer No." := "Purchased By Customer No.";
                    UsedGoodsRegistration.Name := Name;
                    UsedGoodsRegistration.Address := Address;
                    UsedGoodsRegistration."Address 2" := "Address 2";
                    UsedGoodsRegistration."Post Code" := "Post Code";
                    UsedGoodsRegistration.Identification := Identification;
                    //-NPR5.27
                    //UsedGoodsRegistration."CPR No." := "CPR No.";
                    //+NPR5.27
                    UsedGoodsRegistration."Identification Number" := "Identification Number";
                    //-NPR5.27
                    //UsedGoodsRegistration.Puljemomsordning := Puljemomsordning;
                    //+NPR5.27
                    UsedGoodsRegistration.By := By;
                    UsedGoodsRegistration."Salesperson Code" := "Salesperson Code";
                    UsedGoodsRegistration.Link := Link;
                    UsedGoodsRegistration.Modify;
                    Get(UsedGoodsRegistration."No.");
                end;
            }
            group("&Goods")
            {
                Caption = '&Goods';
                action("Associated Registration Card")
                {
                    Caption = 'Associated Registration Card';
                    Image = List;
                    ShortCutKey = 'F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Associated Registration Card action';

                    trigger OnAction()
                    var
                        TempUsedGoodsRegistration: Record "NPR Used Goods Registration" temporary;
                        UsedGoodsRegistration: Record "NPR Used Goods Registration";
                        PageAction: Action;
                    begin

                        UsedGoodsRegistration.Reset;
                        TempUsedGoodsRegistration.SetCurrentKey(Link);
                        TempUsedGoodsRegistration.DeleteAll;
                        if Link <> '' then begin
                            UsedGoodsRegistration.Get(Link);
                            UsedGoodsRegistration.SetRange(Link, UsedGoodsRegistration."No.");
                            if UsedGoodsRegistration.Find('-') then
                                repeat
                                    TempUsedGoodsRegistration := UsedGoodsRegistration;
                                    TempUsedGoodsRegistration.Insert;
                                until UsedGoodsRegistration.Next = 0;
                            PageAction :=// FORM.RUNMODAL(FORM::"Used Goods Link List",TempUsedGoodsRegistration);
                                          PAGE.RunModal(PAGE::"NPR Used Goods Link List", TempUsedGoodsRegistration);

                            if PageAction = ACTION::LookupOK then
                                Get(TempUsedGoodsRegistration."No.");
                        end else begin
                            UsedGoodsRegistration.SetCurrentKey("No.");
                            UsedGoodsRegistration := Rec;
                            UsedGoodsRegistration.FilterGroup := 2;
                            UsedGoodsRegistration.SetRange("No.", "No.");
                            UsedGoodsRegistration.FilterGroup := 0;
                            //FORM.RUNMODAL(FORM::"Used Goods Link List",UsedGoodsRegistration);
                            PAGE.RunModal(PAGE::"NPR Used Goods Link List", UsedGoodsRegistration);
                        end;
                    end;
                }
                action("Create Used Item")
                {
                    Caption = 'Create Used Item';
                    Image = ElectronicNumber;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Used Item action';

                    trigger OnAction()
                    begin

                        TestField(Subject);
                        //TESTFIELD(Kostpris);
                        TestField("Purchased By Customer No.");
                        //-NPR5.30
                        //TESTFIELD(Blocked,FALSE);
                        //+NPR5.30
                        TestField("Salesperson Code");
                        // TESTFIELD("Kostercentralen Registreret d.");
                        TestField("Salgspris inkl. Moms");
                        CODEUNIT.Run((CODEUNIT::"NPR Convert used goods"), Rec);
                    end;
                }
                action("Create Sales Credit Memo")
                {
                    Caption = 'Create Sales Credit Memo';
                    Image = CreateCreditMemo;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Sales Credit Memo action';

                    trigger OnAction()
                    var
                        "Convert used goods": Codeunit "NPR Convert used goods";
                    begin
                        //-NPR5.26
                        //-NPR5.27
                        "Convert used goods".UsedGoods2SalesCreditMemo(Rec);
                        //+NPR5.27
                        //+NPR5.26
                    end;
                }
                action("Item Card")
                {
                    Caption = '&Item Card';
                    Image = Card;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Item Card action';

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin

                        TestField("Item No. Created");
                        Item.Get("Item No. Created");
                        PAGE.RunModal(PAGE::"Item Card", Item);
                    end;
                }
                action("Item Entry")
                {
                    Caption = 'Item &Entry';
                    Image = Entries;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item &Entry action';

                    trigger OnAction()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin

                        TestField("Item No. Created");
                        ItemLedgerEntry.FilterGroup := 2;
                        ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code");
                        ItemLedgerEntry.SetRange("Item No.", "Item No. Created");
                        ItemLedgerEntry.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgerEntry);
                    end;
                }
                action("Registration Card")
                {
                    Caption = 'Print Registration Card';
                    Image = PrintDocument;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Registration Card action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        xUsedGoodsRegistration: Record "NPR Used Goods Registration";
                    begin

                        TestField("Purchased By Customer No.");
                        TestField(Name);
                        TestField(Address);
                        TestField("Post Code");
                        TestField(Subject);
                        TestField(Identification);
                        TestField("Identification Number");
                        if Link <> '' then
                            xUsedGoodsRegistration.Get(Link)
                        else
                            xUsedGoodsRegistration.Get("No.");
                        xUsedGoodsRegistration.FilterGroup := 2;
                        xUsedGoodsRegistration.SetRange("No.", xUsedGoodsRegistration."No.");
                        xUsedGoodsRegistration.FilterGroup := 0;
                        REPORT.RunModal(REPORT::"NPR Register Used Goods", true, false, xUsedGoodsRegistration);
                    end;
                }
                action("Create Used Item and Print Label")
                {
                    Caption = 'Create Used Item and Print Label';
                    Image = ElectronicNumber;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Used Item and Print Label action';

                    trigger OnAction()
                    var
                        Item: Record Item;
                        PrintLabelAndDisplay: Codeunit "NPR Label Library";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        //+NPR5.54
                        TestField(Subject);
                        TestField("Purchased By Customer No.");
                        TestField("Salesperson Code");
                        TestField("Salgspris inkl. Moms");
                        CODEUNIT.Run((CODEUNIT::"NPR Convert used goods"), Rec);

                        TestField("Item No. Created");
                        Item.Get("Item No. Created");
                        PrintLabelAndDisplay.ResolveVariantAndPrintItem(Item, ReportSelectionRetail."Report Type"::"Price Label");
                        //-NPR5.54
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        /*
        CurrForm.Ny.VISIBLE(FALSE);
        CurrForm.Hoved.VISIBLE(FALSE);
        CurrForm.Link.VISIBLE(FALSE);
        IF (Link <> '') AND (Nummer <> Link) THEN CurrForm.Link.VISIBLE(TRUE);
        IF Nummer = Link THEN CurrForm.Hoved.VISIBLE(TRUE);
        IF Link = '' THEN BEGIN
          CurrForm.Ny.VISIBLE(TRUE);
          Link := Nummer;
        END;
        */
        //-NPR5.30
        if (Link <> '') and ("No." <> Link) then
            Status := Status::SubPost;
        if "No." = Link then
            Status := Status::MainPost;
        if Link = '' then begin
            Status := Status::SinglePost;
            Link := "No.";
        end;
        //+NPR5.30

    end;

    trigger OnOpenPage()
    begin
        /*
        CurrForm.Ny.VISIBLE(FALSE);
        CurrForm.Hoved.VISIBLE(FALSE);
        CurrForm.Link.VISIBLE(FALSE);
        */

    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        Text10600000: Label 'Copy function only applies to not printed cards!';
        ErrItemAlreadySH: Label 'Error. Item already set as second-hand and associated to a Used Goods Item !!!';
        ErrUsedGoodAlreadySet: Label 'Error. Used Good Item already set to an Item !!!';
        [InDataSet]
        FieldsVisible: Boolean;
        Text10600001: Label 'Item %1 set to second item';
}


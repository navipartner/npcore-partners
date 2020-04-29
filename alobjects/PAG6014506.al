page 6014506 "Used Goods Reg. Card"
{
    // NPR5.26/TS/20160726 CASE 246761 Added code in Item No. Created
    // NPR5.27/TS/20161027 CASE 246761 Removed Unued/Deleted Fields.
    // NPR5.30/TS/20161221  CASE 246761 Renamed variables
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.54/MITH/20200304 CASE 394335 Added button to print label after creating item from used goods.

    Caption = 'Used Item Registration Card';
    SourceTable = "Used Goods Registration";

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
                    field(Status;Status)
                    {
                        Editable = false;
                        OptionCaption = 'MainPost,,SubPost';
                    }
                    field("No.";"No.")
                    {

                        trigger OnAssistEdit()
                        begin
                            //-NPR5.26
                            if Assistedit(xRec) then
                              CurrPage.Update;
                            Link := "No.";
                            //+NPR5.26
                        end;
                    }
                    field("Location Code";"Location Code")
                    {
                    }
                    field("Salesperson Code";"Salesperson Code")
                    {
                    }
                    field(Subject;Subject)
                    {
                    }
                    field("Search Name";"Search Name")
                    {
                    }
                    field(Serienummer;Serienummer)
                    {
                    }
                    field(Puljemomsordning;Puljemomsordning)
                    {
                    }
                    field("Item No. Created";"Item No. Created")
                    {

                        trigger OnValidate()
                        var
                            SelectedItem: Record Item;
                            FotoOps: Record "Retail Contract Setup";
                        begin
                            //-NPR5.26
                            if xRec."Item No. Created" <> '' then
                              Error(ErrUsedGoodAlreadySet);

                            FotoOps.Get;
                            if FotoOps."Used Goods Serial No. Mgt." then begin
                              if Serienummer <> '' then begin
                                FotoOps.TestField( "Used Goods Item Tracking Code" );
                                "Brugtvare lagermetode" := "Brugtvare lagermetode"::Serienummer;
                              end else begin
                                "Brugtvare lagermetode" := FotoOps."Used Goods Inventory Method";
                              end;
                            end else
                              "Brugtvare lagermetode" := FotoOps."Used Goods Inventory Method";


                            SelectedItem.Get("Item No. Created");
                            if SelectedItem."Second-hand number" <> '' then
                              Error(ErrItemAlreadySH);
                            Stand := SelectedItem.Condition;
                            "Salgspris inkl. Moms" := SelectedItem."Unit Price";
                            "Unit Cost" := SelectedItem."Unit Cost";
                            "Item Group No." := SelectedItem."Item Group";
                            Subject := SelectedItem.Description;
                            "Search Name" := SelectedItem."Search Description";
                            //"Brugtvare lagermetode" :=
                            Modify;
                            SelectedItem."Second-hand number" := "No.";
                            SelectedItem."Second-hand" := true;
                            SelectedItem.Modify(true);
                            Message(StrSubstNo(Text10600001,"Item No. Created"));
                            //+NPR5.26
                        end;
                    }
                    field(Link;Link)
                    {
                        Editable = false;
                    }
                }
                group(Control6150625)
                {
                    ShowCaption = false;
                    field("Purchase Date";"Purchase Date")
                    {
                    }
                    field(Beholdning;Beholdning)
                    {
                        Editable = false;
                    }
                    field("Unit Cost";"Unit Cost")
                    {
                    }
                    field(Paid;Paid)
                    {
                    }
                    field("Salgspris inkl. Moms";"Salgspris inkl. Moms")
                    {
                    }
                    field("Item Group No.";"Item Group No.")
                    {
                    }
                    field(Stand;Stand)
                    {
                        Caption = 'Condition';
                    }
                }
            }
            group("Customer Information")
            {
                Caption = 'Customer Information';
                field("Purchased By Customer No.";"Purchased By Customer No.")
                {
                }
                field(Name;Name)
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(By;By)
                {
                }
                field(Identification;Identification)
                {
                }
                field("Identification Number";"Identification Number")
                {
                }
                field(Blocked;Blocked)
                {
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

                trigger OnAction()
                var
                    NoSeriesManagement: Codeunit NoSeriesManagement;
                    UsedGoodsRegistration: Record "Used Goods Registration";
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
                    NoSeriesManagement.InitSeries(RetailSetup."Used Goods No. Management",xRec.Nummerserie,0D,UsedGoodsRegistration."No.",UsedGoodsRegistration.Nummerserie);
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

                    trigger OnAction()
                    var
                        TempUsedGoodsRegistration: Record "Used Goods Registration" temporary;
                        UsedGoodsRegistration: Record "Used Goods Registration";
                        PageAction: Action;
                    begin

                        UsedGoodsRegistration.Reset;
                        TempUsedGoodsRegistration.SetCurrentKey(Link);
                        TempUsedGoodsRegistration.DeleteAll;
                        if Link <> '' then begin
                          UsedGoodsRegistration.Get(Link);
                          UsedGoodsRegistration.SetRange(Link,UsedGoodsRegistration."No.");
                          if UsedGoodsRegistration.Find('-') then repeat
                            TempUsedGoodsRegistration := UsedGoodsRegistration;
                            TempUsedGoodsRegistration.Insert;
                          until UsedGoodsRegistration.Next = 0;
                          PageAction :=// FORM.RUNMODAL(FORM::"Used Goods Link List",TempUsedGoodsRegistration);
                                        PAGE.RunModal(PAGE::"Used Goods Link List",TempUsedGoodsRegistration);

                          if PageAction = ACTION::LookupOK then
                            Get(TempUsedGoodsRegistration."No.");
                        end else begin
                          UsedGoodsRegistration.SetCurrentKey("No.");
                          UsedGoodsRegistration := Rec;
                          UsedGoodsRegistration.FilterGroup := 2;
                          UsedGoodsRegistration.SetRange("No.","No.");
                          UsedGoodsRegistration.FilterGroup := 0;
                          //FORM.RUNMODAL(FORM::"Used Goods Link List",UsedGoodsRegistration);
                          PAGE.RunModal(PAGE::"Used Goods Link List",UsedGoodsRegistration);
                        end;
                    end;
                }
                action("Create Used Item")
                {
                    Caption = 'Create Used Item';
                    Image = ElectronicNumber;

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
                        CODEUNIT.Run((CODEUNIT::"Convert used goods"),Rec);
                    end;
                }
                action("Create Sales Credit Memo")
                {
                    Caption = 'Create Sales Credit Memo';
                    Image = CreateCreditMemo;

                    trigger OnAction()
                    var
                        "Convert used goods": Codeunit "Convert used goods";
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

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin

                        TestField("Item No. Created");
                        Item.Get("Item No. Created");
                        //FORM.RUNMODAL(FORM::"Item card - Retail",Vare);
                        PAGE.RunModal(PAGE:: "Retail Item Card",Item);
                    end;
                }
                action("Item Entry")
                {
                    Caption = 'Item &Entry';
                    Image = Entries;

                    trigger OnAction()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin

                        TestField("Item No. Created");
                        ItemLedgerEntry.FilterGroup := 2;
                        ItemLedgerEntry.SetCurrentKey("Item No.","Variant Code");
                        ItemLedgerEntry.SetRange("Item No.","Item No. Created");
                        ItemLedgerEntry.FilterGroup := 0;
                        PAGE.RunModal(PAGE::"Item Ledger Entries",ItemLedgerEntry);
                    end;
                }
                action("Registration Card")
                {
                    Caption = 'Print Registration Card';
                    Image = PrintDocument;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        xUsedGoodsRegistration: Record "Used Goods Registration";
                    begin

                        TestField("Purchased By Customer No.");
                        TestField(Name);
                        TestField(Address);
                        TestField("Post Code");
                        TestField(Subject);
                        TestField(Identification);
                        TestField("Identification Number");
                        if Link <>'' then
                          xUsedGoodsRegistration.Get(Link)
                        else
                          xUsedGoodsRegistration.Get("No.");
                        xUsedGoodsRegistration.FilterGroup := 2;
                        xUsedGoodsRegistration.SetRange("No.",xUsedGoodsRegistration."No.");
                        xUsedGoodsRegistration.FilterGroup := 0;
                        REPORT.RunModal(REPORT::"Register Used Goods",true,false,xUsedGoodsRegistration);
                    end;
                }
                action("Create Used Item and Print Label")
                {
                    Caption = 'Create Used Item and Print Label';
                    Image = ElectronicNumber;
                    Visible = false;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        PrintLabelAndDisplay: Codeunit "Label Library";
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        //+NPR5.54
                        TestField(Subject);
                        TestField("Purchased By Customer No.");
                        TestField("Salesperson Code");
                        TestField("Salgspris inkl. Moms");
                        CODEUNIT.Run((CODEUNIT::"Convert used goods"),Rec);

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
        if (Link <> '') and ("No."<> Link) then
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
        RetailSetup: Record "Retail Setup";
        Text10600000: Label 'Copy function only applies to not printed cards!';
        ErrItemAlreadySH: Label 'Error. Item already set as second-hand and associated to a Used Goods Item !!!';
        ErrUsedGoodAlreadySet: Label 'Error. Used Good Item already set to an Item !!!';
        [InDataSet]
        FieldsVisible: Boolean;
        Text10600001: Label 'Item %1 set to second item';
}


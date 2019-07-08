page 6014466 "Quantity Discount Card"
{
    // 
    // //-NPR 290509 Ny menupunkt under funktion Sag 70115
    // Send to Retail Journal
    // 
    // NPR4.002.003, 01-06-10, MH - Added Function, UpdateStatus(). It corrects the status depending on "Closing date" and "Closing Time"
    //                         (Job 87927).
    // 
    // 
    // 
    // 
    // // -NPR7-TS-18.10.12., On previous form there was code to set the Subform as visible or not ,as this CAL code do not work on page anymore,I created a global variable as boolean datatype,set Includedataser property to TRUE and then assign it as a
    // source expression to the control's property you want to change.
    // NPR5.30/BHR /20170223  CASE 265244 Copy Discount Functionality
    // NPR5.46/JDH /20180927 CASE 294354 Send to retail journal recoded

    Caption = 'Multiple Price Header';
    SourceTable = "Quantity Discount Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Main No.";"Main No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Status;Status)
                {
                }
                field("Last Date Modified";"Last Date Modified")
                {
                }
                field("Block Custom Discount";"Block Custom Discount")
                {
                }
            }
            group(Conditions)
            {
                field("Starting Date";"Starting Date")
                {
                }
                field("Closing Date";"Closing Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Closing Time";"Closing Time")
                {
                }
                grid(Control6150629)
                {
                    ShowCaption = false;
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
            }
            part(QuantityDiscountLine1;"Quantity Discount Line")
            {
                SubPageLink = "Item No."=FIELD("Item No."),
                              "Main no."=FIELD("Main No.");
                Visible = ActionVisible;
            }
        }
        area(factboxes)
        {
            part(Control6150634;"Item Invoicing FactBox")
            {
                SubPageLink = "No."=FIELD("Item No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Function';
            }
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "Quantity Discount List";
            }
            separator(Separator6150623)
            {
            }
            action("Send to Retail Journal")
            {
                Caption = 'Send to Retail Journal';
                Image = sendTo;

                trigger OnAction()
                var
                    RetailJournalMgt: Codeunit "Retail Journal Code";
                begin
                    //-NPR5.46 [294354]
                    // IF PAGE.RUNMODAL(PAGE::"Retail Journal List", "Retail Journal Header") <> ACTION::LookupOK THEN EXIT;
                    //   QuantityDiscountLine.SETRANGE("Main no.","Main No.");
                    //  IF QuantityDiscountLine.FIND('-') THEN REPEAT
                    //     RetailJournalLine.RESET;
                    //     RetailJournalLine.SETRANGE("No.", "Retail Journal Header"."No.");
                    //     IF RetailJournalLine.FIND('+') THEN
                    //        tempInt := RetailJournalLine."Line No." + 10000
                    //     ELSE
                    //       tempInt := 10000;
                    //     tempAntal := QuantityDiscountLine.COUNT;
                    //
                    //  RetailJournalLine."No.":= "Retail Journal Header"."No.";
                    //  RetailJournalLine."Line No.":=tempInt;
                    //  RetailJournalLine.VALIDATE("Item No.",QuantityDiscountLine."Item No.");
                    //  //RetailJournalLine."Variant Code":= QuantityDiscountLine."Variant Code";
                    //  RetailJournalLine."Discount Type":= 3;
                    //  RetailJournalLine."Discount Unit Price":= QuantityDiscountLine."Unit Price";
                    //  //RetailJournalLine."Unit price":= QuantityDiscountLine."Campaign Unit price";
                    //  RetailJournalLine.Quantity:= QuantityDiscountLine.Quantity;
                    //  RetailJournalLine."Discount Code":= QuantityDiscountLine."Main no.";
                    //  RetailJournalLine.INSERT(TRUE);
                    // UNTIL QuantityDiscountLine.NEXT=0;
                    // MESSAGE(txt001, tempAntal);
                    RetailJournalMgt.Quantity2RetailJnl("Item No.", "Main No.", '');
                    //+NPR5.46 [294354]
                end;
            }
            action("Copy Multiple Price Discount")
            {
                Caption = 'Copy Multiple Price Discount';
                Image = CopyDocument;

                trigger OnAction()
                var
                    QuantityDiscountHeader: Record "Quantity Discount Header";
                    QuantityDiscountLine1: Record "Quantity Discount Line";
                    QuantityDiscountLine: Record "Quantity Discount Line";
                begin
                    //-NPR5.30 [265244]
                    if PAGE.RunModal(PAGE::"Quantity Discount List",QuantityDiscountHeader) <> ACTION::LookupOK then exit;
                      QuantityDiscountLine1.Reset;
                      QuantityDiscountLine1.SetRange("Main no.","Main No.");
                      QuantityDiscountLine1.SetRange("Item No.","Item No.");
                      QuantityDiscountLine1.DeleteAll;

                      QuantityDiscountLine1.Reset;
                      QuantityDiscountLine1.SetRange("Main no.",QuantityDiscountHeader."Main No.");
                      QuantityDiscountLine1.SetRange("Item No.",QuantityDiscountHeader."Item No.");
                      if QuantityDiscountLine1.FindSet then
                        repeat
                          QuantityDiscountLine.Init;
                          QuantityDiscountLine.TransferFields(QuantityDiscountLine1);
                          QuantityDiscountLine."Main no." := "Main No.";
                          QuantityDiscountLine."Item No." := "Item No.";
                          QuantityDiscountLine.Insert(true);
                        until QuantityDiscountLine1.Next=0;

                    //+NPR5.30 [265244]
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Flerstykhoved: Record "Quantity Discount Header";
    begin
        UpdateStatus();

        Flerstykhoved.SetRange( "Item No.", GetFilter( "Item No." ));
        if not Flerstykhoved.Find('-') then begin

        end;
        ActionVisible:=true;
    end;

    var
        [InDataSet]
        ActionVisible: Boolean;
        QuantityDiscountLine: Record "Quantity Discount Line";

    procedure UpdateStatus()
    var
        "Quantity Discount Header 2": Record "Quantity Discount Header";
    begin
        //-NPK1.0
        "Quantity Discount Header 2".SetFilter( Status, '<>%1', Status::Balanced );
        if "Quantity Discount Header 2".FindFirst then repeat
          if ("Quantity Discount Header 2"."Closing Date" < Today) or
             ( ("Quantity Discount Header 2"."Closing Date" = Today) and ("Quantity Discount Header 2"."Closing Time" < Time) ) then begin
            "Quantity Discount Header 2".Validate( Status, Status::Balanced );
            "Quantity Discount Header 2".Modify( true );
          end;
        until "Quantity Discount Header 2".Next = 0;
        //+NPK1.0
    end;
}


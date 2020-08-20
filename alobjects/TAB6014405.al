table 6014405 "Sale POS"
{
    // NPR4.04/JDH /20150403 CASE 204978 Correct bug whereby the vat is added to all the items when previous transaction on POS had a "Vat Customer" made Var Local
    // NPR4.16/MMV /20151028 CASE 225533 Renamed field 130 "Custom Report No." to "Custom Print Object ID"
    //                                   Addded  field 131 "Custom Print Object Type" : Text [10]
    // NPR4.18/MMV /20160128 CASE 224257 Added field 140 "Issue Tax Free Voucher" : Boolean
    // NPR4.21/BHR /20160209 CASE 229736 Correct dimension
    // NPR5.22/MMV /20160404 CASE 232067 Added field 150 "Customer Location No." : Code[20]
    // NPR5.22/AP  /20160413 CASE 235391 Change scope-property for function UpdateAllLineDim from LOCAL to non-LOCAL.
    // NPR5.27/JDH /20161018 CASE 255575 Removed unused functions
    // NPR5.28/MMV /20161104 CASE 254575 Added field 60 "Send Receipt Email".
    // NPR5.29/AP  /20170119 CASE 257938 Fixing dimension issues. Dimension Set not propagated correctly from header to line and with proper priority.
    // NPR5.29/AP  /20170119 CASE 262628 Added field 160 POS Sale ID (Autoincerement). Future use as surrogate key of POS Sale
    // NPR5.30/AP  /20170214 CASE 261728 Introducing POS Unit and POS Store.
    //                                   Added field 3 "POS Store Code"
    //                                   Added helper functions GetPOSUnit and GetPOSStore
    //                                   Removed malicious global dimension handling.
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.31/MHA /20170113 CASE 263093 Added field 45 "Customer Disc. Group"
    // NPR5.31/TSA /20170314 CASE 269105 Removed field 5103 "Prices incl. VAT" from page since it is a duplicate of field 3.
    // NPR5.31/AP  /20170227 CASE 248534 Re-introduced US Sales Tax
    //                                   Added fields 74 "Gen. Bus. Posting Group", 141 "Tax Area Code", 142 "Tax Liable" and 143 "VAT Bus. Posting Group"
    //                                   Setting up posting setup on the header for the lines to inherit from (instead of lines recalculating every time)
    // NPR5.31/AP  /20170309 CASE 266785 Removed unused fields 103 "Customer Display Line1", 104 "Customer Display Line2", 124 "Meta Trigger Error" and 125 "Meta Trigger Error String"
    //                                   Removed field 110 "Computer Name" and corresponding, unused key
    // NPR5.31/AP  /20170427 CASE 269105 Reversed removal of 5103 "Prices incl. VAT".
    // NPR5.32/AP  /20170519 CASE 248534 Apply header defaults to lines when validating customer. Some was never set, others was not set due to refactoring of HentMomsPct and HentBel¢b
    // NPR5.32/JDH /20170525 CASE 278031 Changed SalesPerson Code field from 20 to 10. renamed a couple of variables to English
    // NPR5.32.01/AP  /20170530 CASE 248534 More issues regarding VAT refactoring. VAT % not always set correct when updating exiting lines.
    // NPR5.36/TJ  /20170904 CASE 286283 Renamed all the danish OptionString properties to english
    // NPR5.37/TS  /20171012 CASE 292422 Added Field Customer Name ( 485 )
    // NPR5.45/MHA /20180803  CASE 323705 Signature changed on SaleLinePOS.FindItemSalesPrice()
    // NPR5.45/MMV /20180828  CASE 326466 Recalculate discount once on end of customer validate
    // NPR5.50/MHA /20190422 CASE 337539 Added field 170 "Retail ID"
    // NPR5.52/ALPO/20190820 CASE 359596 Do not change unit price on the line after customer is selected, should new unit price is higher than existing one, unless there was a customer change
    // NPR5.52/MMV /20191007 CASE 352473 Added "Prices Including VAT" switch validation.
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.53/ALPO/20191105 CASE 376035 Save active event on Sale POS, copy event's dimensions directly to the sale instead of overwriting pos unit dimensions
    // NPR5.53/BHR /20191008  CASE 369354 comment code in relation to 'New Customer Creation'
    // NPR5.53/TJ  /20191205 CASE 380453 Country Code is now properly populated when setting Customer No.
    // NPR5.53/ALPO/20191211 CASE 380609 NPRE: New guest arrival procedure. Store preselected Waiterpad No. and Seating Code as well as Number of Guests on Sale POS
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.54/MMV /20200220 CASE 391871 Moved GUID creation from table subscribers to table trigger to have everything centralized.
    // NPR5.55/ALPO/20200702 CASE 380979 Incorrect amount calculation, when a customer with prices set to be vat-including is changed to a customer with VAT-excluding prices

    Caption = 'Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';

            trigger OnValidate()
            begin
                //-NPR5.53 [371956]
                CreateDim(
                  DATABASE::"POS Unit", "Register No.",
                  DATABASE::"POS Store", "POS Store Code",
                  DATABASE::Job, "Event No.",  //NPR5.53 [376035]
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
                //+NPR5.53 [371956]
            end;
        }
        field(4; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;

            trigger OnValidate()
            begin
                CreateDim(
                  //DATABASE::Register,"Register No.",  //NPR5.53 [371956]-revoked
                  //-NPR5.53 [371956]
                  DATABASE::"POS Unit", "Register No.",
                  DATABASE::"POS Store", "POS Store Code",
                  //+NPR5.53 [371956]
                  DATABASE::Job, "Event No.",  //NPR5.53 [376035]
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
            end;
        }
        field(5; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(6; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Customer Type" = CONST(Ord)) Customer."No."
            ELSE
            IF ("Customer Type" = CONST(Cash)) Contact."No.";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                SaleLinePOS: Record "Sale Line POS";
                Item: Record Item;
                Contact: Record Contact;
                AltNo: Record "Alternative No.";
                DoCreate: Boolean;
                Cust: Record Customer;
                RetailFormCode: Codeunit "Retail Form Code";
                POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
                NewUnitPrice: Decimal;
                xSaleLinePOS: Record "Sale Line POS";
                POSSaleLine: Codeunit "POS Sale Line";
            begin
                RetailSetup.Get();
                Register.Get("Register No.");
                //-NPR5.30 [261728]
                GetPOSUnit;
                "POS Store Code" := POSUnit."POS Store Code";
                GetPOSStore;
                //+NPR5.30 [261728]

                "Customer Price Group" := Register."Customer Price Group";
                //-NPR5.31 [263093]
                "Customer Disc. Group" := Register."Customer Disc. Group";
                //+NPR5.31 [263093]
                //-NPR5.31 [248534]
                "Gen. Bus. Posting Group" := POSStore."Gen. Bus. Posting Group";
                "Tax Area Code" := POSStore."Tax Area Code";
                "Tax Liable" := POSStore."Tax Liable";
                "VAT Bus. Posting Group" := POSStore."VAT Bus. Posting Group";
                //+NPR5.31 [248534]

                //- Alternative Customer no.
                AltNo.SetCurrentKey("Alt. No.", Type);
                AltNo.SetRange("Alt. No.", "Customer No.");
                AltNo.SetFilter(Type, '=%1|=%2', AltNo.Type::Customer, AltNo.Type::"CRM Customer");
                //-NPR5.45 [323705]
                //IF AltNo.FIND('-') THEN BEGIN
                if AltNo.FindFirst then begin
                    //+NPR5.45 [323705]
                    if AltNo.Type = AltNo.Type::Customer then
                        "Customer Type" := "Customer Type"::Ord
                    else
                        "Customer Type" := "Customer Type"::Cash;
                    "Customer No." := AltNo.Code;
                end;

                if ("Customer Type" = "Customer Type"::Cash) and ("Customer No." <> '') then begin
                    if not Contact.Get("Customer No.") then begin
                        //-NPR5.53 [369354]
                        //    DoCreate := FALSE;
                        //    CASE RetailSetup."New Customer Creation" OF
                        //      RetailSetup."New Customer Creation"::All :
                        //        DoCreate := TRUE;
                        //      RetailSetup."New Customer Creation"::"Cash Customer" :
                        //        DoCreate := TRUE;
                        //      RetailSetup."New Customer Creation"::"User Managed": BEGIN
                        //        SalesPerson.GET("Salesperson Code");
                        //        CASE SalesPerson."Customer Creation" OF
                        //          SalesPerson."Customer Creation"::"1" :
                        //            DoCreate := TRUE;
                        //          SalesPerson."Customer Creation"::"2" :
                        //            DoCreate := TRUE;
                        //        END;
                        //      END;
                        //      RetailSetup."New Customer Creation"::Customer :
                        //        DoCreate := FALSE;
                        //    END;
                        //
                        //    IF NOT DoCreate THEN
                        //      ERROR(Text1060002);
                        //+NPR5.53 [369354]
                        RetailFormCode.CreateContact("Customer No.");

                        if "Customer No." <> '' then begin
                            Contact.Get("Customer No.");
                            "Customer No." := Contact."No.";
                            Name := Contact.Name;
                            Address := Contact.Address;
                            "Address 2" := Contact."Address 2";
                            Validate("Post Code", Contact."Post Code");
                            //-NPR5.53 [380453]
                            Validate("Country Code", Contact."Country/Region Code");
                            //+NPR5.53 [380453]
                        end;
                    end else begin
                        Name := Contact.Name;
                        Address := Contact.Address;
                        "Address 2" := Contact."Address 2";
                        "Post Code" := Contact."Post Code";
                        City := Contact.City;
                        "Contact No." := Contact."No.";
                        //-NPR5.53 [380453]
                        Validate("Country Code", Contact."Country/Region Code");
                        //+NPR5.53 [380453]
                    end;
                end;

                Modify;

                if ("Customer No." <> '') and ("Customer Type" = "Customer Type"::Ord) then begin
                    //ohm - customer lookup
                    if not Cust.Get("Customer No.") then begin
                        //-NPR5.53 [369354]
                        //    DoCreate := FALSE;
                        //    CASE RetailSetup."New Customer Creation" OF
                        //      RetailSetup."New Customer Creation"::All :
                        //        DoCreate := TRUE;
                        //      RetailSetup."New Customer Creation"::"Cash Customer" :
                        //        DoCreate := FALSE;
                        //      RetailSetup."New Customer Creation"::"User Managed": BEGIN
                        //        SalesPerson.GET("Salesperson Code");
                        //        CASE SalesPerson."Customer Creation" OF
                        //          SalesPerson."Customer Creation"::"1" :
                        //            DoCreate := TRUE;
                        //          SalesPerson."Customer Creation"::"2" :
                        //            DoCreate := TRUE;
                        //        END;
                        //      END;
                        //      RetailSetup."New Customer Creation"::Customer :
                        //        DoCreate := TRUE;
                        //    END;
                        //
                        //    IF NOT DoCreate THEN
                        //      ERROR(Text1060002);
                        //+NPR5.53 [369354]
                        RetailFormCode.CreateCustomer("Customer No.");
                    end;

                    if "Customer No." <> '' then begin
                        Cust.Get("Customer No.");
                        Name := Cust.Name;
                        Address := Cust.Address;
                        "Address 2" := Cust."Address 2";
                        "Post Code" := Cust."Post Code";
                        City := Cust.City;
                        //-NPR5.53 [380453]
                        Validate("Country Code", Cust."Country/Region Code");
                        //+NPR5.53 [380453]
                        if Cust."Customer Price Group" <> '' then
                            "Customer Price Group" := Cust."Customer Price Group";
                        //-NPR5.31 [263093]
                        if Cust."Customer Disc. Group" <> '' then
                            "Customer Disc. Group" := Cust."Customer Disc. Group";
                        //+NPR5.31 [263093]

                        //-NPR5.31 [248534]
                        if POSStore."Default POS Posting Setup" = POSStore."Default POS Posting Setup"::Customer then begin
                            "Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                            "Tax Area Code" := Cust."Tax Area Code";
                            "Tax Liable" := Cust."Tax Liable";
                            "VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group";
                        end else begin
                            "Gen. Bus. Posting Group" := POSStore."Gen. Bus. Posting Group";
                            "Tax Area Code" := POSStore."Tax Area Code";
                            "Tax Liable" := POSStore."Tax Liable";
                            "VAT Bus. Posting Group" := POSStore."VAT Bus. Posting Group";
                        end;
                        //+NPR5.31 [248534]

                        //-NPR5.30 [261728]
                        //IF Cust."Global Dimension 1 Code" <> '' THEN
                        //  VALIDATE("Shortcut Dimension 1 Code",Cust."Global Dimension 1 Code");
                        //IF Cust."Global Dimension 2 Code" <> '' THEN
                        //  VALIDATE("Shortcut Dimension 2 Code",Cust."Global Dimension 2 Code");
                        //+NPR5.30 [261728]

                    end;
                end;

                if "Customer No." = '' then begin
                    Name := '';
                    Address := '';
                    "Address 2" := '';
                    "Post Code" := '';
                    City := '';
                    "Contact No." := '';
                    //-NPR5.53 [380453]
                    Validate("Country Code", '');
                    //+NPR5.53 [380453]
                end;

                if Cust."No." <> '' then
                    "Prices Including VAT" := Cust."Prices Including VAT"
                else
                    //-NPR5.31 [269105]
                    ////"Price including VAT" := Ops�tning."Prices incl. VAT";
                    //"Price including VAT" := Ops�tning."Prices Include VAT";
                    "Prices Including VAT" := RetailSetup."Prices incl. VAT";
                //+NPR5.31 [269105]

                if not Modify then;

                if ("Customer Type" = "Customer Type"::Ord) then begin
                    SaleLinePOS.Reset;
                    SaleLinePOS.SetRange("Register No.", "Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                    SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
                    SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
                    SaleLinePOS.SetRange(Date, Date);
                    //-NPR5.55 [380979]
                    if not SaleLinePOS.IsEmpty and ("Prices Including VAT" <> xRec."Prices Including VAT") then begin
                        SaleLinePOS.ModifyAll(Amount, 0);
                        SaleLinePOS.ModifyAll("Amount Including VAT", 0);
                        SaleLinePOS.ModifyAll("VAT Base Amount", 0);
                        SaleLinePOS.ModifyAll("Line Amount", 0);
                        SaleLinePOS.ModifyAll("Invoice Discount Amount", 0);
                    end;
                    //+NPR5.55 [380979]
                    if SaleLinePOS.FindSet(true, false) then begin
                        repeat
                            xSaleLinePOS := SaleLinePOS;  //NPR5.52 [359596]
                            Item.Get(SaleLinePOS."No.");
                            SaleLinePOS.Internal := Cust."Internal y/n";
                            SaleLinePOS."Customer Price Group" := "Customer Price Group";
                            //-NPR5.32 [248534]
                            SaleLinePOS."Allow Line Discount" := "Allow Line Discount";
                            SaleLinePOS."Price Includes VAT" := "Prices Including VAT";
                            SaleLinePOS."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
                            SaleLinePOS."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
                            SaleLinePOS."Tax Area Code" := "Tax Area Code";
                            SaleLinePOS."Tax Liable" := "Tax Liable";
                            //+NPR5.32 [248534]
                            //-NPR5.32.01 [248534]
                            //SaleLinePOS."VAT %"                   := SaleLinePOS.HentMomsPct( SaleLinePOS."Item Group" );
                            SaleLinePOS.UpdateVATSetup;
                            //+NPR5.32.01 [248534]
                            //-NPR5.45 [323705]
                            //SaleLinePOS."Unit Price"              := SaleLinePOS.FindItemSalesPrice( SaleLinePOS );
                            //SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();  //NPR5.52 [359596]-revoked
                            //-NPR5.52 [359596]
                            //Recalc.existing price to reflect possible VAT Rate/Price Inc. VAT change
                            POSSaleLine.ConvertPriceToVAT(
                              xSaleLinePOS."Price Includes VAT", xSaleLinePOS."VAT Bus. Posting Group", xSaleLinePOS."VAT Prod. Posting Group",
                              SaleLinePOS, SaleLinePOS."Unit Price");
                            NewUnitPrice := SaleLinePOS.FindItemSalesPrice();
                            if (NewUnitPrice < SaleLinePOS."Unit Price") or
                               not (xRec."Customer No." in ['', "Customer No."])
                            then
                                SaleLinePOS."Unit Price" := NewUnitPrice;
                            //+NPR5.52 [359596]
                            //+NPR5.45 [323705]
                            SaleLinePOS.GetAmount(SaleLinePOS, Item, SaleLinePOS."Unit Price");
                            SaleLinePOS.Modify;
                        until SaleLinePOS.Next = 0;
                        //-NPR5.52 [359596]-revoked
                        //SaleLinePOS.VALIDATE("Unit of Measure Code");
                        //SaleLinePOS.MODIFY;
                        //+NPR5.52 [359596]-revoked
                    end;
                end;

                //-NPR5.45 [326466]
                POSSalesDiscountCalcMgt.RecalculateAllSaleLinePOS(Rec);
                //+NPR5.45 [326466]

                //Ændring foretaget for at kunne validere på nummer og slette rabatter på linier, ved ændring af kundenummer.
                Modify;

                //-NPR5.30 [261728]
                //IF Cust.GET("Customer No.") THEN BEGIN
                //  IF Cust."Bill-to Customer No."<>'' THEN
                //    Custno := Cust."Bill-to Customer No."
                //  ELSE
                //    Custno:=Cust."No.";
                //END;
                //+NPR5.30 [261728]

                //TempNPRDim.GetDimensions(DATABASE::"Sale POS","Register No.","Sales Ticket No.",0,0D,0,'',TempNPRDim);

                //-NPR4.21
                //CreateDim(
                //  DATABASE::Register,"Register No.",
                //  DATABASE::Customer,Custno,
                //  DATABASE::"Salesperson/Purchaser","Salesperson Code");
                CreateDim(
                  //-NPR5.30 [261728]
                  //DATABASE::Customer,Custno,
                  DATABASE::Customer, "Customer No.",
                  //+NPR5.30 [261728]
                  //DATABASE::Register,"Register No.",  //NPR5.53 [371956]-revoked
                  //-NPR5.53 [371956]
                  DATABASE::"POS Unit", "Register No.",
                  DATABASE::"POS Store", "POS Store Code",
                  //+NPR5.53 [371956]
                  DATABASE::Job, "Event No.",  //NPR5.53 [376035]
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
                //+NPR4.21

                //TempNPRDim.UpdateAllLineDim(DATABASE::"Sale POS","Register No.","Sales Ticket No.",0,0D,TempNPRDim);
            end;
        }
        field(8; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(9; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(10; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(11; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(12; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(15; "Contact No."; Text[30])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(16; Reference; Text[30])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(33; "Allow Line Discount"; Boolean)
        {
            Caption = 'Allow Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(34; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
        }
        field(36; "Sales Document Type"; Option)
        {
            Caption = 'Sales Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(37; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            DataClassification = CustomerContent;
        }
        field(39; "Last Shipping No."; Code[20])
        {
            Caption = 'Last Shipping No.';
            DataClassification = CustomerContent;
        }
        field(40; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            DataClassification = CustomerContent;
        }
        field(45; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
        }
        field(50; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
        }
        field(60; "Send Receipt Email"; Boolean)
        {
            Caption = 'Send Receipt Email';
            DataClassification = CustomerContent;
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Gen. Business Posting Group";
        }
        field(100; "Saved Sale"; Boolean)
        {
            Caption = 'Saved Sale';
            DataClassification = CustomerContent;
        }
        field(101; "Customer Relations"; Option)
        {
            Caption = 'Customer Relations';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Cash Customer';
            OptionMembers = " ",Customer,"Cash Customer";
        }
        field(102; "Last Sale"; Boolean)
        {
            Caption = 'Last Sale';
            DataClassification = CustomerContent;
        }
        field(105; Kontankundenr; Code[20])
        {
            Caption = 'Cash Customer No.';
            DataClassification = CustomerContent;
        }
        field(106; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ord,Cash;
        }
        field(107; "Org. Bonnr."; Code[20])
        {
            Caption = 'Original Ticket No.';
            DataClassification = CustomerContent;
        }
        field(108; "Non-editable sale"; Boolean)
        {
            Caption = 'Non-Editable Sale';
            DataClassification = CustomerContent;
        }
        field(109; "Sale type"; Option)
        {
            Caption = 'Sale type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Annullment';
            OptionMembers = Sale,Annullment;
        }
        field(111; "Retursalg Bonnummer"; Code[20])
        {
            Caption = 'Reversesale Ticket No.';
            DataClassification = CustomerContent;
            Description = 'Giver mulighed for at tilbagef¢re KUN ÉN bon - benyttet i CU Ekspeditionsmenu';
        }
        field(112; Parameters; Text[250])
        {
            Caption = 'Parameters';
            DataClassification = CustomerContent;
            Description = 'Overf¢r parametre fra ekspeditionen til underfunktioner. Brug f.eks.  Ÿ som separator';
        }
        field(113; "From Quote no."; Code[20])
        {
            Caption = 'From Quote no.';
            DataClassification = CustomerContent;
        }
        field(115; "Service No."; Code[20])
        {
            Caption = 'Service No.';
            DataClassification = CustomerContent;
        }
        field(116; "Stats - Customer Post Code"; Code[20])
        {
            Caption = 'Stats - Customer Post Code';
            DataClassification = CustomerContent;
        }
        field(117; "Retail Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(118; "Retail Document No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(119; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
        }
        field(120; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SaleLinePOS: Record "Sale Line POS";
                xSaleLinePOS: Record "Sale Line POS";
                POSSaleLine: Codeunit "POS Sale Line";
            begin
                //-NPR5.52 [352473]
                if "Prices Including VAT" = xRec."Prices Including VAT" then
                    exit;

                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
                SaleLinePOS.SetRange(Date, Date);
                if SaleLinePOS.FindSet(true, false) then begin
                    repeat
                        xSaleLinePOS := SaleLinePOS;

                        SaleLinePOS.Validate("Price Includes VAT", "Prices Including VAT");
                        POSSaleLine.ConvertPriceToVAT(
                          xSaleLinePOS."Price Includes VAT", xSaleLinePOS."VAT Bus. Posting Group", xSaleLinePOS."VAT Prod. Posting Group", SaleLinePOS, SaleLinePOS."Unit Price");

                        SaleLinePOS.UpdateAmounts(SaleLinePOS);
                        SaleLinePOS.Modify(true);
                    until SaleLinePOS.Next = 0;
                end;
                //+NPR5.52 [352473]
            end;
        }
        field(121; TouchScreen; Boolean)
        {
            Caption = 'TouchScreen';
            DataClassification = CustomerContent;
        }
        field(123; Deposit; Decimal)
        {
            Caption = 'Deposit';
            DataClassification = CustomerContent;
        }
        field(126; "Alternative Register No."; Code[20])
        {
            Caption = 'Alternative Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(127; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(128; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(130; "Custom Print Object ID"; Integer)
        {
            Caption = 'Custom Print Object ID';
            DataClassification = CustomerContent;
        }
        field(131; "Custom Print Object Type"; Text[10])
        {
            Caption = 'Custom Print Object Type';
            DataClassification = CustomerContent;
        }
        field(140; "Issue Tax Free Voucher"; Boolean)
        {
            Caption = 'Issue Tax Free Voucher';
            DataClassification = CustomerContent;
        }
        field(141; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(142; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(143; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "VAT Business Posting Group";
        }
        field(150; "Customer Location No."; Code[20])
        {
            Caption = 'Customer Location No.';
            DataClassification = CustomerContent;
        }
        field(160; "POS Sale ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'POS Sale ID';
            DataClassification = CustomerContent;
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
        }
        field(180; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53 [376035]';
            TableRelation = Job WHERE(Event = CONST(true));

            trigger OnValidate()
            var
                FromDefDim: Record "Default Dimension";
                ToDefDim: Record "Default Dimension";
                POSUnit: Record "POS Unit";
            begin
                //-NPR5.53 [376035]
                CreateDim(
                  DATABASE::Job, "Event No.",
                  DATABASE::"POS Unit", "Register No.",
                  DATABASE::"POS Store", "POS Store Code",
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
                //+NPR5.53 [376035]
            end;
        }
        field(200; "Device ID"; Text[50])
        {
            Caption = 'Device ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(201; "Host Name"; Text[100])
        {
            Caption = 'Host Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(210; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(300; Amount; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Sale Line POS".Amount WHERE("Register No." = FIELD("Register No."),
                                                            "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                            "Sale Type" = FILTER(Sale | "Debit Sale" | "Gift Voucher" | "Credit Voucher" | Deposit),
                                                            Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Amount';
            Description = 'NPR5.54';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Trans0001: Label 'The sign on quantity and amount must be the same';
            begin
            end;
        }
        field(310; "Amount Including VAT"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Sale Line POS"."Amount Including VAT" WHERE("Register No." = FIELD("Register No."),
                                                                            "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                            "Sale Type" = FILTER(Sale | "Debit Sale" | "Gift Voucher" | "Credit Voucher" | Deposit),
                                                                            Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Amount Including VAT';
            Description = 'NPR5.54';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320; "Payment Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Sale Line POS"."Amount Including VAT" WHERE("Register No." = FIELD("Register No."),
                                                                            "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                            "Sale Type" = FILTER(Payment | "Out payment"),
                                                                            Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Payment Amount';
            Description = 'NPR5.54';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim;
            end;
        }
        field(485; "Customer Name"; Text[50])
        {
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Caption = 'Customer Name';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(700; "NPRE Pre-Set Seating Code"; Code[10])
        {
            Caption = 'Pre-Set Seating Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPRE Seating";

            trigger OnValidate()
            var
                SaleLinePOS: Record "Sale Line POS";
                SaleLinePOS2: Record "Sale Line POS";
            begin
                //-NPR5.53 [380609]
                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
                if "NPRE Pre-Set Seating Code" <> '' then
                    SaleLinePOS.SetRange("NPRE Seating Code", xRec."NPRE Pre-Set Seating Code");
                if SaleLinePOS.FindSet(true) then
                    repeat
                        SaleLinePOS2 := SaleLinePOS;
                        SaleLinePOS2.Validate("NPRE Seating Code", "NPRE Pre-Set Seating Code");
                        SaleLinePOS2.Modify;
                    until SaleLinePOS.Next = 0;
                //+NPR5.53 [380609]
            end;
        }
        field(701; "NPRE Pre-Set Waiter Pad No."; Code[20])
        {
            Caption = 'Pre-Set Waiter Pad No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPRE Waiter Pad";
        }
        field(710; "NPRE Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.")
        {
        }
        key(Key2; "Salesperson Code", "Saved Sale")
        {
        }
        key(Key3; "Register No.", "Saved Sale")
        {
        }
        key(Key4; "Retail ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        RetailSetup.Get;

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        RetailSetup.Get;

        Register.Get("Register No.");
        "Location Code" := Register."Location Code";
        "Customer Disc. Group" := Register."Customer Disc. Group";
        "POS Sale ID" := 0;
        "Event No." := Register."Active Event No.";  //NPR5.53 [376035]

        //-NPR5.54 [391871]
        if IsNullGuid("Retail ID") then begin
            "Retail ID" := CreateGuid();
        end;
        //+NPR5.54 [391871]
    end;

    var
        Text1060002: Label 'You are not permitted to enter customers! Contact the system administrator.';
        RetailSetup: Record "Retail Setup";
        SalesPerson: Record "Salesperson/Purchaser";
        DimMgt: Codeunit DimensionManagement;
        NPRDimMgt: Codeunit NPRDimensionManagement;
        Register: Record Register;
        POSUnit: Record "POS Unit";
        POSStore: Record "POS Store";

    procedure LookUpShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        //Lookupshortcutdimcode
        RetailSetup.Get;
        if RetailSetup."Use Adv. dimensions" then
            NPRDimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
    end;

    procedure DeleteDimOnEkspAndLines()
    var
        EkspeditionLinie: Record "Sale Line POS";
    begin
        //DeleteDimOnEkspAndLines()

        RetailSetup.Get;
        if not RetailSetup."Use Adv. dimensions" then
            exit;

        if "Register No." <> '' then
            if "Sales Ticket No." <> '' then begin
                NPRDimMgt.DeleteNPRDim(DATABASE::"Sale POS", "Register No.", "Sales Ticket No.", 0D, 0, 0, '');
                EkspeditionLinie.SetRange("Register No.", "Register No.");
                EkspeditionLinie.SetRange("Sales Ticket No.", "Sales Ticket No.");
                with EkspeditionLinie do begin
                    //-NPR5.45 [323705]
                    //IF FIND('-') THEN
                    if FindSet then
                        //+NPR5.45 [323705]
                        repeat
                            NPRDimMgt.DeleteNPRDim(DATABASE::"Sale Line POS", "Register No.",
                            "Sales Ticket No.", Date, "Sale Type", "Line No.", '');
                        until Next = 0;
                end;
            end;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20]; Type5: Integer; No5: Code[20])
    var
        RetailConfiguration: Record "Retail Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        OldDimSetID: Integer;
    begin
        RetailConfiguration.Get;
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        //-NPR5.53 [371956]
        TableID[4] := Type4;
        No[4] := No4;
        //+NPR5.53 [371956]
        //-NPR5.53 [376035]
        TableID[5] := Type5;
        No[5] := No5;
        //+NPR5.53 [376035]
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(TableID, No, RetailConfiguration."Posting Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        //-NPR5.29
        // IF (OldDimSetID <> "Dimension Set ID") AND SalesLinesExist THEN BEGIN
        //  MODIFY;
        //  UpdateAllLineDim("Dimension Set ID",OldDimSetID);
        // END;
        if (OldDimSetID <> "Dimension Set ID") then begin
            Modify;
            if SalesLinesExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
        //-NPR5.29
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "Sales Ticket No." <> '' then
            Modify;

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify;
            if SalesLinesExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', "Register No.", "Sales Ticket No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then begin
            Modify;
            if SalesLinesExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        SaleLinePOS: Record "Sale Line POS";
        NewDimSetID: Integer;
    begin
        // Update all lines with changed dimensions.
        if NewParentDimSetID = OldParentDimSetID then
            exit;

        // By default always update dimensions
        // IF NOT CONFIRM(Text064) THEN
        //   EXIT;

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.LockTable;
        //-NPR5.45 [323705]
        //IF SaleLinePOS.FIND('-') THEN
        if SaleLinePOS.FindSet then
            //+NPR5.45 [323705]
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(SaleLinePOS."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if SaleLinePOS."Dimension Set ID" <> NewDimSetID then begin
                    SaleLinePOS."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      SaleLinePOS."Dimension Set ID", SaleLinePOS."Shortcut Dimension 1 Code", SaleLinePOS."Shortcut Dimension 2 Code");
                    SaleLinePOS.Modify;
                    // Investigate
                    // ATOLink.UpdateAsmDimFromSalesLine(SalesLine);
                end;
            until SaleLinePOS.Next = 0;
    end;

    procedure SalesLinesExist(): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        exit(SaleLinePOS.FindFirst);
    end;

    local procedure GetPOSUnit()
    begin
        //-NPR5.30 [261728]
        if POSUnit."No." <> "Register No." then
            POSUnit.Get("Register No.");
        //+NPR5.30 [261728]
    end;

    local procedure GetPOSStore()
    begin
        //-NPR5.30 [261728]
        if POSStore.Code <> "POS Store Code" then
            POSStore.Get("POS Store Code");
        //+NPR5.30 [261728]
    end;
}


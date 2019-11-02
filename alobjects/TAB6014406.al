table 6014406 "Sale Line POS"
{
    // VRT1.00/JDH /20150305  CASE 201022 Possible to get customer prices on POS
    // NPR4.04/JDH /20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.10/VB  /20150602  CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.10/RMT /20150603  CASE 214310 Removed filter when finding next line number
    // NPR4.14/RMT /20150715  CASE 216519 Added fields - used for registering prepayment
    //                                   140 "Sales Document Type"
    //                                   141 "Sales Document No."
    //                                   142 "Sales Document Line No."
    //                                   143 "Sales Document Prepayment"
    //                                   144 "Sales Doc. Prepayment %"
    //                                   145 "Sales Document Invoice"
    //                                   146 "Sales Document Ship"
    //                                   recalculate Prepayment % if unit price is changed
    // NPR4.16/JDH /20151104  CASE 212229 Removed references to old Variant solution "Color Size"
    // NPR5.00/VB  /20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.01/RMT /20160217  CASE 234145 Change field "Register No." property "SQL Data Type" from Variant to <Undefined>
    //                                     Change field "Sales Ticket No." property "SQL Data Type" from Variant to <Undefined>
    //                                     NOTE: require data upgrade
    // TM1.09 /TSA /20160301  CASE 235860 Sell event tickets in POS
    // NPR5.22/VB  /20160406  CASE 237866 Added SQL Server Timestamp field to keep track of record updates when exchanging data with JavaScript
    // NPR5.22/MMV /20160408  CASE 232067 Added field 150 "Customer Location No." : Code[20]
    // NPR5.22/JC  /20160421  CASE 239058 VAT calculation issue using VAT prod posting group from item
    // NPR5.23/MMV /20160527  CASE 237189 Commented out deprecated function KundeDisplay()
    // NPR5.23/MHA /20160530  CASE 242929 Field 6039 "Description 2" length increased from 30 to 50
    // NPR5.29/THRO/20161130  CASE 259899 Bugfix. Trying to get Customer without checking if "Customer No." is customer or Contact
    // NPR5.29/TJ  /20161223  CASE 249720 Replaced calling of standard codeunit 7000 Sales Price Calc. Mgt. with our own codeunit 6014453 POS Sales Price Calc. Mgt.
    // NPR5.29/MMV /20170110  CASE 260033 Updated report selection code.
    // NPR5.29/AP  /20170119  CASE 257938 Fixing dimension issues. Dimension Set not propagated correctly from header to line and with proper priority.
    // NPR5.29/BHR /20172001  CASE 261127 Validate Variant to trigger correct description on sales line
    // NPR5.29/MHA /20170117  CASE 263043 GetTrueItemNo() should only be invoked upon change of "No."
    // NPR5.30/TS  /20170130  CASE 264914 Removed field SportingPartner
    // NPR5.30/MHA /20170201  CASE 264918 Np Photo Module removed
    // NPR5.30/TS  /20170130  CASE 264917 Removed code reference field 3.5x Variant
    // NPR5.30/TJ  /20170215  CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/AP  /20170302  CASE 266785 General clean-up, refactoring.
    //                                    Renamed field "Price Group Code" -> "Customer Price Group"
    //                                    Deleted fields 6040 "OK", 6042 "Hidden", 7015 "Shopname"
    // NPR5.31/MHA /20170210  CASE 262904 Removed direct discount calculations and added functions to enable Subscriber based Discount Calculation: GetSkipCalcDiscount(),SetSkipCalcDiscount()
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.31/AP  /20170227  CASE 248534 Re-introduced US Sales Tax
    //                                    Added the fields 84 "Gen. Posting Type", 85 "Tax Area Code", 86 "Tax Liable", 87 "Tax Group Code", 88 "Use Tax"
    // NPR5.31/AP  /20170403  CASE 262628 Added new fields 160 Orig. POS Sale ID and 161 Orig. Line No. - surrogate keys for originating refs. for tickets, memebers, payments etc.
    // NPR5.31/MHA /20170413  CASE 272109 "BOM List" Lines should not be set as Type Item but will be converted to Comment Line in Audit Roll
    // NPR5.32/AP  /20170227  CASE 248534 Fixed issues regarding VAT update
    // NPR5.32/JDH /20170525  CASE 278031 Changed "Unit" to "Unit of measure Code" (should also be a type Code)
    //                                    Changed "Belong to Item Group" to "Item Group"
    //                                    Changed a couple of captions, and aligned an Option (field 302) where Enu caption didnt match option string
    // NPR5.32.01/AP/20170530  CASE 248534 More issues regarding VAT refactoring. VAT % not always set correct when updating exiting lines. Discounts on returns not VAT'ed correctly when posting.
    // NPR5.33/AP  /20170627  CASE 278605 Fixed issue with Reverse Charge VAT (EU)
    //                                    Syncing option string and ENU Captions for VAT Calculation Type. Option string was in DAN and not correctly translated.
    //                                    Also added option Puljemoms/Pool VAT seems not to be used in this context - and is not compatible with price calculations and debetsales.
    //                                    Old Option string:
    //                                      "Normal moms,Modtagermoms,Momskorrektion,Sales tax,Puljemoms"/ENU=ENU=Regular VAT,Reverse Charge VAT,VAT Correction,Sales VAT,Pool VAT
    //                                    New Option string:
    //                                      "Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax"
    // NPR5.34/JDH /20170629  CASE 280329 Reworked field "Special Price" - renamed vars etc (no functional change)
    // NPR5.34/MHA /20170720  CASE 282799 Added fields 420 "Coupon Qty." and 425 "Coupon Discount Amount"
    // NPR5.34/JC  /20170720  CASE 284658 Changed function ReverseCalculateTax to CalculateTax for North America Sales Tax
    // NPR5.35/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.37/JDH /20171026  CASE 294640 Changed "Item group" and "Bin code" field to code 10.
    // NPR5.38/MMV /20171122  CASE 296642 Do not round non-cash types with global precision setup.
    //                                    Skip rounding entirely for transcendence.
    // NPR5.38/TSA /20171121  CASE 296851 Fixed OnValidate code for "Discount Amount"
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.38/MHA /20180105  CASE 301053 Renamed field 6026 and 6027 from Danish to English
    // NPR5.40/BR  /20180126  CASE 303616 Fix Sales Tax Calculation
    // NPR5.39/TJ  /20180208  CASE 302634 Renamed OptionString property of field 302 "Return Sales Type" to english
    //                                    Renamed field 6029 to english
    // NPR5.39/MHA /20180214 CASE 305139 Added field 405 "Discount Authorised by"
    // NPR5.40/TSA /20180214 CASE 305045 Adding field 6100 "Main Line No."
    // NPR5.40/MMV /20180215 CASE 294655 Renamed field 402 from "Delete Discount Line" to "Discount Modified"
    //                                   Remove some obvious legacy code.
    // NPR5.40/MMV /20180223 CASE 306257 Transfer description to sales line after validation.
    // NPR5.41/MMV /20180416 CASE 311309 Refactored function UpdateAmounts for better sales tax implementation.
    //                                   Renamed field "Std. quantity" to "Quantity (Base)".
    //                                   Added field "VAT Identifier".
    // NPR5.41/TSA /20180424 CASE 312575 Added "Item Category Code", and "Product Group Code" assignment for items
    // NPR5.42/MMV /20180504 CASE 313062 Added "Coupon Applied"
    // NPR5.42/JC  /20180522 CASE 315194 Fix issue with getting Payment Type POS if using setup Payment type per register
    // NPR5.44/TJ  /20180717 CASE 317326 Moved item group confirmation to a subscriber
    // NPR5.45/MHA /20180803 CASE 323705 FindItemSalesPrice() updated to invoke price codeunits directly and deleted unused function GetLineUnitPriceInclVat()
    // NPR5.45/TSA /20180809 CASE 323615 "Discount Amount" should be same sign as quantity, changed UpdateAmounts()
    // NPR5.45/MHA /20180821 CASE 324395 Reworked "No.".OnValidate()
    // NPR5.48/TJ  /20181115 CASE 330832 Increased Length of field Item Category Code from 10 to 20
    // NPR5.48/JDH /20181113 CASE 334555 Changed Unit of measure code from Text to Code
    // NPR5.48/MHA /20181127 CASE 334922 Renamed field 21 "Line Discount %, manually" to "Manual Item Sales Price"
    // NPR5.48/JDH /20181113 CASE 335967 Implemented Unit of measure
    //                                   Renamed ItemGlobal to Item (Undocumented) and implemented function GetItem().
    // NPR5.48/TSA /20181217 CASE 338181 "Line Amount" assignment moved to after "Discount Amount" is calculated in function UpdateAmounts()
    // NPR5.48/MMV /20181220 CASE 340154 Renamed field 402
    // NPR5.48/TJ  /20190102 CASE 340615 Commented out usage of field Item."Product Group Code"
    // NPR5.50/MHA /20190422 CASE 337539 Added field 170 "Retail ID"
    // NPR5.50/MMV /20190320 CASE 300557 Added fields 147, 148, 151, 152, 155, 156, 157, 158
    //                                   Removed old prepayment % handling
    // NPR5.50/TSA /20190514 CASE 354832 Added VAT settings for payment lines (specifically for vouchers)
    // NPR5.51/THRO/20190624 CASE 359293 Make sure lastest version of Item is read in TestItem().
    // NPR5.51/MMV /20190627 CASE 359385 Changed EFT delete error wording and renamed field
    // NPR5.51/MHA /20190722 CASE 358985 Added hook OnGetVATPostingSetup() in UpdateVATSetup()
    // NPR5.51/MHA /20190812 CASE 358490 Removed test on RegisterGlobal."Credit Voucher Account" in Quantity - OnValidate()
    // NPR5.51/TSA /20190821 CASE 365487 Corner case when discount is 100% and VAT amount is rounded in different directions.
    // NPR5.52/MMV /20190910 CASE 352473 Added fields for more sales document control
    // NPR5.52/MHA /20191017 CASE 373294 Changed validation of Min. and Max. Amount for payment

    Caption = 'Sale Line';
    PasteIsValid = false;

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = Register;
        }
        field(2;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(3;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            Description = 'NPR5.30';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
        }
        field(6;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("G/L Entry")) "G/L Account"."No."
                            ELSE IF (Type=CONST("Item Group")) "Item Group"."No."
                            ELSE IF (Type=CONST(Repair)) "Customer Repair"."No."
                            ELSE IF (Type=CONST(Payment)) "Payment Type POS"."No." WHERE (Status=CONST(Active),
                                                                                          "Via Terminal"=CONST(false))
                                                                                          ELSE IF (Type=CONST(Customer)) Customer."No."
                                                                                          ELSE IF (Type=CONST(Item)) Item."No.";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                //-NPR5.45 [324395]
                InitFromSalePOS();

                RegisterGlobal.Get(Rec."Register No.");
                RetailSetup.Get;

                if (Type = Type::Item) and ("No." = '*') then begin
                  Type := Type::Comment;
                  "Sale Type" := "Sale Type"::Comment;
                end;

                case Type of
                  Type::"G/L Entry":
                    begin
                      InitFromGLAccount();
                      UpdateVATSetup();
                    end;
                  Type::Item,Type::"BOM List":
                    begin
                      InitFromItem();
                      UpdateVATSetup();
                      CalculateCostPrice();
                      "Unit Price" := FindItemSalesPrice();
                      Validate(Quantity);
                    end;
                  Type::"Item Group":
                    begin
                      InitFromItemGroup();
                      UpdateVATSetup();
                    end;
                  Type::Payment:
                    begin
                      InitFromPaymentTypePOS();
                    end;
                  Type::Customer:
                    begin
                      InitFromCustomer();
                    end;
                  else
                    exit;
                end;

                CreateDim(
                  DATABASE::Register,"Register No.",
                  NPRDimMgt.TypeToTableNPR(Type),"No.",
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code",
                  0,'');
                //+NPR5.45 [324395]
            end;
        }
        field(7;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(8;"Posting Group";Code[10])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type=CONST(Item)) "Inventory Posting Group";
        }
        field(9;"Qty. Discount Code";Code[20])
        {
            Caption = 'Qty. Discount Code';
        }
        field(10;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(11;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."))
                                ELSE "Unit of Measure";

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                //-NPR5.45 [324395]
                //-NPR5.48 [335967]
                // //RetailSalesLineCode.Unit(Rec,xRec,CustomerDiscount);
                // IF NOT ItemUoM.GET("No.","Unit of Measure Code") THEN
                //  ItemUoM."Qty. per Unit of Measure" := 1;
                //
                // VALIDATE("Quantity (Base)",ItemUoM."Qty. per Unit of Measure" * Quantity);
                GetItem;
                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
                "Quantity (Base)" := CalcBaseQty(Quantity);
                //+NPR5.48 [335967]

                "Unit Price" := FindItemSalesPrice();
                UpdateAmounts(Rec);
                //+NPR5.45 [324395]
            end;
        }
        field(12;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
            MaxValue = 99.999;

            trigger OnValidate()
            var
                SaleLinePOS: Record "Sale Line POS";
                Txt001: Label 'Quantity can not be changes on a repair sale';
                Err001: Label 'Quantity at %2 %1 can only be 1 or -1';
                Err003: Label 'A quantity must be specified on the line';
                OldUnitPrice: Decimal;
            begin
                //-NPR5.48 [335967]
                //CondFirstRun := FALSE;
                //+NPR5.48 [335967]

                //-NPR5.40 [294655]
                //RetailSetup.GET;
                //+NPR5.40 [294655]
                if ("Serial No." <> '') and
                  ("Sale Type" = "Sale Type"::Sale) and
                    (Abs(Quantity) <> 1) then
                      Error(Err001,
                        "Serial No.",FieldName("Serial No."));

                if ("Serial No." <> '') then
                  Validate("Serial No.","Serial No.");

                //-NPR5.48 [335967]
                //Cost := "Unit Cost" * Quantity;
                //+NPR5.48 [335967]

                case Type of
                  Type::"G/L Entry":
                    begin
                      if not Silent then begin
                        if Quantity = 0 then
                          Error(Err003);
                      end;
                      "Amount Including VAT" := "Unit Price" * Quantity;
                      Amount := "Amount Including VAT";
                    end;
                  Type::Item:
                    begin
                      //-NPR5.48 [335967]
                      // //-NPR5.45 [324395]
                      // //RetailSalesLineCode.QuantityValidate(Rec,xRec,CustomerDiscount);
                      // RetailSalesLineCode.QuantityValidate(Rec,xRec);
                      // //+NPR5.45 [324395]
                      // Copied code from RetailSalesLineCode.QuantityValidate (im not sure its correct, but its copyed "as is")
                      GetItem;
                      "Quantity (Base)" := CalcBaseQty(Quantity);

                      UpdateDependingLinesQuantity;

                      if ( "Discount Type" = "Discount Type"::Manual ) and ( "Discount %" <> 0 ) then
                        Validate( "Discount %" );

                      CalculateCostPrice;
                      UpdateAmounts(Rec);

                      if not Item."Group sale" then begin
                        OldUnitPrice := "Unit Price";
                        "Unit Price" := Rec.FindItemSalesPrice();
                        if OldUnitPrice <> "Unit Price" then
                          UpdateAmounts(Rec);
                      end;
                      //+NPR5.48 [335967]
                    end;
                  Type::"Item Group":
                    begin
                      if Quantity = 0 then
                        Error(Err003);
                //-NPR5.40 [294655]
                //      IF RetailSetup.GET THEN
                //+NPR5.40 [294655]
                        if "Price Includes VAT" then
                          "Amount Including VAT" := Round("Unit Price" * Quantity,0.01)
                        else
                          "Amount Including VAT" := Round("Unit Price" * Quantity * ( 1 + "VAT %"/100),0.01);
                    end;
                  Type::Repair:
                    begin
                      Error(Txt001);
                    end;
                  Type::"BOM List":
                    begin
                      SaleLinePOS.SetRange("Register No.","Register No.");
                      SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
                      SaleLinePOS.SetRange("Sale Type","Sale Type");
                      SaleLinePOS.SetRange(Date,Date);
                      SaleLinePOS.SetRange("Discount Code","Discount Code");
                      SaleLinePOS.SetFilter("No.",'<>%1',"No.");
                      "Amount Including VAT" := 0;
                    end;
                end;
                //-NPR5.48 [335967]
                UpdateCost;
                //+NPR5.48 [335967]
            end;
        }
        field(13;"Invoice (Qty)";Decimal)
        {
            Caption = 'Invoice (Qty)';
            DecimalPlaces = 0:5;
        }
        field(14;"To Ship (Qty)";Decimal)
        {
            Caption = 'To Ship (Qty)';
            DecimalPlaces = 0:5;
        }
        field(15;"Unit Price";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DecimalPlaces = 2:2;
            Editable = true;
            MaxValue = 9.999.999;

            trigger OnValidate()
            var
                ErrDisabled: Label 'Unit Cost is disabled';
                ErrDisNo: Label 'Unit Cost is disabled for Quantity > 0';
                ErrDisX: Label 'Unit Cost cannot be reduced';
                ErrItemBelow: Label 'Price cannot be negative.';
                Err001: Label 'A quantity must be specified on the line';
                Err002: Label 'The creditvoucher cannot be changed';
                Err003: Label 'The sales price cannot be changed for this item';
                TotalAmount: Decimal;
            begin
                //-NPR5.50 [300557]
                //-NPR4.14
                // IF "Sales Document Prepayment" THEN BEGIN
                //  IF "Sales Doc. Prepayment %"<>0 THEN BEGIN
                //    TotalAmount := xRec."Unit Price" / ("Sales Doc. Prepayment %"/100);
                //    IF TotalAmount <> 0 THEN
                //      "Sales Doc. Prepayment %" := ("Unit Price"/TotalAmount) * 100;
                //  END;
                // END;
                //+NPR4.14
                //+NPR5.50 [300557]
                RetailSetup.Get;
                RegisterGlobal.Get("Register No.");
                case Type of
                  Type::"G/L Entry":
                    begin
                      if Quantity <> 0 then begin
                        "Amount Including VAT" := "Unit Price" * Quantity;
                        Amount := "Amount Including VAT";
                      end;
                //-NPR5.40 [294655]
                //      IF RegisterGlobal.GET("Register No.") AND ("Sale Type" <> "Sale Type"::"Out payment") THEN
                      if ("Sale Type" <> "Sale Type"::"Out payment") then
                //+NPR5.40 [294655]
                        if not Silent then
                          if RegisterGlobal."Credit Voucher Account" = "No." then
                            Error(Err002)
                        else if RegisterGlobal."Gift Voucher Account" = "No." then begin
                          if GiftVoucher.Get("Discount Code") then begin
                            GiftVoucher.Amount := "Amount Including VAT";
                            GiftVoucher.Modify(true);
                          end;
                        end;
                    end;
                  Type::Item:
                    begin
                      if "Unit Price" < 0 then
                        Error(ErrItemBelow);
                      //-NPR5.48 [335967]
                      //ItemGlobal.GET("No.");
                      GetItem;
                      //+NPR5.48 [335967]

                      if not Item."Group sale" then begin
                        if not ForceApris then begin
                          case RetailSetup."Unit Cost Control" of
                            RetailSetup."Unit Cost Control"::Enabled:
                              begin
                              end;
                            RetailSetup."Unit Cost Control"::Disabled:
                              begin
                                if not (RetailSetup."Reset unit price on neg. sale" and (Quantity < 0)) then
                                  Error(ErrDisabled);
                              end;
                            RetailSetup."Unit Cost Control"::"Disabled if Quantity > 0":
                              begin
                                if Quantity > 0 then
                                  Error(ErrDisNo);
                              end;
                            RetailSetup."Unit Cost Control"::"Disabled if xUnit Cost > Unit Cost":
                              begin
                                if xRec."Unit Price" > "Unit Price" then
                                  Error(ErrDisX);
                              end;
                            RetailSetup."Unit Cost Control"::"Disabled if Quantity > 0 and xUnit Cost > Unit Cost":
                              begin
                                //-NPR5.45 [323705]
                                //IF NOT((Quantity < 0) OR ("Unit Price" >= FindItemSalesPrice(Rec))) THEN
                                if not((Quantity < 0) or ("Unit Price" >= FindItemSalesPrice())) then
                                //+NPR5.45 [323705]
                                  Error(ErrDisX);
                              end;
                          end;
                        end;
                      end;

                      "Eksp. Salgspris" := true;
                //-NPR5.40 [294655]
                //      ItemGlobal.GET("No.");
                //+NPR5.40 [294655]
                      GetAmount(Rec,Item,"Unit Price");
                      if ("No." <> '') then begin
                //-NPR5.40 [294655]
                //        IF (ItemGlobal.GET("No.") AND ItemGlobal."Group sale") OR (ItemGlobal.GET("No.") AND (ItemGlobal."Unit Cost" = 0)) THEN BEGIN
                        if (Item."Group sale") or (Item."Unit Cost" = 0) then begin
                //+NPR5.40 [294655]
                          CalculateCostPrice();
                        end else if ("Serial No." <> '') and (Quantity > 0) then
                          Error(Err003);
                      end;
                      "Custom Price" := true;
                    end;
                  Type::"Item Group":
                    begin
                      if Quantity = 0 then
                        Error(Err001);
                      if RetailSetup.Get then
                        if "Price Includes VAT" then
                          "Amount Including VAT" := Round("Unit Price" * Quantity,0.01) - "Discount Amount"
                        else
                          "Amount Including VAT" := Round("Unit Price" * Quantity * (1 + "VAT %"/100),0.01);
                    end;
                  Type::"BOM List":
                    begin
                      "Unit Price" := xRec."Unit Price";
                      exit;
                    end;
                  Type::Customer:
                    begin
                      if Quantity <> 0 then begin
                        "Amount Including VAT" := "Unit Price" * Quantity;
                        Amount := "Amount Including VAT";
                      end;
                    end;
                end;
            end;
        }
        field(16;"Unit Cost (LCY)";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
            Description = 'NPR5.45';

            trigger OnValidate()
            begin
                //-NPR5.48 [335967]
                "Unit Cost" := "Unit Cost (LCY)";

                //well i dont agree that we should maintain field "Cost" here, but its here, so we need to support it
                UpdateCost;
                //+NPR5.48 [335967]
            end;
        }
        field(17;"VAT %";Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(18;"Qty. Discount %";Decimal)
        {
            Caption = 'Qty. Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(19;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:1;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            var
                SaleLinePOS: Record "Sale Line POS";
                ErrMin: Label 'Discount % cannot be negative.';
                ErrMax: Label 'Discount % cannot exeed 100.';
                RetailFormCode: Codeunit "Retail Form Code";
                GiftFound: Boolean;
                Trans0001: Label 'A deptorpayment cannot have discount';
                Trans0002: Label 'An itemgroup cannot have discount';
                Trans0003: Label 'Financial posts cannot be given a rebate';
            begin
                if "Discount %" < 0 then
                  Error(ErrMin);

                if "Discount %" > 100 then
                  Error(ErrMax);

                //-NPR5.48 [334922]
                // IF CurrFieldNo = FIELDNO("Discount %") THEN
                //  "Line Discount %, manually" := TRUE
                // ELSE
                //  "Line Discount %, manually" := FALSE;
                //+NPR5.48 [334922]

                RetailSetup.Get;

                case Type of
                  Type::"G/L Entry":
                    begin
                      if not ("Sale Type" = "Sale Type"::Deposit) then
                        Error(Trans0003);
                      "Discount Type" := "Discount Type"::" ";
                      "Discount Code" := '';
                      "Discount Amount" := Round("Unit Price" * "Discount %" / 100,RetailSetup."Amount Rounding Precision");
                      "Amount Including VAT" := "Unit Price" - "Discount Amount";
                    end;
                  Type::Item:
                    begin
                      RemoveBOMDiscount;
                      //-NPR5.34 [282799]
                      //"Discount Type" := "Discount Type"::Manual;
                      if "Discount %" > 0 then
                        "Discount Type" := "Discount Type"::Manual;
                      //+NPR5.34 [282799]
                      "Discount Code" :=  xRec."Discount Code";
                      "Amount Including VAT" := 0;
                      "Discount Amount" := 0;
                      if Modify then;
                      RetailSalesLineCode.CalcAmounts(Rec);
                    end;
                  Type::"Item Group":
                    Error(Trans0002);
                  Type::"BOM List":
                    begin
                      "Discount %" := xRec."Discount %";
                      exit;
                    end;
                  Type::Customer:
                    Error(Trans0001);
                end;

                GiftFound := false;
                if ("Gift Voucher Ref." <> '') and not Silent then begin
                  SaleLinePOS.Reset;
                  if GiftCrtLine <> 0 then begin
                    SaleLinePOS.SetRange("Register No.","Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
                    SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::"Out payment");
                    SaleLinePOS.SetRange(Type,SaleLinePOS.Type::"G/L Entry");
                    SaleLinePOS.SetRange("Line No.",GiftCrtLine);
                    if SaleLinePOS.FindSet(true,false) then begin
                      if "Discount %" = 0 then begin
                        SaleLinePOS.Delete;
                      end else begin
                        GiftFound := true;
                        SaleLinePOS.Validate("Unit Price","Unit Price" * "Discount %" / 100);
                        SaleLinePOS.Modify;
                        Silent := true;
                        Validate("Discount %",0);
                        Silent := false;
                      end;
                    end
                  end;
                  if not GiftFound and ("Discount %" <> 0) then begin
                    GiftCrtLine := RetailFormCode.InsertGiftCrtDiscLine(Rec,"Line No." + 558,"Unit Price" * "Discount %" / 100);
                    Silent := true;
                    Validate("Discount %",0);
                    Silent := false;
                  end;
                end;
            end;
        }
        field(20;"Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Discount';
            MinValue = 0;

            trigger OnValidate()
            begin
                //-NPR5.38 [296851]
                if "Price Includes VAT" then begin
                  Validate("Discount %","Discount Amount" / "Unit Price" / Quantity * 100);
                end else begin
                  Validate("Discount %","Discount Amount" / "Unit Price" / Quantity / (100 + "VAT %") * 10000);
                end;
                //+NPR5.38 [296851]
            end;
        }
        field(21;"Manual Item Sales Price";Boolean)
        {
            Caption = 'Manual Item Sales Price';
            Description = 'NPR5.48';
            InitValue = false;
        }
        field(25;Date;Date)
        {
            Caption = 'Date';
        }
        field(30;Amount;Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DecimalPlaces = 2:2;
            MaxValue = 1.000.000;

            trigger OnValidate()
            var
                Trans0001: Label 'The sign on quantity and amount must be the same';
            begin
                //-NPR5.40 [294655]
                //RegisterGlobal.GET("Register No.");
                //+NPR5.40 [294655]
                if Amount <> xRec.Amount then begin
                  case Type of
                    Type::Item:
                      begin
                        //-NPR5.48 [335967]
                        //IF ItemGlobal.GET("No.") THEN BEGIN
                        GetItem;
                        //+NPR5.48 [335967]
                        if Amount * xRec.Amount <> Abs(Amount) * Abs(xRec.Amount) then
                          Error(Trans0001);

                        if not "Price Includes VAT" then
                          "Discount %" := (1 - Amount / ("Unit Price" * Quantity)) * 100
                        else
                          "Discount %" := (1 - Amount * ((100 + "VAT %") / 100) / ("Unit Price" * Quantity)) * 100;

                        "Discount Type" := "Discount Type"::Manual;
                        "Discount Code" := '';
                        "Discount Amount" := 0;
                        "Amount Including VAT" := 0;

                        if Modify then;

                        RetailSalesLineCode.CalcAmounts(Rec);
                        //-NPR5.48 [335967]
                        //END;
                        //+NPR5.48 [335967]
                      end;
                  end;
                end;
            end;
        }
        field(31;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            MaxValue = 99.999.999;

            trigger OnValidate()
            begin
                if "Unit Price" <> 0 then begin
                  if "Price Includes VAT"  then begin
                    Validate("Discount %",100 - "Amount Including VAT" / ("Unit Price" * Quantity) * 100 );
                  end else begin
                    Validate("Discount %",100 - "Amount Including VAT" / ("Unit Price" * Quantity) / (100 + "VAT %") * 10000);
                  end;
                end;

                if Type = Type::Payment then begin
                  //-NPR5.52 [373294]
                  if PaymentTypePOS."Maximum Amount" <> 0 then begin
                    if Abs("Amount Including VAT") > Abs(PaymentTypePOS."Maximum Amount") then
                      Error(ErrMaxExceeded,"No.",PaymentTypePOS."Maximum Amount");
                  end;
                  if PaymentTypePOS."Minimum Amount" <> 0 then begin
                    if Abs("Amount Including VAT") < PaymentTypePOS."Minimum Amount" then
                      Error(ErrMinExceeded,"No.",PaymentTypePOS."Minimum Amount");
                  end;
                  //+NPR5.52 [373294]
                  if EuroExchRate <> 0 then
                    Euro := "Amount Including VAT" / EuroExchRate;
                end;
            end;
        }
        field(32;"Allow Invoice Discount";Boolean)
        {
            Caption = 'Allow Invoice Discount';
            InitValue = true;
        }
        field(33;"Allow Line Discount";Boolean)
        {
            Caption = 'Allow Line Discount';
            InitValue = true;
        }
        field(34;"Price Includes VAT";Boolean)
        {
            Caption = 'Price Includes VAT';
        }
        field(38;"Initial Group Sale Price";Decimal)
        {
            Caption = 'Initial Group Sale Price';

            trigger OnValidate()
            begin

                Validate("Unit of Measure Code");
            end;
        }
        field(41;"Customer Price Group";Code[10])
        {
            Caption = 'Customer Price Group';
            Description = 'NPR5.30';
            TableRelation = "Customer Price Group";

            trigger OnValidate()
            begin
                Validate("No.");
            end;
        }
        field(42;"Allow Quantity Discount";Boolean)
        {
            Caption = 'Allow Quantity Discount';
            InitValue = true;
        }
        field(43;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            begin
                //-NPR5.48 [335967]
                //NFRetailCode.TR406SerialNoOnLookup(Rec);
                SerialNoLookup;
                // "Unit Cost"        := FindItemCostPrice(Item);
                // Cost               := "Unit Cost" * Quantity;
                // //-NPR5.45 [324395]
                // //"Unit Price (LCY)" := "Unit Cost";
                // "Unit Cost (LCY)" := "Unit Cost";
                // //+NPR5.45 [324395]
                //IF MODIFY THEN;
                //+NPR5.48 [335967]
            end;

            trigger OnValidate()
            begin
                //-NPR5.48 [335967]
                //NFRetailCode.TR406SerialNoOnValidate(Rec,TotalNonAppliedQuantity,TotalAuditRollQuantity,TotalItemLedgerEntryQuantity);
                SerialNoValidate();
                // "Unit Cost"        := FindItemCostPrice(Item);
                // Cost               := "Unit Cost" * Quantity;
                // //-NPR5.45 [324395]
                // //"Unit Price (LCY)" := "Unit Cost";
                // "Unit Cost (LCY)" := "Unit Cost";
                // //+NPR5.45 [324395]
                Validate("Unit Cost (LCY)", GetUnitCostLCY);
                //+NPR5.48 [335967]
            end;
        }
        field(44;"Customer/Item Discount %";Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(45;"Sales Order Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Sale Line POS"."Amount Including VAT");
            Caption = 'Sales Order Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(46;"Invoice to Customer No.";Code[20])
        {
            Caption = 'Invoice to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(47;"Invoice Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
        }
        field(48;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(49;"Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(50;"VAT Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(51;"VAT Prod. Posting Group";Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(52;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(53;"Claim (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Claim (LCY)';
            Editable = false;
        }
        field(54;"VAT Base Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(55;Cost;Decimal)
        {
            Caption = 'Cost';
        }
        field(56;Euro;Decimal)
        {
            Caption = 'Euro';

            trigger OnValidate()
            var
                OriginalEUROamount: Decimal;
            begin
                OriginalEUROamount := Euro;
                Validate("Amount Including VAT",Euro * EuroExchRate);
                Euro := OriginalEUROamount;
                Validate("Currency Amount",Euro);
            end;
        }
        field(57;"Quantity (Base)";Decimal)
        {
            Caption = 'Quantity (Base)';
        }
        field(58;"Period Discount code";Code[20])
        {
            Caption = 'Period Discount code';
            TableRelation = "Period Discount".Code;

            trigger OnValidate()
            begin
                //-NPR5.45 [324395]
                // CreateDim(
                //  DATABASE::Register,"Register No.",
                //  NPRDimMgt.TypeToTableNPR(Type),"No.",
                //  DATABASE::"Period Discount","Period Discount code",
                //  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code");
                CreateDim(
                  DATABASE::Register,"Register No.",
                  NPRDimMgt.TypeToTableNPR(Type),"No.",
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code",
                  0,'');
                //+NPR5.45 [324395]
            end;
        }
        field(59;"Lookup On No.";Boolean)
        {
            Caption = 'Lookup On No.';
        }
        field(70;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';

            trigger OnLookup()
            begin
                LookupShortcutDimCode(1,"Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code","Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
            end;
        }
        field(71;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';

            trigger OnLookup()
            begin
                LookupShortcutDimCode(2,"Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code","Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
            end;
        }
        field(75;"Bin Code";Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code;
        }
        field(80;"Special price";Decimal)
        {
            Caption = 'Special price';

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if "Special price" = 0 then begin
                  //-NPR5.48 [335967]
                  //ItemGlobal.GET("No.");
                  GetItem;
                  //+NPR5.48 [335967]
                  "Custom Price" := false;
                  "Eksp. Salgspris" := false;
                  //-NPR5.45 [323705]
                  //GetAmount(Rec,ItemGlobal,FindItemSalesPrice(Rec));
                  GetAmount(Rec,Item,FindItemSalesPrice());
                  //+NPR5.45 [323705]
                end else begin
                  //-NPR5.48 [335967]
                  //SalePOS.GET("Register No.","Sales Ticket No.");
                  GetPOSHeader;
                  //+NPR5.48 [335967]
                  if Customer.Get(SalePOS."Customer No.") then begin
                    if Customer.Type = Customer.Type::Cash then begin
                      if Customer."Prices Including VAT" then
                        Validate("Unit Price","Special price" * (1 + "VAT %" / 100))
                      else
                        Validate("Unit Price","Special price");
                      if "Discount %" <> 0 then
                        Validate("Discount %", 0);
                    end;
                  end;
                end;
            end;
        }
        field(84;"Gen. Posting Type";Option)
        {
            Caption = 'Gen. Posting Type';
            Description = 'NPR5.31';
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;

            trigger OnValidate()
            begin
                //-NPR5.31 [248534]
                if "Gen. Posting Type" > 0 then
                  TestField(Type,Type::"G/L Entry");
                //+NPR5.31 [248534]
            end;
        }
        field(85;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(86;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
            Description = 'NPR5.31';
        }
        field(87;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            Description = 'NPR5.31';
            TableRelation = "Tax Group";
        }
        field(88;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';
            Description = 'NPR5.31';
        }
        field(90;"Return Reason Code";Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(91;"Reason Code";Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(100;"Unit Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DecimalPlaces = 2:2;
            Editable = false;

            trigger OnValidate()
            begin
                if "Unit Cost" <> 0 then begin
                  "Custom Cost" := true;
                  //-NPR5.45 [324395]
                  //"Unit Price (LCY)" := "Unit Cost";
                  "Unit Cost (LCY)" := "Unit Cost";
                  //+NPR5.45 [324395]
                  //-NPR5.48 [335967]
                  //Cost := "Unit Cost" * Quantity;
                  UpdateCost;
                  //+NPR5.48 [335967]
                end else begin
                  "Custom Cost" := false;
                  Validate("No.");
                end;
            end;
        }
        field(101;"System-Created Entry";Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(102;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));

            trigger OnValidate()
            begin
                Validate("No.");
            end;
        }
        field(103;"Line Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';

            trigger OnValidate()
            begin
                TestField(Type);
                TestField(Quantity);
                TestField("Unit Price");
                GetPOSHeader;
                "Line Amount" := Round("Line Amount",Currency."Amount Rounding Precision");
            end;
        }
        field(106;"VAT Identifier";Code[10])
        {
            Caption = 'VAT Identifier';
            Editable = false;
        }
        field(117;"Retail Document Type";Option)
        {
            Caption = 'Retail Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(118;"Retail Document No.";Code[20])
        {
            Caption = 'Retail Document No.';
        }
        field(140;"Sales Document Type";Integer)
        {
            Caption = 'Sales Document Type';
        }
        field(141;"Sales Document No.";Code[20])
        {
            Caption = 'Sales Document No.';
        }
        field(142;"Sales Document Line No.";Integer)
        {
            Caption = 'Sales Document Line No.';
        }
        field(143;"Sales Document Prepayment";Boolean)
        {
            Caption = 'Sales Document Prepayment';
        }
        field(144;"Sales Doc. Prepayment Value";Decimal)
        {
            Caption = 'Sales Doc. Prepayment Value';
        }
        field(145;"Sales Document Invoice";Boolean)
        {
            Caption = 'Sales Document Invoice';
        }
        field(146;"Sales Document Ship";Boolean)
        {
            Caption = 'Sales Document Ship';
        }
        field(147;"Sales Document Sync. Posting";Boolean)
        {
            Caption = 'Sales Document Sync. Posting';
        }
        field(148;"Sales Document Print";Boolean)
        {
            Caption = 'Sales Document Print';
        }
        field(149;"Sales Document Receive";Boolean)
        {
            Caption = 'Sales Document Receive';
        }
        field(150;"Customer Location No.";Code[20])
        {
            Caption = 'Customer Location No.';
        }
        field(151;"Sales Document Prepay. Refund";Boolean)
        {
            Caption = 'Sales Document Prepay. Refund';
        }
        field(152;"Sales Document Delete";Boolean)
        {
            Caption = 'Sales Document Delete';
        }
        field(153;"Sales Doc. Prepay Is Percent";Boolean)
        {
            Caption = 'Sales Doc. Prepay Is Percent';
        }
        field(154;"Sales Document Pdf2Nav";Boolean)
        {
            Caption = 'Sales Document Pdf2Nav';
        }
        field(155;"Posted Sales Document Type";Option)
        {
            Caption = 'Posted Sales Document Type';
            OptionCaption = 'Invoice,Credit Memo';
            OptionMembers = INVOICE,CREDIT_MEMO;
        }
        field(156;"Posted Sales Document No.";Code[20])
        {
            Caption = 'Posted Sales Document No.';
            TableRelation = IF ("Posted Sales Document Type"=CONST(INVOICE)) "Sales Invoice Header"
                            ELSE IF ("Posted Sales Document Type"=CONST(CREDIT_MEMO)) "Sales Cr.Memo Header";
        }
        field(157;"Delivered Sales Document Type";Option)
        {
            Caption = 'Delivered Sales Document Type';
            OptionCaption = 'Shipment,Return Receipt';
            OptionMembers = SHIPMENT,RETURN_RECEIPT;
        }
        field(158;"Delivered Sales Document No.";Code[20])
        {
            Caption = 'Delivered Sales Document No.';
            TableRelation = IF ("Delivered Sales Document Type"=CONST(SHIPMENT)) "Sales Shipment Header"
                            ELSE IF ("Delivered Sales Document Type"=CONST(RETURN_RECEIPT)) "Return Receipt Header";
        }
        field(159;"Sales Document Send";Boolean)
        {
            Caption = 'Sales Document Send';
        }
        field(160;"Orig. POS Sale ID";Integer)
        {
            Caption = 'Orig. POS Sale ID';
            Description = 'NPR5.31';
        }
        field(161;"Orig. POS Line No.";Integer)
        {
            Caption = 'Orig. POS Line No.';
            Description = 'NPR5.31';
        }
        field(170;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
            Description = 'NPR5.50';
        }
        field(200;"Qty. per Unit of Measure";Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0:5;
            Editable = false;
            InitValue = 1;
        }
        field(300;"Return Sale Register No.";Code[10])
        {
            Caption = 'Return Sale Cash Register No.';
        }
        field(301;"Return Sale Sales Ticket No.";Code[20])
        {
            Caption = 'Return Sale Sales Ticket No.';
        }
        field(302;"Return Sales Sales Type";Option)
        {
            Caption = 'Return Sales Sales Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Payment1,Disbursement,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Payment1,Disbursement,Comment,,"Open/Close";
        }
        field(303;"Return Sale Line No.";Integer)
        {
            Caption = 'Return Sale Line No.';
        }
        field(304;"Return Sale No.";Code[20])
        {
            Caption = 'Return Sale No.';
        }
        field(305;"Return Sales Sales Date";Date)
        {
            Caption = 'Return Sales Sales Date';
        }
        field(400;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;

            trigger OnValidate()
            begin
                "Discount %" := 0;
                "Discount Amount"  := 0;
            end;
        }
        field(401;"Discount Code";Code[20])
        {
            Caption = 'Discount Code';

            trigger OnValidate()
            begin
                RetailSetup.Get;
                if RetailSetup."Use Adv. dimensions" then
                  //-NPR5.45 [324395]
                  // CreateDim(
                  //  DATABASE::Register,"Register No.",
                  //  NPRDimMgt.TypeToTableNPR(Type),"No.",
                  //  DATABASE::"Period Discount","Period Discount code",
                  //  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code");
                  CreateDim(
                    DATABASE::Register,"Register No.",
                    NPRDimMgt.TypeToTableNPR(Type),"No.",
                    NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code",
                    0,'');
                  //+NPR5.45 [324395]
            end;
        }
        field(402;"Discount Calculated";Boolean)
        {
            Caption = 'Discount Calculated';
            Description = 'NPR5.40';
        }
        field(405;"Discount Authorised by";Code[20])
        {
            Caption = 'Discount Authorised by';
            Description = 'NPR5.39';
            TableRelation = "Salesperson/Purchaser";
        }
        field(420;"Coupon Qty.";Integer)
        {
            CalcFormula = Count("NpDc Sale Line POS Coupon" WHERE ("Register No."=FIELD("Register No."),
                                                                   "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                   "Sale Type"=FIELD("Sale Type"),
                                                                   "Sale Date"=FIELD(Date),
                                                                   "Sale Line No."=FIELD("Line No."),
                                                                   Type=CONST(Coupon)));
            Caption = 'Coupon Qty.';
            Description = 'NPR5.00 [250375]';
            Editable = false;
            FieldClass = FlowField;
        }
        field(425;"Coupon Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NpDc Sale Line POS Coupon"."Discount Amount" WHERE ("Register No."=FIELD("Register No."),
                                                                                   "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                                   "Sale Type"=FIELD("Sale Type"),
                                                                                   "Sale Date"=FIELD(Date),
                                                                                   "Sale Line No."=FIELD("Line No."),
                                                                                   Type=CONST(Discount)));
            Caption = 'Coupon Discount Amount';
            Description = 'NPR5.00 [250375]';
            Editable = false;
            FieldClass = FlowField;
        }
        field(430;"Coupon Applied";Boolean)
        {
            Caption = 'Coupon Applied';
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
        }
        field(500;"EFT Approved";Boolean)
        {
            Caption = 'Cash Terminal Approved';
        }
        field(505;"Credit Card Tax Free";Boolean)
        {
            Caption = 'Credit Card Tax Free';
            Description = 'Only to be set if Cash Terminal Approved';

            trigger OnValidate()
            begin
                TestField("EFT Approved");
            end;
        }
        field(550;"Drawer Opened";Boolean)
        {
            Caption = 'Drawer Opened';
            Description = 'NPR4.002.005, for indication of opening on drawer.';
        }
        field(600;"VAT Calculation Type";Option)
        {
            Caption = 'VAT Calculation Type';
            Description = 'NPR5.33';
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(801;"Insurance Category";Code[50])
        {
            Caption = 'Insurance Category';
            TableRelation = "Insurance Category";

            trigger OnValidate()
            begin
                if (xRec."Insurance Category" <> '') and ("Insurance Category" <> xRec."Insurance Category") then
                  "Cust Forsikring" := true;
            end;
        }
        field(5002;Color;Code[20])
        {
            Caption = 'Color';
        }
        field(5003;Size;Code[20])
        {
            Caption = 'Size';
        }
        field(5004;Clearing;Option)
        {
            Caption = 'Clearing';
            OptionCaption = ' ,Gift Voucher,Credit Voucher';
            OptionMembers = " ",Gavekort,Tilgodebevis;
        }
        field(5008;"External Document No.";Code[20])
        {
            Caption = 'External Document No.';
        }
        field(5999;"Buffer Ref. No.";Integer)
        {
            Caption = 'Buffer Ref. No.';
        }
        field(6000;"Buffer Document Type";Option)
        {
            Caption = 'Buffer Document Type';
            OptionCaption = ' ,Payment,Invoice,Credit Note,Interest Note,Reminder';
            OptionMembers = " ",Betaling,Faktura,Kreditnota,Rentenota,Rykker;
        }
        field(6001;"Buffer ID";Code[20])
        {
            Caption = 'Buffer ID';
        }
        field(6002;"Buffer Document No.";Code[20])
        {
            Caption = 'Buffer Document No.';
        }
        field(6003;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(6004;Internal;Boolean)
        {
            Caption = 'Internal';
            InitValue = false;
        }
        field(6005;"Currency Amount";Decimal)
        {
            Caption = 'Currency Amount';
        }
        field(6006;Accessory;Boolean)
        {
            Caption = 'Accessory';
            InitValue = false;
        }
        field(6007;"Main Item No.";Code[21])
        {
            Caption = 'Main Item No.';
        }
        field(6008;"Combination Item";Boolean)
        {
            Caption = 'Combination Item';
        }
        field(6009;"Combination No.";Code[20])
        {
            Caption = 'Combination No.';
        }
        field(6010;"From Selection";Boolean)
        {
            Caption = 'From Selection';
            InitValue = false;
        }
        field(6011;"Item Group";Code[10])
        {
            Caption = 'Item Group';
            TableRelation = "Item Group";

            trigger OnValidate()
            begin
                //-NPR5.45 [324395]
                // CreateDim(
                //  DATABASE::Register,"Register No.",
                //  NPRDimMgt.TypeToTableNPR(Type),"No.",
                //  DATABASE::"Period Discount","Period Discount code",
                //  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code");
                CreateDim(
                  DATABASE::Register,"Register No.",
                  NPRDimMgt.TypeToTableNPR(Type),"No.",
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"),"Discount Code",
                  0,'');
                //+NPR5.45 [324395]
            end;
        }
        field(6012;"MR Anvendt antal";Decimal)
        {
            Caption = 'MR Used Amount';
        }
        field(6013;"FP Anvendt";Boolean)
        {
            Caption = 'FP Used';
            InitValue = true;
        }
        field(6014;"Eksp. Salgspris";Boolean)
        {
            Caption = 'Sale POS Salesprice';
            InitValue = false;
        }
        field(6015;"Serial No. not Created";Code[30])
        {
            Caption = 'Serial No. not Created';
        }
        field(6019;"Custom Price";Boolean)
        {
            Caption = 'Custom Price';
        }
        field(6020;NegPriceZero;Boolean)
        {
            Caption = 'NegPriceZero';
        }
        field(6021;Reference;Text[50])
        {
            Caption = 'Reference';
        }
        field(6022;"Rep. Nummer";Code[10])
        {
            Caption = 'Rep. No.';
        }
        field(6023;"Gift Voucher Ref.";Code[20])
        {
            Caption = 'Gift Voucher Ref.';
        }
        field(6024;"Credit voucher ref.";Code[20])
        {
            Caption = 'Credit voucher ref.';
        }
        field(6025;"Custom Cost";Boolean)
        {
            Caption = 'Custom Cost';
        }
        field(6026;"Wish List";Code[10])
        {
            Caption = 'Wish list';
            Description = 'NPR5.38';
        }
        field(6027;"Wish List Line No.";Integer)
        {
            Caption = 'Wish List Line No.';
            Description = 'NPR5.38';
        }
        field(6028;"Item group accessory";Boolean)
        {
            Caption = 'Itemgroup Accessories';
        }
        field(6029;"Accessories Item Group No.";Code[20])
        {
            Caption = 'Accessories Itemgroup No.';
        }
        field(6032;"Label Quantity";Integer)
        {
            Caption = 'Label Quantity';
        }
        field(6033;"Offline Sales Ticket No";Code[20])
        {
            Caption = 'Emergency Ticket No.';
        }
        field(6034;"Custom Descr";Boolean)
        {
            Caption = 'Customer Description';
        }
        field(6036;"Foreign No.";Code[20])
        {
            Caption = 'Foreign No.';
        }
        field(6037;GiftCrtLine;Integer)
        {
            Caption = 'Gift Certificate Line';
        }
        field(6038;"Label Date";Date)
        {
            Caption = 'Label Date';
        }
        field(6039;"Description 2";Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.23';
        }
        field(6043;"Order No. from Web";Code[20])
        {
            Caption = 'Order No. from Web';
        }
        field(6044;"Order Line No. from Web";Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
        }
        field(6050;"Item Category Code";Code[20])
        {
            Caption = 'Item Category Code';
            Description = 'NPR5.00 [250375]';
        }
        field(6051;"Product Group Code";Code[10])
        {
            Caption = 'Product Group Code';
            Description = 'NPR5.000 [250375]';
        }
        field(6055;"Lock Code";Code[10])
        {
            Caption = 'Lock Code';
            Description = 'NPR4.007.016';
        }
        field(6100;"Main Line No.";Integer)
        {
            Caption = 'Main Line No.';
            Description = 'NPR5.40';
        }
        field(7014;"Item Disc. Group";Code[20])
        {
            Caption = 'Item Disc. Group';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Discount Group" WHERE (Code=FIELD("Item Disc. Group"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10000;Silent;Boolean)
        {
            Caption = 'Silent';
        }
        field(10001;Deleting;Boolean)
        {
            Caption = 'Deleting';
        }
        field(10002;NoWarning;Boolean)
        {
            Caption = 'No Warning';
        }
        field(10003;CondFirstRun;Boolean)
        {
            Caption = 'Conditioned First Run';
            InitValue = true;
        }
        field(10004;CurrencySilent;Boolean)
        {
            Caption = 'Currency (Silent)';
        }
        field(10005;StyklisteSilent;Boolean)
        {
            Caption = 'Bill of materials (Silent)';
        }
        field(10006;"Cust Forsikring";Boolean)
        {
            Caption = 'Cust. Insurrance';
        }
        field(10007;Forsikring;Boolean)
        {
            Caption = 'Insurrance';
        }
        field(10008;TestOnServer;Boolean)
        {
            Caption = 'Test on Server';
        }
        field(10009;"Customer No. Line";Boolean)
        {
            Caption = 'Customer No. Line';
        }
        field(10010;ForceApris;Boolean)
        {
            Caption = 'Force A-Price';
        }
        field(10011;GuaranteePrinted;Boolean)
        {
            Caption = 'Guarantee Certificat Printed';
            Description = 'Field set true, if guarantee certificate has been printed';
        }
        field(10012;"Custom Disc Blocked";Boolean)
        {
            Caption = 'Custom Disc Blocked';
        }
        field(10013;"Invoiz Guid";Text[150])
        {
            Caption = 'Invoiz Guid';
        }
        field(6014511;"Label No.";Code[8])
        {
            Caption = 'Label Number';
            Description = 'NPR4.007.025 - Benyttes i forbindelse med Smart Safety forsikring';
        }
        field(6014512;"SQL Server Timestamp";BigInteger)
        {
            Caption = 'Timestamp';
            Description = 'NPR5.22';
            Editable = false;
            SQLTimestamp = true;
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.",Date,"Sale Type","Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT",Cost,"Discount Amount",Amount;
        }
        key(Key2;"Register No.","Sales Ticket No.","Sale Type","Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key3;"Register No.","Sales Ticket No.","Sale Type",Type,"No.","Item Group",Quantity)
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,Quantity;
        }
        key(Key4;"Register No.","Sales Ticket No.","Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key5;"Discount Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount;
        }
        key(Key6;"Register No.","Sales Ticket No.",Date,"Sale Type",Type,"Discount Type","Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key7;"Serial No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key8;"Register No.","Sales Ticket No.","No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
        key(Key9;"Insurance Category","Register No.","Sales Ticket No.",Date,"Sale Type",Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SaleLinePOS: Record "Sale Line POS";
        ErrNoDelete: Label 'Sales lines cannot be deleted when sale is part of a selection';
        ErrNoDeleteDep: Label 'Deposit line from a rental is not to be deleted.';
        GiftVoucher2: Record "Gift Voucher";
        CreditVoucher2: Record "Credit Voucher";
        GiftVoucher3: Record "Gift Voucher";
        ICommRec: Record "I-Comm";
        RetailCode: Codeunit "Retail Table Code";
        Err001: Label '%1 is not legal tender';
        Err002: Label 'A financial account has not been selected for the purchase %1';
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin
        //-NPR5.51 [359385]
        // IF "Cash Terminal Approved" THEN
        //  ERROR(ErrTerm,"No.");
        if "EFT Approved" then
          Error(ERR_EFT_DELETE);
        //+NPR5.51 [359385]

        RetailSetup.Get;
        Deleting := true;

        if RetailSetup."Sales Lines from Selection" and "From Selection" then
          Error(ErrNoDelete);

        if ((Type = Type::Customer) and ("Sale Type" = "Sale Type"::Deposit) and ("From Selection")) then
          Error(ErrNoDeleteDep);

        if (Type = Type::Item) or (Type = Type::"BOM List") then begin
          case "Discount Type" of
            "Discount Type"::"BOM List":
              begin
                SaleLinePOS.Reset;
                SaleLinePOS.SetRange("Register No.","Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
                SaleLinePOS.SetRange("Sale Type","Sale Type");
                SaleLinePOS.SetRange(Date,Date);
                SaleLinePOS.SetRange("Discount Code","Discount Code");
                if SaleLinePOS.FindSet then
                  repeat
                    if SaleLinePOS.Type = Type::"BOM List" then
                      SaleLinePOS.Validate("No.");
                    if "Line No." <> SaleLinePOS."Line No." then
                      SaleLinePOS.Delete;
                  until SaleLinePOS.Next = 0;
              end;
          end;
        end else if Type = Type::"G/L Entry" then begin
          if "Gift Voucher Ref." <> '' then
            if GiftVoucher3.Get("Gift Voucher Ref.") then
              if GiftVoucher3.Status <> GiftVoucher3.Status::Cancelled then begin
                GiftVoucher3.Validate(Status,GiftVoucher3.Status::Cancelled);
                //-NPR5.48 [335967]
                //SalePOS2.GET("Register No.","Sales Ticket No.");
                //GiftVoucher3.VALIDATE("Canceling Salesperson",SalePOS2."Salesperson Code");
                GetPOSHeader;
                GiftVoucher3.Validate("Canceling Salesperson",SalePOS."Salesperson Code");
                //+NPR5.48 [335967]
                GiftVoucher3.Modify(true);
                if RetailSetup."Use I-Comm" then begin
                  ICommRec.Get;
                  if ICommRec."Company - Clearing" <> '' then
                    //-NPR5.48 [335967]
                    //RetailCode.GiftVoucherCommonValidate(SalePOS2,GiftVoucher3."No.",GiftVoucher3.Status::Cancelled);
                    RetailCode.GiftVoucherCommonValidate(SalePOS,GiftVoucher3."No.",GiftVoucher3.Status::Cancelled);
                    //+NPR5.48 [335967]
                end;
              end;
        end else if (Type = Type::Payment) then begin
          //-NPR5.45 [324395]
          // IF RetailSetup.GET THEN
          //  IF RetailSetup."Payment Type By Register" THEN BEGIN
          //    IF NOT PaymentTypePOS.GET("No.","Register No.") THEN
          //      ERROR(Err001,"No.");
          //  END
          // ELSE IF NOT PaymentTypePOS.GET("No.") THEN
          //  ERROR(Err001,"No.");
          GetPaymentTypePOS(PaymentTypePOS);
          //+NPR5.45 [324395]
          if PaymentTypePOS."G/L Account No." <> '' then begin
            case PaymentTypePOS."Processing Type" of
              PaymentTypePOS."Processing Type"::Cash:
                begin
                  if "Discount Type" = "Discount Type"::Rounding then begin
                    SaleLinePOS.Reset;
                    SaleLinePOS.SetRange("Register No.","Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
                    SaleLinePOS.SetRange("Sale Type","Sale Type"::"Out payment");
                    SaleLinePOS.SetRange(Type,Type::"G/L Entry");
                    SaleLinePOS.SetFilter("Line No.","Discount Code");
                    SaleLinePOS.SetRange(Date,Date);
                    SaleLinePOS.DeleteAll;
                  end;
                end;
              PaymentTypePOS."Processing Type"::"Credit Voucher":
                begin
                  if CreditVoucher.Get("Discount Code") then begin
                    CreditVoucher."Cashed on Register No." := '0';
                    CreditVoucher."Cashed on Sales Ticket No." := '';
                    CreditVoucher."Cashed Date" := 0D;
                    CreditVoucher."Cashed Salesperson" := '';
                    CreditVoucher."Cashed in Global Dim 1 Code" := '';
                    CreditVoucher."Cashed in Location Code" := '';
                    CreditVoucher."Cashed External" := false;
                    CreditVoucher.Status := CreditVoucher.Status::Open;
                    CreditVoucher.Modify;
                  end;
                end;
              PaymentTypePOS."Processing Type"::"Gift Voucher":
                begin
                  if GiftVoucher.Get("Discount Code") then begin
                    GiftVoucher."Cashed on Register No." := '0';
                    GiftVoucher."Cashed on Sales Ticket No." := '';
                    GiftVoucher."Cashed Date" := 0D;
                    GiftVoucher."Cashed Salesperson" := '';
                    GiftVoucher."Cashed in Global Dim 1 Code" := '';
                    GiftVoucher."Cashed in Location Code" := '';
                    GiftVoucher."Cashed External" := false;
                    GiftVoucher.Status := GiftVoucher.Status::Open;
                    GiftVoucher.Modify(true);
                  end;
                end;
            end;
          end else begin
            if PaymentTypePOS."Account Type" = PaymentTypePOS."Account Type"::"G/L Account" then
              Error(Err002,"No.");
          end;
        end;

        if "Gift Voucher Ref." <> '' then begin
          GiftVoucher2.Get("Gift Voucher Ref.");
          GiftVoucher2."Sales Ticket No." := '' ;
          GiftVoucher2.Modify;
        end;

        if "Credit voucher ref." <> '' then begin
          CreditVoucher2.Get("Credit voucher ref.");
          CreditVoucher2."Sales Ticket No." := '';
          CreditVoucher2.Modify;
        end;

        if GiftCrtLine <> 0 then begin
          SaleLinePOS.Reset;
          SaleLinePOS.SetRange("Register No.","Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::"Out payment");
          SaleLinePOS.SetRange(Type,SaleLinePOS.Type::"G/L Entry");
          SaleLinePOS.SetRange("Line No.",GiftCrtLine);
          if SaleLinePOS.FindFirst then
            SaleLinePOS.Delete;
        end;

        //-TMx.xx
        TicketRequestManager.OnDeleteSaleLinePos(Rec);
        //+TMx.xx
    end;

    trigger OnInsert()
    begin
        if "Orig. POS Sale ID" = 0 then begin
          //-NPR5.48 [335967]
          //SalePOS.GET("Register No.","Sales Ticket No.");
          GetPOSHeader;
          //+NPR5.48 [335967]
          "Orig. POS Sale ID" := SalePOS."POS Sale ID";
          "Orig. POS Line No." := "Line No.";
        end;

        //-NPR5.40 [294655]
        // IF Item.GET(ItemGlobal."No.") THEN BEGIN
        //  IF Item."Std. Sales Qty." <> 0 THEN
        //    VALIDATE(Quantity, Item."Std. Sales Qty.");
        // END;
        //+NPR5.40 [294655]
    end;

    trigger OnRename()
    var
        ErrBlanc: Label 'Number in the expedition line must not be blank.';
    begin
        if (xRec."No." <> '') and ("No." = '') then
          Error(ErrBlanc);
    end;

    var
        Item: Record Item;
        InventorySetup: Record "Inventory Setup";
        ItemGroup: Record "Item Group";
        PaymentTypePOS: Record "Payment Type POS";
        RetailSetup: Record "Retail Setup";
        RetailContractSetup: Record "Retail Contract Setup";
        GLAcc: Record "G/L Account";
        RegisterGlobal: Record Register;
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";
        CustomerRepair: Record "Customer Repair";
        CustomerGlobal: Record Customer;
        SalePOS: Record "Sale POS";
        Currency: Record Currency;
        DimMgt: Codeunit DimensionManagement;
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        NFRetailCode: Codeunit "NF Retail Code";
        NPRDimMgt: Codeunit NPRDimensionManagement;
        RegisterNo: Code[10];
        CustomerDiscount: Decimal;
        TotalItemLedgerEntryQuantity: Decimal;
        TotalAuditRollQuantity: Decimal;
        PreDefQty: Decimal;
        VariationSelected: Boolean;
        ErrMaxExceeded: Label 'The amount on payment option %1 must not surpass %2';
        ErrMinExceeded: Label 'The amount on payment option %1 must not be below %2';
        SkipCalcDiscount: Boolean;
        ErrVATCalcNotSupportInPOS: Label '%1 %2 not supported in POS';
        Text000: Label 'Only one means of payment type allowed as payment choice on Invoice';
        Text001: Label 'Account is missing on Payment Type %1';
        Text002: Label '%1 %2 is used more than once.';
        Text003: Label 'Adjust the inventory first, and then continue the transaction';
        Text004: Label '%1 %2 is already used.';
        ERR_EFT_DELETE: Label 'Cannot delete externally approved electronic funds transfer. Please attempt refund or void of the original transaction instead.';

    local procedure GetPOSHeader()
    var
        SalePOS2: Record "Sale POS";
    begin
        //-NPR5.48 [335967]
        if SalePOS2.Get("Register No.", "Sales Ticket No.") then
          SalePOS := SalePOS2;

        Currency.InitRoundingPrecision;
        //+NPR5.48 [335967]
    end;

    procedure SetPOSHeader(NewSalePOS: Record "Sale POS")
    begin
        //-NPR5.48 [335967]
        SalePOS := NewSalePOS;

        Currency.InitRoundingPrecision;
        //+NPR5.48 [335967]
    end;

    procedure CalculateCostPrice()
    var
        VATPercent: Decimal;
    begin
        //-NPR5.48 [335967]
        //Item.GET("No.");
        GetItem;
        //+NPR5.48 [335967]

        if "Price Includes VAT" then
          VATPercent := "VAT %"
        else
          VATPercent := 0;

        //-NPR5.48 [335967]
        //IF (Item."Group sale") AND (Item."Profit %" <> 0) THEN
        //  "Unit Cost" := (1 - Item."Profit %" / 100) * "Unit Price" / ( 1 + VATPercent/100)
        //ELSE
        //  "Unit Cost" := Item."Unit Cost";

        //Cost := Quantity * "Unit Cost";
        ////-NPR5.45 [324395]
        ////"Unit Price (LCY)" := "Unit Cost";
        //"Unit Cost (LCY)" := "Unit Cost";
        ////+NPR5.45 [324395]

        if (Item."Group sale") and (Item."Profit %" <> 0) then
          Validate("Unit Cost (LCY)", ((1 - Item."Profit %" / 100) * "Unit Price" / ( 1 + VATPercent/100)) * "Qty. per Unit of Measure")
        else
          Validate("Unit Cost (LCY)", Item."Unit Cost" * "Qty. per Unit of Measure");
        //+NPR5.48 [335967]
    end;

    procedure EuroExchRate(): Decimal
    var
        PaymentTypePOS2: Record "Payment Type POS";
    begin
        //EuroExchRate()
        PaymentTypePOS2.SetRange(Euro,true);
        //-NPR5.38 [294640]
        //IF PaymentTypePOS2.FIND('-') THEN
        if PaymentTypePOS2.FindFirst then
        //+NPR5.38 [294640]
          exit(PaymentTypePOS2."Fixed Rate" / 100)
        else
          exit(0.01);
    end;

    procedure RemoveBOMDiscount()
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        if ("Discount Type" = "Discount Type"::"BOM List") then begin
          SaleLinePOS.SetRange("Register No.","Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS.SetRange("Sale Type","Sale Type");
          SaleLinePOS.SetRange(Date,Date);
          SaleLinePOS.SetRange("Discount Code","Discount Code");
          SaleLinePOS.SetFilter("No.",'<>%1',"No.");
          if SaleLinePOS.FindSet(true,false) then
            repeat
              if SaleLinePOS.Type = Type::"BOM List" then
                SaleLinePOS.Delete
              else begin
                SaleLinePOS."Discount Type" := "Discount Type"::" ";
                SaleLinePOS."Discount Code" := '';
                SaleLinePOS."Discount %" := 0;
                SaleLinePOS."Discount Amount" := 0;
                SaleLinePOS."Amount Including VAT" := 0;
                SaleLinePOS.Validate("No.");
                SaleLinePOS.Modify;
              end;
            until SaleLinePOS.Next = 0 ;
        end;
    end;

    procedure FindItemSalesPrice(): Decimal
    var
        TempSaleLinePOS: Record "Sale Line POS" temporary;
        POSSalesPriceCalcMgt: Codeunit "POS Sales Price Calc. Mgt.";
    begin
        //FindItemSalesPrice
        //-NPR5.48 [334922]
        if "Manual Item Sales Price" then
          exit("Unit Price");
        //+NPR5.48 [334922]
        //-NPR5.45 [323705]
        //EXIT(NFRetailCode.TR406FindItemSalesPrice(SaleLinePOS));
        //-NPR5.48 [335967]
        //IF (SalePOS."Register No." <> "Register No.") OR (SalePOS."Sales Ticket No." <> "Sales Ticket No.") THEN
        //  SalePOS.GET("Register No.","Sales Ticket No.");
        GetPOSHeader;
        //+NPR5.48 [335967]
        TempSaleLinePOS := Rec;
        TempSaleLinePOS."Currency Code" := '';
        POSSalesPriceCalcMgt.FindItemPrice(SalePOS,TempSaleLinePOS);
        exit(TempSaleLinePOS."Unit Price");
        //+NPR5.45 [323705]
    end;

    procedure FindItemCostPrice(var Item: Record Item): Decimal
    begin
        exit(NFRetailCode.TR406FindItemCostPrice(Rec,Item,'',''));
    end;

    procedure GetVATPct(ItemGroupCode: Code[10]): Decimal
    begin
        UpdateVATSetup;
        exit("VAT %");   //For backwards compatibilty
    end;

    procedure GetAmount(var SaleLinePOS: Record "Sale Line POS";var Item: Record Item;UnitPrice: Decimal)
    begin
        SaleLinePOS."Unit Price" := UnitPrice;
        UpdateAmounts(SaleLinePOS);
    end;

    procedure InsertCashRoundingAmount(var RoundingAmount: Decimal;GLAccount: Record "G/L Account")
    var
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
    begin
        SaleLinePOS.SetRange("Register No.","Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
        SaleLinePOS.SetRange(Date,Date);

        if SaleLinePOS.FindLast then
          LineNo := SaleLinePOS."Line No." + 10000
        else
          LineNo := 10000;

        SaleLinePOS.Init;
        SaleLinePOS."Register No." := "Register No.";
        SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
        SaleLinePOS.Date := Date;
        SaleLinePOS."Sale Type" := "Sale Type"::"Out payment";
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS.Type := Type::"G/L Entry";
        SaleLinePOS.Validate("No.",GLAccount."No.");
        SaleLinePOS."Location Code" := "Location Code";
        SaleLinePOS.Description := GLAccount.Name;
        SaleLinePOS.Quantity := 1;
        SaleLinePOS."Unit Price" := -1 * RoundingAmount;
        SaleLinePOS."Amount Including VAT" := -1 * RoundingAmount;
        SaleLinePOS."Shortcut Dimension 1 Code" := RegisterGlobal."Global Dimension 1 Code";
        SaleLinePOS."Shortcut Dimension 2 Code" := RegisterGlobal."Global Dimension 2 Code";
        SaleLinePOS."Discount Type" := "Discount Type"::Rounding;
        SaleLinePOS.Insert(true);

        "Discount Type" := "Discount Type"::Rounding;
        "Discount Code" := StrSubstNo('%1',LineNo);
    end;

    procedure TransferToSalesLine(var SalesLine: Record "Sales Line"): Boolean
    var
        RetailCode: Codeunit "NF Retail Code";
        Txt001: Label 'Deposit';
    begin
        //TransferToSalesLine

        //-NPR5.40 [306257]
        //SalesLine.Description := Description;
        //+NPR5.40 [306257]

        if "No." = '*' then begin
          SalesLine."No." := '';
          //-NPR5.40 [306257]
          SalesLine.Description := Description;
          //+NPR5.40 [306257]
          exit;
        end;

        if (Type = Type::Customer) and ("Sale Type" = "Sale Type"::Deposit) then begin
          SalesLine."No." := '';
          SalesLine.Description := Txt001 + ' ' + Format(Abs("Amount Including VAT"));
          exit;
        end;

        SalesLine.Validate("No.","No.");
        SalesLine."Location Code" := "Location Code";
        SalesLine."Posting Group" := "Posting Group";
        SalesLine.Validate("Unit of Measure Code","Unit of Measure Code");
        SalesLine.Validate(Quantity,Quantity);
        SalesLine.Description := Description;
        SalesLine."Unit Price" := "Unit Price";

        SalesLine."VAT %" := "VAT %";
        SalesLine."Line Discount %" := "Discount %";
        SalesLine."Line Discount Amount" := "Discount Amount";
        SalesLine.Amount := Amount;
        SalesLine."Amount Including VAT" := "Amount Including VAT";
        SalesLine."Allow Invoice Disc." := "Allow Invoice Discount";
        SalesLine."Customer Price Group" := "Customer Price Group";
        RetailCode.TS37SerieNoCopy(SalesLine,Rec);
        if CustomerGlobal."Bill-to Customer No." <> '' then
          SalesLine."Bill-to Customer No." := CustomerGlobal."Bill-to Customer No."
        else
          SalesLine."Bill-to Customer No." := SalesLine."Sell-to Customer No.";

        SalesLine."Inv. Discount Amount" := "Invoice Discount Amount";
        SalesLine."Currency Code" := "Currency Code";
        SalesLine."Outstanding Amount (LCY)" := "Claim (LCY)";
        SalesLine."VAT Base Amount" := "VAT Base Amount";
        SalesLine."Special Price" := "Special price";
        SalesLine."Unit Cost" := "Unit Cost";
        SalesLine."Discount Type" := "Discount Type";
        SalesLine."Discount Code" := "Discount Code";
        SalesLine."VAT Calculation Type" := "VAT Calculation Type";
        SalesLine.Internal := Internal;
        SalesLine."Serial No. not Created" := "Serial No. not Created";
        //-NPR5.45 [324395]
        //SalesLine."Unit Price (LCY)" := "Unit Cost (LCY)";
        SalesLine."Unit Cost (LCY)" := "Unit Cost (LCY)";
        //+NPR5.45 [324395]
        SalesLine.Validate("Variant Code","Variant Code");
        //-NPR5.40 [306257]
        SalesLine.Description := Description;
        SalesLine."Description 2" := "Description 2";
        //+NPR5.40 [306257]
    end;

    procedure PrintWarrantyCertificate(var SaleLinePOS: Record "Sale Line POS";FormatedDate: Text[250];IsTouch: Boolean) Succes: Boolean
    var
        RetailSetup2: Record "Retail Setup";
        ReportSelectionRetail: Record "Report Selection Retail";
        Txt002: Label 'What date is the return garantie valid from?';
        Register: Record Register;
        DateTable: Record Date;
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        Date1: Date;
        RequestDate: Boolean;
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
    begin
        //PrintWarrantyCertificate
        RetailSetup2.Get;
        Register.Get(SaleLinePOS."Register No.");
        case Register."Sales Ticket Print Output" of
          Register."Sales Ticket Print Output"::NEVER,
          Register."Sales Ticket Print Output"::DEVELOPMENT,
          Register."Sales Ticket Print Output"::CUSTOMER :
            exit;
        end;

        SaleLinePOS.SetRecFilter;

        RequestDate := true;

        if (RetailSetup2."Skip Warranty Voucher Dialog" <> '') and (FormatedDate = 'AUTO') then begin
          DateTable.SetFilter("Period Start",RetailSetup2."Skip Warranty Voucher Dialog");
          if (Today >= DateTable.GetRangeMin("Period Start")) and
             (Today <= DateTable.GetRangeMin("Period Start")) then begin
             RequestDate := false;
             FormatedDate := Format(RetailSetup2."Warranty Standard Date");
             RequestDate := false;
          end else
            FormatedDate := Format(Today);
        end;

        Date1 := Today;
        if RequestDate then
          if not POSEventMarshaller.NumPadDate(Txt002,Date1,false,false) then
            exit(false);

        SaleLinePOS.Validate("Label Date",Date1);
        SaleLinePOS.Modify;

        RecRef.GetTable(SaleLinePOS);
        RetailReportSelectionMgt.SetRegisterNo("Register No.");
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Warranty Certificate");
    end;

    procedure CheckSerialNoApplication(ItemNo: Code[20];SerialNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //-NPR5.48 [335967]
        //NFRetailCode.TR406CheckSerialNoApplication(Rec,TotalAmountILE,ItemNo,SerialNo);
        ItemLedgerEntry.SetCurrentKey(Open,Positive,"Item No.","Serial No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        if ItemLedgerEntry.FindFirst then begin
          ItemLedgerEntry.CalcSums(Quantity);
          TotalItemLedgerEntryQuantity := ItemLedgerEntry.Quantity;
          if ItemLedgerEntry.Count > 1 then
            Error(Text002 + Text003, FieldName("Serial No."), "Serial No.");
        end;
        //+NPR5.48 [335967]
    end;

    procedure CheckSerialNoAuditRoll(ItemNo: Code[20];SerialNo: Code[20];Positive: Boolean)
    var
        AuditRoll: Record "Audit Roll";
        Err001: Label '%2 %1 is already in stock but has not been posted yet';
        Err002: Label '%2 %1 has already been sold to a customer but is not yet posted';
    begin
        if Positive then begin
          AuditRoll.SetCurrentKey(Posted,"Serial No.");
          AuditRoll.SetRange(Posted,false);
          AuditRoll.SetRange("Serial No.","Serial No.");
          if AuditRoll.FindFirst then
            AuditRoll.CalcSums(Quantity);
          TotalAuditRollQuantity := AuditRoll.Quantity;
          if AuditRoll.Quantity = -1 then
            Error(Err001,"Serial No.",FieldName("Serial No."));
        end else begin
          AuditRoll.SetCurrentKey(Posted,"Serial No.");
          AuditRoll.SetRange(Posted,false);
          AuditRoll.SetRange("Serial No.","Serial No.");
          if AuditRoll.FindFirst then
            AuditRoll.CalcSums(Quantity);
          TotalAuditRollQuantity := AuditRoll.Quantity;
          if AuditRoll.Quantity = 1 then
            Error(Err002,"Serial No.",FieldName("Serial No."));
        end;
    end;

    procedure TransferToService()
    var
        ServiceItem: Record "Service Item";
    begin
        //-NPR5.48 [335967]
        //SalePOS3.GET("Register No.","Sales Ticket No.");
        GetPOSHeader;
        //+NPR5.48 [335967]
        ServiceItem.Init;
        ServiceItem.Insert(true);
        ServiceItem.Validate("Item No.","No.");
        ServiceItem.Validate("Serial No.","Serial No.");
        ServiceItem.Validate(Status,ServiceItem.Status::Installed);
        ServiceItem.Validate("Warranty Starting Date (Labor)",SalePOS.Date); //-NPR5.48 [335967] Changed SalePos3 to SalePos
        ServiceItem.Validate("Warranty Ending Date (Labor)",CalcDate('<+1Y>',SalePOS.Date)); //-NPR5.48 [335967] Changed SalePos3 to SalePos
        ServiceItem.Validate("Customer No.",SalePOS."Customer No."); //-NPR5.48 [335967] Changed SalePos3 to SalePos
        ServiceItem.Validate("Unit of Measure Code","Unit of Measure Code");
        ServiceItem.Validate("Sales Date",SalePOS.Date);//-NPR5.48 [335967] Changed SalePos3 to SalePos
        ServiceItem.Modify;
    end;

    procedure ExplodeBOM(ItemNo: Code[20];StartLineNo: Integer;EndLineNo: Integer;var Level: Integer;UnitPrice: Decimal;"Sum": Decimal)
    var
        BOMComponent: Record "BOM Component";
        SaleLinePOS: Record "Sale Line POS";
        Item2: Record Item;
        FromLineNo: Integer;
        ToLineNo: Integer;
    begin
        if Sum = 0 then begin               //* Sker kun f�rste gang *
          if Quantity = 0
            then Quantity := 1;                //* Rettelse af fejl i antal under udpakning af stykliste *
          StartLineNo := Rec."Line No.";
          SaleLinePOS.Reset;
          SaleLinePOS.SetRange("Register No.","Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS.SetFilter("Sale Type",'%1|%2|%3',"Sale Type"::Sale,"Sale Type"::Deposit,
                          "Sale Type"::"Out payment");
          SaleLinePOS.SetRange(Date,Date);
          SaleLinePOS.SetRange("Line No.",StartLineNo + 1,StartLineNo + 10000);
          if SaleLinePOS.FindFirst then
            EndLineNo := SaleLinePOS."Line No."
          else
            EndLineNo := StartLineNo + 10000;

          //-NPR5.48 [335967]
          //IF Item.GET(ItemNo) THEN
          //  UnitPrice := Item."Unit Price";
            if Item2.Get(ItemNo) then
            UnitPrice := Item2."Unit Price";
          //+NPR5.48 [335967]

        end;

        BOMComponent.SetRange("Parent Item No.",ItemNo);
        if BOMComponent.FindSet then begin
          Sum := 0;
          repeat
            if BOMComponent."Assembly BOM" then begin
              ExplodeBOM(BOMComponent."No.",StartLineNo,EndLineNo,Level,UnitPrice,Sum);
            end else begin
              Level += 1;
              SaleLinePOS.Init;
              SaleLinePOS."Register No." := "Register No.";
              SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
              SaleLinePOS."Sale Type" := "Sale Type";
              SaleLinePOS.Date := Rec.Date;
              SaleLinePOS."Line No." := Round(EndLineNo - (EndLineNo - StartLineNo) / (2 * Level),1);
              if not SaleLinePOS.Insert(true) then
                SaleLinePOS.Modify(true);
              SaleLinePOS."No." := BOMComponent."No.";
              SaleLinePOS.Silent := true;
              SaleLinePOS.Validate("No.");
              SaleLinePOS.Quantity := BOMComponent."Quantity per" * Rec.Quantity;
              SaleLinePOS.Validate(Quantity);
              Sum += SaleLinePOS."Unit Price" * SaleLinePOS.Quantity;
              SaleLinePOS.Silent := false;
              if not SaleLinePOS.Modify(true) then
                SaleLinePOS.Insert(true);
              if FromLineNo = 0 then
                FromLineNo := SaleLinePOS."Line No.";

              ToLineNo := SaleLinePOS."Line No.";
            end;
          until BOMComponent.Next = 0;

          if (UnitPrice <> 0) and (Sum <> 0) then begin
            SaleLinePOS.Reset;
            SaleLinePOS.SetRange("Register No.","Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
            SaleLinePOS.SetRange("Line No.",FromLineNo,ToLineNo);
            if SaleLinePOS.FindSet(true,false) then
              repeat
                SaleLinePOS."Discount Code" := "Discount Code";
                SaleLinePOS.Validate("Discount %",100 - UnitPrice / Sum * 100);
                SaleLinePOS.Modify(true);
              until SaleLinePOS.Next = 0;
            SaleLinePOS.ModifyAll("Discount Type", SaleLinePOS."Discount Type"::"BOM List");
          end;
        end;
    end;

    procedure GetSkipCalcDiscount(): Boolean
    begin
        //-NPR5.31 [262904]
        exit(SkipCalcDiscount);
        //+NPR5.31 [262904]
    end;

    procedure SetSkipCalcDiscount(NewSkipCalcDiscount: Boolean)
    begin
        //-NPR5.31 [262904]
        SkipCalcDiscount := NewSkipCalcDiscount;
        //+NPR5.31 [262904]
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID",StrSubstNo('%1 %2 %3',"Register No.","Sales Ticket No.","Line No."));
        // Investigate
        // VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
    end;

    procedure CreateDim(Type1: Integer;No1: Code[20];Type2: Integer;No2: Code[20];Type3: Integer;No3: Code[20];Type4: Integer;No4: Code[20])
    var
        RetailConfiguration: Record "Retail Setup";
        TableID: array [10] of Integer;
        No: array [10] of Code[20];
    begin
        RetailConfiguration.Get;
        //-NPR5.29 [257938]
        //-NPR5.48 [335967]
        //SalePOS.GET("Register No.","Sales Ticket No.");
        GetPOSHeader;
        //+NPR5.48 [335967]

        //+NPR5.29 [257938]
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';

        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            TableID,No,RetailConfiguration."Posting Source Code",
            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code",
            //-NPR5.29 [257938]
            //SalePOS."Dimension Set ID",DATABASE::"Sale Line POS");
            SalePOS."Dimension Set ID",DATABASE::Customer);
            //+NPR5.29 [257938]
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber,ShortcutDimCode,"Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber,ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array [8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID",ShortcutDimCode);
    end;

    procedure UpdateVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSTaxCalculation: Codeunit "POS Tax Calculation";
        Handled: Boolean;
    begin
        if (Type = Type::"G/L Entry") and ("Gen. Posting Type" = "Gen. Posting Type"::" ") then begin
          "VAT %" := 0;
          "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
        end else begin
          VATPostingSetup.Get("VAT Bus. Posting Group","VAT Prod. Posting Group");
          //-NPR5.51 [358985]
          POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup,Handled);
          //+NPR5.51 [358985]
          //-NPR5.41 [311309]
          "VAT Identifier" := VATPostingSetup."VAT Identifier";
          //+NPR5.41 [311309]
          "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";

          case "VAT Calculation Type" of
            "VAT Calculation Type"::"Normal VAT":
              "VAT %" := VATPostingSetup."VAT %";
            "VAT Calculation Type"::"Sales Tax":
              "VAT %" := 0;
            "VAT Calculation Type"::"Reverse Charge VAT":
              if (Type = Type::"G/L Entry") and ("Gen. Posting Type" = "Gen. Posting Type"::Purchase) then
                "VAT %" := VATPostingSetup."VAT %"
              else
                "VAT %" := 0;
            else
              Error(ErrVATCalcNotSupportInPOS,FieldCaption("VAT Calculation Type"),"VAT Calculation Type");
          end;

        end;
    end;

    procedure UpdateAmounts(var SaleLinePOS: Record "Sale Line POS")
    var
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        SaleLinePOS2: Record "Sale Line POS";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalQuantityBase: Decimal;
    begin

        //-NPR5.31 [248534]
        with SaleLinePOS do begin
          //-NPR5.48 [335967]
          SaleLinePOS2.SetRange("Register No.", "Register No.");
          SaleLinePOS2.SetRange("Sales Ticket No.", "Sales Ticket No.");
          SaleLinePOS2.SetRange(Date, Date);
          SaleLinePOS2.SetRange("Sale Type", "Sale Type");
          SaleLinePOS2.SetFilter("Line No.", '<>%1', "Line No.");
          if (Quantity * "Unit Price") > 0 then
            SaleLinePOS2.SetFilter(Amount, '>%1', 0)
          else
            SaleLinePOS2.SetFilter(Amount, '<%1', 0);
          SaleLinePOS2.SetRange("VAT Identifier", "VAT Identifier");
          SaleLinePOS2.SetRange("Tax Group Code", "Tax Group Code");

          //-NPR5.48 [338181]
          //"Line Amount" := ROUND(Quantity * "Unit Price", Currency."Amount Rounding Precision") - "Discount Amount";
          //+NPR5.48 [338181]:= ROUND(Quantity * "Unit Price", Currency."Amount Rounding Precision") - "Discount Amount";

          TotalLineAmount := 0;
          TotalInvDiscAmount := 0;
          TotalAmount := 0;
          TotalAmountInclVAT := 0;
          TotalQuantityBase := 0;

          if ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") or
             (("VAT Calculation Type" in
               ["VAT Calculation Type"::"Normal VAT","VAT Calculation Type"::"Reverse Charge VAT"]) and ("VAT %" <> 0))
          then
            if not SaleLinePOS2.IsEmpty then begin
              SaleLinePOS2.CalcSums("Line Amount","Invoice Discount Amount",Amount,"Amount Including VAT","Quantity (Base)");
              TotalLineAmount := SaleLinePOS2."Line Amount";
              TotalInvDiscAmount := SaleLinePOS2."Invoice Discount Amount";
              TotalAmount := SaleLinePOS2.Amount;
              TotalAmountInclVAT := SaleLinePOS2."Amount Including VAT";
              TotalQuantityBase := SaleLinePOS2."Quantity (Base)";
            end;

          //+NPR5.48 [335967]

          if "Price Includes VAT" then begin
            "Amount Including VAT" := Quantity * "Unit Price";
            if "Discount %" <> 0 then
              "Discount Amount" := Round("Amount Including VAT" * "Discount %"/100)
            else
              if "Discount Amount" <> 0 then
                "Discount %" := Round(100-("Amount Including VAT" - "Discount Amount")/"Amount Including VAT"*100,0.0001);
            "Amount Including VAT" := "Amount Including VAT" - "Discount Amount";

            //-NPR5.48 [338181]
            "Line Amount" := Round(Quantity * "Unit Price", Currency."Amount Rounding Precision") - "Discount Amount";
            //+NPR5.48 [338181]

            case "VAT Calculation Type" of
              "VAT Calculation Type"::"Reverse Charge VAT",
              "VAT Calculation Type"::"Normal VAT":
                begin
                  //-NPR5.48 [335967]
                  //Amount := ROUND("Amount Including VAT"/(1 + "VAT %"/100));
                  Amount:= Round((TotalLineAmount -TotalInvDiscAmount + "Line Amount" - "Invoice Discount Amount") / (1 + "VAT %" / 100),
                                   Currency."Amount Rounding Precision") - TotalAmount;
                  //+NPR5.48 [335967]
                  "Amount Including VAT" := Round("Amount Including VAT");

                  //-NPR5.51 [365487]
                  if ("Amount Including VAT" = 0) then
                    Amount := 0;
                  //+NPR5.51 [365487]

                  "VAT Base Amount" := Amount;
                end;
              "VAT Calculation Type"::"Sales Tax":
                begin
                  //-NPR5.34 [284658]
                  //Amount := SalesTaxCalculate.ReverseCalculateTax(
                  //-NPR5.40 [303616]
                  TestField("Tax Area Code");
                  //+NPR5.40 [303616]
                  //-NPR5.41 [311309]
                  //Amount := SalesTaxCalculate.CalculateTax(
                  Amount := SalesTaxCalculate.ReverseCalculateTax(
                  //+NPR5.41 [311309]
                  //+NPR5.34
                    "Tax Area Code","Tax Group Code","Tax Liable",Rec.Date,
                  //-NPR5.41 [311309]
                  //  "Amount Including VAT",Quantity,0);
                    "Amount Including VAT","Quantity (Base)",0);
                  //-NPR5.41 [311309]
                  if Amount <> 0 then
                    "VAT %" := Round(100 * ("Amount Including VAT" - Amount) / Amount,0.00001)
                  else
                    "VAT %" := 0;
                  "Amount Including VAT" := Round("Amount Including VAT");
                  Amount := Round(Amount);
                  "VAT Base Amount" := Amount;
                end;
              else
                Error(ErrVATCalcNotSupportInPOS,FieldCaption("VAT Calculation Type"),"VAT Calculation Type");
            end;
          end else begin
            Amount := Quantity * "Unit Price";
            if "Discount %" <> 0 then
              "Discount Amount" := Round(Amount * "Discount %"/100)
            else
              if "Discount Amount" <> 0 then
                "Discount %" := Round(100-(Amount - "Discount Amount")/Amount*100,0.0001);
            Amount := Amount - "Discount Amount";

            //-NPR5.48 [338181]
            "Line Amount" := Round(Quantity * "Unit Price", Currency."Amount Rounding Precision") - "Discount Amount";
            //+NPR5.48 [338181]

            case "VAT Calculation Type" of
              "VAT Calculation Type"::"Reverse Charge VAT",
              "VAT Calculation Type"::"Normal VAT":
                begin
                  //-NPR5.48 [335967]
                  //"Amount Including VAT" := ROUND(Amount * (1 + "VAT %"/100));
                  //Amount := ROUND(Amount);
                  //"VAT Base Amount" := Amount;
                  Amount := Round("Line Amount" - "Invoice Discount Amount",Currency."Amount Rounding Precision");
                  "VAT Base Amount" := Amount;
                  "Amount Including VAT" :=
                    TotalAmount + Amount +
                    Round(
                      (TotalAmount + Amount) * "VAT %" / 100,
                      Currency."Amount Rounding Precision",Currency.VATRoundingDirection) -
                    TotalAmountInclVAT;
                  //+NPR5.48 [335967]

                  //-NPR5.51 [365487]
                  if (Amount  = 0) then
                    "Amount Including VAT" := 0;
                  //+NPR5.51 [365487]

                end;
              "VAT Calculation Type"::"Sales Tax":
                begin
                  Amount := Round(Amount);
                  "VAT Base Amount" := Amount;
                  //-NPR5.34 [284658]
                  //"Amount Including VAT" := Amount + ROUND(SalesTaxCalculate.ReverseCalculateTax(
                  "Amount Including VAT" := Amount + Round(SalesTaxCalculate.CalculateTax(
                  //+NPR5.34
                    "Tax Area Code","Tax Group Code","Tax Liable",Rec.Date,
                  //-NPR5.41 [311309]
                    //Amount,Quantity,0));
                    Amount,"Quantity (Base)",0));
                  //+NPR5.41 [311309]
                  if "VAT Base Amount" <> 0 then
                    "VAT %" := Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount",0.00001)
                  else
                    "VAT %" := 0;
                end;
              else
                Error(ErrVATCalcNotSupportInPOS,FieldCaption("VAT Calculation Type"),"VAT Calculation Type");
            end;
          end;
          //-NPR5.32.01 [248534]
          "Discount %" := Abs("Discount %");

          //-NPR5.45 [323615] Discount Amount needs to be same sign as quantity field, this value propagates in posting to value entry.
          //"Discount Amount" := ABS("Discount Amount");
          //+NPR5.45 [323615]

          //+NPR5.32.01 [248534]
        end;
        //+NPR5.31 [248534]
    end;

    local procedure InitFromSalePOS()
    begin
        //-NPR5.45 [324395]
        //-NPR5.48 [335967]
        //SalePOS.GET("Register No.","Sales Ticket No.");
        GetPOSHeader;
        //+NPR5.48 [335967]

        "Allow Line Discount" := SalePOS."Allow Line Discount";
        "Location Code" := SalePOS."Location Code";
        "Price Includes VAT" := SalePOS."Prices Including VAT";
        "Customer Price Group" := SalePOS."Customer Price Group";
        "Gen. Bus. Posting Group" := SalePOS."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
        "Tax Area Code" := SalePOS."Tax Area Code";
        "Tax Liable" := SalePOS."Tax Liable";
        //+NPR5.45 [324395]
    end;

    local procedure InitFromCustomer()
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
    begin
        //-NPR5.45 [324395]
        if "No." = '' then
          exit;

        Customer.Get("No.");
        Customer.TestField("Customer Posting Group");
        if Customer."Currency Code" <> '' then begin
          GLSetup.Get;
          Customer.TestField("Currency Code",GLSetup."LCY Code");
        end;

        Description := CopyStr(Customer.Name,1,MaxStrLen(Description));
        Validate("Currency Code",Customer."Currency Code");
        //+NPR5.45 [324395]
    end;

    local procedure InitFromGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        if "No." = '' then
          exit;

        //*-NPR5.45 [324395]
        GLAccount.Get("No.");
        GLAccount.CheckGLAcc;
        Description := GLAccount.Name;
        "Gen. Posting Type" := GLAccount."Gen. Posting Type";
        "Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group"  := GLAccount."VAT Prod. Posting Group";
        "Tax Group Code" := GLAccount."Tax Group Code";
        //+NPR5.45 [324395]
    end;

    local procedure InitFromItem()
    var
        DescriptionControl: Codeunit "Description Control";
    begin
        //-NPR5.45 [324395]
        if "No." = '' then
          exit;

        TestItem();

        //-NPR5.48 [335967]
        //Item.GET("No.");
        GetItem;
        //+NPR5.48 [335967]
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Item Category Code" := Item."Item Category Code";
        //-NPR5.48 [340615]
        //"Product Group Code" := Item."Product Group Code";
        //+NPR5.48 [340615]
        "Tax Group Code" := Item."Tax Group Code";
        "Posting Group" := Item."Inventory Posting Group";
        "Item Group" := Item."Item Group";
        "Item Disc. Group" := Item."Item Disc. Group";
        "Vendor No." := Item."Vendor No.";
        "Custom Disc Blocked" := Item."Custom Discount Blocked";
        if "Unit of Measure Code" = '' then
          "Unit of Measure Code" := Item."Base Unit of Measure";
        if not "Cust Forsikring" then
          "Insurance Category" := Item."Insurrance category";

        DescriptionControl.GetDescriptionPOS(Rec,xRec,Item);
        //+NPR5.45 [324395]
    end;

    local procedure InitFromItemGroup()
    var
        ItemGroup: Record "Item Group";
    begin
        //-NPR5.45 [324395]
        if "No." = '' then
          exit;

        ItemGroup.Get("No.");
        //-NPR5.48 [335967]
        //Item.GET(ItemGroup."No.");
        GetItem;
        //+NPR5.48 [335967]

        Item.TestField("Group sale");

        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        "Item Disc. Group" := Item."Item Disc. Group";
        Description := CopyStr(ItemGroup.Description,1,MaxStrLen(Description));
        //+NPR5.45 [324395]
    end;

    local procedure InitFromPaymentTypePOS()
    var
        PaymentTypePOS: Record "Payment Type POS";
        GLAccount: Record "G/L Account";
    begin
        //-NPR5.45 [324395]
        if "No." = '' then
          exit;

        TestPaymentTypePOS();

        GetPaymentTypePOS(PaymentTypePOS);
        Description := PaymentTypePOS."Sales Line Text";
        //+NPR5.45 [324395]

        //-NPR5.50 [354832]
        //IF (PaymentTypePOS."Reverse Unrealized VAT") THEN begin
        if (PaymentTypePOS."Reverse Unrealized VAT") then begin
          if (PaymentTypePOS."Account Type" = PaymentTypePOS."Account Type"::"G/L Account") then begin

            GLAccount.Get (PaymentTypePOS."G/L Account No.");
            GLAccount.CheckGLAcc ();

            "Gen. Posting Type" := GLAccount."Gen. Posting Type";
            "Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
            "VAT Prod. Posting Group"  := GLAccount."VAT Prod. Posting Group";
            "Tax Group Code" := GLAccount."Tax Group Code";
            UpdateVATSetup();
          end;
        end;
        //+NPR5.50 [354832]
    end;

    procedure GetPaymentTypePOS(var PaymentTypePOS: Record "Payment Type POS"): Boolean
    var
        RegisterNo: Code[10];
    begin
        //-NPR5.45 [324395]
        Clear(PaymentTypePOS);

        RegisterNo := '';
        RetailSetup.Get;
        if RetailSetup."Payment Type By Register" then
          RegisterNo := "Register No.";

        PaymentTypePOS.Get("No.",RegisterNo);
        //+NPR5.45 [324395]
    end;

    local procedure TestItem()
    var
        ItemVariant: Record "Item Variant";
    begin
        //-NPR5.45 [324395]
        if "No." = '' then
          exit;

        //-NPR5.48 [335967]
        //-NPR5.51 [359293]
        Item.Get("No.");
        //-NPR5.51 [359293]
        //+NPR5.48 [335967]

        Item.TestField(Blocked,false);
        Item.TestField("Blocked on Pos",false);
        Item.TestField("Gen. Prod. Posting Group");
        if Item.Type <> Item.Type::Service then
          Item.TestField("Inventory Posting Group");
        if Item."Price Includes VAT" then
        Item.TestField(Item."VAT Bus. Posting Gr. (Price)");
        if "Variant Code" <> '' then begin
          ItemVariant.Get(Item."No.","Variant Code");
          ItemVariant.TestField(Blocked,false);
        end;
        //+NPR5.45 [324395]
    end;

    local procedure TestPaymentTypePOS()
    var
        Register: Record Register;
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.45 [324395]
        GetPaymentTypePOS(PaymentTypePOS);
        Register.Get("Register No.");

        if (PaymentTypePOS."G/L Account No." = '') and (PaymentTypePOS."Customer No." = '') and (PaymentTypePOS."Bank Acc. No." = '') then
          Error(Text001,"No.");
        PaymentTypePOS.TestField(Status,PaymentTypePOS.Status::Active);
        if PaymentTypePOS."Global Dimension 1 Code" <> '' then
          PaymentTypePOS.TestField("Global Dimension 1 Code",Register."Global Dimension 1 Code");

        if PaymentTypePOS."Processing Type" <> PaymentTypePOS."Processing Type"::Invoice then
          exit;

        //-NPR5.48 [335967]
        //SalePOS.GET("Register No.","Sales Ticket No.");
        GetPOSHeader;
        //+NPR5.48 [335967]

        SalePOS.TestField("Customer No.");

        SaleLinePOS.SetRange("Register No.","Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
        SaleLinePOS.SetRange(Type,Type::Payment);
        SaleLinePOS.SetFilter("Line No.",'<>%1',"Line No.");
        SaleLinePOS.SetFilter("No.",'<>%1','');
        if SaleLinePOS.FindSet then
          repeat
            SaleLinePOS.GetPaymentTypePOS(PaymentTypePOS);
            if PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::Invoice then
              Error(Text000);
          until SaleLinePOS.Next = 0;
        //+NPR5.45 [324395]
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        //-NPR5.48 [335967]
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure",0.00001));
        //+NPR5.48 [335967]
    end;

    local procedure GetItem()
    begin
        //-NPR5.48 [335967]
        TestField("No.");
        if "No." <> Item."No." then
          Item.Get("No.");
        //+NPR5.48 [335967]
    end;

    local procedure UpdateCost()
    begin
        //-NPR5.48 [335967]
        Cost := "Unit Cost (LCY)" * Quantity;
        //+NPR5.48 [335967]
    end;

    procedure GetUnitCostLCY(): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemTrackingCode: Record "Item Tracking Code";
        PriceMult: Decimal;
        TxtNoSerial: Label 'No open Item Ledger Entry has been found with the Serial No. %2';
    begin
        //-NPR5.48 [335967]
        // Copy of function "TR406FindItemCostPrice" from Codeunit 6014434 (deleted commented code, and obsolete code)
        // im not sure if its working as it should, but its the best we have
        if "Custom Cost" then
          exit("Unit Cost");

        if ( "Serial No." <> '' ) and ( Quantity > 0 ) then begin
          GetItem;
          Item.TestField("Item Tracking Code");
          ItemTrackingCode.Get(Item."Item Tracking Code");
          if ItemTrackingCode."SN Specific Tracking" then begin
            ItemLedgerEntry.SetCurrentKey(Open,Positive,"Item No.","Serial No.");
            ItemLedgerEntry.SetRange(Open,true);
            ItemLedgerEntry.SetRange(Positive,true);
            ItemLedgerEntry.SetRange("Item No.","No.");
            ItemLedgerEntry.SetRange("Serial No.","Serial No.");
            if not ItemLedgerEntry.FindFirst then begin
              Message(TxtNoSerial,"Serial No.");
              exit(0);
            end;
            ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
            exit(ItemLedgerEntry."Cost Amount (Actual)");
          end;
        end;
        //+NPR5.48 [335967]
    end;

    local procedure UpdateDependingLinesQuantity()
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.48 [335967]
        if Silent then
          exit;

        if xRec.Quantity = 0 then
          exit;

        //TSD is numbering lines differently. Implmented "Main Line No." as reference
        // NOTE: TSD Allows auto split key on new lines
        SaleLinePOS.SetFilter ("Register No.", '=%1', "Register No." );
        SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', "Sales Ticket No." );
        SaleLinePOS.SetFilter ("Sale Type", '=%1', "Sale Type"::Sale );
        SaleLinePOS.SetFilter ("Main Line No.", '=%1', "Line No.");
        SaleLinePOS.SetFilter (Accessory, '=%1', true ); // not really required, would also be one solution for combination items below
        SaleLinePOS.SetFilter ("Main Item No.", '=%1', "No." ); // not really required, would also be one solution for combination items below
        if (SaleLinePOS.FindSet (true,false)) then repeat
          SaleLinePOS.Silent := true;
          SaleLinePOS.Validate (Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity );
          SaleLinePOS.Silent := false;
          SaleLinePOS.SetSkipCalcDiscount (true);
          SaleLinePOS.Modify;
        until SaleLinePOS.Next = 0;
        SaleLinePOS.Reset;

        SaleLinePOS.SetFilter ("Main Line No.", '=%1', 0); // STD will have "Main Line No." as 0 and this function should not interfer in TSD.

        SaleLinePOS.SetRange( "Register No.", "Register No." );
        SaleLinePOS.SetRange( "Sales Ticket No.", "Sales Ticket No." );
        SaleLinePOS.SetRange( "Sale Type", "Sale Type"::Sale );
        SaleLinePOS.SetRange( "Line No.", "Line No." , "Line No." + 9999);
        SaleLinePOS.SetRange( Accessory, true );
        SaleLinePOS.SetRange( "Main Item No.", "No." );
        if SaleLinePOS.FindSet(true,false) then repeat
          SaleLinePOS.Silent := true;
          SaleLinePOS.Validate( Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity );
          SaleLinePOS.Silent := false;
          SaleLinePOS.SetSkipCalcDiscount(true);
          SaleLinePOS.Modify;
        until SaleLinePOS.Next = 0;
        SaleLinePOS.Reset;

        SaleLinePOS.SetRange( "Register No.", "Register No." );
        SaleLinePOS.SetRange( "Sales Ticket No.", "Sales Ticket No." );
        SaleLinePOS.SetRange( Date, Date );
        SaleLinePOS.SetRange( "Sale Type", "Sale Type"::Sale );
        SaleLinePOS.SetRange( "Line No.", "Line No.", "Line No." + 9999 );
        SaleLinePOS.SetRange( "Combination Item", true );
        SaleLinePOS.SetRange( "Main Item No.", "No." );
        SaleLinePOS.SetRange( "Combination No.", "Combination No." );
        if SaleLinePOS.FindSet(true,false) then repeat
          SaleLinePOS.Silent := true;
          SaleLinePOS.Validate( Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity );
          SaleLinePOS.Silent := false;
          SaleLinePOS.SetSkipCalcDiscount(true);
          SaleLinePOS.Modify;
        until SaleLinePOS.Next = 0;
        //+NPR5.48 [335967]
    end;

    procedure SerialNoLookup()
    var
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //-NPR5.48 [335967]
        //Copied from CU 6014434 - function TR406SerialNoOnLookup
        RetailSetup.Get;
        TestField("Sale Type", "Sale Type"::Sale);
        TestField(Type, Type::Item);

        GetItem;
        Item.TestField("Costing Method", Item."Costing Method"::Specific);
        ItemLedgerEntry.SetCurrentKey(Open,Positive,"Item No.","Serial No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Item No.", "No.");
        ItemLedgerEntry.SetFilter("Serial No.", '<> %1', '');
        ItemLedgerEntry.SetRange("Location Code", "Location Code");
        if not RetailSetup."Not use Dim filter SerialNo" then
          ItemLedgerEntry.SetRange("Global Dimension 1 Code", "Shortcut Dimension 1 Code");
        if ItemLedgerEntry.Find('-') then
          repeat
            ItemLedgerEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
            ItemLedgerEntry.FindLast;
            TempItemLedgerEntry := ItemLedgerEntry;
            TempItemLedgerEntry.Insert;
            ItemLedgerEntry.SetRange("Serial No.");
          until ItemLedgerEntry.Next = 0;

        if PAGE.RunModal(PAGE::"Item - Series Number", TempItemLedgerEntry) <> ACTION::LookupOK then
          exit;

        Validate("Serial No.", TempItemLedgerEntry."Serial No.");

        TempItemLedgerEntry.CalcFields("Cost Amount (Actual)");
        Validate("Unit Cost (LCY)", TempItemLedgerEntry."Cost Amount (Actual)");
        "Custom Cost" := true;
        //+NPR5.48 [335967]
    end;

    procedure SerialNoValidate()
    var
        SaleLinePOS2: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        Positive: Boolean;
        Txt001: Label 'Quantity in a serial number sale must be 1 or -1!';
        Txt002: Label '%2 %1 has already been used in another transaction! \';
        Txt003: Label 'try to check saved receipts';
        Txt004: Label '%2 %1 has already sold!';
        Txt005: Label '%2 %1 is already in stock!';
        TotalNonAppliedQuantity: Decimal;
    begin
        //-NPR5.48 [335967]
        //Copied from CU 6014434 - function TR406SerialNoOnValidate (modifyed partly)
        if "Serial No." = '' then
          exit;

        TotalAuditRollQuantity := 0;
        TotalItemLedgerEntryQuantity := 0;
        TestField("Sale Type","Sale Type"::Sale);
        TestField(Quantity);

        GetItem;
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");
        //-NPR5.48 [335967]
        //  IF ItemTrackingCode."SN Specific Tracking" THEN
        //    Item.TESTFIELD("Costing Method",Item."Costing Method"::Specific);
        //+NPR5.48 [335967]

        SaleLinePOS2.SetCurrentKey("Serial No.");
        SaleLinePOS2.SetRange("Serial No.","Serial No.");
        if SaleLinePOS2.FindSet then
          repeat
            SalePOS.Get(SaleLinePOS2."Register No.",SaleLinePOS2."Sales Ticket No.");
            if not SalePOS."Saved Sale" then
              if (SaleLinePOS2."Sales Ticket No." <> "Sales Ticket No.") or (SaleLinePOS2."Line No." <> "Line No.") then
                Error(Text004, FieldName("Serial No."), "Serial No.");
          until SaleLinePOS2.Next = 0;

        //If not sure what this is, but i have copied it 1:1
        if Quantity <> Abs(1) then
          Quantity := 1 * (Quantity / Abs(Quantity));
        Positive := (Quantity >= 0);

        if ItemTrackingCode."SN Specific Tracking" then begin
          CheckSerialNoApplication("No.", "Serial No.");
          CheckSerialNoAuditRoll("No.", "Serial No.", Positive);
          if not NoWarning then begin
            if Positive then begin
              TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
              if (TotalNonAppliedQuantity < 0) then begin
                Message(Txt004,"Serial No.",FieldName("Serial No."));
                "Serial No." := '';
              end;
            end else begin
              TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
              if TotalNonAppliedQuantity > 1 then begin
                Message(Txt005,"Serial No.",FieldName("Serial No."));
                "Serial No." := '';
              end;
            end;
          end;
        end;
        //+NPR5.48 [335967]
    end;
}


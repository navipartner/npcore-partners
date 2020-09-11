page 6014425 "NPR Retail Item Card"
{
    // NPR3.1p, NPK, DL, 04-01-07, Added "Automatic Ext. Texts"
    // NPR4.000.003, NPK, 29-03-09, MH, Tilf¢jet "Additional info" på web-fanebladet.
    // NPR7.000.000    27.2.2013  TS   :was on Activate Trigger of Form :
    // MAG1.00/MH/20150113    CASE 199932 Upgraded Magento Integration from WEB1.00
    // NPR1.06/BHR/20150120   CASE 203485 Add field Blocked on POS
    // MAG1.01/MH/20150201    CASE 199932 Updated Magento Group
    // MAG1.04/MH/20150206    CASE 199932 Added WebVariant
    // NPR3.07/MH/20150216    CASE 204110 Removed NaviShop References (WS).
    // MAG1.05/MH/20150224    CASE 199932 Updated WebVariant
    // VRT1.00/JDH/20150304   CASE 201022 Variety Page Added + Fields + shortcut to Matrix under button Item
    // MAG1.09/MH/20150316    CASE 206395 Updated link to Subpage Magento Picture Link Subform
    // MAG1.11/MH/20150325    CASE 209616 Added MagentoEditableWebVariantType
    // MAG1.12/MH/20150408    CASE 210740 Changed importance of Additional Magento fields to Standard and added missing SetMagentoVisible-invoke
    // MAG1.14/MH/20150415    CASE 211360 Added Test on Item Webshop Descriptions and reduced SetVisible Variables
    // NPR4.04/JDH/20150427   CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.11/MMV/20150520   CASE 213635 Refactored label print code and added support for Variety
    // NPR4.11/TSA/20150422   CASE 209946 - Entity and Shortcut Attributes
    // NPR4.11/TSA/20150513   CASE 209946 - Made 5 of the new fields available on the general tab, default invisible
    // NPR4.11/TSA/20150605   CASE 209946 - Change the attrbutes to have 1-5 on general tab 6-10 on property tag, visible if assigned
    // MAG1.17/TR/20150402    CASE 210548 Multiwebsite Page (Magento Store Item Page) called.
    // MAG1.17/MH/20150622    CASE 215533 Magento related NaviConnect Setup moved to Magento Setup
    // NPR4.11/RMT/20150625   CASE 209946 - Set attribute fields editable when creating new items
    // NPR4.11/JDH/20150625   CASE 217444 Removed Function "SamletLager" - didnt work (Changecompany and Calcfields)
    // MAG1.18/MH/20150716    CASE 218309 Removed TESTFIELD on Webshop Descriptions
    // NPR4.14/MMV/20150724   CASE 213635 Fixed variable naming and syntax of EAN Label actions. Moved PrintEAN() and references to CU 6014413
    // NPR4.14/JDH/20150831   CASE 221837 Removed unused variables and functions
    // NPR4.15/JDH/20151001   CASE 224204 Caption changed from GL to Item on the ledger entries lookup
    // NPR4.15/TS/20151013    CASE 224751 Added NpAttribute Factbox
    // NPR4.17/LS/20151022    CASE 225607 Next Counting Period removed ( no more in Table 27) + Item Tracking Entries Changed
    // MAG1.21/MHA/20151118   CASE 227354 Added PromotedActionCategoriesML (5 = Retail,6 = Magento) and restructured Magento Groups
    // MAG1.21/MHA/20151118   CASE 223835 Magento Pictures PagePart removed and functionality added to Action Magento Pictures
    // MAG1.21/MHA/20151120   CASE 227734 WebVariant deleted [MAG1.04]
    // MAG1.22/MHA/20151202   CASE 227734 Added ProductRelations subpage
    // NPR4.18/MMV/20151229   CASE 225584 Added field "Print Tags"
    // NPR4.18/MMV/20151230   CASE 229221 Removed action "EAN Label".
    //                                    Disabled action "Shelf" since it is not used currently. Should be rewritten if needed.
    //                                    Changed captions.
    // NPR5.22/MMV/20160420   CASE 237743 Updated reference to Label Library CU.
    //                                    Added missing action captions & properties from NPR4.18 release
    // MAG1.22/TR  /20160414  CASE 238563 Added "Custom Options" field
    // MAG1.22/MHA /20160422  CASE 239060 Magento Item Picture Factbox added to display Magento Base Picture
    // NPR5.23/JDH /20160513  CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.23/TS  /20160524  CASE 242691  Added field Unit List Price
    // VRT1.11/JDH /20160531  CASE 242940  Added action create missing barcode(s)
    // NPR5.23/TS  /20160609  CASE 243984 Added field Type to be able to select Service/Inventory
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // NPR5.26/MHA /20160810  CASE 248288 Reference removed to deleted Item Field: 6014417 "NPK Created"
    // NPR5.26/OSFI/20160810  CASE 246167 Added option "POS Info" to allow links to POS info.
    // NPR5.27/LS  /20161018  CASE 255541 Changed link on action "Multiple Unit Prices"
    // NPR5.29/LS  /20161108  CASE 257874 Changed length from 100 to 250 for Global Var "NPRAttrTextArray"
    // NPR5.29/LS  /20161125  CASE 259161 Added field Condition in General tab
    // NPR5.29/MMV /20161201  CASE 259398 Refactored search field.
    // NPR5.29/JDH /20161221  CASE 261631 removed code on Label Barcode field (no documentation), as well as restructured code on field AltNr
    // NPR5.29/TS  /20161230  CASE 262167 Added "Country/Region of Origin Code"
    // NPR5.29/TS  /20170103  CASE 261860 Added field Inventory Value Zero
    // NPR5.29/BHR /20170126  CASE 264081 Change display sequence of these fields : Type, Item Group,  Base Unit of measure
    // NPR5.30/TS  /20170112  CASE 259207 Removed field Change Quantity by PhotoOrder
    // NPR5.30/BHR /20170217  CASE 262923 Add Action Reparation
    // NPR5.30/TJ  /20170221  CASE 266258 Changed RunObject property on actions Item Journal and Item Reclassification Journal to use new pages Retail Item Journal and Retail Item Reclass. Journal
    // NPR5.30/MMV /20170221  CASE 266517 Changed label action caption.
    //                                    Removed not-visible sign action.
    // NPR5.30/TJ  /20170224  CASE 267292 Added field "VAT Bus. Posting Gr. (Price)" under Invoicing tab
    // NPR5.30/BR  /20170228  CASE 252646 Added RelatedInformation to MCS Recommendations Lines page
    // NPR5.30/JDH /20170309  CASE 255961 Promoted Variety Actions
    // NPR5.31/MMV /20170329  CASE 266049 Added "Units per Parcel"
    // NPR5.33/ANEN/20170427  CASE 273989 Extending to 40 attributes
    // NPR5.32/JLK /20170515  CASE 274419 Added field Item Status
    // NPR5.32/JLK /20170524  CASE 277219 Added field 105 "Global Dimension 1 Code" and 106 "Global Dimension 2 Code"
    // NPR5.34/ANEN/20170704  CASE 284384 Show attributes in group extra fields
    // MAG2.06/MHA /20170817  CASE 286203 Added AutoOverwrite to Magento DragDrop
    // NPR5.35/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    // NPR5.35/ANEN/20170704  CASE 284384 Show attributes in group extra fields
    // NPR5.36/BHR /20170210  CASE 289871 Correct bug on search functionality
    // NPR5.36/JLK /20171003  CASE 291592 Copied and placed OnLookup function to General tab for Client Attributes
    // NPR5.37/JLK /20171009  CASE 291604 Added field "Sales (Qty.)" under Inventory field in General tab
    // NPR5.38/BR  /20171116  CASE 295255 Added Action POS Sales Entries
    // NPR5.38/MHA /20180104  CASE 299272 Added fields 6014635 "Sale Blocked" and 6014640 "Purchase Blocked"
    // NPR5.38/BR  /20180125  CASE 302803 Added Field "Tax Group Code"
    // NPR5.40/TS  /20180315  CASE 308197 Added filter Status to Period Discount
    // NPR5.40/JLK /20180316  CASE 308393 Renamed Action Variety to Variety Matrix and moved Statistic Group to General Tab
    // NPR5.42/MMV /20180504  CASE 297569 Added field "Custom Discount Blocked"
    // NPR5.43/RA  /20180605  CASE 311123 Deskription was missing
    // NPR5.43/TS  /20180606  CASE 314830 Code removed on Validate as it was not working.Move to on AfterGetCurrRecord to load values.
    // NPR5.43/TS  /20180330  CASE 308196 Added Discount
    // MAG2.15/TS  /20180531  CASE 311926 Added Magento Video Links
    // NPR5.48/MHA /20181109  CASE 334922 Added field 6151125 "Item AddOn No."
    // NPR5.48/TS  /20181220  CASE 339348 Adde Shortcut Key to Add Barcodes
    // NPR5.48/TJ  /20190102  CASE 340615 Removed field "Product Group Code"
    // NPR5.50/THRO/20190412  CASE 352040 Removed fixed key on card. Was "Primary Key Length"
    // NPR5.50/BHR /20190506  CASE 353006 Add field Season
    // MAG2.22/MHA /20190625  CASE 359285 Added field 6151500 "Magento Picture Variety Type"
    // NPR5.51/ZESO/20190828  CASE 365796 Added field 6014642 Shelf Label Type
    // NPR5.51/JAKUBV/20190904  CASE 361514 Transport NPR5.51 - 3 September 2019
    // NPR5.52/ANPA/20191001  CASE 367476 Removed field "Units", "Barcodes" and "Reperation" in pageaction Related
    // NPR5.52/SARA/20191014  CASE 372089 Redesign Magento fasttab for webclient
    // NPR5.53/MHA /20191113  CASE 374721 Updated Page Caption
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"
    // NPR5.55/ALPO/20200708  CASE 382428 Added field "Rest. Item Routing Profile"

    Caption = 'Retail Item Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Reports,Manage,Retail,Magento';
    RefreshOnActivate = true;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            group(Control6150668)
            {
                ShowCaption = false;
                group(Control6150618)
                {
                    ShowCaption = false;
                    field(SearchNo; SearchNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Find Item Card';

                        trigger OnValidate()
                        var
                            BarcodeLibrary: Codeunit "NPR Barcode Library";
                            ItemNo: Code[20];
                            VariantCode: Code[10];
                            ResolvingTable: Integer;
                        begin
                            //-NPR5.36 [289871]
                            if Format(OriginalRec) <> Format(Rec) then
                                Modify(true);
                            //+NPR5.36 [289871]
                            // CurrPage.UPDATE(TRUE);
                            if BarcodeLibrary.TranslateBarcodeToItemVariant(SearchNo, ItemNo, VariantCode, ResolvingTable, true) then begin
                                SetRange("No.", ItemNo);
                                FindFirst;
                            end;

                            Clear(SearchNo);
                        end;
                    }
                }
                group(Control6150616)
                {
                    ShowCaption = false;
                    field(Barcode; Barcode)
                    {
                        ApplicationArea = All;
                        Caption = 'Create barcode';

                        trigger OnAssistEdit()
                        var
                            VarietyCloneData: Codeunit "NPR Variety Clone Data";
                        begin
                            //-NPR5.29 [261631]
                            VarietyCloneData.LookupBarcodes("No.", '');
                            //Altnr := Utility.CreateEAN("No.", '');
                            //RetailFormCode.CreateNewAltItem(Rec,xRec,Altnr,'');
                            //Altnr := '';
                            //+NPR5.29 [261631]
                        end;

                        trigger OnValidate()
                        var
                            VarietyCloneData: Codeunit "NPR Variety Clone Data";
                        begin
                            //-NPR5.29 [261631]
                            //IF Altnr <> '' THEN
                            //  RetailFormCode.CreateNewAltItem(Rec,xRec,Altnr,'');
                            VarietyCloneData.AddCustomBarcode("No.", '', Barcode);
                            //+NPR5.29 [261631]
                            Barcode := '';
                        end;
                    }
                }
            }
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Item Status"; "NPR Item Status")
                {
                    ApplicationArea = All;
                }
                field("Item Group"; "NPR Item Group")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Assembly BOM"; "Assembly BOM")
                {
                    ApplicationArea = All;
                }
                field("Shelf No."; "Shelf No.")
                {
                    ApplicationArea = All;
                }
                field(AverageCostLCY; AverageCostLCY)
                {
                    ApplicationArea = All;
                    Caption = 'Average Cost (LCY)';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Show Avg. Calc. - Item", Rec);
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.43 [314830]
                        //This code was written on the control.
                        //ItemCostMgt.CalculateAverageCost(Rec,AverageCostLCY,AverageCostACY)
                        //+NPR5.43 [314830]
                    end;
                }
                field("Automatic Ext. Texts"; "Automatic Ext. Texts")
                {
                    ApplicationArea = All;
                }
                field("Created From Nonstock Item"; "Created From Nonstock Item")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        EnableCostingControls;
                    end;
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = All;
                }
                field("Label Barcode"; "NPR Label Barcode")
                {
                    ApplicationArea = All;
                }
                field("Service Item Group"; "Service Item Group")
                {
                    ApplicationArea = All;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Inventory Value Zero"; "Inventory Value Zero")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Sales (Qty.)"; "Sales (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Purch. Order"; "Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Prod. Order"; "Qty. on Prod. Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Component Lines"; "Qty. on Component Lines")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Service Order"; "Qty. on Service Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Job Order"; "Qty. on Job Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Assembly Order"; "Qty. on Assembly Order")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Qty. on Asm. Component"; "Qty. on Asm. Component")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Group sale"; "NPR Group sale")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Blocked on Pos"; "NPR Blocked on Pos")
                {
                    ApplicationArea = All;
                }
                field("Custom Discount Blocked"; "NPR Custom Discount Blocked")
                {
                    ApplicationArea = All;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item Brand"; "NPR Item Brand")
                {
                    ApplicationArea = All;
                }
                field("Statistics Group"; "Statistics Group")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field(NPRAttrTextArray_01_GEN; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.37
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                        //+NPR5.37
                    end;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02_GEN; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.37
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                        //+NPR5.37
                    end;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03_GEN; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.37
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                        //+NPR5.37
                    end;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04_GEN; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.37
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                        //+NPR5.37
                    end;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05_GEN; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.37
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                        //+NPR5.37
                    end;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                    end;
                }
                field(Condition; "NPR Condition")
                {
                    ApplicationArea = All;
                }
                field(Season; "NPR Season")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Shelf Label Type"; "NPR Shelf Label Type")
                {
                    ApplicationArea = All;
                }
            }
            group("Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 6, "No.", NPRAttrTextArray[6]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 6, "No.", NPRAttrTextArray[6]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 7, "No.", NPRAttrTextArray[7]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 7, "No.", NPRAttrTextArray[7]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 8, "No.", NPRAttrTextArray[8]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 8, "No.", NPRAttrTextArray[8]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 9, "No.", NPRAttrTextArray[9]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 9, "No.", NPRAttrTextArray[9]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 10, "No.", NPRAttrTextArray[10]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 10, "No.", NPRAttrTextArray[10]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_11; NPRAttrTextArray[11])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,11,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible11;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 11, "No.", NPRAttrTextArray[11]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 11, "No.", NPRAttrTextArray[11]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_12; NPRAttrTextArray[12])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,12,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible12;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 12, "No.", NPRAttrTextArray[12]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 12, "No.", NPRAttrTextArray[12]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_13; NPRAttrTextArray[13])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,13,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible13;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 13, "No.", NPRAttrTextArray[13]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 13, "No.", NPRAttrTextArray[13]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_14; NPRAttrTextArray[14])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,14,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible14;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 14, "No.", NPRAttrTextArray[14]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 14, "No.", NPRAttrTextArray[14]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_15; NPRAttrTextArray[15])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,15,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible15;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 15, "No.", NPRAttrTextArray[15]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 15, "No.", NPRAttrTextArray[15]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_16; NPRAttrTextArray[16])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,16,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible16;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 16, "No.", NPRAttrTextArray[16]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 16, "No.", NPRAttrTextArray[16]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_17; NPRAttrTextArray[17])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,17,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible17;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 17, "No.", NPRAttrTextArray[17]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 17, "No.", NPRAttrTextArray[17]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_18; NPRAttrTextArray[18])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,18,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible18;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 18, "No.", NPRAttrTextArray[18]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 18, "No.", NPRAttrTextArray[18]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_19; NPRAttrTextArray[19])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,19,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible19;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 19, "No.", NPRAttrTextArray[19]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 19, "No.", NPRAttrTextArray[19]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_20; NPRAttrTextArray[20])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,20,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible20;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 20, "No.", NPRAttrTextArray[20]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 20, "No.", NPRAttrTextArray[20]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_21; NPRAttrTextArray[21])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,21,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible21;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 21, "No.", NPRAttrTextArray[21]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 21, "No.", NPRAttrTextArray[21]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_22; NPRAttrTextArray[22])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,22,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible22;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 22, "No.", NPRAttrTextArray[22]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 22, "No.", NPRAttrTextArray[22]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_23; NPRAttrTextArray[23])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,23,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible23;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 23, "No.", NPRAttrTextArray[23]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 23, "No.", NPRAttrTextArray[23]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_24; NPRAttrTextArray[24])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,24,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible24;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 24, "No.", NPRAttrTextArray[24]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 24, "No.", NPRAttrTextArray[24]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_25; NPRAttrTextArray[25])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,25,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible25;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 25, "No.", NPRAttrTextArray[25]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 25, "No.", NPRAttrTextArray[25]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_26; NPRAttrTextArray[26])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,26,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible26;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 26, "No.", NPRAttrTextArray[26]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 26, "No.", NPRAttrTextArray[26]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_27; NPRAttrTextArray[27])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,27,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible27;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 27, "No.", NPRAttrTextArray[27]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 27, "No.", NPRAttrTextArray[27]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_28; NPRAttrTextArray[28])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,28,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible28;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 28, "No.", NPRAttrTextArray[28]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 28, "No.", NPRAttrTextArray[28]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_29; NPRAttrTextArray[29])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,29,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible29;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 29, "No.", NPRAttrTextArray[29]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 29, "No.", NPRAttrTextArray[29]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_30; NPRAttrTextArray[30])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,30,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible30;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 30, "No.", NPRAttrTextArray[30]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 30, "No.", NPRAttrTextArray[30]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_31; NPRAttrTextArray[31])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,31,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible31;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 31, "No.", NPRAttrTextArray[31]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 31, "No.", NPRAttrTextArray[31]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_32; NPRAttrTextArray[32])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,32,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible32;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 32, "No.", NPRAttrTextArray[32]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 32, "No.", NPRAttrTextArray[32]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_33; NPRAttrTextArray[33])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,33,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible33;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 33, "No.", NPRAttrTextArray[33]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 33, "No.", NPRAttrTextArray[33]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_34; NPRAttrTextArray[34])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,34,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible34;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 34, "No.", NPRAttrTextArray[34]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 34, "No.", NPRAttrTextArray[34]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_35; NPRAttrTextArray[35])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,35,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible35;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 35, "No.", NPRAttrTextArray[35]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 35, "No.", NPRAttrTextArray[35]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_36; NPRAttrTextArray[36])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,36,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible36;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 36, "No.", NPRAttrTextArray[36]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 36, "No.", NPRAttrTextArray[36]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_37; NPRAttrTextArray[37])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,37,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible37;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 37, "No.", NPRAttrTextArray[37]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 37, "No.", NPRAttrTextArray[37]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_38; NPRAttrTextArray[38])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,38,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible38;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 38, "No.", NPRAttrTextArray[38]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 38, "No.", NPRAttrTextArray[38]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_39; NPRAttrTextArray[39])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,39,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible39;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 39, "No.", NPRAttrTextArray[39]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 39, "No.", NPRAttrTextArray[39]);
                        //+NPR5.34 [284384]
                    end;
                }
                field(NPRAttrTextArray_40; NPRAttrTextArray[40])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,40,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible40;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.35 [284384]
                        NPRAttrManagement.OnPageLookUp(DATABASE::Item, 40, "No.", NPRAttrTextArray[40]);
                        //+NPR5.35 [284384]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.34 [284384]
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 40, "No.", NPRAttrTextArray[40]);
                        //+NPR5.34 [284384]
                    end;
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        EnableCostingControls;
                        CheckItemGroup();
                    end;
                }
                field("Cost is Adjusted"; "Cost is Adjusted")
                {
                    ApplicationArea = All;
                }
                field("Cost is Posted to G/L"; "Cost is Posted to G/L")
                {
                    ApplicationArea = All;
                }
                field("Standard Cost"; "Standard Cost")
                {
                    ApplicationArea = All;
                    Enabled = StandardCostEnable;

                    trigger OnDrillDown()
                    var
                        ShowAvgCalcItem: Codeunit "Show Avg. Calc. - Item";
                    begin
                        ShowAvgCalcItem.DrillDownAvgCostAdjmtPoint(Rec)
                    end;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    Enabled = UnitCostEnable;

                    trigger OnDrillDown()
                    var
                        ShowAvgCalcItem: Codeunit "Show Avg. Calc. - Item";
                    begin
                        ShowAvgCalcItem.DrillDownAvgCostAdjmtPoint(Rec)
                    end;
                }
                field("Overhead Rate"; "Overhead Rate")
                {
                    ApplicationArea = All;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    ApplicationArea = All;
                }
                field("Last Direct Cost"; "Last Direct Cost")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Price/Profit Calculation"; "Price/Profit Calculation")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Unit List Price"; "Unit List Price")
                {
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                }
                field("Net Invoiced Qty."; "Net Invoiced Qty.")
                {
                    ApplicationArea = All;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = All;
                }
                field("Item Disc. Group"; "Item Disc. Group")
                {
                    ApplicationArea = All;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CheckItemGroup();
                    end;
                }
                field("Application Wksh. User ID"; "Application Wksh. User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Sale Blocked"; "NPR Sale Blocked")
                {
                    ApplicationArea = All;
                }
            }
            group(Replenishment)
            {
                Caption = 'Replenishment';
                field("Replenishment System"; "Replenishment System")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Lead Time Calculation"; "Lead Time Calculation")
                {
                    ApplicationArea = All;
                }
                group(Purchase)
                {
                    Caption = 'Purchase';
                    field("Vendor No."; "Vendor No.")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CheckItemGroup();
                        end;
                    }
                    field(VendorItemNo2; "Vendor Item No.")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CheckItemGroup();
                        end;
                    }
                    field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CheckItemGroup();
                        end;
                    }
                    field("Purchase Blocked"; "NPR Purchase Blocked")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control230)
                {
                    Caption = 'Production';
                    field("Manufacturing Policy"; "Manufacturing Policy")
                    {
                        ApplicationArea = All;
                    }
                    field("Routing No."; "Routing No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Production BOM No."; "Production BOM No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Rounding Precision"; "Rounding Precision")
                    {
                        ApplicationArea = All;
                    }
                    field("Flushing Method"; "Flushing Method")
                    {
                        ApplicationArea = All;
                    }
                    field("Scrap %"; "Scrap %")
                    {
                        ApplicationArea = All;
                    }
                    field("Lot Size"; "Lot Size")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Assembly)
                {
                    Caption = 'Assembly';
                    field("Assembly Policy"; "Assembly Policy")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Planning)
            {
                Caption = 'Planning';
                field("Reordering Policy"; "Reordering Policy")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        EnablePlanningControls
                    end;
                }
                field(Reserve; Reserve)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Order Tracking Policy"; "Order Tracking Policy")
                {
                    ApplicationArea = All;
                }
                field("Stockkeeping Unit Exists"; "Stockkeeping Unit Exists")
                {
                    ApplicationArea = All;
                }
                field("Dampener Period"; "Dampener Period")
                {
                    ApplicationArea = All;
                    Enabled = DampenerPeriodEnable;
                }
                field("Dampener Quantity"; "Dampener Quantity")
                {
                    ApplicationArea = All;
                    Enabled = DampenerQtyEnable;
                }
                field(Critical; Critical)
                {
                    ApplicationArea = All;
                }
                field("Safety Lead Time"; "Safety Lead Time")
                {
                    ApplicationArea = All;
                    Enabled = SafetyLeadTimeEnable;
                }
                field("Safety Stock Quantity"; "Safety Stock Quantity")
                {
                    ApplicationArea = All;
                    Enabled = SafetyStockQtyEnable;
                }
                group("Lot-for-Lot Parameters")
                {
                    Caption = 'Lot-for-Lot Parameters';
                    field("Include Inventory"; "Include Inventory")
                    {
                        ApplicationArea = All;
                        Enabled = IncludeInventoryEnable;

                        trigger OnValidate()
                        begin
                            EnablePlanningControls
                        end;
                    }
                    field("Lot Accumulation Period"; "Lot Accumulation Period")
                    {
                        ApplicationArea = All;
                        Enabled = LotAccumulationPeriodEnable;
                    }
                    field("Rescheduling Period"; "Rescheduling Period")
                    {
                        ApplicationArea = All;
                        Enabled = ReschedulingPeriodEnable;
                    }
                }
                group("Reorder-Point Parameters")
                {
                    Caption = 'Reorder-Point Parameters';
                    grid(Control65)
                    {
                        GridLayout = Rows;
                        ShowCaption = false;
                        group(Control64)
                        {
                            ShowCaption = false;
                            field("Reorder Point"; "Reorder Point")
                            {
                                ApplicationArea = All;
                                Enabled = ReorderPointEnable;

                                trigger OnValidate()
                                begin
                                    CheckItemGroup();
                                end;
                            }
                            field("Reorder Quantity"; "Reorder Quantity")
                            {
                                ApplicationArea = All;
                                Enabled = ReorderQtyEnable;
                            }
                            field("Maximum Inventory"; "Maximum Inventory")
                            {
                                ApplicationArea = All;
                                Enabled = MaximumInventoryEnable;

                                trigger OnValidate()
                                begin
                                    CheckItemGroup();
                                end;
                            }
                        }
                    }
                    field("Overflow Level"; "Overflow Level")
                    {
                        ApplicationArea = All;
                        Enabled = OverflowLevelEnable;
                        Importance = Additional;
                    }
                    field("Time Bucket"; "Time Bucket")
                    {
                        ApplicationArea = All;
                        Enabled = TimeBucketEnable;
                        Importance = Additional;
                    }
                }
                group("Order Modifiers")
                {
                    Caption = 'Order Modifiers';
                    grid(Control60)
                    {
                        GridLayout = Rows;
                        ShowCaption = false;
                        group(Control61)
                        {
                            ShowCaption = false;
                            field("Minimum Order Quantity"; "Minimum Order Quantity")
                            {
                                ApplicationArea = All;
                                Enabled = MinimumOrderQtyEnable;
                            }
                            field("Maximum Order Quantity"; "Maximum Order Quantity")
                            {
                                ApplicationArea = All;
                                Enabled = MaximumOrderQtyEnable;
                            }
                            field("Order Multiple"; "Order Multiple")
                            {
                                ApplicationArea = All;
                                Enabled = OrderMultipleEnable;
                            }
                        }
                    }
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                field("Tariff No."; "Tariff No.")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; "Net Weight")
                {
                    ApplicationArea = All;
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = All;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = All;
                }
            }
            group("Item Tracking")
            {
                Caption = 'Item Tracking';
                field("Item Tracking Code"; "Item Tracking Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Serial Nos."; "Serial Nos.")
                {
                    ApplicationArea = All;
                }
                field("Lot Nos."; "Lot Nos.")
                {
                    ApplicationArea = All;
                }
                field("Expiration Calculation"; "Expiration Calculation")
                {
                    ApplicationArea = All;
                }
            }
            group(Control1907509201)
            {
                Caption = 'Warehouse';
                field("Special Equipment Code"; "Special Equipment Code")
                {
                    ApplicationArea = All;
                }
                field("Put-away Template Code"; "Put-away Template Code")
                {
                    ApplicationArea = All;
                }
                field("Put-away Unit of Measure Code"; "Put-away Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Phys Invt Counting Period Code"; "Phys Invt Counting Period Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Last Phys. Invt. Date"; "Last Phys. Invt. Date")
                {
                    ApplicationArea = All;
                }
                field("Last Counting Period Update"; "Last Counting Period Update")
                {
                    ApplicationArea = All;
                }
                field("Identifier Code"; "Identifier Code")
                {
                    ApplicationArea = All;
                }
                field("Use Cross-Docking"; "Use Cross-Docking")
                {
                    ApplicationArea = All;
                }
            }
            group(Variety)
            {
                Caption = 'Variety';
                group(Control6150691)
                {
                    ShowCaption = false;
                    field("Has Variants"; "NPR Has Variants")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Variety Group"; "NPR Variety Group")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 1"; "NPR Variety 1")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 1 Table"; "NPR Variety 1 Table")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 2"; "NPR Variety 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 2 Table"; "NPR Variety 2 Table")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 3"; "NPR Variety 3")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 3 Table"; "NPR Variety 3 Table")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 4"; "NPR Variety 4")
                    {
                        ApplicationArea = All;
                    }
                    field("Variety 4 Table"; "NPR Variety 4 Table")
                    {
                        ApplicationArea = All;
                    }
                    field("Cross Variety No."; "NPR Cross Variety No.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Properties)
            {
                Caption = 'Properties';
                group(Control6150684)
                {
                    ShowCaption = false;
                    field("Item AddOn No."; "NPR Item AddOn No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Guarantee Index"; "NPR Guarantee Index")
                    {
                        ApplicationArea = All;
                    }
                    field("Insurrance category"; "NPR Insurrance category")
                    {
                        ApplicationArea = All;
                        Width = 30;
                    }
                }
                group(Control6150676)
                {
                    ShowCaption = false;
                    field("Explode BOM auto"; "NPR Explode BOM auto")
                    {
                        ApplicationArea = All;
                    }
                    field("Guarantee voucher"; "NPR Guarantee voucher")
                    {
                        ApplicationArea = All;
                    }
                    field("No Print on Reciept"; "NPR No Print on Reciept")
                    {
                        ApplicationArea = All;
                    }
                    field("Ticket Type"; "NPR Ticket Type")
                    {
                        ApplicationArea = All;
                    }
                    field(NPRAttrTextArray_06_GEN; NPRAttrTextArray[6])
                    {
                        ApplicationArea = All;
                        CaptionClass = '6014555,27,6,2';
                        Editable = NPRAttrEditable;
                        Visible = NPRAttrVisible06;

                        trigger OnValidate()
                        begin
                            NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 6, "No.", NPRAttrTextArray[6]);
                        end;
                    }
                    field(NPRAttrTextArray_07_GEN; NPRAttrTextArray[7])
                    {
                        ApplicationArea = All;
                        CaptionClass = '6014555,27,7,2';
                        Editable = NPRAttrEditable;
                        Visible = NPRAttrVisible07;

                        trigger OnValidate()
                        begin
                            NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 7, "No.", NPRAttrTextArray[7]);
                        end;
                    }
                    field(NPRAttrTextArray_08_GEN; NPRAttrTextArray[8])
                    {
                        ApplicationArea = All;
                        CaptionClass = '6014555,27,8,2';
                        Editable = NPRAttrEditable;
                        Visible = NPRAttrVisible08;

                        trigger OnValidate()
                        begin
                            NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 8, "No.", NPRAttrTextArray[8]);
                        end;
                    }
                    field(NPRAttrTextArray_09_GEN; NPRAttrTextArray[9])
                    {
                        ApplicationArea = All;
                        CaptionClass = '6014555,27,9,2';
                        Editable = NPRAttrEditable;
                        Visible = NPRAttrVisible09;

                        trigger OnValidate()
                        begin
                            NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 9, "No.", NPRAttrTextArray[9]);
                        end;
                    }
                    field(NPRAttrTextArray_10_GEN; NPRAttrTextArray[10])
                    {
                        ApplicationArea = All;
                        CaptionClass = '6014555,27,10,2';
                        Editable = NPRAttrEditable;
                        Visible = NPRAttrVisible10;

                        trigger OnValidate()
                        begin
                            NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 10, "No.", NPRAttrTextArray[10]);
                        end;
                    }
                    field("Print Tags"; "NPR Print Tags")
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            PrintTagsPage: Page "NPR Print Tags";
                        begin
                            //-NPR4.18
                            Clear(PrintTagsPage);

                            PrintTagsPage.SetTagText("NPR Print Tags");
                            if PrintTagsPage.RunModal = ACTION::OK then
                                "NPR Print Tags" := PrintTagsPage.ToText;
                            //+NPR4.18
                        end;
                    }
                    field("NPRE Item Routing Profile"; "NPR NPRE Item Routing Profile")
                    {
                        ApplicationArea = All;
                    }
                }
                group("NPR Attributes")
                {
                    Caption = 'NPR Attributes';
                }
            }
            group(MagentoGroup)
            {
                Caption = 'Magento';
                Visible = MagentoEnabled;
                group(Control6014404)
                {
                    ShowCaption = false;
                    field("Magento Item"; "NPR Magento Item")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;

                        trigger OnValidate()
                        begin
                            //-MAG1.21
                            //SetMagentoVisible();
                            SetMagentoEnabled();
                            //+MAG1.21
                        end;
                    }
                    field("Magento Status"; "NPR Magento Status")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Magento Name"; "NPR Magento Name")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            //-MAG2.00
                            //IF "Seo Link" <> '' THEN
                            //  IF NOT CONFIRM(Text6059800,FALSE) THEN
                            //    EXIT;
                            //VALIDATE("Seo Link","Webshop Name");
                            if "NPR Seo Link" <> '' then
                                if not Confirm(Text6151400, false) then
                                    exit;
                            Validate("NPR Seo Link", "NPR Magento Name");
                            //+MAG2.00
                        end;
                    }
                    field("FORMAT(""Magento Description"".HASVALUE)"; Format("NPR Magento Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Magento Description';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            //-MAG2.00
                            //FieldRef := RecRef.FIELD(FIELDNO("Webshop Description"));
                            FieldRef := RecRef.Field(FieldNo("NPR Magento Description"));
                            //+MAG2.00
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Modify(true);
                                //-MAG1.22
                                //MagentoItemMgt.TestItem(Rec);
                                //+MAG1.22
                            end;
                        end;
                    }
                    field("FORMAT(""Magento Short Description"".HASVALUE)"; Format("NPR Magento Short Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Magento Short Description';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            //-MAG2.00
                            //FieldRef := RecRef.FIELD(FIELDNO("Webshop Short Description"));
                            FieldRef := RecRef.Field(FieldNo("NPR Magento Short Description"));
                            //+MAG2.00
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Modify(true);
                                //-MAG1.22
                                ////-MAG1.18
                                //MagentoItemMgt.TestItem(Rec);
                                ////+MAG1.18
                                //+MAG1.22
                            end;
                        end;
                    }
                    field("Magento Brand"; "NPR Magento Brand")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledBrand;
                    }
                    field(MagentoUnitPrice; "Unit Price")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Product New From"; "NPR Product New From")
                    {
                        ApplicationArea = All;
                    }
                    field("Product New To"; "NPR Product New To")
                    {
                        ApplicationArea = All;
                    }
                    field("Featured From"; "NPR Featured From")
                    {
                        ApplicationArea = All;
                    }
                    field("Featured To"; "NPR Featured To")
                    {
                        ApplicationArea = All;
                    }
                    field("Special Price"; "NPR Special Price")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledSpecialPrices;
                    }
                    field("Special Price From"; "NPR Special Price From")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledSpecialPrices;
                    }
                    field("Special Price To"; "NPR Special Price To")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledSpecialPrices;
                    }
                    field("Custom Options"; "NPR Custom Options")
                    {
                        ApplicationArea = All;
                        Visible = MagentoEnabledCustomOptions;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            MagentoItemCustomOptions: Page "NPR Magento Item Cstm Options";
                        begin
                            //-MAG1.22
                            Clear(MagentoItemCustomOptions);
                            MagentoItemCustomOptions.SetItemNo("No.");
                            MagentoItemCustomOptions.Run;
                            //+MAG1.22
                        end;
                    }
                    field(Backorder; "NPR Backorder")
                    {
                        ApplicationArea = All;
                    }
                    field("Display Only"; "NPR Display Only")
                    {
                        ApplicationArea = All;
                        ToolTip = 'test';
                    }
                    field("Display only Text"; "NPR Display only Text")
                    {
                        ApplicationArea = All;
                    }
                    field("Seo Link"; "NPR Seo Link")
                    {
                        ApplicationArea = All;
                    }
                    field("Meta Title"; "NPR Meta Title")
                    {
                        ApplicationArea = All;
                    }
                    field("Meta Description"; "NPR Meta Description")
                    {
                        ApplicationArea = All;
                    }
                    field("Attribute Set ID"; "NPR Attribute Set ID")
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Editable = NOT "NPR Magento Item";
                        Visible = MagentoEnabledAttributeSet;

                        trigger OnAssistEdit()
                        var
                            MagentoAttributeSetMgt: Codeunit "NPR Magento Attr. Set Mgt.";
                        begin
                            if "NPR Attribute Set ID" <> 0 then begin
                                CurrPage.Update(true);
                                //-MAG1.21
                                //MagentoAttributeSetMgt.EditItemAttributes("No.",'',FALSE);
                                MagentoAttributeSetMgt.EditItemAttributes("No.", '');
                                //+MAG1.21
                            end;
                        end;
                    }
                }
                group(Control6151430)
                {
                    ShowCaption = false;
                    Visible = MagentoPictureVarietyTypeVisible;
                    field("Magento Picture Variety Type"; "NPR Magento Pict. Variety Type")
                    {
                        ApplicationArea = All;
                    }
                }
                part("Category Links"; "NPR Magento Category Links")
                {
                    Caption = 'Category Links';
                    SubPageLink = "Item No." = FIELD("No.");
                    Visible = NOT MagentoEnabledMultiStore;
                    ApplicationArea = All;
                }
                part("Product Relations"; "NPR Magento Product Relations")
                {
                    Caption = 'Product Relations';
                    SubPageLink = "From Item No." = FIELD("No.");
                    Visible = MagentoEnabledProductRelations;
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6150614; Links)
            {
                Visible = true;
                ApplicationArea = All;
            }
            systempart(Control6150613; Notes)
            {
                Visible = true;
                ApplicationArea = All;
            }
            part(ItemAttributesFactbox; "Item Attributes Factbox")
            {
                ApplicationArea = Basic, Suite;
            }
            part(MagentoPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Magento Picture';
                Visible = MagentoEnabled;
                ApplicationArea = All;
            }
            part(Picture; "NPR Magento Item Pict. Factbox")
            {
                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "No." = FIELD("No.");
                Visible = MagentoEnabled;
                ApplicationArea = All;
            }
            part("Discount FactBox"; "NPR Discount FactBox")
            {
                Caption = 'Discounts';
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = All;
            }
            part(NPAttributes; "NPR NP Attributes FactBox")
            {
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Master Data")
            {
                Caption = 'Master Data';
                Image = "<DataEntry>";
                action("&Units of Measure")
                {
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    RunObject = Page "Item Units of Measure";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("Va&riants")
                {
                    Caption = 'Va&riants';
                    Image = ItemVariant;
                    RunObject = Page "Item Variants";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action(Attributes)
                {
                    AccessByPermission = TableData "Item Attribute" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attributes';
                    Image = Category;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = New;
                    ToolTip = 'View or edit the item''s attributes, such as color, size, or other characteristics that help to describe the item.';

                    trigger OnAction()
                    begin
                        //-#361229 [361229]
                        PAGE.RunModal(PAGE::"Item Attribute Value Editor", Rec);
                        CurrPage.SaveRecord;
                        CurrPage.ItemAttributesFactbox.PAGE.LoadItemAttributesData("No.");
                        //+#361229 [361229]
                    end;
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                }
                action(Action6150810)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(27),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                }
                action("Substituti&ons")
                {
                    Caption = 'Substituti&ons';
                    Image = ItemSubstitution;
                    RunObject = Page "Item Substitution Entry";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("Cross Re&ferences")
                {
                    Caption = 'Cross Re&ferences';
                    Image = Change;
                    RunObject = Page "Item Cross Reference Entries";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("E&xtended Texts")
                {
                    Caption = 'E&xtended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
                    ApplicationArea = All;
                }
                action(Translations)
                {
                    Caption = 'Translations';
                    Image = Translations;
                    RunObject = Page "Item Translations";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("&Picture")
                {
                    Caption = '&Picture';
                    Image = Picture;
                    RunObject = Page "Item Picture";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Location Filter" = FIELD("Location Filter"),
                                  "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                  "Variant Filter" = FIELD("Variant Filter");
                    ApplicationArea = All;
                }
                action(Identifiers)
                {
                    Caption = 'Identifiers';
                    Image = BarCode;
                    RunObject = Page "Item Identifiers";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.", "Variant Code", "Unit of Measure Code");
                    ApplicationArea = All;
                }
            }
            group(Availability)
            {
                Caption = 'Availability';
                Image = ItemAvailability;
                action(ItemsByLocation)
                {
                    Caption = 'Items b&y Location';
                    Image = ItemAvailbyLoc;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ItemsByLocation: Page "Items by Location";
                    begin
                        ItemsByLocation.SetRecord(Rec);
                        ItemsByLocation.Run;
                    end;
                }
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("<Action110>")
                    {
                        Caption = 'Event';
                        Image = "Event";
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action(Action6150798)
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action(Location)
                    {
                        Caption = 'Location';
                        Image = Warehouse;
                        RunObject = Page "Item Availability by Location";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                    action(Timeline)
                    {
                        Caption = 'Timeline';
                        Image = Timeline;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            ShowTimelineFromItem(Rec);
                        end;
                    }
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Ledger E&ntries")
                    {
                        Caption = 'Ledger E&ntries';
                        Image = ItemLedger;
                        Promoted = false;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                        ShortCutKey = 'Ctrl+F7';
                        ApplicationArea = All;
                    }
                    action("&Reservation Entries")
                    {
                        Caption = '&Reservation Entries';
                        Image = ReservationLedger;
                        RunObject = Page "Reservation Entries";
                        RunPageLink = "Reservation Status" = CONST(Reservation),
                                      "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.", "Variant Code", "Location Code", "Reservation Status");
                        ApplicationArea = All;
                    }
                    action("&Phys. Inventory Ledger Entries")
                    {
                        Caption = '&Phys. Inventory Ledger Entries';
                        Image = PhysicalInventoryLedger;
                        RunObject = Page "Phys. Inventory Ledger Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                        ApplicationArea = All;
                    }
                    action("&Value Entries")
                    {
                        Caption = '&Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                        ApplicationArea = All;
                    }
                    action("Item &Tracking Entries")
                    {
                        Caption = 'Item &Tracking Entries';
                        Image = ItemTrackingLedger;
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
                        begin
                            //-NPR4.17
                            //ItemTrackingMgt.CallItemTrackingEntryForm(3,'',"No.",'','','','');
                            ItemTrackingDocMgt.ShowItemTrackingForMasterData(3, '', "No.", '', '', '', '');
                            //+NPR4.17
                        end;
                    }
                    action("&Warehouse Entries")
                    {
                        Caption = '&Warehouse Entries';
                        Image = BinLedger;
                        RunObject = Page "Warehouse Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated);
                        ApplicationArea = All;
                    }
                    action("Application Worksheet")
                    {
                        Caption = 'Application Worksheet';
                        Image = ApplicationWorksheet;
                        RunObject = Page "Application Worksheet";
                        RunPageLink = "Item No." = FIELD("No.");
                        ApplicationArea = All;
                    }
                    action(POSSalesEntries)
                    {
                        Caption = 'POS Sales Entries';
                        Image = Entries;
                        ApplicationArea = All;
                    }
                }
                group(ActionGroup6150785)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    action(Statistics)
                    {
                        Caption = 'Statistics';
                        Image = Statistics;
                        Promoted = true;
                        PromotedCategory = Process;
                        ShortCutKey = 'F7';
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            ItemStatistics: Page "Item Statistics";
                        begin
                            ItemStatistics.SetItem(Rec);
                            ItemStatistics.RunModal;
                        end;
                    }
                    action("Entry Statistics")
                    {
                        Caption = 'Entry Statistics';
                        Image = EntryStatistics;
                        RunObject = Page "Item Entry Statistics";
                        RunPageLink = "No." = FIELD("No."),
                                      "Date Filter" = FIELD("Date Filter"),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action("T&urnover")
                    {
                        Caption = 'T&urnover';
                        Image = Turnover;
                        RunObject = Page "Item Turnover";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                    ApplicationArea = All;
                }
            }
            group("&Purchases")
            {
                Caption = '&Purchases';
                Image = Purchasing;
                action("Ven&dors")
                {
                    Caption = 'Ven&dors';
                    Image = Vendor;
                    RunObject = Page "Item Vendor Catalog";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ApplicationArea = All;
                }
                action(Prices)
                {
                    Caption = 'Prices';
                    Image = Price;
                    RunObject = Page "Purchase Prices";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ApplicationArea = All;
                }
                action("Line Discounts")
                {
                    Caption = 'Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Purchase Line Discounts";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("Prepa&yment Percentages")
                {
                    Caption = 'Prepa&yment Percentages';
                    Image = PrepaymentPercentages;
                    RunObject = Page "Purchase Prepmt. Percentages";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                separator(Separator6150775)
                {
                }
                action(Orders)
                {
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = Page "Purchase Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                    ApplicationArea = All;
                }
                action("Return Orders")
                {
                    Caption = 'Return Orders';
                    Image = ReturnOrder;
                    RunObject = Page "Purchase Return Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                    ApplicationArea = All;
                }
                action("Nonstoc&k Items")
                {
                    Caption = 'Nonstoc&k Items';
                    Image = NonStockItem;
                    RunObject = Page "Catalog Item List";
                    ApplicationArea = All;
                }
            }
            group("S&ales")
            {
                Caption = 'S&ales';
                Image = Sales;
                action(Action6150770)
                {
                    Caption = 'Prices';
                    Image = Price;
                    RunObject = Page "Sales Prices";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ApplicationArea = All;
                }
                action(Action6150769)
                {
                    Caption = 'Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Sales Line Discounts";
                    RunPageLink = Type = CONST(Item),
                                  Code = FIELD("No.");
                    RunPageView = SORTING(Type, Code);
                    ApplicationArea = All;
                }
                action(Action6150768)
                {
                    Caption = 'Prepa&yment Percentages';
                    Image = PrepaymentPercentages;
                    RunObject = Page "Sales Prepayment Percentages";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                separator(Separator6150767)
                {
                }
                action(Action6150766)
                {
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = Page "Sales Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                    ApplicationArea = All;
                }
                action(Action6150765)
                {
                    Caption = 'Return Orders';
                    Image = ReturnOrder;
                    RunObject = Page "Sales Return Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                    ApplicationArea = All;
                }
                action("Recommended Items")
                {
                    Caption = 'Recommended Items';
                    Image = SuggestLines;
                    RunObject = Page "NPR MCS Recomm. Lines";
                    RunPageLink = "Seed Item No." = FIELD("No."),
                                  "Table No." = CONST(27);
                    ApplicationArea = All;
                }
            }
            group("Assembly/Production")
            {
                Caption = 'Assembly/Production';
                Image = Production;
                action(Structure)
                {
                    Caption = 'Structure';
                    Image = Hierarchy;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        BOMStructure: Page "BOM Structure";
                    begin
                        BOMStructure.InitItem(Rec);
                        BOMStructure.Run;
                    end;
                }
                action("Cost Shares")
                {
                    Caption = 'Cost Shares';
                    Image = CostBudget;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        BOMCostShares: Page "BOM Cost Shares";
                    begin
                        BOMCostShares.InitItem(Rec);
                        BOMCostShares.Run;
                    end;
                }
                group("Assemb&ly")
                {
                    Caption = 'Assemb&ly';
                    Image = AssemblyBOM;
                    action(AssemblyBOM)
                    {
                        Caption = 'Assembly BOM';
                        Image = BOM;
                        RunObject = Page "Assembly BOM";
                        RunPageLink = "Parent Item No." = FIELD("No.");
                        ApplicationArea = All;
                    }
                    action("Where-Used")
                    {
                        Caption = 'Where-Used';
                        Image = Track;
                        RunObject = Page "Where-Used List";
                        RunPageLink = Type = CONST(Item),
                                      "No." = FIELD("No.");
                        RunPageView = SORTING(Type, "No.");
                        ApplicationArea = All;
                    }
                    action("Calc. Stan&dard Cost")
                    {
                        Caption = 'Calc. Stan&dard Cost';
                        Image = CalculateCost;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            Clear(CalculateStdCost);
                            CalculateStdCost.CalcItem("No.", true);
                        end;
                    }
                    action("Calc. Unit Price")
                    {
                        Caption = 'Calc. Unit Price';
                        Image = SuggestItemPrice;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            Clear(CalculateStdCost);
                            CalculateStdCost.CalcAssemblyItemPrice("No.")
                        end;
                    }
                }
                group(Production)
                {
                    Caption = 'Production';
                    Image = Production;
                    action("Production BOM")
                    {
                        Caption = 'Production BOM';
                        Image = BOM;
                        RunObject = Page "Production BOM";
                        RunPageLink = "No." = FIELD("No.");
                        ApplicationArea = All;
                    }
                    action(Action6150754)
                    {
                        Caption = 'Where-Used';
                        Image = "Where-Used";
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
                        begin
                            ProdBOMWhereUsed.SetItem(Rec, WorkDate);
                            ProdBOMWhereUsed.RunModal;
                        end;
                    }
                    action(Action6150753)
                    {
                        Caption = 'Calc. Stan&dard Cost';
                        Image = CalculateCost;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            Clear(CalculateStdCost);
                            CalculateStdCost.CalcItem("No.", false);
                        end;
                    }
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                Image = Warehouse;
                action("&Bin Contents")
                {
                    Caption = '&Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Item Bin Contents";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ApplicationArea = All;
                }
                action("Stockkeepin&g Units")
                {
                    Caption = 'Stockkeepin&g Units';
                    Image = SKU;
                    RunObject = Page "Stockkeeping Unit List";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ApplicationArea = All;
                }
            }
            group(Service)
            {
                Caption = 'Service';
                Image = ServiceItem;
                action("Ser&vice Items")
                {
                    Caption = 'Ser&vice Items';
                    Image = ServiceItem;
                    RunObject = Page "Service Items";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ApplicationArea = All;
                }
                action(Troubleshooting)
                {
                    Caption = 'Troubleshooting';
                    Image = Troubleshoot;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        TroubleshootingHeader: Record "Troubleshooting Header";
                    begin
                        TroubleshootingHeader.ShowForItem(Rec);
                    end;
                }
                action("Troubleshooting Setup")
                {
                    Caption = 'Troubleshooting Setup';
                    Image = Troubleshoot;
                    RunObject = Page "Troubleshooting Setup";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    ApplicationArea = All;
                }
            }
            group(Resources)
            {
                Caption = 'Resources';
                Image = Resource;
                group("R&esource")
                {
                    Caption = 'R&esource';
                    Image = Resource;
                    action("Resource Skills")
                    {
                        Caption = 'Resource Skills';
                        Image = ResourceSkills;
                        RunObject = Page "Resource Skills";
                        RunPageLink = Type = CONST(Item),
                                      "No." = FIELD("No.");
                        ApplicationArea = All;
                    }
                    action("Skilled Resources")
                    {
                        Caption = 'Skilled Resources';
                        Image = ResourceSkills;
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            ResourceSkill: Record "Resource Skill";
                        begin
                            Clear(SkilledResourceList);
                            SkilledResourceList.Initialize(ResourceSkill.Type::Item.AsInteger(), "No.", Description);
                            SkilledResourceList.RunModal;
                        end;
                    }
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                action(Pictures)
                {
                    Caption = 'Pictures';
                    Image = Picture;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MagentoVariantPictureList: Page "NPR Magento Item Pict. List";
                    begin
                        //-MAG1.21
                        TestField("No.");
                        //CLEAR(MagentoVariantPictureList);
                        FilterGroup(2);
                        MagentoVariantPictureList.SetItemNo("No.");
                        FilterGroup(0);

                        MagentoVariantPictureList.Run();
                        //+MAG1.21
                    end;
                }
                action(Videos)
                {
                    Caption = 'Videos';
                    Image = Camera;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "NPR Magento Video Links";
                    RunPageLink = "Item No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action(Webshops)
                {
                    Caption = 'Webshops';
                    Image = Web;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledMultistore;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MagentoStoreItem: Record "NPR Magento Store Item";
                        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
                    begin
                        //-MAG1.21
                        MagentoItemMgt.SetupMultiStoreData(Rec);
                        MagentoStoreItem.FilterGroup(0);
                        MagentoStoreItem.SetRange("Item No.", "No.");
                        MagentoStoreItem.FilterGroup(2);
                        PAGE.Run(PAGE::"NPR Magento Store Items", MagentoStoreItem);
                        //+MAG1.21
                    end;
                }
                action(DisplayConfig)
                {
                    Caption = 'Display Config';
                    Image = ViewPage;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledDisplayConfig;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MagentoDisplayConfig: Record "NPR Magento Display Config";
                        MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                    begin
                        //-MAG1.21
                        MagentoDisplayConfig.SetRange("No.", "No.");
                        MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Item);
                        MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                        MagentoDisplayConfigPage.Run;
                        //+MAG1.21
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("&Create Stockkeeping Unit")
                {
                    Caption = '&Create Stockkeeping Unit';
                    Image = CreateSKU;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin
                        Item.SetRange("No.", "No.");
                        REPORT.RunModal(REPORT::"Create Stockkeeping Unit", true, false, Item);
                    end;
                }
                action("C&alculate Counting Period")
                {
                    Caption = 'C&alculate Counting Period';
                    Image = CalculateCalendar;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
                    begin
                        PhysInvtCountMgt.UpdateItemPhysInvtCount(Rec);
                    end;
                }
                action("Apply Template")
                {
                    Caption = 'Apply Template';
                    Ellipsis = true;
                    Image = ApplyTemplate;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ConfigTemplateMgt: Codeunit "Config. Template Management";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        ConfigTemplateMgt.UpdateFromTemplateSelection(RecRef);
                    end;
                }
            }
            action("Requisition Worksheet")
            {
                Caption = 'Requisition Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Req. Worksheet";
                ApplicationArea = All;
            }
            action("Item Journal")
            {
                Caption = 'Item Journal';
                Image = Journals;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Retail Item Journal";
                ApplicationArea = All;
            }
            action("Item Reclassification Journal")
            {
                Caption = 'Item Reclassification Journal';
                Image = Journals;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Retail ItemReclass.Journal";
                ApplicationArea = All;
            }
            separator(Separator6150718)
            {
            }
            action("Item Tracing")
            {
                Caption = 'Item Tracing';
                Image = ItemTracing;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Item Tracing";
                ApplicationArea = All;
            }
            separator(Separator6150719)
            {
            }
            action(ReplicateThisItem)
            {
                Caption = 'Replicate this Item';
                Image = Copy;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ReplicateItem;
                end;
            }
            group("Transfer to")
            {
                Caption = 'Transfer to';
                Image = "Action";
                action("Transfer to Retail Journal")
                {
                    Caption = 'Transfer to Retail Journal';
                    Image = TransferToGeneralJournal;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RetailJournalHeader: Record "NPR Retail Journal Header";
                        RetailJournalLine: Record "NPR Retail Journal Line";
                        InputDialog: Page "NPR Input Dialog";
                        TempInt: Integer;
                        TempQty: Integer;
                        t001: Label 'Quantity to be transfered to UPDATED?';
                    begin
                        if PAGE.RunModal(PAGE::"NPR Retail Journal List", RetailJournalHeader) <> ACTION::LookupOK then
                            exit;

                        RetailJournalLine.Reset;
                        RetailJournalLine.SetRange("No.", RetailJournalHeader."No.");
                        if RetailJournalLine.Find('+') then
                            TempInt := RetailJournalLine."Line No." + 10000
                        else
                            TempInt := 10000;

                        TempQty := 1;

                        InputDialog.SetInput(1, TempQty, t001);
                        if InputDialog.RunModal = ACTION::OK then
                            InputDialog.InputInteger(1, TempQty);

                        RetailJournalLine.Init;
                        RetailJournalLine."No." := RetailJournalHeader."No.";
                        RetailJournalLine."Line No." := TempInt;
                        RetailJournalLine.Validate("Item No.", Rec."No.");
                        RetailJournalLine.Validate("Quantity to Print", TempQty);
                        RetailJournalLine.Insert;
                        //+TS
                        //CurrForm.S¢gkode.ACTIVATE;
                        //-TS
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Shift+F8';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        PrintLabelAndDisplay: Codeunit "NPR Label Library";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        //-NPR5.22
                        //PrintLabelAndDisplay.ResolveVariantAndPrintItem(Rec);
                        PrintLabelAndDisplay.ResolveVariantAndPrintItem(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                        //+NPR5.22

                        //+TS
                        //CurrForm.S¢gkode.ACTIVATE;
                        //-TS
                    end;
                }
            }
            group("Variant")
            {
                Caption = 'Variant';
                Description = 'Action';
                Image = Setup;
                action("Variety Matrix")
                {
                    Caption = 'Variety Matrix';
                    Image = ItemVariant;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        VRTWrapper: Codeunit "NPR Variety Wrapper";
                    begin
                        //-VRT1.00
                        VRTWrapper.ShowVarietyMatrix(Rec, 0);
                        //+VRT1.00
                    end;
                }
                action("Variety Maintenance")
                {
                    Caption = 'Variety Maintenance';
                    Image = ItemVariant;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Ctrl+Alt+v';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        VRTWrapper: Codeunit "NPR Variety Wrapper";
                    begin
                        //-VRT1.11
                        VRTWrapper.ShowMaintainItemMatrix(Rec, 0);
                        //+VRT1.11
                    end;
                }
                action("Add missing Barcode(s)")
                {
                    Caption = 'Add missing Barcode(s)';
                    Image = BarCode;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+B';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        //-VRT1.11
                        VRTCloneData.AssignBarcodes(Rec);
                        //+VRT1.11
                    end;
                }
            }
            group(Relateret)
            {
                Caption = 'Related';
                action(Accessories)
                {
                    Caption = 'Accessories';
                    Image = Allocations;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin

                        AccessorySparePart.FilterGroup := 2;
                        AccessorySparePart.SetRange(Code, "No.");
                        AccessorySparePart.SetRange(Type, AccessorySparePart.Type::Accessory);
                        AccessorySparePart.FilterGroup := 2;

                        PAGE.RunModal(PAGE::"NPR Accessory List", AccessorySparePart);
                    end;
                }
                separator(Separator6150694)
                {
                }
                action("POS Info")
                {
                    Caption = 'POS Info';
                    Image = Info;
                    RunObject = Page "NPR POS Info Links";
                    RunPageLink = "Table ID" = CONST(27),
                                  "Primary Key" = FIELD("No.");
                    ApplicationArea = All;
                }
            }
            group("Price Management")
            {
                Caption = 'Price Management';
                action("Multiple Unit Prices")
                {
                    Caption = 'Multiple Unit Prices';
                    Image = Price;
                    RunObject = Page "NPR Quantity Discount Card";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageMode = Edit;
                    ApplicationArea = All;
                }
                action("Period Discount")
                {
                    Caption = 'Period Discount';
                    Image = Period;
                    ShortCutKey = 'Ctrl+P';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CampaignDiscountLines: Page "NPR Campaign Discount Lines";
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                    begin
                        Clear(CampaignDiscountLines);
                        CampaignDiscountLines.Editable(false);
                        PeriodDiscountLine.Reset;
                        //-NPR5.40
                        PeriodDiscountLine.SetRange(Status, PeriodDiscountLine.Status::Active);
                        //+NPR5.40
                        PeriodDiscountLine.SetRange("Item No.", "No.");
                        CampaignDiscountLines.SetTableView(PeriodDiscountLine);
                        CampaignDiscountLines.RunModal;
                    end;
                }
                action("Mix Discount")
                {
                    Caption = 'Mix Discount';
                    Image = Discount;
                    ShortCutKey = 'Ctrl+F';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MixedDiscountLines: Page "NPR Mixed Discount Lines";
                        MixedDiscountLine: Record "NPR Mixed Discount Line";
                    begin
                        Clear(MixedDiscountLines);
                        MixedDiscountLines.Editable(false);
                        MixedDiscountLine.Reset;
                        MixedDiscountLine.SetRange("No.", "No.");
                        MixedDiscountLines.SetTableView(MixedDiscountLine);
                        MixedDiscountLines.RunModal;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetRange("No.");
        //-NPR5.36 [289871]
        OriginalRec := Rec;
        //+NPR5.36 [289871]

        //-MAG1.14
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetItemNo("No.");
        //-MAG1.21
        //CurrPage.MagentoPictureDragDropAddin.PAGE.SetRecordPosition(0,CurrPage.MagentoPictureLinkSubform.PAGE.GetPictureName);
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetHidePicture(true);
        //+MAG1.21
        //+MAG1.14
        //-NPR5.43 [314830]
        ItemCostMgt.CalculateAverageCost(Rec, AverageCostLCY, AverageCostACY)
        //+NPR5.43 [314830]
    end;

    trigger OnAfterGetRecord()
    begin
        EnablePlanningControls;
        EnableCostingControls;

        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Item, "No.");
        NPRAttrEditable := CurrPage.Editable();
    end;

    trigger OnInit()
    begin
        UnitCostEnable := true;
        StandardCostEnable := true;
        OverflowLevelEnable := true;
        DampenerQtyEnable := true;
        DampenerPeriodEnable := true;
        LotAccumulationPeriodEnable := true;
        ReschedulingPeriodEnable := true;
        IncludeInventoryEnable := true;
        OrderMultipleEnable := true;
        MaximumOrderQtyEnable := true;
        MinimumOrderQtyEnable := true;
        MaximumInventoryEnable := true;
        ReorderQtyEnable := true;
        ReorderPointEnable := true;
        SafetyStockQtyEnable := true;
        SafetyLeadTimeEnable := true;
        TimeBucketEnable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        EnablePlanningControls;
        EnableCostingControls;
    end;

    trigger OnOpenPage()
    begin
        //-MAG1.21
        //SetMagentoVisible();
        SetMagentoEnabled();
        //+MAG1.21
        //-MAG2.06 [286203]
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetAutoOverwrite(true);
        //+MAG2.06 [286203]

        //-NPR4.11
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
        //+NPR4.11


        //-NPR5.34 [284384]
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
        //-NPR5.34 [284384]

        //-NPR4.11
        NPRAttrEditable := CurrPage.Editable();
        //+NPR4.11
    end;

    var
        SkilledResourceList: Page "Skilled Resource List";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        [InDataSet]
        TimeBucketEnable: Boolean;
        [InDataSet]
        SafetyLeadTimeEnable: Boolean;
        [InDataSet]
        SafetyStockQtyEnable: Boolean;
        [InDataSet]
        ReorderPointEnable: Boolean;
        [InDataSet]
        ReorderQtyEnable: Boolean;
        [InDataSet]
        MaximumInventoryEnable: Boolean;
        [InDataSet]
        MinimumOrderQtyEnable: Boolean;
        [InDataSet]
        MaximumOrderQtyEnable: Boolean;
        [InDataSet]
        OrderMultipleEnable: Boolean;
        [InDataSet]
        IncludeInventoryEnable: Boolean;
        [InDataSet]
        ReschedulingPeriodEnable: Boolean;
        [InDataSet]
        LotAccumulationPeriodEnable: Boolean;
        [InDataSet]
        DampenerPeriodEnable: Boolean;
        [InDataSet]
        DampenerQtyEnable: Boolean;
        [InDataSet]
        OverflowLevelEnable: Boolean;
        [InDataSet]
        StandardCostEnable: Boolean;
        [InDataSet]
        UnitCostEnable: Boolean;
        AccessorySparePart: Record "NPR Accessory/Spare Part";
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        Barcode: Code[13];
        AverageCostLCY: Decimal;
        AverageCostACY: Decimal;
        ItemCostMgt: Codeunit ItemCostManagement;
        Text10600005: Label '%1 does not exist as alt. item no. or as item no.!';
        Text10600012: Label 'Enter item number for new item';
        ErrItemGroup: Label 'Itemgroup does not exists!';
        NPRAttrTextArray: array[40] of Text[250];
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
        Text6151400: Label 'Update Seo Link?';
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
        SearchNo: Code[20];
        OriginalRec: Record Item;

    procedure EnablePlanningControls()
    var
        PlanningGetParam: Codeunit "Planning-Get Parameters";
        TimeBucketEnabled: Boolean;
        SafetyLeadTimeEnabled: Boolean;
        SafetyStockQtyEnabled: Boolean;
        ReorderPointEnabled: Boolean;
        ReorderQtyEnabled: Boolean;
        MaximumInventoryEnabled: Boolean;
        MinimumOrderQtyEnabled: Boolean;
        MaximumOrderQtyEnabled: Boolean;
        OrderMultipleEnabled: Boolean;
        IncludeInventoryEnabled: Boolean;
        ReschedulingPeriodEnabled: Boolean;
        LotAccumulationPeriodEnabled: Boolean;
        DampenerPeriodEnabled: Boolean;
        DampenerQtyEnabled: Boolean;
        OverflowLevelEnabled: Boolean;
    begin
        PlanningGetParam.SetUpPlanningControls("Reordering Policy", "Include Inventory",
          TimeBucketEnabled, SafetyLeadTimeEnabled, SafetyStockQtyEnabled,
          ReorderPointEnabled, ReorderQtyEnabled, MaximumInventoryEnabled,
          MinimumOrderQtyEnabled, MaximumOrderQtyEnabled, OrderMultipleEnabled, IncludeInventoryEnabled,
          ReschedulingPeriodEnabled, LotAccumulationPeriodEnabled,
          DampenerPeriodEnabled, DampenerQtyEnabled, OverflowLevelEnabled);

        TimeBucketEnable := TimeBucketEnabled;
        SafetyLeadTimeEnable := SafetyLeadTimeEnabled;
        SafetyStockQtyEnable := SafetyStockQtyEnabled;
        ReorderPointEnable := ReorderPointEnabled;
        ReorderQtyEnable := ReorderQtyEnabled;
        MaximumInventoryEnable := MaximumInventoryEnabled;
        MinimumOrderQtyEnable := MinimumOrderQtyEnabled;
        MaximumOrderQtyEnable := MaximumOrderQtyEnabled;
        OrderMultipleEnable := OrderMultipleEnabled;
        IncludeInventoryEnable := IncludeInventoryEnabled;
        ReschedulingPeriodEnable := ReschedulingPeriodEnabled;
        LotAccumulationPeriodEnable := LotAccumulationPeriodEnabled;
        DampenerPeriodEnable := DampenerPeriodEnabled;
        DampenerQtyEnable := DampenerQtyEnabled;
        OverflowLevelEnable := OverflowLevelEnabled;
    end;

    procedure EnableCostingControls()
    begin
        StandardCostEnable := "Costing Method" = "Costing Method"::Standard;
        UnitCostEnable := "Costing Method" <> "Costing Method"::Standard;
    end;

    procedure CheckItemGroup()
    begin
        if ("NPR Item Group" = '') then
            FieldError("NPR Item Group");
    end;

    procedure ReplicateItem()
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
        ItemCopy."Search Description" := Description;
        //-NPR5.43
        ItemCopy."NPR Label Barcode" := '';
        ItemCopy."Net Weight" := 0;
        CalcFields("NPR Magento Description");
        ItemCopy."NPR Magento Description" := "NPR Magento Description";
        //+NPR5.43
        ItemCopy.Insert(true);

        ItemUnitofMeasure.SetRange("Item No.", "No.");
        if ItemUnitofMeasure.Find('-') then begin
            repeat
                ItemUnitofMeasureNew.Copy(ItemUnitofMeasure);
                ItemUnitofMeasureNew."Item No." := NewItemNo;
                if ItemUnitofMeasureNew.Insert then;
            until ItemUnitofMeasure.Next = 0;
        end;

        Get(ItemCopy."No.");
        //+TS
        //CurrForm.UPDATE(FALSE);
        CurrPage.Update(false);
        //-TS
    end;

    procedure SetMagentoEnabled()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG1.21
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;

        MagentoEnabled := true;
        MagentoEnabledBrand := MagentoSetup."Brands Enabled";
        MagentoEnabledAttributeSet := MagentoSetup."Attributes Enabled";
        MagentoEnabledSpecialPrices := MagentoSetup."Special Prices Enabled";
        MagentoEnabledMultistore := MagentoSetup."Multistore Enabled";
        MagentoEnabledDisplayConfig := MagentoSetup."Customers Enabled";
        //+MAG1.21
        //-MAG1.22
        MagentoEnabledProductRelations := MagentoSetup."Product Relations Enabled";
        MagentoEnabledCustomOptions := MagentoSetup."Custom Options Enabled";
        //+MAG1.22
        //-MAG2.22 [359285]
        MagentoPictureVarietyTypeVisible :=
          (MagentoSetup."Variant System" = MagentoSetup."Variant System"::Variety) and
          (MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::"Select on Item");
        //+MAG2.22 [359285]
    end;
}


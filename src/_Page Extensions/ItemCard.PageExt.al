pageextension 6014430 "NPR Item Card" extends "Item Card"
{
    // VRT1.00/JDH /20150304 CASE 201022 Variety Page Added + Fields + shortcut to Matrix under button Item
    // NPR4.10/TSA /20150422 CASE 209946 - Shortcut Attributes
    // NPR4.11/TSA /20150625 CASE 209946 - Shortcut Attributes
    // NPR4.15/JDH /20151001 CASE 224204 Caption changed from GL to Item on the ledger entries lookup
    // NPR4.21/OSFI/20160223 CASE 233660 Added Action <Action6150637> for showing inventory across companies
    // NPR5.22/TJ/  20160411 CASE 238601 Moved code from actions Variety and All Attributes Values to NPR Event Subscriber codeunit
    //                                   Fixed caption of Ledger Entries action to show standard caption (Finansposter instead of Vareposter)
    // NPR5.23/JLK /20160525 CASE 242350 Promoted and Promoted Category: Process for Item by Location button
    // NPR5.23/TS  /20160609 CASE 243984 Added field Type to be able to select Service/Inventory
    // NPR5.24/JDH /20160720 CASE 241848 Moved code OnOpenPage + OnAfterGetRecord 2 lines up, so Powershell didnt triggered a mergeConflicts
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.34/JLK /20170630 CASE 279958 Added field Description 2
    // NPR5.38/BR  /20171116 CASE 295255 Added Action POS Sales Entries
    // NPR5.40/JLK /20180316 CASE 308393 Renamed Action Variety to Variety Matrix
    // NPR5.51/THRO/20190717 CASE 361514 Action Variety Matrix named VarietyMatrix (for AL Conversion)
    //                                   Action POS Sales Entries named POSSalesEntries (for AL Conversion)
    layout
    {
        addafter(Description)
        {
            field("NPR Description 2"; "Description 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Prices & Sales")
        {
            group("NPR Variety")
            {
                Caption = 'Variety';
                field("NPR Variety Group"; "NPR Variety Group")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 1"; "NPR Variety 1")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 1 Table"; "NPR Variety 1 Table")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 2"; "NPR Variety 2")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 2 Table"; "NPR Variety 2 Table")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 3"; "NPR Variety 3")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 3 Table"; "NPR Variety 3 Table")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 4"; "NPR Variety 4")
                {
                    ApplicationArea = All;
                }
                field("NPR Variety 4 Table"; "NPR Variety 4 Table")
                {
                    ApplicationArea = All;
                }
                field("NPR Cross Variety No."; "NPR Cross Variety No.")
                {
                    ApplicationArea = All;
                }
            }
            group("NPR Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
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
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
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
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
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
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
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
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
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
            }
        }
    }
    actions
    {
        modify(ItemsByLocation)
        {
            Promoted = true;
            PromotedCategory = Process;
        }
        addafter("Va&riants")
        {
            action("NPR VarietyMatrix")
            {
                Caption = 'Variety Matrix';
                Image = ItemAvailability;
                ShortCutKey = 'Ctrl+Alt+v';
                ApplicationArea=All;
            }
            action("NPR AttributeValues")
            {
                Caption = 'All Attributes Values';
                Image = ShowList;
                ApplicationArea=All;
            }
        }
        addafter("Application Worksheet")
        {
            action("NPR POSSalesEntries")
            {
                Caption = 'POS Sales Entries';
                Image = Entries;
                ApplicationArea=All;
            }
        }
    }

    var
        NPRAttrTextArray: array[40] of Text;
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


    //Unsupported feature: Code Insertion on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //begin
    /*
    //-NPR4.11
    NPRAttrManagement.GetMasterDataAttributeValue (NPRAttrTextArray, DATABASE::Item, "No.");
    NPRAttrEditable := CurrPage.Editable ();
    //+NPR4.11
    */
    //end;


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IsFoundationEnabled := ApplicationAreaMgmtFacade.IsFoundationEnabled;
    EnableControls;
    SetNoFieldVisible;
    IsSaaS := PermissionManager.SoftwareAsAService;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    //-NPR4.11
    NPRAttrManagement.GetAttributeVisibility (DATABASE::Item, NPRAttrVisibleArray);
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

    NPRAttrEditable := CurrPage.Editable ();
    //+NPR4.11

    #1..4
    */
    //end;
}


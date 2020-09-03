pageextension 6014427 "NPR Vendor Card" extends "Vendor Card"
{
    // PN1.00/MH/20140725  NAV-AddOn: PDF2NAV
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // NPR4.11/TSA/20150623 CASE 209946 - Shortcut Attributes
    // NPR9   /LS/20151022  CASE 225607 Merge NAV 2016
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    layout
    {
        addafter("Last Date Modified")
        {
            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,23,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,23,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 2, "No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,23,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 3, "No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,23,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 4, "No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,23,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 5, "No.", NPRAttrTextArray[5]);
                end;
            }
        }
        addafter("Address & Contact")
        {
            group("NPR Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,23,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 6, "No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,23,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 7, "No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,23,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 8, "No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,23,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 9, "No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,23,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Vendor, 10, "No.", NPRAttrTextArray[10]);
                    end;
                }
            }
        }
        addafter("Prices Including VAT")
        {
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
        }
    }

    var
        NPRAttrTextArray: array[40] of Text[100];
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


    //Unsupported feature: Code Modification on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ActivateFields;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    ActivateFields;

    //-NPR4.11
    NPRAttrManagement.GetMasterDataAttributeValue (NPRAttrTextArray, DATABASE::Vendor, "No.");
    NPRAttrEditable := CurrPage.Editable ();
    //+NPR4.11
    */
    //end;


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ActivateFields;
    IsOfficeAddin := OfficeMgt.IsAvailable;
    SetNoFieldVisible;
    IsSaaS := PermissionManager.SoftwareAsAService;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    ActivateFields;

    //-NPR4.11
    NPRAttrManagement.GetAttributeVisibility (DATABASE::Vendor, NPRAttrVisibleArray);
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

    #2..4
    */
    //end;
}


pageextension 50030 pageextension50030 extends "Item List" 
{
    // NPR4.11/TSA/20150623 CASE 209946 - Shortcut Attributes
    // NPR4.18/JLK/20151105 CASE 226296 - Field "Item Group" Added
    // NPR9   /LS/20151022  CASE 225607  Merged to NAV 2016
    // NPR5.24/JDH/20160727 CASE 241848 Moved NPR code on triggers for better Powershell merge
    // NPR5.29/LS  /20161108 CASE 257874 Changed length from 100 to 250 for Global Var "NPRAttrTextArray"
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.38/BR  /20171116 CASE 295255 Added Action POS Sales Entries
    // NPR5.51/THRO/20190717 CASE 361514 Action POS Sales Entries named POSSalesEntries (for AL Conversion)
    layout
    {
        addafter("VAT Prod. Posting Group")
        {
            field("Item Group";"Item Group")
            {
            }
        }
        addafter("Item Tracking Code")
        {
            field(NPRAttrTextArray_01;NPRAttrTextArray[1])
            {
                CaptionClass = '6014555,27,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02;NPRAttrTextArray[2])
            {
                CaptionClass = '6014555,27,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03;NPRAttrTextArray[3])
            {
                CaptionClass = '6014555,27,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04;NPRAttrTextArray[4])
            {
                CaptionClass = '6014555,27,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05;NPRAttrTextArray[5])
            {
                CaptionClass = '6014555,27,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                end;
            }
            field(NPRAttrTextArray_06;NPRAttrTextArray[6])
            {
                CaptionClass = '6014555,27,6,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible06;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 6, "No.", NPRAttrTextArray[6]);
                end;
            }
            field(NPRAttrTextArray_07;NPRAttrTextArray[7])
            {
                CaptionClass = '6014555,27,7,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible07;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 7, "No.", NPRAttrTextArray[7]);
                end;
            }
            field(NPRAttrTextArray_08;NPRAttrTextArray[8])
            {
                CaptionClass = '6014555,27,8,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible08;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 8, "No.", NPRAttrTextArray[8]);
                end;
            }
            field(NPRAttrTextArray_09;NPRAttrTextArray[9])
            {
                CaptionClass = '6014555,27,9,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible09;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 9, "No.", NPRAttrTextArray[9]);
                end;
            }
            field(NPRAttrTextArray_10;NPRAttrTextArray[10])
            {
                CaptionClass = '6014555,27,10,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible10;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 10, "No.", NPRAttrTextArray[10]);
                end;
            }
        }
    }
    actions
    {
        addafter("&Warehouse Entries")
        {
            action(POSSalesEntries)
            {
                Caption = 'POS Sales Entries';
                Image = Entries;
            }
        }
    }

    var
        NPRAttrTextArray: array [40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array [40] of Boolean;
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
        EnableControls;
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        //-NPR4.11
        NPRAttrManagement.GetMasterDataAttributeValue (NPRAttrTextArray, DATABASE::Item, "No.");
        NPRAttrEditable := CurrPage.Editable ();
        //+NPR4.11

        EnableControls;
        */
    //end;


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
        /*
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
        with SocialListeningSetup do
          SocialListeningSetupVisible := Get and "Show on Customers" and "Accept License Agreement" and ("Solution ID" <> '');
        IsFoundationEnabled := ApplicationAreaMgmtFacade.IsFoundationEnabled;
        SetWorkflowManagementEnabledState;
        IsOnPhone := ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Phone;
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
        //+NPR4.11

        #1..6
        */
    //end;
}


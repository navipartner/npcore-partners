pageextension 50023 pageextension50023 extends "Customer List" 
{
    // NPR4.11/TSA/20150623 CASE 209946 - Shortcut Attributes
    // PN1.08/TTH/10122015 CASE 229069 Added Customer Statement Sending
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.22/TJ/20160411 CASE 238601 Implementing danish action captions.
    // NPR5.23/BHR/20160329 CASE 222711 Added PhoneLookup Action.
    // NPR5.24/JDH/20160727 CASE 241848 Moved NPR code on triggers for better Powershell merge
    // NPR5.25/TS/20160622 CASE 244813 Added Action Item Ledger Entries
    // NPR5.29/TJ/20170125 CASE 263507 Moved code from PhoneLookup action to a subscriber and also renamed that action from default to PhoneLookup
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.33/BHR /20172526 CASE 277663 Added action Audit Roll
    // NPR5.35/TS  /20170710  CASE 282995 Added New Button
    // NPR5.35/JDH /20170823 CASE 286307 Added fields to the list - Name 2, address fields and Global Dimension fields - all added as Visible = False
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.42/THRO/20180516 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.51/MAOT/20190717 CASE 359891 Added column 'E-Mail'
    layout
    {
        addafter(Name)
        {
            field("Name 2";"Name 2")
            {
                Visible = false;
            }
            field("E-Mail";"E-Mail")
            {
            }
            field(Address;Address)
            {
                Visible = false;
            }
            field("Address 2";"Address 2")
            {
                Visible = false;
            }
        }
        addafter("Post Code")
        {
            field(City;City)
            {
                Visible = false;
            }
        }
        addafter(Contact)
        {
            field("Global Dimension 1 Code";"Global Dimension 1 Code")
            {
                Visible = false;
            }
            field("Global Dimension 2 Code";"Global Dimension 2 Code")
            {
                Visible = false;
            }
        }
        addafter("Base Calendar Code")
        {
            field(NPRAttrTextArray_01;NPRAttrTextArray[1])
            {
                CaptionClass = '6014555,18,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02;NPRAttrTextArray[2])
            {
                CaptionClass = '6014555,18,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 2, "No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03;NPRAttrTextArray[3])
            {
                CaptionClass = '6014555,18,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 3, "No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04;NPRAttrTextArray[4])
            {
                CaptionClass = '6014555,18,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 4, "No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05;NPRAttrTextArray[5])
            {
                CaptionClass = '6014555,18,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 5, "No.", NPRAttrTextArray[5]);
                end;
            }
            field(NPRAttrTextArray_06;NPRAttrTextArray[6])
            {
                CaptionClass = '6014555,18,6,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible06;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 6, "No.", NPRAttrTextArray[6]);
                end;
            }
            field(NPRAttrTextArray_07;NPRAttrTextArray[7])
            {
                CaptionClass = '6014555,18,7,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible07;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 7, "No.", NPRAttrTextArray[7]);
                end;
            }
            field(NPRAttrTextArray_08;NPRAttrTextArray[8])
            {
                CaptionClass = '6014555,18,8,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible08;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 8, "No.", NPRAttrTextArray[8]);
                end;
            }
            field(NPRAttrTextArray_09;NPRAttrTextArray[9])
            {
                CaptionClass = '6014555,18,9,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible09;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 9, "No.", NPRAttrTextArray[9]);
                end;
            }
            field(NPRAttrTextArray_10;NPRAttrTextArray[10])
            {
                CaptionClass = '6014555,18,10,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible10;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Customer, 10, "No.", NPRAttrTextArray[10]);
                end;
            }
        }
    }
    actions
    {
        addafter("&Customer")
        {
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send Statement as PDF';
                    Image = SendEmailPDF;
                }
            }
        }
        addfirst(History)
        {
            action(AuditRoll)
            {
                Caption = 'Audit Roll';
                Image = ListPage;
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
            }
            action(ItemLedgerEntries)
            {
                Caption = 'Item Ledger Entries';
                Image = ItemLedger;
                Promoted = true;
            }
        }
        addfirst(Creation)
        {
            action(NewCustomer)
            {
                Caption = 'New Customer';
                Image = NewCustomer;
                Promoted = true;
                RunObject = Page "Customer Card";
                RunPageMode = Create;
            }
        }
        addafter("Sales Journal")
        {
            action(PhoneLookup)
            {
                Caption = 'PhoneLookup';
                Image = ImportLog;
            }
        }
    }

    var
        NPRAttrTextArray: array [40] of Text[100];
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


    //Unsupported feature: Code Insertion on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //begin
        /*
        //-NPR4.11
        NPRAttrManagement.GetMasterDataAttributeValue (NPRAttrTextArray, DATABASE::Customer, "No.");
        NPRAttrEditable := CurrPage.Editable ();
        //+NPR4.11
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
        SetWorkflowManagementEnabledState;
        SetFilter("Date Filter",'..%1',WorkDate);
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        //-NPR4.11
        NPRAttrManagement.GetAttributeVisibility (DATABASE::Customer, NPRAttrVisibleArray);
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

        #1..5
        */
    //end;
}

